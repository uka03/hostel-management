-- Per-person settings, and the count shown on the profile screen.

alter table public.profiles
  add column notifications_enabled boolean not null default true,
  add column language text not null default 'mn'
    check (language in ('mn', 'en'));

create function public.set_my_preferences(
  p_notifications_enabled boolean,
  p_language text
)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'not_signed_in';
  end if;
  if p_notifications_enabled is null
    or p_language is null
    or p_language not in ('mn', 'en')
  then
    raise exception 'invalid_preferences';
  end if;
  update public.profiles
    set notifications_enabled = p_notifications_enabled,
        language = p_language
    where id = auth.uid();
end;
$$;

create function public.profile_stats()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := private.require_active();
begin
  return jsonb_build_object(
    'cleaned_count', (
      select count(*) from public.duty_completions where person_id = me
    )
  );
end;
$$;

revoke all on function public.set_my_preferences(boolean, text) from public, anon;
grant execute on function public.set_my_preferences(boolean, text) to authenticated;
revoke all on function public.profile_stats() from public, anon;
grant execute on function public.profile_stats() to authenticated;
