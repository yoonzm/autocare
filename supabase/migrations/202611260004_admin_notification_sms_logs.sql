-- 运营后台通知中心短信接入 sms_logs：
-- 1. reserve_notice_sms 对 admin_notice 跳过 60s 同用途冷却，避免运营连续发通知被误拦；仍写 sms_logs 并计入日配额。
-- 2. admin_notification_create 的 sms_targets 附带 store_name，便于在短信记录中识别接收门店或平台通知。

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
  if trim(p_purpose) <> 'admin_notice' then
    select max(created_at) into latest
    from public.sms_logs
    where phone = p_phone and purpose = p_purpose and kind = 'notice';
    if latest > now() - interval '60 seconds' then
      return jsonb_build_object(
        'error', 'cooldown',
        'retry_after', greatest(1, ceil(extract(epoch from latest + interval '60 seconds' - now()))::int)
      );
    end if;
  end if;
  if coalesce((select count from public.phone_sms_quota where phone = notice_phone_key and day = d), 0) >= 20 then
    return jsonb_build_object('error', 'phone_quota');
  end if;
  if coalesce((select count from public.phone_sms_quota where phone = '__autocare_notice_global__' and day = d), 0) >= 5000 then
    return jsonb_build_object('error', 'global_quota');
  end if;
  perform public.take_sms_quota(notice_phone_key, d, 20);
  perform public.take_sms_quota('__autocare_notice_global__', d, 5000);
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

create or replace function public.admin_notification_create(
  p_actor_id uuid,
  p_actor_name text,
  p_title text,
  p_body text,
  p_audience_type text,
  p_store_id uuid default null,
  p_role text default null,
  p_targets jsonb default '[]'::jsonb,
  p_channels text[] default array['inbox']::text[],
  p_popup_expires_at timestamptz default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_title text := trim(coalesce(p_title, ''));
  v_body text := trim(coalesce(p_body, ''));
  v_id uuid;
  v_rec_count integer := 0;
  v_inbox_count integer := 0;
  v_push_count integer := 0;
  v_popup_count integer := 0;
  v_sms_targets jsonb := '[]'::jsonb;
  v_has_inbox boolean := 'inbox' = any(p_channels);
  v_has_push boolean := 'push' = any(p_channels);
  v_has_sms boolean := 'sms' = any(p_channels);
  v_has_popup boolean := 'popup' = any(p_channels);
  r record;
  v_msg_id uuid;
begin
  if length(v_title) < 1 or length(v_title) > 60 then
    raise exception 'notification_invalid';
  end if;
  if length(v_body) < 1 or length(v_body) > 500 then
    raise exception 'notification_invalid';
  end if;
  if p_audience_type not in ('users', 'store', 'role', 'all') then
    raise exception 'notification_invalid';
  end if;
  if coalesce(cardinality(p_channels), 0) = 0 then
    raise exception 'notification_invalid';
  end if;

  insert into public.admin_notifications(
    actor_id, actor_name, title, body,
    audience_type, audience_store_id, audience_role, audience_targets,
    channels, popup_expires_at
  )
  values (
    p_actor_id, coalesce(p_actor_name, ''), v_title, v_body,
    p_audience_type, p_store_id, p_role, coalesce(p_targets, '[]'::jsonb),
    p_channels, case when v_has_popup then p_popup_expires_at else null end
  )
  returning id into v_id;

  for r in
    select * from public.admin_notification_resolve_recipients(
      p_audience_type, p_store_id, p_role, p_targets
    )
  loop
    v_rec_count := v_rec_count + 1;
    v_msg_id := null;

    if v_has_inbox then
      insert into public.staff_messages(
        store_id, staff_id, owner_id, kind, title, body, link, push_enabled
      )
      values (
        r.store_id, r.staff_id, r.owner_id, 'system',
        v_title, left(v_body, 300), '', false
      )
      returning id into v_msg_id;
      v_inbox_count := v_inbox_count + 1;
    end if;

    if v_has_push then
      if exists (
        select 1 from public.push_devices d
        where d.store_id = r.store_id
          and d.disabled_at is null
          and ((r.staff_id is not null and d.staff_id = r.staff_id)
            or (r.owner_id is not null and d.owner_id = r.owner_id))
      ) then
        insert into public.push_outbox(
          message_id, store_id, staff_id, owner_id, title, body
        )
        values (
          v_msg_id, r.store_id, r.staff_id, r.owner_id, v_title, left(v_body, 300)
        );
        v_push_count := v_push_count + 1;
      end if;
    end if;

    if v_has_popup then
      insert into public.app_popups(
        notification_id, store_id, staff_id, owner_id, title, body, expires_at
      )
      values (
        v_id, r.store_id, r.staff_id, r.owner_id, v_title, v_body, p_popup_expires_at
      );
      v_popup_count := v_popup_count + 1;
    end if;
  end loop;

  if v_has_sms then
    select coalesce(
      jsonb_agg(jsonb_build_object('phone', p.clean_phone, 'store_name', p.store_name)),
      '[]'::jsonb
    )
    into v_sms_targets
    from (
      select
        regexp_replace(phone, '^\+86', '') as clean_phone,
        case
          when count(distinct store_id) = 1 then coalesce(nullif(min(store_name), ''), '平台通知')
          else '平台通知'
        end as store_name
      from public.admin_notification_resolve_recipients(
        p_audience_type, p_store_id, p_role, p_targets
      )
      where regexp_replace(phone, '^\+86', '') ~ '^1[3-9][0-9]{9}$'
      group by regexp_replace(phone, '^\+86', '')
    ) p;
  end if;

  update public.admin_notifications
  set recipient_count = v_rec_count,
      inbox_count = v_inbox_count,
      push_count = v_push_count,
      popup_count = v_popup_count
  where id = v_id;

  return jsonb_build_object(
    'id', v_id,
    'recipient_count', v_rec_count,
    'inbox_count', v_inbox_count,
    'push_count', v_push_count,
    'popup_count', v_popup_count,
    'sms_targets', v_sms_targets
  );
end $$;
