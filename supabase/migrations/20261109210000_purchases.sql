-- Shared purchases, split equally between people (never rooms).
--
-- Each purchase stores its shares when it is made, so someone who moves in
-- later never pays for earlier purchases, and someone who moves out still owes
-- theirs. Amounts are whole tögrög. share = amount / people, and the remainder
-- stays with the buyer, so the shares always add up to the amount exactly.
--
-- Clients have no direct table access: everything goes through the functions
-- below. Purchases are not anonymous; the buyer's name is shown.

create table public.purchases (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references public.profiles (id),
  title text not null check (char_length(btrim(title)) between 1 and 80),
  amount integer not null check (amount between 1 and 100000000),
  purchased_on date not null,
  created_at timestamptz not null default now()
);

create table public.purchase_shares (
  purchase_id uuid not null references public.purchases (id) on delete cascade,
  person_id uuid not null references public.profiles (id),
  share integer not null check (share >= 0),
  primary key (purchase_id, person_id)
);

create table public.needed_items (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 80),
  requested_by uuid not null references public.profiles (id),
  requested_on date not null,
  claimed_by uuid references public.profiles (id),
  bought boolean not null default false,
  created_at timestamptz not null default now()
);

do $$
declare
  t text;
begin
  foreach t in array array['purchases', 'purchase_shares', 'needed_items'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant all on public.%I to service_role', t);
  end loop;
end;
$$;

-- Splits between everyone active right now; the buyer keeps the remainder.
create function private.create_purchase(
  p_buyer uuid,
  p_title text,
  p_amount integer
)
returns uuid language plpgsql set search_path = '' as $$
declare
  people uuid[];
  n integer;
  new_id uuid;
begin
  if p_amount is null or p_amount not between 1 and 100000000 then
    raise exception 'invalid_amount';
  end if;
  if char_length(btrim(coalesce(p_title, ''))) not between 1 and 80 then
    raise exception 'invalid_title';
  end if;

  select array_agg(id) into people
    from public.profiles where status = 'active';
  n := cardinality(people);

  insert into public.purchases (buyer_id, title, amount, purchased_on)
    values (p_buyer, btrim(p_title), p_amount, private.ub_today())
    returning id into new_id;

  insert into public.purchase_shares (purchase_id, person_id, share)
    select new_id, person,
      p_amount / n + case when person = p_buyer then p_amount % n else 0 end
    from unnest(people) as person;

  return new_id;
end;
$$;

create function public.purchases_overview()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  return jsonb_build_object(
    'today', private.ub_today(),
    'active_count', (
      select count(*) from public.profiles where status = 'active'
    ),
    -- Running totals, not limited to any month or to the list below.
    'total_amount', (
      select coalesce(sum(amount), 0) from public.purchases
    ),
    'my_paid', (
      select coalesce(sum(amount), 0) from public.purchases where buyer_id = me
    ),
    'my_share', (
      select coalesce(sum(share), 0) from public.purchase_shares
      where person_id = me
    ),
    'purchases', coalesce((
      select jsonb_agg(row_data order by purchased_on desc, created_at desc)
      from (
        select
          p.purchased_on,
          p.created_at,
          jsonb_build_object(
            'id', p.id,
            'title', p.title,
            'amount', p.amount,
            'buyer_id', p.buyer_id,
            'buyer_name', buyer.name,
            'purchased_on', p.purchased_on,
            'my_share', (
              select s.share from public.purchase_shares s
              where s.purchase_id = p.id and s.person_id = me
            ),
            'people_count', (
              select count(*) from public.purchase_shares s
              where s.purchase_id = p.id
            )
          ) as row_data
        from public.purchases p
        join public.profiles buyer on buyer.id = p.buyer_id
        order by p.purchased_on desc, p.created_at desc
        limit 300
      ) recent
    ), '[]'::jsonb),
    'needed_items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', i.id,
        'name', i.name,
        'requested_by', i.requested_by,
        'requested_on', i.requested_on,
        'claimed_by', i.claimed_by,
        'claimed_by_name', claimer.name
      ) order by i.created_at)
      from public.needed_items i
      left join public.profiles claimer on claimer.id = i.claimed_by
      where not i.bought
    ), '[]'::jsonb)
  );
end;
$$;

create function public.add_purchase(p_title text, p_amount integer)
returns uuid language plpgsql security definer set search_path = '' as $$
begin
  return private.create_purchase(private.require_active(), p_title, p_amount);
end;
$$;

-- For correcting a mistake: the buyer's own, or any purchase by a manager.
create function public.delete_purchase(p_purchase_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  delete from public.purchases
    where id = p_purchase_id and (
      buyer_id = me or exists (
        select 1 from public.profiles where id = me and role = 'manager'
      )
    );
  if not found then
    raise exception 'purchase_not_found';
  end if;
end;
$$;

create function public.add_needed_item(p_name text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  new_id uuid;
begin
  if char_length(btrim(coalesce(p_name, ''))) not between 1 and 80 then
    raise exception 'invalid_name';
  end if;
  insert into public.needed_items (name, requested_by, requested_on)
    values (btrim(p_name), me, private.ub_today())
    returning id into new_id;
  return new_id;
end;
$$;

create function public.claim_item(p_item_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  update public.needed_items set claimed_by = me
    where id = p_item_id and claimed_by is null and not bought;
  if not found then
    raise exception 'item_not_available';
  end if;
end;
$$;

create function public.unclaim_item(p_item_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  update public.needed_items set claimed_by = null
    where id = p_item_id and claimed_by = me and not bought;
  if not found then
    raise exception 'item_not_available';
  end if;
end;
$$;

-- Adding the receipt amount turns a claimed item into a purchase.
create function public.complete_item(p_item_id uuid, p_amount integer)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  item_name text;
  new_id uuid;
begin
  select name into item_name from public.needed_items
    where id = p_item_id and claimed_by = me and not bought
    for update;
  if not found then
    raise exception 'item_not_available';
  end if;

  new_id := private.create_purchase(me, item_name, p_amount);
  update public.needed_items set bought = true where id = p_item_id;
  return new_id;
end;
$$;

-- The person who asked, or a manager, can take a request back.
create function public.remove_needed_item(p_item_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  delete from public.needed_items
    where id = p_item_id and not bought and (
      requested_by = me or exists (
        select 1 from public.profiles where id = me and role = 'manager'
      )
    );
  if not found then
    raise exception 'item_not_available';
  end if;
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'purchases_overview()',
    'add_purchase(text, integer)',
    'delete_purchase(uuid)',
    'add_needed_item(text)',
    'claim_item(uuid)',
    'unclaim_item(uuid)',
    'complete_item(uuid, integer)',
    'remove_needed_item(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end;
$$;
