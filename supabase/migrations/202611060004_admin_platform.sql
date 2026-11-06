-- Platform operations are independent from merchant staff and customer wallets.
create table public.admin_accounts (
 id uuid primary key references auth.users(id),
 username text not null unique check (username ~ '^[a-z0-9_]{4,20}$'),
 name text not null check (length(trim(name)) between 1 and 50),
 role text not null check (role in ('superAdmin','ops')),
 enabled boolean not null default true,
 must_change boolean not null default true,
 created_at timestamptz not null default now()
);
create table public.platform_plans (
 kind text primary key check (kind in ('trial','basic','pro')),
 name text not null check (length(trim(name)) between 1 and 50),
 fee integer not null check (fee between 0 and 100000000 and fee%100=0), -- cents; existing editor accepts whole yuan
 -- Existing registration copy promises 14 days. Do not silently shorten that
 -- promise before a dynamic public offer label is connected (TODO public_offer).
 trial_days integer not null default 14 check (trial_days between 14 and 365),
 staff_limit integer check (staff_limit between 1 and 100000),
 sms boolean not null default false, export boolean not null default false,
 multi_store boolean not null default false, version integer not null default 1
);
-- Product catalogue, not fabricated merchants, payments or usage.
insert into public.platform_plans(kind,name,fee,staff_limit) values
 ('trial','试用版',0,5),('basic','基础版',59900,5),('pro','专业版',119900,null);
create table public.platform_plan_versions (
 kind text not null references public.platform_plans(kind), version integer not null,
 snapshot jsonb not null, created_at timestamptz not null default now(),
 primary key(kind,version)
);
insert into public.platform_plan_versions select kind,version,to_jsonb(p),now() from public.platform_plans p;
alter table public.stores add column account_frozen boolean not null default false,
 add column service_paused boolean not null default false;
create table public.store_subscriptions (
 store_id uuid primary key references public.stores(id) on delete cascade,
 plan text not null references public.platform_plans(kind),
 plan_version integer not null default 1,
 starts_at timestamptz not null, ends_at timestamptz not null,
 source text not null check (source in ('trial','legacy','payment','gift')),
 foreign key(plan,plan_version) references public.platform_plan_versions(kind,version)
);
-- Preserve known trials. Missing historical payment evidence remains legacy.
insert into public.store_subscriptions(store_id,plan,starts_at,ends_at,source)
 select id,plan,created_at,coalesce(trial_ends_at,created_at),
 case when plan='trial' then 'trial' else 'legacy' end from public.stores
 where plan in ('trial','basic','pro');
create table public.platform_orders (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id),
 plan text not null, plan_version integer not null, cycle text not null,
 original integer not null check(original>=0), coupon integer not null default 0 check(coupon>=0 and coupon<=original),
 refunded integer not null default 0 check(refunded>=0 and refunded<=original-coupon),
 status text not null check(status in ('pending','paid','cancelled','refunded')),
 pay text not null default '', starts_at timestamptz not null, ends_at timestamptz not null,
 created_at timestamptz not null default now(), paid_at timestamptz,
 foreign key(plan,plan_version) references public.platform_plan_versions(kind,version),
 check(ends_at>starts_at), check(status not in ('paid','refunded') or paid_at is not null)
);
create table public.platform_refunds (
 id uuid primary key default gen_random_uuid(), order_id uuid not null references public.platform_orders(id),
 amount integer not null check(amount>0), status text not null check(status in ('pending','processing','succeeded','failed')),
 created_at timestamptz not null default now(), completed_at timestamptz
);
create table public.merchant_follow_logs (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id) on delete cascade,
 actor_id uuid not null references public.admin_accounts(id), actor_name text not null,
 text text not null check(length(trim(text)) between 1 and 2000), created_at timestamptz not null default now()
);
create table public.support_tickets (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id),
 title text not null check(length(trim(title)) between 1 and 200),
 status text not null default 'todo' check(status in ('todo','doing','done')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.support_messages (
 id uuid primary key default gen_random_uuid(), ticket_id uuid not null references public.support_tickets(id),
 from_merchant boolean not null, actor_id uuid not null references auth.users(id),
 text text not null check(length(trim(text)) between 1 and 5000), created_at timestamptz not null default now()
);
create table public.support_requests (
 actor_id uuid not null references auth.users(id), request_id uuid not null,
 action text not null, input jsonb not null, result jsonb not null,
 primary key(actor_id,request_id)
);
create table public.admin_audit_logs (
 id uuid primary key default gen_random_uuid(), actor_id uuid references public.admin_accounts(id),
 action text not null, target text, detail jsonb not null default '{}',
 created_at timestamptz not null default now()
);
create table public.admin_requests (
 actor_id uuid not null references public.admin_accounts(id), request_id uuid not null,
 action text not null, input jsonb not null, result jsonb not null,
 created_at timestamptz not null default now(), primary key(actor_id,request_id)
);
create table public.admin_login_limits (
 key text primary key, window_start timestamptz not null, attempts integer not null
);
create index on public.platform_orders(store_id,created_at desc);
create index on public.merchant_follow_logs(store_id,created_at desc);
create index on public.support_tickets(status,created_at desc);
create index on public.support_messages(ticket_id,created_at,id);
create index on public.platform_orders(paid_at) where status in ('paid','refunded');
create index on public.platform_refunds(completed_at) where status='succeeded';
do $$ declare t text; begin
 foreach t in array array['admin_accounts','platform_plans','platform_plan_versions','store_subscriptions',
 'platform_orders','platform_refunds','merchant_follow_logs','support_tickets','support_messages','support_requests',
 'admin_audit_logs','admin_requests','admin_login_limits'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('revoke all on public.%I from public,anon,authenticated',t);
 execute format('grant select,insert,update,delete on public.%I to service_role',t);
 end loop;
end $$;

create function public.admin_login_attempt(p_key text) returns boolean
language plpgsql security definer set search_path=public as $$
declare n int; begin
 insert into admin_login_limits values(p_key,now(),1) on conflict(key) do update
 set attempts=case when admin_login_limits.window_start<now()-interval '15 minutes' then 1 else admin_login_limits.attempts+1 end,
 window_start=case when admin_login_limits.window_start<now()-interval '15 minutes' then now() else admin_login_limits.window_start end
 returning attempts into n;
 return n<=10;
end $$;

create function public.admin_identity(p_actor uuid,p_session uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a admin_accounts; begin
 if not exists(select 1 from auth.sessions where id=p_session and user_id=p_actor) then
 raise exception '登录已过期' using errcode='28000'; end if;
 select * into a from admin_accounts where id=p_actor;
 if a.id is null or not a.enabled then raise exception '无运营权限或账号已禁用' using errcode='42501'; end if;
 return to_jsonb(a)-'created_at';
end $$;

-- All critical mutations and their audit records commit together. The Edge
-- verifies the JWT; SQL rechecks membership and the live session under locks.
create function public.admin_command(p_actor uuid,p_session uuid,p_action text,p_input jsonb,p_request uuid)
returns jsonb language plpgsql security definer set search_path=public as $$
declare a admin_accounts; target uuid; s stores; sub store_subscriptions; p platform_plans;
 prev admin_requests; result jsonb := '{"ok":true}'; t support_tickets; old jsonb;
begin
 perform pg_advisory_xact_lock(hashtextextended('admin-accounts',0));
 perform admin_identity(p_actor,p_session);
 select * into a from admin_accounts where id=p_actor for update;
 if a.must_change and p_action not in ('password_changed','logout') then
 raise exception '请先修改初始或临时密码' using errcode='42501'; end if;
 if p_request is null then raise exception '缺少请求编号'; end if;
 select * into prev from admin_requests where actor_id=p_actor and request_id=p_request;
 if found then
 if prev.action<>p_action or prev.input<>p_input then raise exception '请求编号已用于其他操作' using errcode='23505'; end if;
 return prev.result||'{"replayed":true}'::jsonb;
 end if;
 if p_action in ('account_create','account_role','account_enabled','account_reset','plan_save','refund') and a.role<>'superAdmin' then
 raise exception '需要超级管理员权限' using errcode='42501'; end if;
 target := nullif(p_input->>'id','')::uuid;
 if p_action in ('merchant_extend','merchant_pause','merchant_freeze','merchant_revoke','follow_save','merchant_upgrade','merchant_send_code') then
 select * into s from stores where id=target for update;
 if s.id is null then raise exception '门店不存在' using errcode='P0002'; end if;
 select * into sub from store_subscriptions where store_id=target for update;
 old:=jsonb_build_object('frozen',s.account_frozen,'paused',s.service_paused,'expiry',sub.ends_at);
 if p_action='merchant_extend' then
 if sub.store_id is null then raise exception '门店订阅资料待核实，无法延期'; end if;
 update store_subscriptions set ends_at=greatest(now(),ends_at)+interval '7 days' where store_id=target;
 update stores set trial_ends_at=(select ends_at from store_subscriptions where store_id=target) where id=target;
 elsif p_action='merchant_pause' then update stores set service_paused=(p_input->>'value')::boolean where id=target;
 elsif p_action='merchant_freeze' then
 update stores set account_frozen=(p_input->>'value')::boolean where id=target;
 if (p_input->>'value')::boolean then delete from auth.sessions where user_id=s.owner_id; end if;
 elsif p_action='merchant_revoke' then delete from auth.sessions where user_id=s.owner_id;
 elsif p_action='follow_save' then
 insert into merchant_follow_logs(store_id,actor_id,actor_name,text) values(target,a.id,a.name,trim(p_input->>'text'));
 elsif p_action='merchant_upgrade' then
 -- TODO payment_create: no verified payment provider or offline receipt workflow.
 raise exception '套餐支付渠道尚未接通，暂不能升级；不会生成已支付订单';
 end if;
 elsif p_action='account_create' then
 insert into admin_accounts(id,username,name,role) values(target,lower(trim(p_input->>'username')),trim(p_input->>'name'),p_input->>'role');
 elsif p_action in ('account_role','account_enabled','account_reset') then
 if not exists(select 1 from admin_accounts where id=target) then raise exception '账号不存在' using errcode='P0002'; end if;
 if p_action='account_role' then update admin_accounts set role=p_input->>'role' where id=target;
 elsif p_action='account_enabled' then
 if target=a.id and not (p_input->>'value')::boolean then raise exception '不能禁用自己的账号'; end if;
 update admin_accounts set enabled=(p_input->>'value')::boolean where id=target;
 else update admin_accounts set must_change=true where id=target;
 end if;
 if not exists(select 1 from admin_accounts where role='superAdmin' and enabled) then raise exception '至少需要保留一名启用中的超级管理员'; end if;
 -- Permission changes invalidate the target's sessions too.
 delete from auth.sessions where user_id=target;
 elsif p_action='password_changed' then
 update admin_accounts set must_change=false where id=a.id;
 -- Revoke other devices; retain the verified session that changed the password.
 delete from auth.sessions where user_id=a.id and id<>p_session;
 elsif p_action='logout' then delete from auth.sessions where id=p_session and user_id=a.id;
 elsif p_action='plan_save' then
 select * into p from platform_plans where kind=p_input->>'kind' for update;
 if p.kind is null then raise exception '套餐不存在'; end if;
 old:=to_jsonb(p);
 if p.kind='trial' and (p_input->>'fee')::integer<14 then raise exception '现有注册页承诺 14 天试用，试用天数暂不能少于 14 天'; end if;
 if p.kind<>'trial' and (p_input->>'fee')::integer%100<>0 then raise exception '当前套餐年费只支持整数元'; end if;
 -- Feature flags remain configuration only until corresponding merchant
 -- capabilities are implemented; do not sell unavailable entitlements.
 if coalesce((p_input->>'sms')::boolean,false) or coalesce((p_input->>'export')::boolean,false) or coalesce((p_input->>'multi')::boolean,false) then
 raise exception '套餐短信权益、导出与多门店授权尚未接通，暂不能启用'; end if;
 update platform_plans set name=trim(p_input->>'name'),
 fee=case when kind='trial' then 0 else (p_input->>'fee')::integer end,
 trial_days=case when kind='trial' then (p_input->>'fee')::integer else trial_days end,
 staff_limit=nullif(p_input->>'staff','')::integer, sms=false,export=false,multi_store=false,version=version+1
 where kind=p.kind returning * into p;
 insert into platform_plan_versions(kind,version,snapshot) values(p.kind,p.version,to_jsonb(p));
 elsif p_action in ('ticket_reply','ticket_resolve') then
 select * into t from support_tickets where id=target for update;
 if t.id is null then raise exception '工单不存在' using errcode='P0002'; end if;
 if t.status='done' then raise exception '已解决工单不能继续回复或重复关闭'; end if;
 if p_action='ticket_reply' then
 insert into support_messages(ticket_id,from_merchant,actor_id,text) values(t.id,false,a.id,trim(p_input->>'text'));
 update support_tickets set status='doing',updated_at=now() where id=t.id;
 else update support_tickets set status='done',updated_at=now() where id=t.id;
 end if;
 elsif p_action='refund' then
 -- TODO payment_refund: require original payment reference, provider callback
 -- verification and reconciliation before recording a successful refund.
 raise exception '原路退款渠道尚未接通，未发起退款';
 else raise exception '不支持的操作'; end if;
 insert into admin_audit_logs(actor_id,action,target,detail) values(a.id,p_action,coalesce(target::text,p_input->>'kind'),
 jsonb_build_object('before',old,'request_id',p_request));
 insert into admin_requests values(a.id,p_request,p_action,p_input,result,now());
 return result;
end $$;

-- Returns a stable page of each entity; totals and dashboard aggregates never
-- depend on the page size. Client walks pages; no silent REST 1000-row truncation.
create function public.admin_snapshot(p_actor uuid,p_session uuid,p_offset integer default 0)
returns jsonb language plpgsql security definer set search_path=public as $$
declare a jsonb; month_start timestamptz:=date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai';
 week_start timestamptz:=date_trunc('week',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai';
 result jsonb; begin
 a:=admin_identity(p_actor,p_session);
 if (a->>'must_change')::boolean then raise exception '请先修改初始或临时密码' using errcode='42501'; end if;
 if p_offset<0 then raise exception '分页参数无效'; end if;
 select jsonb_build_object('me',a,'now',now(),
 'merchants',coalesce((select jsonb_agg(x) from (select s.id,s.name,s.city,s.contact_name as owner,s.phone,
 coalesce(u.plan,s.plan) plan,coalesce(u.ends_at,s.trial_ends_at,s.created_at) expiry,s.created_at opened,
 null::integer staff,(select count(*) from members m where m.store_id=s.id and m.deleted_at is null) members,
 (select coalesce(sum(original-coupon-refunded),0)/100.0 from platform_orders o where o.store_id=s.id and o.status in ('paid','refunded')) paid_total,
 (select count(*) from orders o where o.store_id=s.id and o.created_at>=month_start) month_orders,
 s.account_frozen frozen,s.service_paused paused,
 coalesce((select jsonb_agg(jsonb_build_object('date',l.created_at,'who',l.actor_name,'text',l.text) order by l.created_at desc,l.id) from merchant_follow_logs l where l.store_id=s.id),'[]') logs
 from stores s left join store_subscriptions u on u.store_id=s.id order by s.id limit 200 offset p_offset) x),'[]'),
 'orders',coalesce((select jsonb_agg(x) from (select o.id,s.name merchant,o.plan,o.cycle,o.paid_at time,
 o.original/100.0 original,o.coupon/100.0 coupon,o.refunded/100.0 refunded,o.pay,o.starts_at,o.ends_at,o.status
 from platform_orders o join stores s on s.id=o.store_id where o.status in ('paid','refunded')
 order by o.paid_at desc,o.id limit 200 offset p_offset) x),'[]'),
 'tickets',coalesce((select jsonb_agg(x) from (select t.id,t.title,s.name merchant,s.contact_name owner,t.created_at time,t.status,
 coalesce((select jsonb_agg(jsonb_build_object('from_merchant',m.from_merchant,'text',m.text) order by m.created_at,m.id) from support_messages m where m.ticket_id=t.id),'[]') msgs
 from support_tickets t join stores s on s.id=t.store_id order by t.created_at desc,t.id limit 200 offset p_offset) x),'[]'),
 'accounts',case when a->>'role'='superAdmin' then coalesce((select jsonb_agg(x) from
 (select id,username,name,role,enabled,must_change from admin_accounts order by created_at,id limit 200 offset p_offset) x),'[]') else '[]'::jsonb end,
 'plans',(select jsonb_agg(to_jsonb(p)||jsonb_build_object('merchants',(select count(*) from store_subscriptions u where u.plan=p.kind and u.ends_at>now()))) from platform_plans p),
 'stats',jsonb_build_object(
 'paid_count',(select count(*) from store_subscriptions where plan<>'trial' and ends_at>now()),
 'trial_count',(select count(*) from store_subscriptions where plan='trial' and ends_at>now()),
 'week_new',(select count(*) from stores where created_at>=week_start),
 'week_delta',(select count(*) from stores where created_at>=week_start)-(select count(*) from stores where created_at>=week_start-interval '7 days' and created_at<week_start),
 'mrr',0,
 'subs_revenue',(select coalesce(sum(original-coupon),0)/100.0 from platform_orders where paid_at>=month_start and status in ('paid','refunded')),
 'refund_total',(select coalesce(sum(amount),0)/100.0 from platform_refunds where completed_at>=month_start and status='succeeded'),
 'addon_revenue',0,'renewal_rate',null,'mrr_change',null,'revenue_change',null,
 'history',(select jsonb_agg(jsonb_build_object('month',to_char(d,'FMMM')||'月','value',
 (select coalesce(sum(original-coupon),0)/100.0 from platform_orders where paid_at>=d and paid_at<d+interval '1 month' and status in ('paid','refunded'))-
 (select coalesce(sum(amount),0)/100.0 from platform_refunds where completed_at>=d and completed_at<d+interval '1 month' and status='succeeded')) order by d)
 from generate_series(month_start-interval '5 months',month_start,interval '1 month') d)
 ),'more',p_offset+200<greatest((select count(*) from stores),(select count(*) from platform_orders where status in ('paid','refunded')),
 (select count(*) from support_tickets),case when a->>'role'='superAdmin' then (select count(*) from admin_accounts) else 0 end)) into result;
 return jsonb_set(result,'{stats}',result->'stats'||public.platform_metrics());
end $$;

create function public.platform_metrics() returns jsonb
language sql stable security definer set search_path=public as $$
 with clock as (
 select date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai' m
 ), totals as (
 select
 coalesce((select sum((o.original-o.coupon-o.refunded)/100.0*365.2425/12/extract(epoch from (o.ends_at-o.starts_at))*86400)
 from platform_orders o where o.status='paid' and o.starts_at<=now() and o.ends_at>now()),0) mrr,
 coalesce((select sum((o.original-o.coupon)/100.0*365.2425/12/extract(epoch from (o.ends_at-o.starts_at))*86400)
 from platform_orders o where o.paid_at<m and o.status in ('paid','refunded') and o.starts_at<m and o.ends_at>=m),0) prev_mrr,
 coalesce((select sum(original-coupon) from platform_orders where paid_at>=m and status in ('paid','refunded')),0)-
 coalesce((select sum(amount) from platform_refunds where completed_at>=m and status='succeeded'),0) revenue,
 coalesce((select sum(original-coupon) from platform_orders where paid_at>=m-interval '1 month' and paid_at<m and status in ('paid','refunded')),0)-
 coalesce((select sum(amount) from platform_refunds where completed_at>=m-interval '1 month' and completed_at<m and status='succeeded'),0) prev_revenue
 from clock
 ), due as (
 -- Renewal is measured for paid contract periods ending in the previous full
 -- calendar month; a subsequent paid contract must cover the previous expiry.
 select o.*,exists(select 1 from platform_orders n where n.store_id=o.store_id and n.id<>o.id
 and n.status='paid' and n.starts_at<=o.ends_at and n.ends_at>o.ends_at and n.paid_at<=o.ends_at) renewed
 from platform_orders o,clock where o.status='paid' and o.ends_at>=m-interval '1 month' and o.ends_at<m
 ) select jsonb_build_object('mrr',round(mrr,2),
 'mrr_change',case when prev_mrr=0 then null else round((mrr-prev_mrr)*100/prev_mrr,1) end,
 'revenue_change',case when prev_revenue=0 then null else round((revenue-prev_revenue)*100/abs(prev_revenue),1) end,
 'renewal_rate',(select case when count(*)=0 then null else round(count(*) filter(where renewed)*100.0/count(*),1) end from due))
 from totals;
$$;
revoke all on function public.platform_metrics() from public,anon,authenticated;
grant execute on function public.platform_metrics() to service_role;

-- New merchant trials use the published trial configuration in one transaction.
create function public.platform_store_trial() returns trigger language plpgsql security definer set search_path=public as $$
declare p platform_plans; begin
 select * into p from platform_plans where kind='trial';
 new.plan:='trial'; new.trial_ends_at:=new.created_at+make_interval(days=>p.trial_days);
 return new;
end $$;
create trigger platform_store_trial before insert on public.stores for each row execute function public.platform_store_trial();
create function public.platform_subscription_init() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into store_subscriptions(store_id,plan,plan_version,starts_at,ends_at,source)
 select new.id,'trial',version,new.created_at,new.trial_ends_at,'trial' from platform_plans where kind='trial';
 return new;
end $$;
create trigger platform_subscription_init after insert on public.stores for each row execute function public.platform_subscription_init();

-- Restrictive policies complement the existing owner SELECT policies on EVERY
-- store-scoped table; no client can bypass an Edge guard with PostgREST.
create function public.platform_session_live() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from auth.sessions where user_id=auth.uid() and id=nullif(auth.jwt()->>'session_id','')::uuid);
$$;
revoke all on function public.platform_session_live() from public,anon;
grant execute on function public.platform_session_live() to authenticated,service_role;
create function public.platform_store_access(p_store uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from stores s join store_subscriptions u on u.store_id=s.id
 where s.id=p_store and s.owner_id=auth.uid() and not s.account_frozen and not s.service_paused and u.ends_at>now());
$$;
do $$ declare r record; begin
 for r in select c.table_name from information_schema.columns c join information_schema.tables t using(table_schema,table_name)
 where c.table_schema='public' and c.column_name='store_id' and t.table_type='BASE TABLE' loop
 execute format('create policy platform_access on public.%I as restrictive for select to authenticated using(public.platform_session_live() and public.platform_store_access(store_id))',r.table_name);
 end loop;
end $$;
create policy platform_store_visible on public.stores as restrictive for select to authenticated using(not account_frozen and public.platform_session_live());

revoke all on function public.admin_login_attempt(text),public.admin_identity(uuid,uuid),
 public.admin_command(uuid,uuid,text,jsonb,uuid),public.admin_snapshot(uuid,uuid,integer),
 public.platform_store_trial(),public.platform_subscription_init() from public,anon,authenticated;
grant execute on function public.admin_login_attempt(text),public.admin_identity(uuid,uuid),
 public.admin_command(uuid,uuid,text,jsonb,uuid),public.admin_snapshot(uuid,uuid,integer) to service_role;
revoke all on function public.platform_store_access(uuid) from public,anon;
grant execute on function public.platform_store_access(uuid) to authenticated,service_role;

create function public.platform_merchant_session(p_user uuid,p_session uuid,p_business boolean default true)
returns jsonb language plpgsql security definer set search_path=public as $$
declare s stores; u store_subscriptions; begin
 if p_session is null or not exists(select 1 from auth.sessions where id=p_session and user_id=p_user) then
 return jsonb_build_object('error','登录已过期','status',401); end if;
 select * into s from stores where owner_id=p_user;
 if s.id is null then return jsonb_build_object('error','门店不存在','status',403); end if;
 if s.account_frozen then return jsonb_build_object('error','商家账号已冻结，请联系平台','status',403); end if;
 if p_business then
 if s.service_paused then return jsonb_build_object('error','服务已暂停，请联系平台','status',403); end if;
 select * into u from store_subscriptions where store_id=s.id;
 if u.store_id is null or u.ends_at<=now() then return jsonb_build_object('error','订阅已到期，请联系平台续费','status',403); end if;
 end if;
 return jsonb_build_object('store_id',s.id);
end $$;
revoke all on function public.platform_merchant_session(uuid,uuid,boolean) from public,anon,authenticated;
grant execute on function public.platform_merchant_session(uuid,uuid,boolean) to service_role;

create function public.admin_password_matches(p_actor uuid,p_session uuid,p_password text)
returns boolean language plpgsql security definer set search_path=public,extensions as $$
declare matches boolean; begin
 perform public.admin_identity(p_actor,p_session);
 select encrypted_password=crypt(p_password,encrypted_password) into matches from auth.users where id=p_actor;
 return coalesce(matches,false);
end $$;
revoke all on function public.admin_password_matches(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.admin_password_matches(uuid,uuid,text) to service_role;

-- Real merchant-side source for support tickets. No UI is added here; existing
-- merchant help UI can adopt these endpoints without inventing customer messages.
create function public.merchant_support(p_actor uuid,p_session uuid,p_action text,p_input jsonb,p_request uuid default null)
returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb; shop uuid; ticket support_tickets; prior support_requests;
 result jsonb; target uuid; off integer:=coalesce((p_input->>'offset')::integer,0);
begin
 state:=platform_merchant_session(p_actor,p_session,false);
 if state?'error' then raise exception '%',state->>'error' using errcode='42501'; end if;
 shop:=(state->>'store_id')::uuid;
 if p_action='support_list' then
 if off<0 then raise exception '分页参数无效'; end if;
 return jsonb_build_object('items',coalesce((select jsonb_agg(x) from (select id,title,status,created_at,updated_at from support_tickets
 where store_id=shop order by created_at desc,id limit 50 offset off) x),'[]'),
 'total',(select count(*) from support_tickets where store_id=shop));
 end if;
 target:=nullif(p_input->>'id','')::uuid;
 if p_action<>'support_create' then
 select * into ticket from support_tickets where id=target and store_id=shop for update;
 if ticket.id is null then raise exception '工单不存在' using errcode='P0002'; end if;
 end if;
 if p_action='support_get' then
 return jsonb_build_object('ticket',to_jsonb(ticket),'messages',coalesce((select jsonb_agg(to_jsonb(m)-'actor_id' order by created_at,id) from support_messages m where ticket_id=target),'[]'));
 end if;
 if p_action not in ('support_create','support_reply') then raise exception '不支持的操作'; end if;
 if p_request is null then raise exception '缺少请求编号'; end if;
 perform pg_advisory_xact_lock(hashtextextended('support:'||p_actor::text,0));
 select * into prior from support_requests where actor_id=p_actor and request_id=p_request;
 if found then
 if prior.action<>p_action or prior.input<>p_input then raise exception '请求编号已用于其他操作'; end if;
 return prior.result;
 end if;
 if p_action='support_create' then
 insert into support_tickets(store_id,title) values(shop,trim(p_input->>'title')) returning * into ticket;
 else
 if ticket.status='done' then raise exception '已解决工单不能继续回复'; end if;
 update support_tickets set updated_at=now() where id=ticket.id;
 end if;
 insert into support_messages(ticket_id,from_merchant,actor_id,text) values(ticket.id,true,p_actor,trim(p_input->>'text'));
 result:=jsonb_build_object('id',ticket.id);
 insert into support_requests values(p_actor,p_request,p_action,p_input,result);
 return result;
end $$;
revoke all on function public.merchant_support(uuid,uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function public.merchant_support(uuid,uuid,text,jsonb,uuid) to service_role;
