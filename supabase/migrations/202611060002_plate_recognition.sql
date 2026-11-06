-- Shared, atomic per-store limits across Edge Function instances. Photos are never stored.
create table public.plate_recognition_limits (
  store_id uuid primary key references public.stores(id) on delete cascade,
  minute_start timestamptz not null,
  minute_count integer not null default 0,
  day date not null,
  day_count integer not null default 0
);
alter table public.plate_recognition_limits enable row level security;
revoke all on public.plate_recognition_limits from public, anon, authenticated;

create function public.reserve_plate_recognition(p_store uuid) returns text
language plpgsql security definer set search_path = public as $$
declare
  v_now timestamptz := clock_timestamp();
  v_day date := (v_now at time zone 'Asia/Shanghai')::date;
  v_minute timestamptz := date_trunc('minute', v_now);
  v_row public.plate_recognition_limits%rowtype;
begin
  insert into public.plate_recognition_limits(store_id,minute_start,day)
  values(p_store,v_minute,v_day) on conflict(store_id) do nothing;
  select * into strict v_row from public.plate_recognition_limits where store_id=p_store for update;
  if v_row.day=v_day and v_row.day_count >= 500 then return 'day'; end if;
  if v_row.minute_start=v_minute and v_row.minute_count >= 10 then return 'minute'; end if;
  update public.plate_recognition_limits set
    minute_start=v_minute, minute_count=case when minute_start=v_minute then minute_count+1 else 1 end,
    day=v_day, day_count=case when day=v_day then day_count+1 else 1 end
  where store_id=p_store;
  return 'ok';
end;
$$;
revoke all on function public.reserve_plate_recognition(uuid) from public,anon,authenticated;
grant execute on function public.reserve_plate_recognition(uuid) to service_role;
