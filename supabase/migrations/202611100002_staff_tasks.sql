-- 员工端（合并后的 App）：技师任务与施工进度、完工提交、业绩提成、员工消息。
-- 所有写入仅 service_role（merchant-v1 校验身份与权限后调用）。

-- ───────── 施工进度 ─────────
-- 施工节点固定四个：到店接车 → 清洗 · 打磨 → <项目>施工 → 固化 · 质检。stage = 已完成的节点数（0–4）。
create table public.appointment_work (
  appointment_id uuid primary key references public.appointments(id) on delete cascade,
  store_id uuid not null references public.stores(id) on delete cascade,
  stage integer not null default 1 check (stage between 0 and 4),
  finished_at timestamptz,
  finished_by uuid references public.store_staff(id) on delete set null,
  updated_at timestamptz not null default now()
);
alter table public.appointment_work enable row level security;
revoke all on public.appointment_work from public,anon,authenticated;
grant all on public.appointment_work to service_role;

create function public.work_progress(p_stage integer) returns integer language sql immutable as $$
  select case when p_stage<=0 then 0 when p_stage>=4 then 100 else p_stage*25+12 end
$$;

-- 预计提成：按当前提成方案和预约里的项目价格估算（实际提成在预约结算时按实收落快照）。
create function public.staff_estimate_commission(p_store uuid,p_staff uuid,p_appointment uuid) returns numeric
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; a public.appointments; it jsonb; svc public.service_items; total numeric:=0; price numeric; rate numeric; sid uuid;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  select * into a from public.appointments where id=p_appointment and store_id=p_store;
  if s.id is null or a.id is null then return 0; end if;
  for it in select * from jsonb_array_elements(a.items) loop
    price:=coalesce((it->>'price')::numeric,0);
    sid:=nullif(it->>'service_id','')::uuid;
    select * into svc from public.service_items where id=sid and store_id=p_store;
    if s.commission_mode='flat' then total:=total+price*s.commission_rate/100;
    elsif s.commission_mode='custom' and sid is not null and s.commission_overrides ? sid::text then
      total:=total+price*(s.commission_overrides->>sid::text)::numeric/100;
    elsif svc.id is not null then
      total:=total+case when svc.commission_type='fixed' then svc.commission_value else price*svc.commission_value/100 end;
    end if;
  end loop;
  return round(total,2);
end $$;

create function public.staff_task_json(p_store uuid,p_staff uuid,p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'status',a.status,'starts_at',a.starts_at,
    'duration_minutes',a.duration_minutes,'customer',a.customer_name,'note',a.note,'items',a.items,
    'level',coalesce((select c.name from public.members m join public.card_types c on c.id=m.card_type_id where m.id=a.member_id),'散客'),
    'bay_name',(select b.name from public.appointment_resources b where b.id=a.bay_id),
    'stage',coalesce(w.stage,case when a.status in ('arrived','done') then 1 else 0 end),
    'progress',public.work_progress(coalesce(w.stage,case when a.status in ('arrived','done') then 1 else 0 end)),
    'finished_at',w.finished_at,'arrived_at',a.arrived_at,'completed_at',a.completed_at,
    'est_commission',public.staff_estimate_commission(p_store,p_staff,a.id))
  from public.appointments a left join public.appointment_work w on w.appointment_id=a.id
  where a.id=p_id and a.store_id=p_store
$$;

-- 任务列表：待施工（待到店）/ 施工中 / 已完成（今日）。仅技师自己的预约。
create function public.staff_task_list(p_store uuid,p_staff uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; d0 timestamptz; d1 timestamptz; rows jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  if not found or s.role<>'technician' then raise exception 'staff_not_found' using errcode='P0002'; end if;
  d0:=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai'); d1:=d0+interval '1 day';
  select coalesce(jsonb_agg(public.staff_task_json(p_store,p_staff,a.id) order by a.starts_at),'[]'::jsonb) into rows
    from public.appointments a
    where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('waiting','arrived','done')
      and a.starts_at>=d0 and a.starts_at<d1;
  return jsonb_build_object('items',rows);
end $$;

create function public.staff_task_detail(p_store uuid,p_staff uuid,p_id uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; a public.appointments;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  select * into a from public.appointments where id=p_id and store_id=p_store;
  if s.id is null or a.id is null or a.technician_id is distinct from s.resource_id then
    raise exception 'task_not_found' using errcode='P0002';
  end if;
  return public.staff_task_json(p_store,p_staff,p_id);
end $$;

-- 更新进度：只能向前推进（已完成节点数不减少），仅施工中的任务。
create function public.staff_task_progress(p_store uuid,p_staff uuid,p_id uuid,p_stage integer) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; a public.appointments; cur integer;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_id::text,3));
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  select * into a from public.appointments where id=p_id and store_id=p_store for update;
  if s.id is null or a.id is null or a.technician_id is distinct from s.resource_id then raise exception 'task_not_found' using errcode='P0002'; end if;
  if a.status<>'arrived' then raise exception 'task_not_working'; end if;
  if p_stage is null or p_stage<1 or p_stage>3 then raise exception 'stage_invalid'; end if;
  insert into public.appointment_work(appointment_id,store_id,stage) values(p_id,p_store,1) on conflict do nothing;
  select stage into cur from public.appointment_work where appointment_id=p_id for update;
  if (select finished_at from public.appointment_work where appointment_id=p_id) is not null then raise exception 'task_finished'; end if;
  if p_stage<cur then raise exception 'stage_backward'; end if;
  update public.appointment_work set stage=p_stage,updated_at=now() where appointment_id=p_id;
  return public.staff_task_json(p_store,p_staff,p_id);
end $$;

-- 提交完工：施工中的任务标记完工，通知前台 / 店长收银与车主取车（消息）；订单与提成快照在收银结算时生成。
create function public.staff_task_finish(p_store uuid,p_staff uuid,p_id uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; a public.appointments; w public.appointment_work; r jsonb;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_id::text,3));
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  select * into a from public.appointments where id=p_id and store_id=p_store for update;
  if s.id is null or a.id is null or a.technician_id is distinct from s.resource_id then raise exception 'task_not_found' using errcode='P0002'; end if;
  if a.status<>'arrived' then raise exception 'task_not_working'; end if;
  insert into public.appointment_work(appointment_id,store_id,stage) values(p_id,p_store,1) on conflict do nothing;
  select * into w from public.appointment_work where appointment_id=p_id for update;
  if w.finished_at is not null then raise exception 'task_finished'; end if;
  update public.appointment_work set stage=4,finished_at=now(),finished_by=s.id,updated_at=now() where appointment_id=p_id;
  r:=public.staff_task_json(p_store,p_staff,p_id);
  insert into public.staff_messages(store_id,staff_id,kind,title,body,link)
    select p_store,x.id,'system','施工已完成待收银',
      coalesce(nullif(a.vehicle_plate,''),'车辆')||' '||(select string_agg(i->>'name',' · ') from jsonb_array_elements(a.items) i)||' 已由 '||s.name||' 完工。',
      'StCashQueue'
    from public.store_staff x where x.store_id=p_store and x.status='active' and x.role in ('cashier','manager');
  return r||jsonb_build_object('today_commission',coalesce((
    select sum(public.staff_estimate_commission(p_store,p_staff,b.id)) from public.appointments b
    join public.appointment_work bw on bw.appointment_id=b.id
    where b.store_id=p_store and b.technician_id=s.resource_id and bw.finished_at>=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0));
end $$;

-- ───────── 业绩提成 ─────────
create function public.staff_perf(p_store uuid,p_staff uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; m0 timestamptz; d0 timestamptz; days jsonb; rows jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  m0:=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  d0:=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  select jsonb_agg(jsonb_build_object('day',to_char(dd,'YYYY-MM-DD'),'amount',coalesce((select sum(c.amount) from public.staff_commissions c
      where c.staff_id=s.id and c.created_at>=(dd::timestamp at time zone 'Asia/Shanghai')
        and c.created_at<((dd+1)::timestamp at time zone 'Asia/Shanghai')),0)) order by dd)
    into days from (select ((now() at time zone 'Asia/Shanghai')::date-g) dd from generate_series(0,6) g) x;
  select coalesce(jsonb_agg(jsonb_build_object('service',coalesce(i.name,'服务'),'plate',coalesce(ap.vehicle_plate,o.vehicle_plate,''),
      'at',c.created_at,'amount',c.amount) order by c.created_at desc),'[]'::jsonb) into rows
    from (select * from public.staff_commissions where staff_id=s.id and created_at>=m0 order by created_at desc limit 50) c
    join public.orders o on o.id=c.order_id
    left join public.order_items i on i.order_id=c.order_id and i.position=c.position
    left join public.appointments ap on ap.id=c.appointment_id;
  return jsonb_build_object('month_commission',coalesce((select sum(amount) from public.staff_commissions where staff_id=s.id and created_at>=m0),0),
    'month_orders',(select count(distinct o.id) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id and o.created_at>=m0),
    'month_revenue',coalesce((select sum(o.payable) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id and o.created_at>=m0),0),
    'days',days,'rows',rows,'month',to_char(now() at time zone 'Asia/Shanghai','YYYY-MM'));
end $$;

-- ───────── 员工消息 ─────────
create table public.staff_messages (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid not null references public.store_staff(id) on delete cascade,
  kind text not null check (kind in ('task','arrival','system')),
  title text not null check (length(title) between 1 and 60),
  body text not null default '' check (length(body) <= 300),
  link text not null default '',
  created_at timestamptz not null default clock_timestamp(),
  read_at timestamptz
);
create index staff_messages_staff_idx on public.staff_messages(staff_id,created_at desc);
alter table public.staff_messages enable row level security;
revoke all on public.staff_messages from public,anon,authenticated;
grant all on public.staff_messages to service_role;

-- 新任务派给技师 / 车主已到店
create function public.appointment_staff_messages() returns trigger
language plpgsql security definer set search_path=public as $$
declare t public.store_staff; items text;
begin
  if new.technician_id is null then return new; end if;
  select * into t from public.store_staff where resource_id=new.technician_id and store_id=new.store_id and status<>'disabled';
  if not found then return new; end if;
  select string_agg(i->>'name',' · ') into items from jsonb_array_elements(new.items) i;
  if tg_op='INSERT' or old.technician_id is distinct from new.technician_id then
    insert into public.staff_messages(store_id,staff_id,kind,title,body,link)
      values(new.store_id,t.id,'task','新任务派给你',coalesce(nullif(new.vehicle_plate,''),'车辆')||' '||coalesce(items,'')||'，预计 '
        ||to_char(new.starts_at at time zone 'Asia/Shanghai','HH24:MI')||' 到店。','StTaskDetail:'||new.id);
  end if;
  if tg_op='UPDATE' and old.status is distinct from new.status and new.status='arrived' then
    insert into public.staff_messages(store_id,staff_id,kind,title,body,link)
      values(new.store_id,t.id,'arrival','车主已到店',new.customer_name||'的'||coalesce(nullif(new.vehicle_plate,''),'车辆')||' 已到店，可以接车。','StTaskDetail:'||new.id);
  end if;
  return new;
end $$;
create trigger appointments_staff_messages after insert or update of technician_id,status on public.appointments
  for each row execute function public.appointment_staff_messages();

-- 提成已更新
create function public.commission_staff_messages() returns trigger
language plpgsql security definer set search_path=public as $$
begin
  insert into public.staff_messages(store_id,staff_id,kind,title,body,link)
    values(new.store_id,new.staff_id,'system','提成已更新',
      '订单已结算，+¥'||trim(to_char(new.amount,'FM999999990.00'))||' 计入本月提成。','StPerf');
  return new;
end $$;
create trigger staff_commissions_messages after insert on public.staff_commissions
  for each row execute function public.commission_staff_messages();

-- 角色权限被老板调整：该角色的在职员工收到留痕消息
create or replace function public.save_staff_permissions(p_store uuid,p_role text,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare k text; v jsonb; changed boolean:=false; before boolean; after boolean;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,1));
  if p_role not in ('manager','cashier','technician') then raise exception 'role_locked'; end if;
  if jsonb_typeof(p_input) <> 'object' then raise exception 'permission_invalid'; end if;
  perform public.staff_permissions(p_store);
  for k,v in select * from jsonb_each(p_input) loop
    if k<>all(public.staff_permission_keys()) or jsonb_typeof(v)<>'boolean' then raise exception 'permission_invalid'; end if;
    if public.staff_permission_locked_off(p_role,k) then continue; end if;
    select allowed into before from public.store_role_permissions where store_id=p_store and role=p_role and permission=k;
    update public.store_role_permissions set allowed=(v#>>'{}')::boolean,updated_at=now()
      where store_id=p_store and role=p_role and permission=k;
    after:=(v#>>'{}')::boolean;
    if before is distinct from after then changed:=true; end if;
  end loop;
  if changed then
    insert into public.staff_messages(store_id,staff_id,kind,title,body,link)
      select p_store,x.id,'system','权限已调整','老板调整了「'||(case p_role when 'manager' then '店长' when 'cashier' then '前台收银' else '施工技师' end)||'」的权限，已立即生效。','StMine'
      from public.store_staff x where x.store_id=p_store and x.role=p_role and x.status='active';
  end if;
  return public.staff_permissions(p_store);
end $$;

create function public.staff_messages_list(p_store uuid,p_staff uuid,p_kind text) returns jsonb
language plpgsql stable security definer set search_path=public as $$
begin
  if not exists(select 1 from public.store_staff where id=p_staff and store_id=p_store) then raise exception 'staff_not_found' using errcode='P0002'; end if;
  if p_kind is not null and p_kind not in ('task','arrival','system') then raise exception 'kind_invalid'; end if;
  return jsonb_build_object(
    'items',coalesce((select jsonb_agg(to_jsonb(m)-'store_id'-'staff_id' order by m.created_at desc) from (
      select * from public.staff_messages where staff_id=p_staff and (p_kind is null or kind=p_kind) order by created_at desc limit 100) m),'[]'::jsonb),
    'unread',(select count(*) from public.staff_messages where staff_id=p_staff and read_at is null));
end $$;

create function public.staff_messages_read(p_store uuid,p_staff uuid,p_id uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
begin
  if not exists(select 1 from public.store_staff where id=p_staff and store_id=p_store) then raise exception 'staff_not_found' using errcode='P0002'; end if;
  update public.staff_messages set read_at=now() where staff_id=p_staff and read_at is null and (p_id is null or id=p_id);
  return jsonb_build_object('unread',(select count(*) from public.staff_messages where staff_id=p_staff and read_at is null));
end $$;

-- 工作台 / 我的：未读消息数
create or replace function public.staff_unread(p_staff uuid) returns integer
language sql stable security definer set search_path=public as $$
  select count(*)::integer from public.staff_messages where staff_id=p_staff and read_at is null
$$;

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace='public'::regnamespace
    and proname in ('work_progress','staff_estimate_commission','staff_task_json','staff_task_list','staff_task_detail','staff_task_progress',
      'staff_task_finish','staff_perf','appointment_staff_messages','commission_staff_messages','save_staff_permissions',
      'staff_messages_list','staff_messages_read','staff_unread') loop
    execute format('revoke all on function %s from public,anon,authenticated',f.signature);
    execute format('grant execute on function %s to service_role',f.signature);
  end loop;
end $$;
