-- 短信下行送达回执（助通 /v2/batchReport 定时拉取）：记录通道消息 ID、送达状态与送达时间。
alter table public.sms_logs
  add column provider_msg_id text not null default '',
  add column delivery_status text not null default 'unknown'
    check (delivery_status in ('unknown', 'delivered', 'failed')),
  add column delivery_code text not null default '',
  add column delivered_at timestamptz;

create index sms_logs_provider_msg_idx on public.sms_logs (provider_msg_id)
  where provider_msg_id <> '';
create index sms_logs_delivery_failed_idx on public.sms_logs (created_at desc)
  where delivery_status = 'failed';

drop function public.finish_phone_otp(text, text, uuid, boolean, text, text);
create function public.finish_phone_otp(
  p_phone text,
  p_purpose text,
  p_request uuid,
  p_sent boolean,
  p_provider text,
  p_error text default null,
  p_provider_msg_id text default null
) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  update public.phone_otps
  set delivery_state = case when p_sent then 'sent' else 'failed' end,
      provider = p_provider
  where phone = p_phone and purpose = p_purpose and request_id = p_request and delivery_state = 'pending';
  if not found then return false; end if;
  update public.sms_logs
  set status = case when p_sent then 'sent' else 'failed' end,
      provider = p_provider,
      provider_msg_id = case when p_sent then coalesce(nullif(trim(p_provider_msg_id), ''), '') else '' end,
      sent_at = case when p_sent then now() else null end,
      error = coalesce(left(p_error, 300), '')
  where request_id = p_request;
  return true;
end $$;

drop function public.finish_notice_sms(uuid, boolean, text, text);
create function public.finish_notice_sms(
  p_request uuid,
  p_sent boolean,
  p_provider text,
  p_error text default null,
  p_provider_msg_id text default null
) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  update public.sms_logs
  set status = case when p_sent then 'sent' else 'failed' end,
      provider = p_provider,
      provider_msg_id = case when p_sent then coalesce(nullif(trim(p_provider_msg_id), ''), '') else '' end,
      sent_at = case when p_sent then now() else null end,
      error = coalesce(left(p_error, 300), '')
  where request_id = p_request and kind = 'notice' and status = 'pending';
  return found;
end $$;

create or replace function public.apply_sms_delivery_reports(
  p_provider text,
  p_records jsonb
) returns integer
language plpgsql security definer set search_path = public as $$
declare
  rec jsonb;
  v_msg_id text;
  v_extend text;
  v_mobile text;
  v_code text;
  v_msg text;
  v_raw_time text;
  v_report_time timestamptz;
  v_delivery_status text;
  v_err text;
  v_target_id uuid;
  v_updated integer := 0;
begin
  if p_records is null or jsonb_typeof(p_records) <> 'array' then
    return 0;
  end if;
  for rec in select * from jsonb_array_elements(p_records)
  loop
    v_msg_id := coalesce(nullif(trim(rec->>'msg_id'), ''), nullif(trim(rec->>'msgId'), ''), '');
    v_extend := trim(coalesce(rec->>'extend', ''));
    v_mobile := right(regexp_replace(coalesce(rec->>'mobile', ''), '\D', '', 'g'), 11);
    v_code := trim(coalesce(rec->>'code', ''));
    v_msg := trim(coalesce(rec->>'msg', ''));
    v_raw_time := trim(coalesce(rec->>'report_time', rec->>'reportTime', ''));
    if v_raw_time ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}$' then
      v_report_time := replace(v_raw_time, 'T', ' ')::timestamp at time zone 'Asia/Shanghai';
    else
      v_report_time := now();
    end if;
    if v_code = 'DELIVRD' then
      v_delivery_status := 'delivered';
      v_err := '';
    else
      v_delivery_status := 'failed';
      v_err := left(coalesce(nullif(v_msg, ''), nullif(v_code, ''), '运营商未送达'), 300);
    end if;

    select id into v_target_id
    from public.sms_logs
    where status = 'sent'
      and (
        (v_extend ~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
          and request_id = v_extend::uuid)
        or (
          v_msg_id <> ''
          and provider = p_provider
          and provider_msg_id = v_msg_id
          and (v_mobile = '' or right(regexp_replace(phone, '\D', '', 'g'), 11) = v_mobile)
        )
      )
    order by created_at desc
    limit 1
    for update;

    if found then
      update public.sms_logs
      set delivery_status = case
            when delivery_status = 'failed' then 'failed'
            else v_delivery_status
          end,
          delivery_code = case
            when delivery_status = 'failed' then delivery_code
            else v_code
          end,
          delivered_at = case
            when delivery_status = 'failed' or v_delivery_status = 'failed' then null
            else greatest(coalesce(delivered_at, v_report_time), v_report_time)
          end,
          error = case
            when delivery_status = 'failed' then error
            when v_delivery_status = 'failed' then v_err
            else error
          end
      where id = v_target_id;
      v_updated := v_updated + 1;
    end if;
  end loop;
  return v_updated;
end $$;

create or replace function public.admin_sms_list(
  p_actor uuid,
  p_session uuid,
  p_kind text default 'all',
  p_phone text default '',
  p_before_at timestamptz default null,
  p_before_id uuid default null,
  p_limit integer default 30
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  digits text := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g');
  lim integer := least(greatest(coalesce(p_limit, 30), 1), 50);
  rows jsonb;
  n integer;
  failed integer;
begin
  perform public.admin_sms_guard(p_actor, p_session);
  if p_kind not in ('all', 'code', 'notice', 'failed') then raise exception '短信类型无效'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id desc), '[]'::jsonb), count(*)
  into rows, n
  from (
    select id, phone, purpose, kind, code, content, provider, sign_name, status, error, attempts, store_name,
      delivery_status, delivery_code, delivered_at,
      created_at, sent_at, expires_at, consumed_at
    from public.sms_logs
    where (
      p_kind = 'all'
      or (p_kind = 'failed' and (status = 'failed' or delivery_status = 'failed'))
      or (p_kind in ('code', 'notice') and kind = p_kind)
    )
      and (digits = '' or regexp_replace(phone, '\D', '', 'g') like '%' || digits || '%')
      and (p_before_at is null or (created_at, id) < (p_before_at, coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid)))
    order by created_at desc, id desc limit lim + 1
  ) x;
  select count(*) into failed from public.sms_logs where status = 'failed' or delivery_status = 'failed';
  return jsonb_build_object(
    'items', case when n > lim then rows - lim else rows end,
    'more', n > lim,
    'failed_count', failed,
    'now', now()
  );
end $$;

revoke all on function public.finish_phone_otp(text, text, uuid, boolean, text, text, text) from public, anon, authenticated;
revoke all on function public.finish_notice_sms(uuid, boolean, text, text, text) from public, anon, authenticated;
revoke all on function public.apply_sms_delivery_reports(text, jsonb) from public, anon, authenticated;
grant execute on function public.finish_phone_otp(text, text, uuid, boolean, text, text, text) to service_role;
grant execute on function public.finish_notice_sms(uuid, boolean, text, text, text) to service_role;
grant execute on function public.apply_sms_delivery_reports(text, jsonb) to service_role;
