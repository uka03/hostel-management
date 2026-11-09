// Request handling for phone-verify, free of Supabase and Deno globals so it
// can be tested with fakes. index.ts supplies the real dependencies.
//
//   { "action": "start",  "phone": "+97699112233" }
//   { "action": "status", "session_id": "..." }
//
// Never log phone numbers, codes, session ids, tokens or the API key.

const VERIFY_BASE = "https://api.verify.mn";

export interface VerificationStore {
  insert(sessionId: string, phone: string, expiresAt: string): Promise<void>;
  find(sessionId: string): Promise<{ phone: string; consumed: boolean } | null>;
  /** Atomically marks a session used; false if it was already used. */
  claim(sessionId: string): Promise<boolean>;
  release(sessionId: string): Promise<void>;
}

export interface Deps {
  apiKey: string | undefined;
  fetch: typeof fetch;
  store: VerificationStore;
  issueSession(phone: string): Promise<unknown>;
}

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

function randomCode(): string {
  const [n] = crypto.getRandomValues(new Uint32Array(1));
  return String(n % 1_000_000).padStart(6, "0");
}

async function start(deps: Deps, apiKey: string, phone: unknown) {
  if (typeof phone !== "string" || !/^\+976\d{8}$/.test(phone)) {
    return json(400, { error_code: "invalid_phone" });
  }

  const response = await deps.fetch(`${VERIFY_BASE}/sessions`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({ phone: phone.slice(4), text: randomCode() }),
  });
  if (response.status === 401) {
    console.error("verify.mn rejected VERIFY_MN_API_KEY");
    return json(500, { error_code: "not_configured" });
  }
  if (!response.ok) {
    console.error(`verify.mn create failed: ${response.status}`);
    return json(502, { error_code: "verify_unavailable" });
  }
  const session = await response.json();

  await deps.store.insert(session.sessionId, phone, session.expiresAt);

  return json(200, {
    session_id: session.sessionId,
    sms_uri: session.smsUri,
    display_instruction: session.displayInstruction,
    expires_at: session.expiresAt,
  });
}

async function status(deps: Deps, sessionId: unknown) {
  if (typeof sessionId !== "string") {
    return json(400, { error_code: "invalid_session" });
  }

  // Only sessions this function created can ever produce a login.
  const row = await deps.store.find(sessionId);
  if (!row) return json(404, { error_code: "session_not_found" });
  if (row.consumed) return json(200, { status: "EXPIRED" });

  const response = await deps.fetch(
    `${VERIFY_BASE}/sessions/${encodeURIComponent(sessionId)}`,
  );
  if (!response.ok) {
    console.error(`verify.mn status failed: ${response.status}`);
    return json(502, { error_code: "verify_unavailable" });
  }
  const { sessionStatus } = await response.json();
  if (sessionStatus !== "VERIFIED") {
    return json(200, {
      status: sessionStatus === "EXPIRED" ? "EXPIRED" : "PENDING",
    });
  }

  // A verification can only ever produce one login.
  if (!(await deps.store.claim(sessionId))) {
    return json(200, { status: "EXPIRED" });
  }

  try {
    const session = await deps.issueSession(row.phone);
    return json(200, { status: "VERIFIED", session });
  } catch (e) {
    // The resident already paid for this SMS: let the next poll retry.
    await deps.store.release(sessionId);
    throw e;
  }
}

export async function handle(request: Request, deps: Deps): Promise<Response> {
  if (request.method !== "POST") return json(405, { error_code: "method" });

  const apiKey = deps.apiKey;
  if (!apiKey) {
    console.error("VERIFY_MN_API_KEY is not set");
    return json(500, { error_code: "not_configured" });
  }

  try {
    const body = await request.json();
    if (body.action === "start") return await start(deps, apiKey, body.phone);
    if (body.action === "status") return await status(deps, body.session_id);
    return json(400, { error_code: "invalid_action" });
  } catch (e) {
    console.error(
      `phone-verify failed: ${e instanceof Error ? e.name : "unknown"}`,
    );
    return json(500, { error_code: "internal" });
  }
}
