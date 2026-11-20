begin;
do $$
declare owner_u uuid:=gen_random_uuid(); admin_u uuid:=gen_random_uuid(); admin_s uuid:=gen_random_uuid();
 shop uuid; shop2 uuid; empty_shop uuid; employee uuid:=gen_random_uuid(); snapshot jsonb; total integer; caught boolean;
begin
 insert into auth.users(id,phone) values(owner_u,'8613900090001'),(admin_u,'8613900090002');
 insert into auth.sessions(id,user_id) values(admin_s,admin_u);
 insert into admin_accounts(id,username,name,role,must_change) values(admin_u,'staff_count_test','员工数测试','superAdmin',false);
 insert into stores(owner_id,name,phone) values(owner_u,'员工数主店','13900090001') returning id into shop;
 insert into stores(owner_id,name,phone) values(owner_u,'员工数分店','13900090001') returning id into shop2;
 insert into stores(owner_id,name,phone) values(owner_u,'空店','13900090001') returning id into empty_shop;
 insert into store_staff(id,store_id,name,phone,role,status) values
  (employee,shop,'店长','13800090001','manager','active'),
  (gen_random_uuid(),shop,'待加入前台','13800090002','cashier','pending'),
  (gen_random_uuid(),shop2,'分店前台','13800090002','cashier','active');
 perform save_staff(shop,'{"name":"技师","phone":"13800090003","role":"technician"}','老板');
 perform save_staff(shop,'{"name":"停用技师","phone":"13800090004","role":"technician"}','老板');
 update store_staff set status='active' where store_id=shop and phone='13800090003';
 update store_staff set status='disabled' where store_id=shop and phone='13800090004';
 snapshot:=admin_snapshot(admin_u,admin_s,0);
 select (m->>'staff')::integer into total from jsonb_array_elements(snapshot->'merchants') m where m->>'id'=shop::text;
 assert total=3,'包含在职/待激活的三种员工，不含停用员工或店主';
 select (m->>'staff')::integer into total from jsonb_array_elements(snapshot->'merchants') m where m->>'id'=shop2::text;
 assert total=1,'同一店主的多家店铺独立统计';
 select (m->>'staff')::integer into total from jsonb_array_elements(snapshot->'merchants') m where m->>'id'=empty_shop::text;
 assert total=0,'无员工返回数字0而不是null';
 update store_staff set status='disabled' where id=employee;
 snapshot:=admin_snapshot(admin_u,admin_s,0);
 select (m->>'staff')::integer into total from jsonb_array_elements(snapshot->'merchants') m where m->>'id'=shop::text;
 assert total=2,'停用后刷新减少员工数';
 update store_staff set status='active' where id=employee;
 snapshot:=admin_snapshot(admin_u,admin_s,0);
 select (m->>'staff')::integer into total from jsonb_array_elements(snapshot->'merchants') m where m->>'id'=shop::text;
 assert total=3,'重新启用后刷新增加员工数';
 snapshot:=admin_snapshot(admin_u,admin_s,1);
 assert jsonb_array_length(snapshot->'merchants')=2,'保留原分页行为';
 assert not exists(select 1 from jsonb_array_elements(snapshot->'merchants') m where m->'staff'='null'::jsonb);
 caught:=false; begin perform admin_snapshot(owner_u,admin_s,0);
 exception when sqlstate '28000' then caught:=true; end; assert caught,'商家不能读取后台快照';
 assert not has_function_privilege('authenticated','admin_snapshot(uuid,uuid,integer)','EXECUTE');
end $$;
rollback;
