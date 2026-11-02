-- 挂单：估价、保存 / 修改、取单结算（加项）、重复结算、重试幂等。
-- 在应用了全部迁移的空库里运行：psql -v ON_ERROR_STOP=1 -f supabase/tests/held_orders.sql
-- 预期：金卡 9 折估价 342 -> 挂单 -> 修改加项后估价 410.4 -> 取单结算扣余额一次 -> 再结算被拒 -> 同 request 重试返回原结果
-- -> 已结算挂单不能修改 -> 另一单取消后不再出现在待处理里。
\set ON_ERROR_STOP on
\pset format unaligned
\pset tuples_only on
insert into auth.users(id, phone, email) values ('aaaaaaaa-0000-0000-0000-000000000003','+8613900000003','c@x.cn');
insert into public.stores(owner_id,name,contact_name,contact_role) values ('aaaaaaaa-0000-0000-0000-000000000003','测试店C','陈明','店长');
select id as sid from public.stores where name='测试店C' \gset
insert into public.card_types (store_id, name, discount, upgrade_recharge, upgrade_cumulative, points_multiplier, color)
values (:'sid','金卡',0.9,null,null,1,'champagne');
insert into public.service_items(store_id,name,category,price) values (:'sid','精致洗车','洗车',68),(:'sid','内饰深度清洁','内饰',380);
select id as s1 from public.service_items where name='精致洗车' and store_id=:'sid' \gset
select id as s2 from public.service_items where name='内饰深度清洁' and store_id=:'sid' \gset
select public.create_member(:'sid','{"phone":"13816826021","name":"王建国"}'::jsonb,null) as mid \gset
select public.recharge_member(:'sid',:'mid',1000,0,'微信','陈明','','r1') ->> 'balance' as bal0;
-- 估价：内饰 380 * 0.9 = 342
select public.quote_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1))) ->> 'payable' as quote_342;
-- 挂单
select public.hold_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1)), '施工中', '车漆有划痕', '30 分钟', '沪A8K29M', null) as hid \gset
select 'hold: estimate=' || estimate || ' status=' || status || ' items=' || (select count(*) from public.held_order_items where held_order_id=:'hid') from public.held_orders where id=:'hid';
-- 修改：加一项精致洗车 68 -> (380+68)*0.9 = 403.2
select public.hold_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1), jsonb_build_object('service_id',:'s1','qty',1)), '待结算', '', '不提醒', '沪A8K29M', :'hid') = :'hid'::uuid as updated_same_id;
select 'hold: estimate=' || estimate || ' status=' || status || ' items=' || (select count(*) from public.held_order_items where held_order_id=:'hid') from public.held_orders where id=:'hid';
-- 没有项目被拒
do $$ begin perform public.hold_order((select id from public.stores where name='测试店C'),(select id from public.members limit 1),'[]'::jsonb,'待施工','','不提醒','',null); exception when sqlstate 'P0001' then raise notice 'empty lines blocked: %', sqlerrm; end $$;
-- 取单结算：再加一份精致洗车，余额支付 (380+68+68)*0.9 = 464.4
select public.settle_held_order(:'sid',:'hid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1), jsonb_build_object('service_id',:'s1','qty',2)), '会员余额', null, null, '沪A8K29M','','陈明','h1') ->> 'payable' as settled_payable;
select 'balance=' || balance || ' spent=' || total_spent from public.members where id=:'mid';
select 'hold closed=' || (settled_at is not null) || ' order_linked=' || (order_id is not null) from public.held_orders where id=:'hid';
-- 再结算被拒，余额不再变化
do $$ begin perform public.settle_held_order((select id from public.stores where name='测试店C'),(select id from public.held_orders limit 1),jsonb_build_array(jsonb_build_object('service_id',(select id from public.service_items where name='精致洗车' limit 1),'qty',1)),'现金',null,null,'','','x','h2'); exception when sqlstate 'P0001' then raise notice 'double settle blocked: %', sqlerrm; end $$;
-- 同一 request 重试：返回原结果，不重复扣
select public.settle_held_order(:'sid',:'hid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1), jsonb_build_object('service_id',:'s1','qty',2)), '会员余额', null, null, '沪A8K29M','','陈明','h1') ->> 'repeated' as retry_repeated;
select 'balance=' || balance from public.members where id=:'mid';
select count(*) || ' orders' from public.orders;
-- 已结算的挂单不能再修改
do $$ begin perform public.hold_order((select id from public.stores where name='测试店C'),(select id from public.members limit 1),jsonb_build_array(jsonb_build_object('service_id',(select id from public.service_items limit 1),'qty',1)),'待施工','','不提醒','',(select id from public.held_orders limit 1)); exception when sqlstate 'P0002' then raise notice 'closed hold not editable: %', sqlerrm; end $$;
