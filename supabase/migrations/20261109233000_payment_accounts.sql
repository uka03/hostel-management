-- Bank details, so a resident can pay a buyer back.
--
-- A resident reads their own through their profile row. Anyone else's is
-- available only through purchase_payment_info, and only to someone who has
-- a share to pay in that purchase.

alter table public.profiles
  add column bank_name text check (char_length(btrim(bank_name)) between 1 and 60),
  add column bank_account_number text
    check (bank_account_number ~ '^[0-9]{4,20}$'),
  add column bank_account_holder text
    check (char_length(btrim(bank_account_holder)) between 1 and 60);

create function public.set_my_payment_account(
  p_bank text,
  p_number text,
  p_holder text
)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'not_signed_in';
  end if;
  if char_length(btrim(coalesce(p_bank, ''))) not between 1 and 60
    or coalesce(p_number, '') !~ '^[0-9]{4,20}$'
    or char_length(btrim(coalesce(p_holder, ''))) not between 1 and 60
  then
    raise exception 'invalid_account';
  end if;

  update public.profiles
    set bank_name = btrim(p_bank),
        bank_account_number = p_number,
        bank_account_holder = btrim(p_holder)
    where id = auth.uid();
end;
$$;

create function public.purchase_payment_info(p_purchase_id uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
  info jsonb;
begin
  select jsonb_build_object(
      'buyer_name', buyer.name,
      'bank_name', buyer.bank_name,
      'account_number', buyer.bank_account_number,
      'account_holder', buyer.bank_account_holder
    )
    into info
    from public.purchases p
    join public.purchase_shares s on s.purchase_id = p.id and s.person_id = me
    join public.profiles buyer on buyer.id = p.buyer_id
    where p.id = p_purchase_id and p.buyer_id <> me;
  if info is null then
    raise exception 'share_not_found';
  end if;
  return info;
end;
$$;

revoke all on function public.set_my_payment_account(text, text, text)
  from public, anon;
grant execute on function public.set_my_payment_account(text, text, text)
  to authenticated;
revoke all on function public.purchase_payment_info(uuid) from public, anon;
grant execute on function public.purchase_payment_info(uuid) to authenticated;
