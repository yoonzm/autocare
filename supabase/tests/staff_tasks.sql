-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); other_u uuid:=gen_random_uuid(); shop uuid; other uuid; svc uuid; bay uuid; tech jsonb; cash jsonb; tech_id uuid; cash_id uuid; res uuid;
  a1 uuid; a2 uuid; a3 uuid; r jsonb; caught boolean; msgs jsonb;
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
  update public.store_staff set status='active',activated_at=now() where store_id=shop;  -- 已确认加入门店

  -- 派单 → 技师收到「新任务派给你」
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,bay_id,status,vehicle_plate,note)
    values(shop,'王建国',array[svc],jsonb_build_array(jsonb_build_object('service_id',svc,'name','镀晶','price',1000,'minutes',240)),
      now()-interval '1 hour',240,1000,'t-1',res,bay,'waiting','沪A8K29M','车内有宠物毛发') returning id into a1;
  msgs:=public.staff_messages_list(shop,tech_id,null);
  assert (msgs->>'unread')::int=1 and msgs->'items'->0->>'title'='新任务派给你' and msgs->'items'->0->>'kind'='task';
  assert msgs->'items'->0->>'link'='StTaskDetail:'||a1;

  -- 任务列表与详情：只含自己的；详情带预计提成、节点进度
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,status)
    values(shop,'他人',array[svc],'[]',now()-interval '50 minutes',30,100,'t-2','waiting') returning id into a2;
  r:=public.staff_task_list(shop,tech_id);
  assert jsonb_array_length(r->'items')=1 and r->'items'->0->>'plate'='沪A8K29M';
  r:=public.staff_task_detail(shop,tech_id,a1);
  assert r->>'status'='waiting' and (r->>'progress')::int=0 and (r->>'est_commission')::numeric=100 and r->>'bay_name'='3 号工位' and r->>'note'='车内有宠物毛发';
  caught:=false; begin perform public.staff_task_detail(shop,tech_id,a2); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能读取他人的任务';
  caught:=false; begin perform public.staff_task_detail(other,tech_id,a1); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能跨店读取任务';

  -- 车主到店 → 技师收到「车主已到店」；待施工任务不能更新进度
  caught:=false; begin perform public.staff_task_progress(shop,tech_id,a1,2); exception when others then caught:=true; end;
  assert caught,'未到店的任务不能更新进度';
  perform public.change_appointment(shop,a1,'arrive');
  assert (public.staff_messages_list(shop,tech_id,'arrival')->'items'->0->>'title')='车主已到店';
  r:=public.staff_task_detail(shop,tech_id,a1);
  assert (r->>'stage')::int=1 and (r->>'progress')::int=37;

  -- 进度只能前进；越界与回退被拒
  r:=public.staff_task_progress(shop,tech_id,a1,2);
  assert (r->>'stage')::int=2 and (r->>'progress')::int=62;
  caught:=false; begin perform public.staff_task_progress(shop,tech_id,a1,1); exception when others then caught:=true; end;
  assert caught,'进度不能倒退';
  caught:=false; begin perform public.staff_task_progress(shop,tech_id,a1,4); exception when others then caught:=true; end;
  assert caught,'完成请走完工提交';
  caught:=false; begin perform public.staff_task_progress(shop,cash_id,a1,3); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'非技师不能更新他人任务';

  -- 完工：进度 100%，前台 / 店长收到待收银提醒，返回预计提成与今日预计
  r:=public.staff_task_finish(shop,tech_id,a1);
  assert (r->>'progress')::int=100 and (r->>'stage')::int=4 and (r->>'est_commission')::numeric=100 and (r->>'today_commission')::numeric=100;
  assert (public.staff_messages_list(shop,cash_id,'system')->'items'->0->>'title')='施工已完成待收银';
  assert (select count(*) from public.staff_messages where title='施工已完成待收银')=2,'前台与店长各一条';
  caught:=false; begin perform public.staff_task_finish(shop,tech_id,a1); exception when others then caught:=true; end;
  assert caught,'不能重复提交完工';
  caught:=false; begin perform public.staff_task_progress(shop,tech_id,a1,3); exception when others then caught:=true; end;
  assert caught,'完工后不能再改进度';

  -- 收银结算后：提成快照落库、业绩统计、「提成已更新」消息
  perform public.checkout_appointment(shop,a1,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金',null,null,'沪A8K29M','店主','t-1-pay');
  r:=public.staff_perf(shop,tech_id);
  assert (r->>'month_commission')::numeric=100 and (r->>'month_orders')::int=1 and (r->>'month_revenue')::numeric=1000;
  assert jsonb_array_length(r->'days')=7 and (r->'days'->6->>'amount')::numeric=100;
  assert r->'rows'->0->>'service'='镀晶' and (r->'rows'->0->>'amount')::numeric=100 and r->'rows'->0->>'plate'='沪A8K29M';
  assert (public.staff_messages_list(shop,tech_id,'system')->'items'->0->>'title')='提成已更新';

  -- 已读：单条与全部
  msgs:=public.staff_messages_list(shop,tech_id,null);
  assert (msgs->>'unread')::int=3;
  r:=public.staff_messages_read(shop,tech_id,(msgs->'items'->0->>'id')::uuid);
  assert (r->>'unread')::int=2;
  r:=public.staff_messages_read(shop,tech_id,null);
  assert (r->>'unread')::int=0;
  caught:=false; begin perform public.staff_messages_read(other,tech_id,null); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能跨店读消息';
  caught:=false; begin perform public.staff_messages_list(shop,tech_id,'bad'); exception when others then caught:=true; end;
  assert caught;

  -- 权限被老板调整 → 该角色在职员工收到留痕；没有变化不发
  perform public.save_staff_permissions(shop,'technician','{"stock_use":false}');
  assert (public.staff_messages_list(shop,tech_id,'system')->'items'->0->>'title')='权限已调整';
  r:=public.staff_messages_read(shop,tech_id,null);
  perform public.save_staff_permissions(shop,'technician','{"stock_use":false}');
  assert (public.staff_messages_list(shop,tech_id,null)->>'unread')::int=0,'没有变化不重复通知';
  assert (public.staff_messages_list(shop,cash_id,null)->>'unread')::int>=1;

  -- 函数权限：仅 service_role
  assert not has_function_privilege('authenticated','public.staff_task_finish(uuid,uuid,uuid)','execute');
  assert has_function_privilege('service_role','public.staff_perf(uuid,uuid)','execute');
  assert not has_table_privilege('authenticated','public.staff_messages','select');
end $$;
rollback;
