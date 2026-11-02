-- 散客开单：不记会员、没有折扣和次卡抵扣，只能用微信 / 支付宝 / 现金 / POS 刷卡收款，订单不关联会员。
-- 价格同样只由服务端的服务价目表算；同一次点击的 request_id 重试返回第一次的结果。
create or replace function public.checkout_walkin(
  p_store uuid, p_lines jsonb, p_method text, p_plate text, p_remark text, p_operator text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  prior public.orders;
  ln jsonb;
  svc public.service_items;
  v_qty int;
  v_pos int := 0;
  v_subtotal numeric := 0;
  v_order uuid;
  v_names text := '';
  v_line numeric;
begin
  if p_request is not null then
    select * into prior from public.orders where store_id = p_store and request_id = p_request;
    if found then
      return jsonb_build_object('order_id', prior.id, 'payable', prior.payable, 'repeated', true);
    end if;
  end if;
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'no_items' using errcode = 'P0002';
  end if;
  if coalesce(p_method, '') not in ('微信', '支付宝', '现金', 'POS 刷卡') then
    raise exception 'bad_method' using errcode = 'P0001';
  end if;

  insert into public.orders (store_id, member_id, vehicle_plate, remark, operator, request_id, pay_method)
  values (p_store, null, coalesce(p_plate, ''), coalesce(p_remark, ''), p_operator, p_request, p_method)
  returning id into v_order;

  for ln in select * from jsonb_array_elements(p_lines) loop
    v_qty := coalesce((ln->>'qty')::int, 1);
    select * into svc from public.service_items
    where id = (ln->>'service_id')::uuid and store_id = p_store and active;
    if not found then raise exception 'service_not_found' using errcode = 'P0002'; end if;
    v_line := svc.price * v_qty;
    v_subtotal := v_subtotal + v_line;
    v_names := v_names || case when v_names = '' then '' else ' · ' end || svc.name;
    insert into public.order_items (order_id, position, service_id, name, unit_price, qty, line_total, member_package_id)
    values (v_order, v_pos, svc.id, svc.name, svc.price, v_qty, v_line, null);
    v_pos := v_pos + 1;
  end loop;

  update public.orders set subtotal = v_subtotal, payable = v_subtotal where id = v_order;
  return jsonb_build_object('order_id', v_order, 'items', v_names, 'subtotal', v_subtotal, 'card_off', 0,
    'discount_off', 0, 'discount', 1, 'card_name', '散客', 'payable', v_subtotal, 'balance_paid', 0,
    'pay_method', p_method, 'points_gained', 0, 'covered', '[]'::jsonb, 'repeated', false);
end;
$$;
revoke all on function public.checkout_walkin(uuid, jsonb, text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.checkout_walkin(uuid, jsonb, text, text, text, text, text) to service_role;
