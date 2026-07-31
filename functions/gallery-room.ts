import { DurableObject } from "cloudflare:workers";

/**
 * One instance per birthday profile: the shared party gallery.
 *
 * Media is uploaded in chunks so a single request never has to carry a whole
 * video, and stored as BLOBs inside the object's SQLite storage. Thumbnails are
 * kept inline (base64) so the grid renders without downloading the originals.
 */
type ItemRow = {
  id: string;
  uploaded_by: string;
  uploader_name: string;
  media_type: string;
  mime: string;
  created_at: number;
  byte_size: number;
  chunk_count: number;
  duration: number;
  thumb: string | null;
  committed: number;
};

const MEDIA_TYPES = new Set(["photo", "video"]);
/** Hard ceiling per item, matching what the client is allowed to send. */
const MAX_BYTES = 26_214_400;
const MAX_CHUNK_BYTES = 1_048_576;
const MAX_ITEMS = 300;

function json(data: unknown, status = 200): Response {
  return Response.json(data, { status });
}

export class GalleryRoom extends DurableObject {
  constructor(ctx: DurableObjectState, env: unknown) {
    super(ctx, env);
    const sql = this.ctx.storage.sql;
    sql.exec(`CREATE TABLE IF NOT EXISTS items (
      id TEXT PRIMARY KEY,
      uploaded_by TEXT NOT NULL,
      uploader_name TEXT NOT NULL,
      media_type TEXT NOT NULL,
      mime TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      byte_size INTEGER NOT NULL DEFAULT 0,
      chunk_count INTEGER NOT NULL DEFAULT 0,
      duration REAL NOT NULL DEFAULT 0,
      thumb TEXT,
      committed INTEGER NOT NULL DEFAULT 0
    )`);
    sql.exec(`CREATE TABLE IF NOT EXISTS chunks (
      item_id TEXT NOT NULL,
      idx INTEGER NOT NULL,
      bytes BLOB NOT NULL,
      PRIMARY KEY (item_id, idx)
    )`);
  }

  override async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    try {
      if (request.method === "GET" && path === "/items") {
        return this.list();
      }
      if (request.method === "POST" && path === "/begin") {
        return await this.begin(request);
      }
      if (request.method === "POST" && path === "/chunk") {
        return await this.chunk(request, url);
      }
      if (request.method === "POST" && path === "/commit") {
        return await this.commit(request);
      }
      if (request.method === "GET" && path === "/media") {
        return this.media(url.searchParams.get("itemId") ?? "");
      }
      if (request.method === "POST" && path === "/delete") {
        return await this.remove(request);
      }
    } catch (error) {
      console.error("gallery room failure", path, error);
      return json({ error: "room_failure" }, 500);
    }

    return json({ error: "not_found" }, 404);
  }

  // MARK: - Routes

  /** Metadata of every committed item, newest first. */
  private list(): Response {
    const rows = this.ctx.storage.sql
      .exec<ItemRow>(
        `SELECT id, uploaded_by, uploader_name, media_type, mime, created_at,
                byte_size, chunk_count, duration, thumb, committed
         FROM items WHERE committed = 1 ORDER BY created_at DESC LIMIT ?`,
        MAX_ITEMS,
      )
      .toArray();

    return json({
      items: rows.map((row) => ({
        id: row.id,
        uploadedByUserId: row.uploaded_by,
        uploaderName: row.uploader_name,
        mediaType: row.media_type,
        mime: row.mime,
        createdAt: row.created_at,
        byteSize: row.byte_size,
        duration: row.duration,
        thumbnailBase64: row.thumb,
      })),
    });
  }

  /** Reserves an item row; the media itself arrives as chunks right after. */
  private async begin(request: Request): Promise<Response> {
    const body = (await request.json()) as {
      itemId?: string;
      userId?: string;
      userName?: string;
      mediaType?: string;
      mime?: string;
      createdAt?: number;
      byteSize?: number;
      chunkCount?: number;
      duration?: number;
      thumbnailBase64?: string | null;
    };

    const itemId = (body.itemId ?? "").trim();
    const userId = (body.userId ?? "").trim();
    const mediaType = (body.mediaType ?? "").trim();
    const byteSize = Number(body.byteSize ?? 0);
    const chunkCount = Number(body.chunkCount ?? 0);

    if (!itemId || !userId || !MEDIA_TYPES.has(mediaType)) return json({ error: "bad_request" }, 400);
    if (byteSize <= 0 || byteSize > MAX_BYTES) return json({ error: "too_large" }, 413);
    if (chunkCount <= 0 || chunkCount > 200) return json({ error: "bad_request" }, 400);

    const count = this.ctx.storage.sql
      .exec<{ total: number }>("SELECT COUNT(*) AS total FROM items WHERE committed = 1")
      .toArray()[0];
    if ((count?.total ?? 0) >= MAX_ITEMS) return json({ error: "gallery_full" }, 409);

    // A retried upload starts from a clean slate.
    this.ctx.storage.sql.exec("DELETE FROM chunks WHERE item_id = ?", itemId);
    this.ctx.storage.sql.exec(
      `INSERT INTO items (id, uploaded_by, uploader_name, media_type, mime, created_at,
                          byte_size, chunk_count, duration, thumb, committed)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
       ON CONFLICT(id) DO UPDATE SET
         uploader_name = excluded.uploader_name,
         mime = excluded.mime,
         byte_size = excluded.byte_size,
         chunk_count = excluded.chunk_count,
         duration = excluded.duration,
         thumb = excluded.thumb,
         committed = 0`,
      itemId,
      userId,
      (body.userName ?? "").trim() || "Guest",
      mediaType,
      (body.mime ?? "").trim() || (mediaType === "video" ? "video/mp4" : "image/jpeg"),
      Number(body.createdAt) || Date.now(),
      byteSize,
      chunkCount,
      Number(body.duration) || 0,
      body.thumbnailBase64 ?? null,
    );

    return json({ ok: true, itemId });
  }

  /** Stores one binary slice of an item still being uploaded. */
  private async chunk(request: Request, url: URL): Promise<Response> {
    const itemId = (url.searchParams.get("itemId") ?? "").trim();
    const index = Number(url.searchParams.get("index") ?? "-1");
    const userId = (url.searchParams.get("userId") ?? "").trim();
    if (!itemId || index < 0) return json({ error: "bad_request" }, 400);

    const item = this.item(itemId);
    if (!item) return json({ error: "unknown_item" }, 404);
    if (userId && item.uploaded_by !== userId) return json({ error: "not_uploader" }, 403);
    if (index >= item.chunk_count) return json({ error: "bad_request" }, 400);

    const bytes = await request.arrayBuffer();
    if (bytes.byteLength === 0 || bytes.byteLength > MAX_CHUNK_BYTES) {
      return json({ error: "bad_chunk" }, 413);
    }

    this.ctx.storage.sql.exec(
      `INSERT INTO chunks (item_id, idx, bytes) VALUES (?, ?, ?)
       ON CONFLICT(item_id, idx) DO UPDATE SET bytes = excluded.bytes`,
      itemId,
      index,
      bytes,
    );

    return json({ ok: true, index });
  }

  /** Publishes the item once every chunk has landed. */
  private async commit(request: Request): Promise<Response> {
    const body = (await request.json()) as { itemId?: string; userId?: string };
    const itemId = (body.itemId ?? "").trim();
    const userId = (body.userId ?? "").trim();
    if (!itemId) return json({ error: "bad_request" }, 400);

    const item = this.item(itemId);
    if (!item) return json({ error: "unknown_item" }, 404);
    if (userId && item.uploaded_by !== userId) return json({ error: "not_uploader" }, 403);

    const stored = this.ctx.storage.sql
      .exec<{ total: number }>("SELECT COUNT(*) AS total FROM chunks WHERE item_id = ?", itemId)
      .toArray()[0];

    if ((stored?.total ?? 0) !== item.chunk_count) {
      return json({ error: "incomplete_upload" }, 409);
    }

    this.ctx.storage.sql.exec("UPDATE items SET committed = 1 WHERE id = ?", itemId);
    return json({ ok: true, itemId });
  }

  /** Streams the original media back, rebuilt from its chunks. */
  private media(itemId: string): Response {
    if (!itemId) return json({ error: "bad_request" }, 400);
    const item = this.item(itemId);
    if (!item || item.committed !== 1) return json({ error: "unknown_item" }, 404);

    const rows = this.ctx.storage.sql
      .exec<{ bytes: ArrayBuffer }>("SELECT bytes FROM chunks WHERE item_id = ? ORDER BY idx ASC", itemId)
      .toArray();

    const total = rows.reduce((sum, row) => sum + row.bytes.byteLength, 0);
    const payload = new Uint8Array(total);
    let offset = 0;
    for (const row of rows) {
      payload.set(new Uint8Array(row.bytes), offset);
      offset += row.bytes.byteLength;
    }

    return new Response(payload, {
      status: 200,
      headers: {
        "Content-Type": item.mime,
        "Content-Length": String(total),
        "Cache-Control": "private, max-age=31536000, immutable",
      },
    });
  }

  /** The uploader removes their own memories; the profile owner removes any. */
  private async remove(request: Request): Promise<Response> {
    const body = (await request.json()) as { itemId?: string; userId?: string; isOwner?: boolean };
    const itemId = (body.itemId ?? "").trim();
    const userId = (body.userId ?? "").trim();
    if (!itemId || !userId) return json({ error: "bad_request" }, 400);

    const item = this.item(itemId);
    if (!item) return json({ ok: true });
    if (item.uploaded_by !== userId && body.isOwner !== true) {
      return json({ error: "not_uploader" }, 403);
    }

    this.ctx.storage.sql.exec("DELETE FROM chunks WHERE item_id = ?", itemId);
    this.ctx.storage.sql.exec("DELETE FROM items WHERE id = ?", itemId);
    return json({ ok: true });
  }

  // MARK: - Helpers

  private item(itemId: string): ItemRow | undefined {
    return this.ctx.storage.sql
      .exec<ItemRow>(
        `SELECT id, uploaded_by, uploader_name, media_type, mime, created_at,
                byte_size, chunk_count, duration, thumb, committed
         FROM items WHERE id = ?`,
        itemId,
      )
      .toArray()[0];
  }
}
