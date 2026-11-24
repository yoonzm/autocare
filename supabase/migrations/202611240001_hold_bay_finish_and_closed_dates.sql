-- 1. 挂单与订单增加工位（bay_id / bay_name）及预计完工时间（estimated_finish）
alter table public.held_orders
  add column if not exists bay_id uuid references public.appointment_resources(id) on delete set null,
  add column if not exists bay_name text not null default '',
  add column if not exists estimated_finish text not null default '';

alter table public.orders
  add column if not exists bay_id uuid references public.appointment_resources(id) on delete set null,
  add column if not exists bay_name text not null default '',
  add column if not exists estimated_finish text not null default '';

-- 校验门店工位并返回名称快照（已停用但原本已选中的工位允许保留）
create or replace function public.order_bay_snapshot(
  p_store uuid, p_bay uuid, p_existing uuid default null
) returns text
language plpgsql stable security definer set search_path = public as $$
declare
  v_name text;
begin
  if p_bay is null then return ''; end if;
  select name into v_name
  from public.appointment_resources
  where id = p_bay and store_id = p_store and kind = 'bay'
    and (active or id = p_existing);
  if not found then
    raise exception 'order_bay_unavailable' using errcode = '22023';
  end if;
  return v_name;
end $$;

drop function if exists public.hold_order_with_technicians(uuid, uuid, jsonb, text, text, text, text, uuid, uuid[], uuid);
create or replace function public.hold_order_with_technicians(
  p_store uuid, p_member uuid, p_lines jsonb, p_status text, p_note text, p_remind text,
  p_plate text, p_hold uuid, p_technician_ids uuid[], p_appointment uuid default null,
  p_bay uuid default null, p_estimated_finish text default ''
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
  v_hold uuid := p_hold;
  v_existing uuid[];
  v_existing_bay uuid;
  v_techs uuid[];
  v_bay_name text := '';
  v_finish text := left(trim(coalesce(p_estimated_finish, '')), 30);
begin
  if p_appointment is not null then
    if not exists (
      select 1 from public.appointments
      where id = p_appointment and store_id = p_store and status not in ('done', 'cancelled')
    ) then
      raise exception 'appointment_not_found' using errcode = 'P0002';
    end if;
    if v_hold is null then
      select id into v_hold from public.held_orders
      where store_id = p_store and appointment_id = p_appointment and settled_at is null and cancelled_at is null
      order by created_at desc limit 1;
    end if;
  end if;

  if v_hold is not null then
    select bay_id into v_existing_bay from public.held_orders where id = v_hold and store_id = p_store;
  end if;

  v_id := public.hold_order(p_store, p_member, p_lines, p_status, p_note, p_remind, p_plate, v_hold);

  if p_technician_ids is not null then
    select technician_ids into v_existing from public.held_orders where id = v_id and store_id = p_store;
    v_techs := public.order_technicians(p_store, p_technician_ids, v_existing);
    update public.held_orders set technician_ids = v_techs where id = v_id and store_id = p_store;
  else
    select technician_ids into v_techs from public.held_orders where id = v_id and store_id = p_store;
  end if;

  v_bay_name := public.order_bay_snapshot(p_store, p_bay, v_existing_bay);
  update public.held_orders
  set bay_id = p_bay,
      bay_name = v_bay_name,
      estimated_finish = v_finish
  where id = v_id and store_id = p_store;

  if p_appointment is not null then
    update public.held_orders set appointment_id = p_appointment where id = v_id and store_id = p_store;
    update public.appointments
    set status = 'arrived',
        arrived_at = coalesce(arrived_at, now()),
        technician_id = coalesce(v_techs[1], technician_id),
        bay_id = coalesce(p_bay, bay_id),
        updated_at = now()
    where id = p_appointment and store_id = p_store and status in ('waiting', 'late', 'arrived');
  end if;

  return v_id;
end;
$$;

drop function if exists public.checkout_with_technicians(uuid, jsonb, text, text, text, text, text, uuid[], uuid, uuid, uuid, numeric, text);
create or replace function public.checkout_with_technicians(
  p_store uuid, p_lines jsonb, p_method text, p_plate text, p_remark text, p_operator text,
  p_request text, p_technician_ids uuid[], p_member uuid, p_hold uuid, p_appointment uuid,
  p_balance_part numeric, p_other text,
  p_bay uuid default null, p_estimated_finish text default ''
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_result jsonb;
  v_order uuid;
  v_ids uuid[] := '{}';
  v_bay uuid := p_bay;
  v_existing_bay uuid;
  v_bay_name text := '';
  v_finish text := left(trim(coalesce(p_estimated_finish, '')), 30);
begin
  if p_appointment is not null then
    v_result := public.checkout_appointment(p_store, p_appointment, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_operator, p_request);
  elsif p_hold is not null then
    v_result := public.settle_held_order(p_store, p_hold, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_remark, p_operator, p_request);
  elsif p_member is not null then
    v_result := public.checkout_order(p_store, p_member, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_remark, p_operator, p_request);
  else
    v_result := public.checkout_walkin(p_store, p_lines, p_method, p_plate, p_remark, p_operator, p_request);
  end if;

  v_order := (v_result->>'order_id')::uuid;
  if v_result->>'repeated' = 'true' then
    select technician_ids, bay_id, bay_name, estimated_finish
    into v_ids, v_bay, v_bay_name, v_finish
    from public.orders where id = v_order and store_id = p_store;
  else
    if p_appointment is not null then
      select array_remove(array[technician_id], null), bay_id
      into v_ids, v_existing_bay
      from public.appointments where id = p_appointment and store_id = p_store;
    elsif p_hold is not null then
      select technician_ids, bay_id, estimated_finish
      into v_ids, v_existing_bay, v_finish
      from public.held_orders where id = p_hold and store_id = p_store;
      if v_finish = '' then
        v_finish := left(trim(coalesce(p_estimated_finish, '')), 30);
      elsif trim(coalesce(p_estimated_finish, '')) <> '' then
        v_finish := left(trim(p_estimated_finish), 30);
      end if;
    end if;
    if v_bay is null then
      v_bay := v_existing_bay;
    end if;
    v_ids := public.order_technicians(p_store, p_technician_ids, v_ids);
    v_bay_name := public.order_bay_snapshot(p_store, v_bay, v_existing_bay);
    if cardinality(v_ids) > 0 or v_bay is not null or v_finish <> '' then
      update public.orders
      set technician_ids = case when cardinality(v_ids) > 0 then v_ids else technician_ids end,
          bay_id = v_bay,
          bay_name = v_bay_name,
          estimated_finish = v_finish
      where id = v_order and store_id = p_store;
    end if;
  end if;
  return v_result || jsonb_build_object(
    'technician_ids', coalesce(v_ids, '{}'::uuid[]),
    'bay_id', v_bay,
    'bay_name', coalesce(v_bay_name, ''),
    'estimated_finish', coalesce(v_finish, '')
  );
end;
$$;

-- 2. 预约设置增加节假日 / 指定休息日（closed_dates）
alter table public.appointment_settings
  add column if not exists closed_dates date[] not null default '{}';

create or replace function public.appointment_slot_available(p_store uuid, p_start timestamptz, p_duration integer,
  p_exclude uuid default null,p_bay uuid default null,p_tech uuid default null)
returns boolean language plpgsql stable security definer set search_path=public as $$
declare s public.appointment_settings; local_start timestamp; local_end timestamp; assignment jsonb; effective_capacity integer;
begin
  select * into s from public.appointment_settings where store_id=p_store;
  if not found or p_duration is null or p_duration < 15 or p_duration > 1440 or p_start is null then return false; end if;
  assignment:=public.appointment_assignment(p_store,p_bay,p_tech);
  p_bay:=(assignment->>'bay_id')::uuid;p_tech:=(assignment->>'technician_id')::uuid;
  select least(s.capacity,count(*)::integer) into effective_capacity from public.appointment_resources
    where store_id=p_store and kind='bay' and active;
  if effective_capacity=0 then return false; end if;
  if p_bay is not null and not exists(select 1 from public.appointment_resources where id=p_bay and store_id=p_store and kind='bay' and active)
    then return false; end if;
  if p_tech is not null and not exists(select 1 from public.appointment_resources where id=p_tech and store_id=p_store and kind='technician' and active)
    then return false; end if;
  if exists(select 1 from public.appointments a where a.store_id=p_store and a.status in ('waiting','arrived')
    and (p_exclude is null or a.id<>p_exclude)
    and ((p_bay is not null and a.bay_id=p_bay) or (p_tech is not null and a.technician_id=p_tech))
    and a.starts_at<p_start+make_interval(mins=>p_duration) and a.starts_at+make_interval(mins=>a.duration_minutes)>p_start)
    then return false; end if;
  local_start := p_start at time zone 'Asia/Shanghai';
  local_end := local_start + make_interval(mins=>p_duration);
  if p_start < now()+make_interval(hours=>s.lead_hours)
    or local_start::date > (now() at time zone 'Asia/Shanghai')::date+s.advance_days
    or extract(isodow from local_start)::integer=any(s.closed_days)
    or local_start::date = any(s.closed_dates)
    or local_start::time < s.opens_at or local_end::date <> local_start::date or local_end::time > s.closes_at
    or extract(second from local_start) <> 0
    or mod((extract(epoch from (local_start::time-s.opens_at))/60)::integer,s.slot_minutes) <> 0 then return false; end if;
  return not exists (
    select 1 from (
      select p_start as point union select a.starts_at from public.appointments a
      where a.store_id=p_store and a.status in ('waiting','arrived')
        and (p_exclude is null or a.id<>p_exclude) and a.starts_at>=p_start
        and a.starts_at < p_start+make_interval(mins=>p_duration)
    ) points where (select count(*) from public.appointments a
      where a.store_id=p_store and a.status in ('waiting','arrived')
        and (p_exclude is null or a.id<>p_exclude) and a.starts_at<=points.point
        and a.starts_at+make_interval(mins=>a.duration_minutes)>points.point) >= effective_capacity
  );
end $$;

create or replace function public.save_appointment_settings(p_store uuid,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.appointment_settings;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  insert into public.appointment_settings(store_id) values(p_store) on conflict do nothing;
  select * into s from public.appointment_settings where store_id=p_store;
  s:=jsonb_populate_record(s,p_input||jsonb_build_object('store_id',p_store));
  if exists(select 1 from public.appointments a where a.store_id=p_store and a.status in ('waiting','arrived')
    and a.starts_at+make_interval(mins=>a.duration_minutes)>now() and (select count(*) from public.appointments b
      where b.store_id=p_store and b.status in ('waiting','arrived') and b.starts_at<=a.starts_at
        and b.starts_at+make_interval(mins=>b.duration_minutes)>a.starts_at)>s.capacity) then raise exception 'capacity_conflict'; end if;
  update public.appointment_settings set opens_at=s.opens_at,closes_at=s.closes_at,slot_minutes=s.slot_minutes,
    capacity=s.capacity,lead_hours=s.lead_hours,advance_days=s.advance_days,grace_minutes=s.grace_minutes,
    closed_days=s.closed_days,closed_dates=coalesce(s.closed_dates,'{}')
    where store_id=p_store;
  return to_jsonb(s);
end $$;

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace = 'public'::regnamespace
    and proname in ('order_bay_snapshot', 'hold_order_with_technicians', 'checkout_with_technicians', 'appointment_slot_available', 'save_appointment_settings') loop
    execute format('revoke all on function %s from public, anon, authenticated', f.signature);
    execute format('grant execute on function %s to service_role', f.signature);
  end loop;
end $$;
