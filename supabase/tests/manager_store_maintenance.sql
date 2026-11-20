begin;
do $$
declare u uuid:=gen_random_uuid(); m uuid:=gen_random_uuid(); outsider uuid:=gen_random_uuid();
 os uuid:=gen_random_uuid(); ms uuid:=gen_random_uuid(); shop uuid; other_shop uuid; st uuid;
 body jsonb; r jsonb; photo uuid:=gen_random_uuid(); caught boolean; op text;
begin
 insert into auth.users(id,phone) values(u,'8613900000001'),(m,'8613800001111'),(outsider,'8613900000002');
 insert into auth.sessions(id,user_id) values(os,u),(ms,m);
 insert into stores(owner_id,name,phone) values(u,'店长维护测试','13900000001') returning id into shop;
 insert into stores(owner_id,name,phone) values(outsider,'其他门店','13900000002') returning id into other_shop;
 st:=(save_staff(shop,'{"name":"店长","phone":"13800001111","role":"manager"}','店主')->>'id')::uuid;
 perform select_staff_identity(m,ms,st);
 body:=jsonb_build_object('id',shop,'name','更新门店','phone','13800001111','address','测试地址');
 assert merchant_store_mutate(m,ms,'update',body,'same')->>'code'='join_required';
 perform staff_join_confirm(m,ms);
 r:=merchant_store_mutate(m,ms,'update',body,'same');
 assert r->>'id'=shop::text;
 assert (select name from stores where id=shop)='更新门店';
 assert merchant_store_mutate(m,ms,'update',body,'same')=r;
 caught:=false; begin perform merchant_store_mutate(m,ms,'update',body||'{"name":"另一名称"}','same'); exception when others then caught:=true; end; assert caught,'不同内容不能复用请求';
 -- 老板和店长使用同一请求号不会互相冲突。
 perform merchant_store_mutate(u,os,'update',body||'{"name":"老板更新"}','same');
 caught:=false; begin perform merchant_store_mutate(m,ms,'update',body||jsonb_build_object('id',other_shop),'cross'); exception when serialization_failure then caught:=true; end; assert caught,'跨店更新拒绝';
 foreach op in array array['create','archive','restore','switch'] loop
  caught:=false; begin perform merchant_store_mutate(m,ms,op,body,'lifecycle'); exception when insufficient_privilege then caught:=true; end; assert caught,op;
 end loop;
 perform merchant_media_mutate(shop,m,st,'store',shop,'begin',photo,repeat('a',64),'png');
 perform merchant_media_mutate(shop,m,st,'store',shop,'finish',photo);
 assert jsonb_array_length(merchant_media_mutate(shop,m,st,'store',shop,'list')->'items')=1;
 caught:=false; begin perform merchant_media_access(other_shop,m,st,'store',other_shop); exception when insufficient_privilege then caught:=true; end; assert caught,'跨店照片拒绝';
 caught:=false; begin perform merchant_media_access(shop,outsider,st,'store',shop); exception when insufficient_privilege then caught:=true; end; assert caught,'伪造员工身份拒绝';
 perform merchant_media_mutate(shop,m,st,'store',shop,'remove',photo);
 assert jsonb_array_length(merchant_media_mutate(shop,m,st,'store',shop,'list')->'items')=0;
 update store_staff set role='cashier' where id=st;
 caught:=false; begin perform merchant_store_mutate(m,ms,'update',body,'cashier'); exception when insufficient_privilege then caught:=true; end; assert caught;
 caught:=false; begin perform merchant_media_access(shop,m,st,'store',shop); exception when insufficient_privilege then caught:=true; end; assert caught;
 update store_staff set role='manager',status='disabled' where id=st;
 assert merchant_store_mutate(m,ms,'update',body,'same')->>'code'='staff_disabled','停用后不可重放成功结果';
 caught:=false; begin perform merchant_media_access(shop,m,st,'store',shop); exception when insufficient_privilege then caught:=true; end; assert caught;
 assert not has_function_privilege('authenticated','merchant_store_mutate(uuid,uuid,text,jsonb,text)','EXECUTE');
end $$;
rollback;
