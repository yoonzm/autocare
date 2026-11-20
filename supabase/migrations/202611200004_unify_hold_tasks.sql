-- 技师任务极简三态（100% 基于挂单 held_orders，与预约解耦，不建 held_order_work 表）：
-- 1. 预约只管到店前（技师在「今日到店」查看）；预约到店开单支持直接点「挂单」转为挂单（held_orders.appointment_id）；
-- 2. 技师工作台与「我的任务」只查指派给该技师（s.resource_id = any(h.technician_ids)）的挂单：
--    待施工（waiting）→ 点「开始施工」变为 施工中（arrived）→ 点「提交完工」变为 待结算（done）；
-- 3. 前台待收银展示所有「待结算」挂单，退回时恢复为「施工中」；取单结算同步完成关联预约并按 technician_ids 计提成。

alter table public.held_orders
  add column if not exists appointment_id uuid references public.appointments(id) on delete set null;

create index if not exists held_orders_appointment_idx
  on public.held_orders(appointment_id)
  where appointment_id is not null and settled_at is null and cancelled_at is null;

drop function if exists public.hold_order_with_technicians(uuid, uuid, jsonb, text, text, text, text, uuid, uuid[]);
create or replace function public.hold_order_with_technicians(
  p_store uuid, p_member uuid, p_lines jsonb, p_status text, p_note text, p_remind text,
  p_plate text, p_hold uuid, p_technician_ids uuid[], p_appointment uuid default null
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
  v_hold uuid := p_hold;
  v_existing uuid[];
  v_techs uuid[];
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

  v_id := public.hold_order(p_store, p_member, p_lines, p_status, p_note, p_remind, p_plate, v_hold);

  if p_technician_ids is not null then
    select technician_ids into v_existing from public.held_orders where id = v_id and store_id = p_store;
    v_techs := public.order_technicians(p_store, p_technician_ids, v_existing);
    update public.held_orders set technician_ids = v_techs where id = v_id and store_id = p_store;
  else
    select technician_ids into v_techs from public.held_orders where id = v_id and store_id = p_store;
  end if;

  if p_appointment is not null then
    update public.held_orders set appointment_id = p_appointment where id = v_id and store_id = p_store;
    update public.appointments
    set status = 'arrived',
        arrived_at = coalesce(arrived_at, now()),
        technician_id = coalesce(v_techs[1], technician_id),
        updated_at = now()
    where id = p_appointment and store_id = p_store and status in ('waiting', 'late', 'arrived');
  end if;

  return v_id;
end;
$$;

-- 取单结算时若挂单关联了预约，同步回填订单的 appointment_id 并将预约标记为 done
create or replace function public.settle_held_order(
  p_store uuid, p_hold uuid, p_lines jsonb, p_method text, p_balance_part numeric, p_other text,
  p_plate text, p_remark text, p_operator text, p_request text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  h public.held_orders;
  v_res jsonb;
  v_remark text;
  v_order uuid;
begin
  select * into h from public.held_orders where id = p_hold and store_id = p_store for update;
  if not found then raise exception 'hold_not_found' using errcode = 'P0002'; end if;
  v_remark := coalesce(nullif(p_remark, ''), h.note);
  if h.settled_at is not null or h.cancelled_at is not null then
    if p_request is not null and exists (
      select 1 from public.orders where store_id = p_store and request_id = p_request
    ) then
      if h.member_id is null then
        return public.checkout_walkin(p_store, p_lines, p_method, p_plate, v_remark, p_operator, p_request);
      end if;
      return public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
        p_plate, p_remark, p_operator, p_request);
    end if;
    raise exception 'hold_closed' using errcode = 'P0001';
  end if;
  if h.member_id is null then
    v_res := public.checkout_walkin(p_store, p_lines, p_method, p_plate, v_remark, p_operator, p_request);
  else
    v_res := public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
      p_plate, v_remark, p_operator, p_request);
  end if;
  v_order := (v_res->>'order_id')::uuid;
  update public.held_orders set settled_at = now(), order_id = v_order, updated_at = now()
  where id = h.id;
  if h.appointment_id is not null then
    update public.orders set appointment_id = h.appointment_id where id = v_order and store_id = p_store;
    update public.appointments
    set status = 'done',
        completed_at = coalesce(completed_at, now()),
        order_id = v_order,
        updated_at = now()
    where id = h.appointment_id and store_id = p_store;
  end if;
  return v_res;
end;
$$;

-- 挂单预计提成：按当前技师提成方案和挂单项目价格估算
create or replace function public.staff_estimate_hold_commission(p_store uuid, p_staff uuid, p_hold uuid) returns numeric
language plpgsql stable security definer set search_path = public as $$
declare
  s public.store_staff;
  h public.held_orders;
  it record;
  svc public.service_items;
  total numeric := 0;
  price numeric;
  qty integer;
begin
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  select * into h from public.held_orders where id = p_hold and store_id = p_store;
  if s.id is null or h.id is null then return 0; end if;
  for it in select * from public.held_order_items where held_order_id = p_hold order by position loop
    qty := greatest(coalesce(it.qty, 1), 1);
    select * into svc from public.service_items where id = it.service_id and store_id = p_store;
    price := coalesce(svc.price, 0) * qty;
    if s.commission_mode = 'flat' then
      total := total + price * s.commission_rate / 100;
    elsif s.commission_mode = 'custom' and it.service_id is not null and s.commission_overrides ? it.service_id::text then
      total := total + price * (s.commission_overrides->>it.service_id::text)::numeric / 100;
    elsif svc.id is not null then
      total := total + case when svc.commission_type = 'fixed' then svc.commission_value * qty else price * svc.commission_value / 100 end;
    end if;
  end loop;
  return round(total, 2);
end $$;

-- 挂单转为技师任务 JSON（极简三态：待施工 waiting / 施工中 arrived / 已完成 done）
create or replace function public.staff_hold_task_json(p_store uuid, p_staff uuid, p_id uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'id', h.id,
    'plate', h.vehicle_plate,
    'status', case
      when h.settled_at is not null or h.status = '待结算' then 'done'
      when h.status = '施工中' then 'arrived'
      else 'waiting'
    end,
    'starts_at', h.created_at,
    'duration_minutes', coalesce((
      select sum(coalesce(sv.duration_minutes, 30) * greatest(coalesce(i.qty, 1), 1))::int
      from public.held_order_items i
      left join public.service_items sv on sv.id = i.service_id and sv.store_id = p_store
      where i.held_order_id = h.id
    ), 30),
    'customer', coalesce((select m.name from public.members m where m.id = h.member_id), '散客'),
    'note', h.note,
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'service_id', i.service_id,
        'name', i.name,
        'qty', i.qty,
        'price', coalesce(sv.price, 0) * greatest(coalesce(i.qty, 1), 1)
      ) order by i.position)
      from public.held_order_items i
      left join public.service_items sv on sv.id = i.service_id and sv.store_id = p_store
      where i.held_order_id = h.id
    ), '[]'::jsonb),
    'level', coalesce((select c.name from public.members m join public.card_types c on c.id = m.card_type_id where m.id = h.member_id), '散客'),
    'bay_name', coalesce(
      (select b.name from public.appointments a join public.appointment_resources b on b.id = a.bay_id where a.id = h.appointment_id),
      (select b.name from public.store_staff st join public.appointment_resources b on b.id = st.bay_id where st.id = p_staff)
    ),
    'finished_at', case
      when h.settled_at is not null or h.status = '待结算' then coalesce(h.settled_at, h.updated_at)
      else null
    end,
    'arrived_at', h.created_at,
    'completed_at', h.settled_at,
    'est_commission', public.staff_estimate_hold_commission(p_store, p_staff, h.id)
  )
  from public.held_orders h
  where h.id = p_id and h.store_id = p_store
$$;

-- 员工工作台：技师任务只展示指派给自己的未结算挂单（待施工 / 施工中）；预约通过「今日到店」查看
create or replace function public.staff_home(p_store uuid, p_staff uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  s public.store_staff;
  d0 timestamptz;
  d1 timestamptz;
  res jsonb;
  tasks jsonb;
begin
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  if not found then raise exception 'staff_not_found' using errcode = 'P0002'; end if;
  d0 := (date_trunc('day', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  d1 := d0 + interval '1 day';
  if s.role = 'technician' then
    select coalesce(jsonb_agg(public.staff_hold_task_json(p_store, p_staff, h.id) order by h.status <> '施工中', h.created_at), '[]'::jsonb)
    into tasks
    from public.held_orders h
    where h.store_id = p_store
      and s.resource_id = any(h.technician_ids)
      and h.settled_at is null
      and h.cancelled_at is null
      and h.status in ('待施工', '施工中');
    res := jsonb_build_object(
      'tasks', tasks,
      'done_today', (
        select count(*) from public.orders o
        left join public.appointments a on a.id = o.appointment_id and a.store_id = o.store_id
        where o.store_id = p_store
          and (s.resource_id = any(o.technician_ids) or (cardinality(o.technician_ids) = 0 and a.technician_id = s.resource_id))
          and o.created_at >= d0 and o.created_at < d1
      ),
      'revenue_today', coalesce((
        select sum(o.payable) from public.orders o
        left join public.appointments a on a.id = o.appointment_id and a.store_id = o.store_id
        where o.store_id = p_store
          and (s.resource_id = any(o.technician_ids) or (cardinality(o.technician_ids) = 0 and a.technician_id = s.resource_id))
          and o.created_at >= d0 and o.created_at < d1
      ), 0),
      'commission_today', coalesce((
        select sum(c.amount) from public.staff_commissions c
        where c.staff_id = s.id and c.created_at >= d0 and c.created_at < d1
      ), 0),
      'waiting', (
        select count(*) from public.held_orders h
        where h.store_id = p_store and s.resource_id = any(h.technician_ids) and h.settled_at is null and h.cancelled_at is null and h.status = '待施工'
      ),
      'working', (
        select count(*) from public.held_orders h
        where h.store_id = p_store and s.resource_id = any(h.technician_ids) and h.settled_at is null and h.cancelled_at is null and h.status = '施工中'
      )
    );
  else
    select coalesce(jsonb_agg(jsonb_build_object(
      'id', a.id, 'plate', a.vehicle_plate, 'status', a.status, 'starts_at', a.starts_at,
      'customer', a.customer_name, 'items', a.items
    ) order by a.starts_at), '[]'::jsonb)
    into tasks
    from (
      select * from public.appointments
      where store_id = p_store and status = 'waiting' and starts_at >= now() and starts_at < d1
      order by starts_at limit 5
    ) a;
    res := jsonb_build_object(
      'upcoming', tasks,
      'orders_today', (select count(*) from public.orders where store_id = p_store and created_at >= d0 and created_at < d1),
      'waiting', (
        select count(*) from public.appointments where store_id = p_store and status = 'waiting' and starts_at >= d0 and starts_at < d1
      ),
      'working', (
        select count(*) from public.held_orders where store_id = p_store and settled_at is null and cancelled_at is null and status = '施工中'
      )
    );
  end if;
  return res || jsonb_build_object(
    'role', s.role,
    'name', s.name,
    'phone', s.phone,
    'joined_on', s.joined_on,
    'month_done', (
      select count(*) from public.orders o
      left join public.appointments a on a.id = o.appointment_id and a.store_id = o.store_id
      where o.store_id = p_store
        and (s.resource_id = any(o.technician_ids) or (cardinality(o.technician_ids) = 0 and a.technician_id = s.resource_id))
        and o.created_at >= (date_trunc('month', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')
    ),
    'month_commission', coalesce((
      select sum(c.amount) from public.staff_commissions c
      where c.staff_id = s.id
        and c.created_at >= (date_trunc('month', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')
    ), 0)
  );
end $$;

-- 我的任务列表：只返回指派给当前技师的挂单（待施工 / 施工中 / 今日待结算或今日已结算）
create or replace function public.staff_task_list(p_store uuid, p_staff uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  s public.store_staff;
  d0 timestamptz;
  d1 timestamptz;
  rows jsonb;
begin
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  if not found or s.role <> 'technician' then raise exception 'staff_not_found' using errcode = 'P0002'; end if;
  d0 := (date_trunc('day', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  d1 := d0 + interval '1 day';
  select coalesce(jsonb_agg(public.staff_hold_task_json(p_store, p_staff, h.id) order by h.created_at), '[]'::jsonb)
  into rows
  from public.held_orders h
  where h.store_id = p_store
    and s.resource_id = any(h.technician_ids)
    and h.cancelled_at is null
    and (
      (h.settled_at is null and h.status in ('待施工', '施工中'))
      or (h.settled_at is null and h.status = '待结算' and h.updated_at >= d0)
      or (h.settled_at is not null and h.settled_at >= d0 and h.settled_at < d1)
    );
  return jsonb_build_object('items', rows);
end $$;

-- 任务详情：读取指派给当前技师的挂单
create or replace function public.staff_task_detail(p_store uuid, p_staff uuid, p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  s public.store_staff;
  h public.held_orders;
begin
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  select * into h from public.held_orders where id = p_id and store_id = p_store and cancelled_at is null;
  if s.id is null or h.id is null or not (s.resource_id = any(h.technician_ids)) then
    raise exception 'task_not_found' using errcode = 'P0002';
  end if;
  return public.staff_hold_task_json(p_store, p_staff, p_id);
end $$;

-- 开始施工：将「待施工」挂单推进为「施工中」
create or replace function public.staff_task_progress(p_store uuid, p_staff uuid, p_id uuid, p_stage integer) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  s public.store_staff;
  h public.held_orders;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_id::text, 3));
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  select * into h from public.held_orders where id = p_id and store_id = p_store and cancelled_at is null for update;
  if s.id is null or h.id is null or not (s.resource_id = any(h.technician_ids)) then
    raise exception 'task_not_found' using errcode = 'P0002';
  end if;
  if p_stage is null or p_stage < 1 or p_stage > 3 then raise exception 'stage_invalid'; end if;
  if h.settled_at is not null or h.status = '待结算' then raise exception 'task_finished'; end if;
  update public.held_orders set status = '施工中', updated_at = now() where id = p_id;
  return public.staff_hold_task_json(p_store, p_staff, p_id);
end $$;

-- 提交完工：将「施工中」挂单推进为「待结算」，并通知前台/店长收银
create or replace function public.staff_task_finish(p_store uuid, p_staff uuid, p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  s public.store_staff;
  h public.held_orders;
  r jsonb;
  d0 timestamptz;
  today_est numeric;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_id::text, 3));
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  select * into h from public.held_orders where id = p_id and store_id = p_store and cancelled_at is null for update;
  if s.id is null or h.id is null or not (s.resource_id = any(h.technician_ids)) then
    raise exception 'task_not_found' using errcode = 'P0002';
  end if;
  if h.settled_at is not null or h.status = '待结算' then raise exception 'task_finished'; end if;
  if h.status <> '施工中' then raise exception 'task_not_working'; end if;
  d0 := (date_trunc('day', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');

  update public.held_orders
  set status = '待结算',
      submitted_by = coalesce(submitted_by, s.id),
      updated_at = now()
  where id = p_id;
  if h.appointment_id is not null then
    perform public.service_consumables_deduct(p_store, h.appointment_id, s.name || '（完工自动扣减）');
  end if;

  r := public.staff_hold_task_json(p_store, p_staff, p_id);
  insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
    select p_store, x.id, 'system', '施工已完成待收银',
      coalesce(nullif(h.vehicle_plate, ''), '车辆') || ' ' || coalesce((select string_agg(i.name, ' · ' order by i.position) from public.held_order_items i where i.held_order_id = h.id), '') || ' 已由 ' || s.name || ' 完工。',
      'StCashQueue'
    from public.store_staff x where x.store_id = p_store and x.status = 'active' and x.role in ('cashier', 'manager');

  today_est := coalesce((
    select sum(public.staff_estimate_hold_commission(p_store, p_staff, hb.id))
    from public.held_orders hb
    where hb.store_id = p_store
      and s.resource_id = any(hb.technician_ids)
      and hb.cancelled_at is null
      and (hb.status = '待结算' or hb.settled_at is not null)
      and coalesce(hb.settled_at, hb.updated_at) >= d0
  ), 0);

  return r || jsonb_build_object('today_commission', today_est);
end $$;

-- 新挂单指派技师时发送任务通知
create or replace function public.held_order_staff_messages() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  t public.store_staff;
  items text;
begin
  if new.cancelled_at is not null or new.settled_at is not null or cardinality(new.technician_ids) = 0 then
    return new;
  end if;
  select string_agg(i.name, ' · ' order by i.position) into items
  from public.held_order_items i where i.held_order_id = new.id;
  for t in
    select * from public.store_staff
    where store_id = new.store_id and status <> 'disabled' and resource_id = any(new.technician_ids)
      and (tg_op = 'INSERT' or not (resource_id = any(coalesce(old.technician_ids, '{}'))))
  loop
    insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
    values (
      new.store_id, t.id, 'task', '新任务派给你',
      coalesce(nullif(new.vehicle_plate, ''), '车辆') || ' ' || coalesce(items, '施工任务') || ' 已挂单派给你。',
      'StTaskDetail:' || new.id
    );
  end loop;
  return new;
end $$;

drop trigger if exists held_orders_staff_messages on public.held_orders;
create trigger held_orders_staff_messages after insert or update of technician_ids on public.held_orders
  for each row execute function public.held_order_staff_messages();

-- 施工照片权限：校验挂单归属当前技师（同时兼容历史预约照片读取）
create or replace function public.merchant_media_access(p_store uuid, p_user uuid, p_staff uuid, p_kind text, p_target uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_kind = 'store' then
    if p_target is null or p_target <> p_store or not exists(select 1 from public.stores where id = p_store and owner_id = p_user and archived_at is null) then
      raise exception 'media_forbidden' using errcode = '42501';
    end if;
  elsif p_kind = 'task' then
    if not exists(
      select 1 from public.held_orders h
      join public.store_staff s on s.store_id = h.store_id and s.resource_id = any(h.technician_ids)
      where h.id = p_target and h.store_id = p_store and s.id = p_staff and s.status = 'active' and h.cancelled_at is null
    ) and not exists(
      select 1 from public.appointments a
      join public.store_staff s on s.store_id = a.store_id and s.resource_id = a.technician_id
      where a.id = p_target and a.store_id = p_store and s.id = p_staff and s.status = 'active' and a.status in ('waiting', 'arrived', 'done')
    ) then
      raise exception 'media_forbidden' using errcode = '42501';
    end if;
  else
    raise exception 'media_kind_invalid';
  end if;
end $$;

-- 前台待收银退回：带技师的待结算挂单退回为「施工中」回到技师任务
create or replace function public.staff_order_return(p_store uuid, p_hold uuid, p_reason text)
returns boolean language plpgsql security definer set search_path = public as $$
declare h public.held_orders;
begin
  select * into h from public.held_orders
  where id = p_hold and store_id = p_store and settled_at is null and cancelled_at is null
    and (submitted_by is not null or status = '待结算')
  for update;
  if not found then raise exception 'hold_not_found' using errcode = 'P0002'; end if;

  if cardinality(h.technician_ids) > 0 then
    update public.held_orders set status = '施工中', updated_at = now() where id = h.id;
    insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
    select h.store_id, st.id, 'system', '开单被退回',
      left(coalesce(nullif(trim(p_reason), ''), '请核对后重新提交') || ' · ' || h.vehicle_plate, 300),
      'StTaskDetail:' || h.id
    from public.store_staff st
    where st.store_id = h.store_id and st.status = 'active'
      and (st.resource_id = any(h.technician_ids) or st.id = h.submitted_by);
  else
    update public.held_orders set cancelled_at = now(), updated_at = now() where id = h.id;
    insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
    select h.store_id, h.submitted_by, 'system', '开单被退回',
      left(coalesce(nullif(trim(p_reason), ''), '请核对后重新提交') || ' · ' || h.vehicle_plate, 300), ''
    where h.submitted_by is not null;
  end if;
  return true;
end $$;

-- 提成快照与业绩统计：支持直接开单/挂单结算选中的 technician_ids，以及预约关联的技师
alter table public.staff_commissions drop constraint if exists staff_commissions_pkey;
alter table public.staff_commissions add primary key (order_id, position, staff_id);

create or replace function public.staff_commission_snapshot() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  s public.store_staff;
  it record;
  svc public.service_items;
  actual numeric;
  ratio numeric;
  rl text;
  rt numeric;
  amt numeric;
  tech_res uuid[];
begin
  tech_res := coalesce(new.technician_ids, '{}');
  if cardinality(tech_res) = 0 and new.appointment_id is not null then
    select array_remove(array[a.technician_id], null) into tech_res
    from public.appointments a where a.id = new.appointment_id and a.store_id = new.store_id;
  end if;
  if cardinality(coalesce(tech_res, '{}')) = 0 then return new; end if;

  ratio := case when new.subtotal > 0 then new.payable / new.subtotal else 1 end;
  for s in
    select * from public.store_staff
    where store_id = new.store_id and resource_id = any(tech_res)
  loop
    for it in select * from public.order_items where order_id = new.id loop
      actual := round(it.line_total * ratio, 2);
      select * into svc from public.service_items where id = it.service_id;
      rl := null;
      if s.commission_mode = 'flat' then
        rl := 'flat_percent'; rt := s.commission_rate;
      elsif s.commission_mode = 'custom' and s.commission_overrides ? coalesce(it.service_id::text, '') then
        rl := 'custom_percent'; rt := (s.commission_overrides->>it.service_id::text)::numeric;
      elsif svc.id is not null then
        rl := case when svc.commission_type = 'fixed' then 'project_fixed' else 'project_percent' end;
        rt := svc.commission_value;
      end if;
      if rl is null then continue; end if;
      amt := case when rl = 'project_fixed' then round(rt * it.qty, 2) else round(actual * rt / 100, 2) end;
      insert into public.staff_commissions(order_id, position, store_id, staff_id, appointment_id, service_id, base, rule, rate, amount)
      values (new.id, it.position, new.store_id, s.id, new.appointment_id, it.service_id, actual, rl, rt, amt)
      on conflict do nothing;
    end loop;
  end loop;
  return new;
end $$;

drop trigger if exists orders_staff_commission on public.orders;
create trigger orders_staff_commission after update of appointment_id, technician_ids on public.orders
  for each row execute function public.staff_commission_snapshot();

create or replace function public.staff_perf(p_store uuid, p_staff uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  s public.store_staff;
  m0 timestamptz;
  d0 timestamptz;
  days jsonb;
  rows jsonb;
begin
  select * into s from public.store_staff where id = p_staff and store_id = p_store;
  if not found then raise exception 'staff_not_found' using errcode = 'P0002'; end if;
  m0 := (date_trunc('month', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  d0 := (date_trunc('day', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  select jsonb_agg(jsonb_build_object(
    'day', to_char(dd, 'YYYY-MM-DD'),
    'amount', coalesce((
      select sum(c.amount) from public.staff_commissions c
      where c.staff_id = s.id
        and c.created_at >= (dd::timestamp at time zone 'Asia/Shanghai')
        and c.created_at < ((dd + 1)::timestamp at time zone 'Asia/Shanghai')
    ), 0)
  ) order by dd)
  into days
  from (select ((now() at time zone 'Asia/Shanghai')::date - g) dd from generate_series(0, 6) g) x;

  select coalesce(jsonb_agg(jsonb_build_object(
    'service', coalesce(i.name, '服务'),
    'plate', coalesce(ap.vehicle_plate, o.vehicle_plate, ''),
    'at', c.created_at,
    'amount', c.amount
  ) order by c.created_at desc), '[]'::jsonb)
  into rows
  from (select * from public.staff_commissions where staff_id = s.id and created_at >= m0 order by created_at desc limit 50) c
  join public.orders o on o.id = c.order_id
  left join public.order_items i on i.order_id = c.order_id and i.position = c.position
  left join public.appointments ap on ap.id = c.appointment_id;

  return jsonb_build_object(
    'month_commission', coalesce((select sum(amount) from public.staff_commissions where staff_id = s.id and created_at >= m0), 0),
    'month_orders', (
      select count(distinct o.id) from public.orders o
      left join public.appointments a on a.id = o.appointment_id and a.store_id = o.store_id
      where o.store_id = p_store
        and (s.resource_id = any(o.technician_ids) or (cardinality(o.technician_ids) = 0 and a.technician_id = s.resource_id))
        and o.created_at >= m0
    ),
    'month_revenue', coalesce((
      select sum(o.payable) from public.orders o
      left join public.appointments a on a.id = o.appointment_id and a.store_id = o.store_id
      where o.store_id = p_store
        and (s.resource_id = any(o.technician_ids) or (cardinality(o.technician_ids) = 0 and a.technician_id = s.resource_id))
        and o.created_at >= m0
    ), 0),
    'days', days,
    'rows', rows,
    'month', to_char(now() at time zone 'Asia/Shanghai', 'YYYY-MM')
  );
end $$;

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace = 'public'::regnamespace
    and proname in (
      'hold_order_with_technicians', 'settle_held_order',
      'staff_estimate_hold_commission', 'staff_hold_task_json',
      'staff_home', 'staff_task_list', 'staff_task_detail', 'staff_task_progress', 'staff_task_finish',
      'held_order_staff_messages', 'merchant_media_access', 'staff_order_return', 'staff_commission_snapshot', 'staff_perf'
    ) loop
    execute format('revoke all on function %s from public, anon, authenticated', f.signature);
    execute format('grant execute on function %s to service_role', f.signature);
  end loop;
end $$;
