begin;
do $$
declare
  owner_id uuid := gen_random_uuid(); other_owner uuid := gen_random_uuid();
  shop uuid; other_shop uuid; customer uuid; tier uuid; svc uuid; tech_a uuid; tech_b uuid;
  foreign_tech uuid; bay uuid; held uuid; appt uuid; lines jsonb; result jsonb; order_id uuid;
begin
  insert into auth.users(id) values (owner_id), (other_owner);
  insert into public.stores(owner_id,name,phone) values (owner_id,'技师开单测试','13900000031') returning id into shop;
  insert into public.stores(owner_id,name,phone) values (other_owner,'其他门店','13900000032') returning id into other_shop;
  insert into public.card_types(store_id,name,discount) values (shop,'普通会员',1) returning id into tier;
  insert into public.members(store_id,name,phone,card_type_id) values (shop,'会员','13900000033',tier) returning id into customer;
  insert into public.service_items(store_id,name,category,price) values (shop,'洗车','洗车',30) returning id into svc;
  insert into public.appointment_resources(store_id,kind,name) values (shop,'technician','技师甲') returning id into tech_a;
  insert into public.appointment_resources(store_id,kind,name) values (shop,'technician','技师乙') returning id into tech_b;
  insert into public.appointment_resources(store_id,kind,name) values (shop,'bay','工位') returning id into bay;
  insert into public.appointment_resources(store_id,kind,name) values (other_shop,'technician','外店技师') returning id into foreign_tech;
  lines := jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1));

  result := public.checkout_with_technicians(shop,lines,'现金','','','前台','member',
    array[tech_b,tech_a,tech_b],customer,null,null,null,null);
  order_id := (result->>'order_id')::uuid;
  assert (select technician_ids from public.orders where id=order_id)=array[tech_b,tech_a];
  result := public.checkout_with_technicians(shop,lines,'现金','','','前台','member',
    array[tech_a],customer,null,null,null,null);
  assert (result->>'repeated')::boolean and result->'technician_ids'=to_jsonb(array[tech_b,tech_a]);
  assert (select technician_ids from public.orders where id=order_id)=array[tech_b,tech_a], '重放不改派技师';

  result := public.checkout_with_technicians(shop,lines,'现金','','','前台','walkin',
    array[tech_a],null,null,null,null,null);
  assert (select technician_ids from public.orders where id=(result->>'order_id')::uuid)=array[tech_a];

  held := public.hold_order_with_technicians(shop,null,lines,'待施工','','不提醒','',null,array[tech_a,tech_b]);
  assert (select technician_ids from public.held_orders where id=held)=array[tech_a,tech_b];
  perform public.hold_order_with_technicians(shop,null,lines,'待施工','','不提醒','',held,'{}');
  assert (select cardinality(technician_ids) from public.held_orders where id=held)=0, '支持清除全部选择';
  perform public.hold_order_with_technicians(shop,null,lines,'待施工','','不提醒','',held,array[tech_b]);
  perform public.hold_order_with_technicians(shop,null,lines,'待施工','','不提醒','',held,null);
  assert (select technician_ids from public.held_orders where id=held)=array[tech_b], '旧版修改挂单不清空';
  update public.appointment_resources set active=false where id=tech_b;
  begin
    perform public.checkout_with_technicians(shop,lines,'现金','','','前台','invalid-held',
      array[foreign_tech],null,held,null,null,null);
    assert false, '必须拒绝外店技师';
  exception when invalid_parameter_value then
    assert sqlerrm='order_technician_unavailable';
  end;
  assert not exists(select 1 from public.orders where store_id=shop and request_id='invalid-held');
  assert (select settled_at is null from public.held_orders where id=held), '校验失败不会结清挂单';
  result := public.checkout_with_technicians(shop,lines,'现金','','','前台','settled',
    null,null,held,null,null,null);
  assert (select technician_ids from public.orders where id=(result->>'order_id')::uuid)=array[tech_b], '取单沿用原技师';

  begin
    perform public.hold_order_with_technicians(shop,customer,lines,'待施工','','不提醒','',null,array[bay,tech_b]);
    assert false, '工位和新选的停用技师无效';
  exception when invalid_parameter_value then
    assert sqlerrm='order_technician_unavailable';
  end;
  assert (select count(*) from public.held_orders where store_id=shop)=1, '失败不留下挂单';

  insert into public.appointments(store_id,customer_name,technician_id,service_ids,items,starts_at,duration_minutes,estimate,status,request_id)
  values (shop,'散客',tech_a,array[svc],lines,now(),30,30,'arrived','tech-appointment') returning id into appt;
  result := public.checkout_with_technicians(shop,lines,'现金','','','前台','appointment',
    null,null,null,appt,null,null);
  assert (select technician_ids from public.orders where id=(result->>'order_id')::uuid)=array[tech_a], '预约转开单沿用预约技师';
  assert not has_function_privilege('authenticated','public.checkout_with_technicians(uuid,jsonb,text,text,text,text,text,uuid[],uuid,uuid,uuid,numeric,text)','execute');
  assert not has_function_privilege('anon','public.hold_order_with_technicians(uuid,uuid,jsonb,text,text,text,text,uuid,uuid[],uuid)','execute');
end;
$$;
rollback;
