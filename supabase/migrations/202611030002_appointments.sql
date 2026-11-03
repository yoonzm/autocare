-- 商户预约：北京时间，权限由 Edge Function 校验；写入仅允许 service_role。
alter table public.service_items add column if not exists duration_minutes integer not null default 30
  check (duration_minutes between 15 and 720);

create table public.appointment_settings (
  store_id uuid primary key references public.stores(id) on delete cascade,
  opens_at time not null default '09:00', closes_at time not null default '20:00',
  slot_minutes integer not null default 30 check (slot_minutes in (15,30,60)),
  capacity integer not null default 1 check (capacity between 1 and 20),
  lead_hours integer not null default 0 check (lead_hours between 0 and 168),
  advance_days integer not null default 30 check (advance_days between 1 and 90),
  grace_minutes integer not null default 15 check (grace_minutes between 0 and 120),
  closed_days integer[] not null default '{}',
  check (opens_at < closes_at), check (closed_days <@ array[1,2,3,4,5,6,7])
);
create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid references public.members(id) on delete restrict,
  bay_id uuid, technician_id uuid,
  customer_name text not null, phone text not null default '', vehicle_plate text not null default '',
  service_ids uuid[] not null, items jsonb not null,
  starts_at timestamptz not null, duration_minutes integer not null check (duration_minutes between 15 and 1440),
  estimate numeric(12,2) not null check (estimate >= 0),
  status text not null default 'waiting' check (status in ('waiting','arrived','done','cancelled')),
  note text not null default '' check (length(note) <= 200),
  cancel_reason text not null default '' check (length(cancel_reason) <= 200),
  request_id text not null, arrived_at timestamptz, completed_at timestamptz, cancelled_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(store_id, request_id)
);
create index appointments_store_time_idx on public.appointments(store_id, starts_at);
create table public.appointment_resources (
  id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id) on delete cascade,
  kind text not null check (kind in ('bay','technician')), name text not null check (length(trim(name)) between 1 and 30),
  phone text not null default '' check (phone='' or phone ~ '^1[3-9][0-9]{9}$'),
  category text not null default '', active boolean not null default true,
  linked_id uuid references public.appointment_resources(id) on delete restrict,
  joined_on date, online boolean not null default false,
  position integer not null default 0 check (position between 0 and 100),
  created_at timestamptz not null default now(), unique(store_id,kind,name)
);
create unique index appointment_resource_phone_idx on public.appointment_resources(store_id,kind,phone) where phone<>'';
alter table public.appointments add foreign key(bay_id) references public.appointment_resources(id) on delete restrict;
alter table public.appointments add foreign key(technician_id) references public.appointment_resources(id) on delete restrict;
alter table public.orders add column appointment_id uuid references public.appointments(id) on delete restrict;
create unique index orders_appointment_idx on public.orders(appointment_id) where appointment_id is not null;
do $$ declare t text; begin
  foreach t in array array['appointment_settings','appointments','appointment_resources'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('create policy %I on public.%I for select to authenticated using (exists
      (select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())))',t||'_owner',t);
    execute format('revoke all on public.%I from public,anon,authenticated',t);
    execute format('grant select on public.%I to authenticated',t);
    execute format('grant all on public.%I to service_role',t);
  end loop;
end $$;

create function public.appointment_assignment(p_store uuid,p_bay uuid,p_tech uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare b public.appointment_resources; t public.appointment_resources;
begin
  if p_bay is not null then
    select * into b from public.appointment_resources where id=p_bay and store_id=p_store and kind='bay' and active;
    if not found then raise exception 'resource_not_found' using errcode='P0002'; end if;
    if p_tech is null then select id into p_tech from public.appointment_resources
      where id=b.linked_id and store_id=p_store and kind='technician' and active; end if;
  end if;
  if p_tech is not null then
    select * into t from public.appointment_resources where id=p_tech and store_id=p_store and kind='technician' and active;
    if not found then raise exception 'resource_not_found' using errcode='P0002'; end if;
    if t.linked_id is not null then
      if p_bay is not null and p_bay<>t.linked_id then raise exception 'resource_assignment_conflict'; end if;
      p_bay:=t.linked_id;
      if not exists(select 1 from public.appointment_resources where id=p_bay and store_id=p_store and kind='bay' and active)
        then raise exception 'resource_not_found' using errcode='P0002'; end if;
    end if;
  end if;
  return jsonb_build_object('bay_id',p_bay,'technician_id',p_tech);
end $$;

create function public.appointment_slot_available(p_store uuid, p_start timestamptz, p_duration integer,
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
    or local_start::time < s.opens_at or local_end::date <> local_start::date or local_end::time > s.closes_at
    or extract(second from local_start) <> 0
    or mod((extract(epoch from (local_start::time-s.opens_at))/60)::integer,s.slot_minutes) <> 0 then return false; end if;
  -- 检查区间内的每个并发量变化点，连续预约不会被误算成同时占用。
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

create function public.appointment_detail(p_store uuid,p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select to_jsonb(a)||jsonb_build_object(
    'status',case when a.status='waiting' and a.starts_at+make_interval(mins=>coalesce(s.grace_minutes,15))<now()
      then 'late' else a.status end,
    'level',coalesce(c.name,'散客'),
    'bay_name',(select name from public.appointment_resources where id=a.bay_id),
    'technician_name',(select name from public.appointment_resources where id=a.technician_id))
  from public.appointments a left join public.appointment_settings s on s.store_id=a.store_id
    left join public.members m on m.id=a.member_id left join public.card_types c on c.id=m.card_type_id
  where a.store_id=p_store and a.id=p_id
$$;

create function public.appointment_board(p_store uuid,p_day date) returns jsonb
language sql stable security definer set search_path=public as $$
  select jsonb_build_object('items',coalesce(jsonb_agg(public.appointment_detail(p_store,a.id) order by a.starts_at)
    filter(where a.id is not null),'[]'::jsonb)) from public.appointments a
  where a.store_id=p_store and a.status<>'cancelled'
    and a.starts_at >= (date_trunc('week',p_day::timestamp) at time zone 'Asia/Shanghai')
    and a.starts_at < ((date_trunc('week',p_day::timestamp)+interval '7 days') at time zone 'Asia/Shanghai')
$$;

create function public.save_appointment(p_store uuid,p_input jsonb,p_request text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a public.appointments; m public.members; svc public.service_items;
  v_id uuid; v_member uuid; v_start timestamptz; v_services uuid[]; v_service uuid;
  v_minutes integer:=0; v_estimate numeric:=0; v_items jsonb:='[]'; v_plate text:='';
  assignment jsonb;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  if p_request is null or length(p_request) not between 1 and 100 then raise exception 'request_required'; end if;
  select * into a from public.appointments where store_id=p_store and request_id=p_request;
  if found then return public.appointment_detail(p_store,a.id); end if;
  insert into public.appointment_settings(store_id) values(p_store) on conflict do nothing;
  if p_input->>'id' is not null then
    select * into a from public.appointments where id=(p_input->>'id')::uuid and store_id=p_store for update;
    if not found then raise exception 'appointment_not_found' using errcode='P0002'; end if;
    if a.status<>'waiting' then raise exception 'appointment_closed'; end if;
    v_id:=a.id; v_member:=a.member_id; v_services:=a.service_ids;
  else
    v_member:=(p_input->>'member_id')::uuid;
    select array_agg(distinct x::uuid) into v_services from jsonb_array_elements_text(p_input->'service_ids') x;
  end if;
  if coalesce(cardinality(v_services),0) not between 1 and 20 then raise exception 'services_required'; end if;
  if v_member is not null then
    select * into m from public.members where id=v_member and store_id=p_store and deleted_at is null;
    if not found then raise exception 'member_not_found' using errcode='P0002'; end if;
    -- 车牌必须取本店该会员的车辆，不接受伪造的任意车牌。
    select plate into v_plate from public.member_vehicles where member_id=v_member and store_id=p_store order by created_at limit 1;
  end if;
  foreach v_service in array v_services loop
    select * into svc from public.service_items where id=v_service and store_id=p_store and active;
    if not found then raise exception 'service_not_found' using errcode='P0002'; end if;
    v_minutes:=v_minutes+svc.duration_minutes; v_estimate:=v_estimate+svc.price;
    v_items:=v_items||jsonb_build_array(jsonb_build_object('service_id',svc.id,'name',svc.name,'price',svc.price,'minutes',svc.duration_minutes));
  end loop;
  v_start:=(p_input->>'starts_at')::timestamptz;
  assignment:=public.appointment_assignment(p_store,(p_input->>'bay_id')::uuid,(p_input->>'technician_id')::uuid);
  if not public.appointment_slot_available(p_store,v_start,v_minutes,v_id,
    (p_input->>'bay_id')::uuid,(p_input->>'technician_id')::uuid) then raise exception 'slot_unavailable'; end if;
  if v_member is not null then v_estimate:=round(v_estimate*(select discount from public.card_types where id=m.card_type_id),2); end if;
  if v_id is null then
    insert into public.appointments(store_id,member_id,bay_id,technician_id,customer_name,phone,vehicle_plate,service_ids,items,starts_at,
      duration_minutes,estimate,note,request_id)
    values(p_store,v_member,(assignment->>'bay_id')::uuid,(assignment->>'technician_id')::uuid,
      case when v_member is null then '散客' else m.name end,coalesce(m.phone,''),coalesce(v_plate,''),
      v_services,v_items,v_start,v_minutes,v_estimate,coalesce(p_input->>'note',''),p_request) returning id into v_id;
  else
    update public.appointments set starts_at=v_start,duration_minutes=v_minutes,estimate=v_estimate,items=v_items,
      bay_id=(assignment->>'bay_id')::uuid,technician_id=(assignment->>'technician_id')::uuid,
      updated_at=now() where id=v_id;
  end if;
  return public.appointment_detail(p_store,v_id);
end $$;

create function public.change_appointment(p_store uuid,p_id uuid,p_action text,p_reason text default '') returns jsonb
language plpgsql security definer set search_path=public as $$
declare a public.appointments;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  select * into a from public.appointments where id=p_id and store_id=p_store for update;
  if not found then raise exception 'appointment_not_found' using errcode='P0002'; end if;
  if p_action='arrive' then
    if a.status='arrived' then return public.appointment_detail(p_store,p_id); end if;
    if a.status<>'waiting' then raise exception 'appointment_closed'; end if;
    if (a.starts_at at time zone 'Asia/Shanghai')::date > (now() at time zone 'Asia/Shanghai')::date then raise exception 'arrival_too_early'; end if;
    update public.appointments set status='arrived',arrived_at=now(),updated_at=now() where id=p_id;
  elsif p_action='cancel' then
    if a.status='cancelled' then return public.appointment_detail(p_store,p_id); end if;
    if a.status<>'waiting' then raise exception 'appointment_closed'; end if;
    if length(trim(coalesce(p_reason,''))) not between 1 and 200 then raise exception 'cancel_reason_required'; end if;
    update public.appointments set status='cancelled',cancel_reason=p_reason,cancelled_at=now(),updated_at=now() where id=p_id;
  else raise exception 'invalid_action'; end if;
  return public.appointment_detail(p_store,p_id);
end $$;

create function public.checkout_appointment(p_store uuid,p_id uuid,p_lines jsonb,p_method text,p_balance_part numeric,
  p_other text,p_plate text,p_operator text,p_request text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a public.appointments; result jsonb; prior public.orders;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  if p_request is null or length(p_request) not between 1 and 100 then raise exception 'request_required'; end if;
  select * into a from public.appointments where id=p_id and store_id=p_store for update;
  if not found then raise exception 'appointment_not_found' using errcode='P0002'; end if;
  select * into prior from public.orders where store_id=p_store and appointment_id=p_id;
  if found then
    if prior.request_id=p_request then
      return jsonb_build_object('order_id',prior.id,'payable',prior.payable,'repeated',true);
    end if;
    raise exception 'appointment_closed';
  end if;
  if a.status<>'arrived' then raise exception 'appointment_not_arrived'; end if;
  if exists(select 1 from public.orders where store_id=p_store and request_id=p_request) then raise exception 'request_reused'; end if;
  if a.member_id is null then
    result:=public.checkout_walkin(p_store,p_lines,p_method,coalesce(nullif(p_plate,''),a.vehicle_plate),'',p_operator,p_request);
  else
    result:=public.checkout_order(p_store,a.member_id,p_lines,p_method,p_balance_part,p_other,a.vehicle_plate,'',p_operator,p_request);
  end if;
  update public.orders set appointment_id=p_id where id=(result->>'order_id')::uuid;
  update public.appointments set status='done',completed_at=now(),updated_at=now() where id=p_id;
  return result;
end $$;

-- RPC 不能由匿名或客户端直接指定门店调用。
create function public.save_appointment_settings(p_store uuid,p_input jsonb) returns jsonb
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
    capacity=s.capacity,lead_hours=s.lead_hours,advance_days=s.advance_days,grace_minutes=s.grace_minutes,closed_days=s.closed_days
    where store_id=p_store;
  return to_jsonb(s);
end $$;

create function public.save_appointment_resource(p_store uuid,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare r public.appointment_resources; remaining integer;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  if p_input->>'linked_id' is not null and not exists(select 1 from public.appointment_resources
    where id=(p_input->>'linked_id')::uuid and store_id=p_store and active
      and kind=case when p_input->>'kind'='bay' then 'technician' else 'bay' end) then raise exception 'resource_not_found' using errcode='P0002'; end if;
  if p_input->>'id' is not null then
    select * into r from public.appointment_resources where id=(p_input->>'id')::uuid and store_id=p_store for update;
    if not found then raise exception 'resource_not_found' using errcode='P0002'; end if;
    if r.kind<>p_input->>'kind' then raise exception 'resource_kind_invalid'; end if;
    if (p_input->>'active')::boolean=false and exists(select 1 from public.appointments a where a.store_id=p_store
      and (a.bay_id=r.id or a.technician_id=r.id) and a.status in ('waiting','arrived')) then raise exception 'resource_busy'; end if;
    if r.kind='bay' and r.active and (p_input->>'active')::boolean=false then
      select count(*) into remaining from public.appointment_resources where store_id=p_store and kind='bay' and active and id<>r.id;
      if exists(select 1 from public.appointments a where a.store_id=p_store and a.status in ('waiting','arrived')
        and a.starts_at+make_interval(mins=>a.duration_minutes)>now() and (select count(*) from public.appointments b
          where b.store_id=p_store and b.status in ('waiting','arrived') and b.starts_at<=greatest(a.starts_at,now())
            and b.starts_at+make_interval(mins=>b.duration_minutes)>greatest(a.starts_at,now()))>remaining)
        then raise exception 'resource_busy'; end if;
    end if;
    update public.appointment_resources set name=p_input->>'name',phone=coalesce(p_input->>'phone',''),
      category=coalesce(p_input->>'category',''),position=coalesce((p_input->>'position')::integer,0),
      linked_id=(p_input->>'linked_id')::uuid,joined_on=(p_input->>'joined_on')::date,
      online=coalesce((p_input->>'online')::boolean,false),
      active=coalesce((p_input->>'active')::boolean,true) where id=r.id returning * into r;
  else
    if (select count(*) from public.appointment_resources where store_id=p_store and kind=p_input->>'kind') >=
      (case when p_input->>'kind'='bay' then 20 else 100 end) then raise exception 'resource_limit'; end if;
    insert into public.appointment_resources(store_id,kind,name,phone,category,position,linked_id,joined_on,online,active)
      values(p_store,p_input->>'kind',p_input->>'name',coalesce(p_input->>'phone',''),coalesce(p_input->>'category',''),
        coalesce((p_input->>'position')::integer,0),(p_input->>'linked_id')::uuid,(p_input->>'joined_on')::date,
        coalesce((p_input->>'online')::boolean,false),coalesce((p_input->>'active')::boolean,true)) returning * into r;
  end if;
  return to_jsonb(r);
end $$;

create function public.appointment_slots(p_store uuid,p_day date,p_services uuid[],p_exclude uuid default null,
  p_bay uuid default null,p_tech uuid default null) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.appointment_settings; minutes integer; slots jsonb;
begin
  select * into s from public.appointment_settings where store_id=p_store;
  select sum(duration_minutes) into minutes from public.service_items
    where store_id=p_store and id=any(p_services) and active;
  if minutes is null or cardinality(p_services)<>(select count(*) from public.service_items
    where store_id=p_store and id=any(p_services) and active) then raise exception 'service_not_found'; end if;
  select coalesce(jsonb_agg(jsonb_build_object('time',to_char(t at time zone 'Asia/Shanghai','HH24:MI'),
    'available',public.appointment_slot_available(p_store,t,minutes,p_exclude,p_bay,p_tech)) order by t),'[]'::jsonb)
    into slots from generate_series((p_day+s.opens_at) at time zone 'Asia/Shanghai',
      ((p_day+s.closes_at) at time zone 'Asia/Shanghai')-make_interval(mins=>minutes),make_interval(mins=>s.slot_minutes)) t;
  return jsonb_build_object('slots',slots,'duration_minutes',minutes);
end $$;

create function public.appointment_resource_list(p_store uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select coalesce(jsonb_agg(to_jsonb(r)||jsonb_build_object(
    'month_orders',(select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=r.id
        and o.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),
    'busy',exists(select 1 from public.appointments a where a.store_id=p_store and a.status='arrived'
      and (a.bay_id=r.id or a.technician_id=r.id) and a.starts_at<=now()
      and a.starts_at+make_interval(mins=>a.duration_minutes)>now())
  ) order by r.position,r.created_at),'[]'::jsonb) from public.appointment_resources r where r.store_id=p_store
$$;

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace='public'::regnamespace
    and proname in ('appointment_assignment','appointment_slot_available','appointment_detail','appointment_board','save_appointment','change_appointment','checkout_appointment',
      'save_appointment_settings','save_appointment_resource','appointment_slots','appointment_resource_list') loop
    execute format('revoke all on function %s from public,anon,authenticated',f.signature);
    execute format('grant execute on function %s to service_role',f.signature);
  end loop;
end $$;
