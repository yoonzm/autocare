begin;
do $$
declare u uuid:=gen_random_uuid(); shop uuid; svc uuid; s jsonb; n jsonb; a jsonb; b jsonb; at_time timestamptz;
  request text:=gen_random_uuid()::text; caught boolean:=false;
begin
  insert into auth.users(id) values(u);
  insert into stores(owner_id,name,phone) values(u,'通知设置测试','13900001111') returning id into shop;
  insert into service_items(store_id,name,category,price,duration_minutes)
    values(shop,'洗车','洗车',68,30) returning id into svc;
  perform save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}');

  -- appointment_settings 不再包含任何通知开关列
  assert not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'appointment_settings'
      and column_name in (
        'notify_confirm_default','remind_default','notify_manager',
        'notify_reschedule','notify_cancel','notify_consume','notify_recharge'
      )
  ), 'appointment_settings must not keep notification columns';

  -- 预约设置保存与门店通知开关完全独立
  s:=save_appointment_settings(shop,'{"opens_at":"00:00","closes_at":"23:59","slot_minutes":30,"capacity":20,"lead_hours":0,"advance_days":30,"grace_minutes":15,"closed_days":[]}');
  assert not (s ? 'notify_confirm_default') and not (s ? 'notify_consume');

  -- 局部更新 store_notify_settings：未传字段保持默认值/原值
  n:=save_store_notify_settings(shop,'{"notify_confirm_default":true,"remind_default":true}');
  assert (n->>'notify_confirm_default')::boolean and (n->>'remind_default')::boolean;
  assert (n->>'notify_consume')::boolean and (n->>'notify_recharge')::boolean;
  assert (n->>'notify_reschedule')::boolean and (n->>'notify_cancel')::boolean;
  assert (select notify_confirm_default and remind_default from store_notify_settings where store_id=shop);

  -- 单独关闭消费通知不影响预约默认开关
  n:=save_store_notify_settings(shop,'{"notify_consume":false}');
  assert not (n->>'notify_consume')::boolean and (n->>'notify_confirm_default')::boolean and (n->>'remind_default')::boolean;

  -- 保存预约设置不影响已保存的通知开关
  perform save_appointment_settings(shop,'{"lead_hours":0}');
  assert (select notify_confirm_default and remind_default and not notify_consume from store_notify_settings where store_id=shop), 'appointment settings save must not touch notify settings';

  -- 未配置启用店长时不允许开启店长通知
  begin perform save_store_notify_settings(shop,'{"notify_manager":true}');
  exception when others then caught:=SQLERRM='appointment_manager_required'; end;
  assert caught and not (select notify_manager from store_notify_settings where store_id=shop);

  insert into store_staff(store_id,name,phone,role,status) values(shop,'店长','13900002222','manager','active');
  perform save_store_notify_settings(shop,'{"notify_manager":true}');
  assert (select notify_manager from store_notify_settings where store_id=shop);

  -- 新建预约自动带入 store_notify_settings 的默认值，且支持本单显式关闭
  at_time:=(((now() at time zone 'Asia/Shanghai')::date+2)+time '10:00') at time zone 'Asia/Shanghai';
  a:=save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'guest_phone','13900001111','starts_at',at_time),request);
  assert (a->>'notify_confirm')::boolean and (a->>'remind_enabled')::boolean;
  b:=save_merchant_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),
    'guest_phone','13900001111','starts_at',at_time+interval '1 hour','notify',false,'remind',false),'explicit-off');
  assert not (b->>'notify_confirm')::boolean and not (b->>'remind_enabled')::boolean;

  -- 修改默认开关不影响既有预约，重放与改期均保持原预约快照
  perform save_store_notify_settings(shop,'{"notify_confirm_default":false,"remind_default":false}');
  assert (select notify_confirm and remind_enabled from appointments where id=(a->>'id')::uuid), 'defaults must not rewrite existing appointments';
  b:=save_merchant_appointment(shop,'{}',request);
  assert (b->>'notify_confirm')::boolean and (b->>'remind_enabled')::boolean, 'replay preserves original choices';
  b:=save_merchant_appointment(shop,jsonb_build_object('id',a->>'id','starts_at',at_time+interval '2 hours'),'edit-existing');
  assert (b->>'notify_confirm')::boolean and (b->>'remind_enabled')::boolean, 'reschedule preserves snapshot';

  -- 会员端直接调用 save_appointment 不受商户端默认开关影响
  perform save_store_notify_settings(shop,'{"notify_confirm_default":true,"remind_default":true}');
  b:=save_appointment(shop,jsonb_build_object('service_ids',jsonb_build_array(svc),'starts_at',at_time+interval '3 hours'),'member-unaffected');
  assert not (b->>'notify_confirm')::boolean and not (b->>'remind_enabled')::boolean;
end $$;
rollback;
