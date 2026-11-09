import { assert, assertEquals, assertFalse } from "jsr:@std/assert@1";
import jpeg from "npm:jpeg-js@0.4";
import { Buffer } from "node:buffer";
import {
  Caller,
  Deps,
  handle,
  hmac,
  NewReport,
  ReportRow,
  ReportStore,
} from "./handler.ts";
import { sanitizePhoto } from "./photo.ts";

const SECRET = "test-secret";
const USER_ID = "11111111-1111-1111-1111-111111111111";
const USER_PHONE = "97699112233";
const resident: Caller = { id: USER_ID, role: "resident" };
const manager: Caller = {
  id: "22222222-2222-2222-2222-222222222222",
  role: "manager",
};

/** Rows also carry everything a careless query could return. */
type StoredRow = ReportRow & Record<string, unknown>;

function memoryStore() {
  const rows: StoredRow[] = [];
  const votes: { report_id: string; vote_hash: string }[] = [];
  const photos = new Map<string, string>();
  let nextId = 1;

  const store: ReportStore = {
    countByAuthorSince: (authorHash) =>
      Promise.resolve(rows.filter((r) => r.author_hash === authorHash).length),
    insert: (report: NewReport) => {
      const id = `report-${nextId++}`;
      const row: StoredRow = {
        id,
        author_hash: report.author_hash,
        user_id: USER_ID,
        author: USER_PHONE,
        category: report.category,
        location: report.location,
        description: report.description,
        status: "open",
        reply: null,
        has_photo: report.photo_base64 !== null,
        created_hour: "2026-11-09T14:37:21.123Z",
      };
      rows.push(row);
      if (report.photo_base64) photos.set(id, report.photo_base64);
      return Promise.resolve(row);
    },
    list: () => Promise.resolve([...rows]),
    find: (id) => Promise.resolve(rows.find((r) => r.id === id) ?? null),
    votes: (ids) =>
      Promise.resolve(votes.filter((v) => ids.includes(v.report_id))),
    addVote: (vote_hash, report_id) => {
      if (!votes.some((v) => v.vote_hash === vote_hash)) {
        votes.push({ vote_hash, report_id });
      }
      return Promise.resolve();
    },
    removeVote: (hash) => {
      const i = votes.findIndex((v) => v.vote_hash === hash);
      if (i >= 0) votes.splice(i, 1);
      return Promise.resolve();
    },
    photo: (id) => Promise.resolve(photos.get(id) ?? null),
    update: (id, changes) => {
      const row = rows.find((r) => r.id === id);
      if (row) Object.assign(row, changes);
      return Promise.resolve(row ?? null);
    },
  };
  return { store, rows, votes, photos };
}

function setup() {
  const memory = memoryStore();
  const deps: Deps = {
    secret: SECRET,
    authenticate: () => Promise.resolve(resident),
    store: memory.store,
    sanitizePhoto: (bytes) => bytes,
  };
  const call = async (
    body: unknown,
    caller: Caller | null = resident,
    overrides: Partial<Deps> = {},
  ) => {
    const response = await handle(
      new Request("https://x.test", {
        method: "POST",
        body: JSON.stringify(body),
      }),
      { ...deps, authenticate: () => Promise.resolve(caller), ...overrides },
    );
    const text = await response.text();
    return { status: response.status, body: JSON.parse(text), text };
  };
  return { ...memory, call };
}

const report = {
  action: "create",
  category: "noise",
  location: "2-р давхрын коридор",
  description: "Шөнө чанга хөгжим тавьж байна.",
};

const ALLOWED_FIELDS = [
  "category",
  "created_at",
  "description",
  "has_photo",
  "id",
  "location",
  "reply",
  "status",
  "vote_count",
  "voted",
].sort();

/** Fails if anything that could identify the author appears in the text. */
async function assertNoIdentity(text: string, row: StoredRow) {
  assertFalse(text.includes(USER_ID), "user id leaked");
  assertFalse(text.includes(USER_PHONE), "phone leaked");
  assertFalse(text.includes(row.author_hash as string), "author hash leaked");
  assertFalse(text.includes("author"), "author field leaked");
  assertFalse(text.includes("user_id"), "user_id field leaked");
  assertFalse(
    text.includes(await hmac(SECRET, USER_ID + row.id)),
    "vote hash leaked",
  );
}

Deno.test("author identity cannot be recovered from any response", async () => {
  const t = setup();
  const created = await t.call(report);
  const row = t.rows[0];
  await assertNoIdentity(created.text, row);

  const voted = await t.call({
    action: "vote",
    report_id: row.id,
    voted: true,
  });
  await assertNoIdentity(voted.text, row);

  for (const caller of [resident, manager]) {
    await assertNoIdentity((await t.call({ action: "list" }, caller)).text, row);
  }

  const updated = await t.call(
    { action: "update", report_id: row.id, status: "resolved", reply: "OK" },
    manager,
  );
  await assertNoIdentity(updated.text, row);
});

Deno.test("reports contain exactly the allowed fields", async () => {
  const t = setup();
  const created = await t.call(report);
  assertEquals(Object.keys(created.body.report).sort(), ALLOWED_FIELDS);

  const listed = await t.call({ action: "list" }, manager);
  assertEquals(Object.keys(listed.body.reports[0]).sort(), ALLOWED_FIELDS);
});

Deno.test("managers see exactly what residents see", async () => {
  const t = setup();
  await t.call(report);

  const asResident = await t.call({ action: "list" }, resident);
  const asManager = await t.call({ action: "list" }, manager);

  assertEquals(asManager.body, asResident.body);
});

Deno.test("times are rounded to the hour", async () => {
  const t = setup();
  const created = await t.call(report);
  assertEquals(created.body.report.created_at, "2026-11-09T14:00:00.000Z");

  const listed = await t.call({ action: "list" });
  assertEquals(listed.body.reports[0].created_at, "2026-11-09T14:00:00.000Z");
});

Deno.test("only an HMAC of the author is stored", async () => {
  const t = setup();
  await t.call(report);

  assertEquals(t.rows[0].author_hash, await hmac(SECRET, USER_ID));
  assertFalse((t.rows[0].author_hash as string).includes(USER_ID));
});

Deno.test("votes count once per person and store only a hash", async () => {
  const t = setup();
  await t.call(report);
  const report_id = t.rows[0].id;

  await t.call({ action: "vote", report_id, voted: true });
  await t.call({ action: "vote", report_id, voted: true });
  await t.call({ action: "vote", report_id, voted: true }, manager);

  assertEquals(t.votes.length, 2);
  assertEquals(t.votes[0].vote_hash, await hmac(SECRET, USER_ID + report_id));

  const listed = await t.call({ action: "list" });
  assertEquals(listed.body.reports[0].vote_count, 2);
  assertEquals(listed.body.reports[0].voted, true);
});

Deno.test("a vote can be taken back", async () => {
  const t = setup();
  await t.call(report);
  const report_id = t.rows[0].id;

  await t.call({ action: "vote", report_id, voted: true });
  await t.call({ action: "vote", report_id, voted: false });

  const listed = await t.call({ action: "list" });
  assertEquals(listed.body.reports[0].vote_count, 0);
  assertEquals(listed.body.reports[0].voted, false);
});

Deno.test("only managers can change status or reply", async () => {
  const t = setup();
  await t.call(report);
  const update = {
    action: "update",
    report_id: t.rows[0].id,
    status: "in_progress",
    reply: "Шалгаж байна",
  };

  assertEquals((await t.call(update, resident)).status, 403);
  assertEquals(t.rows[0].status, "open");

  assertEquals((await t.call(update, manager)).status, 200);
  const listed = await t.call({ action: "list" });
  assertEquals(listed.body.reports[0].status, "in_progress");
  assertEquals(listed.body.reports[0].reply, "Шалгаж байна");
});

Deno.test("requests must come from an active resident", async () => {
  const t = setup();
  assertEquals((await t.call({ action: "list" }, null)).status, 401);
  assertEquals((await t.call(report, null)).status, 401);
  assertEquals(t.rows.length, 0);
});

Deno.test("reports are validated", async () => {
  const t = setup();
  const bad = [
    { ...report, category: "nope" },
    { ...report, location: "  " },
    { ...report, description: "" },
    { ...report, description: "x".repeat(501) },
  ];
  for (const body of bad) assertEquals((await t.call(body)).status, 400);
  assertEquals(t.rows.length, 0);
});

Deno.test("reporting is rate limited per person", async () => {
  const t = setup();
  for (let i = 0; i < 10; i++) {
    assertEquals((await t.call(report)).status, 200);
  }
  const limited = await t.call(report);
  assertEquals(limited.status, 429);
  assertEquals((await t.call(report, manager)).status, 200);
});

Deno.test("a missing secret refuses every request", async () => {
  const t = setup();
  const { status } = await t.call(report, resident, { secret: undefined });
  assertEquals(status, 500);
  assertEquals(t.rows.length, 0);
});

function tinyJpeg(width = 8, height = 8): Uint8Array {
  const data = new Uint8Array(width * height * 4).fill(180);
  return new Uint8Array(jpeg.encode({ data, width, height }, 90).data);
}

/** Inserts an EXIF segment with GPS text straight after the JPEG header. */
function withExif(input: Uint8Array, secret: string): Uint8Array {
  const payload = new TextEncoder().encode(`Exif\0\0${secret}`);
  const segment = new Uint8Array(payload.length + 4);
  segment.set([0xff, 0xe1, (payload.length + 2) >> 8, (payload.length + 2) & 255]);
  segment.set(payload, 4);
  const out = new Uint8Array(input.length + segment.length);
  out.set(input.subarray(0, 2));
  out.set(segment, 2);
  out.set(input.subarray(2), 2 + segment.length);
  return out;
}

const contains = (haystack: Uint8Array, text: string) =>
  new TextDecoder("latin1").decode(haystack).includes(text);

Deno.test("sanitizePhoto removes EXIF and GPS data", () => {
  const original = withExif(tinyJpeg(), "GPS-47.9184N-106.9177E");
  assert(contains(original, "GPS-47.9184N"), "test image must carry the data");

  const clean = sanitizePhoto(original);

  assertFalse(contains(clean, "GPS-47.9184N"));
  assertFalse(contains(clean, "Exif"));
  assertEquals(jpeg.decode(clean).width, 8);
});

Deno.test("sanitizePhoto rejects anything that isn't a JPEG", () => {
  let threw = false;
  try {
    sanitizePhoto(new TextEncoder().encode("<svg></svg>"));
  } catch {
    threw = true;
  }
  assert(threw);
});

Deno.test("sanitizePhoto handles a full-size upload quickly", () => {
  const large = tinyJpeg(1280, 960);
  const started = performance.now();
  sanitizePhoto(large);
  const elapsed = performance.now() - started;
  console.log(`sanitize 1280x960: ${Math.round(elapsed)} ms`);
  assert(elapsed < 2000);
});

Deno.test("photos are stored only after sanitizing", async () => {
  const t = setup();
  const original = withExif(tinyJpeg(), "GPS-SECRET");

  const created = await t.call(
    { ...report, photo_base64: Buffer.from(original).toString("base64") },
    resident,
    { sanitizePhoto },
  );

  assertEquals(created.body.report.has_photo, true);
  const stored = Buffer.from(t.photos.get(t.rows[0].id)!, "base64");
  assertFalse(contains(stored, "GPS-SECRET"));

  const fetched = await t.call({ action: "photo", report_id: t.rows[0].id });
  assertEquals(fetched.body.photo_base64, t.photos.get(t.rows[0].id));
  await assertNoIdentity(fetched.text, t.rows[0]);
});

Deno.test("a bad photo refuses the report", async () => {
  const t = setup();
  const created = await t.call(
    { ...report, photo_base64: Buffer.from("nope").toString("base64") },
    resident,
    { sanitizePhoto },
  );
  assertEquals(created.status, 400);
  assertEquals(t.rows.length, 0);
});

Deno.test("errors don't log what failed", async () => {
  const t = setup();
  const logged: unknown[] = [];
  const original = console.error;
  console.error = (...args: unknown[]) => logged.push(...args);
  try {
    await t.call(report, resident, {
      store: {
        ...t.store,
        insert: () => Promise.reject(new Error(`bad row ${USER_ID}`)),
      },
    });
  } finally {
    console.error = original;
  }
  assertFalse(JSON.stringify(logged).includes(USER_ID));
});
