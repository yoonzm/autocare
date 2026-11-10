-- 售卡经营统计：只允许云函数在鉴权和门店解析后调用，不受 REST 行数上限影响。
create index if not exists member_packages_store_purchased_idx
  on public.member_packages(store_id, purchased_at);

create or replace function public.merchant_package_stats(p_store uuid, p_at timestamptz default now())
returns jsonb
language sql stable security definer
set search_path = public
as $$
  with bounds as (
    select date_trunc('month', p_at at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai' as month_start,
      (date_trunc('month', p_at at time zone 'Asia/Shanghai') - interval '1 month') at time zone 'Asia/Shanghai' as prev_start
  ), cards as materialized (
    select * from public.member_packages where store_id = p_store and purchased_at <= p_at
  ), amounts as (
    select
      coalesce(sum(price_paid) filter (where purchased_at >= b.month_start and purchased_at <= p_at), 0)
        - coalesce(sum(refund_amount) filter (where refunded_at >= b.month_start and refunded_at <= p_at), 0) as revenue,
      coalesce(sum(price_paid) filter (where purchased_at >= b.prev_start and purchased_at < b.month_start), 0)
        - coalesce(sum(refund_amount) filter (where refunded_at >= b.prev_start and refunded_at < b.month_start), 0) as previous_revenue,
      count(*) filter (where purchased_at >= b.month_start and purchased_at <= p_at) as sold_month,
      count(*) filter (where refunded_at is null and used_count < total_count
        and (expires_at is null or expires_at > p_at)) as active_count,
      count(*) filter (where refunded_at is null and used_count < total_count
        and expires_at > p_at and expires_at <= p_at + interval '7 days') as expiring_count
    from cards cross join bounds b
  ), sales as (
    select package_id, count(*) as sold from cards where purchased_at <= p_at group by package_id
  )
  select jsonb_build_object(
    'revenue', a.revenue,
    'change_percent', case when a.previous_revenue <= 0 then null
      else round((a.revenue - a.previous_revenue) * 100 / a.previous_revenue, 1) end,
    'sold_month', a.sold_month, 'active_count', a.active_count, 'expiring_count', a.expiring_count,
    'sold_by_package', coalesce((select jsonb_object_agg(package_id::text, sold) from sales), '{}'::jsonb)
  ) from amounts a
$$;
revoke all on function public.merchant_package_stats(uuid, timestamptz) from public, anon, authenticated;
grant execute on function public.merchant_package_stats(uuid, timestamptz) to service_role;
