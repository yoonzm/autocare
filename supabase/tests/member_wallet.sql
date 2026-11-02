-- 会员钱包的数据库测试：办卡、充值（赠送、积分、幂等重试）、自动升级、手动调整。
-- 在一个已应用全部迁移的空库里运行：psql -v ON_ERROR_STOP=1 -f supabase/tests/member_wallet.sql
-- 最后一条（积分不足）预期报错 points_not_enough。需要先有 auth.users 表（Supabase 自带）。
-- 预期输出：普通会员 -> 充值 1000 送 100（积分 1000，不升级）-> 同一个 request_id 重试不重复入账
-- -> 充值 5000 送 1000 直接升到金卡 -> 再充 2000 不降级 -> 手动降到银卡并扣 500 积分 -> 扣过头报错。
\set ON_ERROR_STOP on
\pset format unaligned
\pset tuples_only on
insert into auth.users(id, phone, email) values ('aaaaaaaa-0000-0000-0000-000000000001','+8613900000001','a@x.cn');
insert into public.stores(owner_id,name) values ('aaaaaaaa-0000-0000-0000-000000000001','测试店');
select id as sid from public.stores limit 1 \gset
\echo store :sid
insert into public.card_types (store_id, name, discount, upgrade_recharge, upgrade_cumulative, points_multiplier, color)
values (:'sid','普通会员',1,null,null,1,'white'), (:'sid','银卡',0.98,2000,3000,1,'silver'),
       (:'sid','金卡',0.95,5000,10000,1.5,'champagne'), (:'sid','黑金卡',0.9,10000,30000,2,'black');
select public.create_member(:'sid', '{"phone":"13816826021","name":"王建国"}'::jsonb, null) as mid \gset
select 'tier=' || t.name || ' balance=' || m.balance from public.members m join public.card_types t on t.id=m.card_type_id where m.id=:'mid';
-- 充值 1000 + 赠送 100，普通会员 1 倍：积分 1000，不升级（门槛 2000）
select public.recharge_member(:'sid', :'mid', 1000, 100, '微信', '陈明（店长）', '', 'req-1');
-- 同一个 request_id 重试：不重复入账
select public.recharge_member(:'sid', :'mid', 1000, 100, '微信', '陈明（店长）', '', 'req-1');
select 'after-retry balance=' || balance || ' points=' || points || ' recharged=' || total_recharged from public.members where id=:'mid';
-- 充值 5000 + 1000 赠送：单次充值达金卡门槛 -> 升到金卡（不会停在银卡）
select public.recharge_member(:'sid', :'mid', 5000, 1000, '现金', '陈明（店长）', '', 'req-2');
select 'tier=' || t.name || ' balance=' || m.balance || ' points=' || m.points from public.members m join public.card_types t on t.id=m.card_type_id where m.id=:'mid';
-- 再充 2000：不降级
select public.recharge_member(:'sid', :'mid', 2000, 300, '微信', '陈明（店长）', '', 'req-3') ->> 'upgraded_to' as up;
select 'tier=' || t.name from public.members m join public.card_types t on t.id=m.card_type_id where m.id=:'mid';
-- 手动调整：降到银卡，扣 500 积分
select id as silver from public.card_types where name='银卡' \gset
select public.adjust_member(:'sid', :'mid', :'silver', -500, '录入错误', '', '陈明（店长）');
select 'tier=' || t.name || ' points=' || m.points from public.members m join public.card_types t on t.id=m.card_type_id where m.id=:'mid';
-- 积分扣过头
select public.adjust_member(:'sid', :'mid', null, -999999, '其他', '', 'x');
