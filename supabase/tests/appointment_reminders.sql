begin;
do $$
declare u uuid:=gen_random_uuid(); shop uuid; svc uuid; a jsonb; b jsonb; rid uuid;
  future_at timestamptz; old_request uuid; n integer; caught boolean:=false;
begin
  insert into auth.users(id) values(u);
  insert into stores(owner_id,name,phone) values(u,'提醒测试','13900001111') returning id into shop;
  insert into service_items(store_id,name,category,price,duration_minutes)
    values(shop,'洗车','洗车',68,30) returning id into svc;
  perform save_appointment_settings(shop,'{"opens_at":"00:00","closes_at":"23:59","slot_minutes":30,"capacity":20,"lead_hours":0,"advance_days":30,"grace_minutes":15,"closed_days":[]}');
  perform save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}');
  future_at:=(((now() at time zone 'Asia/Shanghai')::date+2)+time '10:00') at time zone 'Asia/Shanghai';
  a:=save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'guest_name','客户','guest_phone','13900001111','starts_at',future_at,'remind',true),'reminder-create');
  rid:=(a->>'id')::uuid;
  assert a->>'remind_state'='pending';
  assert (a->>'remind_at')::timestamptz=future_at-interval '2 hours';
  old_request:=(a->>'remind_request')::uuid;
  b:=save_merchant_appointment(shop,jsonb_build_object('remind',false),'reminder-create');
  assert b->>'remind_request'=old_request::text, 'replay must not change reminder';
  b:=save_merchant_appointment(shop,jsonb_build_object('id',rid,'starts_at',future_at+interval '1 hour'),'reminder-edit');
  assert (b->>'remind_enabled')::boolean and b->>'remind_request'<>old_request::text;
  -- Member's existing save RPC never opts into reminders.
  b:=save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'starts_at',future_at+interval '2 hours','remind',true),'member-create');
  assert b->>'remind_state'='disabled';
  begin
    perform save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
      'starts_at',future_at+interval '3 hours','remind',true),'invalid-phone');
  exception when others then caught:=SQLERRM='reminder_phone_required'; end;
  assert caught;
  assert not exists(select 1 from appointments where request_id='invalid-phone'), 'save must roll back';
  -- Simulate a clock reaching the scheduled moment without a wall-clock wait.
  update appointments set remind_next_at=now()-interval '1 second' where id=rid;
  select count(*) into n from claim_appointment_reminders(); assert n=1;
  select count(*) into n from claim_appointment_reminders(); assert n=0, 'cannot claim twice';
  select remind_request into old_request from appointments where id=rid;
  perform finish_appointment_reminder(rid,old_request,'pending');
  assert (select remind_state from appointments where id=rid)='pending';
  update appointments set remind_next_at=now()-interval '1 second' where id=rid;
  perform claim_appointment_reminders();
  update appointments set remind_claimed_at=now()-interval '6 minutes' where id=rid;
  perform claim_appointment_reminders();
  assert (select remind_state from appointments where id=rid)='unknown';
  perform finish_appointment_reminder(rid,old_request,'sent');
  assert (select remind_state from appointments where id=rid)='unknown';
  update appointments set starts_at=future_at+interval '4 hours' where id=rid;
  perform finish_appointment_reminder(rid,old_request,'sent');
  assert (select remind_state from appointments where id=rid)='pending', 'old callback must not overwrite new schedule';
  update appointments set remind_next_at=now()-interval '1 second',remind_attempts=2 where id=rid;
  perform claim_appointment_reminders();
  select remind_request into old_request from appointments where id=rid;
  perform finish_appointment_reminder(rid,old_request,'pending');
  assert (select remind_state from appointments where id=rid)='failed', 'bounded cooldown retries';
  update appointments set starts_at=future_at+interval '5 hours' where id=rid;
  update appointments set remind_next_at=now()-interval '1 second' where id=rid;
  perform claim_appointment_reminders();
  select remind_request into old_request from appointments where id=rid;
  perform finish_appointment_reminder(rid,old_request,'sent');
  assert (select remind_state from appointments where id=rid)='sent';
  select count(*) into n from claim_appointment_reminders(); assert n=0;
  perform change_appointment(shop,rid,'cancel','客户取消');
  assert (select remind_state from appointments where id=rid)='cancelled';
  update appointments set status='waiting',starts_at=now()+interval '1 hour' where id=rid;
  assert (select remind_state from appointments where id=rid)='skipped';
  update appointments set starts_at=future_at where id=rid;
  update appointments set status='arrived' where id=rid;
  assert (select remind_state from appointments where id=rid)='cancelled';
  assert not has_function_privilege('authenticated','public.claim_appointment_reminders()','execute');
  assert not has_function_privilege('anon','public.save_merchant_appointment(uuid,jsonb,text)','execute');
  old_request:=gen_random_uuid();
  assert reserve_notice_sms('+8613900001111','appointment_reminder',old_request,'测试')='{}'::jsonb;
  assert reserve_notice_sms('+8613900001111','appointment_reminder',old_request,'测试')->>'error'='duplicate_request';
  assert (select count from phone_sms_quota where phone='notice:+8613900001111')=1;
end $$;
rollback;
