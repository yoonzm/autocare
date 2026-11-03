-- 应用全部迁移后执行；事务回滚，不留下测试数据。
begin;
do $$
declare
  owner1 uuid := gen_random_uuid(); owner2 uuid := gen_random_uuid();
  shop uuid; other_shop uuid; tier uuid; member uuid; result jsonb;
  today date := (now() at time zone 'Asia/Shanghai')::date;
  midnight timestamptz;
begin
  midnight := today::timestamp at time zone 'Asia/Shanghai';
  insert into auth.users(id) values(owner1), (owner2);
  insert into public.stores(owner_id, name) values(owner1, '首页统计测试') returning id into shop;
  insert into public.stores(owner_id, name) values(owner2, '隔离门店') returning id into other_shop;
  result := public.merchant_home_stats(shop);
  assert (result->>'revenue')::numeric = 0;
  assert (result->>'orders')::int = 0;
  assert (result->>'average')::numeric = 0;
  assert result->'change_percent' = 'null'::jsonb;
  assert result->'daily_revenue' = '[0,0,0,0,0,0,0]'::jsonb;
  insert into public.card_types(store_id, name, discount) values(shop, '普通会员', 1) returning id into tier;
  insert into public.members(store_id, phone, name, card_type_id, created_at)
    values(shop, '13900008888', '测试会员', tier, midnight) returning id into member;
  -- 今天午夜包含、明天午夜排除、昨日最后一刻不计入今天；超过 REST 默认 1000 条也须全量聚合。
  insert into public.orders(store_id, payable, created_at)
    select shop, 1, midnight from generate_series(1, 1001);
  insert into public.orders(store_id, payable, created_at) values
    (shop, 12.34, midnight), (shop, 99999, midnight + interval '1 day'),
    (shop, 33, midnight - interval '1 microsecond'),
    (shop, 100, midnight - interval '7 days'), (other_shop, 90000, midnight);
  insert into public.member_ledger(store_id, member_id, kind, amount, gift, created_at) values
    (shop, member, 'recharge', 600, 60, midnight),
    (shop, member, 'adjust_points', 999, 0, midnight),
    (shop, member, 'recharge', 1000, 0, midnight - interval '1 microsecond');
  result := public.merchant_home_stats(shop);
  assert (result->>'revenue')::numeric = 1013.34, result::text;
  assert (result->>'orders')::int = 1002;
  assert (result->>'average')::numeric = 1.01;
  assert (result->>'new_members')::int = 1;
  assert (result->>'change_percent')::numeric = 913.3;
  assert (result->>'recharge')::numeric = 600; -- 排除赠送、其他类型和昨天充值。
  assert jsonb_array_length(result->'daily_revenue') = 7;
  assert (result->'daily_revenue'->>5)::numeric = 33;
  assert (result->'daily_revenue'->>6)::numeric = 1013.34;
  assert not has_function_privilege('anon', 'public.merchant_home_stats(uuid)', 'execute');
  assert not has_function_privilege('authenticated', 'public.merchant_home_stats(uuid)', 'execute');
  assert has_function_privilege('service_role', 'public.merchant_home_stats(uuid)', 'execute');
end $$;
rollback;
