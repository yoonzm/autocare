-- 应用全部迁移后执行；事务回滚，不留下测试数据。
begin;
do $$
declare
  owner1 uuid := gen_random_uuid(); owner2 uuid := gen_random_uuid();
  shop uuid; other_shop uuid; tier uuid; member uuid; result jsonb;
  coat uuid; wash uuid; wrap uuid; interior uuid; o uuid;
  today date := (now() at time zone 'Asia/Shanghai')::date;
  midnight timestamptz := ((now() at time zone 'Asia/Shanghai')::date)::timestamp at time zone 'Asia/Shanghai';
  monday date := date_trunc('week', (now() at time zone 'Asia/Shanghai')::date)::date;
  mstart timestamptz := (date_trunc('week', (now() at time zone 'Asia/Shanghai')::date)::date)::timestamp at time zone 'Asia/Shanghai';
begin
  insert into auth.users(id) values(owner1), (owner2);
  insert into public.stores(owner_id, name) values(owner1, '营业统计测试') returning id into shop;
  insert into public.stores(owner_id, name) values(owner2, '隔离门店') returning id into other_shop;

  -- 空门店：零值而不是 null，对比为 null，构成四项都在。
  result := public.merchant_business_stats(shop, 'week');
  assert (result->>'revenue')::numeric = 0 and (result->>'orders')::int = 0, result::text;
  assert result->'change_percent' = 'null'::jsonb and result->'member_share' = 'null'::jsonb;
  assert jsonb_array_length(result->'composition') = 4;
  assert (result->'composition'->0->>'amount')::numeric = 0;

  insert into public.card_types(store_id, name, discount) values(shop, '普通会员', 1) returning id into tier;
  insert into public.members(store_id, phone, name, card_type_id) values(shop, '13900008888', '测试会员', tier) returning id into member;
  insert into public.service_items(store_id, name, category, price) values(shop, '镀晶', '镀晶镀膜', 1000) returning id into coat;
  insert into public.service_items(store_id, name, category, price) values(shop, '洗车', '洗车', 100) returning id into wash;
  insert into public.service_items(store_id, name, category, price) values(shop, '车衣', '贴膜', 5000) returning id into wrap;
  insert into public.service_items(store_id, name, category, price) values(shop, '内饰', '内饰', 300) returning id into interior;

  -- 今天 00:01（放在零点后，任何时间运行都已过去）：会员单，镀晶 1000 + 洗车 100，九折后应收 990，按 10:1 摊到两个分类（900 / 90）。
  insert into public.orders(store_id, member_id, subtotal, payable, created_at)
    values(shop, member, 1100, 990, midnight + interval '1 minute') returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total)
    values(o, 0, coat, '镀晶', 1000, 1, 1000), (o, 1, wash, '洗车', 100, 1, 100);
  -- 同在 00:01：散客单，内饰 300；另一单只有次卡抵扣行，应收 0（仍计一单）。
  insert into public.orders(store_id, subtotal, payable, created_at)
    values(shop, 300, 300, midnight + interval '1 minute') returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total)
    values(o, 0, interior, '内饰', 300, 1, 300);
  insert into public.orders(store_id, member_id, subtotal, payable, created_at)
    values(shop, member, 100, 0, midnight + interval '1 minute') returning id into o;
  -- 已删除服务（service_id 为空）归入“其他”，别的门店与明天的订单不计入。
  insert into public.orders(store_id, subtotal, payable, created_at)
    values(shop, 50, 50, midnight + interval '1 minute') returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total)
    values(o, 0, null, '已删服务', 50, 1, 50);
  insert into public.orders(store_id, payable, created_at) values
    (other_shop, 90000, midnight + interval '1 minute'),
    (shop, 99999, midnight + interval '1 day');
  -- 上周同日 400。
  insert into public.orders(store_id, payable, created_at) values(shop, 400, midnight - interval '7 days' + interval '9 hours');

  result := public.merchant_business_stats(shop, 'today');
  assert result->>'unit' = 'hour' and jsonb_array_length(result->'current') = 24, result::text;
  assert (result->>'revenue')::numeric = 1340 and (result->>'orders')::int = 4, result::text;
  assert (result->>'change_percent')::numeric = 235.0, result::text; -- (1340-400)/400
  assert (result->>'member_share')::numeric = 73.9, result::text;   -- 990/1340
  assert (result->'previous'->>9)::numeric = 400;
  assert (result->'current'->>0)::numeric = 1340 and result->'current'->>1 is not null = (extract(hour from now() at time zone 'Asia/Shanghai') >= 1);
  assert (result->'composition'->0->>'amount')::numeric = 900.00, result::text; -- coating
  assert (result->'composition'->2->>'amount')::numeric = 90.00, result::text;  -- wash
  assert (result->'composition'->3->>'amount')::numeric = 350.00, result::text; -- other：内饰 300 + 已删服务 50
  assert (result->'composition'->1->>'amount')::numeric = 0;
  -- 构成合计等于有明细订单的营业额（零应收的次卡单没有可摊行）。
  assert (select sum((c->>'amount')::numeric) from jsonb_array_elements(result->'composition') c) = 1340;

  -- 本周：包含今天，周一起算；对比期是上周同期。
  result := public.merchant_business_stats(shop, 'week');
  assert (result->>'from')::date = monday and (result->>'to')::date = today, result::text;
  assert jsonb_array_length(result->'current') = today - monday + 1;
  assert jsonb_array_length(result->'previous') = today - monday + 1;
  assert (result->>'prev_from')::date = monday - 7;
  assert (result->>'revenue')::numeric >= 1340;

  -- 本月：从 1 号起；上月同期不超过上月末。
  result := public.merchant_business_stats(shop, 'month');
  assert (result->>'from')::date = date_trunc('month', today)::date, result::text;
  assert (result->>'prev_to')::date <= date_trunc('month', today)::date - 1, result::text;
  assert (result->>'prev_to')::date >= (result->>'prev_from')::date;

  -- 自定义：边界含首尾；对比期为紧邻其前的等长时段；非法范围被拒绝。
  result := public.merchant_business_stats(shop, 'custom', today - 7, today - 7);
  assert (result->>'revenue')::numeric = 400 and (result->>'orders')::int = 1, result::text;
  assert (result->>'prev_from')::date = today - 8 and (result->>'prev_to')::date = today - 8;
  result := public.merchant_business_stats(shop, 'custom', today - 1, today);
  assert (result->>'revenue')::numeric = 1340, result::text; -- 昨天无订单，今天 1340；明天的订单不计入
  assert jsonb_array_length(result->'current') = 2 and result->'current'->>0 = '0';
  begin perform public.merchant_business_stats(shop, 'custom', today, today - 1); assert false;
  exception when sqlstate '22023' then null; end;
  begin perform public.merchant_business_stats(shop, 'custom', today, today + 1); assert false;
  exception when sqlstate '22023' then null; end;
  begin perform public.merchant_business_stats(shop, 'custom', today - 400, today); assert false;
  exception when sqlstate '22023' then null; end;
  begin perform public.merchant_business_stats(shop, 'year'); assert false;
  exception when sqlstate '22023' then null; end;

  -- 与首页口径一致：今日营业额相同。
  assert (public.merchant_business_stats(shop, 'today')->>'revenue')::numeric
       = (public.merchant_home_stats(shop)->>'revenue')::numeric;

  assert not has_function_privilege('anon', 'public.merchant_business_stats(uuid,text,date,date)', 'execute');
  assert not has_function_privilege('authenticated', 'public.merchant_business_stats(uuid,text,date,date)', 'execute');
  assert has_function_privilege('service_role', 'public.merchant_business_stats(uuid,text,date,date)', 'execute');
end $$;
rollback;
