begin;
do $$
declare u uuid:=gen_random_uuid(); other_u uuid:=gen_random_uuid(); shop uuid; other_shop uuid;
 photo uuid:=gen_random_uuid(); item jsonb; caught boolean; task uuid; staff jsonb; staff_id uuid;
begin
 insert into auth.users(id) values(u),(other_u);
 insert into stores(owner_id,name,phone) values(u,'图片测试','13900000001') returning id into shop;
 insert into stores(owner_id,name,phone) values(other_u,'隔离测试','13900000002') returning id into other_shop;
 item:=merchant_media_mutate(shop,u,null,'store',shop,'begin',photo,repeat('a',64),'png');
 assert item->>'state'='pending';
 assert jsonb_array_length(merchant_media_mutate(shop,u,null,'store',shop,'list')->'items')=0;
 perform merchant_media_mutate(shop,u,null,'store',shop,'finish',photo);
 assert jsonb_array_length(merchant_media_mutate(shop,u,null,'store',shop,'list')->'items')=1;
 assert merchant_media_mutate(shop,u,null,'store',shop,'begin',photo,repeat('a',64),'png')->>'state'='ready','重试幂等';
 caught:=false; begin perform merchant_media_mutate(shop,u,null,'store',shop,'begin',photo,repeat('b',64),'png'); exception when others then caught:=sqlerrm='media_request_reused'; end; assert caught;
 caught:=false; begin perform merchant_media_mutate(shop,other_u,null,'store',shop,'list'); exception when insufficient_privilege then caught:=true; end; assert caught,'非店主不能读';
 caught:=false; begin perform merchant_media_mutate(other_shop,other_u,null,'store',other_shop,'remove',photo); exception when insufficient_privilege then caught:=true; end; assert caught,'不能跨店删图';
 for i in 2..9 loop perform merchant_media_mutate(shop,u,null,'store',shop,'begin',gen_random_uuid(),repeat('a',64),'png'); end loop;
 caught:=false; begin perform merchant_media_mutate(shop,u,null,'store',shop,'begin',gen_random_uuid(),repeat('a',64),'png'); exception when others then caught:=sqlerrm='media_limit'; end; assert caught,'9张限额含上传中';
 perform merchant_media_mutate(shop,u,null,'store',shop,'remove',photo);
 perform merchant_media_mutate(shop,u,null,'store',shop,'remove',photo);
 assert jsonb_array_length(merchant_media_mutate(shop,u,null,'store',shop,'list')->'items')=0;
 caught:=false; begin perform merchant_media_mutate(shop,u,null,'store',shop,'finish',photo); exception when others then caught:=sqlerrm='media_missing'; end; assert caught,'删除不能被晚到上传复活';
 staff:=save_staff(shop,'{"name":"技师","phone":"13800001111","role":"technician"}','店主');
 staff_id:=(staff->>'id')::uuid;
 update store_staff set status='active' where id=staff_id;
 insert into appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,status)
 values(shop,'测试','{}','[]',now(),30,0,'media-task',(staff->>'resource_id')::uuid,'arrived') returning id into task;
 for i in 1..6 loop perform merchant_media_mutate(shop,u,staff_id,'task',task,'begin',gen_random_uuid(),repeat('a',64),'png'); end loop;
 caught:=false; begin perform merchant_media_mutate(shop,u,staff_id,'task',task,'begin',gen_random_uuid(),repeat('a',64),'png'); exception when others then caught:=sqlerrm='media_limit'; end; assert caught,'施工6张上限';
 caught:=false; begin perform merchant_media_mutate(shop,u,gen_random_uuid(),'task',task,'list'); exception when insufficient_privilege then caught:=true; end; assert caught,'非任务技师不能读';
 update store_staff set status='disabled' where id=staff_id;
 caught:=false; begin perform merchant_media_mutate(shop,u,staff_id,'task',task,'list'); exception when insufficient_privilege then caught:=true; end; assert caught,'停用不能读';
 assert not has_table_privilege('authenticated','merchant_media','SELECT');
 assert not has_function_privilege('authenticated','merchant_media_mutate(uuid,uuid,uuid,text,uuid,text,uuid,text,text)','EXECUTE');
 assert not (select public from storage.buckets where id='merchant-media');
end $$;
rollback;
