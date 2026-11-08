-- 员工管理：员工（店长 / 前台收银 / 施工技师）、邀请、角色权限、提成方案与提成快照。
-- 所有写入仅 service_role（由 merchant-v1 Edge Function 校验后调用）；客户端只有本店店主的只读策略。
-- 技师继续以 appointment_resources(kind='technician') 参与预约排班，store_staff 通过 resource_id 关联，
-- 技师的姓名 / 手机号 / 擅长项目 / 固定工位 / 入职日期由 save_staff 同步写入两边，避免改动既有预约逻辑。

-- ───────── 服务项目的结构化提成 ─────────
alter table public.service_items
  add column if not exists commission_type text not null default 'percent' check (commission_type in ('percent','fixed')),
  add column if not exists commission_value numeric(10,2) not null default 0 check (commission_value >= 0);
-- 既有项目的提成原先只写在描述文字里（“提成 8%” / “提成 ¥60/单”），一次性解析为结构化值。
update public.service_items set commission_type='percent',
  commission_value=least(100,substring(description from '提成\s*([0-9]+(?:\.[0-9]+)?)\s*%')::numeric)
  where description ~ '提成\s*[0-9]+(\.[0-9]+)?\s*%';
update public.service_items set commission_type='fixed',
  commission_value=substring(description from '提成\s*[¥￥]\s*([0-9]+(?:\.[0-9]+)?)')::numeric
  where description ~ '提成\s*[¥￥]\s*[0-9]+(\.[0-9]+)?' and description !~ '提成\s*[0-9]+(\.[0-9]+)?\s*%';
alter table public.service_items add constraint service_items_commission_range
  check (commission_type <> 'percent' or commission_value <= 100);

-- 新建项目（含门店初始化模板）时描述里写了“提成 8%”/“提成 ¥60/单”，同步为结构化提成；
-- 之后以结构化字段为准，只在提成值仍为 0 时才从描述解析，不覆盖已设置的值。
create function public.service_commission_from_description() returns trigger language plpgsql as $$
begin
  if new.commission_value=0 then
    if new.description ~ '提成\s*[0-9]+(\.[0-9]+)?\s*%' then
      new.commission_type:='percent';
      new.commission_value:=least(100,substring(new.description from '提成\s*([0-9]+(?:\.[0-9]+)?)\s*%')::numeric);
    elsif new.description ~ '提成\s*[¥￥]\s*[0-9]+(\.[0-9]+)?' then
      new.commission_type:='fixed';
      new.commission_value:=substring(new.description from '提成\s*[¥￥]\s*([0-9]+(?:\.[0-9]+)?)')::numeric;
    end if;
  end if;
  return new;
end $$;
create trigger service_items_commission_default before insert or update of description on public.service_items
  for each row execute function public.service_commission_from_description();

-- ───────── 员工 ─────────
create table public.store_staff (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 30),
  phone text not null check (phone ~ '^1[3-9][0-9]{9}$'),
  role text not null check (role in ('manager','cashier','technician')),
  skills text not null default '' check (length(skills) <= 100),
  bay_id uuid references public.appointment_resources(id) on delete set null,
  resource_id uuid unique references public.appointment_resources(id) on delete restrict,
  joined_on date,
  -- pending：已添加、邀请尚未被员工接受；active：正常；disabled：已停用。
  status text not null default 'pending' check (status in ('pending','active','disabled')),
  activated_at timestamptz,
  -- 提成方案：follow 跟随项目设置；flat 统一比例；custom 按项目自定义（overrides: {service_id: 比例}）。
  commission_mode text not null default 'follow' check (commission_mode in ('follow','flat','custom')),
  commission_rate numeric(5,2) not null default 0 check (commission_rate between 0 and 100),
  commission_overrides jsonb not null default '{}'::jsonb,
  disabled_at timestamptz, disabled_by text not null default '', disable_reason text not null default '' check (length(disable_reason) <= 100),
  created_by text not null default '',
  created_at timestamptz not null default now(),
  check (role <> 'technician' or resource_id is not null)
);
create unique index store_staff_phone_idx on public.store_staff(store_id, phone);
create index store_staff_store_idx on public.store_staff(store_id, role, status);

-- ───────── 邀请：仅保存令牌哈希，原文只在生成时返回一次 ─────────
create table public.store_staff_invites (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid not null references public.store_staff(id) on delete cascade,
  token_hash text not null unique,
  expires_at timestamptz not null,
  created_by text not null default '',
  created_at timestamptz not null default now(),
  accepted_at timestamptz, revoked_at timestamptz
);
create index store_staff_invites_staff_idx on public.store_staff_invites(staff_id, created_at desc);

-- ───────── 角色权限（逐店、逐角色、逐权限开关）─────────
create table public.store_role_permissions (
  store_id uuid not null references public.stores(id) on delete cascade,
  role text not null check (role in ('manager','cashier','technician')),
  permission text not null,
  allowed boolean not null,
  updated_at timestamptz not null default now(),
  primary key (store_id, role, permission)
);

-- ───────── 提成快照：预约订单结算时按当时规则计算，之后规则变更不重算 ─────────
create table public.staff_commissions (
  order_id uuid not null references public.orders(id) on delete cascade,
  position int not null,
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid not null references public.store_staff(id) on delete restrict,
  appointment_id uuid references public.appointments(id) on delete set null,
  service_id uuid references public.service_items(id) on delete set null,
  base numeric(12,2) not null,
  rule text not null check (rule in ('project_percent','project_fixed','flat_percent','custom_percent')),
  rate numeric(10,2) not null,
  amount numeric(12,2) not null check (amount >= 0),
  created_at timestamptz not null default now(),
  primary key (order_id, position)
);
create index staff_commissions_staff_idx on public.staff_commissions(staff_id, created_at desc);

do $$ declare t text; begin
  foreach t in array array['store_staff','store_staff_invites','store_role_permissions','staff_commissions'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('revoke all on public.%I from public,anon,authenticated',t);
    execute format('grant all on public.%I to service_role',t);
  end loop;
  -- 邀请令牌哈希不向客户端开放；其余三张表本店店主只读。
  foreach t in array array['store_staff','store_role_permissions','staff_commissions'] loop
    execute format('create policy %I on public.%I for select to authenticated using (exists
      (select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())))',t||'_owner',t);
    execute format('grant select on public.%I to authenticated',t);
    -- 与其他门店表一致：已撤销会话、冻结、暂停或到期的账号不能直读。
    execute format('create policy platform_access on public.%I as restrictive for select to authenticated using(public.platform_session_live() and public.platform_store_access(store_id))',t);
  end loop;
end $$;

-- ───────── 既有技师回填为员工（营业中为 active，已停用为 disabled）─────────
insert into public.store_staff(store_id,name,phone,role,skills,bay_id,resource_id,joined_on,status,activated_at,created_by)
select r.store_id,r.name,r.phone,'technician',r.category,r.linked_id,r.id,r.joined_on,
  case when r.active then 'active' else 'disabled' end, case when r.active then r.created_at end,'系统迁移'
from public.appointment_resources r
where r.kind='technician' and r.phone ~ '^1[3-9][0-9]{9}$'
on conflict do nothing;

-- ───────── 权限定义与默认值 ─────────
create function public.staff_permission_keys() returns text[] language sql immutable as $$
  select array['order_view_own','order_view_all','progress_update','cashier','member_view','member_recharge_refund',
    'stock_use','stock_manage','perf_view_own','stats_view_store']
$$;
create function public.staff_permission_default(p_role text,p_permission text) returns boolean language sql immutable as $$
  select case p_role
    when 'manager' then true
    when 'cashier' then p_permission in ('order_view_all','cashier','member_view','stock_use')
    else p_permission in ('order_view_own','progress_update','member_view','stock_use','perf_view_own')
  end
$$;
-- 读取并按需补齐本店默认权限。
create function public.staff_permissions(p_store uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
begin
  insert into public.store_role_permissions(store_id,role,permission,allowed)
  select p_store,r,k,public.staff_permission_default(r,k)
  from unnest(array['manager','cashier','technician']) r, unnest(public.staff_permission_keys()) k
  on conflict do nothing;
  return (select jsonb_object_agg(role,perms) from (
    select role,jsonb_object_agg(permission,allowed) perms from public.store_role_permissions
    where store_id=p_store group by role) x);
end $$;
-- 后端统一权限校验（员工端及后续接口复用）。店主账号不经过角色，仍是全权限。
create function public.staff_has_permission(p_store uuid,p_role text,p_permission text) returns boolean
language plpgsql security definer set search_path=public as $$
begin
  if p_role='manager' then return true; end if;
  return coalesce((select allowed from public.store_role_permissions
    where store_id=p_store and role=p_role and permission=p_permission),
    public.staff_permission_default(p_role,p_permission));
end $$;
create function public.save_staff_permissions(p_store uuid,p_role text,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare k text; v jsonb;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,1));
  if p_role not in ('cashier','technician') then raise exception 'role_locked'; end if;
  if jsonb_typeof(p_input) <> 'object' then raise exception 'permission_invalid'; end if;
  perform public.staff_permissions(p_store);
  for k,v in select * from jsonb_each(p_input) loop
    if k<>all(public.staff_permission_keys()) or jsonb_typeof(v)<>'boolean' then raise exception 'permission_invalid'; end if;
    update public.store_role_permissions set allowed=(v#>>'{}')::boolean,updated_at=now()
      where store_id=p_store and role=p_role and permission=k;
  end loop;
  return public.staff_permissions(p_store);
end $$;

-- ───────── 员工视图 ─────────
create function public.staff_json(p_store uuid,p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select to_jsonb(s)-'resource_id'||jsonb_build_object(
    'resource_id',s.resource_id,
    'invite',(select jsonb_build_object('expires_at',i.expires_at,'created_at',i.created_at,
        'expired',i.expires_at<=now()) from public.store_staff_invites i
      where i.staff_id=s.id and i.accepted_at is null and i.revoked_at is null order by i.created_at desc limit 1),
    'month_orders',coalesce((select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id
        and o.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0),
    'month_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id
        and c.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0),
    'total_orders',coalesce((select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id),0),
    'total_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id),0),
    'busy',exists(select 1 from public.appointments a where a.store_id=p_store and a.status='arrived'
      and a.technician_id=s.resource_id and a.starts_at<=now() and a.starts_at+make_interval(mins=>a.duration_minutes)>now()),
    'bay_name',(select b.name from public.appointment_resources b where b.id=s.bay_id)
  ) from public.store_staff s where s.id=p_id and s.store_id=p_store
$$;
create function public.staff_list(p_store uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select jsonb_build_object(
    'staff',coalesce((select jsonb_agg(public.staff_json(p_store,s.id) order by s.status='disabled',s.created_at) from public.store_staff s where s.store_id=p_store),'[]'::jsonb),
    'permissions',public.staff_permissions(p_store),
    'services',coalesce((select jsonb_agg(jsonb_build_object('id',v.id,'name',v.name,'commission_type',v.commission_type,
      'commission_value',v.commission_value) order by v.created_at) from public.service_items v where v.store_id=p_store and v.active),'[]'::jsonb),
    'bays',coalesce((select jsonb_agg(jsonb_build_object('id',b.id,'name',b.name) order by b.position,b.created_at)
      from public.appointment_resources b where b.store_id=p_store and b.kind='bay' and b.active),'[]'::jsonb))
$$;
-- 进行中 / 待到店的预约（停用与转交用）。
create function public.staff_open_work(p_store uuid,p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select coalesce(jsonb_agg(jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'customer',a.customer_name,'status',a.status,
    'starts_at',a.starts_at,'duration_minutes',a.duration_minutes,'items',a.items,'bay_id',a.bay_id,
    'bay_name',(select b.name from public.appointment_resources b where b.id=a.bay_id)) order by a.starts_at),'[]'::jsonb)
  from public.appointments a join public.store_staff s on s.resource_id=a.technician_id
  where s.id=p_id and s.store_id=p_store and a.store_id=p_store and a.status in ('waiting','arrived')
$$;
create function public.staff_detail(p_store uuid,p_id uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare r jsonb;
begin
  r:=public.staff_json(p_store,p_id);
  if r is null then raise exception 'staff_not_found' using errcode='P0002'; end if;
  return r||jsonb_build_object('open_work',public.staff_open_work(p_store,p_id),
    'recent',(public.staff_records(p_store,p_id,'recent')->'rows'),
    'last_month_commission',(public.staff_records(p_store,p_id,'last')->'summary'->'commission'),
    'services',coalesce((select jsonb_agg(jsonb_build_object('id',v.id,'name',v.name,'commission_type',v.commission_type,
      'commission_value',v.commission_value) order by v.created_at) from public.service_items v where v.store_id=p_store and v.active),'[]'::jsonb));
end $$;

-- ───────── 施工记录：range = month | last | all | recent ─────────
create function public.staff_records(p_store uuid,p_id uuid,p_range text) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; m0 timestamptz; m1 timestamptz; rows jsonb; summary jsonb;
begin
  select * into s from public.store_staff where id=p_id and store_id=p_store;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  if p_range not in ('month','last','all','recent') then raise exception 'range_invalid'; end if;
  m0:=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  m1:=null;
  if p_range='last' then m1:=m0; m0:=(date_trunc('month',now() at time zone 'Asia/Shanghai')-interval '1 month') at time zone 'Asia/Shanghai';
  elsif p_range in ('all','recent') then m0:='-infinity'; end if;
  select coalesce(jsonb_agg(x order by (x->>'at') desc),'[]'::jsonb) into rows from (
    select jsonb_build_object('appointment_id',a.id,'plate',a.vehicle_plate,'status',a.status,
      'service',(select string_agg(i->>'name',' · ') from jsonb_array_elements(a.items) i),
      'at',coalesce(a.completed_at,a.arrived_at,a.starts_at),
      'commission',(select sum(c.amount) from public.staff_commissions c join public.orders o on o.id=c.order_id
        where o.appointment_id=a.id and c.staff_id=s.id)) x
    from public.appointments a
    where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('arrived','done')
      and coalesce(a.completed_at,a.arrived_at,a.starts_at)>=m0 and (m1 is null or coalesce(a.completed_at,a.arrived_at,a.starts_at)<m1)
    order by coalesce(a.completed_at,a.arrived_at,a.starts_at) desc limit (case when p_range='recent' then 3 else 200 end)) q;
  select jsonb_build_object(
    'orders',(select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id and o.created_at>=m0 and (m1 is null or o.created_at<m1)),
    'commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id
      and c.created_at>=m0 and (m1 is null or c.created_at<m1)),0),
    'avg_hours',(select round(avg(extract(epoch from (a.completed_at-a.arrived_at))/3600)::numeric,1)
      from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status='done'
        and a.arrived_at is not null and a.completed_at>=m0 and (m1 is null or a.completed_at<m1))) into summary;
  return jsonb_build_object('summary',summary,'rows',rows);
end $$;

-- ───────── 新增 / 编辑员工 ─────────
create function public.save_staff(p_store uuid,p_input jsonb,p_operator text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; found_staff boolean:=false; old_resource uuid; res jsonb; rid uuid; role_new text:=p_input->>'role'; bay uuid:=nullif(p_input->>'bay_id','')::uuid;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,2));
  if role_new not in ('manager','cashier','technician') then raise exception 'role_invalid'; end if;
  if bay is not null and not exists(select 1 from public.appointment_resources where id=bay and store_id=p_store and kind='bay' and active)
    then raise exception 'resource_not_found' using errcode='P0002'; end if;
  if p_input->>'id' is not null then
    select * into s from public.store_staff where id=(p_input->>'id')::uuid and store_id=p_store for update;
    if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
    found_staff:=true; old_resource:=s.resource_id;
    if s.status='disabled' then raise exception 'staff_disabled'; end if;
    if s.role='technician' and role_new<>'technician' then
      if exists(select 1 from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('waiting','arrived'))
        then raise exception 'staff_has_open_work'; end if;
      update public.appointment_resources set active=false where id=s.resource_id;
    end if;
  end if;
  if role_new='technician' then
    res:=public.save_appointment_resource(p_store,jsonb_build_object(
      'id',old_resource,'kind','technician','name',p_input->>'name','phone',p_input->>'phone',
      'category',coalesce(p_input->>'skills',''),'linked_id',bay,'joined_on',p_input->>'joined_on','active',true,
      'position',coalesce((select position from public.appointment_resources where id=old_resource),0)));
    rid:=(res->>'id')::uuid;
  else rid:=null; end if;
  if not found_staff then
    insert into public.store_staff(store_id,name,phone,role,skills,bay_id,resource_id,joined_on,created_by)
      values(p_store,trim(p_input->>'name'),p_input->>'phone',role_new,coalesce(p_input->>'skills',''),
        case when role_new='technician' then bay end,rid,nullif(p_input->>'joined_on','')::date,coalesce(p_operator,''))
      returning * into s;
  else
    update public.store_staff set name=trim(p_input->>'name'),phone=p_input->>'phone',role=role_new,
      skills=case when role_new='technician' then coalesce(p_input->>'skills','') else '' end,
      bay_id=case when role_new='technician' then bay end,
      resource_id=case when role_new='technician' then rid else resource_id end,
      joined_on=nullif(p_input->>'joined_on','')::date where id=s.id returning * into s;
  end if;
  return public.staff_json(p_store,s.id);
end $$;

-- ───────── 邀请 ─────────
create function public.create_staff_invite(p_store uuid,p_staff uuid,p_hash text,p_operator text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; i public.store_staff_invites;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,2));
  select * into s from public.store_staff where id=p_staff and store_id=p_store for update;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  if s.status<>'pending' then raise exception 'invite_not_needed'; end if;
  update public.store_staff_invites set revoked_at=now() where staff_id=p_staff and accepted_at is null and revoked_at is null;
  insert into public.store_staff_invites(store_id,staff_id,token_hash,expires_at,created_by)
    values(p_store,p_staff,p_hash,now()+interval '7 days',coalesce(p_operator,'')) returning * into i;
  return jsonb_build_object('expires_at',i.expires_at,'phone',s.phone,'name',s.name);
end $$;

-- ───────── 停用 / 启用 / 转交 ─────────
-- p_transfer_to 为接手技师（store_staff.id）。停用技师时：未提供则必须没有进行中 / 待到店预约。
create function public.set_staff_status(p_store uuid,p_staff uuid,p_status text,p_reason text,p_transfer_to uuid,p_operator text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; t public.store_staff; ap record; open_count int;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,2));
  select * into s from public.store_staff where id=p_staff and store_id=p_store for update;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  if p_status='disabled' then
    if s.status='disabled' then raise exception 'staff_state_unchanged'; end if;
    if length(coalesce(p_reason,''))>100 then raise exception 'reason_invalid'; end if;
    if s.role='technician' then
      select count(*) into open_count from public.appointments a
        where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('waiting','arrived');
      if open_count>0 then
        if p_transfer_to is null then raise exception 'staff_has_open_work'; end if;
        select * into t from public.store_staff where id=p_transfer_to and store_id=p_store and role='technician'
          and status<>'disabled' and id<>s.id;
        if not found then raise exception 'transfer_target_invalid'; end if;
        for ap in select * from public.appointments where store_id=p_store and technician_id=s.resource_id and status in ('waiting','arrived') for update loop
          if ap.status='waiting' and not public.appointment_slot_available(p_store,ap.starts_at,ap.duration_minutes,ap.id,ap.bay_id,t.resource_id)
            then raise exception 'slot_unavailable'; end if;
          update public.appointments set technician_id=t.resource_id,updated_at=now() where id=ap.id;
        end loop;
      end if;
      update public.appointment_resources set active=false where id=s.resource_id;
    end if;
    update public.store_staff set status='disabled',disabled_at=now(),disabled_by=coalesce(p_operator,''),
      disable_reason=coalesce(p_reason,'') where id=s.id;
  elsif p_status='enabled' then
    if s.status<>'disabled' then raise exception 'staff_state_unchanged'; end if;
    if s.role='technician' then update public.appointment_resources set active=true where id=s.resource_id; end if;
    update public.store_staff set status=case when activated_at is null then 'pending' else 'active' end,
      disabled_at=null,disabled_by='',disable_reason='' where id=s.id;
  else raise exception 'status_invalid'; end if;
  return public.staff_json(p_store,s.id);
end $$;

-- ───────── 提成方案 ─────────
create function public.save_staff_commission(p_store uuid,p_staff uuid,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; mode text:=p_input->>'mode'; rate numeric:=coalesce((p_input->>'rate')::numeric,0);
  ov jsonb:=coalesce(p_input->'overrides','{}'::jsonb); k text; v jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store for update;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  if mode not in ('follow','flat','custom') or rate<0 or rate>100 or jsonb_typeof(ov)<>'object' then raise exception 'commission_invalid'; end if;
  for k,v in select * from jsonb_each(ov) loop
    if jsonb_typeof(v)<>'number' or (v#>>'{}')::numeric not between 0 and 100
      or not exists(select 1 from public.service_items where id=k::uuid and store_id=p_store) then raise exception 'commission_invalid'; end if;
  end loop;
  update public.store_staff set commission_mode=mode,commission_rate=case when mode='flat' then rate else 0 end,
    commission_overrides=case when mode='custom' then ov else '{}'::jsonb end where id=s.id;
  return public.staff_json(p_store,s.id);
end $$;

-- ───────── 预约订单结算时计算提成 ─────────
-- checkout_appointment 先建订单再回填 appointment_id，因此在回填那一刻按订单项计算并落快照。
create function public.staff_commission_snapshot() returns trigger
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; it record; svc public.service_items; actual numeric; ratio numeric; rl text; rt numeric; amt numeric; ov jsonb;
begin
  if new.appointment_id is null or old.appointment_id is not null then return new; end if;
  select st.* into s from public.appointments a join public.store_staff st on st.resource_id=a.technician_id
    where a.id=new.appointment_id and st.store_id=new.store_id;
  if not found then return new; end if;
  ratio:=case when new.subtotal>0 then new.payable/new.subtotal else 1 end;
  for it in select * from public.order_items where order_id=new.id loop
    actual:=round(it.line_total*ratio,2);
    select * into svc from public.service_items where id=it.service_id;
    rl:=null;
    if s.commission_mode='flat' then rl:='flat_percent'; rt:=s.commission_rate;
    elsif s.commission_mode='custom' and s.commission_overrides ? coalesce(it.service_id::text,'') then
      rl:='custom_percent'; rt:=(s.commission_overrides->>it.service_id::text)::numeric;
    elsif svc.id is not null then rl:=case when svc.commission_type='fixed' then 'project_fixed' else 'project_percent' end; rt:=svc.commission_value;
    end if;
    if rl is null then continue; end if;
    amt:=case when rl='project_fixed' then round(rt*it.qty,2) else round(actual*rt/100,2) end;
    insert into public.staff_commissions(order_id,position,store_id,staff_id,appointment_id,service_id,base,rule,rate,amount)
      values(new.id,it.position,new.store_id,s.id,new.appointment_id,it.service_id,actual,rl,rt,amt) on conflict do nothing;
  end loop;
  return new;
end $$;
create trigger orders_staff_commission after update of appointment_id on public.orders
  for each row execute function public.staff_commission_snapshot();

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace='public'::regnamespace
    and proname in ('staff_permissions','staff_has_permission','save_staff_permissions','staff_json','staff_list','staff_open_work',
      'staff_detail','staff_records','save_staff','create_staff_invite','set_staff_status','save_staff_commission','staff_commission_snapshot') loop
    execute format('revoke all on function %s from public,anon,authenticated',f.signature);
    execute format('grant execute on function %s to service_role',f.signature);
  end loop;
end $$;
