-- 次卡售卖 / 延期 / 退款、开单收银、累计消费自动升级的数据库测试。
-- 在应用了全部迁移的空库里运行：psql -v ON_ERROR_STOP=1 -f supabase/tests/member_orders.sql
-- 预期：充值 2300 -> 买次卡（余额）剩 1220、重试不重复、限购 1 份再买被拒 -> 开单（精致洗车次卡抵扣 +
-- 内饰 380 余额支付）-> 累计消费达标升金卡 -> 金卡 9 折 342、组合支付 -> 余额不足 / 次卡次数不够被拒
-- -> 延期 -> 退款 1026 到余额、重复退款被拒。
\set ON_ERROR_STOP on
\pset format unaligned
\pset tuples_only on
insert into auth.users(id, phone, email) values ('aaaaaaaa-0000-0000-0000-000000000002','+8613900000002','b@x.cn');
insert into public.stores(owner_id,name,contact_name,contact_role) values ('aaaaaaaa-0000-0000-0000-000000000002','测试店B','陈明','店长');
select id as sid from public.stores where name='测试店B' \gset
insert into public.card_types (store_id, name, discount, upgrade_recharge, upgrade_cumulative, points_multiplier, color)
values (:'sid','普通会员',1,null,null,1,'white'), (:'sid','金卡',0.9,null,1500,1,'champagne');
insert into public.service_items(store_id,name,category,price) values (:'sid','精致洗车','洗车',68),(:'sid','内饰深度清洁','内饰',380);
select id as s1 from public.service_items where name='精致洗车' and store_id=:'sid' \gset
select id as s2 from public.service_items where name='内饰深度清洁' and store_id=:'sid' \gset
select public.save_card_package(:'sid', null, '{"name":"精致洗车年卡","price":1080,"validity_months":12,"purchase_limit":1,"vehicle_scope":"全部车型","show_in_mini":true,"description":"","active":true}'::jsonb,
  jsonb_build_array(jsonb_build_object('service_id', :'s1', 'count', 20))) as pid \gset
select public.create_member(:'sid','{"phone":"13816826021","name":"王建国"}'::jsonb,null) as mid \gset
select public.recharge_member(:'sid',:'mid',2000,300,'微信','陈明','','r1') ->> 'balance' as bal_after_recharge;
-- 买次卡：余额 2300 付 1080
select (public.sell_package(:'sid',:'mid',:'pid','会员余额','陈明','sp1')) ->> 'balance' as bal_after_buy;
select 'member: spent=' || total_spent || ' points=' || points from public.members where id=:'mid';
-- 同一 request 重试
select (public.sell_package(:'sid',:'mid',:'pid','会员余额','陈明','sp1')) ->> 'repeated' as repeated;
select count(*)||' package rows' from public.member_packages;
-- 限购 1：再买失败
do $$ begin perform public.sell_package((select id from public.stores where name='测试店B'),(select id from public.members limit 1),(select id from public.card_packages limit 1),'现金','x','sp2'); exception when sqlstate 'P0001' then raise notice 'limit ok: %', sqlerrm; end $$;
select id as mp from public.member_packages limit 1 \gset
-- 开单：精致洗车(次卡抵扣) + 内饰深度清洁(折扣：普通会员无折扣) 余额支付
select public.checkout_order(:'sid',:'mid', jsonb_build_array(
  jsonb_build_object('service_id',:'s1','qty',1,'member_package_id',:'mp'),
  jsonb_build_object('service_id',:'s2','qty',1)), '会员余额', null, null, '沪A8K29M','', '陈明', 'o1');
select 'member: balance=' || balance || ' spent=' || total_spent || ' visits=' || visit_count || ' points=' || points || ' tier=' || (select name from public.card_types where id=card_type_id) from public.members where id=:'mid';
select 'pkg used=' || used_count from public.member_packages;
-- 累计消费 1080+380=1460 <1500：未升级。再单买精致洗车 现金，累计达标升金卡
select public.checkout_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s1','qty',1)), '现金', null, null, '', '', '陈明', 'o2') ->> 'upgraded_to' as up2;
select 'tier=' || (select name from public.card_types where id=card_type_id) || ' spent=' || total_spent from public.members where id=:'mid';
-- 金卡 9 折：内饰 380 -> 342，组合支付 余额 100 + 微信
select public.checkout_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1)), '组合支付', 100, '微信', '', '', '陈明', 'o3') ->> 'payable' as combo_payable;
select 'balance=' || balance from public.members where id=:'mid';
-- 余额不足
do $$ begin perform public.checkout_order((select id from public.stores where name='测试店B'),(select id from public.members limit 1), jsonb_build_array(jsonb_build_object('service_id',(select id from public.service_items where name='内饰深度清洁' limit 1),'qty',99)),'会员余额',null,null,'','','x','o4'); exception when sqlstate 'P0001' then raise notice 'balance check ok: %', sqlerrm; end $$;
-- 次卡次数不够
do $$ begin perform public.checkout_order((select id from public.stores where name='测试店B'),(select id from public.members limit 1), jsonb_build_array(jsonb_build_object('service_id',(select id from public.service_items where name='精致洗车' limit 1),'qty',50,'member_package_id',(select id from public.member_packages limit 1))),'现金',null,null,'','','x','o5'); exception when sqlstate 'P0001' then raise notice 'package count ok: %', sqlerrm; end $$;
-- 延期 30 天
select public.extend_package(:'sid', :'mp', 30, '会员长期出差', '陈明') ->> 'expires_at' is not null as extended;
-- 退款：实付 1080，已用 1 次 -> 1080 - 54 = 1026，退到余额
select public.refund_package(:'sid', :'mp', '储值余额', '会员不再需要', '陈明');
do $$ begin perform public.refund_package((select id from public.stores where name='测试店B'),(select id from public.member_packages limit 1),'原路退回','x','x'); exception when sqlstate 'P0001' then raise notice 'double refund blocked: %', sqlerrm; end $$;
select kind || ':' || coalesce(nullif(title,''),'-') from public.member_ledger order by created_at, id;
