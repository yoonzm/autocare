-- 通知类自定义短信预留与回执（写入 sms_logs kind='notice'，与 OTP 额度隔离）。
create or replace function public.reserve_notice_sms(
  p_phone text,
  p_purpose text,
  p_request uuid,
  p_content text,
  p_sign text default '',
  p_store_name text default ''
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
  insert into public.sms_logs(request_id, phone, purpose, kind, content, sign_name, store_name, status)
  values (p_request, p_phone, trim(p_purpose), 'notice', trim(p_content), coalesce(p_sign, ''), coalesce(p_store_name, ''), 'pending')
  on conflict (request_id) do nothing;
  return '{}'::jsonb;
end $$;

create or replace function public.finish_notice_sms(
  p_request uuid,
  p_sent boolean,
  p_provider text,
  p_error text default null
) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  update public.sms_logs
  set status = case when p_sent then 'sent' else 'failed' end,
      provider = p_provider,
      sent_at = case when p_sent then now() else null end,
      error = coalesce(left(p_error, 300), '')
  where request_id = p_request and kind = 'notice' and status = 'pending';
  return found;
end $$;

revoke all on function public.reserve_notice_sms(text, text, uuid, text, text, text) from public, anon, authenticated;
revoke all on function public.finish_notice_sms(uuid, boolean, text, text) from public, anon, authenticated;
grant execute on function public.reserve_notice_sms(text, text, uuid, text, text, text) to service_role;
grant execute on function public.finish_notice_sms(uuid, boolean, text, text) to service_role;
