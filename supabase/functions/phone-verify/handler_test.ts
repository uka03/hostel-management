import { assert, assertEquals } from "jsr:@std/assert@1";
import { Deps, handle, VerificationStore } from "./handler.ts";

const PHONE = "+97699112233";

function memoryStore() {
  const rows = new Map<string, { phone: string; consumed: boolean }>();
  const store: VerificationStore = {
    insert: (sessionId, phone) => {
      rows.set(sessionId, { phone, consumed: false });
      return Promise.resolve();
    },
    find: (sessionId) => Promise.resolve(rows.get(sessionId) ?? null),
    claim: (sessionId) => {
      const row = rows.get(sessionId)!;
      if (row.consumed) return Promise.resolve(false);
      row.consumed = true;
      return Promise.resolve(true);
    },
    release: (sessionId) => {
      rows.get(sessionId)!.consumed = false;
      return Promise.resolve();
    },
  };
  return { store, rows };
}

const verifyMnSession = {
  sessionId: "s1",
  smsUri: "sms:144773?body=482916",
  displayInstruction: "instruction",
  expiresAt: "2026-11-09T12:30:00.000Z",
};

function setup(replies: { create?: Response; statuses?: string[] } = {}) {
  const { store, rows } = memoryStore();
  const statuses = [...(replies.statuses ?? [])];
  const requests: { url: string; init?: RequestInit }[] = [];
  const issued: string[] = [];
  let failIssue = false;

  const fakeFetch = ((input: string, init?: RequestInit) => {
    requests.push({ url: input, init });
    if (init?.method === "POST") {
      return Promise.resolve(
        replies.create ?? Response.json(verifyMnSession),
      );
    }
    return Promise.resolve(
      Response.json({ sessionStatus: statuses.shift() ?? "PENDING" }),
    );
  }) as typeof fetch;

  const deps: Deps = {
    apiKey: "key-123",
    fetch: fakeFetch,
    store,
    issueSession: (phone) => {
      if (failIssue) return Promise.reject(new Error("boom"));
      issued.push(phone);
      return Promise.resolve({ access_token: "a" });
    },
  };

  const call = async (body: unknown, overrides: Partial<Deps> = {}) => {
    const response = await handle(
      new Request("https://x.test", {
        method: "POST",
        body: JSON.stringify(body),
      }),
      { ...deps, ...overrides },
    );
    return { status: response.status, body: await response.json() };
  };

  return {
    call,
    rows,
    requests,
    issued,
    failNextIssue: (value: boolean) => (failIssue = value),
  };
}

const start = { action: "start", phone: PHONE };
const check = { action: "status", session_id: "s1" };

Deno.test("start sends a 6-digit code and the bearer key", async () => {
  const t = setup();
  const { status, body } = await t.call(start);

  assertEquals(status, 200);
  assertEquals(body.session_id, "s1");
  assertEquals(body.sms_uri, verifyMnSession.smsUri);
  assertEquals(body.display_instruction, "instruction");

  const sent = JSON.parse(t.requests[0].init!.body as string);
  assertEquals(sent.phone, "99112233");
  assert(/^\d{6}$/.test(sent.text));
  assertEquals(
    (t.requests[0].init!.headers as Record<string, string>).Authorization,
    "Bearer key-123",
  );
  assertEquals(t.rows.get("s1")?.phone, PHONE);
});

Deno.test("codes differ between sessions", async () => {
  const t = setup();
  const codes = new Set<string>();
  for (let i = 0; i < 5; i++) {
    await t.call(start);
    codes.add(JSON.parse(t.requests[i].init!.body as string).text);
    t.rows.clear();
  }
  assert(codes.size > 1);
});

Deno.test("PENDING then VERIFIED issues exactly one session", async () => {
  const t = setup({ statuses: ["PENDING", "VERIFIED"] });
  await t.call(start);

  assertEquals((await t.call(check)).body, { status: "PENDING" });
  assertEquals(t.issued, []);

  const verified = await t.call(check);
  assertEquals(verified.body.status, "VERIFIED");
  assertEquals(verified.body.session, { access_token: "a" });
  assertEquals(t.issued, [PHONE]);
});

Deno.test("EXPIRED issues no session", async () => {
  const t = setup({ statuses: ["EXPIRED"] });
  await t.call(start);

  assertEquals((await t.call(check)).body, { status: "EXPIRED" });
  assertEquals(t.issued, []);
});

Deno.test("a verification cannot be replayed", async () => {
  const t = setup({ statuses: ["VERIFIED", "VERIFIED"] });
  await t.call(start);
  await t.call(check);

  assertEquals((await t.call(check)).body, { status: "EXPIRED" });
  assertEquals(t.issued, [PHONE]);
});

Deno.test("an unknown session never reaches verify.mn", async () => {
  const t = setup({ statuses: ["VERIFIED"] });

  const { status } = await t.call({ action: "status", session_id: "forged" });

  assertEquals(status, 404);
  assertEquals(t.requests, []);
  assertEquals(t.issued, []);
});

Deno.test("a failed login can be retried after paying for the SMS", async () => {
  const t = setup({ statuses: ["VERIFIED", "VERIFIED"] });
  await t.call(start);

  t.failNextIssue(true);
  assertEquals((await t.call(check)).status, 500);

  t.failNextIssue(false);
  assertEquals((await t.call(check)).body.status, "VERIFIED");
});

Deno.test("401 on a bad key is reported and creates nothing", async () => {
  const t = setup({
    create: Response.json({ statusCode: 401 }, { status: 401 }),
  });

  const { status, body } = await t.call(start);

  assertEquals(status, 500);
  assertEquals(body.error_code, "not_configured");
  assertEquals(t.rows.size, 0);
});

Deno.test("a missing key fails loudly before calling verify.mn", async () => {
  const t = setup();

  const { status, body } = await t.call(start, { apiKey: undefined });

  assertEquals(status, 500);
  assertEquals(body.error_code, "not_configured");
  assertEquals(t.requests, []);
});

Deno.test("responses never contain the key or the code", async () => {
  const t = setup();
  const { body } = await t.call(start);
  const text = JSON.stringify(body);
  const sent = JSON.parse(t.requests[0].init!.body as string);

  assert(!text.includes("key-123"));
  // The code reaches the client only inside verify.mn's own fields.
  assertEquals("text" in body, false);
  assert(sent.text.length === 6);
});

Deno.test("rejects malformed phones", async () => {
  const t = setup();
  assertEquals((await t.call({ action: "start", phone: "991" })).status, 400);
  assertEquals(t.requests, []);
});

Deno.test("repeated attempts are not limited", async () => {
  const t = setup();
  for (let i = 0; i < 20; i++) {
    t.rows.set(`old${i}`, { phone: PHONE, consumed: true });
  }

  assertEquals((await t.call(start)).status, 200);
});
