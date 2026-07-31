import { DurableObject } from "cloudflare:workers";

/** One instance per shared birthday profile: participants, notes and votes. */
type ParticipantRow = {
  user_id: string;
  name: string;
  permission: string;
  invited_at: number;
  accepted_at: number | null;
  is_owner: number;
};

type NoteRow = {
  id: string;
  author_id: string;
  author_name: string;
  text: string;
  created_at: number;
};

type VoteRow = {
  card: string;
  user_id: string;
  user_name: string;
  value: number;
  updated_at: number;
};

type InviteRow = {
  code: string;
  permission: string;
  created_at: number;
  claimed_by: string | null;
};

type IncomingNote = { id: string; text: string; createdAt: number };

const PERMISSIONS = new Set(["view", "edit"]);

function json(data: unknown, status = 200): Response {
  return Response.json(data, { status });
}

export class ShareRoom extends DurableObject {
  constructor(ctx: DurableObjectState, env: unknown) {
    super(ctx, env);
    const sql = this.ctx.storage.sql;
    sql.exec(`CREATE TABLE IF NOT EXISTS meta (k TEXT PRIMARY KEY, v TEXT NOT NULL)`);
    sql.exec(`CREATE TABLE IF NOT EXISTS invites (
      code TEXT PRIMARY KEY,
      permission TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      claimed_by TEXT
    )`);
    sql.exec(`CREATE TABLE IF NOT EXISTS participants (
      user_id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      permission TEXT NOT NULL,
      invited_at INTEGER NOT NULL,
      accepted_at INTEGER,
      is_owner INTEGER NOT NULL DEFAULT 0
    )`);
    sql.exec(`CREATE TABLE IF NOT EXISTS notes (
      id TEXT PRIMARY KEY,
      author_id TEXT NOT NULL,
      author_name TEXT NOT NULL,
      text TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )`);
    sql.exec(`CREATE TABLE IF NOT EXISTS votes (
      card TEXT NOT NULL,
      user_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      value INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (card, user_id)
    )`);
  }

  override async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    try {
      if (request.method === "POST" && path === "/invite") {
        return await this.createInvite(request);
      }
      if (request.method === "POST" && path === "/join") {
        return await this.join(request);
      }
      if (request.method === "POST" && path === "/snapshot") {
        return await this.pushSnapshot(request);
      }
      if (request.method === "GET" && path === "/state") {
        return this.state(url.searchParams.get("userId") ?? "");
      }
      if (request.method === "POST" && path === "/notes") {
        return await this.addNote(request);
      }
      if (request.method === "POST" && path === "/notes/delete") {
        return await this.deleteNote(request);
      }
      if (request.method === "POST" && path === "/votes") {
        return await this.vote(request);
      }
      if (request.method === "POST" && path === "/participants/remove") {
        return await this.removeParticipant(request);
      }
    } catch (error) {
      console.error("share room failure", path, error);
      return json({ error: "room_failure" }, 500);
    }

    return json({ error: "not_found" }, 404);
  }

  // MARK: - Routes

  /** Owner registers the room (idempotent) and mints one invite code. */
  private async createInvite(request: Request): Promise<Response> {
    const body = (await request.json()) as {
      code?: string;
      ownerUserId?: string;
      ownerName?: string;
      permission?: string;
      snapshot?: unknown;
    };

    const ownerUserId = (body.ownerUserId ?? "").trim();
    const code = (body.code ?? "").trim().toUpperCase();
    const permission = PERMISSIONS.has(body.permission ?? "") ? (body.permission as string) : "view";

    if (!ownerUserId || !code) return json({ error: "bad_request" }, 400);

    const existingOwner = this.meta("owner_user_id");
    if (existingOwner && existingOwner !== ownerUserId) {
      return json({ error: "not_owner" }, 403);
    }

    const ownerName = (body.ownerName ?? "").trim() || "Owner";
    this.setMeta("owner_user_id", ownerUserId);
    this.setMeta("owner_name", ownerName);
    if (body.snapshot !== undefined) {
      this.setMeta("snapshot", JSON.stringify(body.snapshot));
      this.setMeta("snapshot_updated_at", String(Date.now()));
    }

    const now = Date.now();
    this.ctx.storage.sql.exec(
      `INSERT INTO participants (user_id, name, permission, invited_at, accepted_at, is_owner)
       VALUES (?, ?, 'edit', ?, ?, 1)
       ON CONFLICT(user_id) DO UPDATE SET name = excluded.name, permission = 'edit', is_owner = 1`,
      ownerUserId,
      ownerName,
      now,
      now,
    );

    this.ctx.storage.sql.exec(
      `INSERT INTO invites (code, permission, created_at, claimed_by) VALUES (?, ?, ?, NULL)
       ON CONFLICT(code) DO UPDATE SET permission = excluded.permission`,
      code,
      permission,
      now,
    );

    return json({ ok: true, code, permission, invitedAt: now });
  }

  /** An invitee claims a code and becomes a participant. */
  private async join(request: Request): Promise<Response> {
    const body = (await request.json()) as { code?: string; userId?: string; userName?: string };
    const code = (body.code ?? "").trim().toUpperCase();
    const userId = (body.userId ?? "").trim();
    const userName = (body.userName ?? "").trim() || "Guest";

    if (!code || !userId) return json({ error: "bad_request" }, 400);

    const invite = this.ctx.storage.sql
      .exec<InviteRow>("SELECT code, permission, created_at, claimed_by FROM invites WHERE code = ?", code)
      .toArray()[0];

    if (!invite) return json({ error: "invalid_code" }, 404);
    if (invite.claimed_by && invite.claimed_by !== userId) return json({ error: "code_used" }, 409);
    if (this.meta("owner_user_id") === userId) return json({ error: "own_profile" }, 409);

    const now = Date.now();
    this.ctx.storage.sql.exec("UPDATE invites SET claimed_by = ? WHERE code = ?", userId, code);
    this.ctx.storage.sql.exec(
      `INSERT INTO participants (user_id, name, permission, invited_at, accepted_at, is_owner)
       VALUES (?, ?, ?, ?, ?, 0)
       ON CONFLICT(user_id) DO UPDATE SET
         name = excluded.name,
         permission = excluded.permission,
         accepted_at = excluded.accepted_at`,
      userId,
      userName,
      invite.permission,
      invite.created_at,
      now,
    );

    return this.state(userId);
  }

  /** Owner pushes the authoritative profile snapshot plus its own diary notes. */
  private async pushSnapshot(request: Request): Promise<Response> {
    const body = (await request.json()) as {
      ownerUserId?: string;
      ownerName?: string;
      snapshot?: unknown;
      notes?: IncomingNote[];
    };

    const ownerUserId = (body.ownerUserId ?? "").trim();
    if (!ownerUserId) return json({ error: "bad_request" }, 400);
    if (this.meta("owner_user_id") !== ownerUserId) return json({ error: "not_owner" }, 403);

    const ownerName = (body.ownerName ?? "").trim();
    if (ownerName) {
      this.setMeta("owner_name", ownerName);
      this.ctx.storage.sql.exec("UPDATE participants SET name = ? WHERE user_id = ?", ownerName, ownerUserId);
    }

    if (body.snapshot !== undefined) {
      this.setMeta("snapshot", JSON.stringify(body.snapshot));
      this.setMeta("snapshot_updated_at", String(Date.now()));
    }

    if (Array.isArray(body.notes)) {
      const keep: string[] = [];
      for (const note of body.notes) {
        if (!note?.id || typeof note.text !== "string") continue;
        keep.push(note.id);
        this.ctx.storage.sql.exec(
          `INSERT INTO notes (id, author_id, author_name, text, created_at) VALUES (?, ?, ?, ?, ?)
           ON CONFLICT(id) DO UPDATE SET text = excluded.text, author_name = excluded.author_name`,
          note.id,
          ownerUserId,
          ownerName || "Owner",
          note.text,
          Number(note.createdAt) || Date.now(),
        );
      }

      // Notes the owner deleted locally disappear for everyone too.
      const owned = this.ctx.storage.sql
        .exec<{ id: string }>("SELECT id FROM notes WHERE author_id = ?", ownerUserId)
        .toArray();
      const kept = new Set(keep);
      for (const row of owned) {
        if (!kept.has(row.id)) {
          this.ctx.storage.sql.exec("DELETE FROM notes WHERE id = ?", row.id);
        }
      }
    }

    return this.state(ownerUserId);
  }

  private async addNote(request: Request): Promise<Response> {
    const body = (await request.json()) as {
      userId?: string;
      userName?: string;
      note?: IncomingNote;
    };

    const userId = (body.userId ?? "").trim();
    const note = body.note;
    if (!userId || !note?.id || typeof note.text !== "string") return json({ error: "bad_request" }, 400);

    const participant = this.participant(userId);
    if (!participant) return json({ error: "not_participant" }, 403);
    if (participant.permission !== "edit" && participant.is_owner !== 1) {
      return json({ error: "read_only" }, 403);
    }

    const name = (body.userName ?? "").trim() || participant.name;
    this.ctx.storage.sql.exec(
      `INSERT INTO notes (id, author_id, author_name, text, created_at) VALUES (?, ?, ?, ?, ?)
       ON CONFLICT(id) DO UPDATE SET text = excluded.text`,
      note.id,
      userId,
      name,
      note.text,
      Number(note.createdAt) || Date.now(),
    );

    return json({ ok: true });
  }

  private async deleteNote(request: Request): Promise<Response> {
    const body = (await request.json()) as { userId?: string; noteId?: string };
    const userId = (body.userId ?? "").trim();
    const noteId = (body.noteId ?? "").trim();
    if (!userId || !noteId) return json({ error: "bad_request" }, 400);

    const participant = this.participant(userId);
    if (!participant) return json({ error: "not_participant" }, 403);

    if (participant.is_owner === 1) {
      this.ctx.storage.sql.exec("DELETE FROM notes WHERE id = ?", noteId);
    } else {
      this.ctx.storage.sql.exec("DELETE FROM notes WHERE id = ? AND author_id = ?", noteId, userId);
    }
    return json({ ok: true });
  }

  private async vote(request: Request): Promise<Response> {
    const body = (await request.json()) as {
      userId?: string;
      userName?: string;
      card?: string;
      value?: number;
    };

    const userId = (body.userId ?? "").trim();
    const card = (body.card ?? "").trim();
    const raw = Number(body.value ?? 0);
    const value = raw > 0 ? 1 : raw < 0 ? -1 : 0;
    if (!userId || !card) return json({ error: "bad_request" }, 400);

    const participant = this.participant(userId);
    if (!participant) return json({ error: "not_participant" }, 403);
    if (participant.permission !== "edit" && participant.is_owner !== 1) {
      return json({ error: "read_only" }, 403);
    }

    if (value === 0) {
      this.ctx.storage.sql.exec("DELETE FROM votes WHERE card = ? AND user_id = ?", card, userId);
    } else {
      this.ctx.storage.sql.exec(
        `INSERT INTO votes (card, user_id, user_name, value, updated_at) VALUES (?, ?, ?, ?, ?)
         ON CONFLICT(card, user_id) DO UPDATE SET
           value = excluded.value,
           user_name = excluded.user_name,
           updated_at = excluded.updated_at`,
        card,
        userId,
        (body.userName ?? "").trim() || participant.name,
        value,
        Date.now(),
      );
    }

    return json({ ok: true });
  }

  /** Only the original owner can revoke access, and never their own. */
  private async removeParticipant(request: Request): Promise<Response> {
    const body = (await request.json()) as { ownerUserId?: string; targetUserId?: string };
    const ownerUserId = (body.ownerUserId ?? "").trim();
    const targetUserId = (body.targetUserId ?? "").trim();
    if (!ownerUserId || !targetUserId) return json({ error: "bad_request" }, 400);
    if (this.meta("owner_user_id") !== ownerUserId) return json({ error: "not_owner" }, 403);
    if (ownerUserId === targetUserId) return json({ error: "cannot_remove_owner" }, 409);

    this.ctx.storage.sql.exec("DELETE FROM participants WHERE user_id = ? AND is_owner = 0", targetUserId);
    this.ctx.storage.sql.exec("DELETE FROM votes WHERE user_id = ?", targetUserId);
    this.ctx.storage.sql.exec("UPDATE invites SET claimed_by = NULL WHERE claimed_by = ?", targetUserId);

    return this.state(ownerUserId);
  }

  // MARK: - Shared payload

  private state(userId: string): Response {
    const requester = userId ? this.participant(userId) : undefined;
    if (!requester) return json({ error: "not_participant" }, 403);

    const snapshotRaw = this.meta("snapshot");
    const participants = this.ctx.storage.sql
      .exec<ParticipantRow>(
        `SELECT user_id, name, permission, invited_at, accepted_at, is_owner
         FROM participants ORDER BY is_owner DESC, invited_at ASC`,
      )
      .toArray();

    const notes = this.ctx.storage.sql
      .exec<NoteRow>(
        "SELECT id, author_id, author_name, text, created_at FROM notes ORDER BY created_at DESC LIMIT 400",
      )
      .toArray();

    const votes = this.ctx.storage.sql
      .exec<VoteRow>("SELECT card, user_id, user_name, value, updated_at FROM votes")
      .toArray();

    const pending = this.ctx.storage.sql
      .exec<InviteRow>(
        "SELECT code, permission, created_at, claimed_by FROM invites WHERE claimed_by IS NULL ORDER BY created_at DESC",
      )
      .toArray();

    return json({
      profileId: this.ctx.id.name ?? "",
      ownerUserId: this.meta("owner_user_id") ?? "",
      ownerName: this.meta("owner_name") ?? "",
      permission: requester.is_owner === 1 ? "edit" : requester.permission,
      isOwner: requester.is_owner === 1,
      snapshotUpdatedAt: Number(this.meta("snapshot_updated_at") ?? "0"),
      snapshot: snapshotRaw ? (JSON.parse(snapshotRaw) as unknown) : null,
      participants: participants.map((row) => ({
        userId: row.user_id,
        name: row.name,
        permission: row.is_owner === 1 ? "edit" : row.permission,
        invitedAt: row.invited_at,
        acceptedAt: row.accepted_at,
        isOwner: row.is_owner === 1,
      })),
      pendingInvites: pending.map((row) => ({
        code: row.code,
        permission: row.permission,
        invitedAt: row.created_at,
      })),
      notes: notes.map((row) => ({
        id: row.id,
        authorId: row.author_id,
        authorName: row.author_name,
        text: row.text,
        createdAt: row.created_at,
      })),
      votes: votes.map((row) => ({
        card: row.card,
        userId: row.user_id,
        userName: row.user_name,
        value: row.value,
        updatedAt: row.updated_at,
      })),
    });
  }

  private participant(userId: string): ParticipantRow | undefined {
    return this.ctx.storage.sql
      .exec<ParticipantRow>(
        `SELECT user_id, name, permission, invited_at, accepted_at, is_owner
         FROM participants WHERE user_id = ?`,
        userId,
      )
      .toArray()[0];
  }

  private meta(key: string): string | null {
    const row = this.ctx.storage.sql
      .exec<{ v: string }>("SELECT v FROM meta WHERE k = ?", key)
      .toArray()[0];
    return row?.v ?? null;
  }

  private setMeta(key: string, value: string): void {
    this.ctx.storage.sql.exec(
      "INSERT INTO meta (k, v) VALUES (?, ?) ON CONFLICT(k) DO UPDATE SET v = excluded.v",
      key,
      value,
    );
  }
}
