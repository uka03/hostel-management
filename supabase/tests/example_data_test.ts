// Checks the example data scripts on an in-memory Postgres. Run from the
// project root:
//
//   deno test -A --no-lock supabase/tests/example_data_test.ts

import { PGlite } from "npm:@electric-sql/pglite@0.3";
import { assertEquals } from "jsr:@std/assert@1";

const SUPABASE = new URL("../", import.meta.url);
const REAL = "11111111-1111-4111-8111-111111111111";

type Row = Record<string, unknown>;

const read = (name: string) => Deno.readTextFileSync(new URL(name, SUPABASE));

async function setup() {
  const db = new PGlite();
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create schema auth;
    create table auth.users (
      id uuid primary key, instance_id uuid, aud text, role text, phone text,
      phone_confirmed_at timestamptz, confirmation_token text,
      recovery_token text, email_change_token_new text, email_change text,
      created_at timestamptz, updated_at timestamptz
    );
    create function auth.uid() returns uuid language sql stable as
      $$ select nullif(current_setting('test.uid', true), '')::uuid $$;
    grant usage on schema public to anon, authenticated;
  `);
  const dir = new URL("migrations/", SUPABASE);
  for (const file of [...Deno.readDirSync(dir)].map((f) => f.name).sort()) {
    await db.exec(Deno.readTextFileSync(new URL(file, dir)));
  }
  await db.query("insert into auth.users (id, phone) values ($1, '97699112233')", [REAL]);
  await db.query(
    "update public.profiles set role = 'manager', status = 'active', name = 'Би' where id = $1",
    [REAL],
  );

  const count = async (sql: string) =>
    Number((await db.query<Row>(`select count(*) as c from ${sql}`)).rows[0].c);
  const totals = async () =>
    (await db.query<Row>(
      `select p.amount, sum(s.share)::int as shares from public.purchases p
       join public.purchase_shares s on s.purchase_id = p.id
       group by p.id, p.amount`,
    )).rows;

  return { db, count, totals };
}

Deno.test("adds data for every feature", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));

  assertEquals(await t.count("public.profiles where status = 'active'"), 6);
  assertEquals(await t.count("public.profiles where status = 'pending'"), 1);
  assertEquals(await t.count("public.purchases"), 8);
  assertEquals(await t.count("public.needed_items"), 4);
  assertEquals(await t.count("public.reports"), 5);
  assertEquals(await t.count("public.report_votes"), 15);

  const order = (await t.db.query<Row>(
    "select private.sequence_at(private.current_period() + 1) as s",
  )).rows[0].s as string[];
  assertEquals(new Set(order).size, 5 + 0 + (order.includes(REAL) ? 1 : 0));
});

Deno.test("purchase shares add up exactly", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));

  for (const row of await t.totals()) assertEquals(row.shares, row.amount);
});

Deno.test("real accounts get purchases to their name", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));

  assertEquals(await t.count(`public.purchases where buyer_id = '${REAL}'`), 2);
});

Deno.test("works when there is no real account yet", async () => {
  const t = await setup();
  await t.db.query("update public.profiles set status = 'pending' where id = $1", [REAL]);

  await t.db.exec(read("example_data.sql"));

  assertEquals(await t.count("public.purchases"), 8);
});

Deno.test("running it twice changes nothing", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));
  await t.db.exec(read("example_data.sql"));

  assertEquals(await t.count("public.purchases"), 8);
  assertEquals(await t.count("public.purchase_shares"), 48);
  assertEquals(await t.count("public.reports"), 5);
  assertEquals(await t.count("public.report_votes"), 15);
  assertEquals(await t.count("auth.users"), 7);
  const order = (await t.db.query<Row>(
    "select private.sequence_at(private.current_period() + 1) as s",
  )).rows[0].s as string[];
  assertEquals(new Set(order).size, order.length);
});

Deno.test("example reports have rounded times and no author", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));

  assertEquals(
    await t.count(
      "public.reports where created_hour <> date_trunc('hour', created_hour)",
    ),
    0,
  );
  assertEquals(await t.count("public.reports where author_hash <> 'example'"), 0);
});

Deno.test("removal leaves no trace and keeps real data correct", async () => {
  const t = await setup();
  await t.db.exec(read("example_data.sql"));

  const realPurchase = "22222222-2222-4222-8222-222222222222";
  await t.db.query(
    `insert into public.purchases (id, buyer_id, title, amount, purchased_on)
     values ($1, $2, 'Жинхэнэ', 1000, current_date)`,
    [realPurchase, REAL],
  );
  await t.db.query(
    `insert into public.purchase_shares (purchase_id, person_id, share)
     select $1, id, 166 + case when id = $2 then 4 else 0 end
     from public.profiles where status = 'active'`,
    [realPurchase, REAL],
  );

  await t.db.exec(read("example_data_remove.sql"));

  assertEquals(await t.count("auth.users"), 1);
  assertEquals(await t.count("public.profiles"), 1);
  assertEquals(await t.count("public.reports"), 0);
  assertEquals(await t.count("public.report_votes"), 0);
  assertEquals(await t.count("public.needed_items"), 0);
  assertEquals(await t.count("public.purchases"), 1);
  assertEquals(await t.totals(), [{ amount: 1000, shares: 1000 }]);

  const leftover = await t.db.query<Row>(
    "select 1 from public.rotation_versions, unnest(member_ids) m where m::text like 'e0000000-%'",
  );
  assertEquals(leftover.rows, []);
});
