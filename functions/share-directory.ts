import { DurableObject } from "cloudflare:workers";

/** Singleton lookup table mapping short invite codes to their profile room. */
export class ShareDirectory extends DurableObject {
  constructor(ctx: DurableObjectState, env: unknown) {
    super(ctx, env);
    this.ctx.storage.sql.exec(`CREATE TABLE IF NOT EXISTS codes (
      code TEXT PRIMARY KEY,
      profile_id TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )`);
  }

  override async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "POST" && url.pathname === "/register") {
      const body = (await request.json()) as { code?: string; profileId?: string };
      const code = (body.code ?? "").trim().toUpperCase();
      const profileId = (body.profileId ?? "").trim();
      if (!code || !profileId) return Response.json({ error: "bad_request" }, { status: 400 });

      const existing = this.ctx.storage.sql
        .exec<{ profile_id: string }>("SELECT profile_id FROM codes WHERE code = ?", code)
        .toArray()[0];

      if (existing && existing.profile_id !== profileId) {
        return Response.json({ error: "code_taken" }, { status: 409 });
      }

      this.ctx.storage.sql.exec(
        "INSERT INTO codes (code, profile_id, created_at) VALUES (?, ?, ?) ON CONFLICT(code) DO NOTHING",
        code,
        profileId,
        Date.now(),
      );
      return Response.json({ ok: true });
    }

    if (request.method === "GET" && url.pathname === "/resolve") {
      const code = (url.searchParams.get("code") ?? "").trim().toUpperCase();
      const row = this.ctx.storage.sql
        .exec<{ profile_id: string }>("SELECT profile_id FROM codes WHERE code = ?", code)
        .toArray()[0];
      if (!row) return Response.json({ error: "invalid_code" }, { status: 404 });
      return Response.json({ profileId: row.profile_id });
    }

    return Response.json({ error: "not_found" }, { status: 404 });
  }
}
