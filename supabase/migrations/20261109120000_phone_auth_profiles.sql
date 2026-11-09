-- Residents and SMS login state. Row-level security is on for every table:
-- the publishable key ships in the app, so RLS is what protects the data.

create type public.user_role as enum ('resident', 'manager');
create type public.resident_status as enum ('pending', 'active', 'left');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text not null unique,
  name text,
  role public.user_role not null default 'resident',
  status public.resident_status not null default 'pending',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant all on public.profiles to service_role;

-- Phone numbers stay private: a resident can read only their own row for now.
create policy "profiles_select_own"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()));

-- Every new phone user gets a pending profile, in the same transaction.
create function public.handle_new_phone_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.phone is not null then
    insert into public.profiles (id, phone) values (new.id, new.phone);
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_phone_user();

-- Used only by the phone-verify Edge Function: no client access at all.
create table public.phone_verifications (
  session_id text primary key,
  phone text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  consumed_at timestamptz
);

create index phone_verifications_phone_created_idx
  on public.phone_verifications (phone, created_at desc);

alter table public.phone_verifications enable row level security;

revoke all on public.phone_verifications from anon, authenticated;
grant all on public.phone_verifications to service_role;
