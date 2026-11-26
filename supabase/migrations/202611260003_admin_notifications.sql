-- 运营后台统一通知中心：受众圈选（单人 / 门店 / 角色 / 全员）× 4 渠道（站内信 / App推送 / 短信 / 应用内弹窗）

-- 1. 解耦站内信与推送队列：允许「仅站内信不推 App」和「仅推 App 不落站内信」。
alter table public.staff_messages
  add column if not exists push_enabled boolean not null default true;

alter table public.push_outbox
  alter column message_id drop not null;

create or replace function public.push_enqueue_staff_message() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not coalesce(new.push_enabled, true) then
    return new;
  end if;
  if exists (
    select 1 from public.push_devices d
    where d.store_id = new.store_id
      and d.disabled_at is null
      and ((new.staff_id is not null and d.staff_id = new.staff_id)
        or (new.owner_id is not null and d.owner_id = new.owner_id))
  ) then
    insert into public.push_outbox(message_id, store_id, staff_id, owner_id, title, body)
    values (new.id, new.store_id, new.staff_id, new.owner_id, new.title, new.body);
  end if;
  return new;
end $$;

-- 2. 运营通知批次记录表
create table public.admin_notifications (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null,
  actor_name text not null default '',
  title text not null check (length(trim(title)) between 1 and 60),
  body text not null check (length(trim(body)) between 1 and 500),
  audience_type text not null check (audience_type in ('users', 'store', 'role', 'all')),
  audience_store_id uuid references public.stores(id) on delete set null,
  audience_role text check (audience_role is null or audience_role in ('owner', 'manager', 'cashier', 'technician')),
  audience_targets jsonb not null default '[]'::jsonb,
  channels text[] not null check (cardinality(channels) > 0),
  popup_expires_at timestamptz,
  popup_revoked_at timestamptz,
  recipient_count integer not null default 0,
  inbox_count integer not null default 0,
  push_count integer not null default 0,
  sms_sent integer not null default 0,
  sms_failed integer not null default 0,
  popup_count integer not null default 0,
  created_at timestamptz not null default now()
);

create index admin_notifications_created_idx
  on public.admin_notifications(created_at desc, id desc);

alter table public.admin_notifications enable row level security;
revoke all on public.admin_notifications from public, anon, authenticated;
grant all on public.admin_notifications to service_role;

-- 3. 商户端应用内弹窗表（每个命中收件人一条，支持有效期与后台一键撤回）
create table public.app_popups (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null references public.admin_notifications(id) on delete cascade,
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid references public.store_staff(id) on delete cascade,
  owner_id uuid references auth.users(id) on delete cascade,
  title text not null check (length(trim(title)) between 1 and 60),
  body text not null check (length(trim(body)) between 1 and 500),
  expires_at timestamptz,
  revoked_at timestamptz,
  dismissed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint app_popups_recipient_check check ((staff_id is null) <> (owner_id is null))
);

create index app_popups_active_idx
  on public.app_popups(store_id, staff_id, owner_id, created_at desc)
  where dismissed_at is null and revoked_at is null;

create index app_popups_notification_idx
  on public.app_popups(notification_id);

alter table public.app_popups enable row level security;
revoke all on public.app_popups from public, anon, authenticated;
grant all on public.app_popups to service_role;

-- 4. 受众解析辅助函数：统一输出 (store_id, staff_id, owner_id, role, name, phone, store_name)
create function public.admin_notification_resolve_recipients(
  p_audience_type text,
  p_store_id uuid default null,
  p_role text default null,
  p_targets jsonb default '[]'::jsonb
) returns table (
  store_id uuid,
  staff_id uuid,
  owner_id uuid,
  role text,
  name text,
  phone text,
  store_name text
)
language plpgsql stable security definer set search_path = public as $$
begin
  if p_audience_type = 'users' then
    return query
    with wanted as (
      select
        nullif(elem->>'store_id', '')::uuid as w_store,
        nullif(elem->>'staff_id', '')::uuid as w_staff,
        nullif(elem->>'owner_id', '')::uuid as w_owner
      from jsonb_array_elements(coalesce(p_targets, '[]'::jsonb)) elem
    )
    select distinct on (r.store_id, r.staff_id, r.owner_id)
      r.store_id, r.staff_id, r.owner_id, r.role, r.name, r.phone, r.store_name
    from (
      select
        s.id as store_id,
        null::uuid as staff_id,
        s.owner_id as owner_id,
        'owner'::text as role,
        coalesce(nullif(s.name, ''), '门店老板') as name,
        coalesce(nullif(s.phone, ''), nullif(u.phone, ''), '') as phone,
        s.name as store_name
      from wanted w
      join public.stores s on s.id = w.w_store and s.owner_id = w.w_owner
      left join auth.users u on u.id = s.owner_id
      where w.w_owner is not null and w.w_staff is null
      union all
      select
        st.store_id,
        st.id as staff_id,
        null::uuid as owner_id,
        st.role,
        st.name,
        st.phone,
        s.name as store_name
      from wanted w
      join public.store_staff st on st.id = w.w_staff and st.store_id = w.w_store and st.status = 'active'
      join public.stores s on s.id = st.store_id
      where w.w_staff is not null and w.w_owner is null
    ) r;
  elsif p_audience_type = 'store' then
    return query
    select
      s.id as store_id,
      null::uuid as staff_id,
      s.owner_id as owner_id,
      'owner'::text as role,
      coalesce(nullif(s.name, ''), '门店老板') as name,
      coalesce(nullif(s.phone, ''), nullif(u.phone, ''), '') as phone,
      s.name as store_name
    from public.stores s
    left join auth.users u on u.id = s.owner_id
    where s.id = p_store_id
      and (p_role is null or p_role = 'owner')
    union all
    select
      st.store_id,
      st.id as staff_id,
      null::uuid as owner_id,
      st.role,
      st.name,
      st.phone,
      s.name as store_name
    from public.store_staff st
    join public.stores s on s.id = st.store_id
    where st.store_id = p_store_id
      and st.status = 'active'
      and (p_role is null or st.role = p_role);
  elsif p_audience_type = 'role' then
    if p_role = 'owner' then
      return query
      select
        s.id as store_id,
        null::uuid as staff_id,
        s.owner_id as owner_id,
        'owner'::text as role,
        coalesce(nullif(s.name, ''), '门店老板') as name,
        coalesce(nullif(s.phone, ''), nullif(u.phone, ''), '') as phone,
        s.name as store_name
      from public.stores s
      left join auth.users u on u.id = s.owner_id;
    elsif p_role in ('manager', 'cashier', 'technician') then
      return query
      select
        st.store_id,
        st.id as staff_id,
        null::uuid as owner_id,
        st.role,
        st.name,
        st.phone,
        s.name as store_name
      from public.store_staff st
      join public.stores s on s.id = st.store_id
      where st.status = 'active' and st.role = p_role;
    end if;
  elsif p_audience_type = 'all' then
    return query
    select
      s.id as store_id,
      null::uuid as staff_id,
      s.owner_id as owner_id,
      'owner'::text as role,
      coalesce(nullif(s.name, ''), '门店老板') as name,
      coalesce(nullif(s.phone, ''), nullif(u.phone, ''), '') as phone,
      s.name as store_name
    from public.stores s
    left join auth.users u on u.id = s.owner_id
    union all
    select
      st.store_id,
      st.id as staff_id,
      null::uuid as owner_id,
      st.role,
      st.name,
      st.phone,
      s.name as store_name
    from public.store_staff st
    join public.stores s on s.id = st.store_id
    where st.status = 'active';
  end if;
end $$;

-- 5. 搜索可选收件人（老板与在职员工）
create function public.admin_notification_recipients_search(
  p_q text default '',
  p_limit integer default 30
) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_q text := trim(coalesce(p_q, ''));
  v_lim integer := greatest(1, least(coalesce(p_limit, 30), 50));
begin
  return coalesce((
    select jsonb_agg(to_jsonb(r))
    from (
      select * from (
        select
          s.id as store_id,
          null::uuid as staff_id,
          s.owner_id as owner_id,
          'owner'::text as role,
          coalesce(nullif(s.name, ''), '门店老板') as name,
          coalesce(nullif(s.phone, ''), nullif(u.phone, ''), '') as phone,
          s.name as store_name
        from public.stores s
        left join auth.users u on u.id = s.owner_id
        union all
        select
          st.store_id,
          st.id as staff_id,
          null::uuid as owner_id,
          st.role,
          st.name,
          st.phone,
          s.name as store_name
        from public.store_staff st
        join public.stores s on s.id = st.store_id
        where st.status = 'active'
      ) all_r
      where v_q = ''
        or all_r.name ilike '%' || v_q || '%'
        or all_r.phone ilike '%' || v_q || '%'
        or all_r.store_name ilike '%' || v_q || '%'
      order by all_r.store_name asc, (all_r.role = 'owner') desc, all_r.name asc
      limit v_lim
    ) r
  ), '[]'::jsonb);
end $$;

-- 6. 发送前预估命中人数
create function public.admin_notification_preview(
  p_audience_type text,
  p_store_id uuid default null,
  p_role text default null,
  p_targets jsonb default '[]'::jsonb
) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_rec integer := 0;
  v_phones integer := 0;
  v_devices integer := 0;
begin
  with rec as (
    select * from public.admin_notification_resolve_recipients(
      p_audience_type, p_store_id, p_role, p_targets
    )
  )
  select
    count(*)::integer,
    count(distinct nullif(regexp_replace(phone, '^\+86', ''), '')) filter (
      where regexp_replace(phone, '^\+86', '') ~ '^1[3-9][0-9]{9}$'
    )::integer,
    (
      select count(*)::integer from rec r
      where exists (
        select 1 from public.push_devices d
        where d.store_id = r.store_id
          and d.disabled_at is null
          and ((r.staff_id is not null and d.staff_id = r.staff_id)
            or (r.owner_id is not null and d.owner_id = r.owner_id))
      )
    )
  into v_rec, v_phones, v_devices
  from rec;

  return jsonb_build_object(
    'recipient_count', coalesce(v_rec, 0),
    'phone_count', coalesce(v_phones, 0),
    'push_device_count', coalesce(v_devices, 0)
  );
end $$;

-- 7. 创建通知批次并执行数据库内渠道（站内信 / 推送入队 / 应用内弹窗），返回短信目标列表交由云函数发送
create function public.admin_notification_create(
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
    select coalesce(jsonb_agg(jsonb_build_object('phone', p.clean_phone)), '[]'::jsonb)
    into v_sms_targets
    from (
      select distinct regexp_replace(phone, '^\+86', '') as clean_phone
      from public.admin_notification_resolve_recipients(
        p_audience_type, p_store_id, p_role, p_targets
      )
      where regexp_replace(phone, '^\+86', '') ~ '^1[3-9][0-9]{9}$'
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

create function public.admin_notification_sms_stats(
  p_id uuid,
  p_sent integer,
  p_failed integer
) returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.admin_notifications
  set sms_sent = greatest(0, coalesce(p_sent, 0)),
      sms_failed = greatest(0, coalesce(p_failed, 0))
  where id = p_id;
end $$;

create function public.admin_notification_list(
  p_before_at timestamptz default null,
  p_before_id uuid default null,
  p_limit integer default 20
) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_lim integer := greatest(1, least(coalesce(p_limit, 20), 50));
  v_rows jsonb;
  v_more boolean := false;
begin
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id desc), '[]'::jsonb)
  into v_rows
  from (
    select
      n.id, n.actor_name, n.title, n.body,
      n.audience_type, n.audience_store_id, n.audience_role,
      coalesce(s.name, '') as audience_store_name,
      n.channels, n.popup_expires_at, n.popup_revoked_at,
      n.recipient_count, n.inbox_count, n.push_count,
      n.sms_sent, n.sms_failed, n.popup_count, n.created_at
    from public.admin_notifications n
    left join public.stores s on s.id = n.audience_store_id
    where p_before_at is null or (n.created_at, n.id) < (p_before_at, p_before_id)
    order by n.created_at desc, n.id desc
    limit v_lim + 1
  ) x;

  if jsonb_array_length(v_rows) > v_lim then
    v_more := true;
    v_rows := v_rows - v_lim;
  end if;

  return jsonb_build_object('items', v_rows, 'more', v_more);
end $$;

create function public.admin_notification_revoke_popup(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  update public.admin_notifications
  set popup_revoked_at = coalesce(popup_revoked_at, now())
  where id = p_id;
  if not found then
    raise exception 'notification_not_found' using errcode = 'P0002';
  end if;
  update public.app_popups
  set revoked_at = coalesce(revoked_at, now())
  where notification_id = p_id and revoked_at is null;
  return jsonb_build_object('ok', true);
end $$;

-- 8. 商户端应用内弹窗查询与关闭（沿用 inbox_assert_recipient 安全校验）
create function public.inbox_popups(
  p_store uuid,
  p_staff uuid,
  p_owner uuid
) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform public.inbox_assert_recipient(p_store, p_staff, p_owner);
  return jsonb_build_object(
    'items', coalesce((
      select jsonb_agg(to_jsonb(p) order by p.created_at asc)
      from (
        select id, title, body, created_at, expires_at
        from public.app_popups
        where store_id = p_store
          and ((p_staff is not null and staff_id = p_staff)
            or (p_owner is not null and owner_id = p_owner))
          and dismissed_at is null
          and revoked_at is null
          and (expires_at is null or expires_at > now())
        order by created_at asc
        limit 5
      ) p
    ), '[]'::jsonb)
  );
end $$;

create function public.inbox_popup_dismiss(
  p_store uuid,
  p_staff uuid,
  p_owner uuid,
  p_id uuid
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform public.inbox_assert_recipient(p_store, p_staff, p_owner);
  update public.app_popups
  set dismissed_at = coalesce(dismissed_at, now())
  where id = p_id
    and store_id = p_store
    and ((p_staff is not null and staff_id = p_staff)
      or (p_owner is not null and owner_id = p_owner));
  return jsonb_build_object('ok', true);
end $$;

revoke all on function
  public.admin_notification_resolve_recipients(text, uuid, text, jsonb),
  public.admin_notification_recipients_search(text, integer),
  public.admin_notification_preview(text, uuid, text, jsonb),
  public.admin_notification_create(uuid, text, text, text, text, uuid, text, jsonb, text[], timestamptz),
  public.admin_notification_sms_stats(uuid, integer, integer),
  public.admin_notification_list(timestamptz, uuid, integer),
  public.admin_notification_revoke_popup(uuid),
  public.inbox_popups(uuid, uuid, uuid),
  public.inbox_popup_dismiss(uuid, uuid, uuid, uuid)
from public, anon, authenticated;

grant execute on function
  public.admin_notification_recipients_search(text, integer),
  public.admin_notification_preview(text, uuid, text, jsonb),
  public.admin_notification_create(uuid, text, text, text, text, uuid, text, jsonb, text[], timestamptz),
  public.admin_notification_sms_stats(uuid, integer, integer),
  public.admin_notification_list(timestamptz, uuid, integer),
  public.admin_notification_revoke_popup(uuid),
  public.inbox_popups(uuid, uuid, uuid),
  public.inbox_popup_dismiss(uuid, uuid, uuid, uuid)
to service_role;
