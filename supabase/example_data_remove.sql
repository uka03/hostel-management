-- Removes everything added by supabase/example_data.sql and nothing else.
-- Real purchases that example residents shared in are re-split between the
-- real people on them, so their shares still add up to the amount.

do $$
declare
  p record;
  n integer;
begin
  delete from public.reports where id::text like 'e0000000-%';
  delete from public.purchases where id::text like 'e0000000-%';
  delete from public.needed_items where id::text like 'e0000000-%';

  update public.needed_items set claimed_by = null
    where claimed_by::text like 'e0000000-%';

  for p in
    select distinct pu.id, pu.amount, pu.buyer_id
    from public.purchases pu
    join public.purchase_shares s on s.purchase_id = pu.id
    where s.person_id::text like 'e0000000-%'
  loop
    delete from public.purchase_shares
      where purchase_id = p.id and person_id::text like 'e0000000-%';
    select count(*) into n from public.purchase_shares where purchase_id = p.id;
    update public.purchase_shares
      set share = p.amount / n
        + case when person_id = p.buyer_id then p.amount % n else 0 end
      where purchase_id = p.id;
  end loop;

  update public.rotation_versions set member_ids = array(
    select m from unnest(member_ids) with ordinality as t(m, o)
    where m::text not like 'e0000000-%'
    order by o
  )
  where exists (
    select 1 from unnest(member_ids) as m where m::text like 'e0000000-%'
  );

  -- Cleaning records and profiles go with the users, by cascade.
  delete from auth.users where id::text like 'e0000000-%';
end;
$$;
