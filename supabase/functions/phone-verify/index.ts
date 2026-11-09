// Phone login through verify.mn, where the user texts a code to 144773.
//
// Supabase Auth can't do this flow, so once verify.mn reports VERIFIED this
// function finds or creates the user and issues a normal Supabase session.
// Deploy with verify_jwt = false: callers aren't signed in yet.

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";
import { handle, VerificationStore } from "./handler.ts";

function supabaseStore(db: SupabaseClient): VerificationStore {
  const table = () => db.from("phone_verifications");
  return {
    async insert(sessionId, phone, expiresAt) {
      const { error } = await table().insert({
        session_id: sessionId,
        phone,
        expires_at: expiresAt,
      });
      if (error) throw error;
    },
    async find(sessionId) {
      const { data, error } = await table()
        .select("phone, consumed_at")
        .eq("session_id", sessionId)
        .maybeSingle();
      if (error) throw error;
      return data && { phone: data.phone, consumed: !!data.consumed_at };
    },
    async claim(sessionId) {
      const { data, error } = await table()
        .update({ consumed_at: new Date().toISOString() })
        .eq("session_id", sessionId)
        .is("consumed_at", null)
        .select("session_id");
      if (error) throw error;
      return data.length > 0;
    },
    async release(sessionId) {
      const { error } = await table()
        .update({ consumed_at: null })
        .eq("session_id", sessionId);
      if (error) throw error;
    },
  };
}

async function findUserId(db: SupabaseClient, digits: string) {
  const { data, error } = await db
    .from("profiles")
    .select("id")
    .eq("phone", digits)
    .maybeSingle();
  if (error) throw error;
  return data?.id as string | undefined;
}

async function issueSession(db: SupabaseClient, phone: string) {
  const digits = phone.slice(1); // Supabase Auth stores phones without "+".

  // Magic links need an email. This address is internal and never receives
  // mail: generateLink only returns a token, it doesn't send anything.
  const host = new URL(Deno.env.get("SUPABASE_URL")!).host;
  const email = `${digits}@${host}`;

  if (!(await findUserId(db, digits))) {
    const { error } = await db.auth.admin.createUser({
      phone: digits,
      phone_confirm: true,
      email,
      email_confirm: true,
    });
    // A parallel request may have created the user first.
    if (error && !(await findUserId(db, digits))) throw error;
  }

  const { data: link, error: linkError } = await db.auth.admin.generateLink({
    type: "magiclink",
    email,
  });
  if (linkError) throw linkError;

  const { data, error } = await db.auth.verifyOtp({
    token_hash: link.properties.hashed_token,
    type: "magiclink",
  });
  if (error) throw error;
  if (!data.session) throw new Error("no session returned");

  return {
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
    user: { id: data.session.user.id, phone: data.session.user.phone },
  };
}

Deno.serve((request) => {
  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  return handle(request, {
    apiKey: Deno.env.get("VERIFY_MN_API_KEY"),
    fetch,
    store: supabaseStore(db),
    issueSession: (phone) => issueSession(db, phone),
  });
});
