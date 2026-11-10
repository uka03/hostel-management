// Runs the real migrations on an in-memory Postgres, with only the parts of
// Supabase they rely on stubbed. Run from the project root:
//
//   deno test -A --no-lock supabase/tests/notifications_test.ts

import { PGlite } from "npm:@electric-sql/pglite@0.3";
import { assert, assertEquals, assertRejects } from "jsr:@std/assert@1";

const MIGRATIONS = new URL("../migrations/", import.meta.url);

type Row = Record<string, unknown>;
type Note = { id: string; kind: string; data: Row; created_at: string; read: boolean };

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
  const addUser = async (role = "resident", status = "active") => {
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

  const notes = async (uid: string) =>
    (await as(uid, "select public.my_notifications() as n"))[0].n as {
      unread_count: number;
      items: Note[];
    };

  const buy = async (uid: string, amount: number, title = "Цаас") =>
    (await as(uid, "select public.add_purchase($1, $2) as id", [title, amount]))[0]
      .id;

  // Reports are written by the Edge Function with the service role.
  const report = async () =>
    (await db.query<Row>(
      `insert into public.reports (author_hash, category, location, description)
       values ('secret-hash', 'damage', 'Угаалга', 'Эвдэрсэн') returning id`,
    )).rows[0].id;

  return { db, addUser, as, notes, buy, report };
}

Deno.test("a new purchase tells everyone who shares in it", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];

  await t.buy(a, 3000, "Саван");

  assertEquals((await t.notes(a)).items, [], "not the buyer");
  for (const person of [b, c]) {
    const n = await t.notes(person);
    assertEquals(n.unread_count, 1);
    assertEquals(n.items[0].kind, "new_purchase");
    assertEquals(n.items[0].data, {
      person_name: "user1",
      title: "Саван",
      amount: 1000,
    });
  }
});

Deno.test("paying tells the buyer once", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const id = await t.buy(a, 3000);

  await t.as(b, "select public.set_share_paid($1, true)", [id]);
  // Paying again after an undo shouldn't be missed, but an undo says nothing.
  await t.as(b, "select public.set_share_paid($1, false)", [id]);

  const n = await t.notes(a);
  assertEquals(n.items.map((i) => i.kind), ["paid"]);
  assertEquals(n.items[0].data, { person_name: "user2", title: "Цаас", amount: 1500 });

  await t.as(b, "select public.set_share_paid($1, true)", [id]);
  assertEquals((await t.notes(a)).unread_count, 2);
});

Deno.test("reading marks everything read, only for me", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];
  await t.buy(a, 300);

  await t.as(b, "select public.mark_notifications_read()");

  assertEquals((await t.notes(b)).unread_count, 0);
  assertEquals((await t.notes(b)).items[0].read, true);
  assertEquals((await t.notes(c)).unread_count, 1);
});

Deno.test("notifications off means none are written", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.as(b, "select public.set_my_preferences(false, 'mn')");

  await t.buy(a, 300);

  assertEquals((await t.notes(b)).items, []);
});

Deno.test("a deleted purchase takes its notifications with it", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const id = await t.buy(a, 300);

  await t.as(a, "select public.delete_purchase($1)", [id]);

  assertEquals((await t.notes(b)).items, []);
});

Deno.test("a new report goes to every manager, at the rounded hour", async () => {
  const t = await setup();
  const resident = await t.addUser();
  const [m1, m2] = [await t.addUser("manager"), await t.addUser("manager")];

  await t.report();

  assertEquals((await t.notes(resident)).items, []);
  for (const m of [m1, m2]) {
    const [item] = (await t.notes(m)).items;
    assertEquals(item.kind, "report_new");
    assertEquals(item.data, { category: "damage", location: "Угаалга" });
    const at = new Date(item.created_at);
    assertEquals(at.getUTCMinutes() + at.getUTCSeconds() + at.getUTCMilliseconds(), 0);
  }
});

Deno.test("report notifications can't identify the author", async () => {
  const t = await setup();
  const author = await t.addUser();
  const other = await t.addUser();
  const manager = await t.addUser("manager");

  const id = await t.report();
  await t.db.query(
    "update public.reports set status = 'in_progress', reply = 'Засна' where id = $1",
    [id],
  );

  // Everyone of a role gets the same thing, so recipients reveal nothing.
  const forAuthor = (await t.notes(author)).items;
  const forOther = (await t.notes(other)).items;
  assertEquals(forAuthor.map((i) => [i.kind, i.data]), forOther.map((i) => [i.kind, i.data]));
  assertEquals(forAuthor[0].data, {
    location: "Угаалга",
    status: "in_progress",
    replied: true,
  });

  const text = JSON.stringify([forAuthor, (await t.notes(manager)).items]);
  for (const leak of ["secret-hash", author, "user1", "9769", "phone", "author"]) {
    assert(!text.includes(leak), leak);
  }

  // The table itself has nothing pointing back at a report's author.
  const rows = await t.db.query<Row>(
    "select distinct recipient_id from public.notifications where report_id = $1",
    [id],
  );
  assertEquals(
    rows.rows.map((r) => r.recipient_id).sort(),
    [author, other, manager].sort(),
  );
});

Deno.test("an update with no visible change says nothing", async () => {
  const t = await setup();
  const r = await t.addUser();
  const id = await t.report();

  await t.db.query("update public.reports set status = 'open' where id = $1", [id]);

  assertEquals((await t.notes(r)).items, []);
});

Deno.test("an exact time on a new-report notification is refused", async () => {
  const t = await setup();
  const m = await t.addUser("manager");
  await assertRejects(
    () =>
      t.db.query(
        `insert into public.notifications (recipient_id, kind, created_at)
         values ($1, 'report_new', '2026-11-10 14:37:00+00')`,
        [m],
      ),
    Error,
    "check",
  );
});

Deno.test("clients can't reach the table, pending residents are refused", async () => {
  const t = await setup();
  const a = await t.addUser();
  const p = await t.addUser("resident", "pending");

  await assertRejects(
    () => t.as(a, "select * from public.notifications"),
    Error,
    "permission denied",
  );
  await assertRejects(() => t.notes(p), Error, "not_active");
  await assertRejects(
    () => t.as(null, "select public.my_notifications()"),
    Error,
    "permission denied",
  );
});
