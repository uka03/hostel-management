-- Lets a resident mark that they have paid the buyer their share.
--
-- A payment moves money between two people, so it is reflected in what each
-- has paid: the payer's goes up and the buyer's goes down. Balance is still
-- simply paid minus shares.

alter table public.purchase_shares add column settled_at timestamptz;

create function public.set_share_paid(p_purchase_id uuid, p_paid boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  update public.purchase_shares s
    set settled_at = case when p_paid then now() else null end
    from public.purchases p
    where p.id = s.purchase_id
      and s.purchase_id = p_purchase_id
      and s.person_id = me
      and p.buyer_id <> me;
  if not found then
    raise exception 'share_not_found';
  end if;
end;
$$;

revoke all on function public.set_share_paid(uuid, boolean) from public, anon;
grant execute on function public.set_share_paid(uuid, boolean) to authenticated;

create or replace function public.purchases_overview()
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
    ) + (
      -- Shares this resident has paid to other buyers.
      select coalesce(sum(s.share), 0)
      from public.purchase_shares s
      join public.purchases p on p.id = s.purchase_id
      where s.person_id = me and p.buyer_id <> me and s.settled_at is not null
    ) - (
      -- Shares others have paid back to this resident.
      select coalesce(sum(s.share), 0)
      from public.purchase_shares s
      join public.purchases p on p.id = s.purchase_id
      where p.buyer_id = me and s.person_id <> me and s.settled_at is not null
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
            'my_paid', exists (
              select 1 from public.purchase_shares s
              where s.purchase_id = p.id and s.person_id = me
                and s.settled_at is not null
            ),
            'people_count', (
              select count(*) from public.purchase_shares s
              where s.purchase_id = p.id
            ),
            'paid_count', (
              select count(*) from public.purchase_shares s
              where s.purchase_id = p.id and s.settled_at is not null
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
