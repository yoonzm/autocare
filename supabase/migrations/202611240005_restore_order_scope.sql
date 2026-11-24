-- Restore staff order scope after the refund migration replaced order_rows.
-- Refund entries follow their order; recharges and packages have no technician.
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
  where o.store_id = p_store and o.created_at >= p_from and o.created_at < p_to and public.order_in_scope(o.id)
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
  where r.store_id = p_store and r.created_at >= p_from and r.created_at < p_to and public.order_in_scope(o.id)
  union all
  -- 消费退款（兼容历史无 order_refunds 明细的整单退款）
  select 'refund', o.id, o.refunded_at, '消费退款',
         case when o.payable - o.balance_paid > 0 then '线下退还' else '退回储值' end,
         coalesce(nullif(m.name, ''), nullif(o.vehicle_plate, ''), '散客'),
         -o.payable, 'completed', o.refund_operator, public.order_no(o.refunded_at, o.seq),
         -(o.payable - o.balance_paid), -o.balance_paid, public.order_cash_method(o.pay_method),
         o.vehicle_plate, coalesce(m.phone, ''), coalesce(m.name, '')
  from public.orders o left join public.members m on m.id = o.member_id
  where o.store_id = p_store and o.status = 'refunded' and o.refunded_at >= p_from and o.refunded_at < p_to and public.order_in_scope(o.id)
    and not exists (select 1 from public.order_refunds r where r.order_id = o.id)
  union all
  -- 充值
  select 'recharge', l.id, l.created_at,
         '储值充值' || case when l.gift > 0 then ' · 送 ¥' || trim(trailing '.' from trim(trailing '0' from l.gift::text)) else '' end,
         l.pay_method, coalesce(m.name, ''), l.amount, 'completed', l.operator,
         public.order_no(l.created_at, l.seq), l.amount, 0, l.pay_method,
         '', coalesce(m.phone, ''), coalesce(m.name, '')
  from public.member_ledger l join public.members m on m.id = l.member_id
  where l.store_id = p_store and l.kind = 'recharge' and l.created_at >= p_from and l.created_at < p_to and nullif(current_setting('autocare.order_scope', true), '') is null
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
  where p.store_id = p_store and p.purchased_at >= p_from and p.purchased_at < p_to and nullif(current_setting('autocare.order_scope', true), '') is null
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
  where p.store_id = p_store and p.refunded_at is not null and p.refunded_at >= p_from and p.refunded_at < p_to and nullif(current_setting('autocare.order_scope', true), '') is null;
$$;
