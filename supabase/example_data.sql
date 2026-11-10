-- Example data, so every screen has something to show during development.
-- Safe to run more than once. Undo with supabase/example_data_remove.sql.
--
-- Every example row has an id starting with e0000000-, which is how the removal
-- script finds them. The phone numbers can't belong to anyone: no Mongolian
-- number starts with 0.

do $$
declare
  residents constant text[][] := array[
    ['e0000000-0000-4000-8000-000000000001', 'Болд', '97600000001', 'active'],
    ['e0000000-0000-4000-8000-000000000002', 'Сараа', '97600000002', 'active'],
    ['e0000000-0000-4000-8000-000000000003', 'Тэмүүжин', '97600000003', 'active'],
    ['e0000000-0000-4000-8000-000000000004', 'Ану', '97600000004', 'active'],
    ['e0000000-0000-4000-8000-000000000005', 'Оюунаа', '97600000005', 'active'],
    ['e0000000-0000-4000-8000-000000000006', 'Тэмүүлэн', '97600000006', 'pending']
  ];
  r text[];
  bold constant uuid := 'e0000000-0000-4000-8000-000000000001';
  saraa constant uuid := 'e0000000-0000-4000-8000-000000000002';
  temuujin constant uuid := 'e0000000-0000-4000-8000-000000000003';
  anu constant uuid := 'e0000000-0000-4000-8000-000000000004';
  oyunaa constant uuid := 'e0000000-0000-4000-8000-000000000005';
  me uuid;
  today date := private.ub_today();
  next_order uuid[];
  people uuid[];
  n integer;
  p record;
begin
  -- Residents. The auth trigger creates each profile.
  foreach r slice 1 in array residents loop
    insert into auth.users (
      id, instance_id, aud, role, phone, phone_confirmed_at,
      confirmation_token, recovery_token, email_change_token_new, email_change,
      created_at, updated_at
    )
    values (
      r[1]::uuid, '00000000-0000-0000-0000-000000000000', 'authenticated',
      'authenticated', r[3], now(), '', '', '', '', now(), now()
    )
    on conflict (id) do nothing;

    update public.profiles
      set name = r[2], status = r[4]::public.resident_status
      where id = r[1]::uuid;
  end loop;

  -- Example bank accounts, so the payment popup has something to show.
  update public.profiles
    set bank_name = 'Хаан банк',
        bank_account_number = '000000' || right(id::text, 4),
        bank_account_holder = name
    where id::text like 'e0000000-%' and status = 'active';

  -- The real account that example purchases are attributed to, if any.
  select id into me from public.profiles
    where status = 'active' and id::text not like 'e0000000-%'
    order by (role = 'manager') desc, created_at
    limit 1;

  -- Cleaning rotation: example residents join from the next period.
  perform private.ensure_started();
  next_order := private.sequence_at(private.current_period() + 1);
  next_order := next_order || array(
    select unnest(array[bold, saraa, temuujin, anu, oyunaa])
    except select unnest(next_order)
  );
  perform private.write_next_order(next_order);

  -- Purchases, split between everyone active now; the buyer keeps the rest.
  select array_agg(id) into people from public.profiles where status = 'active';
  n := cardinality(people);

  for p in
    select *, ('e0000000-0000-4000-8000-0000000001' || lpad(num::text, 2, '0'))::uuid
        as purchase_id
    from (values
      (1, bold, 'Аяга тавагны угаалга', 4500, 1),
      (2, saraa, 'Цэвэрлэгээний шүршигч', 6000, 3),
      (3, coalesce(me, anu), 'Хогны уут, ариун цэврийн цаас', 12000, 4),
      (4, temuujin, 'Гэрлийн чийдэн', 8200, 6),
      (5, oyunaa, 'Угаалгын нунтаг', 15900, 8),
      (6, coalesce(me, bold), 'Шүүр, хогийн хүрз', 9500, 11),
      (7, anu, 'Гар угаах саван', 3700, 14),
      (8, bold, 'Цонх арчих алчуур', 5400, 20)
    ) as v(num, buyer, title, amount, days_ago)
  loop
    insert into public.purchases (id, buyer_id, title, amount, purchased_on)
      values (p.purchase_id, p.buyer, p.title, p.amount, today - p.days_ago)
      on conflict (id) do nothing;

    if found then
      insert into public.purchase_shares (purchase_id, person_id, share)
        select p.purchase_id, person,
          p.amount / n + case when person = p.buyer then p.amount % n else 0 end
        from unnest(people) as person;
    end if;
  end loop;

  -- Needed items.
  insert into public.needed_items (id, name, requested_by, requested_on, claimed_by)
    values
      ('e0000000-0000-4000-8000-000000000201', 'Ариун цэврийн цаас (12 ш)', saraa, today - 2, null),
      ('e0000000-0000-4000-8000-000000000202', 'Аяга тавагны угаалга', bold, today, null),
      ('e0000000-0000-4000-8000-000000000203', 'Хогны уут', anu, today - 1, null),
      ('e0000000-0000-4000-8000-000000000204', 'Гар угаах саван', temuujin, today - 3, saraa)
    on conflict (id) do nothing;

  -- Reports. author_hash is a placeholder: these have no author at all.
  insert into public.reports
      (id, author_hash, category, location, description, status, reply, created_hour)
    values
      ('e0000000-0000-4000-8000-000000000301', 'example', 'noise',
       '2-р давхрын коридор',
       '23:00-с хойш чанга хөгжим. Энэ долоо хоног бараг шөнө бүр тавьж байна.',
       'in_progress', null, date_trunc('hour', now()) - interval '2 hours'),
      ('e0000000-0000-4000-8000-000000000302', 'example', 'damage',
       'Угаалгын өрөө',
       '2-р давхрын шүршүүр эвдэрсэн. Ус хүйтэн, хошуу нь гоожиж байна.',
       'open', null, date_trunc('hour', now()) - interval '26 hours'),
      ('e0000000-0000-4000-8000-000000000303', 'example', 'hygiene',
       'Гал тогоо',
       'Хамтын хөргөгчинд хугацаа нь дууссан хоол байна.',
       'resolved', 'Хөргөгчийг цэвэрлэсэн. Баярлалаа!',
       date_trunc('hour', now()) - interval '5 days'),
      ('e0000000-0000-4000-8000-000000000304', 'example', 'safety',
       'Гадна хаалга',
       'Гадна хаалганы цоож эвдэрсэн. Шөнө хаагдахгүй байна.',
       'open', null, date_trunc('hour', now()) - interval '7 hours'),
      ('e0000000-0000-4000-8000-000000000305', 'example', 'other',
       'Угаалгын машин',
       'Угаалгын машин ажиллах үед их чичирч байна.',
       'in_progress', 'Засварчин дуудсан, энэ долоо хоногт ирнэ.',
       date_trunc('hour', now()) - interval '3 days')
    on conflict (id) do nothing;

  insert into public.report_votes (vote_hash, report_id)
    select 'example-' || report_id || '-' || i, report_id::uuid
    from (values
      ('e0000000-0000-4000-8000-000000000301', 4),
      ('e0000000-0000-4000-8000-000000000302', 5),
      ('e0000000-0000-4000-8000-000000000303', 2),
      ('e0000000-0000-4000-8000-000000000304', 3),
      ('e0000000-0000-4000-8000-000000000305', 1)
    ) as v(report_id, votes), generate_series(1, votes) as i
    on conflict (vote_hash) do nothing;
end;
$$;
