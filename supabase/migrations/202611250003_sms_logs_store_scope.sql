-- 为门店级「通知与消息」记录归属：sms_logs 增加 store_id（仅记录业务通知归属门店，不影响历史数据与验证码）。
alter table public.sms_logs
  add column if not exists store_id uuid references public.stores(id) on delete set null;

create index if not exists sms_logs_store_notice_idx
  on public.sms_logs (store_id, created_at desc, id desc)
  where kind = 'notice';

drop function if exists public.reserve_notice_sms(text, text, uuid, text, text, text);
create or replace function public.reserve_notice_sms(
  p_phone text,
  p_purpose text,
  p_request uuid,
  p_content text,
  p_sign text default '',
  p_store_name text default '',
  p_store_id uuid default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  d date := (now() at time zone 'Asia/Shanghai')::date;
  latest timestamptz;
  notice_phone_key text := 'notice:' || p_phone;
begin
  if p_phone !~ '^\+861[3-9][0-9]{9}$'
    or length(trim(coalesce(p_purpose, ''))) not between 1 and 50
    or length(trim(coalesce(p_content, ''))) not between 1 and 500
    or p_request is null then
    raise exception 'invalid_notice_sms_reservation';
  end if;
  if exists (select 1 from public.sms_logs where request_id = p_request) then
    return jsonb_build_object('error', 'duplicate_request');
  end if;
  perform pg_advisory_xact_lock(79433702);
  select max(created_at) into latest
  from public.sms_logs
  where phone = p_phone and purpose = p_purpose and kind = 'notice';
  if latest > now() - interval '60 seconds' then
    return jsonb_build_object(
      'error', 'cooldown',
      'retry_after', greatest(1, ceil(extract(epoch from latest + interval '60 seconds' - now()))::int)
    );
  end if;
  if coalesce((select count from public.phone_sms_quota where phone = notice_phone_key and day = d), 0) >= 20 then
    return jsonb_build_object('error', 'phone_quota');
  end if;
  if coalesce((select count from public.phone_sms_quota where phone = '__autocare_notice_global__' and day = d), 0) >= 500 then
    return jsonb_build_object('error', 'global_quota');
  end if;
  perform public.take_sms_quota(notice_phone_key, d, 20);
  perform public.take_sms_quota('__autocare_notice_global__', d, 500);
  insert into public.sms_logs(request_id, phone, purpose, kind, content, sign_name, store_name, store_id, status)
  values (
    p_request,
    p_phone,
    trim(p_purpose),
    'notice',
    trim(p_content),
    coalesce(p_sign, ''),
    coalesce(p_store_name, ''),
    p_store_id,
    'pending'
  )
  on conflict (request_id) do nothing;
  return '{}'::jsonb;
end $$;

revoke all on function public.reserve_notice_sms(text, text, uuid, text, text, text, uuid) from public, anon, authenticated;
grant execute on function public.reserve_notice_sms(text, text, uuid, text, text, text, uuid) to service_role;
