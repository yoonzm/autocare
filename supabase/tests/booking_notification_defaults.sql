begin;
do $$
declare u uuid:=gen_random_uuid(); shop uuid; svc uuid; s jsonb; a jsonb; b jsonb; at_time timestamptz;
  request text:=gen_random_uuid()::text; caught boolean:=false;
begin
  insert into auth.users(id) values(u);
  insert into stores(owner_id,name,phone) values(u,'通知设置测试','13900001111') returning id into shop;
  insert into service_items(store_id,name,category,price,duration_minutes)
    values(shop,'洗车','洗车',68,30) returning id into svc;
  perform save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}');
  s:=save_appointment_settings(shop,'{"opens_at":"00:00","closes_at":"23:59","slot_minutes":30,"capacity":20,"lead_hours":0,"advance_days":30,"grace_minutes":15,"closed_days":[],"notify_confirm_default":true,"remind_default":true}');
  assert (s->>'notify_confirm_default')::boolean and (s->>'remind_default')::boolean;
  assert (select notify_confirm_default and remind_default from appointment_settings where store_id=shop);
  perform save_appointment_settings(shop,'{"lead_hours":0}');
  assert (select notify_confirm_default and remind_default from appointment_settings where store_id=shop), 'legacy saves preserve defaults';
  begin perform save_appointment_settings(shop,'{"notify_manager":true}');
  exception when others then caught:=SQLERRM='appointment_manager_required'; end;
  assert caught and not (select notify_manager from appointment_settings where store_id=shop);
  insert into store_staff(store_id,name,phone,role,status) values(shop,'店长','13900002222','manager','active');
  perform save_appointment_settings(shop,'{"notify_manager":true}');
  assert (select notify_manager from appointment_settings where store_id=shop);
  at_time:=(((now() at time zone 'Asia/Shanghai')::date+2)+time '10:00') at time zone 'Asia/Shanghai';
  a:=save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'guest_phone','13900001111','starts_at',at_time),request);
  assert (a->>'notify_confirm')::boolean and (a->>'remind_enabled')::boolean;
  b:=save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'guest_phone','13900001111','starts_at',at_time+interval '1 hour','notify',false,'remind',false),'explicit-off');
  assert not (b->>'notify_confirm')::boolean and not (b->>'remind_enabled')::boolean;
  perform save_appointment_settings(shop,'{"notify_confirm_default":false,"remind_default":false}');
  assert (select notify_confirm and remind_enabled from appointments where id=(a->>'id')::uuid), 'defaults must not rewrite existing appointments';
  b:=save_merchant_appointment(shop,'{}',request);
  assert (b->>'notify_confirm')::boolean and (b->>'remind_enabled')::boolean, 'replay preserves original choices';
  b:=save_merchant_appointment(shop,jsonb_build_object('id',a->>'id','starts_at',at_time+interval '2 hours'),'edit-existing');
  assert (b->>'notify_confirm')::boolean and (b->>'remind_enabled')::boolean, 'reschedule preserves snapshot';
  perform save_appointment_settings(shop,'{"notify_confirm_default":true,"remind_default":true}');
  b:=save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),'starts_at',at_time+interval '3 hours'),'member-unaffected');
  assert not (b->>'notify_confirm')::boolean and not (b->>'remind_enabled')::boolean;
end $$;
rollback;
