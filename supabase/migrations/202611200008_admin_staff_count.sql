-- 后台员工数按门店统计：含待激活/在职的店长、前台和技师，不含停用员工及店主。
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
 (select count(*) from public.store_staff st where st.store_id=s.id and st.status in ('pending','active')) staff,(select count(*) from members m where m.store_id=s.id and m.deleted_at is null) members,
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

revoke all on function public.admin_snapshot(uuid,uuid,integer) from public,anon,authenticated;
grant execute on function public.admin_snapshot(uuid,uuid,integer) to service_role;
