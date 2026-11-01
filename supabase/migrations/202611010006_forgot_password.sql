-- Daily SMS quota per phone, and a way to sign a user out everywhere.

create table if not exists public.phone_sms_quota (
  phone text not null,
  day date not null,
  count int not null default 0,
  primary key (phone, day)
);
alter table public.phone_sms_quota enable row level security;
revoke all on public.phone_sms_quota from public, anon, authenticated;
grant select, insert, update, delete on public.phone_sms_quota to service_role;

-- Atomically takes one send from today's quota; false when the limit is reached.
create or replace function public.take_sms_quota(p_phone text, p_day date, p_limit int)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  c int;
begin
  insert into public.phone_sms_quota (phone, day, count)
  values (p_phone, p_day, 1)
  on conflict (phone, day) do update
    set count = public.phone_sms_quota.count + 1
    where public.phone_sms_quota.count < p_limit
  returning count into c;
  return c is not null;
end;
$$;
revoke all on function public.take_sms_quota(text, date, int) from public, anon, authenticated;
grant execute on function public.take_sms_quota(text, date, int) to service_role;

-- Deletes every session (and, by cascade, refresh token) of a user. Access tokens
-- of those sessions stop working because GoTrue checks the session on each call.
create or replace function public.revoke_user_sessions(p_user uuid)
returns void
language sql
security definer
set search_path = auth, public
as $$
  delete from auth.sessions where user_id = p_user;
$$;
revoke all on function public.revoke_user_sessions(uuid) from public, anon, authenticated;
grant execute on function public.revoke_user_sessions(uuid) to service_role;
