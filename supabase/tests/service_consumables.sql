-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); other_u uuid:=gen_random_uuid(); shop uuid; other_shop uuid;
  svc uuid; pa uuid; pb uuid; p_other uuid; appt uuid:=gen_random_uuid(); r jsonb; doc_note text; caught boolean;
begin
  insert into auth.users(id,phone) values(owner_u,'8613900000021'),(other_u,'8613900000022');
  insert into public.stores(owner_id,name,phone) values(owner_u,'耗材测试店','13900000021') returning id into shop;
  insert into public.stores(owner_id,name,phone) values(other_u,'别家店','13900000022') returning id into other_shop;
  insert into public.service_items(store_id,name,category,price) values(shop,'全车镀晶','镀晶镀膜',1580) returning id into svc;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(shop,'9H 镀晶液','镀晶','瓶',2,100) returning id into pa;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(shop,'擦车巾','洗护','条',2,5) returning id into pb;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(other_shop,'别家商品','洗护','条',0,1) returning id into p_other;
  -- 入库：镀晶液 10 瓶、擦车巾 1 条
  perform public.inventory_document_save(shop,gen_random_uuid(),'in',jsonb_build_object('supplier','供应商','lines',
    jsonb_build_array(jsonb_build_object('id',pa,'quantity',10,'cost',100),jsonb_build_object('id',pb,'quantity',1,'cost',5))),0,true);

  -- 保存耗材：校验
  r:=public.save_service_consumables(shop,svc,jsonb_build_array(jsonb_build_object('product_id',pa,'quantity',2),jsonb_build_object('product_id',pb,'quantity',3)));
  assert jsonb_array_length(r)=2,'保存两条耗材';
  caught:=false; begin perform public.save_service_consumables(shop,svc,jsonb_build_array(jsonb_build_object('product_id',pa,'quantity',1),jsonb_build_object('product_id',pa,'quantity',2))); exception when others then caught:=sqlerrm='duplicate_product'; end;
  assert caught,'同一商品不能重复';
  caught:=false; begin perform public.save_service_consumables(shop,svc,jsonb_build_array(jsonb_build_object('product_id',pa,'quantity',0))); exception when others then caught:=sqlerrm='invalid_quantity'; end;
  assert caught,'用量必须大于 0';
  caught:=false; begin perform public.save_service_consumables(shop,svc,jsonb_build_array(jsonb_build_object('product_id',p_other,'quantity',1))); exception when others then caught:=true; end;
  assert caught,'不能绑定别家的商品';
  assert (select count(*) from public.service_consumables where service_id=svc)=2,'校验失败的保存整体回滚，原绑定不变';

  -- 完工自动扣减：镀晶液 2 瓶够用；擦车巾要 3 条只有 1 条 → 扣 1 条，缺 2 条，不拦
  insert into public.appointments(id,store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,status,request_id)
    values(appt,shop,'散客',array[svc],jsonb_build_array(jsonb_build_object('service_id',svc,'name','全车镀晶','price',1580,'minutes',30)),
      now(),30,1580,'arrived','deduct-1');
  insert into public.appointment_work(appointment_id,store_id,stage) values(appt,shop,1);
  r:=public.service_consumables_deduct(shop,appt,'周强（完工自动扣减）');
  assert r->>'document_id' is not null and r->>'error' is null,'生成出库单且不报错';
  assert (select stock from public.inventory_products where id=pa)=8,'镀晶液扣 2 瓶';
  assert (select stock from public.inventory_products where id=pb)=0,'擦车巾扣到 0';
  assert jsonb_array_length(r->'short')=1 and (r->'short'->0->>'name')='擦车巾','只有擦车巾缺料';
  assert (r->'short'->0->>'need')::numeric=3 and (r->'short'->0->>'have')::numeric=1;
  select payload->>'note' into doc_note from public.inventory_documents where id=(r->>'document_id')::uuid;
  assert doc_note like '%库存不足%擦车巾缺 2条%',coalesce(doc_note,'空');
  assert (select payload->>'reason' from public.inventory_documents where id=(r->>'document_id')::uuid)='施工领用';
  assert (select payload->>'operator' from public.inventory_documents where id=(r->>'document_id')::uuid)='周强（完工自动扣减）';
  assert (select consumables->>'document_id' from public.appointment_work where appointment_id=appt)=r->>'document_id','记录到完工记录上';

  -- 没有耗材的服务：不生成出库单
  delete from public.service_consumables where service_id=svc;
  r:=public.service_consumables_deduct(shop,appt,'x');
  assert r->>'document_id' is null and jsonb_array_length(r->'deducted')=0;


  -- 直接开单：收银成功后按「行数量 × 单次用量」扣减
  perform public.save_service_consumables(shop,svc,jsonb_build_array(jsonb_build_object('product_id',pa,'quantity',2),jsonb_build_object('product_id',pb,'quantity',1)));
  perform public.inventory_document_save(shop,gen_random_uuid(),'in',jsonb_build_object('supplier','供应商','lines',
    jsonb_build_array(jsonb_build_object('id',pb,'quantity',5,'cost',5))),0,true);
  r:=public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',2)),'微信','','','小李','co-1');
  assert (select stock from public.inventory_products where id=pa)=4,'开单 2 件扣镀晶液 4 瓶';
  assert (select stock from public.inventory_products where id=pb)=3,'擦车巾扣 2 条';
  assert (select consumables->>'document_id' from public.orders where id=(r->>'order_id')::uuid) is not null,'订单记录扣减结果';
  assert (select payload->>'operator' from public.inventory_documents where id=((select consumables->>'document_id' from public.orders where id=(r->>'order_id')::uuid))::uuid)='小李（收银自动扣减）';
  -- 重复请求（幂等重放）不再扣
  r:=public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',2)),'微信','','','小李','co-1');
  assert (r->>'repeated')::boolean and (select stock from public.inventory_products where id=pa)=4,'重放不重复扣';
  -- 库存不足不拦收银：需要 10 瓶只有 4 瓶
  r:=public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',5)),'微信','','','小李','co-2');
  assert r->>'order_id' is not null,'缺料仍能收银';
  assert (select stock from public.inventory_products where id=pa)=0,'镀晶液扣到 0';
  assert (select jsonb_array_length(consumables->'short') from public.orders where id=(r->>'order_id')::uuid)>=1,'缺料记录在订单上';
  -- 预约完工已扣过：转订单不再扣
  perform public.inventory_document_save(shop,gen_random_uuid(),'in',jsonb_build_object('supplier','供应商','lines',
    jsonb_build_array(jsonb_build_object('id',pa,'quantity',10,'cost',100))),0,true);
  update public.appointment_work set consumables=jsonb_build_object('document_id',gen_random_uuid()) where appointment_id=appt;
  r:=public.checkout_appointment(shop,appt,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'微信',0,null,'','小李','co-3');
  assert (select stock from public.inventory_products where id=pa)=10,'完工扣过，结算不重复扣';
  assert (select consumables->>'skipped' from public.orders where id=(r->>'order_id')::uuid)='appointment_finished';
  assert current_setting('autocare.consumables_done',true)='off','跳过开关已复位';
  assert not has_function_privilege('authenticated','public.service_consumables_deduct_order(uuid,uuid,text)','execute');

  -- 员工完工函数已接入自动扣减
  assert pg_get_functiondef('public.staff_task_finish(uuid,uuid,uuid)'::regprocedure) like '%service_consumables_deduct%';
  -- 权限：只有 service_role
  assert not has_function_privilege('authenticated','public.service_consumables_deduct(uuid,uuid,text)','execute');
  assert not has_function_privilege('anon','public.save_service_consumables(uuid,uuid,jsonb)','execute');
end $$;
rollback;
