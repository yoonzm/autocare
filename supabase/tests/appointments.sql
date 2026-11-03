-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare u uuid:=gen_random_uuid(); u2 uuid:=gen_random_uuid(); shop uuid; other_shop uuid;
  svc uuid; foreign_svc uuid; member uuid; tier uuid; bay uuid; tech uuid; bay2 uuid; tech2 uuid;
  a jsonb; b jsonb; reply jsonb; future_at timestamptz;
  past_id uuid; caught boolean;
begin
  insert into auth.users(id) values(u),(u2);
  insert into public.stores(owner_id,name) values(u,'预约测试') returning id into shop;
  insert into public.stores(owner_id,name) values(u2,'其他门店') returning id into other_shop;
  insert into public.card_types(store_id,name,discount) values(shop,'普通会员',1) returning id into tier;
  insert into public.service_items(store_id,name,category,price,duration_minutes) values(shop,'洗车','洗车',68,30) returning id into svc;
  insert into public.service_items(store_id,name,category,price,duration_minutes) values(other_shop,'外店项目','洗车',999,30) returning id into foreign_svc;
  insert into public.members(store_id,phone,name,card_type_id) values(shop,'13900001234','预约会员',tier) returning id into member;
  perform public.save_appointment_settings(shop,'{"opens_at":"09:00","closes_at":"20:00","slot_minutes":30,"capacity":2,"lead_hours":0,"advance_days":30,"grace_minutes":15,"closed_days":[]}');
  bay:=(public.save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}')->>'id')::uuid;
  bay2:=(public.save_appointment_resource(shop,'{"kind":"bay","name":"2 号工位"}')->>'id')::uuid;
  tech:=(public.save_appointment_resource(shop,'{"kind":"technician","name":"技师甲","phone":"13800001234"}')->>'id')::uuid;
  tech2:=(public.save_appointment_resource(shop,'{"kind":"technician","name":"技师乙","phone":"13800005678"}')->>'id')::uuid;
  future_at:=(((now() at time zone 'Asia/Shanghai')::date+2)+time '10:00') at time zone 'Asia/Shanghai';
  a:=public.save_appointment(shop,jsonb_build_object('member_id',member,'service_ids',jsonb_build_array(svc),
    'starts_at',future_at,'bay_id',bay,'technician_id',tech,'estimate',1,'duration_minutes',1),'booking-one');
  assert (a->>'estimate')::numeric=68; assert (a->>'duration_minutes')::integer=30;
  assert a->>'customer_name'='预约会员';
  reply:=public.save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),'starts_at',future_at),'booking-one');
  assert a->>'id'=reply->>'id';
  assert not public.appointment_slot_available(shop,future_at,30,null,bay,tech2); -- 工位冲突。
  assert not public.appointment_slot_available(shop,future_at,30,null,bay2,tech); -- 技师冲突。
  assert public.appointment_slot_available(shop,future_at+interval '30 minutes',30,null,bay,tech); -- 相邻区间不冲突。
  b:=public.save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),'starts_at',future_at,
    'bay_id',bay2,'technician_id',tech2),'booking-two');
  assert not public.appointment_slot_available(shop,future_at,30); -- 全店容量限制。
  assert public.appointment_detail(other_shop,(a->>'id')::uuid) is null;
  caught:=false;
  begin perform public.save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(foreign_svc),'starts_at',future_at),'foreign-service');
  exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'外店服务必须被拒绝';
  caught:=false;
  begin perform public.change_appointment(other_shop,(a->>'id')::uuid,'arrive');
  exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能变更外店预约';
  caught:=false;
  begin perform public.save_appointment_resource(shop,jsonb_build_object('id',bay,'kind','bay','name','1 号工位','active',false));
  exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'未完成预约占用工位不能停用';
  caught:=false;
  begin perform public.save_appointment_settings(shop,'{"capacity":1}');
  exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'已有预约不能被缩小的容量破坏';
  perform public.change_appointment(shop,(b->>'id')::uuid,'cancel','客户有事');
  assert public.appointment_slot_available(shop,future_at,30,null,bay2,tech2);
  reply:=public.save_appointment(shop,jsonb_build_object('id',a->>'id','starts_at',future_at+interval '1 hour',
    'bay_id',bay,'technician_id',tech),'reschedule-one');
  assert (reply->>'starts_at')::timestamptz=future_at+interval '1 hour';
  caught:=false;
  begin perform public.change_appointment(shop,(a->>'id')::uuid,'arrive');
  exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'未来日期不能标记到店';
  -- 超时标记由服务端计算；到店后经真实订单结算才完成预约。
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id)
    values(shop,'散客',array[svc],jsonb_build_array(jsonb_build_object('service_id',svc,'name','洗车')),
      now()-interval '1 hour',30,68,'past-booking') returning id into past_id;
  assert public.appointment_detail(shop,past_id)->>'status'='late';
  perform public.change_appointment(shop,past_id,'arrive');
  reply:=public.checkout_appointment(shop,past_id,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),
    '现金',null,null,'苏A12345','店主','booking-checkout');
  assert (reply->>'payable')::numeric=68;
  assert public.appointment_detail(shop,past_id)->>'status'='done';
  assert (select count(*) from public.orders where appointment_id=past_id)=1;
  reply:=public.checkout_appointment(shop,past_id,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),
    '现金',null,null,'苏A12345','店主','booking-checkout');
  assert (reply->>'repeated')::boolean;
  assert not has_function_privilege('authenticated','public.save_appointment(uuid,jsonb,text)','execute');
  assert not has_function_privilege('anon','public.appointment_board(uuid,date)','execute');
  assert has_function_privilege('service_role','public.checkout_appointment(uuid,uuid,jsonb,text,numeric,text,text,text,text)','execute');
  -- 固定工位由后端解析，不能把技师安排到其他工位。
  perform public.save_appointment_resource(shop,jsonb_build_object('id',tech,'kind','technician','name','技师甲',
    'phone','13800001234','linked_id',bay));
  assert public.appointment_assignment(shop,null,tech)->>'bay_id'=bay::text;
  caught:=false;
  begin perform public.appointment_assignment(shop,bay2,tech);
  exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'固定工位必须在后端执行';
  -- 真实跨店哨兵数据，验证 RLS 不会泄露其他门店预约。
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id)
    values(other_shop,'其他门店客户',array[foreign_svc],'[]',future_at,30,999,'foreign-booking');
  perform set_config('request.jwt.claim.sub',u::text,true);
  execute 'set local role authenticated';
  assert (select count(*) from public.appointments where store_id=shop)>0;
  assert (select count(*) from public.appointments where store_id=other_shop)=0,'RLS 必须隔离门店';
  caught:=false;
  begin perform public.change_appointment(shop,(a->>'id')::uuid,'arrive');
  exception when insufficient_privilege then caught:=true; end;
  assert caught,'客户端不能绕过云函数直接写预约';
  execute 'reset role';
end $$;
rollback;
