-- Anonymous problem reports.
--
-- Anonymity has to hold against the manager and anyone who can read this
-- database, so:
--   * no column identifies the author. author_hash is an HMAC whose key exists
--     only in the Edge Function's secrets, and is used only for rate limiting;
--   * votes store an HMAC of voter + report, never the voter;
--   * time is stored rounded to the hour, because an exact minute in a small
--     apartment can reveal who sent a report;
--   * photos live in a table with no timestamp, because Storage records the
--     exact upload time;
--   * clients have no access at all. Everything goes through the "reports"
--     Edge Function, which returns only an explicit list of safe fields.

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  author_hash text not null,
  category text not null
    check (category in ('noise', 'hygiene', 'damage', 'safety', 'other')),
  location text not null check (char_length(btrim(location)) between 1 and 80),
  description text not null
    check (char_length(btrim(description)) between 1 and 500),
  status text not null default 'open'
    check (status in ('open', 'in_progress', 'resolved')),
  reply text check (char_length(reply) <= 500),
  has_photo boolean not null default false,
  created_hour timestamptz not null default date_trunc('hour', now())
    check (created_hour = date_trunc('hour', created_hour))
);

create table public.report_photos (
  report_id uuid primary key references public.reports (id) on delete cascade,
  photo_base64 text not null
);

create table public.report_votes (
  vote_hash text primary key,
  report_id uuid not null references public.reports (id) on delete cascade
);

create index report_votes_report_idx on public.report_votes (report_id);

do $$
declare
  t text;
begin
  foreach t in array array['reports', 'report_photos', 'report_votes'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant all on public.%I to service_role', t);
  end loop;
end;
$$;
