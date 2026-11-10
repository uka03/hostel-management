-- In-app notifications, shown under the bell on the home screen.
--
-- Rows are written only by the triggers below, never by clients, and a
-- resident reads only their own through my_notifications.
--
-- Reports stay anonymous:
--   * the triggers on reports never know who wrote a report, so a new report
--     goes to every manager, and a status change or reply goes to every
--     resident. Nobody is singled out;
--   * a new-report notification records only the hour, like the report.
--
-- Nothing is written for someone who turned notifications off.

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null
    check (kind in ('paid', 'new_purchase', 'report_new', 'report_update')),
  purchase_id uuid references public.purchases (id) on delete cascade,
  report_id uuid references public.reports (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  read_at timestamptz,
  check (kind <> 'report_new' or created_at = date_trunc('hour', created_at))
);

create index notifications_recipient_idx
  on public.notifications (recipient_id, created_at desc);

alter table public.notifications enable row level security;
revoke all on public.notifications from anon, authenticated;

-- Someone paid the buyer back.
create function private.notify_share_paid()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.notifications (recipient_id, kind, purchase_id, data)
    select p.buyer_id, 'paid', p.id, jsonb_build_object(
        'person_name', payer.name,
        'title', p.title,
        'amount', new.share
      )
    from public.purchases p
    join public.profiles payer on payer.id = new.person_id
    join public.profiles buyer on buyer.id = p.buyer_id
    where p.id = new.purchase_id
      and p.buyer_id <> new.person_id
      and buyer.notifications_enabled;
  return null;
end;
$$;

create trigger purchase_share_paid
  after update of settled_at on public.purchase_shares
  for each row
  when (old.settled_at is null and new.settled_at is not null)
  execute function private.notify_share_paid();

-- Someone bought something this resident shares in.
create function private.notify_new_share()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.notifications (recipient_id, kind, purchase_id, data)
    select new.person_id, 'new_purchase', p.id, jsonb_build_object(
        'person_name', buyer.name,
        'title', p.title,
        'amount', new.share
      )
    from public.purchases p
    join public.profiles buyer on buyer.id = p.buyer_id
    join public.profiles person on person.id = new.person_id
    where p.id = new.purchase_id
      and p.buyer_id <> new.person_id
      and new.share > 0
      and person.notifications_enabled;
  return null;
end;
$$;

create trigger purchase_share_added
  after insert on public.purchase_shares
  for each row execute function private.notify_new_share();

-- A new report: every manager, at the report's own rounded hour.
create function private.notify_report_new()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.notifications
      (recipient_id, kind, report_id, data, created_at)
    select m.id, 'report_new', new.id, jsonb_build_object(
        'category', new.category,
        'location', new.location
      ), new.created_hour
    from public.profiles m
    where m.role = 'manager' and m.status = 'active'
      and m.notifications_enabled;
  return null;
end;
$$;

create trigger report_created
  after insert on public.reports
  for each row execute function private.notify_report_new();

-- A manager changed a report's status or replied: every resident.
create function private.notify_report_update()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  replied boolean := new.reply is not null
    and new.reply is distinct from old.reply;
begin
  if not replied and new.status = old.status then
    return null;
  end if;
  insert into public.notifications (recipient_id, kind, report_id, data)
    select r.id, 'report_update', new.id, jsonb_build_object(
        'location', new.location,
        'status', new.status,
        'replied', replied
      )
    from public.profiles r
    where r.role = 'resident' and r.status = 'active'
      and r.notifications_enabled;
  return null;
end;
$$;

create trigger report_updated
  after update of status, reply on public.reports
  for each row execute function private.notify_report_update();

create function public.my_notifications()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  return jsonb_build_object(
    'unread_count', (
      select count(*) from public.notifications
      where recipient_id = me and read_at is null
    ),
    'items', coalesce((
      select jsonb_agg(item order by created_at desc)
      from (
        select n.created_at, jsonb_build_object(
            'id', n.id,
            'kind', n.kind,
            'data', n.data,
            'created_at', n.created_at,
            'read', n.read_at is not null
          ) as item
        from public.notifications n
        where n.recipient_id = me
        order by n.created_at desc
        limit 50
      ) recent
    ), '[]'::jsonb)
  );
end;
$$;

create function public.mark_notifications_read()
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  update public.notifications set read_at = now()
    where recipient_id = me and read_at is null;
end;
$$;

revoke all on function public.my_notifications() from public, anon;
grant execute on function public.my_notifications() to authenticated;
revoke all on function public.mark_notifications_read() from public, anon;
grant execute on function public.mark_notifications_read() to authenticated;
