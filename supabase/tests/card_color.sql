-- 卡面颜色：预设名和自定义 #RRGGBB 可存，其他拒绝。
-- 在应用了全部迁移的空库里运行：psql -v ON_ERROR_STOP=1 -f supabase/tests/card_color.sql
\set ON_ERROR_STOP on
\pset format unaligned
\pset tuples_only on
insert into auth.users(id, phone, email) values ('aaaaaaaa-0000-0000-0000-000000000004','+8613900000004','d@x.cn');
insert into public.stores(owner_id,name,contact_name,contact_role) values ('aaaaaaaa-0000-0000-0000-000000000004','测试店D','陈明','店长');
select id as sid from public.stores where name='测试店D' \gset
insert into public.card_types (store_id, name, discount, color) values (:'sid','自定义卡',0.9,'#7A4B2A'), (:'sid','白卡',1,'white');
select 'saved: ' || string_agg(color, ',' order by name) from public.card_types where store_id=:'sid';
do $$ begin insert into public.card_types (store_id, name, discount, color) values ((select id from public.stores where name='测试店D'),'坏卡',1,'#GGGGGG'); exception when check_violation then raise notice 'invalid hex blocked'; end $$;
do $$ begin insert into public.card_types (store_id, name, discount, color) values ((select id from public.stores where name='测试店D'),'坏卡2',1,'red'); exception when check_violation then raise notice 'unknown name blocked'; end $$;
