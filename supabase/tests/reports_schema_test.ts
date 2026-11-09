// Checks the reports tables on an in-memory Postgres, with only the parts of
// Supabase the migrations rely on stubbed. Run from the project root:
//
//   deno test -A --no-lock supabase/tests/reports_schema_test.ts

import { PGlite } from "npm:@electric-sql/pglite@0.3";
import { assertEquals, assertRejects } from "jsr:@std/assert@1";

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
    grant usage on schema public to anon, authenticated;
  `);
  const files = [...Deno.readDirSync(MIGRATIONS)].map((f) => f.name).sort();
  for (const file of files) {
    await db.exec(Deno.readTextFileSync(new URL(file, MIGRATIONS)));
  }
  return db;
}

const insert = `insert into public.reports
  (author_hash, category, location, description, created_hour)
  values ('h', 'noise', 'hall', 'text', $1) returning id`;

Deno.test("no column can identify a report's author", async () => {
  const db = await setup();
  const columns = await db.query<Row>(
    `select table_name, column_name from information_schema.columns
     where table_schema = 'public'
       and table_name in ('reports', 'report_votes', 'report_photos')`,
  );
  const names = columns.rows.map((r) => r.column_name as string);

  for (const forbidden of ["user_id", "author", "author_id", "phone", "voter"]) {
    assertEquals(names.includes(forbidden), false, forbidden);
  }
  const foreignKeys = await db.query<Row>(
    `select conrelid::regclass::text as t, confrelid::regclass::text as target
     from pg_constraint where contype = 'f'
       and conrelid::regclass::text in
         ('reports', 'report_votes', 'report_photos')`,
  );
  for (const key of foreignKeys.rows) {
    assertEquals(key.target, "reports", `${key.t} must only reference reports`);
  }
});

Deno.test("no photo or vote row records a time", async () => {
  const db = await setup();
  const columns = await db.query<Row>(
    `select column_name from information_schema.columns
     where table_schema = 'public'
       and table_name in ('report_votes', 'report_photos')
       and data_type like 'timestamp%'`,
  );
  assertEquals(columns.rows, []);
});

Deno.test("exact times are refused, rounded hours accepted", async () => {
  const db = await setup();
  await assertRejects(
    () => db.query(insert, ["2026-11-09T14:37:21Z"]),
    Error,
    "created_hour_check",
  );
  await db.query(insert, ["2026-11-09T14:00:00Z"]);
});

Deno.test("the default time is rounded to the hour", async () => {
  const db = await setup();
  const { rows } = await db.query<Row>(
    `insert into public.reports (author_hash, category, location, description)
     values ('h', 'noise', 'hall', 'text')
     returning extract(minute from created_hour) as m,
               extract(second from created_hour) as s`,
  );
  assertEquals(Number(rows[0].m), 0);
  assertEquals(Number(rows[0].s), 0);
});

Deno.test("clients cannot reach the tables", async () => {
  const db = await setup();
  for (const role of ["anon", "authenticated"]) {
    await db.exec(`set role ${role}`);
    for (const table of ["reports", "report_votes", "report_photos"]) {
      await assertRejects(
        () => db.query(`select * from public.${table}`),
        Error,
        "permission denied",
      );
    }
    await db.exec("reset role");
  }
});
