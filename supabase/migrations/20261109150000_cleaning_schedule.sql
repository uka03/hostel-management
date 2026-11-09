-- Cleaning schedule: one person on duty per 2-day period.
--
-- Clients have no direct table access. Everything goes through the functions
-- at the end of this file, which enforce who may do what. Duty status is
-- derived (a period with no completion row that has ended is "missed"), so no
-- scheduled job is needed.

create schema private;
revoke all on schema private from public, anon, authenticated;

create table public.cleaning_settings (
  singleton boolean primary key default true check (singleton),
  start_date date not null
);

-- The order from a given period on. member_ids[1] is on duty in that period,
-- and the list repeats after that. Past versions are never changed, which is
-- what keeps history and the current duty stable when the order changes.
create table public.rotation_versions (
  effective_period integer primary key check (effective_period >= 0),
  member_ids uuid[] not null
);

-- A period whose duty person was changed by an accepted swap.
create table public.duty_overrides (
  period integer primary key,
  person_id uuid not null references public.profiles (id) on delete cascade
);

create table public.cleaning_areas (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 60),
  position integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.duty_checks (
  period integer not null,
  area_id uuid not null references public.cleaning_areas (id),
  checked_by uuid not null references public.profiles (id) on delete cascade,
  checked_at timestamptz not null default now(),
  primary key (period, area_id)
);

create table public.duty_completions (
  period integer primary key,
  person_id uuid not null references public.profiles (id) on delete cascade,
  completed_at timestamptz not null default now()
);

create type public.swap_status as enum
  ('pending', 'accepted', 'declined', 'cancelled');

create table public.duty_swaps (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles (id) on delete cascade,
  target_id uuid not null references public.profiles (id) on delete cascade,
  requester_period integer not null,
  target_period integer not null,
  status public.swap_status not null default 'pending',
  created_at timestamptz not null default now(),
  responded_at timestamptz
);

do $$
declare
  t text;
begin
  foreach t in array array[
    'cleaning_settings', 'rotation_versions', 'duty_overrides',
    'cleaning_areas', 'duty_checks', 'duty_completions', 'duty_swaps'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant all on public.%I to service_role', t);
  end loop;
end;
$$;

-- Helpers. The private schema is not reachable from the API.

create function private.ub_today()
returns date language sql stable set search_path = '' as $$
  select (now() at time zone 'Asia/Ulaanbaatar')::date;
$$;

create function private.current_period()
returns integer language sql stable set search_path = '' as $$
  select (private.ub_today() - start_date) / 2 from public.cleaning_settings;
$$;

-- The rotation as seen from period p: element 1 is on duty in p.
create function private.sequence_at(p integer)
returns uuid[] language plpgsql stable set search_path = '' as $$
declare
  v public.rotation_versions;
  n integer;
  o integer;
begin
  select * into v from public.rotation_versions
    where effective_period <= p
    order by effective_period desc limit 1;
  if not found then
    return '{}';
  end if;
  n := cardinality(v.member_ids);
  if n = 0 then
    return '{}';
  end if;
  o := (p - v.effective_period) % n;
  return v.member_ids[o + 1:n] || v.member_ids[1:o];
end;
$$;

create function private.duty_person(p integer)
returns uuid language sql stable set search_path = '' as $$
  select coalesce(
    (select person_id from public.duty_overrides where period = p),
    (private.sequence_at(p))[1]
  );
$$;

create function private.require_active()
returns uuid language plpgsql stable set search_path = '' as $$
declare
  me uuid := auth.uid();
begin
  if me is null or not exists (
    select 1 from public.profiles where id = me and status = 'active'
  ) then
    raise exception 'not_active';
  end if;
  return me;
end;
$$;

create function private.require_manager()
returns uuid language plpgsql stable set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  if not exists (
    select 1 from public.profiles where id = me and role = 'manager'
  ) then
    raise exception 'not_manager';
  end if;
  return me;
end;
$$;

create function private.ensure_started()
returns void language sql set search_path = '' as $$
  insert into public.cleaning_settings (start_date)
    values (private.ub_today())
    on conflict do nothing;
$$;

-- Sets the order from the next period on. The current duty person never
-- changes, unless nobody is on duty yet, in which case it starts right away.
create function private.write_next_order(ids uuid[])
returns void language plpgsql set search_path = '' as $$
declare
  c integer := private.current_period();
  effective integer := c + 1;
begin
  if cardinality(private.sequence_at(c)) = 0 then
    effective := c;
  end if;

  insert into public.rotation_versions (effective_period, member_ids)
    values (effective, ids)
    on conflict (effective_period)
    do update set member_ids = excluded.member_ids;

  delete from public.duty_overrides
    where period > c and not (person_id = any (ids));

  update public.duty_swaps
    set status = 'cancelled', responded_at = now()
    where status = 'pending'
      and (not (requester_id = any (ids)) or not (target_id = any (ids)));
end;
$$;

-- A duty is done when every active area is ticked.
create function private.sync_completion(p integer)
returns void language plpgsql set search_path = '' as $$
declare
  total integer;
  ticked integer;
begin
  select count(*) into total from public.cleaning_areas where active;
  select count(*) into ticked
    from public.duty_checks d
    join public.cleaning_areas a on a.id = d.area_id
    where d.period = p and a.active;

  if total > 0 and ticked >= total then
    insert into public.duty_completions (period, person_id)
      values (p, private.duty_person(p))
      on conflict (period) do nothing;
  else
    delete from public.duty_completions where period = p;
  end if;
end;
$$;

-- API: everyone.

-- Available while pending, so a manager can tell who is asking to join.
create function public.set_my_name(p_name text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  trimmed text := btrim(coalesce(p_name, ''));
begin
  if auth.uid() is null then
    raise exception 'not_signed_in';
  end if;
  if char_length(trimmed) not between 1 and 60 then
    raise exception 'invalid_name';
  end if;
  update public.profiles set name = trimmed where id = auth.uid();
end;
$$;

-- Everything the cleaning screens need, in one consistent read. Phone numbers
-- are deliberately left out.
create function public.cleaning_overview()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  c integer := private.current_period();
  is_manager boolean := exists (
    select 1 from public.profiles where id = me and role = 'manager'
  );
begin
  return jsonb_build_object(
    'today', private.ub_today(),
    'start_date', (select start_date from public.cleaning_settings),
    'versions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'effective_period', effective_period, 'member_ids', member_ids
      ) order by effective_period) from public.rotation_versions
    ), '[]'::jsonb),
    'overrides', coalesce((
      select jsonb_agg(jsonb_build_object(
        'period', period, 'person_id', person_id
      )) from public.duty_overrides where period >= c - 1
    ), '[]'::jsonb),
    'areas', coalesce((
      select jsonb_agg(jsonb_build_object('id', id, 'name', name)
        order by position, created_at)
      from public.cleaning_areas where active
    ), '[]'::jsonb),
    'checked_area_ids', coalesce((
      select jsonb_agg(area_id) from public.duty_checks where period = c
    ), '[]'::jsonb),
    'done_periods', coalesce((
      select jsonb_agg(period) from public.duty_completions where period >= c - 1
    ), '[]'::jsonb),
    'members', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', id, 'name', name, 'active', status = 'active'
      )) from public.profiles where status <> 'pending'
    ), '[]'::jsonb),
    'swaps', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', id,
        'requester_id', requester_id,
        'target_id', target_id,
        'requester_period', requester_period,
        'target_period', target_period
      ))
      from public.duty_swaps
      where status = 'pending'
        and (requester_id = me or target_id = me)
        and requester_period >= c and target_period >= c
    ), '[]'::jsonb),
    'pending_residents', case when is_manager then coalesce((
      select jsonb_agg(jsonb_build_object('id', id, 'name', name)
        order by created_at)
      from public.profiles where status = 'pending'
    ), '[]'::jsonb) else '[]'::jsonb end
  );
end;
$$;

create function public.set_area_checked(p_area_id uuid, p_checked boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  c integer := private.current_period();
begin
  if private.duty_person(c) is distinct from me then
    raise exception 'not_on_duty';
  end if;
  if not exists (
    select 1 from public.cleaning_areas where id = p_area_id and active
  ) then
    raise exception 'unknown_area';
  end if;

  if p_checked then
    insert into public.duty_checks (period, area_id, checked_by)
      values (c, p_area_id, me)
      on conflict do nothing;
  else
    delete from public.duty_checks where period = c and area_id = p_area_id;
  end if;

  perform private.sync_completion(c);
end;
$$;

create function public.request_swap(
  p_my_period integer,
  p_their_period integer
)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  c integer := private.current_period();
  them uuid;
  new_id uuid;
begin
  if p_my_period < c or p_their_period < c or p_my_period = p_their_period then
    raise exception 'invalid_period';
  end if;
  if private.duty_person(p_my_period) is distinct from me then
    raise exception 'not_your_period';
  end if;

  them := private.duty_person(p_their_period);
  if them is null or them = me then
    raise exception 'invalid_target';
  end if;

  if exists (
    select 1 from public.duty_checks
    where period in (p_my_period, p_their_period)
  ) then
    raise exception 'already_started';
  end if;

  if exists (
    select 1 from public.duty_swaps
    where status = 'pending' and (
      requester_period in (p_my_period, p_their_period)
      or target_period in (p_my_period, p_their_period)
    )
  ) then
    raise exception 'swap_already_pending';
  end if;

  insert into public.duty_swaps
      (requester_id, target_id, requester_period, target_period)
    values (me, them, p_my_period, p_their_period)
    returning id into new_id;
  return new_id;
end;
$$;

-- Returns the resulting status. A swap that no longer applies, because the
-- periods passed or the people on them changed, ends up 'cancelled'.
create function public.respond_swap(p_swap_id uuid, p_accept boolean)
returns public.swap_status
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  c integer := private.current_period();
  s public.duty_swaps;
  result public.swap_status;
begin
  select * into s from public.duty_swaps
    where id = p_swap_id and status = 'pending' and target_id = me
    for update;
  if not found then
    raise exception 'swap_not_found';
  end if;

  if not p_accept then
    result := 'declined';
  elsif s.requester_period < c
    or s.target_period < c
    or private.duty_person(s.requester_period) is distinct from s.requester_id
    or private.duty_person(s.target_period) is distinct from s.target_id
    or exists (
      select 1 from public.duty_checks
      where period in (s.requester_period, s.target_period)
    )
  then
    result := 'cancelled';
  else
    insert into public.duty_overrides (period, person_id)
      values (s.requester_period, s.target_id), (s.target_period, s.requester_id)
      on conflict (period) do update set person_id = excluded.person_id;
    result := 'accepted';
  end if;

  update public.duty_swaps
    set status = result, responded_at = now()
    where id = p_swap_id;
  return result;
end;
$$;

create function public.cancel_swap(p_swap_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  update public.duty_swaps
    set status = 'cancelled', responded_at = now()
    where id = p_swap_id and requester_id = me and status = 'pending';
  if not found then
    raise exception 'swap_not_found';
  end if;
end;
$$;

-- API: managers.

create function public.approve_resident(p_user_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  next_order uuid[];
begin
  perform private.require_manager();
  perform private.ensure_started();

  update public.profiles set status = 'active'
    where id = p_user_id and status = 'pending';
  if not found then
    raise exception 'resident_not_found';
  end if;

  next_order := private.sequence_at(private.current_period() + 1);
  perform private.write_next_order(array_append(next_order, p_user_id));
end;
$$;

-- Used both to reject a sign-up and when a resident moves out.
create function public.remove_resident(p_user_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_manager();
begin
  if p_user_id = me then
    raise exception 'cannot_remove_self';
  end if;
  perform private.ensure_started();

  update public.profiles set status = 'left'
    where id = p_user_id and status <> 'left';
  if not found then
    raise exception 'resident_not_found';
  end if;

  perform private.write_next_order(array_remove(
    private.sequence_at(private.current_period() + 1), p_user_id
  ));
end;
$$;

-- p_ids[1] is on duty in the next period.
create function public.set_rotation_order(p_ids uuid[])
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_manager();
  perform private.ensure_started();

  if cardinality(p_ids) <> (
    select count(*) from public.profiles
    where id = any (p_ids) and status = 'active'
  ) then
    raise exception 'invalid_order';
  end if;

  perform private.write_next_order(p_ids);
end;
$$;

create function public.add_cleaning_area(p_name text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  new_id uuid;
begin
  perform private.require_manager();
  insert into public.cleaning_areas (name, position)
    values (
      btrim(p_name),
      (select coalesce(max(position), 0) + 1 from public.cleaning_areas)
    )
    returning id into new_id;
  perform private.sync_completion(private.current_period());
  return new_id;
end;
$$;

create function public.remove_cleaning_area(p_area_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_manager();
  update public.cleaning_areas set active = false where id = p_area_id;
  if not found then
    raise exception 'unknown_area';
  end if;
  perform private.sync_completion(private.current_period());
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'set_my_name(text)',
    'cleaning_overview()',
    'set_area_checked(uuid, boolean)',
    'request_swap(integer, integer)',
    'respond_swap(uuid, boolean)',
    'cancel_swap(uuid)',
    'approve_resident(uuid)',
    'remove_resident(uuid)',
    'set_rotation_order(uuid[])',
    'add_cleaning_area(text)',
    'remove_cleaning_area(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end;
$$;

-- Starting data. The manager can change the areas in the app.

insert into public.cleaning_areas (name, position) values
  ('Гал тогоо', 1),
  ('Угаалгын өрөө, бие засах газар', 2),
  ('Коридор', 3),
  ('Хог гаргах', 4);

insert into public.cleaning_settings (start_date)
  select private.ub_today()
  where exists (select 1 from public.profiles where status = 'active');

insert into public.rotation_versions (effective_period, member_ids)
  select 0, array_agg(id order by created_at)
  from public.profiles where status = 'active'
  having count(*) > 0;
