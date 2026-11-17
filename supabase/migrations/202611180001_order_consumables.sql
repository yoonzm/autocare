-- 服务耗材：不走「完工」环节的订单（直接开单、快速开单、取单结算）在收银结算成功后按订单扣减。
-- 一张订单只扣一次（orders.consumables 为已处理标记）；预约在员工完工时已扣过的，转订单时不再重复扣。
-- 扣减数量 = 订单行数量 × 该服务的单次耗材用量，按商品合并；库存不足扣到 0，不拦收银，失败只记录。
alter table public.orders add column if not exists consumables jsonb;

create function public.service_consumables_deduct_order(p_store uuid, p_order uuid, p_operator text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare o public.orders; r record; use_q numeric; lines jsonb := '[]'; short jsonb := '[]'; note text := '';
  doc jsonb; err text; result jsonb;
begin
  select * into o from public.orders where id = p_order and store_id = p_store for update;
  if not found or o.consumables is not null then return o.consumables; end if;
  -- 预约已在员工完工时扣过：只标记，不重复扣。
  if coalesce(current_setting('autocare.consumables_done', true), '') = 'on' then
    perform set_config('autocare.consumables_done', 'off', true);
    result := jsonb_build_object('skipped', 'appointment_finished');
    update public.orders set consumables = result where id = p_order;
    return result;
  end if;
  begin
    for r in
      select c.product_id, sum(c.quantity * i.qty) as need, max(p.name) as name, max(p.unit) as unit, max(p.stock) as stock,
        bool_and(p.active) as active, bool_and(p.allow_decimal) as allow_decimal
      from public.order_items i
      join public.service_consumables c on c.service_id = i.service_id and c.store_id = p_store
      join public.inventory_products p on p.id = c.product_id and p.store_id = p_store
      where i.order_id = p_order
      group by c.product_id
    loop
      if not r.active then
        short := short || jsonb_build_object('product_id', r.product_id, 'name', r.name, 'unit', r.unit, 'need', r.need, 'have', 0, 'reason', '商品已停用');
        continue;
      end if;
      use_q := least(r.need, r.stock);
      if not r.allow_decimal then use_q := floor(use_q); end if;
      use_q := round(use_q, 3);
      if use_q > 0 then lines := lines || jsonb_build_object('id', r.product_id, 'quantity', use_q); end if;
      if use_q < r.need then
        short := short || jsonb_build_object('product_id', r.product_id, 'name', r.name, 'unit', r.unit, 'need', r.need, 'have', r.stock);
        note := note || case when note = '' then '' else '、' end || r.name || '缺 ' || trim(trailing '.' from trim(trailing '0' from (r.need - use_q)::text)) || r.unit;
      end if;
    end loop;
    if jsonb_array_length(lines) > 0 then
      doc := public.inventory_document_save(p_store, gen_random_uuid(), 'out', jsonb_build_object(
        'lines', lines, 'reason', '施工领用', 'operator', coalesce(nullif(p_operator, ''), '收银') || '（收银自动扣减）',
        'note', left('收银自动扣减' || case when note = '' then '' else ' · 库存不足：' || note end, 200)), 0, true);
    end if;
  exception when others then
    err := sqlerrm; doc := null;
  end;
  result := jsonb_build_object('document_id', doc->>'id', 'deducted', case when doc is null then '[]'::jsonb else lines end,
    'short', short, 'error', err);
  update public.orders set consumables = result where id = p_order;
  return result;
end $$;
revoke all on function public.service_consumables_deduct_order(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.service_consumables_deduct_order(uuid, uuid, text) to service_role;

do $$
declare def text; patched text;
begin
  -- 会员开单
  select pg_get_functiondef('public.checkout_order(uuid,uuid,jsonb,text,numeric,text,text,text,text,text)'::regprocedure) into def;
  patched := replace(def, '  v_up := public.member_spend_upgrade(p_store, m.id);',
    '  v_up := public.member_spend_upgrade(p_store, m.id);' || E'\n  perform public.service_consumables_deduct_order(p_store, v_order, p_operator);');
  if patched = def then raise exception 'checkout_order anchor not found'; end if;
  execute patched;

  -- 散客开单
  select pg_get_functiondef('public.checkout_walkin(uuid,jsonb,text,text,text,text,text)'::regprocedure) into def;
  patched := replace(def, '  update public.orders set subtotal = v_subtotal, payable = v_subtotal where id = v_order;',
    '  update public.orders set subtotal = v_subtotal, payable = v_subtotal where id = v_order;' || E'\n  perform public.service_consumables_deduct_order(p_store, v_order, p_operator);');
  if patched = def then raise exception 'checkout_walkin anchor not found'; end if;
  execute patched;

  -- 预约转订单：完工时已扣过则标记跳过
  select pg_get_functiondef('public.checkout_appointment(uuid,uuid,jsonb,text,numeric,text,text,text,text)'::regprocedure) into def;
  patched := replace(def, '  if a.member_id is null then',
    '  perform set_config(''autocare.consumables_done'', case when exists(select 1 from public.appointment_work w where w.appointment_id = p_id and w.consumables is not null) then ''on'' else ''off'' end, true);' || E'\n  if a.member_id is null then');
  if patched = def then raise exception 'checkout_appointment anchor not found'; end if;
  execute patched;
end $$;
