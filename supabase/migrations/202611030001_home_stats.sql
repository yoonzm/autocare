-- 首页只读汇总。门店由 Edge Function 鉴权取得，RPC 仅 service_role 可执行。
create index if not exists orders_store_created_idx on public.orders(store_id, created_at);
create index if not exists member_ledger_store_created_idx on public.member_ledger(store_id, created_at);

create or replace function public.merchant_home_stats(p_store uuid)
returns jsonb
language sql stable security definer
set search_path = public
as $$
  with clock as (
    select (now() at time zone 'Asia/Shanghai')::date as today
  ), days as (
    select today - n as day from clock cross join generate_series(0, 7) n
  ), daily as (
    select d.day, count(o.id) as orders, coalesce(sum(o.payable), 0) as revenue
    from days d left join public.orders o on o.store_id = p_store
      and o.created_at >= (d.day::timestamp at time zone 'Asia/Shanghai')
      and o.created_at < ((d.day + 1)::timestamp at time zone 'Asia/Shanghai')
    group by d.day
  )
  select jsonb_build_object(
    'date', c.today,
    'revenue', t.revenue,
    'orders', t.orders,
    'new_members', (select count(*) from public.members m where m.store_id = p_store
      and m.created_at >= (c.today::timestamp at time zone 'Asia/Shanghai')
      and m.created_at < ((c.today + 1)::timestamp at time zone 'Asia/Shanghai')),
    'average', case when t.orders = 0 then 0 else round(t.revenue / t.orders, 2) end,
    'change_percent', case when prev.revenue = 0 then null
      else round((t.revenue - prev.revenue) * 100 / prev.revenue, 1) end,
    'daily_revenue', (select jsonb_agg(revenue order by day) from daily where day > c.today - 7),
    'recharge', (select coalesce(sum(l.amount), 0) from public.member_ledger l
      where l.store_id = p_store and l.kind = 'recharge'
      and l.created_at >= (c.today::timestamp at time zone 'Asia/Shanghai')
      and l.created_at < ((c.today + 1)::timestamp at time zone 'Asia/Shanghai'))
  ) from clock c join daily t on t.day = c.today join daily prev on prev.day = c.today - 7
$$;
revoke all on function public.merchant_home_stats(uuid) from public, anon, authenticated;
grant execute on function public.merchant_home_stats(uuid) to service_role;
