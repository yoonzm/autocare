-- 挂单：开单时先存下来，之后取单结算 / 加项 / 删除。
-- 技师、工位、预计完工依赖员工和工位模块，这里不存；到点提醒只记录选择，不会真的推送（通知模块未接入）。

create table if not exists public.held_orders (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  vehicle_plate text not null default '',
  status text not null default '待施工' check (status in ('待施工', '施工中', '待结算')),
  note text not null default '' check (length(note) <= 200),
  remind text not null default '不提醒' check (remind in ('不提醒', '30 分钟', '1 小时', '完工时')),
  -- 挂单时按当时的价格 / 折扣 / 次卡估算的应收，取单结算时会重新计算
  estimate numeric(12, 2) not null default 0,
  settled_at timestamptz,
  cancelled_at timestamptz,
  order_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists held_orders_store_open_idx
  on public.held_orders(store_id, created_at desc) where settled_at is null and cancelled_at is null;

create table if not exists public.held_order_items (
  held_order_id uuid not null references public.held_orders(id) on delete cascade,
  position int not null,
  service_id uuid references public.service_items(id) on delete set null,
  name text not null,
  qty int not null check (qty between 1 and 99),
  member_package_id uuid references public.member_packages(id) on delete set null,
  primary key (held_order_id, position)
);

alter table public.held_orders enable row level security;
alter table public.held_order_items enable row level security;
create policy held_orders_owner on public.held_orders for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
create policy held_order_items_owner on public.held_order_items for select to authenticated
  using (exists (select 1 from public.held_orders h join public.stores s on s.id = h.store_id
                 where h.id = held_order_id and s.owner_id = (select auth.uid())));
revoke all on public.held_orders, public.held_order_items from public, anon, authenticated;
grant select on public.held_orders, public.held_order_items to authenticated;
grant select, insert, update, delete on public.held_orders, public.held_order_items to service_role;

-- 估价：和开单（checkout_order）同样的算法，只读不扣。次卡抵扣按“会员有这张可用次卡且剩余次数够”判断。
create or replace function public.quote_order(p_store uuid, p_member uuid, p_lines jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  cur public.card_types;
  ln jsonb;
  svc public.service_items;
  v_qty int;
  v_line numeric;
  v_subtotal numeric := 0;
  v_card_off numeric := 0;
  v_discount_off numeric := 0;
  v_ok boolean;
begin
  select t.* into cur from public.members m join public.card_types t on t.id = m.card_type_id
  where m.id = p_member and m.store_id = p_store and m.deleted_at is null;
  if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  for ln in select * from jsonb_array_elements(p_lines) loop
    v_qty := coalesce((ln->>'qty')::int, 1);
    select * into svc from public.service_items
    where id = (ln->>'service_id')::uuid and store_id = p_store and active;
    if not found then raise exception 'service_not_found' using errcode = 'P0002'; end if;
    v_line := svc.price * v_qty;
    v_subtotal := v_subtotal + v_line;
    v_ok := false;
    if nullif(ln->>'member_package_id', '') is not null then
      select exists (
        select 1 from public.member_packages p
        join public.member_package_items i on i.member_package_id = p.id
        where p.id = (ln->>'member_package_id')::uuid and p.store_id = p_store and p.member_id = p_member
          and p.refunded_at is null and (p.expires_at is null or p.expires_at > now())
          and i.service_id = svc.id and i.total - i.used >= v_qty
      ) into v_ok;
    end if;
    if v_ok then
      v_card_off := v_card_off + v_line;
    else
      v_discount_off := v_discount_off + round(v_line * (1 - coalesce(cur.discount, 1)), 2);
    end if;
  end loop;
  return jsonb_build_object('subtotal', v_subtotal, 'card_off', v_card_off, 'discount_off', v_discount_off,
    'payable', greatest(v_subtotal - v_card_off - v_discount_off, 0));
end;
$$;
revoke all on function public.quote_order(uuid, uuid, jsonb) from public, anon, authenticated;
grant execute on function public.quote_order(uuid, uuid, jsonb) to service_role;

-- 挂单保存：p_hold 为空 = 新建，否则修改这张还没结算的挂单（整单替换明细）。
-- 错误：P0002 = 会员 / 服务 / 挂单不存在；P0001 = 没有项目。
create or replace function public.hold_order(
  p_store uuid, p_member uuid, p_lines jsonb, p_status text, p_note text, p_remind text,
  p_plate text, p_hold uuid
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_quote jsonb;
  ln jsonb;
  svc public.service_items;
  v_pos int := 0;
begin
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'no_items' using errcode = 'P0001';
  end if;
  v_quote := public.quote_order(p_store, p_member, p_lines);
  if p_hold is null then
    insert into public.held_orders (store_id, member_id, vehicle_plate, status, note, remind, estimate)
    values (p_store, p_member, coalesce(p_plate, ''), p_status, coalesce(p_note, ''), p_remind, (v_quote->>'payable')::numeric)
    returning id into v_id;
  else
    update public.held_orders set member_id = p_member, vehicle_plate = coalesce(p_plate, ''), status = p_status,
      note = coalesce(p_note, ''), remind = p_remind, estimate = (v_quote->>'payable')::numeric, updated_at = now()
    where id = p_hold and store_id = p_store and settled_at is null and cancelled_at is null
    returning id into v_id;
    if v_id is null then raise exception 'hold_not_found' using errcode = 'P0002'; end if;
    delete from public.held_order_items where held_order_id = v_id;
  end if;
  for ln in select * from jsonb_array_elements(p_lines) loop
    select * into svc from public.service_items where id = (ln->>'service_id')::uuid and store_id = p_store;
    insert into public.held_order_items (held_order_id, position, service_id, name, qty, member_package_id)
    values (v_id, v_pos, svc.id, svc.name, coalesce((ln->>'qty')::int, 1), nullif(ln->>'member_package_id', '')::uuid);
    v_pos := v_pos + 1;
  end loop;
  return v_id;
end;
$$;
revoke all on function public.hold_order(uuid, uuid, jsonb, text, text, text, text, uuid) from public, anon, authenticated;
grant execute on function public.hold_order(uuid, uuid, jsonb, text, text, text, text, uuid) to service_role;

-- 取单结算：锁住挂单，用传入的明细（可以加项）调用 checkout_order，成功后关闭挂单——同一个事务。
-- 错误：P0002 = 挂单不存在；P0001 = 挂单已处理；其余错误同 checkout_order。
create or replace function public.settle_held_order(
  p_store uuid, p_hold uuid, p_lines jsonb, p_method text, p_balance_part numeric, p_other text,
  p_plate text, p_remark text, p_operator text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  h public.held_orders;
  v_res jsonb;
begin
  select * into h from public.held_orders where id = p_hold and store_id = p_store for update;
  if not found then raise exception 'hold_not_found' using errcode = 'P0002'; end if;
  if h.settled_at is not null or h.cancelled_at is not null then
    -- 同一次点击重试：订单已经按这个 request 创建过时，直接返回第一次的结果
    if p_request is not null and exists (
      select 1 from public.orders where store_id = p_store and request_id = p_request
    ) then
      return public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
        p_plate, p_remark, p_operator, p_request);
    end if;
    raise exception 'hold_closed' using errcode = 'P0001';
  end if;
  v_res := public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
    p_plate, coalesce(nullif(p_remark, ''), h.note), p_operator, p_request);
  update public.held_orders set settled_at = now(), order_id = (v_res->>'order_id')::uuid, updated_at = now()
  where id = h.id;
  return v_res;
end;
$$;
revoke all on function public.settle_held_order(uuid, uuid, jsonb, text, numeric, text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.settle_held_order(uuid, uuid, jsonb, text, numeric, text, text, text, text, text) to service_role;
