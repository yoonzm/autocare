-- 营业统计页（今日 / 本周 / 本月 / 自定义）。门店由 Edge Function 鉴权取得，RPC 仅 service_role 可执行。
-- 口径与首页 merchant_home_stats 一致：北京时间自然日；营业额 = orders.payable 之和（含余额支付，次卡抵扣后的应收）；
-- 订单数含零应收订单。对比期：今日 = 上周同日；本周 = 上周同期（周一至同一星期）；本月 = 上月同期（1 号至同一日，
-- 上月较短时截到月末）；自定义 = 紧邻其前的等长时段。
-- 项目收入构成：把每单应收按非次卡抵扣行的 line_total 占比摊到服务分类，分类合计等于有行明细订单的营业额。
-- 分类归并：镀晶镀膜 → coating；贴膜 / 改色膜 → wrap；洗车 → wash；其余（内饰、保养维修、其他、已删除服务）→ other。
-- 会员消费占比 = 有会员的订单应收 / 营业额。
create or replace function public.merchant_business_stats(
  p_store uuid, p_range text, p_from date default null, p_to date default null
) returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  v_today date := (now() at time zone 'Asia/Shanghai')::date;
  v_from date; v_to date; v_pfrom date; v_pto date;
  v_hourly boolean := false;
  v_step interval; v_n int; v_pn int;
  v_start timestamptz; v_end timestamptz; v_pstart timestamptz; v_pend timestamptz;
  v_revenue numeric; v_orders bigint; v_member numeric; v_prev numeric;
  v_cur jsonb; v_prv jsonb; v_comp jsonb;
begin
  if p_range = 'today' then
    v_from := v_today; v_to := v_today; v_pfrom := v_today - 7; v_pto := v_pfrom; v_hourly := true;
  elsif p_range = 'week' then
    v_from := date_trunc('week', v_today)::date; v_to := v_today;
    v_pfrom := v_from - 7; v_pto := v_to - 7;
  elsif p_range = 'month' then
    v_from := date_trunc('month', v_today)::date; v_to := v_today;
    v_pfrom := (v_from - interval '1 month')::date;
    v_pto := least(v_pfrom + (v_to - v_from), v_from - 1);
  elsif p_range = 'custom' then
    if p_from is null or p_to is null or p_from > p_to or p_to > v_today or p_to - p_from > 365 then
      raise exception 'invalid_range' using errcode = '22023';
    end if;
    v_from := p_from; v_to := p_to;
    v_pfrom := v_from - (v_to - v_from + 1); v_pto := v_from - 1;
  else
    raise exception 'invalid_range' using errcode = '22023';
  end if;

  v_step := case when v_hourly then interval '1 hour' else interval '1 day' end;
  v_n := case when v_hourly then 24 else v_to - v_from + 1 end;
  v_pn := case when v_hourly then 24 else v_pto - v_pfrom + 1 end;
  v_start := v_from::timestamp at time zone 'Asia/Shanghai';
  v_end := (v_to + 1)::timestamp at time zone 'Asia/Shanghai';
  v_pstart := v_pfrom::timestamp at time zone 'Asia/Shanghai';
  v_pend := (v_pto + 1)::timestamp at time zone 'Asia/Shanghai';

  select coalesce(sum(payable), 0), count(*), coalesce(sum(payable) filter (where member_id is not null), 0)
  into v_revenue, v_orders, v_member
  from public.orders where store_id = p_store and created_at >= v_start and created_at < v_end;
  select coalesce(sum(payable), 0) into v_prev
  from public.orders where store_id = p_store and created_at >= v_pstart and created_at < v_pend;

  -- 趋势：今日按小时（尚未到的小时为 null），其余按自然日（尚未到的日期为 null）；对比期超出其长度的位置为 null。
  select jsonb_agg(case when s.at <= now() then (
    select coalesce(sum(o.payable), 0) from public.orders o
    where o.store_id = p_store and o.created_at >= s.at and o.created_at < s.at + v_step) end order by s.i)
  into v_cur
  from (select i, ((v_from::timestamp + i * v_step) at time zone 'Asia/Shanghai') as at
        from generate_series(0, v_n - 1) i) s;
  select jsonb_agg(case when s.i < v_pn then (
    select coalesce(sum(o.payable), 0) from public.orders o
    where o.store_id = p_store and o.created_at >= s.at and o.created_at < s.at + v_step) end order by s.i)
  into v_prv
  from (select i, ((v_pfrom::timestamp + i * v_step) at time zone 'Asia/Shanghai') as at
        from generate_series(0, v_n - 1) i) s;

  with lines as (
    select oi.line_total, o.payable,
           sum(oi.line_total) over (partition by oi.order_id) as total,
           case when s.category = '镀晶镀膜' then 'coating'
                when s.category in ('贴膜', '改色膜') then 'wrap'
                when s.category = '洗车' then 'wash'
                else 'other' end as bucket
    from public.order_items oi
    join public.orders o on o.id = oi.order_id
    left join public.service_items s on s.id = oi.service_id
    where o.store_id = p_store and o.created_at >= v_start and o.created_at < v_end
      and oi.member_package_id is null
  ), sums as (
    select bucket, sum(payable * line_total / total) as amount
    from lines where total > 0 group by bucket
  ), whole as (
    select coalesce(sum(amount), 0) as total from sums
  )
  select jsonb_agg(jsonb_build_object(
    'key', k.key,
    'amount', round(coalesce(s.amount, 0), 2),
    'percent', case when w.total = 0 then 0 else round(coalesce(s.amount, 0) * 100 / w.total, 1) end
  ) order by k.ord)
  into v_comp
  from (values ('coating', 1), ('wrap', 2), ('wash', 3), ('other', 4)) as k(key, ord)
  left join sums s on s.bucket = k.key cross join whole w;

  return jsonb_build_object(
    'range', p_range, 'from', v_from, 'to', v_to, 'prev_from', v_pfrom, 'prev_to', v_pto,
    'revenue', round(v_revenue, 2), 'orders', v_orders,
    'change_percent', case when v_prev = 0 then null else round((v_revenue - v_prev) * 100 / v_prev, 1) end,
    'member_share', case when v_revenue = 0 then null else round(v_member * 100 / v_revenue, 1) end,
    'unit', case when v_hourly then 'hour' else 'day' end,
    'current', v_cur, 'previous', v_prv, 'composition', v_comp
  );
end $$;
revoke all on function public.merchant_business_stats(uuid, text, date, date) from public, anon, authenticated;
grant execute on function public.merchant_business_stats(uuid, text, date, date) to service_role;
