// Runs the real migrations on an in-memory Postgres, with only the parts of
// Supabase they rely on stubbed. Run from the project root:
//
//   deno test -A --no-lock supabase/tests/purchases_test.ts

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

  const overview = async (uid: string) =>
    (await as(uid, "select public.purchases_overview() as o"))[0].o as {
      purchases: Row[];
      needed_items: Row[];
      active_count: number;
      total_amount: number;
      my_paid: number;
      my_share: number;
    };

  const shares = async (purchaseId: unknown) =>
    Object.fromEntries(
      (await db.query<Row>(
        "select person_id, share from public.purchase_shares where purchase_id = $1",
        [purchaseId],
      )).rows.map((r) => [r.person_id as string, r.share as number]),
    );

  const buy = async (uid: string, amount: number, title = "Цаас") =>
    (await as(uid, "select public.add_purchase($1, $2) as id", [title, amount]))[0]
      .id;

  return { db, addUser, as, overview, shares, buy };
}

Deno.test("cost is split equally between people", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];

  const id = await t.buy(a, 3000);

  assertEquals(await t.shares(id), { [a]: 1000, [b]: 1000, [c]: 1000 });
});

Deno.test("the buyer keeps the remainder, so shares sum exactly", async () => {
  const t = await setup();
  const [a, b, c] = [await t.addUser(), await t.addUser(), await t.addUser()];

  const id = await t.buy(b, 1000);
  const shares = await t.shares(id);

  assertEquals(shares, { [a]: 333, [b]: 334, [c]: 333 });
  assertEquals(Object.values(shares).reduce((x, y) => x + y), 1000);
});

Deno.test("someone who joins later doesn't pay for earlier purchases", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const b = await t.addUser();
  const id = await t.buy(b, 1000);

  const late = await t.addUser("resident", "pending");
  await t.db.query(
    "insert into public.cleaning_settings (start_date) values ((now() at time zone 'Asia/Ulaanbaatar')::date)",
  );
  await t.as(manager, "select public.approve_resident($1)", [late]);

  assertEquals(await t.shares(id), { [manager]: 500, [b]: 500 });

  const next = await t.buy(b, 900);
  assertEquals(await t.shares(next), { [manager]: 300, [b]: 300, [late]: 300 });
  const old = (await t.overview(late)).purchases.find((p) => p.id === id)!;
  assertEquals(old.my_share, null);
});

Deno.test("pending and departed people don't share in purchases", async () => {
  const t = await setup();
  const a = await t.addUser();
  const b = await t.addUser();
  await t.addUser("resident", "pending");
  await t.addUser("resident", "left");

  assertEquals(await t.shares(await t.buy(a, 100)), { [a]: 50, [b]: 50 });
});

Deno.test("someone who leaves still owes their earlier share", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const b = await t.addUser();
  const id = await t.buy(manager, 1000);
  await t.db.query(
    "insert into public.cleaning_settings (start_date) values ((now() at time zone 'Asia/Ulaanbaatar')::date)",
  );

  await t.as(manager, "select public.remove_resident($1)", [b]);

  assertEquals(await t.shares(id), { [manager]: 500, [b]: 500 });
});

Deno.test("amounts must be whole, positive and reasonable", async () => {
  const t = await setup();
  const a = await t.addUser();
  const add = "select public.add_purchase($1, $2)";

  await assertRejects(() => t.as(a, add, ["x", 0]), Error, "invalid_amount");
  await assertRejects(() => t.as(a, add, ["x", -5]), Error, "invalid_amount");
  await assertRejects(
    () => t.as(a, add, ["x", 100000001]),
    Error,
    "invalid_amount",
  );
  await assertRejects(() => t.as(a, add, [" ", 100]), Error, "invalid_title");
});

Deno.test("the overview reports each person's own share and the buyer", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  await t.buy(a, 101, "Хогны уут");

  const seen = (await t.overview(b)).purchases[0];

  assertEquals(seen.title, "Хогны уут");
  assertEquals(seen.amount, 101);
  assertEquals(seen.buyer_name, "user1");
  assertEquals(seen.my_share, 50);
  assertEquals(seen.people_count, 2);
  assertEquals((await t.overview(a)).purchases[0].my_share, 51);
});

Deno.test("balances run across all time, not one month", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const old = await t.buy(a, 1000);
  await t.db.query(
    "update public.purchases set purchased_on = date '2020-01-15' where id = $1",
    [old],
  );
  await t.buy(b, 400);

  const seen = await t.overview(a);

  assertEquals(seen.total_amount, 1400);
  assertEquals(seen.my_paid, 1000);
  assertEquals(seen.my_share, 700);
});

Deno.test("balances include purchases beyond the listed ones", async () => {
  const t = await setup();
  const a = await t.addUser();
  await t.db.query(
    `insert into public.purchases (id, buyer_id, title, amount, purchased_on)
     select gen_random_uuid(), $1, 'x', 10, date '2026-01-01'
     from generate_series(1, 305)`,
    [a],
  );
  await t.db.query(
    `insert into public.purchase_shares (purchase_id, person_id, share)
     select id, $1, amount from public.purchases`,
    [a],
  );

  const seen = await t.overview(a);

  assertEquals(seen.purchases.length, 300);
  assertEquals(seen.total_amount, 3050);
  assertEquals(seen.my_share, 3050);
});

Deno.test("someone who joins later starts with a zero balance", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  await t.buy(manager, 1000);
  const late = await t.addUser();

  const seen = await t.overview(late);

  assertEquals(seen.total_amount, 1000);
  assertEquals(seen.my_paid, 0);
  assertEquals(seen.my_share, 0);
});

Deno.test("paying your share settles it between you and the buyer", async () => {
  const t = await setup();
  const [buyer, payer, other] = [
    await t.addUser(),
    await t.addUser(),
    await t.addUser(),
  ];
  const id = await t.buy(buyer, 900);
  const balance = async (uid: string) => {
    const seen = await t.overview(uid);
    return seen.my_paid - seen.my_share;
  };
  assertEquals(await balance(buyer), 600);
  assertEquals(await balance(payer), -300);

  await t.as(payer, "select public.set_share_paid($1, true)", [id]);

  assertEquals(await balance(payer), 0);
  assertEquals(await balance(buyer), 300);
  assertEquals(await balance(other), -300);
  const seen = (await t.overview(payer)).purchases[0];
  assertEquals(seen.my_paid, true);
  assertEquals(seen.paid_count, 1);
  assertEquals((await t.overview(other)).purchases[0].my_paid, false);
  assertEquals(await t.shares(id), { [buyer]: 300, [payer]: 300, [other]: 300 });

  await t.as(payer, "select public.set_share_paid($1, false)", [id]);

  assertEquals(await balance(payer), -300);
  assertEquals(await balance(buyer), 600);
  assertEquals((await t.overview(payer)).purchases[0].paid_count, 0);
});

Deno.test("balances across everyone always sum to zero", async () => {
  const t = await setup();
  const people = [await t.addUser(), await t.addUser(), await t.addUser()];
  const first = await t.buy(people[0], 1000);
  await t.buy(people[1], 701);
  await t.as(people[2], "select public.set_share_paid($1, true)", [first]);

  let sum = 0;
  for (const person of people) {
    const seen = await t.overview(person);
    sum += seen.my_paid - seen.my_share;
  }
  assertEquals(sum, 0);
});

Deno.test("you can only mark your own share as paid", async () => {
  const t = await setup();
  const buyer = await t.addUser();
  await t.addUser();
  const id = await t.buy(buyer, 100);
  const late = await t.addUser();
  const pay = "select public.set_share_paid($1, true)";

  await assertRejects(() => t.as(buyer, pay, [id]), Error, "share_not_found");
  await assertRejects(() => t.as(late, pay, [id]), Error, "share_not_found");
  await assertRejects(() => t.as(null, pay, [id]), Error, "permission denied");
});

const setAccount = "select public.set_my_payment_account($1, $2, $3)";

Deno.test("someone who owes a share can see the buyer's account", async () => {
  const t = await setup();
  const [buyer, payer] = [await t.addUser(), await t.addUser()];
  await t.as(buyer, setAccount, ["Хаан банк", "5000123456", "  Болд Бат "]);
  const id = await t.buy(buyer, 100);

  const info = (await t.as(
    payer,
    "select public.purchase_payment_info($1) as i",
    [id],
  ))[0].i;

  assertEquals(info, {
    buyer_name: "user1",
    bank_name: "Хаан банк",
    account_number: "5000123456",
    account_holder: "Болд Бат",
  });
});

Deno.test("a buyer with no account still returns their name", async () => {
  const t = await setup();
  const [buyer, payer] = [await t.addUser(), await t.addUser()];
  const id = await t.buy(buyer, 100);

  const info = (await t.as(
    payer,
    "select public.purchase_payment_info($1) as i",
    [id],
  ))[0].i as Row;

  assertEquals(info.buyer_name, "user1");
  assertEquals(info.account_number, null);
});

Deno.test("account details are limited to people with a share", async () => {
  const t = await setup();
  const [buyer, payer] = [await t.addUser(), await t.addUser()];
  await t.as(buyer, setAccount, ["Хаан банк", "5000123456", "Болд"]);
  const id = await t.buy(buyer, 100);
  const late = await t.addUser();
  const read = "select public.purchase_payment_info($1)";

  await assertRejects(() => t.as(late, read, [id]), Error, "share_not_found");
  await assertRejects(() => t.as(buyer, read, [id]), Error, "share_not_found");
  await assertRejects(() => t.as(null, read, [id]), Error, "permission denied");

  assert(!JSON.stringify(await t.overview(payer)).includes("5000123456"));
  const others = await t.as(
    payer,
    "select bank_account_number from public.profiles where id = $1",
    [buyer],
  );
  assertEquals(others, []);
});

Deno.test("account details are validated", async () => {
  const t = await setup();
  const a = await t.addUser();

  for (const bad of [
    ["", "5000123456", "Бат"],
    ["Хаан банк", "12", "Бат"],
    ["Хаан банк", "50001x3456", "Бат"],
    ["Хаан банк", "5000123456", "  "],
  ]) {
    await assertRejects(() => t.as(a, setAccount, bad), Error, "invalid_account");
  }
});

Deno.test("a needed item goes from request to claim to purchase", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];

  const id = (await t.as(a, "select public.add_needed_item($1) as id", ["Саван"]))[0]
    .id;
  assertEquals((await t.overview(b)).needed_items[0].claimed_by, null);

  await t.as(b, "select public.claim_item($1)", [id]);
  assertEquals((await t.overview(a)).needed_items[0].claimed_by_name, "user2");

  const purchase = (await t.as(
    b,
    "select public.complete_item($1, $2) as id",
    [id, 2001],
  ))[0].id;

  assertEquals(await t.shares(purchase), { [a]: 1000, [b]: 1001 });
  const seen = await t.overview(a);
  assertEquals(seen.needed_items, []);
  assertEquals(seen.purchases[0].title, "Саван");
  assertEquals(seen.purchases[0].buyer_id, b);
});

Deno.test("an item can only be claimed once, and finished by its claimer", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const id = (await t.as(a, "select public.add_needed_item('Саван') as id"))[0].id;

  await t.as(a, "select public.claim_item($1)", [id]);

  await assertRejects(
    () => t.as(b, "select public.claim_item($1)", [id]),
    Error,
    "item_not_available",
  );
  await assertRejects(
    () => t.as(b, "select public.complete_item($1, 100)", [id]),
    Error,
    "item_not_available",
  );
  await assertRejects(
    () => t.as(b, "select public.unclaim_item($1)", [id]),
    Error,
    "item_not_available",
  );

  await t.as(a, "select public.unclaim_item($1)", [id]);
  await t.as(b, "select public.claim_item($1)", [id]);
});

Deno.test("a bought item can't be bought again", async () => {
  const t = await setup();
  const a = await t.addUser();
  const id = (await t.as(a, "select public.add_needed_item('Саван') as id"))[0].id;
  await t.as(a, "select public.claim_item($1)", [id]);
  await t.as(a, "select public.complete_item($1, 100)", [id]);

  await assertRejects(
    () => t.as(a, "select public.complete_item($1, 100)", [id]),
    Error,
    "item_not_available",
  );
  assertEquals((await t.overview(a)).purchases.length, 1);
});

Deno.test("only the buyer or a manager can delete a purchase", async () => {
  const t = await setup();
  const manager = await t.addUser("manager");
  const [a, b] = [await t.addUser(), await t.addUser()];
  const del = "select public.delete_purchase($1)";
  const id = await t.buy(a, 300);

  await assertRejects(() => t.as(b, del, [id]), Error, "purchase_not_found");

  await t.as(a, del, [id]);
  assertEquals((await t.overview(a)).purchases, []);

  await t.as(manager, del, [await t.buy(b, 300)]);
  assertEquals((await t.overview(a)).purchases, []);
});

Deno.test("only the requester or a manager can remove a request", async () => {
  const t = await setup();
  const [a, b] = [await t.addUser(), await t.addUser()];
  const id = (await t.as(a, "select public.add_needed_item('Саван') as id"))[0].id;

  await assertRejects(
    () => t.as(b, "select public.remove_needed_item($1)", [id]),
    Error,
    "item_not_available",
  );
  await t.as(a, "select public.remove_needed_item($1)", [id]);
  assertEquals((await t.overview(a)).needed_items, []);
});

Deno.test("pending residents are refused, clients can't reach tables", async () => {
  const t = await setup();
  const a = await t.addUser();
  const p = await t.addUser("resident", "pending");

  await assertRejects(() => t.overview(p), Error, "not_active");
  await assertRejects(() => t.buy(p, 100), Error, "not_active");
  for (const table of ["purchases", "purchase_shares", "needed_items"]) {
    await assertRejects(
      () => t.as(a, `select * from public.${table}`),
      Error,
      "permission denied",
    );
  }
  await assertRejects(
    () => t.as(null, "select public.purchases_overview()"),
    Error,
    "permission denied",
  );
});

Deno.test("the overview never exposes phone numbers", async () => {
  const t = await setup();
  const a = await t.addUser();
  await t.buy(a, 100);
  await t.as(a, "select public.add_needed_item('Саван')");

  const text = JSON.stringify(await t.overview(a));
  assert(!text.includes("phone"));
  assert(!/9769\d/.test(text));
});
