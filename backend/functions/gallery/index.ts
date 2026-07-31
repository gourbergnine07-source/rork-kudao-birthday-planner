import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Party gallery storage: metadata in Postgres, media files in Supabase Storage.
 *
 * Kudao has no sign-in, so the guest list of a gallery is the share room that
 * already exists for that profile in the Cloudflare worker. Every action asks
 * the worker whether this user may touch this room before it does anything, and
 * only then uses the service role to read or write. The `gallery_items` table is
 * locked by row level security with no policies and the bucket is private, so
 * nothing here is reachable from a client directly.
 */

const BUCKET = "party-memories";
/** Hard ceiling per memory, matching what the app is allowed to send. */
const MAX_BYTES = 26_214_400;
const MAX_ITEMS = 300;
const MAX_CAPTION_LENGTH = 140;
const SIGNED_URL_SECONDS = 3_600;
const MEDIA_TYPES = new Set(["photo", "video"]);
const WORKER_FALLBACK = "https://kudao-planner-backend.rork.app";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type ItemRow = {
  item_id: string;
  uploaded_by: string;
  uploader_name: string;
  media_type: string;
  mime: string;
  byte_size: number;
  duration: number;
  thumbnail_base64: string | null;
  caption: string | null;
  storage_path: string;
  created_at: number;
};

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function admin() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
}

/** The share room is the guest list: owner plus everyone who claimed an invite. */
async function access(roomId: string, userId: string): Promise<{ isMember: boolean; isOwner: boolean }> {
  if (!roomId || !userId) return { isMember: false, isOwner: false };

  const base = (Deno.env.get("EXPO_PUBLIC_RORK_FUNCTIONS_URL") ?? WORKER_FALLBACK).replace(/\/+$/, "");
  try {
    const response = await fetch(
      `${base}/rooms/${encodeURIComponent(roomId)}/access?userId=${encodeURIComponent(userId)}`,
    );
    if (!response.ok) return { isMember: false, isOwner: false };
    const payload = (await response.json()) as { isMember?: boolean; isOwner?: boolean };
    return { isMember: payload.isMember === true, isOwner: payload.isOwner === true };
  } catch (error) {
    console.error("gallery access check failed", error);
    return { isMember: false, isOwner: false };
  }
}

function extensionFor(mediaType: string, mime: string): string {
  if (mediaType === "video") return mime.includes("quicktime") ? "mov" : "mp4";
  if (mime.includes("png")) return "png";
  if (mime.includes("heic") || mime.includes("heif")) return "heic";
  return "jpg";
}

function wire(row: ItemRow) {
  return {
    id: row.item_id,
    uploadedByUserId: row.uploaded_by,
    uploaderName: row.uploader_name,
    mediaType: row.media_type,
    mime: row.mime,
    createdAt: Number(row.created_at),
    byteSize: Number(row.byte_size),
    duration: Number(row.duration),
    thumbnailBase64: row.thumbnail_base64,
    caption: row.caption ?? "",
  };
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json({ error: "not_found" }, 404);

  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  const action = String(body.action ?? "").trim();
  const roomId = String(body.roomId ?? "").trim();
  const userId = String(body.userId ?? "").trim();
  const itemId = String(body.itemId ?? "").trim();

  if (!action || !roomId || !userId) return json({ error: "bad_request" }, 400);

  const permission = await access(roomId, userId);
  if (!permission.isMember) return json({ error: "not_participant" }, 403);

  const supabase = admin();

  try {
    switch (action) {
      case "list": {
        const { data, error } = await supabase
          .from("gallery_items")
          .select("item_id, uploaded_by, uploader_name, media_type, mime, byte_size, duration, thumbnail_base64, caption, storage_path, created_at")
          .eq("room_id", roomId)
          .eq("committed", true)
          .order("created_at", { ascending: false })
          .limit(MAX_ITEMS);

        if (error) throw error;
        return json({ items: (data ?? []).map((row) => wire(row as ItemRow)) });
      }

      case "begin": {
        const mediaType = String(body.mediaType ?? "").trim();
        const mime = String(body.mime ?? "").trim() || (mediaType === "video" ? "video/mp4" : "image/jpeg");
        const byteSize = Number(body.byteSize ?? 0);

        if (!itemId || !MEDIA_TYPES.has(mediaType)) return json({ error: "bad_request" }, 400);
        if (byteSize <= 0 || byteSize > MAX_BYTES) return json({ error: "too_large" }, 413);

        const { count, error: countError } = await supabase
          .from("gallery_items")
          .select("id", { count: "exact", head: true })
          .eq("room_id", roomId)
          .eq("committed", true);
        if (countError) throw countError;
        if ((count ?? 0) >= MAX_ITEMS) return json({ error: "gallery_full" }, 409);

        const { data: existing } = await supabase
          .from("gallery_items")
          .select("uploaded_by")
          .eq("room_id", roomId)
          .eq("item_id", itemId)
          .maybeSingle();
        if (existing && existing.uploaded_by !== userId) return json({ error: "not_uploader" }, 403);

        const path = `${roomId}/${itemId}.${extensionFor(mediaType, mime)}`;
        // A retried upload starts from a clean object.
        await supabase.storage.from(BUCKET).remove([path]);

        const caption = String(body.caption ?? "").trim().slice(0, MAX_CAPTION_LENGTH);
        const { error: upsertError } = await supabase.from("gallery_items").upsert(
          {
            room_id: roomId,
            item_id: itemId,
            uploaded_by: userId,
            uploader_name: String(body.userName ?? "").trim() || "Guest",
            media_type: mediaType,
            mime,
            byte_size: byteSize,
            duration: Number(body.duration ?? 0) || 0,
            thumbnail_base64: (body.thumbnailBase64 as string | null) ?? null,
            caption: caption || null,
            storage_path: path,
            created_at: Number(body.createdAt) || Date.now(),
            committed: false,
            updated_at: new Date().toISOString(),
          },
          { onConflict: "room_id,item_id" },
        );
        if (upsertError) throw upsertError;

        const { data: signed, error: signError } = await supabase.storage
          .from(BUCKET)
          .createSignedUploadUrl(path);
        if (signError || !signed) throw signError ?? new Error("no_signed_url");

        return json({ uploadUrl: signed.signedUrl, path, itemId });
      }

      case "commit": {
        if (!itemId) return json({ error: "bad_request" }, 400);

        const { data: row, error } = await supabase
          .from("gallery_items")
          .select("uploaded_by, storage_path")
          .eq("room_id", roomId)
          .eq("item_id", itemId)
          .maybeSingle();
        if (error) throw error;
        if (!row) return json({ error: "unknown_item" }, 404);
        if (row.uploaded_by !== userId) return json({ error: "not_uploader" }, 403);

        const fileName = String(row.storage_path).split("/").pop() ?? "";
        const { data: listed } = await supabase.storage.from(BUCKET).list(roomId, { search: fileName });
        if (!listed?.some((entry) => entry.name === fileName)) {
          return json({ error: "incomplete_upload" }, 409);
        }

        const { error: updateError } = await supabase
          .from("gallery_items")
          .update({ committed: true, updated_at: new Date().toISOString() })
          .eq("room_id", roomId)
          .eq("item_id", itemId);
        if (updateError) throw updateError;

        return json({ ok: true, itemId });
      }

      case "media": {
        if (!itemId) return json({ error: "bad_request" }, 400);

        const { data: row, error } = await supabase
          .from("gallery_items")
          .select("storage_path, committed")
          .eq("room_id", roomId)
          .eq("item_id", itemId)
          .maybeSingle();
        if (error) throw error;
        if (!row || row.committed !== true) return json({ error: "unknown_item" }, 404);

        const { data: signed, error: signError } = await supabase.storage
          .from(BUCKET)
          .createSignedUrl(String(row.storage_path), SIGNED_URL_SECONDS);
        if (signError || !signed) throw signError ?? new Error("no_signed_url");

        return json({ url: signed.signedUrl });
      }

      case "caption": {
        if (!itemId) return json({ error: "bad_request" }, 400);

        const { data: row, error } = await supabase
          .from("gallery_items")
          .select("uploaded_by")
          .eq("room_id", roomId)
          .eq("item_id", itemId)
          .maybeSingle();
        if (error) throw error;
        if (!row) return json({ error: "unknown_item" }, 404);
        if (row.uploaded_by !== userId) return json({ error: "not_uploader" }, 403);

        const caption = String(body.caption ?? "").trim().slice(0, MAX_CAPTION_LENGTH);
        const { error: updateError } = await supabase
          .from("gallery_items")
          .update({ caption: caption || null, updated_at: new Date().toISOString() })
          .eq("room_id", roomId)
          .eq("item_id", itemId);
        if (updateError) throw updateError;

        return json({ ok: true, itemId, caption });
      }

      case "delete": {
        if (!itemId) return json({ error: "bad_request" }, 400);

        const { data: row, error } = await supabase
          .from("gallery_items")
          .select("uploaded_by, storage_path")
          .eq("room_id", roomId)
          .eq("item_id", itemId)
          .maybeSingle();
        if (error) throw error;
        if (!row) return json({ ok: true });
        if (row.uploaded_by !== userId && !permission.isOwner) {
          return json({ error: "not_uploader" }, 403);
        }

        await supabase.storage.from(BUCKET).remove([String(row.storage_path)]);
        const { error: deleteError } = await supabase
          .from("gallery_items")
          .delete()
          .eq("room_id", roomId)
          .eq("item_id", itemId);
        if (deleteError) throw deleteError;

        return json({ ok: true });
      }

      default:
        return json({ error: "not_found" }, 404);
    }
  } catch (error) {
    console.error("gallery function failure", action, error);
    return json({ error: "server_error" }, 500);
  }
});
