-- 次卡售卖与核销、开单收银、会员回访。
-- 金额、次数、余额都只能经由下面的 SECURITY DEFINER 函数（云函数以 service_role 调用）修改。
-- 收款方式只是记账，不接真实支付通道。

-- ───────── 流水扩展 ─────────
alter table public.member_ledger drop constraint if exists member_ledger_kind_check;
alter table public.member_ledger add constraint member_ledger_kind_check check (kind in (
  'recharge', 'adjust_points', 'adjust_card', 'upgrade',
  'consume', 'package_buy', 'package_use', 'package_extend', 'package_refund'
));
alter table public.member_ledger
  add column if not exists title text not null default '',
  add column if not exists order_id uuid,
  add column if not exists ref_id uuid;

-- ───────── 会员的次卡 ─────────
create table if not exists public.member_packages (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  package_id uuid not null references public.card_packages(id) on delete restrict,
  -- 购买时的名称和价格（之后套餐改了也不影响已售次卡）
  name text not null,
  price_paid numeric(12, 2) not null check (price_paid >= 0),
  original_price numeric(12, 2) not null default 0,
  total_count int not null check (total_count > 0),
  used_count int not null default 0 check (used_count >= 0),
  pay_method text not null default '',
  purchased_at timestamptz not null default now(),
  -- null = 永久有效
  expires_at timestamptz,
  refunded_at timestamptz,
  refund_amount numeric(12, 2) not null default 0
);
create index if not exists member_packages_member_idx on public.member_packages(member_id);
create index if not exists member_packages_store_idx on public.member_packages(store_id);

create table if not exists public.member_package_items (
  member_package_id uuid not null references public.member_packages(id) on delete cascade,
  position int not null default 0,
  service_id uuid references public.service_items(id) on delete set null,
  service_name text not null,
  unit_price numeric(10, 2) not null default 0,
  total int not null check (total > 0),
  used int not null default 0 check (used >= 0),
  primary key (member_package_id, position)
);

-- 次卡的使用记录：购买 / 核销 / 延期 / 退款
create table if not exists public.member_package_events (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_package_id uuid not null references public.member_packages(id) on delete cascade,
  kind text not null check (kind in ('buy', 'use', 'extend', 'refund')),
  service_name text not null default '',
  count int not null default 0,
  days int not null default 0,
  amount numeric(12, 2) not null default 0,
  reason text not null default '',
  vehicle_plate text not null default '',
  operator text not null default '',
  order_id uuid,
  created_at timestamptz not null default now()
);
create index if not exists member_package_events_mp_idx on public.member_package_events(member_package_id, created_at desc);

-- ───────── 订单 ─────────
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid references public.members(id) on delete set null,
  subtotal numeric(12, 2) not null default 0,
  card_off numeric(12, 2) not null default 0,
  discount_off numeric(12, 2) not null default 0,
  payable numeric(12, 2) not null default 0,
  balance_paid numeric(12, 2) not null default 0,
  pay_method text not null default '',
  points_gained int not null default 0,
  vehicle_plate text not null default '',
  remark text not null default '' check (length(remark) <= 200),
  operator text not null default '',
  request_id text,
  created_at timestamptz not null default now()
);
create index if not exists orders_member_idx on public.orders(member_id, created_at desc);
create unique index if not exists orders_request_uidx on public.orders(store_id, request_id) where request_id is not null;

create table if not exists public.order_items (
  order_id uuid not null references public.orders(id) on delete cascade,
  position int not null,
  service_id uuid references public.service_items(id) on delete set null,
  name text not null,
  unit_price numeric(10, 2) not null,
  qty int not null check (qty between 1 and 99),
  line_total numeric(12, 2) not null,
  -- 用哪张次卡抵扣
  member_package_id uuid references public.member_packages(id) on delete set null,
  primary key (order_id, position)
);

-- ───────── 回访 ─────────
create table if not exists public.member_follow_ups (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  method text not null check (method in ('电话', '微信', '到店')),
  result text not null default '' check (length(result) <= 30),
  content text not null default '' check (length(content) <= 500),
  next_at date,
  operator text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists member_follow_ups_member_idx on public.member_follow_ups(member_id, created_at desc);

-- ───────── RLS：只读，写入走云函数 ─────────
do $$
declare t text;
begin
  foreach t in array array['member_packages', 'member_package_events', 'orders', 'member_follow_ups'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format($p$create policy %I on public.%I for select to authenticated
      using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())))$p$, t || '_owner', t);
    execute format('revoke all on public.%I from public, anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
    execute format('grant select, insert, update, delete on public.%I to service_role', t);
  end loop;
end $$;
alter table public.member_package_items enable row level security;
alter table public.order_items enable row level security;
create policy member_package_items_owner on public.member_package_items for select to authenticated
  using (exists (select 1 from public.member_packages p join public.stores s on s.id = p.store_id
                 where p.id = member_package_id and s.owner_id = (select auth.uid())));
create policy order_items_owner on public.order_items for select to authenticated
  using (exists (select 1 from public.orders o join public.stores s on s.id = o.store_id
                 where o.id = order_id and s.owner_id = (select auth.uid())));
revoke all on public.member_package_items, public.order_items from public, anon, authenticated;
grant select on public.member_package_items, public.order_items to authenticated;
grant select, insert, update, delete on public.member_package_items, public.order_items to service_role;

-- ───────── 按累计消费自动升级 ─────────
-- 门店开启“充值或消费自动升级”时，累计消费满额的最高卡种；只升不降。返回新卡种名称，没升级返回 null。
create or replace function public.member_spend_upgrade(p_store uuid, p_member uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.members;
  cur public.card_types;
  best public.card_types;
  auto boolean;
begin
  select card_auto_upgrade into auto from public.stores where id = p_store;
  if not coalesce(auto, false) then return null; end if;
  select * into m from public.members where id = p_member and store_id = p_store;
  select * into cur from public.card_types where id = m.card_type_id;
  select t.* into best from public.card_types t
  where t.store_id = p_store and t.active
    and t.upgrade_cumulative is not null and m.total_spent >= t.upgrade_cumulative
  order by public.card_rank(t) desc limit 1;
  if found and public.card_rank(best) > public.card_rank(cur) then
    update public.members set card_type_id = best.id, updated_at = now() where id = m.id;
    insert into public.member_ledger (store_id, member_id, kind, balance_after, points_after, operator, reason, card_from, card_to)
    values (p_store, m.id, 'upgrade', m.balance, m.points, '系统', '累计消费达标自动升级', cur.name, best.name);
    return best.name;
  end if;
  return null;
end;
$$;
revoke all on function public.member_spend_upgrade(uuid, uuid) from public, anon, authenticated;
grant execute on function public.member_spend_upgrade(uuid, uuid) to service_role;

-- ───────── 购买次卡 ─────────
-- 错误：P0002 = 会员 / 套餐不存在；P0001 = 余额不足 / 超过每人限购。
create or replace function public.sell_package(
  p_store uuid, p_member uuid, p_package uuid, p_method text, p_operator text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.members;
  cur public.card_types;
  pkg public.card_packages;
  prior public.member_ledger;
  v_mp uuid;
  v_total int;
  v_orig numeric;
  v_exp timestamptz;
  v_points int;
  v_balance_part numeric := 0;
  v_up text;
begin
  if p_request is not null then
    select * into prior from public.member_ledger where store_id = p_store and request_id = p_request;
    if found then
      select * into m from public.members where id = prior.member_id;
      return jsonb_build_object('member_package_id', prior.ref_id, 'price', prior.amount, 'balance', m.balance,
        'points_gained', prior.points_delta, 'repeated', true);
    end if;
  end if;

  select * into m from public.members where id = p_member and store_id = p_store and deleted_at is null for update;
  if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  select * into pkg from public.card_packages
  where id = p_package and store_id = p_store and deleted_at is null and active;
  if not found then raise exception 'package_not_found' using errcode = 'P0002'; end if;

  if pkg.purchase_limit is not null and (
    select count(*) from public.member_packages
    where member_id = m.id and package_id = pkg.id and refunded_at is null
  ) >= pkg.purchase_limit then
    raise exception 'purchase_limit' using errcode = 'P0001';
  end if;

  if p_method = '会员余额' then
    if m.balance < pkg.price then raise exception 'balance_not_enough' using errcode = 'P0001'; end if;
    v_balance_part := pkg.price;
  end if;

  select coalesce(sum(i.count), 0), coalesce(sum(i.count * s.price), 0)
  into v_total, v_orig
  from public.card_package_items i join public.service_items s on s.id = i.service_id
  where i.package_id = pkg.id;
  if v_total = 0 then raise exception 'package_empty' using errcode = 'P0002'; end if;

  v_exp := case when pkg.validity_months = 0 then null
                else now() + make_interval(months => pkg.validity_months) end;
  select * into cur from public.card_types where id = m.card_type_id;
  v_points := floor(pkg.price * coalesce(cur.points_multiplier, 1));

  insert into public.member_packages (store_id, member_id, package_id, name, price_paid, original_price,
    total_count, pay_method, expires_at)
  values (p_store, m.id, pkg.id, pkg.name, pkg.price, v_orig, v_total, coalesce(p_method, ''), v_exp)
  returning id into v_mp;
  insert into public.member_package_items (member_package_id, position, service_id, service_name, unit_price, total)
  select v_mp, (row_number() over (order by i.position) - 1)::int, s.id, s.name, s.price, i.count
  from public.card_package_items i join public.service_items s on s.id = i.service_id
  where i.package_id = pkg.id;

  update public.members set
    balance = balance - v_balance_part,
    total_spent = total_spent + pkg.price,
    points = points + v_points,
    updated_at = now()
  where id = m.id returning * into m;

  insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after,
    points_delta, points_after, pay_method, operator, title, ref_id, request_id)
  values (p_store, m.id, 'package_buy', pkg.price, -v_balance_part, m.balance, v_points, m.points,
    coalesce(p_method, ''), p_operator, pkg.name, v_mp, p_request);
  insert into public.member_package_events (store_id, member_package_id, kind, count, amount, operator)
  values (p_store, v_mp, 'buy', v_total, pkg.price, p_operator);

  v_up := public.member_spend_upgrade(p_store, m.id);
  return jsonb_build_object('member_package_id', v_mp, 'price', pkg.price, 'original_price', v_orig,
    'total_count', v_total, 'expires_at', v_exp, 'balance', m.balance, 'points_gained', v_points,
    'upgraded_to', v_up, 'repeated', false);
end;
$$;
revoke all on function public.sell_package(uuid, uuid, uuid, text, text, text) from public, anon, authenticated;
grant execute on function public.sell_package(uuid, uuid, uuid, text, text, text) to service_role;

-- ───────── 次卡延期 ─────────
-- 错误：P0002 = 次卡不存在；P0001 = 永久有效 / 已退款 / 已用完无需延期。
create or replace function public.extend_package(
  p_store uuid, p_mp uuid, p_days int, p_reason text, p_operator text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  mp public.member_packages;
begin
  select * into mp from public.member_packages where id = p_mp and store_id = p_store for update;
  if not found then raise exception 'package_not_found' using errcode = 'P0002'; end if;
  if mp.refunded_at is not null or mp.expires_at is null or mp.used_count >= mp.total_count then
    raise exception 'cannot_extend' using errcode = 'P0001';
  end if;
  -- 已过期的次卡从今天起算，没过期的在原到期日基础上延长
  update public.member_packages
  set expires_at = greatest(expires_at, now()) + make_interval(days => p_days)
  where id = mp.id returning * into mp;
  insert into public.member_package_events (store_id, member_package_id, kind, days, reason, operator)
  values (p_store, mp.id, 'extend', 0, p_reason, p_operator);
  update public.member_package_events set days = p_days
  where id = (select id from public.member_package_events where member_package_id = mp.id and kind = 'extend'
              order by created_at desc limit 1);
  insert into public.member_ledger (store_id, member_id, kind, balance_after, points_after, operator, reason, title, ref_id)
  select p_store, m.id, 'package_extend', m.balance, m.points, p_operator, p_reason, mp.name, mp.id
  from public.members m where m.id = mp.member_id;
  return jsonb_build_object('expires_at', mp.expires_at);
end;
$$;
revoke all on function public.extend_package(uuid, uuid, int, text, text) from public, anon, authenticated;
grant execute on function public.extend_package(uuid, uuid, int, text, text) to service_role;

-- ───────── 次卡退款 ─────────
-- 可退金额 = 实付 − 已用次数 × 单次均价（实付 / 总次数）。p_to = '储值余额' 时退到余额，否则记为原路退回。
-- 错误：P0002 = 次卡不存在；P0001 = 已退款 / 没有可退金额。
create or replace function public.refund_package(
  p_store uuid, p_mp uuid, p_to text, p_reason text, p_operator text
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
  insert into public.member_package_events (store_id, member_package_id, kind, amount, reason, operator)
  values (p_store, mp.id, 'refund', v_refund, p_reason, p_operator);
  insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after, points_after,
    pay_method, operator, reason, title, ref_id)
  values (p_store, m.id, 'package_refund', v_refund, v_back, m.balance, m.points, coalesce(p_to, ''),
    p_operator, p_reason, mp.name, mp.id);
  return jsonb_build_object('refund', v_refund, 'balance', m.balance);
end;
$$;
revoke all on function public.refund_package(uuid, uuid, text, text, text) from public, anon, authenticated;
grant execute on function public.refund_package(uuid, uuid, text, text, text) to service_role;

-- ───────── 开单收银 ─────────
-- p_lines: [{service_id, qty, member_package_id?}]；价格、折扣、次卡抵扣、扣款全部在这里算，客户端只传选择。
-- p_method: 会员余额 / 微信 / 支付宝 / 现金 / POS 刷卡 / 组合支付（余额 p_balance_part + 其他 p_other）。
-- 错误：P0002 = 会员 / 服务不存在；P0001 = 余额不足 / 次卡次数不够 / 组合支付参数无效。
create or replace function public.checkout_order(
  p_store uuid, p_member uuid, p_lines jsonb, p_method text, p_balance_part numeric, p_other text,
  p_plate text, p_remark text, p_operator text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.members;
  cur public.card_types;
  prior public.orders;
  ln jsonb;
  svc public.service_items;
  mpi public.member_package_items;
  mp public.member_packages;
  v_qty int;
  v_pos int := 0;
  v_subtotal numeric := 0;
  v_card_off numeric := 0;
  v_discount_off numeric := 0;
  v_payable numeric;
  v_balance numeric := 0;
  v_order uuid;
  v_points int;
  v_names text := '';
  v_method text;
  v_up text;
  v_covered jsonb := '[]'::jsonb;
  v_line numeric;
begin
  if p_request is not null then
    select * into prior from public.orders where store_id = p_store and request_id = p_request;
    if found then
      select * into m from public.members where id = prior.member_id;
      return jsonb_build_object('order_id', prior.id, 'payable', prior.payable, 'balance', m.balance, 'repeated', true);
    end if;
  end if;
  select * into m from public.members where id = p_member and store_id = p_store and deleted_at is null for update;
  if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  select * into cur from public.card_types where id = m.card_type_id;
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'no_items' using errcode = 'P0002';
  end if;

  insert into public.orders (store_id, member_id, vehicle_plate, remark, operator, request_id, pay_method)
  values (p_store, m.id, coalesce(p_plate, ''), coalesce(p_remark, ''), p_operator, p_request, '')
  returning id into v_order;

  for ln in select * from jsonb_array_elements(p_lines) loop
    v_qty := coalesce((ln->>'qty')::int, 1);
    select * into svc from public.service_items
    where id = (ln->>'service_id')::uuid and store_id = p_store and active;
    if not found then raise exception 'service_not_found' using errcode = 'P0002'; end if;
    v_line := svc.price * v_qty;
    v_subtotal := v_subtotal + v_line;
    v_names := v_names || case when v_names = '' then '' else ' · ' end || svc.name;
    mp := null;
    if nullif(ln->>'member_package_id', '') is not null then
      select p.* into mp from public.member_packages p
      where p.id = (ln->>'member_package_id')::uuid and p.store_id = p_store and p.member_id = m.id
        and p.refunded_at is null and (p.expires_at is null or p.expires_at > now()) for update;
      if not found then raise exception 'package_not_enough' using errcode = 'P0001'; end if;
      select i.* into mpi from public.member_package_items i
      where i.member_package_id = mp.id and i.service_id = svc.id for update;
      if not found or mpi.total - mpi.used < v_qty then
        raise exception 'package_not_enough' using errcode = 'P0001';
      end if;
      update public.member_package_items set used = used + v_qty
      where member_package_id = mp.id and position = mpi.position;
      update public.member_packages set used_count = used_count + v_qty where id = mp.id;
      v_card_off := v_card_off + v_line;
      insert into public.member_package_events (store_id, member_package_id, kind, service_name, count, vehicle_plate, operator, order_id)
      values (p_store, mp.id, 'use', svc.name, v_qty, coalesce(p_plate, ''), p_operator, v_order);
      v_covered := v_covered || jsonb_build_array(jsonb_build_object(
        'member_package_id', mp.id, 'name', svc.name, 'count', v_qty,
        'remaining', mpi.total - mpi.used - v_qty, 'package', mp.name));
    else
      v_discount_off := v_discount_off + round(v_line * (1 - coalesce(cur.discount, 1)), 2);
    end if;
    insert into public.order_items (order_id, position, service_id, name, unit_price, qty, line_total, member_package_id)
    values (v_order, v_pos, svc.id, svc.name, svc.price, v_qty, v_line, mp.id);
    v_pos := v_pos + 1;
  end loop;

  v_payable := v_subtotal - v_card_off - v_discount_off;
  v_method := coalesce(p_method, '');
  if v_payable <= 0 then
    v_payable := 0; v_method := '次卡抵扣';
  elsif v_method = '会员余额' then
    if m.balance < v_payable then raise exception 'balance_not_enough' using errcode = 'P0001'; end if;
    v_balance := v_payable;
  elsif v_method = '组合支付' then
    v_balance := coalesce(p_balance_part, 0);
    if v_balance <= 0 or v_balance >= v_payable or v_balance > m.balance
       or coalesce(p_other, '') not in ('微信', '支付宝', '现金', 'POS 刷卡') then
      raise exception 'bad_combo' using errcode = 'P0001';
    end if;
    v_method := '余额 + ' || p_other;
  elsif v_method not in ('微信', '支付宝', '现金', 'POS 刷卡') then
    raise exception 'bad_method' using errcode = 'P0001';
  end if;

  v_points := floor(v_payable * coalesce(cur.points_multiplier, 1));
  update public.orders set subtotal = v_subtotal, card_off = v_card_off, discount_off = v_discount_off,
    payable = v_payable, balance_paid = v_balance, pay_method = v_method, points_gained = v_points
  where id = v_order;
  update public.members set
    balance = balance - v_balance,
    total_spent = total_spent + v_payable,
    visit_count = visit_count + 1,
    last_visit_at = now(),
    points = points + v_points,
    updated_at = now()
  where id = m.id returning * into m;

  if v_payable > 0 or jsonb_array_length(v_covered) = 0 then
    insert into public.member_ledger (store_id, member_id, kind, amount, balance_delta, balance_after,
      points_delta, points_after, pay_method, operator, title, order_id, request_id)
    values (p_store, m.id, 'consume', v_payable, -v_balance, m.balance, v_points, m.points,
      v_method, p_operator, v_names, v_order, null);
  end if;
  for ln in select * from jsonb_array_elements(v_covered) loop
    insert into public.member_ledger (store_id, member_id, kind, balance_after, points_after, operator,
      title, note, order_id, ref_id)
    values (p_store, m.id, 'package_use', m.balance, m.points, p_operator, ln->>'name',
      '次卡抵扣 · 剩 ' || (ln->>'remaining') || ' 次', v_order, (ln->>'member_package_id')::uuid);
  end loop;

  v_up := public.member_spend_upgrade(p_store, m.id);
  return jsonb_build_object('order_id', v_order, 'items', v_names, 'subtotal', v_subtotal,
    'card_off', v_card_off, 'discount_off', v_discount_off, 'discount', coalesce(cur.discount, 1),
    'card_name', cur.name, 'payable', v_payable, 'balance_paid', v_balance, 'pay_method', v_method,
    'balance', m.balance, 'points_gained', v_points, 'upgraded_to', v_up, 'covered', v_covered,
    'repeated', false);
end;
$$;
revoke all on function public.checkout_order(uuid, uuid, jsonb, text, numeric, text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.checkout_order(uuid, uuid, jsonb, text, numeric, text, text, text, text, text) to service_role;
