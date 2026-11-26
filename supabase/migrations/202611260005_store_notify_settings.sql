-- 将门店短信/业务通知开关从 appointment_settings 彻底拆分为独立的 store_notify_settings 表。

create table public.store_notify_settings (
  store_id uuid primary key references public.stores(id) on delete cascade,
  notify_confirm_default boolean not null default false,
  remind_default boolean not null default false,
  notify_manager boolean not null default false,
  notify_reschedule boolean not null default true,
  notify_cancel boolean not null default true,
  notify_consume boolean not null default true,
  notify_recharge boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.store_notify_settings enable row level security;
create policy store_notify_settings_owner on public.store_notify_settings
  for select to authenticated
  using (exists (
    select 1 from public.stores s
    where s.id = store_id and s.owner_id = (select auth.uid())
  ));
revoke all on public.store_notify_settings from public, anon, authenticated;
grant select on public.store_notify_settings to authenticated;
grant all on public.store_notify_settings to service_role;

-- 迁移既有门店的通知开关配置，避免任何历史开关丢失。
insert into public.store_notify_settings (
  store_id,
  notify_confirm_default,
  remind_default,
  notify_manager,
  notify_reschedule,
  notify_cancel,
  notify_consume,
  notify_recharge
)
select
  store_id,
  notify_confirm_default,
  remind_default,
  notify_manager,
  notify_reschedule,
  notify_cancel,
  notify_consume,
  notify_recharge
from public.appointment_settings
on conflict (store_id) do update set
  notify_confirm_default = excluded.notify_confirm_default,
  remind_default = excluded.remind_default,
  notify_manager = excluded.notify_manager,
  notify_reschedule = excluded.notify_reschedule,
  notify_cancel = excluded.notify_cancel,
  notify_consume = excluded.notify_consume,
  notify_recharge = excluded.notify_recharge,
  updated_at = now();

-- 专用局部更新函数：仅更新显式传入的合法布尔开关，避免整行覆盖与预约规则耦合。
create or replace function public.save_store_notify_settings(p_store uuid, p_input jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  n public.store_notify_settings;
  v_key text;
  v_allowed text[] := array[
    'notify_confirm_default',
    'remind_default',
    'notify_manager',
    'notify_reschedule',
    'notify_cancel',
    'notify_consume',
    'notify_recharge'
  ];
begin
  if p_input is null or jsonb_typeof(p_input) <> 'object' then
    raise exception 'invalid_notify_setting';
  end if;
  foreach v_key in array v_allowed loop
    if p_input ? v_key and jsonb_typeof(p_input -> v_key) <> 'boolean' then
      raise exception 'invalid_notify_setting';
    end if;
  end loop;

  perform pg_advisory_xact_lock(hashtextextended(p_store::text, 0));
  insert into public.store_notify_settings(store_id) values(p_store) on conflict do nothing;
  select * into n from public.store_notify_settings where store_id = p_store for update;

  if p_input ? 'notify_confirm_default' then
    n.notify_confirm_default := (p_input ->> 'notify_confirm_default')::boolean;
  end if;
  if p_input ? 'remind_default' then
    n.remind_default := (p_input ->> 'remind_default')::boolean;
  end if;
  if p_input ? 'notify_manager' then
    n.notify_manager := (p_input ->> 'notify_manager')::boolean;
  end if;
  if p_input ? 'notify_reschedule' then
    n.notify_reschedule := (p_input ->> 'notify_reschedule')::boolean;
  end if;
  if p_input ? 'notify_cancel' then
    n.notify_cancel := (p_input ->> 'notify_cancel')::boolean;
  end if;
  if p_input ? 'notify_consume' then
    n.notify_consume := (p_input ->> 'notify_consume')::boolean;
  end if;
  if p_input ? 'notify_recharge' then
    n.notify_recharge := (p_input ->> 'notify_recharge')::boolean;
  end if;

  if n.notify_manager and not exists (
    select 1 from public.store_staff
    where store_id = p_store and role = 'manager' and status = 'active'
  ) then
    raise exception 'appointment_manager_required';
  end if;

  update public.store_notify_settings
  set
    notify_confirm_default = n.notify_confirm_default,
    remind_default = n.remind_default,
    notify_manager = n.notify_manager,
    notify_reschedule = n.notify_reschedule,
    notify_cancel = n.notify_cancel,
    notify_consume = n.notify_consume,
    notify_recharge = n.notify_recharge,
    updated_at = now()
  where store_id = p_store
  returning * into n;

  return to_jsonb(n);
end $$;

-- 预约默认通知改为读取 store_notify_settings。
create or replace function public.save_merchant_appointment(p_store uuid, p_input jsonb, p_request text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  result jsonb;
  a public.appointments;
  n public.store_notify_settings;
  creating boolean := p_input ->> 'id' is null;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text, 0));
  select * into a from public.appointments where store_id = p_store and request_id = p_request;
  if found then return public.appointment_detail(p_store, a.id); end if;
  if creating then
    insert into public.store_notify_settings(store_id) values(p_store) on conflict do nothing;
    select * into n from public.store_notify_settings where store_id = p_store;
    -- 显式传入的 false 始终优先生效；会员端继续直接调用 save_appointment。
    p_input := jsonb_build_object('remind', n.remind_default, 'notify', n.notify_confirm_default) || p_input;
  end if;
  if p_input ? 'notify' and jsonb_typeof(p_input -> 'notify') <> 'boolean' then
    raise exception 'invalid_notification';
  end if;
  if p_input ? 'remind' and jsonb_typeof(p_input -> 'remind') <> 'boolean' then
    raise exception 'invalid_reminder';
  end if;
  result := public.save_appointment(p_store, p_input, p_request);
  if p_input ? 'remind' then
    select * into a from public.appointments where id = (result ->> 'id')::uuid for update;
    if (p_input ->> 'remind')::boolean and a.phone !~ '^(\+?86)?1[3-9][0-9]{9}$' then
      raise exception 'reminder_phone_required';
    end if;
    update public.appointments set remind_enabled = (p_input ->> 'remind')::boolean where id = a.id;
  end if;
  if creating then
    update public.appointments set notify_confirm = (p_input ->> 'notify')::boolean where id = (result ->> 'id')::uuid;
  end if;
  return public.appointment_detail(p_store, (result ->> 'id')::uuid);
end $$;

-- 预约设置保存函数仅维护纯预约规则字段，不再处理任何通知开关。
create or replace function public.save_appointment_settings(p_store uuid, p_input jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  s public.appointment_settings;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text, 0));
  insert into public.appointment_settings(store_id) values(p_store) on conflict do nothing;
  select * into s from public.appointment_settings where store_id = p_store;
  s := jsonb_populate_record(s, p_input || jsonb_build_object('store_id', p_store));
  if exists (
    select 1 from public.appointments a
    where a.store_id = p_store
      and a.status in ('waiting', 'arrived')
      and a.starts_at + make_interval(mins => a.duration_minutes) > now()
      and (
        select count(*) from public.appointments b
        where b.store_id = p_store
          and b.status in ('waiting', 'arrived')
          and b.starts_at <= a.starts_at
          and b.starts_at + make_interval(mins => b.duration_minutes) > a.starts_at
      ) > s.capacity
  ) then
    raise exception 'capacity_conflict';
  end if;
  update public.appointment_settings
  set
    opens_at = s.opens_at,
    closes_at = s.closes_at,
    slot_minutes = s.slot_minutes,
    capacity = s.capacity,
    lead_hours = s.lead_hours,
    advance_days = s.advance_days,
    grace_minutes = s.grace_minutes,
    closed_days = s.closed_days,
    closed_dates = coalesce(s.closed_dates, '{}')
  where store_id = p_store
  returning * into s;
  return to_jsonb(s);
end $$;

-- 删除 appointment_settings 中的历史通知开关列。
alter table public.appointment_settings
  drop column if exists notify_confirm_default,
  drop column if exists remind_default,
  drop column if exists notify_manager,
  drop column if exists notify_reschedule,
  drop column if exists notify_cancel,
  drop column if exists notify_consume,
  drop column if exists notify_recharge;

do $$
declare f record;
begin
  for f in
    select oid::regprocedure as signature
    from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname in (
        'save_store_notify_settings',
        'save_merchant_appointment',
        'save_appointment_settings'
      )
  loop
    execute format('revoke all on function %s from public, anon, authenticated', f.signature);
    execute format('grant execute on function %s to service_role', f.signature);
  end loop;
end $$;
