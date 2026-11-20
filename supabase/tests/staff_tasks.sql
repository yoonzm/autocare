-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); other_u uuid:=gen_random_uuid(); shop uuid; other uuid; svc uuid; bay uuid; tech jsonb; cash jsonb; tech_id uuid; cash_id uuid; res uuid;
  h1 uuid; h2 uuid; ap1 uuid; h_ap uuid; r jsonb; caught boolean; msgs jsonb;
begin
  insert into auth.users(id,phone) values(owner_u,'8613900000001'),(other_u,'8613900000002');
  insert into public.stores(owner_id,name,phone) values(owner_u,'任务测试店','13900000001') returning id into shop;
  insert into public.stores(owner_id,name,phone) values(other_u,'他店','13900000002') returning id into other;
  insert into public.service_items(store_id,name,category,price,duration_minutes,commission_type,commission_value) values(shop,'镀晶','镀晶镀膜',1000,240,'percent',10) returning id into svc;
  bay:=(public.save_appointment_resource(shop,'{"kind":"bay","name":"3 号工位"}')->>'id')::uuid;
  tech:=public.save_staff(shop,jsonb_build_object('name','老周','phone','13800001111','role','technician','bay_id',bay),'店主');
  cash:=public.save_staff(shop,jsonb_build_object('name','小刘','phone','13800002222','role','cashier'),'店主');
  tech_id:=(tech->>'id')::uuid; cash_id:=(cash->>'id')::uuid; res:=(tech->>'resource_id')::uuid;
  perform public.save_staff(shop,jsonb_build_object('name','老板娘','phone','13800003333','role','manager'),'店主');
  update public.store_staff set status='active',activated_at=now() where store_id=shop;

  -- 1. 预约未转挂单前：只出现在「今日到店」，不出现在技师「我的任务」
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,bay_id,status,vehicle_plate,note)
    values(shop,'王建国',array[svc],jsonb_build_array(jsonb_build_object('service_id',svc,'name','镀晶','price',1000,'minutes',240)),
      now()-interval '1 hour',240,1000,'t-ap-1',res,bay,'waiting','沪A8K29M','预约备注') returning id into ap1;
  assert jsonb_array_length(public.staff_task_list(shop,tech_id)->'items')=0,'未转挂单的预约不进技师任务';
  assert jsonb_array_length(public.staff_arrivals(shop,tech_id)->'items')=1,'今日到店可查看预约';

  -- 2. 开单挂单指派技师（或预约转挂单）→ 出现在技师任务（待施工）
  h1:=public.hold_order_with_technicians(shop,null,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'待施工','车内有宠物毛发','不提醒','沪A8K29M',null,array[res]);
  h2:=public.hold_order_with_technicians(shop,null,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'待施工','他人挂单','不提醒','沪B00000',null,'{}');
  r:=public.staff_task_list(shop,tech_id);
  assert jsonb_array_length(r->'items')=1 and r->'items'->0->>'plate'='沪A8K29M';
  r:=public.staff_task_detail(shop,tech_id,h1);
  assert r->>'status'='waiting' and (r->>'est_commission')::numeric=100 and r->>'bay_name'='3 号工位' and r->>'note'='车内有宠物毛发';
  caught:=false; begin perform public.staff_task_detail(shop,tech_id,h2); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能读取未指派给自己的挂单任务';
  caught:=false; begin perform public.staff_task_detail(other,tech_id,h1); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能跨店读取任务';

  -- 3. 极简三态流转：待施工 → 开始施工（施工中）→ 提交完工（待结算）
  caught:=false; begin perform public.staff_task_finish(shop,tech_id,h1); exception when others then caught:=true; end;
  assert caught,'待施工需先开始施工再提交完工';
  r:=public.staff_task_progress(shop,tech_id,h1,1);
  assert r->>'status'='arrived' and (select status from public.held_orders where id=h1)='施工中';
  caught:=false; begin perform public.staff_task_progress(shop,cash_id,h1,1); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'非本人技师不能操作他人任务';

  r:=public.staff_task_finish(shop,tech_id,h1);
  assert r->>'status'='done' and (r->>'est_commission')::numeric=100 and (r->>'today_commission')::numeric=100;
  assert (select status from public.held_orders where id=h1)='待结算';
  assert (public.staff_messages_list(shop,cash_id,'system')->'items'->0->>'title')='施工已完成待收银';
  caught:=false; begin perform public.staff_task_finish(shop,tech_id,h1); exception when others then caught:=true; end;
  assert caught,'不能重复提交完工';

  -- 4. 前台退回修改 → 挂单回到「施工中」；再次完工并结算 → 提成快照落库
  perform public.staff_order_return(shop,h1,'请核对项目');
  assert (select status from public.held_orders where id=h1)='施工中';
  perform public.staff_task_finish(shop,tech_id,h1);
  perform public.checkout_with_technicians(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金','沪A8K29M','','店主','h1-pay',array[res],null,h1,null,null,null);
  r:=public.staff_perf(shop,tech_id);
  assert (r->>'month_commission')::numeric=100 and (r->>'month_orders')::int=1 and (r->>'month_revenue')::numeric=1000;

  -- 5. 预约到店转挂单 → 结算时同步完成原预约
  h_ap:=public.hold_order_with_technicians(shop,null,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'施工中','预约转挂单','不提醒','沪A8K29M',null,array[res],ap1);
  assert (select status from public.appointments where id=ap1)='arrived';
  perform public.staff_task_finish(shop,tech_id,h_ap);
  perform public.checkout_with_technicians(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金','沪A8K29M','','店主','hap-pay',array[res],null,h_ap,null,null,null);
  assert (select status from public.appointments where id=ap1)='done';
  r:=public.staff_perf(shop,tech_id);
  assert (r->>'month_orders')::int=2 and (r->>'month_commission')::numeric=200;

  -- 函数权限：仅 service_role
  assert not has_function_privilege('authenticated','public.staff_task_finish(uuid,uuid,uuid)','execute');
  assert has_function_privilege('service_role','public.staff_perf(uuid,uuid)','execute');
  assert not has_function_privilege('authenticated','public.staff_arrivals(uuid,uuid)','execute');
  assert not has_table_privilege('authenticated','public.staff_messages','select');
end $$;
rollback;
