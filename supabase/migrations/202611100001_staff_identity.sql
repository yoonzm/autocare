-- 商家端与员工端合并为一个 App：身份（老板 / 店长 / 前台收银 / 施工技师）、首次加入确认、
-- 按身份的会话、权限目录与服务端权限校验。所有写入仅 service_role；客户端不直读这些表。

alter table public.store_staff
  add column if not exists user_id uuid references auth.users(id) on delete set null,
  add column if not exists join_confirmed_at timestamptz;
create index if not exists store_staff_user_idx on public.store_staff(user_id) where user_id is not null;
create index if not exists store_staff_phone_only_idx on public.store_staff(phone);

-- 一个登录会话当前使用的员工身份；没有记录表示以老板身份（名下门店）使用。
create table public.staff_sessions (
  session_id uuid primary key references auth.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  staff_id uuid not null references public.store_staff(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index staff_sessions_staff_idx on public.staff_sessions(staff_id);
alter table public.staff_sessions enable row level security;
revoke all on public.staff_sessions from public,anon,authenticated;
grant all on public.staff_sessions to service_role;

-- ───────── 权限目录（设计稿「权限矩阵」）─────────
-- 可在「角色权限」页配置的 10 项沿用原键名；其余键在设计稿尚未画出开关前只取角色默认值。
create or replace function public.staff_permission_keys() returns text[] language sql immutable as $$
  select array['order_view_own','order_view_all','progress_update','cashier','member_view','member_recharge_refund',
    'stock_use','stock_manage','perf_view_own','stats_view_store',
    'arrivals_today','order_submit','cash_queue','order_refund','member_lookup','member_edit','member_refund_adjust',
    'member_delete','appt_view','appt_edit','appt_settings','stock_product','catalog_manage','staff_view','staff_manage',
    'expense','export']
$$;
-- 「角色权限」页现有的 10 个开关（页面只会提交这些键）。
create function public.staff_permission_ui_keys() returns text[] language sql immutable as $$
  select array['order_view_own','order_view_all','progress_update','cashier','member_view','member_recharge_refund',
    'stock_use','stock_manage','perf_view_own','stats_view_store']
$$;
create or replace function public.staff_permission_default(p_role text,p_permission text) returns boolean language sql immutable as $$
  select case p_role
    when 'manager' then p_permission not in ('order_refund','member_refund_adjust','member_delete','staff_manage','expense','export')
    when 'cashier' then p_permission in ('order_view_all','cashier','member_view','member_recharge_refund','arrivals_today','order_submit',
      'cash_queue','member_lookup','member_edit','appt_view','appt_edit','perf_view_own')
    else p_permission in ('order_view_own','progress_update','stock_use','perf_view_own','arrivals_today','order_submit','member_lookup','appt_view')
  end
$$;
-- 设计稿标注为「—」的项：该身份不具备且不可开启，不受已保存开关影响。
create function public.staff_permission_locked_off(p_role text,p_permission text) returns boolean language sql immutable as $$
  select case p_role
    when 'technician' then p_permission in ('order_view_all','cash_queue','order_refund','member_view','member_edit','member_recharge_refund',
      'member_refund_adjust','member_delete','appt_edit','appt_settings','stock_manage','stock_product','catalog_manage','staff_view',
      'staff_manage','expense','export','stats_view_store')
    when 'cashier' then p_permission in ('order_view_own','progress_update','member_refund_adjust','member_delete','appt_settings',
      'stock_use','stock_manage','stock_product','catalog_manage','staff_view','staff_manage','expense','export','stats_view_store')
    else false
  end
$$;

-- 生效权限：老板全开；其余 = 已保存开关（缺省取默认值），再套用「不可开启」。
create function public.staff_caps(p_store uuid,p_role text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare k text; out jsonb:='{}'::jsonb; v boolean;
begin
  if p_role='owner' then
    foreach k in array public.staff_permission_keys() loop out:=out||jsonb_build_object(k,true); end loop;
    return out;
  end if;
  if p_role not in ('manager','cashier','technician') then return out; end if;
  perform public.staff_permissions(p_store);
  foreach k in array public.staff_permission_keys() loop
    v:=coalesce((select allowed from public.store_role_permissions where store_id=p_store and role=p_role and permission=k),
      public.staff_permission_default(p_role,k));
    if public.staff_permission_locked_off(p_role,k) then v:=false; end if;
    out:=out||jsonb_build_object(k,v);
  end loop;
  return out;
end $$;

-- 旧的 staff_has_permission 改为走生效权限（含不可开启）。
create or replace function public.staff_has_permission(p_store uuid,p_role text,p_permission text) returns boolean
language plpgsql security definer set search_path=public as $$
begin
  if p_role in ('owner','manager') and p_permission='*' then return true; end if;
  return coalesce((public.staff_caps(p_store,p_role)->>p_permission)::boolean,false);
end $$;

-- 保存权限：只接受目录里的键；不可开启的项忽略（保持默认），其余照存。店长权限仍由老板在应用外固定。
create or replace function public.save_staff_permissions(p_store uuid,p_role text,p_input jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare k text; v jsonb;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,1));
  if p_role not in ('manager','cashier','technician') then raise exception 'role_locked'; end if;
  if jsonb_typeof(p_input) <> 'object' then raise exception 'permission_invalid'; end if;
  perform public.staff_permissions(p_store);
  for k,v in select * from jsonb_each(p_input) loop
    if k<>all(public.staff_permission_keys()) or jsonb_typeof(v)<>'boolean' then raise exception 'permission_invalid'; end if;
    if public.staff_permission_locked_off(p_role,k) then continue; end if;
    update public.store_role_permissions set allowed=(v#>>'{}')::boolean,updated_at=now()
      where store_id=p_store and role=p_role and permission=k;
  end loop;
  return public.staff_permissions(p_store);
end $$;

-- 店长页也能保存（老板才有这个入口）：role_locked 只拦截未知角色。
create or replace function public.staff_permissions(p_store uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
begin
  insert into public.store_role_permissions(store_id,role,permission,allowed)
  select p_store,r,k,public.staff_permission_default(r,k)
  from unnest(array['manager','cashier','technician']) r, unnest(public.staff_permission_keys()) k
  on conflict do nothing;
  return (select jsonb_object_agg(role,perms) from (
    select role,jsonb_object_agg(permission,allowed) perms from public.store_role_permissions
    where store_id=p_store and permission=any(public.staff_permission_ui_keys()) group by role) x);
end $$;

-- ───────── 身份 ─────────
create function public.staff_phone_matches(p_auth_phone text,p_phone text) returns boolean language sql immutable as $$
  select p_auth_phone is not null and right(regexp_replace(p_auth_phone,'\D','','g'),11)=p_phone
$$;
-- 手机号是否有员工身份（用于员工首次验证码登录创建账号）。
create function public.staff_login_exists(p_phone text) returns boolean
language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.store_staff s join public.stores t on t.id=s.store_id
    where s.phone=p_phone and s.status in ('pending','active') and t.archived_at is null)
$$;
create function public.staff_session_valid(p_user uuid,p_session uuid) returns boolean
language sql stable security definer set search_path=public as $$
  select p_session is not null and exists(select 1 from auth.sessions where id=p_session and user_id=p_user)
$$;

create function public.staff_identities(p_user uuid,p_session uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare ph text; items jsonb:='[]'::jsonb; a public.merchant_accounts; n int; cur uuid; sel uuid;
begin
  if not public.staff_session_valid(p_user,p_session) then return jsonb_build_object('error','登录已过期','status',401); end if;
  select right(regexp_replace(coalesce(phone,''),'\D','','g'),11) into ph from auth.users where id=p_user;
  select staff_id into sel from public.staff_sessions where session_id=p_session;
  select * into a from public.merchant_accounts where owner_id=p_user;
  if a.owner_id is not null and not a.frozen then
    select count(*) into n from public.stores where owner_id=p_user and archived_at is null;
    if n>0 then
      select id into cur from public.stores where id=coalesce((select store_id from public.merchant_store_sessions where session_id=p_session),a.primary_store_id);
      items:=items||jsonb_build_array(jsonb_build_object('kind','owner','role','owner','store_id',cur,
        'store_name',(select name from public.stores where id=cur),'stores',n,'current',sel is null));
    end if;
  end if;
  items:=items||coalesce((select jsonb_agg(jsonb_build_object('kind','staff','staff_id',s.id,'role',s.role,'store_id',s.store_id,
      'store_name',t.name,'status',s.status,'current',s.id=sel,
      'hint',case when s.role='technician' then '待施工 '||coalesce((select count(*) from public.appointments ap
        where ap.technician_id=s.resource_id and ap.status in ('waiting','arrived')
          and ap.starts_at>=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')
          and ap.starts_at<(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')+interval '1 day'),0)
        else '' end) order by s.created_at)
    from public.store_staff s join public.stores t on t.id=s.store_id
    where s.phone=ph and s.status in ('pending','active') and t.archived_at is null
      and not coalesce((select frozen from public.merchant_accounts where owner_id=t.owner_id),false)),'[]'::jsonb);
  return jsonb_build_object('items',items);
end $$;

create function public.select_staff_identity(p_user uuid,p_session uuid,p_staff uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare ph text; s public.store_staff;
begin
  if not public.staff_session_valid(p_user,p_session) then return jsonb_build_object('error','登录已过期','status',401); end if;
  if p_staff is null then
    -- 回到老板身份：必须真的是店主
    if not exists(select 1 from public.merchant_accounts where owner_id=p_user and not frozen) then
      return jsonb_build_object('error','没有可用的老板身份','status',403);
    end if;
    delete from public.staff_sessions where session_id=p_session;
    return jsonb_build_object('ok',true);
  end if;
  select right(regexp_replace(coalesce(phone,''),'\D','','g'),11) into ph from auth.users where id=p_user;
  select * into s from public.store_staff where id=p_staff and phone=ph and status in ('pending','active');
  if not found then return jsonb_build_object('error','该身份不可用','status',403); end if;
  if exists(select 1 from public.stores where id=s.store_id and archived_at is not null) then
    return jsonb_build_object('error','门店已归档','status',403);
  end if;
  insert into public.staff_sessions(session_id,user_id,staff_id) values(p_session,p_user,s.id)
    on conflict(session_id) do update set staff_id=excluded.staff_id,user_id=excluded.user_id,created_at=now();
  return jsonb_build_object('ok',true,'staff_id',s.id,'role',s.role,'status',s.status);
end $$;

-- 首次用该身份登录：确认加入门店 → 账号激活（原先留作 TODO 的 staff_activate）。
create function public.staff_join_confirm(p_user uuid,p_session uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff;
begin
  select st.* into s from public.staff_sessions ss join public.store_staff st on st.id=ss.staff_id
    where ss.session_id=p_session and ss.user_id=p_user for update of st;
  if not found then return jsonb_build_object('error','请先选择身份','status',400); end if;
  if s.status='disabled' then return jsonb_build_object('error','该门店已停用你的账号','status',401); end if;
  if s.status='pending' then
    update public.store_staff set status='active',user_id=p_user,activated_at=now(),join_confirmed_at=now() where id=s.id;
    update public.store_staff_invites set accepted_at=now() where staff_id=s.id and accepted_at is null and revoked_at is null;
  end if;
  return jsonb_build_object('ok',true,'staff_id',s.id);
end $$;

-- 当前会话的身份上下文：角色、生效权限、门店名、本人资料。
create function public.staff_context(p_store uuid,p_role text,p_staff uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; t public.stores; u public.account_subscriptions;
begin
  select * into t from public.stores where id=p_store;
  select * into u from public.account_subscriptions where owner_id=t.owner_id;
  if p_staff is not null then select * into s from public.store_staff where id=p_staff; end if;
  return jsonb_build_object('role',p_role,'store_id',p_store,'store_name',t.name,'caps',public.staff_caps(p_store,p_role),
    'staff_id',p_staff,'name',coalesce(s.name,t.contact_name),'phone',coalesce(s.phone,t.phone),'joined_on',s.joined_on,
    'status',coalesce(s.status,'active'),'plan_expired',coalesce(u.ends_at<=now() or u.starts_at>now(),false),
    'plan_ends_at',u.ends_at,
    'identity_count',(case when p_role='owner' then 1 else 0 end)
      + (select count(*) from public.store_staff x join public.stores xs on xs.id=x.store_id
         where x.phone=coalesce(s.phone,t.phone) and x.status in ('pending','active') and xs.archived_at is null)
      + case when p_role<>'owner' and exists(select 1 from public.merchant_accounts m join auth.users au on au.id=m.owner_id
          where right(regexp_replace(coalesce(au.phone,''),'\D','','g'),11)=s.phone) then 1 else 0 end);
end $$;

-- ───────── 员工工作台（前台 / 技师）─────────
-- 今日数据按北京时间自然日。技师只统计自己的预约订单；前台只给笔数，不给金额。
create function public.staff_home(p_store uuid,p_staff uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; d0 timestamptz; d1 timestamptz; res jsonb; tasks jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  d0:=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai'); d1:=d0+interval '1 day';
  if s.role='technician' then
    select coalesce(jsonb_agg(jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'status',a.status,'starts_at',a.starts_at,
        'duration_minutes',a.duration_minutes,'customer',a.customer_name,'items',a.items,
        'bay_name',(select b.name from public.appointment_resources b where b.id=a.bay_id)) order by a.status<>'arrived',a.starts_at),'[]'::jsonb)
      into tasks from public.appointments a
      where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('waiting','arrived') and a.starts_at>=d0 and a.starts_at<d1;
    res:=jsonb_build_object('tasks',tasks,
      'done_today',(select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
        where o.store_id=p_store and a.technician_id=s.resource_id and o.created_at>=d0 and o.created_at<d1),
      'revenue_today',coalesce((select sum(o.payable) from public.orders o join public.appointments a on a.id=o.appointment_id
        where o.store_id=p_store and a.technician_id=s.resource_id and o.created_at>=d0 and o.created_at<d1),0),
      'commission_today',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id and c.created_at>=d0 and c.created_at<d1),0),
      'waiting',(select count(*) from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status='waiting' and a.starts_at>=d0 and a.starts_at<d1),
      'working',(select count(*) from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status='arrived' and a.starts_at>=d0 and a.starts_at<d1));
  else
    select coalesce(jsonb_agg(jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'status',a.status,'starts_at',a.starts_at,
        'customer',a.customer_name,'items',a.items) order by a.starts_at),'[]'::jsonb)
      into tasks from (select * from public.appointments where store_id=p_store and status='waiting' and starts_at>=now() and starts_at<d1
        order by starts_at limit 5) a;
    res:=jsonb_build_object('upcoming',tasks,
      'orders_today',(select count(*) from public.orders where store_id=p_store and created_at>=d0 and created_at<d1),
      'waiting',(select count(*) from public.appointments where store_id=p_store and status='waiting' and starts_at>=d0 and starts_at<d1),
      'working',(select count(*) from public.appointments where store_id=p_store and status='arrived' and starts_at>=d0 and starts_at<d1));
  end if;
  return res||jsonb_build_object('role',s.role,'name',s.name,'phone',s.phone,'joined_on',s.joined_on,
    'month_done',(select count(*) from public.orders o join public.appointments a on a.id=o.appointment_id
      where o.store_id=p_store and a.technician_id=s.resource_id
        and o.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),
    'month_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id
        and c.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0));
end $$;

-- ───────── 会话校验：同时支持老板与员工身份 ─────────
create or replace function public.platform_merchant_session(p_user uuid,p_session uuid,p_business boolean default true)
returns jsonb language plpgsql security definer set search_path=public as $$
declare s stores; a merchant_accounts;u account_subscriptions; st store_staff; ss_staff uuid;begin
 if p_session is null or not exists(select 1 from auth.sessions where id=p_session and user_id=p_user) then
 return jsonb_build_object('error','登录已过期','status',401);end if;
 select staff_id into ss_staff from staff_sessions where session_id=p_session and user_id=p_user;
 if ss_staff is not null then
  select * into st from store_staff where id=ss_staff;
  if st.id is null or st.status='disabled' then
   return jsonb_build_object('error','该门店已停用你的账号','status',401,'code','staff_disabled');end if;
  select * into s from stores where id=st.store_id;
  if s.id is null or s.archived_at is not null then return jsonb_build_object('error','门店不存在或已归档','status',403);end if;
  select * into a from merchant_accounts where owner_id=s.owner_id;
  if a.frozen then return jsonb_build_object('error','商家账号已冻结，请联系平台','status',403);end if;
  if p_business then
   if st.status='pending' then return jsonb_build_object('error','请先确认加入门店','status',403,'code','join_required');end if;
   if s.service_paused then return jsonb_build_object('error','服务已暂停，请联系老板','status',403,'code','service_paused');end if;
   select * into u from account_subscriptions where owner_id=s.owner_id;
   if u.owner_id is null or u.ends_at<=now() or u.starts_at>now() then
    return jsonb_build_object('error','门店套餐已到期，请联系老板续费','status',403,'code','plan_expired');end if;
  end if;
  return jsonb_build_object('store_id',s.id,'role',st.role,'staff_id',st.id);
 end if;
 select * into a from merchant_accounts where owner_id=p_user;
 if a.owner_id is null then return jsonb_build_object('error','门店不存在','status',403);end if;
 if a.frozen then return jsonb_build_object('error','商家账号已冻结，请联系平台','status',403);end if;
 select * into s from stores where id=coalesce((select store_id from merchant_store_sessions where session_id=p_session),a.primary_store_id) and owner_id=p_user;
 if s.id is null or s.archived_at is not null then return jsonb_build_object('error','门店不存在或已归档','status',403);end if;
 if p_business then
 if s.service_paused then return jsonb_build_object('error','服务已暂停，请联系平台','status',403);end if;
 select * into u from account_subscriptions where owner_id=p_user;
 if u.owner_id is null or u.ends_at<=now() or u.starts_at>now() then return jsonb_build_object('error','订阅已到期，请联系平台续费','status',403);end if;
 end if;return jsonb_build_object('store_id',s.id,'role','owner');
end $$;

-- 员工停用后，其登录会话立即失效（下一次请求回到登录页）。
create or replace function public.set_staff_status(p_store uuid,p_staff uuid,p_status text,p_reason text,p_transfer_to uuid,p_operator text) returns jsonb
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
    delete from public.staff_sessions where staff_id=s.id;
  elsif p_status='enabled' then
    if s.status<>'disabled' then raise exception 'staff_state_unchanged'; end if;
    if s.role='technician' then update public.appointment_resources set active=true where id=s.resource_id; end if;
    update public.store_staff set status=case when activated_at is null then 'pending' else 'active' end,
      disabled_at=null,disabled_by='',disable_reason='' where id=s.id;
  else raise exception 'status_invalid'; end if;
  return public.staff_json(p_store,s.id);
end $$;

do $$ declare f record; begin
  for f in select oid::regprocedure as signature from pg_proc where pronamespace='public'::regnamespace
    and proname in ('staff_permission_ui_keys','staff_permission_locked_off','staff_caps','staff_has_permission','save_staff_permissions',
      'staff_permissions','staff_phone_matches','staff_login_exists','staff_session_valid','staff_identities','select_staff_identity',
      'staff_join_confirm','staff_context','staff_home','set_staff_status','platform_merchant_session') loop
    execute format('revoke all on function %s from public,anon,authenticated',f.signature);
    execute format('grant execute on function %s to service_role',f.signature);
  end loop;
end $$;
