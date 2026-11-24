-- 支持消费订单部分退款、多笔退款明细及次卡退款幂等。
-- 线下收款（微信/支付宝/POS/现金）退款由商家线下退还客户，系统只做退款记账。

-- 1. orders 增加累计已退金额与已退储值，并扩展状态枚举
alter table public.orders
  add column if not exists refunded_amount numeric(12, 2) not null default 0 check (refunded_amount >= 0),
  add column if not exists refunded_balance numeric(12, 2) not null default 0 check (refunded_balance >= 0);

update public.orders
set refunded_amount = payable,
    refunded_balance = balance_paid
where status = 'refunded' and refunded_amount = 0 and payable > 0;

alter table public.orders drop constraint if exists orders_status_check;
alter table public.orders add constraint orders_status_check
  check (status in ('completed', 'partial_refunded', 'refunded'));

-- 2. 消费订单退款明细表（支持部分退款多次退、散客退款及幂等）
create table if not exists public.order_refunds (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  amount numeric(12, 2) not null check (amount > 0),
  back_balance numeric(12, 2) not null default 0 check (back_balance >= 0),
  back_cash numeric(12, 2) not null default 0 check (back_cash >= 0),
  reason text not null default '',
  operator text not null default '',
  request_id text,
  seq bigint not null default nextval('public.order_no_seq'),
  created_at timestamptz not null default now()
);

create index if not exists order_refunds_store_time_idx
  on public.order_refunds(store_id, created_at desc);
create index if not exists order_refunds_order_idx
  on public.order_refunds(order_id, created_at desc);
create unique index if not exists order_refunds_request_uidx
  on public.order_refunds(store_id, request_id) where request_id is not null;

-- 3. member_package_events 增加 request_id 用于次卡退款幂等
alter table public.member_package_events
  add column if not exists request_id text;
create unique index if not exists member_package_events_request_uidx
  on public.member_package_events(store_id, request_id) where request_id is not null;

-- 4. 更新 order_rows：消费退款优先从 order_refunds 读取，兼容历史已退款但无 order_refunds 记录的订单
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
  -- 消费退款（新版：从 order_refunds 读取，支持部分退款与多次退款）
  select 'refund', o.id, r.created_at,
         case when r.amount < o.payable then '部分退款' else '消费退款' end,
         case when r.back_cash > 0 and r.back_balance > 0 then '退回储值 + 线下退还'
              when r.back_cash > 0 then '线下退还'
              else '退回储值' end,
         coalesce(nullif(m.name, ''), nullif(o.vehicle_plate, ''), '散客'),
         -r.amount, 'completed', r.operator, public.order_no(r.created_at, r.seq),
         -r.back_cash, -r.back_balance, public.order_cash_method(o.pay_method),
         o.vehicle_plate, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.order_refunds r
  join public.orders o on o.id = r.order_id
  left join public.members m on m.id = o.member_id
  where r.store_id = p_store and r.created_at >= p_from and r.created_at < p_to
  union all
  -- 消费退款（兼容历史无 order_refunds 明细的整单退款）
  select 'refund', o.id, o.refunded_at, '消费退款',
         case when o.payable - o.balance_paid > 0 then '线下退还' else '退回储值' end,
         coalesce(nullif(m.name, ''), nullif(o.vehicle_plate, ''), '散客'),
         -o.payable, 'completed', o.refund_operator, public.order_no(o.refunded_at, o.seq),
         -(o.payable - o.balance_paid), -o.balance_paid, public.order_cash_method(o.pay_method),
         o.vehicle_plate, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.orders o left join public.members m on m.id = o.member_id
  where o.store_id = p_store and o.status = 'refunded' and o.refunded_at >= p_from and o.refunded_at < p_to
    and not exists (select 1 from public.order_refunds r where r.order_id = o.id)
  union all
  -- 充值
  select 'recharge', l.id, l.created_at,
         '储值充值' || case when l.gift > 0 then ' · 送 ¥' || trim(trailing '.' from trim(trailing '0' from l.gift::text)) else '' end,
         l.pay_method, coalesce(m.name, ''), l.amount, 'completed', l.operator,
         public.order_no(l.created_at, l.seq), l.amount, 0, l.pay_method,
         '', coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_ledger l join public.members m on m.id = l.member_id
  where l.store_id = p_store and l.kind = 'recharge' and l.created_at >= p_from and l.created_at < p_to
  union all
  -- 次卡购买
  select 'package', p.id, p.purchased_at, '购买次卡 · ' || p.name, p.pay_method, coalesce(m.name, ''),
         p.price_paid, case when p.refunded_at is null then 'completed' else 'refunded' end,
         coalesce((select e.operator from public.member_package_events e where e.member_package_id = p.id and e.kind = 'buy' limit 1), ''),
         public.order_no(p.purchased_at, p.seq),
         case when p.pay_method in ('会员余额', '储值余额') then 0 else p.price_paid end,
         case when p.pay_method in ('会员余额', '储值余额') then p.price_paid else 0 end,
         public.order_cash_method(p.pay_method), '', coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_packages p join public.members m on m.id = p.member_id
  where p.store_id = p_store and p.purchased_at >= p_from and p.purchased_at < p_to
  union all
  -- 次卡退款
  select 'refund', p.id, p.refunded_at, '次卡退款 · ' || p.name,
         coalesce((select l.pay_method from public.member_ledger l where l.ref_id = p.id and l.kind = 'package_refund' limit 1), '线下退还'),
         coalesce(m.name, ''), -p.refund_amount, 'completed',
         coalesce((select e.operator from public.member_package_events e where e.member_package_id = p.id and e.kind = 'refund' limit 1), ''),
         public.order_no(p.refunded_at, p.seq),
         case when exists (select 1 from public.member_ledger l where l.ref_id = p.id and l.kind = 'package_refund' and l.balance_delta > 0) then 0 else -p.refund_amount end,
         -coalesce((select l.balance_delta from public.member_ledger l where l.ref_id = p.id and l.kind = 'package_refund' limit 1), 0),
         '', '', coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_packages p join public.members m on m.id = p.member_id
  where p.store_id = p_store and p.refunded_at is not null and p.refunded_at >= p_from and p.refunded_at < p_to;
$$;

-- 5. 更新 order_detail：返回 refunded_amount / refundable_amount / can_refund（含 partial_refunded）
create or replace function public.order_detail(p_store uuid, p_kind text, p_id uuid)
returns jsonb
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
  v_refunds jsonb;
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
    select coalesce(jsonb_agg(jsonb_build_object(
      'at', r.created_at, 'amount', r.amount, 'back_balance', r.back_balance, 'back_cash', r.back_cash,
      'reason', r.reason, 'operator', r.operator
    ) order by r.created_at desc), '[]'::jsonb) into v_refunds
    from public.order_refunds r where r.order_id = o.id;
    return jsonb_build_object(
      'kind', 'consume', 'id', o.id, 'order_no', public.order_no(o.created_at, o.seq), 'status', o.status,
      'amount', o.payable, 'refunded_amount', o.refunded_amount,
      'refundable_amount', greatest(o.payable - o.refunded_amount, 0),
      'subtotal', o.subtotal, 'card_off', o.card_off, 'discount_off', o.discount_off,
      'at', o.created_at, 'plate', o.vehicle_plate, 'operator', o.operator, 'remark', o.remark,
      'member', case when m.id is null then null else jsonb_build_object('id', m.id, 'name', m.name, 'level', coalesce(c.name, '')) end,
      'items', v_items, 'payments', v_pay,
      'refunds', v_refunds,
      'refund', case when o.status in ('refunded', 'partial_refunded') then jsonb_build_object(
        'at', o.refunded_at, 'reason', o.refund_reason, 'operator', o.refund_operator,
        'amount', o.refunded_amount,
        'back_balance', o.refunded_balance,
        'back_cash', o.refunded_amount - o.refunded_balance,
        'cash_label', public.order_cash_method(o.pay_method)) else null end,
      'can_refund', (o.status in ('completed', 'partial_refunded') and (o.payable - o.refunded_amount > 0 or (o.status = 'completed' and o.payable = 0)))
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

-- 6. 消费订单退款（支持整单退款与部分退款；线下收款只记账）
create or replace function public.refund_order(
  p_store uuid, p_order uuid, p_reason text, p_operator text, p_request text, p_amount numeric default null
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  o public.orders;
  m public.members;
  prior_ref public.order_refunds;
  it record;
  v_remaining numeric;
  v_rem_balance numeric;
  v_rem_cash numeric;
  v_refund numeric;
  v_back_balance numeric := 0;
  v_back_cash numeric := 0;
  v_full boolean;
  v_points int := 0;
begin
  if p_reason is null or p_reason not in ('服务问题', '会员不再需要', '录入错误', '其他') then
    raise exception 'bad_reason' using errcode = 'P0001';
  end if;
  select * into o from public.orders where id = p_order and store_id = p_store for update;
  if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;

  if p_request is not null then
    select * into prior_ref from public.order_refunds where store_id = p_store and request_id = p_request;
    if found then
      return jsonb_build_object(
        'order_id', o.id, 'refund', prior_ref.amount,
        'back_balance', prior_ref.back_balance, 'back_cash', prior_ref.back_cash,
        'status', o.status, 'repeated', true
      );
    end if;
  end if;

  if o.status = 'refunded' then
    if p_request is not null and exists (
      select 1 from public.member_ledger where store_id = p_store and request_id = p_request and order_id = o.id
    ) then
      return jsonb_build_object('order_id', o.id, 'refund', o.payable, 'repeated', true);
    end if;
    raise exception 'already_refunded' using errcode = 'P0001';
  end if;

  v_remaining := greatest(o.payable - o.refunded_amount, 0);
  v_rem_balance := greatest(o.balance_paid - o.refunded_balance, 0);
  v_rem_cash := greatest(v_remaining - v_rem_balance, 0);

  if p_amount is null then
    v_refund := v_remaining;
  else
    if p_amount <= 0 or p_amount > v_remaining then
      raise exception 'invalid_refund_amount' using errcode = 'P0001';
    end if;
    v_refund := round(p_amount, 2);
  end if;

  v_full := (v_refund >= v_remaining);

  if v_remaining > 0 then
    if v_full then
      v_back_balance := v_rem_balance;
      v_back_cash := v_rem_cash;
    else
      if v_rem_balance > 0 and v_rem_cash > 0 then
        v_back_balance := least(v_rem_balance, round(v_refund * v_rem_balance / v_remaining, 2));
        v_back_cash := v_refund - v_back_balance;
      elsif v_rem_balance > 0 then
        v_back_balance := v_refund;
        v_back_cash := 0;
      else
        v_back_balance := 0;
        v_back_cash := v_refund;
      end if;
    end if;
  end if;

  if v_refund > 0 then
    insert into public.order_refunds (
      store_id, order_id, amount, back_balance, back_cash, reason, operator, request_id
    ) values (
      p_store, o.id, v_refund, v_back_balance, v_back_cash, p_reason, coalesce(p_operator, ''), p_request
    );
  end if;

  if o.member_id is not null then
    select * into m from public.members where id = o.member_id for update;
    if o.payable > 0 and o.points_gained > 0 then
      v_points := least(
        case when v_full then greatest(o.points_gained - coalesce((
          select sum(abs(points_delta)) from public.member_ledger
          where store_id = p_store and order_id = o.id and kind = 'order_refund'
        ), 0)::int, 0)
        else floor(o.points_gained * v_refund / o.payable)::int end,
        m.points
      );
    end if;
    update public.members set
      balance = balance + v_back_balance,
      total_spent = greatest(total_spent - v_refund, 0),
      visit_count = case when v_full then greatest(visit_count - 1, 0) else visit_count end,
      points = points - v_points,
      updated_at = now()
    where id = m.id returning * into m;

    if v_full then
      for it in select i.qty, i.member_package_id, i.service_id, i.name
                from public.order_items i where i.order_id = o.id and i.member_package_id is not null loop
        update public.member_package_items set used = greatest(used - it.qty, 0)
        where member_package_id = it.member_package_id and service_id = it.service_id;
        update public.member_packages set used_count = greatest(used_count - it.qty, 0) where id = it.member_package_id;
        insert into public.member_package_events (store_id, member_package_id, kind, service_name, count, reason, operator, order_id)
        values (p_store, it.member_package_id, 'use', it.name, -it.qty, '订单退款，次数退回', p_operator, o.id);
      end loop;
    end if;

    insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after,
      points_delta, points_after, pay_method, operator, reason, title, order_id, request_id)
    values (p_store, m.id, 'order_refund', v_refund, v_back_balance, m.balance, -v_points, m.points,
      case when v_back_cash > 0 and v_back_balance > 0 then '退回储值 + 线下退还'
           when v_back_cash > 0 then '线下退还'
           else '储值余额' end,
      p_operator, p_reason, case when v_full then '消费退款' else '部分退款' end, o.id, p_request);
  end if;

  update public.orders set
    refunded_amount = refunded_amount + v_refund,
    refunded_balance = refunded_balance + v_back_balance,
    status = case when v_full then 'refunded' else 'partial_refunded' end,
    refunded_at = now(),
    refund_reason = p_reason,
    refund_operator = coalesce(p_operator, '')
  where id = o.id;

  return jsonb_build_object(
    'order_id', o.id, 'refund', v_refund,
    'back_balance', v_back_balance, 'back_cash', v_back_cash,
    'status', case when v_full then 'refunded' else 'partial_refunded' end
  );
end;
$$;
revoke all on function public.refund_order(uuid, uuid, text, text, text, numeric) from public, anon, authenticated;
grant execute on function public.refund_order(uuid, uuid, text, text, text, numeric) to service_role;

-- 7. 次卡退款（支持 request_id 幂等；选择原路退回时由商家线下退还客户，系统仅记账）
create or replace function public.refund_package(
  p_store uuid, p_mp uuid, p_to text, p_reason text, p_operator text, p_request text default null
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  mp public.member_packages;
  m public.members;
  v_refund numeric;
  v_back numeric := 0;
begin
  if p_request is not null and exists (
    select 1 from public.member_package_events
    where store_id = p_store and request_id = p_request and kind = 'refund'
  ) then
    select * into mp from public.member_packages where id = p_mp and store_id = p_store;
    if found then
      select * into m from public.members where id = mp.member_id;
      return jsonb_build_object('refund', mp.refund_amount, 'balance', m.balance, 'repeated', true);
    end if;
  end if;

  select * into mp from public.member_packages where id = p_mp and store_id = p_store for update;
  if not found then raise exception 'package_not_found' using errcode = 'P0002'; end if;
  if mp.refunded_at is not null then raise exception 'already_refunded' using errcode = 'P0001'; end if;
  v_refund := round(mp.price_paid - mp.used_count * (mp.price_paid / mp.total_count), 2);
  if v_refund <= 0 then raise exception 'nothing_to_refund' using errcode = 'P0001'; end if;
  select * into m from public.members where id = mp.member_id for update;
  if p_to = '储值余额' then
    v_back := v_refund;
    update public.members set balance = balance + v_refund, updated_at = now() where id = m.id returning * into m;
  end if;
  update public.member_packages set refunded_at = now(), refund_amount = v_refund where id = mp.id;
  insert into public.member_package_events (store_id, member_package_id, kind, amount, reason, operator, request_id)
  values (p_store, mp.id, 'refund', v_refund, p_reason, p_operator, p_request);
  insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after, points_after,
    pay_method, operator, reason, title, ref_id, request_id)
  values (p_store, m.id, 'package_refund', v_refund, v_back, m.balance, m.points,
    case when p_to = '储值余额' then '储值余额' else '线下退还' end,
    p_operator, p_reason, mp.name, mp.id, p_request);
  return jsonb_build_object('refund', v_refund, 'balance', m.balance);
end;
$$;
revoke all on function public.refund_package(uuid, uuid, text, text, text, text) from public, anon, authenticated;
grant execute on function public.refund_package(uuid, uuid, text, text, text, text) to service_role;
