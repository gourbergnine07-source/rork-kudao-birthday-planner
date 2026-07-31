export { ShareRoom } from "./share-room";
export { ShareDirectory } from "./share-directory";
export { GalleryRoom } from "./gallery-room";

type Env = { DO: Fetcher };

/** Readable alphabet: no 0/O/1/I so codes survive being read out loud. */
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const CODE_LENGTH = 6;

function json(data: unknown, status = 200): Response {
  return Response.json(data, { status });
}

function makeCode(): string {
  const bytes = new Uint8Array(CODE_LENGTH);
  crypto.getRandomValues(bytes);
  let code = "";
  for (const byte of bytes) {
    code += CODE_ALPHABET[byte % CODE_ALPHABET.length];
  }
  return code;
}

function callDO(
  env: Env,
  className: string,
  id: string,
  path: string,
  method: string,
  body?: unknown,
): Promise<Response> {
  const headers = new Headers({
    "X-Rork-DO-Class": className,
    "X-Rork-DO-Id": id,
  });
  if (body !== undefined) headers.set("Content-Type", "application/json");

  return env.DO.fetch(
    new Request(`https://internal${path}`, {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
    }),
  );
}

function room(env: Env, profileId: string, path: string, method: string, body?: unknown): Promise<Response> {
  return callDO(env, "ShareRoom", profileId, path, method, body);
}

function directory(env: Env, path: string, method: string, body?: unknown): Promise<Response> {
  return callDO(env, "ShareDirectory", "global", path, method, body);
}

function gallery(env: Env, profileId: string, path: string, method: string, body?: unknown): Promise<Response> {
  return callDO(env, "GalleryRoom", profileId, path, method, body);
}

/** Forwards a binary payload (one media chunk) to the gallery object untouched. */
function galleryBinary(env: Env, profileId: string, path: string, body: ArrayBuffer): Promise<Response> {
  return env.DO.fetch(
    new Request(`https://internal${path}`, {
      method: "POST",
      headers: new Headers({
        "X-Rork-DO-Class": "GalleryRoom",
        "X-Rork-DO-Id": profileId,
        "Content-Type": "application/octet-stream",
      }),
      body,
    }),
  );
}

type GalleryAccess = { isMember: boolean; isOwner: boolean };

/**
 * The gallery reuses the share room as its guest list: owner plus everyone who
 * claimed an invite. Profiles that were never shared stay private to their owner.
 */
async function galleryAccess(env: Env, profileId: string, userId: string): Promise<GalleryAccess> {
  if (!userId) return { isMember: false, isOwner: false };

  const response = await room(env, profileId, `/access?userId=${encodeURIComponent(userId)}`, "GET");
  if (!response.ok) return { isMember: false, isOwner: false };

  const access = (await response.json()) as { isMember?: boolean; isOwner?: boolean };
  return { isMember: access.isMember === true, isOwner: access.isOwner === true };
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const segments = url.pathname.split("/").filter(Boolean);

    try {
      if (request.method === "GET" && segments[0] === "health") {
        return json({ ok: true, service: "kudao-shares" });
      }

      // POST /shares — owner mints an invite code for one profile.
      if (request.method === "POST" && segments.length === 1 && segments[0] === "shares") {
        const body = (await request.json()) as {
          profileId?: string;
          ownerUserId?: string;
          ownerName?: string;
          permission?: string;
          snapshot?: unknown;
        };
        const profileId = (body.profileId ?? "").trim();
        if (!profileId || !(body.ownerUserId ?? "").trim()) return json({ error: "bad_request" }, 400);

        // Retry a few times so a colliding code never surfaces to the user.
        let code = "";
        for (let attempt = 0; attempt < 5; attempt += 1) {
          const candidate = makeCode();
          const registered = await directory(env, "/register", "POST", { code: candidate, profileId });
          if (registered.ok) {
            code = candidate;
            break;
          }
          if (registered.status !== 409) {
            return json({ error: "directory_failure" }, 502);
          }
        }
        if (!code) return json({ error: "code_exhausted" }, 503);

        const created = await room(env, profileId, "/invite", "POST", {
          code,
          ownerUserId: body.ownerUserId,
          ownerName: body.ownerName,
          permission: body.permission,
          snapshot: body.snapshot,
        });
        return new Response(created.body, { status: created.status, headers: created.headers });
      }

      // POST /shares/join — invitee claims a code.
      if (request.method === "POST" && segments.length === 2 && segments[0] === "shares" && segments[1] === "join") {
        const body = (await request.json()) as { code?: string; userId?: string; userName?: string };
        const code = (body.code ?? "").trim().toUpperCase();
        if (!code || !(body.userId ?? "").trim()) return json({ error: "bad_request" }, 400);

        const resolved = await directory(env, `/resolve?code=${encodeURIComponent(code)}`, "GET");
        if (!resolved.ok) return json({ error: "invalid_code" }, 404);
        const { profileId } = (await resolved.json()) as { profileId: string };

        const joined = await room(env, profileId, "/join", "POST", {
          code,
          userId: body.userId,
          userName: body.userName,
        });
        return new Response(joined.body, { status: joined.status, headers: joined.headers });
      }

      // /rooms/:profileId[...]
      if (segments[0] === "rooms" && segments.length >= 2) {
        const profileId = decodeURIComponent(segments[1]);
        const rest = segments.slice(2);

        // /rooms/:profileId/gallery[...] — party photos and videos.
        if (rest[0] === "gallery") {
          const action = rest[1] ?? "";
          const userId = url.searchParams.get("userId") ?? "";

          if (request.method === "GET" && (action === "" || action === "media")) {
            const access = await galleryAccess(env, profileId, userId);
            if (!access.isMember) return json({ error: "not_participant" }, 403);

            if (action === "media") {
              const itemId = url.searchParams.get("itemId") ?? "";
              const media = await gallery(
                env,
                profileId,
                `/media?itemId=${encodeURIComponent(itemId)}`,
                "GET",
              );
              return new Response(media.body, { status: media.status, headers: media.headers });
            }

            const items = await gallery(env, profileId, "/items", "GET");
            return new Response(items.body, { status: items.status, headers: items.headers });
          }

          if (request.method === "POST" && action === "chunk") {
            const access = await galleryAccess(env, profileId, userId);
            if (!access.isMember) return json({ error: "not_participant" }, 403);

            const itemId = url.searchParams.get("itemId") ?? "";
            const index = url.searchParams.get("index") ?? "";
            const forwarded = await galleryBinary(
              env,
              profileId,
              `/chunk?itemId=${encodeURIComponent(itemId)}&index=${encodeURIComponent(index)}` +
                `&userId=${encodeURIComponent(userId)}`,
              await request.arrayBuffer(),
            );
            return new Response(forwarded.body, { status: forwarded.status, headers: forwarded.headers });
          }

          if (request.method === "POST" && (action === "begin" || action === "commit" || action === "delete")) {
            const body = (await request.json()) as { userId?: string };
            const access = await galleryAccess(env, profileId, (body.userId ?? "").trim());
            if (!access.isMember) return json({ error: "not_participant" }, 403);

            const payload = action === "delete" ? { ...body, isOwner: access.isOwner } : body;
            const result = await gallery(env, profileId, `/${action}`, "POST", payload);
            return new Response(result.body, { status: result.status, headers: result.headers });
          }

          return json({ error: "not_found" }, 404);
        }

        if (request.method === "GET" && rest.length === 0) {
          const userId = url.searchParams.get("userId") ?? "";
          const state = await room(env, profileId, `/state?userId=${encodeURIComponent(userId)}`, "GET");
          return new Response(state.body, { status: state.status, headers: state.headers });
        }

        if (request.method === "POST" && rest.length >= 1) {
          const allowed: Record<string, string> = {
            snapshot: "/snapshot",
            notes: "/notes",
            votes: "/votes",
          };

          if (rest.length === 1 && allowed[rest[0]]) {
            const body = await request.json();
            const result = await room(env, profileId, allowed[rest[0]], "POST", body);
            return new Response(result.body, { status: result.status, headers: result.headers });
          }

          if (rest.length === 2 && rest[0] === "notes" && rest[1] === "delete") {
            const body = await request.json();
            const result = await room(env, profileId, "/notes/delete", "POST", body);
            return new Response(result.body, { status: result.status, headers: result.headers });
          }

          if (rest.length === 2 && rest[0] === "participants" && rest[1] === "remove") {
            const body = await request.json();
            const result = await room(env, profileId, "/participants/remove", "POST", body);
            return new Response(result.body, { status: result.status, headers: result.headers });
          }
        }
      }
    } catch (error) {
      console.error("kudao shares worker failure", url.pathname, error);
      return json({ error: "worker_failure" }, 500);
    }

    return json({ error: "not_found" }, 404);
  },
} satisfies ExportedHandler<Env>;
