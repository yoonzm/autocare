-- Explicit user-authorized temporary payment simulation. No provider is called.
-- Orders and entitlements carry simulation provenance; cash reporting excludes them.
alter table platform_plans drop constraint platform_plans_kind_check;
alter table platform_plans add constraint platform_plans_kind_check check(kind in ('trial','basic','pro','flagship'));
alter table platform_plans add column monthly_fee integer check(monthly_fee>=0), add column quarterly_fee integer check(quarterly_fee>=0);
update platform_plans set monthly_fee=fee/10,quarterly_fee=round(fee*3*0.95/10.0)::int;
insert into platform_plans(kind,name,fee,staff_limit,multi_store,store_limit,monthly_fee,quarterly_fee)
 values('flagship','旗舰版',699000,null,true,10,69900,199215);
insert into platform_plan_versions select kind,version,to_jsonb(p),now() from platform_plans p where kind='flagship';
update platform_plan_versions v set snapshot=v.snapshot||jsonb_build_object('monthly_fee',p.monthly_fee,'quarterly_fee',p.quarterly_fee)
 from platform_plans p where p.kind=v.kind and p.version=v.version;
alter table platform_orders add column simulated boolean not null default false;
alter table account_subscriptions drop constraint account_subscriptions_source_check;
alter table account_subscriptions add constraint account_subscriptions_source_check check(source in ('trial','legacy','payment','gift','simulation'));
alter table store_subscriptions drop constraint store_subscriptions_source_check;
alter table store_subscriptions add constraint store_subscriptions_source_check check(source in ('trial','legacy','payment','gift','simulation'));
create table subscription_requests (
 owner_id uuid not null references merchant_accounts(owner_id) on delete cascade,
 request_id text not null,input jsonb not null,result jsonb not null,primary key(owner_id,request_id)
);
alter table subscription_requests enable row level security;
revoke all on subscription_requests from public,anon,authenticated;
grant all on subscription_requests to service_role;

create function subscription_catalog(p_user uuid,p_session uuid) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;u account_subscriptions;begin
 state:=platform_merchant_session(p_user,p_session,false);if state?'error' then return state;end if;
 select * into u from account_subscriptions where owner_id=p_user;
 return jsonb_build_object('plans',(select jsonb_agg(to_jsonb(p)||jsonb_build_object('features',jsonb_build_object('core',true,'appointments',true,'budgets',true,'wechat',false,'export',p.export,'chain',false,'support',false)) order by p.fee) from platform_plans p where kind<>'trial'),
 'subscription',to_jsonb(u),'revision',md5(to_jsonb(u)::text),'simulation',true);
end $$;
create function subscription_simulate(p_user uuid,p_session uuid,p_input jsonb,p_request text) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;a merchant_accounts;u account_subscriptions;p platform_plans;prior subscription_requests;
 months int;amount int;start_at timestamptz;end_at timestamptz;order_id uuid;result jsonb;begin
 select * into a from merchant_accounts where owner_id=p_user for update;
 state:=platform_merchant_session(p_user,p_session,false);if state?'error' then return state;end if;
 if p_request is null or length(p_request) not between 1 and 128 then raise exception '缺少请求编号';end if;
 select * into prior from subscription_requests where owner_id=p_user and request_id=p_request;
 if found then if prior.input<>p_input then raise exception '请求编号已用于其他操作';end if;return prior.result;end if;
 select * into u from account_subscriptions where owner_id=p_user for update;
 if p_input->>'revision' is distinct from md5(to_jsonb(u)::text) then raise exception '订阅已变化，请刷新后重试';end if;
 select * into p from platform_plans where kind=p_input->>'plan' and kind<>'trial' for share;
 if p.kind is null then raise exception '请选择有效套餐';end if;
 if (p_input->>'version')::integer is distinct from p.version then raise exception '套餐价格已更新，请刷新后重试';end if;
 months:=(p_input->>'months')::int;
 if months not in (1,3,12) or months is null then raise exception '请选择 1、3 或 12 个月';end if;
 if p_input->>'mode' not in ('subscribe','renew') or p_input->>'mode' is null then raise exception '订阅操作无效';end if;
 if p_input->>'mode'='renew' and p.kind<>u.plan then raise exception '续费须使用当前套餐';end if;
 if (select count(*) from stores where owner_id=p_user and archived_at is null)>p.store_limit then raise exception '门店数量超过所选套餐上限，请先归档多余门店';end if;
 amount:=case months when 1 then p.monthly_fee when 3 then p.quarterly_fee else p.fee end;
 if amount is null or amount<0 then raise exception '套餐价格未配置，请联系平台';end if;
 -- Retain any unexpired time; new version/rights take effect immediately.
 start_at:=case when p_input->>'mode'='renew' then greatest(now(),u.ends_at) else now() end;end_at:=greatest(now(),u.ends_at)+make_interval(months=>months);
 insert into platform_orders(store_id,owner_id,plan,plan_version,cycle,original,status,pay,starts_at,ends_at,paid_at,simulated)
 values((state->>'store_id')::uuid,p_user,p.kind,p.version,months||'个月',amount,'paid','模拟支付',start_at,end_at,now(),true) returning id into order_id;
 update account_subscriptions set plan=p.kind,plan_version=p.version,starts_at=least(now(),starts_at),ends_at=end_at,source='simulation' where owner_id=p_user;
 result:=jsonb_build_object('id',order_id,'plan',p.kind,'name',p.name,'months',months,'amount',amount,'starts_at',start_at,'ends_at',end_at,'pay','模拟支付','simulated',true,'store_limit',p.store_limit);
 insert into subscription_requests values(p_user,p_request,p_input,result);return result;
end $$;
revoke all on function subscription_catalog(uuid,uuid),subscription_simulate(uuid,uuid,jsonb,text) from public,anon,authenticated;
grant execute on function subscription_catalog(uuid,uuid),subscription_simulate(uuid,uuid,jsonb,text) to service_role;

-- Keep admin-published prices coherent when the existing annual-fee editor is used.
create function subscription_plan_prices() returns trigger language plpgsql as $$
begin
 if new.fee is distinct from old.fee then new.monthly_fee:=new.fee/10;new.quarterly_fee:=round(new.fee*3*0.95/10.0)::int;end if;
 if new.kind='flagship' and new.multi_store then new.store_limit:=10;end if;
 return new;
end $$;
create trigger subscription_plan_prices before update on platform_plans for each row execute function subscription_plan_prices();
revoke all on function subscription_plan_prices() from public,anon,authenticated;

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
 (select coalesce(sum(original-coupon-refunded),0)/100.0 from platform_orders o where not o.simulated and not o.simulated and o.store_id=s.id and o.status in ('paid','refunded')) paid_total,
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
 'subs_revenue',(select coalesce(sum(original-coupon),0)/100.0 from platform_orders where not simulated and paid_at>=month_start and status in ('paid','refunded')),
 'refund_total',(select coalesce(sum(amount),0)/100.0 from platform_refunds where completed_at>=month_start and status='succeeded'),
 'addon_revenue',0,'renewal_rate',null,'mrr_change',null,'revenue_change',null,
 'history',(select jsonb_agg(jsonb_build_object('month',to_char(d,'FMMM')||'月','value',
 (select coalesce(sum(original-coupon),0)/100.0 from platform_orders where not simulated and paid_at>=d and paid_at<d+interval '1 month' and status in ('paid','refunded'))-
 (select coalesce(sum(amount),0)/100.0 from platform_refunds where completed_at>=d and completed_at<d+interval '1 month' and status='succeeded')) order by d)
 from generate_series(month_start-interval '5 months',month_start,interval '1 month') d)
 ),'more',p_offset+200<greatest((select count(*) from stores),(select count(*) from platform_orders where not simulated and status in ('paid','refunded')),
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
 from platform_orders o where not o.simulated and o.status='paid' and o.starts_at<=now() and o.ends_at>now()),0) mrr,
 coalesce((select sum((o.original-o.coupon)/100.0*365.2425/12/extract(epoch from (o.ends_at-o.starts_at))*86400)
 from platform_orders o where not o.simulated and o.paid_at<m and o.status in ('paid','refunded') and o.starts_at<m and o.ends_at>=m),0) prev_mrr,
 coalesce((select sum(original-coupon) from platform_orders where not simulated and paid_at>=m and status in ('paid','refunded')),0)-
 coalesce((select sum(amount) from platform_refunds where completed_at>=m and status='succeeded'),0) revenue,
 coalesce((select sum(original-coupon) from platform_orders where not simulated and paid_at>=m-interval '1 month' and paid_at<m and status in ('paid','refunded')),0)-
 coalesce((select sum(amount) from platform_refunds where completed_at>=m-interval '1 month' and completed_at<m and status='succeeded'),0) prev_revenue
 from clock
 ), due as (
 -- Renewal is measured for paid contract periods ending in the previous full
 -- calendar month; a subsequent paid contract must cover the previous expiry.
 select o.*,exists(select 1 from platform_orders n where not n.simulated and n.owner_id=o.owner_id and n.id<>o.id
 and n.status='paid' and n.starts_at<=o.ends_at and n.ends_at>o.ends_at and n.paid_at<=o.ends_at) renewed
 from platform_orders o,clock where not o.simulated and o.status='paid' and o.ends_at>=m-interval '1 month' and o.ends_at<m
 ) select jsonb_build_object('mrr',round(mrr,2),
 'mrr_change',case when prev_mrr=0 then null else round((mrr-prev_mrr)*100/prev_mrr,1) end,
 'revenue_change',case when prev_revenue=0 then null else round((revenue-prev_revenue)*100/abs(prev_revenue),1) end,
 'renewal_rate',(select case when count(*)=0 then null else round(count(*) filter(where renewed)*100.0/count(*),1) end from due))
 from totals;
$$;
revoke all on function public.platform_metrics() from public,anon,authenticated;
grant execute on function public.platform_metrics() to service_role;

