-- 订单中心：把消费 / 充值 / 次卡售卖 / 退款统一成一份“营业记录”，并支持消费订单整单退款。
-- 金额、状态、退回方式都在这里的 SECURITY DEFINER 函数里算，云函数以 service_role 调用；客户端只读。
-- 口径：实收 = 微信 + 支付宝 + 现金 + POS（真正收进来的钱，充值计入实收）；
--       储值抵扣是会员用余额消费，不计入实收；净收入 = 实收 − 退款，退款按退款发生当天计入。

create sequence if not exists public.order_no_seq;

alter table public.orders
  add column if not exists status text not null default 'completed' check (status in ('completed', 'refunded')),
  add column if not exists refunded_at timestamptz,
  add column if not exists refund_reason text not null default '' check (length(refund_reason) <= 30),
  add column if not exists refund_operator text not null default '',
  add column if not exists seq bigint not null default nextval('public.order_no_seq');
alter table public.member_ledger add column if not exists seq bigint not null default nextval('public.order_no_seq');
alter table public.member_packages add column if not exists seq bigint not null default nextval('public.order_no_seq');

alter table public.member_ledger drop constraint if exists member_ledger_kind_check;
alter table public.member_ledger add constraint member_ledger_kind_check check (kind in (
  'recharge', 'adjust_points', 'adjust_card', 'upgrade',
  'consume', 'package_buy', 'package_use', 'package_extend', 'package_refund', 'order_refund'
));

create index if not exists orders_store_time_idx on public.orders(store_id, created_at desc);
create index if not exists orders_refunded_idx on public.orders(store_id, refunded_at desc) where refunded_at is not null;
create index if not exists member_packages_refunded_idx on public.member_packages(store_id, refunded_at desc) where refunded_at is not null;
create index if not exists member_ledger_store_kind_idx on public.member_ledger(store_id, kind, created_at desc);

-- 订单号：当天日期 + 4 位序号
create or replace function public.order_no(p_at timestamptz, p_seq bigint) returns text
language sql immutable as $$
  select to_char(p_at at time zone 'Asia/Shanghai', 'YYYYMMDD') || '-' || lpad((p_seq % 10000)::text, 4, '0')
$$;

-- 收款方式里“真正收进来的钱”是哪种：'余额 + 微信' -> 微信；'会员余额' / '次卡抵扣' / '' -> ''
create or replace function public.order_cash_method(p_pay text) returns text
language sql immutable as $$
  select case
    when p_pay is null or p_pay in ('', '会员余额', '储值余额', '次卡抵扣', '原路退回') then ''
    when p_pay like '余额 + %' then substr(p_pay, 6)
    else p_pay
  end
$$;

-- 列表上显示的收款方式文字
create or replace function public.order_pay_label(p_pay text) returns text
language sql immutable as $$
  select case
    when p_pay is null or p_pay = '' then '未收款'
    when p_pay = '会员余额' then '储值'
    when p_pay like '余额 + %' then '储值 + ' || substr(p_pay, 6)
    else p_pay
  end
$$;

-- ───────── 订单行（消费 / 退款 / 充值 / 次卡）─────────
create or replace function public.order_rows(p_store uuid, p_from timestamptz, p_to timestamptz)
returns table (
  kind text, id uuid, at timestamptz, title text, pay text, who text, amount numeric,
  status text, operator text, order_no text, cash numeric, balance numeric, cash_method text,
  plate text, phone text, member_name text
)
language sql
stable
security definer
set search_path = public
as $$
  -- 消费
  select 'consume'::text, o.id, o.created_at,
         coalesce((select string_agg(i.name, ' · ' order by i.position) from public.order_items i where i.order_id = o.id), '消费订单'),
         o.pay_method,
         coalesce(nullif(m.name, ''), nullif(o.vehicle_plate, ''), '散客'),
         o.payable, o.status, o.operator, public.order_no(o.created_at, o.seq),
         o.payable - o.balance_paid, o.balance_paid, public.order_cash_method(o.pay_method),
         o.vehicle_plate, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.orders o left join public.members m on m.id = o.member_id
  where o.store_id = p_store and o.created_at >= p_from and o.created_at < p_to
  union all
  -- 消费退款（按退款发生时间）
  select 'refund', o.id, o.refunded_at, '消费退款',
         case when o.payable - o.balance_paid > 0 then '原路退回' else '退回储值' end,
         coalesce(nullif(m.name, ''), nullif(o.vehicle_plate, ''), '散客'),
         -o.payable, 'completed', o.refund_operator, public.order_no(o.refunded_at, o.seq),
         -(o.payable - o.balance_paid), -o.balance_paid, public.order_cash_method(o.pay_method),
         o.vehicle_plate, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.orders o left join public.members m on m.id = o.member_id
  where o.store_id = p_store and o.status = 'refunded' and o.refunded_at >= p_from and o.refunded_at < p_to
  union all
  -- 充值
  select 'recharge', l.id, l.created_at,
         '储值充值' || case when l.gift > 0 then ' · 送 ¥' || trim(trailing '.' from trim(trailing '0' from l.gift::text)) else '' end,
         l.pay_method, coalesce(m.name, ''), l.amount, 'completed', l.operator, public.order_no(l.created_at, l.seq),
         l.amount, 0::numeric, public.order_cash_method(l.pay_method), ''::text, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_ledger l left join public.members m on m.id = l.member_id
  where l.store_id = p_store and l.kind = 'recharge' and l.created_at >= p_from and l.created_at < p_to
  union all
  -- 次卡售卖
  select 'package', p.id, p.purchased_at, '次卡售卖 · ' || p.name, p.pay_method, coalesce(m.name, ''), p.price_paid,
         case when p.refunded_at is null then 'completed' else 'refunded' end,
         coalesce((select e.operator from public.member_package_events e where e.member_package_id = p.id and e.kind = 'buy' limit 1), ''),
         public.order_no(p.purchased_at, p.seq),
         case when p.pay_method in ('会员余额', '储值余额') then 0 else p.price_paid end,
         case when p.pay_method in ('会员余额', '储值余额') then p.price_paid else 0 end,
         public.order_cash_method(p.pay_method), ''::text, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_packages p left join public.members m on m.id = p.member_id
  where p.store_id = p_store and p.purchased_at >= p_from and p.purchased_at < p_to
  union all
  -- 次卡退款
  select 'refund', p.id, p.refunded_at, '次卡退款',
         coalesce((select case when l.pay_method = '储值余额' then '退回储值' else '原路退回' end
                   from public.member_ledger l where l.kind = 'package_refund' and l.ref_id = p.id limit 1), '原路退回'),
         coalesce(m.name, ''), -p.refund_amount, 'completed',
         coalesce((select e.operator from public.member_package_events e where e.member_package_id = p.id and e.kind = 'refund' limit 1), ''),
         public.order_no(p.refunded_at, p.seq),
         -coalesce((select case when l.pay_method = '储值余额' then 0 else p.refund_amount end
                    from public.member_ledger l where l.kind = 'package_refund' and l.ref_id = p.id limit 1), p.refund_amount),
         -coalesce((select case when l.pay_method = '储值余额' then p.refund_amount else 0 end
                    from public.member_ledger l where l.kind = 'package_refund' and l.ref_id = p.id limit 1), 0),
         public.order_cash_method(p.pay_method), ''::text, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_packages p left join public.members m on m.id = p.member_id
  where p.store_id = p_store and p.refunded_at >= p_from and p.refunded_at < p_to
$$;
revoke all on function public.order_rows(uuid, timestamptz, timestamptz) from public, anon, authenticated;
grant execute on function public.order_rows(uuid, timestamptz, timestamptz) to service_role;

-- ───────── 订单列表 + 汇总 ─────────
-- p_kind: all / consume / recharge / package / refund；p_method: 微信 / 支付宝 / 现金 / 储值抵扣；
-- p_status: completed / refunded；p_operator：经办人；p_q：车牌 / 手机号 / 订单号 / 姓名。
-- p_before：上一页最后一条的时间（按时间倒序分页）。多取一条用来判断是否还有下一页。
create or replace function public.order_feed(
  p_store uuid, p_from timestamptz, p_to timestamptz,
  p_kind text, p_method text, p_status text, p_operator text, p_q text,
  p_before timestamptz, p_limit int
) returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_items jsonb;
  v_summary jsonb;
  v_limit int := least(greatest(coalesce(p_limit, 30), 1), 100);
  v_q text := replace(nullif(btrim(coalesce(p_q, '')), ''), '·', '');
begin
  -- 汇总只看时间范围，不受类型 / 收款方式 / 状态等筛选影响
  select jsonb_build_object(
    'received', coalesce(sum(cash) filter (where kind <> 'refund'), 0),
    'refunded', coalesce(-sum(cash) filter (where kind = 'refund'), 0),
    'net', coalesce(sum(cash), 0),
    'wechat', coalesce(sum(cash) filter (where kind <> 'refund' and cash_method = '微信'), 0),
    'alipay', coalesce(sum(cash) filter (where kind <> 'refund' and cash_method = '支付宝'), 0),
    'cash_pay', coalesce(sum(cash) filter (where kind <> 'refund' and cash_method = '现金'), 0),
    'pos', coalesce(sum(cash) filter (where kind <> 'refund' and cash_method = 'POS 刷卡'), 0),
    'balance', coalesce(sum(balance) filter (where kind in ('consume', 'package')), 0)
  ) into v_summary from public.order_rows(p_store, p_from, p_to);

  select coalesce(jsonb_agg(jsonb_build_object(
    'key', r.kind || ':' || r.id, 'kind', r.kind, 'id', r.id, 'at', r.at, 'title', r.title,
    'pay_label', case when r.kind = 'refund' then r.pay else public.order_pay_label(r.pay) end,
    'who', r.who, 'amount', r.amount, 'cash', r.cash, 'status', r.status, 'operator', r.operator, 'order_no', r.order_no
  ) order by r.at desc), '[]'::jsonb) into v_items
  from (
    select * from public.order_rows(p_store, p_from, p_to) x
    where (coalesce(p_kind, 'all') in ('all', '') or x.kind = p_kind)
      and (coalesce(p_method, '') = ''
           or (p_method = '储值抵扣' and x.balance <> 0 and x.kind <> 'refund')
           or (p_method <> '储值抵扣' and x.cash_method = p_method))
      and (coalesce(p_status, '') = ''
           or (p_status = 'refunded' and (x.status = 'refunded' or x.kind = 'refund'))
           or (p_status = 'completed' and x.status = 'completed' and x.kind <> 'refund'))
      and (coalesce(p_operator, '') = '' or x.operator = p_operator)
      and (v_q is null
           or replace(x.plate, '·', '') ilike '%' || v_q || '%'
           or x.phone like '%' || v_q || '%' or x.order_no ilike '%' || v_q || '%'
           or x.member_name ilike '%' || v_q || '%')
      and (p_before is null or x.at < p_before)
    order by x.at desc limit v_limit + 1
  ) r;

  return jsonb_build_object('items', v_items, 'summary', v_summary);
end;
$$;
revoke all on function public.order_feed(uuid, timestamptz, timestamptz, text, text, text, text, text, timestamptz, int) from public, anon, authenticated;
grant execute on function public.order_feed(uuid, timestamptz, timestamptz, text, text, text, text, text, timestamptz, int) to service_role;

-- 筛选弹层里的“经办人”选项：本店出现过的经办人
create or replace function public.order_operators(p_store uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(op order by op), '[]'::jsonb) from (
    select distinct operator as op from public.orders where store_id = p_store and operator <> ''
    union select distinct operator from public.member_ledger where store_id = p_store and operator <> '' and kind = 'recharge'
  ) t
$$;
revoke all on function public.order_operators(uuid) from public, anon, authenticated;
grant execute on function public.order_operators(uuid) to service_role;

-- ───────── 订单详情 ─────────
-- p_kind: consume / recharge / package；refund 行的详情就是原订单的详情（用 consume / package + id 查）。
create or replace function public.order_detail(p_store uuid, p_kind text, p_id uuid) returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  o public.orders;
  l public.member_ledger;
  p public.member_packages;
  m public.members;
  c public.card_types;
  v_pay jsonb := '[]'::jsonb;
  v_items jsonb;
begin
  if p_kind = 'consume' then
    select * into o from public.orders where id = p_id and store_id = p_store;
    if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
    select * into m from public.members where id = o.member_id;
    select * into c from public.card_types where id = m.card_type_id;
    select coalesce(jsonb_agg(jsonb_build_object(
      'name', i.name, 'qty', i.qty, 'unit_price', i.unit_price, 'line_total', i.line_total,
      'package', (select pk.name from public.member_packages pk where pk.id = i.member_package_id)
    ) order by i.position), '[]'::jsonb) into v_items from public.order_items i where i.order_id = o.id;
    if o.balance_paid > 0 then
      v_pay := v_pay || jsonb_build_array(jsonb_build_object('label', '储值余额', 'amount', o.balance_paid));
    end if;
    if o.payable - o.balance_paid > 0 then
      v_pay := v_pay || jsonb_build_array(jsonb_build_object('label', public.order_cash_method(o.pay_method) || '支付', 'amount', o.payable - o.balance_paid));
    end if;
    if o.payable = 0 and o.pay_method = '次卡抵扣' then
      v_pay := jsonb_build_array(jsonb_build_object('label', '次卡抵扣', 'amount', 0));
    end if;
    return jsonb_build_object(
      'kind', 'consume', 'id', o.id, 'order_no', public.order_no(o.created_at, o.seq), 'status', o.status,
      'amount', o.payable, 'subtotal', o.subtotal, 'card_off', o.card_off, 'discount_off', o.discount_off,
      'at', o.created_at, 'plate', o.vehicle_plate, 'operator', o.operator, 'remark', o.remark,
      'member', case when m.id is null then null else jsonb_build_object('id', m.id, 'name', m.name, 'level', coalesce(c.name, '')) end,
      'items', v_items, 'payments', v_pay,
      'refund', case when o.status = 'refunded' then jsonb_build_object(
        'at', o.refunded_at, 'reason', o.refund_reason, 'operator', o.refund_operator, 'amount', o.payable,
        'back_balance', o.balance_paid, 'back_cash', o.payable - o.balance_paid,
        'cash_label', public.order_cash_method(o.pay_method)) else null end,
      'can_refund', o.status = 'completed' and o.payable >= 0
    );
  elsif p_kind = 'recharge' then
    select * into l from public.member_ledger where id = p_id and store_id = p_store and kind = 'recharge';
    if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
    select * into m from public.members where id = l.member_id;
    select * into c from public.card_types where id = m.card_type_id;
    return jsonb_build_object(
      'kind', 'recharge', 'id', l.id, 'order_no', public.order_no(l.created_at, l.seq), 'status', 'completed',
      'amount', l.amount, 'gift', l.gift, 'balance_after', l.balance_after, 'at', l.created_at,
      'operator', l.operator, 'remark', l.note,
      'member', jsonb_build_object('id', m.id, 'name', m.name, 'level', coalesce(c.name, ''), 'balance', m.balance),
      'items', '[]'::jsonb,
      'payments', jsonb_build_array(jsonb_build_object('label', l.pay_method || '支付', 'amount', l.amount)),
      'can_refund', false
    );
  elsif p_kind = 'package' then
    select * into p from public.member_packages where id = p_id and store_id = p_store;
    if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
    select * into m from public.members where id = p.member_id;
    select * into c from public.card_types where id = m.card_type_id;
    select coalesce(jsonb_agg(jsonb_build_object(
      'name', i.service_name, 'qty', i.total, 'unit_price', i.unit_price, 'line_total', i.unit_price * i.total, 'package', null
    ) order by i.position), '[]'::jsonb) into v_items from public.member_package_items i where i.member_package_id = p.id;
    return jsonb_build_object(
      'kind', 'package', 'id', p.id, 'order_no', public.order_no(p.purchased_at, p.seq),
      'status', case when p.refunded_at is null then 'completed' else 'refunded' end,
      'title', p.name, 'amount', p.price_paid, 'at', p.purchased_at,
      'operator', coalesce((select e.operator from public.member_package_events e where e.member_package_id = p.id and e.kind = 'buy' limit 1), ''),
      'remark', '',
      'member', jsonb_build_object('id', m.id, 'name', m.name, 'level', coalesce(c.name, '')),
      'items', v_items,
      'payments', jsonb_build_array(jsonb_build_object('label', case when p.pay_method in ('会员余额', '储值余额') then '储值余额' else p.pay_method || '支付' end, 'amount', p.price_paid)),
      'refund', case when p.refunded_at is null then null else jsonb_build_object('at', p.refunded_at, 'amount', p.refund_amount) end,
      'can_refund', false
    );
  end if;
  raise exception 'order_not_found' using errcode = 'P0002';
end;
$$;
revoke all on function public.order_detail(uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.order_detail(uuid, text, uuid) to service_role;

-- ───────── 消费订单整单退款 ─────────
-- 退回：储值部分退回会员余额；其余原路退回（只记账，不接真实支付通道）；积分按当时赠送的扣回，
-- 累计消费和到店次数回退，次卡抵扣的次数退回。已退款的订单不能再退。
-- 错误：P0002 订单不存在；P0001 已退款 / 原因无效。
create or replace function public.refund_order(
  p_store uuid, p_order uuid, p_reason text, p_operator text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  o public.orders;
  m public.members;
  it record;
  v_points int;
begin
  if p_reason is null or p_reason not in ('服务问题', '会员不再需要', '录入错误', '其他') then
    raise exception 'bad_reason' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = p_order and store_id = p_store for update;
  if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
  if o.status = 'refunded' then
    -- 同一次点击的重试：直接返回第一次的结果
    if p_request is not null and exists (
      select 1 from public.member_ledger where store_id = p_store and request_id = p_request and order_id = o.id
    ) then
      return jsonb_build_object('order_id', o.id, 'refund', o.payable, 'repeated', true);
    end if;
    raise exception 'already_refunded' using errcode = 'P0001';
  end if;

  if o.member_id is not null then
    select * into m from public.members where id = o.member_id for update;
    v_points := least(o.points_gained, m.points);
    update public.members set
      balance = balance + o.balance_paid,
      total_spent = greatest(total_spent - o.payable, 0),
      visit_count = greatest(visit_count - 1, 0),
      points = points - v_points,
      updated_at = now()
    where id = m.id returning * into m;
    -- 次卡抵扣的次数退回
    for it in select i.qty, i.member_package_id, i.service_id, i.name
              from public.order_items i where i.order_id = o.id and i.member_package_id is not null loop
      update public.member_package_items set used = greatest(used - it.qty, 0)
      where member_package_id = it.member_package_id and service_id = it.service_id;
      update public.member_packages set used_count = greatest(used_count - it.qty, 0) where id = it.member_package_id;
      insert into public.member_package_events (store_id, member_package_id, kind, service_name, count, reason, operator, order_id)
      values (p_store, it.member_package_id, 'use', it.name, -it.qty, '订单退款，次数退回', p_operator, o.id);
    end loop;
    insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after,
      points_delta, points_after, pay_method, operator, reason, title, order_id, request_id)
    values (p_store, m.id, 'order_refund', o.payable, o.balance_paid, m.balance, -v_points, m.points,
      case when o.balance_paid >= o.payable and o.payable > 0 then '储值余额' else '原路退回' end,
      p_operator, p_reason, '消费退款', o.id, p_request);
  end if;

  update public.orders set status = 'refunded', refunded_at = now(), refund_reason = p_reason,
    refund_operator = coalesce(p_operator, '') where id = o.id;
  return jsonb_build_object('order_id', o.id, 'refund', o.payable, 'back_balance', o.balance_paid,
    'back_cash', o.payable - o.balance_paid);
end;
$$;
revoke all on function public.refund_order(uuid, uuid, text, text, text) from public, anon, authenticated;
grant execute on function public.refund_order(uuid, uuid, text, text, text) to service_role;
