-- 散客挂单：挂单可以不关联会员（member_id 为空 = 散客），估价没有折扣和次卡抵扣，取单结算走散客收款。
alter table public.held_orders alter column member_id drop not null;

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
  if p_member is not null then
    select t.* into cur from public.members m join public.card_types t on t.id = m.card_type_id
    where m.id = p_member and m.store_id = p_store and m.deleted_at is null;
    if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  end if;
  for ln in select * from jsonb_array_elements(p_lines) loop
    v_qty := coalesce((ln->>'qty')::int, 1);
    select * into svc from public.service_items
    where id = (ln->>'service_id')::uuid and store_id = p_store and active;
    if not found then raise exception 'service_not_found' using errcode = 'P0002'; end if;
    v_line := svc.price * v_qty;
    v_subtotal := v_subtotal + v_line;
    if p_member is null then continue; end if; -- 散客：原价，没有折扣和次卡
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

-- p_member 为空 = 散客挂单：不能带次卡。
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
  if p_member is null and exists (
    select 1 from jsonb_array_elements(p_lines) l where nullif(l->>'member_package_id', '') is not null
  ) then
    raise exception 'walkin_package' using errcode = 'P0001';
  end if;
  v_quote := public.quote_order(p_store, p_member, p_lines);
  if p_hold is null then
    insert into public.held_orders (store_id, member_id, vehicle_plate, status, note, remind, estimate)
    values (p_store, p_member, coalesce(p_plate, ''), p_status, coalesce(p_note, ''), p_remind, (v_quote->>'payable')::numeric)
    returning id into v_id;
  else
    -- 修改时不能把会员挂单改成散客（或反过来）：会员是挂单的一部分
    update public.held_orders set vehicle_plate = coalesce(p_plate, ''), status = p_status,
      note = coalesce(p_note, ''), remind = p_remind, estimate = (v_quote->>'payable')::numeric, updated_at = now()
    where id = p_hold and store_id = p_store and settled_at is null and cancelled_at is null
      and member_id is not distinct from p_member
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

-- 取单结算：会员挂单走 checkout_order，散客挂单走 checkout_walkin（不能用余额 / 组合支付）。
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
  v_remark text;
begin
  select * into h from public.held_orders where id = p_hold and store_id = p_store for update;
  if not found then raise exception 'hold_not_found' using errcode = 'P0002'; end if;
  v_remark := coalesce(nullif(p_remark, ''), h.note);
  if h.settled_at is not null or h.cancelled_at is not null then
    -- 同一次点击重试：订单已经按这个 request 创建过时，直接返回第一次的结果
    if p_request is not null and exists (
      select 1 from public.orders where store_id = p_store and request_id = p_request
    ) then
      if h.member_id is null then
        return public.checkout_walkin(p_store, p_lines, p_method, p_plate, v_remark, p_operator, p_request);
      end if;
      return public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
        p_plate, p_remark, p_operator, p_request);
    end if;
    raise exception 'hold_closed' using errcode = 'P0001';
  end if;
  if h.member_id is null then
    v_res := public.checkout_walkin(p_store, p_lines, p_method, p_plate, v_remark, p_operator, p_request);
  else
    v_res := public.checkout_order(p_store, h.member_id, p_lines, p_method, p_balance_part, p_other,
      p_plate, v_remark, p_operator, p_request);
  end if;
  update public.held_orders set settled_at = now(), order_id = (v_res->>'order_id')::uuid, updated_at = now()
  where id = h.id;
  return v_res;
end;
$$;
