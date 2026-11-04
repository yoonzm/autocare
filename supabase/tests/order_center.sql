-- 订单中心：统一订单列表 / 汇总口径 / 详情 / 消费订单整单退款。
-- 在应用了全部迁移的空库里运行：psql -v ON_ERROR_STOP=1 -f supabase/tests/order_center.sql
-- 预期（金卡 9 折）：充值 2000 送 300（微信）-> 买次卡 1080（余额）-> 余额开单 380*0.9=342 -> 次卡抵扣一单 ->
-- 散客现金 68；汇总 实收 = 2000 + 68 = 2068、储值抵扣 = 1080 + 342 = 1422 -> 退款消费单后余额 / 积分 / 累计消费回退，
-- 已退款不能再退；同一 request 重试不重复；筛选 / 搜索 / 分页；次卡退款也出现在退款里。
\set ON_ERROR_STOP on
\pset format unaligned
\pset tuples_only on
insert into auth.users(id, phone, email) values ('aaaaaaaa-0000-0000-0000-000000000004','+8613900000004','d@x.cn');
insert into public.stores(owner_id,name,contact_name,contact_role) values ('aaaaaaaa-0000-0000-0000-000000000004','测试店D','陈明','店长');
select id as sid from public.stores where name='测试店D' \gset
insert into public.card_types (store_id, name, discount, upgrade_recharge, upgrade_cumulative, points_multiplier, color)
values (:'sid','金卡',0.9,null,null,1,'champagne');
insert into public.service_items(store_id,name,category,price) values (:'sid','精致洗车','洗车',68),(:'sid','内饰深度清洁','内饰',380);
select id as s1 from public.service_items where name='精致洗车' and store_id=:'sid' \gset
select id as s2 from public.service_items where name='内饰深度清洁' and store_id=:'sid' \gset
select public.save_card_package(:'sid', null, '{"name":"精致洗车年卡","price":1080,"validity_months":12,"purchase_limit":1,"vehicle_scope":"全部车型","show_in_mini":true,"description":"","active":true}'::jsonb,
  jsonb_build_array(jsonb_build_object('service_id', :'s1', 'count', 20))) as pid \gset
select public.create_member(:'sid','{"phone":"13816826021","name":"王建国"}'::jsonb,null) as mid \gset
select public.recharge_member(:'sid',:'mid',2000,300,'微信','陈明','','r1') ->> 'balance' as bal_after_recharge;
select public.sell_package(:'sid',:'mid',:'pid','会员余额','陈明','sp1') ->> 'balance' as bal_after_package;
-- 余额开单 380 * 0.9 = 342
select public.checkout_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s2','qty',1)), '会员余额', null, null, '沪A8K29M', '', '陈明', 'o1') ->> 'order_id' as oid \gset
-- 次卡抵扣一次精致洗车
select id as mpid from public.member_packages where member_id=:'mid' \gset
select public.checkout_order(:'sid',:'mid', jsonb_build_array(jsonb_build_object('service_id',:'s1','qty',1,'member_package_id',:'mpid')), '微信', null, null, '沪A8K29M', '', '陈明', 'o2') ->> 'order_id' as oid2 \gset
-- 散客现金 68
select public.checkout_walkin(:'sid', jsonb_build_array(jsonb_build_object('service_id',:'s1','qty',1)), '现金', '沪B5566', '', '陈明', 'w1') ->> 'order_id' as wid \gset
select 'before refund: balance=' || balance || ' points=' || points || ' spent=' || total_spent || ' visits=' || visit_count from public.members where id=:'mid';
select 'package used=' || used_count from public.member_packages where id=:'mpid';

-- 今日范围（本地时区）
select date_trunc('day', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai' as d0 \gset
select (:'d0'::timestamptz + interval '1 day') as d1 \gset
-- 列表 + 汇总：4 种类型都出现，实收 2068（充值 2000 + 散客现金 68），储值抵扣 1422（次卡 1080 + 消费 342）
select 'feed: items=' || jsonb_array_length(f->'items') || ' received=' || (f->'summary'->>'received') || ' refunded=' || (f->'summary'->>'refunded')
  || ' net=' || (f->'summary'->>'net') || ' wechat=' || (f->'summary'->>'wechat') || ' cash=' || (f->'summary'->>'cash_pay') || ' balance=' || (f->'summary'->>'balance')
from (select public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all', '', '', '', '', null, 30) as f) t;
select 'kinds: ' || string_agg(distinct i->>'kind', ',' order by i->>'kind') from (select jsonb_array_elements(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','','','',null,30)->'items') i) t;
-- 类型 / 收款方式筛选
select 'consume only=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'consume','','','','',null,30)->'items');
select 'cash only=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','现金','','','',null,30)->'items');
select 'balance only=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','储值抵扣','','','',null,30)->'items');
-- 搜索：车牌 / 手机号 / 姓名
select 'search plate=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','','','沪B·5566',null,30)->'items');
select 'search phone=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','','','13816826021',null,30)->'items');
-- 分页：每页 2 条，多取 1 条判断还有下一页
select 'page size=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','','','',null,2)->'items') || ' (limit 2 -> 3 rows means more)';
-- 详情
select 'detail consume: status=' || (d->>'status') || ' amount=' || (d->>'amount') || ' pays=' || jsonb_array_length(d->'payments') || ' items=' || jsonb_array_length(d->'items') || ' can_refund=' || (d->>'can_refund') || ' no=' || (d->>'order_no')
from (select public.order_detail(:'sid','consume',:'oid') as d) t;
select 'detail recharge: amount=' || (d->>'amount') || ' gift=' || (d->>'gift') || ' can_refund=' || (d->>'can_refund')
from (select public.order_detail(:'sid','recharge',(select id from public.member_ledger where kind='recharge' limit 1)) as d) t;
select 'detail package: amount=' || (d->>'amount') || ' items=' || jsonb_array_length(d->'items') from (select public.order_detail(:'sid','package',:'mpid') as d) t;

-- 退款：非法原因被拒
do $$ begin perform public.refund_order((select id from public.stores where name='测试店D'),(select id from public.orders limit 1),'随便写','陈明','x'); exception when sqlstate 'P0001' then raise notice 'bad reason blocked: %', sqlerrm; end $$;
-- 余额开单（342）整单退款：余额 +342、积分扣回、累计消费回退
select public.refund_order(:'sid', :'oid', '服务问题', '陈明', 'rf1') as refunded;
select 'after refund: balance=' || balance || ' points=' || points || ' spent=' || total_spent || ' visits=' || visit_count from public.members where id=:'mid';
-- 重试返回第一次结果、不重复退
select public.refund_order(:'sid', :'oid', '服务问题', '陈明', 'rf1') ->> 'repeated' as retry_repeated;
select 'balance after retry=' || balance from public.members where id=:'mid';
-- 已退款不能再退（不同 request）
do $$ begin perform public.refund_order((select id from public.stores where name='测试店D'),(select id from public.orders where status='refunded' limit 1),'录入错误','陈明','rf2'); exception when sqlstate 'P0001' then raise notice 'double refund blocked: %', sqlerrm; end $$;
-- 次卡抵扣单退款：次数退回
select public.refund_order(:'sid', :'oid2', '会员不再需要', '陈明', 'rf3') ->> 'refund' as refund_package_use;
select 'package used after refund=' || used_count from public.member_packages where id=:'mpid';
-- 散客订单也能退（没有会员，不动任何余额）
select public.refund_order(:'sid', :'wid', '录入错误', '陈明', 'rf4') ->> 'refund' as walkin_refund;
-- 退款后：状态、列表、汇总
select 'order status=' || status || ' reason=' || refund_reason from public.orders where id=:'oid';
select 'feed after: received=' || (f->'summary'->>'received') || ' refunded=' || (f->'summary'->>'refunded') || ' net=' || (f->'summary'->>'net')
from (select public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all', '', '', '', '', null, 30) as f) t;
select 'refund rows=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'refund','','','','',null,30)->'items');
select 'status refunded rows=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','refunded','','',null,30)->'items');
select 'status completed rows=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','completed','','',null,30)->'items');
-- 次卡退款也进入退款
select public.refund_package(:'sid', :'mpid', '原路退回', '会员不再需要', '陈明') ->> 'refund' as package_refund;
select 'refund rows after package refund=' || jsonb_array_length(public.order_feed(:'sid', :'d0'::timestamptz, :'d1'::timestamptz, 'refund','','','','',null,30)->'items');
-- 经办人选项
select 'operators=' || public.order_operators(:'sid')::text;
-- 订单不存在
do $$ begin perform public.order_detail((select id from public.stores where name='测试店D'),'consume','00000000-0000-0000-0000-000000000000'); exception when sqlstate 'P0002' then raise notice 'missing order: %', sqlerrm; end $$;
-- 其他门店读不到
select 'other store feed=' || jsonb_array_length(public.order_feed('00000000-0000-0000-0000-000000000001', :'d0'::timestamptz, :'d1'::timestamptz, 'all','','','','',null,30)->'items');
