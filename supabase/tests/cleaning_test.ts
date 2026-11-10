// Runs the real migrations on an in-memory Postgres, with only the parts of
// Supabase they rely on stubbed. Run from the project root:
//
//   deno test -A --no-lock supabase/tests/cleaning_test.ts

import { PGlite } from "npm:@electric-sql/pglite@0.3";
import { assert, assertEquals, assertRejects } from "jsr:@std/assert@1";

const MIGRATIONS = new URL("../migrations/", import.meta.url);

type Row = Record<string, unknown>;

async function setup() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth;
    create table auth.users (id uuid primary key, phone text);
    create function auth.uid() returns uuid language sql stable as
      $$ select nullif(current_setting('test.uid', true), '')::uuid $$;
    grant usage on schema auth to anon, authenticated;
    grant usage on schema public to anon, authenticated;
  `);
  const files = [...Deno.readDirSync(MIGRATIONS)].map((f) => f.name).sort();
  for (const file of files) {
    await db.exec(Deno.readTextFileSync(new URL(file, MIGRATIONS)));
  }

  let count = 0;
  const addUser = async (
    role = "resident",
    status = "active",
  ): Promise<string> => {
    count++;
    const id = `00000000-0000-0000-0000-${String(count).padStart(12, "0")}`;
    await db.query("insert into auth.users values ($1, $2)", [id, `9769${count}`]);
    await db.query(
      "update public.profiles set role = $2, status = $3, name = $4 where id = $1",
      [id, role, status, `user${count}`],
    );
    return id;
  };

  const as = async (uid: string | null, sql: string, params: unknown[] = []) => {
    await db.exec(`set test.uid = '${uid ?? ""}'`);
    await db.exec(`set role ${uid ? "authenticated" : "anon"}`);
    try {
      return (await db.query<Row>(sql, params)).rows;
    } finally {
      await db.exec("reset role");
    }
  };

  const overview = async (uid: string) =>
    (await as(uid, "select public.cleaning_overview() as o"))[0].o as Row;

  /** Moves the schedule back, so that it is now `days` days after the start. */
  const advanceDays = (days: number) =>
    db.exec(`update public.cleaning_settings set start_date =
      (now() at time zone 'Asia/Ulaanbaatar')::date - ${days}`);

  const dutyAt = async (p: number) =>
    (await db.query<Row>("select private.duty_person($1) as d", [p])).rows[0].d;

  const start = async (ids: string[]) => {
    await db.query(
      "insert into public.cleaning_settings (start_date) values ((now() at time zone 'Asia/Ulaanbaatar')::date)",
    );
    await db.query(
      "insert into public.rotation_versions values (0, $1::uuid[])",
      [ids],
    );
  };

  return { db, addUser, as, overview, advanceDays, dutyAt, start };
}

const areaIds = async (t: Awaited<ReturnType<typeof setup>>) =>
  (await t.db.query<Row>(
    "select id from public.cleaning_areas where active order by position",
  )).rows.map((r) => r.id as string);

Deno.test("rotation advances every 2 days and repeats", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];
  await t.start([a, b, c]);

  assertEquals(await t.dutyAt(0), a);
  assertEquals(await t.dutyAt(1), b);
  assertEquals(await t.dutyAt(2), c);
  assertEquals(await t.dutyAt(3), a);

  const period = async () =>
    (await t.db.query<Row>("select private.current_period() as p")).rows[0].p;
  await t.advanceDays(1);
  assertEquals(await period(), 0);
  await t.advanceDays(2);
  assertEquals(await period(), 1);
});

Deno.test("a join applies from the next period, at the end", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const b = await t.addUser();
  const c = await t.addUser();
  await t.start([manager, b, c]);
  const d = await t.addUser("resident", "pending");

  await t.as(manager, "select public.approve_resident($1)", [d]);

  assertEquals(await t.dutyAt(0), manager);
  assertEquals(await t.dutyAt(1), b);
  assertEquals(await t.dutyAt(2), c);
  assertEquals(await t.dutyAt(3), manager);
  assertEquals(await t.dutyAt(4), d);
});

Deno.test("a leave never changes the current duty person", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const b = await t.addUser();
  const c = await t.addUser();
  await t.start([b, c, manager]);

  await t.as(manager, "select public.remove_resident($1)", [b]);

  assertEquals(await t.dutyAt(0), b, "still on duty this period");
  assertEquals(await t.dutyAt(1), c);
  assertEquals(await t.dutyAt(2), manager);
  assertEquals(await t.dutyAt(3), c);
});

Deno.test("the first resident starts right away", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const a = await t.addUser("resident", "pending");

  await t.as(manager, "select public.approve_resident($1)", [a]);

  assertEquals(await t.dutyAt(0), a);
});

Deno.test("only the duty person can tick, and all areas finish it", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.start([a, b]);
  const areas = await areaIds(t);
  const tick = "select public.set_area_checked($1, $2)";

  await assertRejects(() => t.as(b, tick, [areas[0], true]), Error, "not_on_duty");

  for (const area of areas.slice(0, -1)) await t.as(a, tick, [area, true]);
  assertEquals((await t.overview(a)).done_periods, []);

  await t.as(a, tick, [areas[3], true]);
  assertEquals((await t.overview(a)).done_periods, [0]);

  await t.as(a, tick, [areas[3], false]);
  assertEquals((await t.overview(a)).done_periods, []);
});

Deno.test("a swap only happens after the other resident accepts", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];
  await t.start([a, b, c]);

  const id = (await t.as(a, "select public.request_swap(0, 2) as id"))[0].id;
  assertEquals(await t.dutyAt(0), a);
  assertEquals(await t.dutyAt(2), c);

  const respond = "select public.respond_swap($1, $2) as s";
  await assertRejects(() => t.as(b, respond, [id, true]), Error, "swap_not_found");

  assertEquals((await t.as(c, respond, [id, true]))[0].s, "accepted");
  assertEquals(await t.dutyAt(0), c);
  assertEquals(await t.dutyAt(2), a);
  assertEquals(await t.dutyAt(1), b);
});

Deno.test("a declined swap changes nothing", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.start([a, b]);

  const id = (await t.as(a, "select public.request_swap(0, 1) as id"))[0].id;
  const s = await t.as(b, "select public.respond_swap($1, false) as s", [id]);

  assertEquals(s[0].s, "declined");
  assertEquals(await t.dutyAt(0), a);
  assertEquals(await t.dutyAt(1), b);
});

Deno.test("swap requests are validated", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];
  await t.start([a, b, c]);
  const request = "select public.request_swap($1, $2)";

  await assertRejects(() => t.as(b, request, [0, 2]), Error, "not_your_period");
  await assertRejects(() => t.as(a, request, [0, 3]), Error, "invalid_target");

  await t.as(a, request, [0, 1]);
  await assertRejects(
    () => t.as(c, request, [2, 1]),
    Error,
    "swap_already_pending",
  );
});

Deno.test("a duty already started cannot be swapped", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.start([a, b]);
  const [area] = await areaIds(t);
  await t.as(a, "select public.set_area_checked($1, true)", [area]);

  await assertRejects(
    () => t.as(a, "select public.request_swap(0, 1)"),
    Error,
    "already_started",
  );
});

Deno.test("accepting a stale swap cancels it", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const [b, c] = [await t.addUser(), await t.addUser()];
  await t.start([manager, b, c]);

  const id = (await t.as(b, "select public.request_swap(1, 2) as id"))[0].id;
  await t.as(manager, "select public.set_rotation_order($1::uuid[])", [
    [c, b, manager],
  ]);

  const s = await t.as(c, "select public.respond_swap($1, true) as s", [id]);
  assertEquals(s[0].s, "cancelled");
  assertEquals(await t.dutyAt(1), c);
});

Deno.test("leaving drops the resident's future swaps", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const [b, c] = [await t.addUser(), await t.addUser()];
  await t.start([manager, b, c]);
  const id = (await t.as(b, "select public.request_swap(1, 2) as id"))[0].id;
  await t.as(c, "select public.respond_swap($1, true)", [id]);
  assertEquals(await t.dutyAt(1), c);

  await t.as(manager, "select public.remove_resident($1)", [b]);

  assertEquals(await t.dutyAt(2), manager, "override for b is gone");
});

Deno.test("manager actions are refused for residents", async () => {
  const t = await setup();
  const a = await t.addUser();
  const p = await t.addUser("resident", "pending");
  const refused = [
    ["select public.approve_resident($1)", [p]],
    ["select public.remove_resident($1)", [p]],
    ["select public.set_rotation_order($1::uuid[])", [[a]]],
    ["select public.add_cleaning_area($1)", ["x"]],
  ] as const;
  for (const [sql, params] of refused) {
    await assertRejects(
      () => t.as(a, sql, [...params]),
      Error,
      "not_manager",
    );
  }
});

Deno.test("pending residents can set a name but nothing else", async () => {
  const t = await setup();
  const p = await t.addUser("resident", "pending");

  await t.as(p, "select public.set_my_name($1)", ["  Бат  "]);
  const row = await t.db.query<Row>("select name from public.profiles where id = $1", [p]);
  assertEquals(row.rows[0].name, "Бат");

  await assertRejects(() => t.overview(p), Error, "not_active");
});

Deno.test("clients cannot touch the tables or call in anonymously", async () => {
  const t = await setup();
  const a = await t.addUser();
  await t.start([a]);

  for (
    const table of [
      "rotation_versions",
      "duty_overrides",
      "duty_checks",
      "duty_completions",
      "duty_swaps",
      "cleaning_areas",
      "cleaning_settings",
    ]
  ) {
    await assertRejects(
      () => t.as(a, `select * from public.${table}`),
      Error,
      "permission denied",
    );
  }
  await assertRejects(
    () => t.as(a, "select private.current_period()"),
    Error,
    "permission denied",
  );
  await assertRejects(
    () => t.as(null, "select public.cleaning_overview()"),
    Error,
    "permission denied",
  );
});

Deno.test("profile stats count only your finished duties", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.start([a, b]);
  const stats = async (uid: string) =>
    (await t.as(uid, "select public.profile_stats() as s"))[0].s;
  for (const area of await areaIds(t)) {
    await t.as(a, "select public.set_area_checked($1, true)", [area]);
  }

  assertEquals(await stats(a), { cleaned_count: 1 });
  assertEquals(await stats(b), { cleaned_count: 0 });
});

Deno.test("preferences save for yourself and are validated", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const save = "select public.set_my_preferences($1, $2)";

  await t.as(a, save, [false, "en"]);

  const read = async (id: string) =>
    (await t.db.query<Row>(
      "select notifications_enabled as n, language as l from public.profiles where id = $1",
      [id],
    )).rows[0];
  assertEquals(await read(a), { n: false, l: "en" });
  assertEquals(await read(b), { n: true, l: "mn" });
  await assertRejects(
    () => t.as(a, save, [true, "fr"]),
    Error,
    "invalid_preferences",
  );
  await assertRejects(() => t.as(null, save, [true, "mn"]), Error, "permission denied");
  await assertRejects(
    () => t.as(null, "select public.profile_stats()"),
    Error,
    "permission denied",
  );
});

Deno.test("the overview never exposes phone numbers", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  await t.addUser("resident", "pending");
  await t.start([manager]);

  const text = JSON.stringify(await t.overview(manager));
  assert(!text.includes("phone"));
  assert(!/9769\d/.test(text));
});

Deno.test("only managers see who is waiting for approval", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const a = await t.addUser();
  await t.addUser("resident", "pending");
  await t.start([manager, a]);

  assertEquals(((await t.overview(manager)).pending_residents as Row[]).length, 1);
  assertEquals(((await t.overview(a)).pending_residents as Row[]).length, 0);
});
