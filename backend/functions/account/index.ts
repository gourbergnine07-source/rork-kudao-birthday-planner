import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Account creation for Kudao.
 *
 * Supabase's own sign-up sends a confirmation email whose link goes to the
 * project's Site URL. That URL is fixed to `localhost:3000` on this managed
 * instance and cannot be changed from here, so every confirmation link died on
 * a "cannot reach the site" page even though the address had just been verified.
 *
 * Kudao's account is optional — the vault is already protected by a recovery
 * code, and signing in only ever reaches that same user's own backup. So the
 * account is created here with the service role, already confirmed, and the app
 * signs in with the password straight away. No email, no link, no dead end.
 */

const MIN_PASSWORD_LENGTH = 8;
const MAX_PASSWORD_LENGTH = 200;
const MAX_EMAIL_LENGTH = 254;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
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
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

/** Deliberately permissive, same rule the app applies before it calls. */
function isValidEmail(address: string): boolean {
  if (address.length < 6 || address.length > MAX_EMAIL_LENGTH) return false;
  const parts = address.split("@");
  if (parts.length !== 2) return false;
  const [local, domain] = parts;
  if (!local || !domain) return false;
  if (!domain.includes(".") || domain.startsWith(".") || domain.endsWith(".")) return false;
  return !/\s/.test(address);
}

/** Supabase words this differently across versions, so match on meaning. */
function isAlreadyRegistered(message: string): boolean {
  const text = message.toLowerCase();
  return (
    text.includes("already registered") ||
    text.includes("already been registered") ||
    text.includes("already exists") ||
    text.includes("user_already_exists") ||
    text.includes("email_exists") ||
    text.includes("duplicate key")
  );
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
  if (action !== "signup") return json({ error: "not_found" }, 404);

  const email = String(body.email ?? "").trim().toLowerCase();
  const password = String(body.password ?? "");

  if (!isValidEmail(email)) return json({ error: "invalid_email" }, 400);
  if (password.length < MIN_PASSWORD_LENGTH || password.length > MAX_PASSWORD_LENGTH) {
    return json({ error: "weak_password" }, 400);
  }

  try {
    const supabase = admin();
    const { data, error } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (error) {
      const message = String(error.message ?? "");
      if (isAlreadyRegistered(message)) return json({ error: "already_registered" }, 409);
      console.error("account createUser rejected", message);
      return json({ error: "server_error" }, 500);
    }

    return json({ ok: true, userId: data.user?.id ?? null }, 201);
  } catch (error) {
    console.error("account function failure", error);
    return json({ error: "server_error" }, 500);
  }
});
