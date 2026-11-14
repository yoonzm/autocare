-- 应用全部迁移后执行；事务回滚，不留下测试数据。
begin;
do $$
declare
  owner1 uuid := gen_random_uuid(); owner2 uuid := gen_random_uuid();
  shop uuid; other_shop uuid; tier uuid; other_tier uuid;
  a uuid; b uuid; c uuid; d uuid; x uuid;
  coat uuid; wrap uuid; wash uuid; pkg uuid; o uuid; ids jsonb;
  now_at timestamptz := now();
begin
  insert into auth.users(id) values(owner1), (owner2);
  insert into public.stores(owner_id, name) values(owner1, '会员筛选测试') returning id into shop;
  insert into public.stores(owner_id, name) values(owner2, '隔离门店') returning id into other_shop;
  insert into public.card_types(store_id, name, discount) values(shop, '普通', 1) returning id into tier;
  insert into public.card_types(store_id, name, discount) values(other_shop, '普通', 1) returning id into other_tier;
  insert into public.members(store_id, phone, name, card_type_id) values(shop, '13900000001', 'A', tier) returning id into a;
  insert into public.members(store_id, phone, name, card_type_id) values(shop, '13900000002', 'B', tier) returning id into b;
  insert into public.members(store_id, phone, name, card_type_id) values(shop, '13900000003', 'C', tier) returning id into c;
  insert into public.members(store_id, phone, name, card_type_id) values(shop, '13900000004', 'D', tier) returning id into d;
  insert into public.members(store_id, phone, name, card_type_id) values(other_shop, '13900000009', 'X', other_tier) returning id into x;
  insert into public.service_items(store_id, name, category, price) values(shop, '镀晶', '镀晶镀膜', 1000) returning id into coat;
  insert into public.service_items(store_id, name, category, price) values(shop, '车衣', '贴膜', 5000) returning id into wrap;
  insert into public.service_items(store_id, name, category, price) values(shop, '洗车', '洗车', 50) returning id into wash;
  insert into public.card_packages(store_id, name, price) values(shop, '次卡', 100) returning id into pkg;

  -- 次卡：A 6 天后到期（剩 3 次）；B 剩 2 次不过期；C 全部用完；D 有一张用完的退款卡（不算）
  insert into public.member_packages(store_id, member_id, package_id, name, price_paid, total_count, used_count, expires_at)
    values(shop, a, pkg, '次卡', 100, 5, 2, now_at + interval '6 days');
  insert into public.member_packages(store_id, member_id, package_id, name, price_paid, total_count, used_count)
    values(shop, b, pkg, '次卡', 100, 5, 3);
  insert into public.member_packages(store_id, member_id, package_id, name, price_paid, total_count, used_count)
    values(shop, c, pkg, '次卡', 100, 5, 5);
  insert into public.member_packages(store_id, member_id, package_id, name, price_paid, total_count, used_count, refunded_at)
    values(shop, d, pkg, '次卡', 100, 5, 5, now_at);

  ids := (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_pkg_expiring);
  assert ids = jsonb_build_array(a), ids::text;
  ids := (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_pkg_low);
  assert ids = jsonb_build_array(b), ids::text;
  ids := (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_pkg_used_up);
  assert ids = jsonb_build_array(c), ids::text;
  -- 8 天后到期的不算 7 天内；已过期的不算
  insert into public.member_packages(store_id, member_id, package_id, name, price_paid, total_count, used_count, expires_at)
    values(shop, d, pkg, '次卡', 100, 5, 1, now_at + interval '8 days'),
          (shop, d, pkg, '次卡', 100, 5, 1, now_at - interval '1 day');
  ids := (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_pkg_expiring);
  assert ids = jsonb_build_array(a), ids::text;
  -- D 现在既不是 used_up（有剩余次数的卡）也不是 low（剩 4 次）
  assert not (select f_pkg_used_up from public.members_filterable where id = d), 'D used_up';

  -- 车辆：A 新能源 1 辆；B 两辆燃油；C 无车辆
  insert into public.member_vehicles(store_id, member_id, plate, energy) values(shop, a, '粤B12345D', 'ev');
  insert into public.member_vehicles(store_id, member_id, plate, energy) values(shop, b, '粤B11111', 'fuel'), (shop, b, '粤B22222', 'fuel');
  assert (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_ev) = jsonb_build_array(a);
  assert (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_multi) = jsonb_build_array(b);

  -- 订单：A 做过镀晶；B 一年前做过车衣；C 5 年前做过车衣；D 只洗车
  insert into public.orders(store_id, member_id, subtotal, payable) values(shop, a, 1000, 1000) returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total) values(o, 0, coat, '镀晶', 1000, 1, 1000);
  insert into public.orders(store_id, member_id, subtotal, payable, created_at) values(shop, b, 5000, 5000, now_at - interval '12 months') returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total) values(o, 0, wrap, '车衣', 5000, 1, 5000);
  insert into public.orders(store_id, member_id, subtotal, payable, created_at) values(shop, c, 5000, 5000, now_at - interval '60 months') returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total) values(o, 0, wrap, '车衣', 5000, 1, 5000);
  insert into public.orders(store_id, member_id, subtotal, payable) values(shop, d, 50, 50) returning id into o;
  insert into public.order_items(order_id, position, service_id, name, unit_price, qty, line_total) values(o, 0, wash, '洗车', 50, 1, 50);
  assert (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_coating) = jsonb_build_array(a);
  assert (select coalesce(jsonb_agg(id order by name), '[]'::jsonb) from public.members_filterable where store_id = shop and deleted_at is null and f_wrap_warranty) = jsonb_build_array(b);
  -- 两个条件取交集
  assert (select count(*) from public.members_filterable where store_id = shop and f_pkg_expiring and f_ev) = 1;
  assert (select count(*) from public.members_filterable where store_id = shop and f_pkg_expiring and f_multi) = 0;
  -- 本店只看到本店（调用方负责按 store_id 过滤；视图含全部门店）
  assert (select count(*) from public.members_filterable where store_id = other_shop and f_pkg_used_up) = 0;
  -- 视图与 members 的列一致（members 加列后需重建视图）
  assert (select count(*) from information_schema.columns where table_schema = 'public' and table_name = 'members')
       = (select count(*) from information_schema.columns where table_schema = 'public' and table_name = 'members_filterable') - 7,
    'members_filterable columns out of date';
end $$;
rollback;
