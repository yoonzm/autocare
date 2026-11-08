-- Account subscriptions are authoritative. store_subscriptions remains a
-- compatibility mirror for legacy platform reports, not a separate entitlement.
alter table public.platform_plans add column store_limit integer not null default 1 check(store_limit between 1 and 1000);
update public.platform_plans set store_limit=3,multi_store=true where kind='pro';
update public.platform_plan_versions set snapshot=snapshot||jsonb_build_object('store_limit',case when kind='pro' then 3 else 1 end,'multi_store',kind='pro');
create table public.merchant_accounts (
 owner_id uuid primary key references auth.users(id) on delete cascade,
 phone text unique not null,
 primary_store_id uuid references public.stores(id),
 frozen boolean not null default false
);
insert into merchant_accounts
 select s.owner_id,coalesce(case when u.phone ~ '^86[0-9]{11}$' then '+'||u.phone when u.phone ~ '^1[0-9]{10}$' then '+86'||u.phone else nullif(u.phone,'') end,s.phone),s.id,s.account_frozen
 from stores s join auth.users u on u.id=s.owner_id;
create table public.account_subscriptions (
 owner_id uuid primary key references merchant_accounts(owner_id) on delete cascade,
 plan text not null, plan_version integer not null, starts_at timestamptz not null,
 ends_at timestamptz not null, source text not null check(source in ('trial','legacy','payment','gift')),
 foreign key(plan,plan_version) references platform_plan_versions(kind,version)
);
insert into account_subscriptions select s.owner_id,u.plan,u.plan_version,u.starts_at,u.ends_at,u.source
 from store_subscriptions u join stores s on s.id=u.store_id;
alter table stores drop constraint stores_owner_id_key;
alter table stores add column archived_at timestamptz;
create index stores_owner_idx on stores(owner_id);
create table public.merchant_store_sessions (
 session_id uuid primary key references auth.sessions(id) on delete cascade,
 store_id uuid not null references stores(id)
);
create table public.merchant_store_requests (
 owner_id uuid not null references merchant_accounts(owner_id) on delete cascade,
 request_id text not null, action text not null, input jsonb not null, result jsonb not null,
 primary key(owner_id,request_id)
);
alter table platform_orders add column owner_id uuid references merchant_accounts(owner_id);
update platform_orders o set owner_id=s.owner_id from stores s where s.id=o.store_id;
alter table platform_orders alter column owner_id set not null;

create or replace function public.platform_store_trial() returns trigger language plpgsql security definer set search_path=public as $$
declare u account_subscriptions; p platform_plans; begin
 select * into u from account_subscriptions where owner_id=new.owner_id;
 if found then new.plan:=u.plan;new.trial_ends_at:=u.ends_at;
 else
 select * into p from platform_plans where kind='trial';
 new.plan:='trial';new.trial_ends_at:=new.created_at+make_interval(days=>p.trial_days);
 end if;return new;
end $$;
create or replace function public.platform_subscription_init() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into merchant_accounts(owner_id,phone,primary_store_id) values(new.owner_id,new.phone,new.id) on conflict(owner_id) do nothing;
 insert into account_subscriptions select new.owner_id,'trial',version,new.created_at,new.trial_ends_at,'trial'
 from platform_plans where kind='trial' on conflict(owner_id) do nothing;
 insert into store_subscriptions select new.id,plan,plan_version,starts_at,ends_at,source from account_subscriptions where owner_id=new.owner_id;
 return new;
end $$;
create function public.account_subscription_sync() returns trigger language plpgsql security definer set search_path=public as $$
begin
 if pg_trigger_depth()>1 then return new;end if;
 -- Downgrades cannot silently disable arbitrary stores.
 if (select count(*) from stores where owner_id=new.owner_id and archived_at is null) >
 (select (snapshot->>'store_limit')::int from platform_plan_versions where kind=new.plan and version=new.plan_version)
 then raise exception '现有门店超过套餐上限，请先归档多余门店';end if;
 update store_subscriptions u set plan=new.plan,plan_version=new.plan_version,starts_at=new.starts_at,ends_at=new.ends_at,source=new.source
 from stores s where s.id=u.store_id and s.owner_id=new.owner_id;
 update stores set plan=new.plan,trial_ends_at=new.ends_at where owner_id=new.owner_id;
 return new;
end $$;
create trigger account_subscription_sync after update on account_subscriptions for each row execute function account_subscription_sync();
create function public.legacy_subscription_sync() returns trigger language plpgsql security definer set search_path=public as $$
declare owner uuid;begin
 if pg_trigger_depth()>1 then return new;end if;
 select owner_id into owner from stores where id=new.store_id;
 if (select count(*) from stores where owner_id=owner and archived_at is null) >
 (select (snapshot->>'store_limit')::int from platform_plan_versions where kind=new.plan and version=new.plan_version)
 then raise exception '现有门店超过套餐上限，请先归档多余门店';end if;
 update account_subscriptions set plan=new.plan,plan_version=new.plan_version,starts_at=new.starts_at,ends_at=new.ends_at,source=new.source where owner_id=owner;
 -- The nested account trigger deliberately does not recurse.
 update store_subscriptions u set plan=new.plan,plan_version=new.plan_version,starts_at=new.starts_at,ends_at=new.ends_at,source=new.source
 from stores s where s.id=u.store_id and s.owner_id=owner and u.store_id<>new.store_id;
 update stores set plan=new.plan,trial_ends_at=new.ends_at where owner_id=owner;
 return new;
end $$;
create trigger legacy_subscription_sync after update on store_subscriptions for each row execute function legacy_subscription_sync();

create or replace function public.platform_merchant_session(p_user uuid,p_session uuid,p_business boolean default true)
returns jsonb language plpgsql security definer set search_path=public as $$
declare s stores; a merchant_accounts;u account_subscriptions;begin
 if p_session is null or not exists(select 1 from auth.sessions where id=p_session and user_id=p_user) then
 return jsonb_build_object('error','登录已过期','status',401);end if;
 select * into a from merchant_accounts where owner_id=p_user;
 if a.owner_id is null then return jsonb_build_object('error','门店不存在','status',403);end if;
 if a.frozen then return jsonb_build_object('error','商家账号已冻结，请联系平台','status',403);end if;
 select * into s from stores where id=coalesce((select store_id from merchant_store_sessions where session_id=p_session),a.primary_store_id) and owner_id=p_user;
 if s.id is null or s.archived_at is not null then return jsonb_build_object('error','门店不存在或已归档','status',403);end if;
 if p_business then
 if s.service_paused then return jsonb_build_object('error','服务已暂停，请联系平台','status',403);end if;
 select * into u from account_subscriptions where owner_id=p_user;
 if u.owner_id is null or u.ends_at<=now() or u.starts_at>now() then return jsonb_build_object('error','订阅已到期，请联系平台续费','status',403);end if;
 end if;return jsonb_build_object('store_id',s.id);
end $$;
create or replace function public.platform_store_access(p_store uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from stores s join account_subscriptions u using(owner_id) join merchant_accounts a using(owner_id)
 where s.id=p_store and s.owner_id=auth.uid() and not a.frozen and not s.service_paused and s.archived_at is null and u.ends_at>now() and u.starts_at<=now()
 and s.id=coalesce((select store_id from merchant_store_sessions where session_id=nullif(auth.jwt()->>'session_id','')::uuid),a.primary_store_id));
$$;

create function public.merchant_store_directory(p_user uuid,p_session uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;u account_subscriptions;p jsonb;n int;lim int;active boolean;items jsonb;begin
 state:=platform_merchant_session(p_user,p_session,false);if state?'error' then return state;end if;
 select * into u from account_subscriptions where owner_id=p_user;
 select snapshot into p from platform_plan_versions where kind=u.plan and version=u.plan_version;
 lim:=coalesce((p->>'store_limit')::int,1);active:=u.ends_at>now() and u.starts_at<=now();
 select count(*) into n from stores where owner_id=p_user and archived_at is null;
 select coalesce(jsonb_agg(jsonb_build_object('id',s.id,'name',s.name,'status_label',case when s.service_paused then '服务已暂停' else '营业额' end,
 'revenue',merchant_home_stats(s.id)->'revenue') order by s.created_at,s.id),'[]') into items from stores s where owner_id=p_user and archived_at is null;
 return jsonb_build_object('current_store_id',state->'store_id','items',items,'can_add',active and n<lim,'used',n,'store_limit',lim,'remaining',greatest(lim-n,0),
 'add_hint',case when not active then '订阅已到期，请先续费' when n>=lim then coalesce(p->>'name',u.plan)||'最多 '||lim||' 家，已达上限' else coalesce(p->>'name',u.plan)||'最多 '||lim||' 家，还可添加 '||(lim-n)||' 家' end,
 'subscription',p||jsonb_build_object('plan',u.plan,'name',p->>'name','starts_at',u.starts_at,'ends_at',u.ends_at,'active',active,'store_limit',lim));
end $$;
create function public.merchant_store_mutate(p_user uuid,p_session uuid,p_action text,p_input jsonb,p_request text) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;a merchant_accounts;u account_subscriptions;r merchant_store_requests;s stores;target uuid;n int;lim int;v_name text;v_phone text;v_address text;result jsonb;begin
 -- One account lock serializes quota checks, creates, restores and switches.
 select * into a from merchant_accounts where owner_id=p_user for update;
 state:=platform_merchant_session(p_user,p_session,false);if state?'error' then return state;end if;
 if p_request is null or length(p_request)<1 or length(p_request)>128 then raise exception '缺少请求编号';end if;
 select * into r from merchant_store_requests where owner_id=p_user and request_id=p_request;
 if found then if r.action<>p_action or r.input<>p_input then raise exception '请求编号已用于其他操作';end if;return r.result;end if;
 target:=nullif(p_input->>'id','')::uuid;
 if p_action='switch' then
 select * into s from stores where id=target and owner_id=p_user and archived_at is null;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 insert into merchant_store_sessions values(p_session,s.id) on conflict(session_id) do update set store_id=excluded.store_id;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('archive','restore') then
 select * into s from stores where id=target and owner_id=p_user;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 if p_action='archive' then
 if s.id=a.primary_store_id then raise exception '原门店需保留供旧版本访问，暂不能归档';end if;
 if exists(select 1 from merchant_store_sessions where store_id=s.id) then raise exception '请先将使用该门店的设备切换到其他门店';end if;
 update stores set archived_at=now() where id=s.id;
 else
 select * into u from account_subscriptions where owner_id=p_user for update;
 if u.ends_at<=now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 if s.archived_at is not null and (select count(*) from stores where owner_id=p_user and archived_at is null)>=lim then raise exception '已达套餐门店上限';end if;
 if exists(select 1 from stores where owner_id=p_user and archived_at is null and id<>s.id and name=s.name) then raise exception '已有同名门店';end if;
 update stores set archived_at=null where id=s.id;
 end if;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('create','update') then
 if p_action='create' then
 target:=null; -- A supplied ID cannot bypass duplicate-name checks on creation.
 select * into u from account_subscriptions where owner_id=p_user for update;
 if u.ends_at is null or u.ends_at<=now() or u.starts_at>now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 select count(*) into n from stores where owner_id=p_user and archived_at is null;
 if n>=coalesce(lim,1) then raise exception '已达套餐门店上限，请升级套餐';end if;
 else
 target:=(state->>'store_id')::uuid;
 if p_input->>'id' is distinct from target::text then raise exception '当前门店已变化，请重新打开页面' using errcode='40001';end if;
 end if;
 v_name:=trim(coalesce(p_input->>'name',''));v_phone:=trim(coalesce(p_input->>'phone',''));v_address:=trim(coalesce(p_input->>'address',''));
 if length(v_name) not between 1 and 30 then raise exception '门店名称须为 1–30 字';end if;
 if length(v_address) not between 1 and 300 then raise exception '请选择或输入门店地址';end if;
 if v_phone<>'' and v_phone!~'^[0-9+ -]{6,20}$' then raise exception '请输入正确的门店电话';end if;
 if exists(select 1 from stores where owner_id=p_user and archived_at is null and stores.name=v_name and (target is null or id<>target)) then raise exception '已有同名门店';end if;
 if p_action='create' then
 insert into stores(owner_id,name,phone,address,contact_name,contact_role,business_types) select p_user,v_name,v_phone,v_address,contact_name,contact_role,business_types from stores where id=a.primary_store_id returning * into s;
 insert into appointment_settings(store_id) values(s.id) on conflict do nothing;
 insert into appointment_resources(store_id,kind,name,position) values(s.id,'bay','洗车工位',0),(s.id,'bay','美容工位',1),(s.id,'bay','贴膜间',2);
 else update stores set name=v_name,phone=v_phone,address=v_address where id=target returning * into s;end if;
 result:=jsonb_build_object('id',s.id);
 else raise exception '不支持的操作';end if;
 insert into merchant_store_requests values(p_user,p_request,p_action,p_input,result);return result;
end $$;

-- New entitlement/context tables are never directly writable by app clients.
do $$declare t text;begin
 foreach t in array array['merchant_accounts','account_subscriptions','merchant_store_sessions','merchant_store_requests'] loop
 execute format('alter table %I enable row level security',t);
 execute format('revoke all on %I from public,anon,authenticated',t);
 execute format('grant select,insert,update,delete on %I to service_role',t);
 end loop;
end $$;
revoke all on function merchant_store_directory(uuid,uuid),merchant_store_mutate(uuid,uuid,text,jsonb,text),account_subscription_sync(),legacy_subscription_sync() from public,anon,authenticated;
grant execute on function merchant_store_directory(uuid,uuid),merchant_store_mutate(uuid,uuid,text,jsonb,text) to service_role;

-- Admin renewals through compatibility rows update the account and all sibling rows.
create or replace function public.admin_command(p_actor uuid,p_session uuid,p_action text,p_input jsonb,p_request uuid)
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
 update merchant_accounts set frozen=(p_input->>'value')::boolean where owner_id=s.owner_id;
 update stores set account_frozen=(p_input->>'value')::boolean where owner_id=s.owner_id;
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
 if coalesce((p_input->>'sms')::boolean,false) or coalesce((p_input->>'export')::boolean,false) then
 raise exception '套餐短信权益与导出尚未接通，暂不能启用'; end if;
 update platform_plans set name=trim(p_input->>'name'),
 fee=case when kind='trial' then 0 else (p_input->>'fee')::integer end,
 trial_days=case when kind='trial' then (p_input->>'fee')::integer else trial_days end,
 staff_limit=nullif(p_input->>'staff','')::integer, sms=false,export=false,
 multi_store=coalesce((p_input->>'multi')::boolean,false),store_limit=case when coalesce((p_input->>'multi')::boolean,false) then 3 else 1 end,version=version+1
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
create or replace function public.admin_snapshot(p_actor uuid,p_session uuid,p_offset integer default 0)
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
 'plans',(select jsonb_agg(to_jsonb(p)||jsonb_build_object('merchants',(select count(*) from account_subscriptions u where u.plan=p.kind and u.ends_at>now()))) from platform_plans p),
 'stats',jsonb_build_object(
 'paid_count',(select count(*) from account_subscriptions where plan<>'trial' and ends_at>now()),
 'trial_count',(select count(*) from account_subscriptions where plan='trial' and ends_at>now()),
 'week_new',(select count(*) from merchant_accounts a join stores s on s.id=a.primary_store_id where s.created_at>=week_start),
 'week_delta',(select count(*) from merchant_accounts a join stores s on s.id=a.primary_store_id where s.created_at>=week_start)-(select count(*) from merchant_accounts a join stores s on s.id=a.primary_store_id where s.created_at>=week_start-interval '7 days' and s.created_at<week_start),
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

create or replace function public.platform_metrics() returns jsonb
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
 select o.*,exists(select 1 from platform_orders n where n.owner_id=o.owner_id and n.id<>o.id
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

create function public.platform_order_account() returns trigger language plpgsql security definer set search_path=public as $$
begin
 select owner_id into new.owner_id from stores where id=new.store_id;
 return new;
end $$;
create trigger platform_order_account before insert on platform_orders for each row execute function platform_order_account();
revoke all on function platform_order_account() from public,anon,authenticated;
