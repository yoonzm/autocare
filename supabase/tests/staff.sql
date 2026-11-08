-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare u uuid:=gen_random_uuid(); u2 uuid:=gen_random_uuid(); shop uuid; other_shop uuid;
  svc uuid; svc2 uuid; bay uuid; tech jsonb; tech2 jsonb; mgr jsonb; cash jsonb; a uuid; r jsonb; perms jsonb; caught boolean;
  tech_id uuid; tech2_id uuid; res_id uuid; inv jsonb; sess uuid:=gen_random_uuid();
begin
  insert into auth.users(id,phone) values(u,'13900000001'),(u2,'13900000002');
  insert into public.stores(owner_id,name,phone) values(u,'员工测试','13900000001') returning id into shop;
  insert into public.stores(owner_id,name,phone) values(u2,'其他门店','13900000002') returning id into other_shop;
  insert into public.service_items(store_id,name,category,price,duration_minutes,description)
    values(shop,'镀晶','镀晶镀膜',1000,30,'工时 4h · 提成 8%') returning id into svc;
  insert into public.service_items(store_id,name,category,price,duration_minutes,description)
    values(shop,'洗车','洗车',100,30,'工时 40min · 提成 ¥8/单') returning id into svc2;
  assert (select commission_type||commission_value from public.service_items where id=svc)='percent8.00','新建项目按描述解析提成比例';
  assert (select commission_type||commission_value from public.service_items where id=svc2)='fixed8.00','新建项目按描述解析固定提成';
  perform public.save_appointment_settings(shop,'{"opens_at":"00:00","closes_at":"23:59","slot_minutes":15,"capacity":5,"lead_hours":0,"advance_days":30,"grace_minutes":15,"closed_days":[]}');
  bay:=(public.save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}')->>'id')::uuid;

  -- 技师同步创建预约资源；其他角色不创建资源。
  tech:=public.save_staff(shop,jsonb_build_object('name','李国强','phone','13800001111','role','technician',
    'skills','镀晶 / 抛光','bay_id',bay,'joined_on','2022-03-14'),'店主');
  tech_id:=(tech->>'id')::uuid; res_id:=(tech->>'resource_id')::uuid;
  assert tech->>'status'='pending' and res_id is not null;
  assert (select name||phone||category from public.appointment_resources where id=res_id)='李国强13800001111镀晶 / 抛光';
  assert (select linked_id from public.appointment_resources where id=res_id)=bay;
  mgr:=public.save_staff(shop,jsonb_build_object('name','陈明','phone','13800002222','role','manager'),'店主');
  cash:=public.save_staff(shop,jsonb_build_object('name','前台甲','phone','13800003333','role','cashier'),'店主');
  assert mgr->>'resource_id' is null and cash->>'resource_id' is null;
  assert (select count(*) from public.appointment_resources where store_id=shop and kind='technician')=1;
  caught:=false;
  begin perform public.save_staff(shop,jsonb_build_object('name','重名','phone','13800001111','role','cashier'),'店主');
  exception when unique_violation then caught:=true; end;
  assert caught,'同店手机号不能重复';
  caught:=false;
  begin perform public.save_staff(shop,jsonb_build_object('name','x','phone','13800004444','role','boss'),'店主');
  exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'角色必须合法';
  -- 编辑技师同步资源；他店员工不能被改。
  r:=public.save_staff(shop,jsonb_build_object('id',tech_id,'name','李国强2','phone','13800001111','role','technician','skills','贴膜','joined_on','2022-03-14'),'店主');
  assert (select name from public.appointment_resources where id=res_id)='李国强2' and r->>'skills'='贴膜' and r->>'bay_id' is null;
  caught:=false;
  begin perform public.save_staff(other_shop,jsonb_build_object('id',tech_id,'name','x','phone','13800001111','role','technician'),'店主');
  exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能修改外店员工';

  -- 邀请：旧邀请作废，仅存哈希。
  inv:=public.create_staff_invite(shop,tech_id,'hash-1','店主');
  perform public.create_staff_invite(shop,tech_id,'hash-2','店主');
  assert (select count(*) from public.store_staff_invites where staff_id=tech_id and revoked_at is null)=1;
  assert (public.staff_json(shop,tech_id)->'invite'->>'expired')::boolean=false;
  caught:=false;
  begin perform public.create_staff_invite(other_shop,tech_id,'hash-3','店主');
  exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能给外店员工发邀请';

  -- 角色权限：默认值、保存、店长固定、非法键。
  perms:=public.staff_permissions(shop);
  assert (perms->'technician'->>'order_view_own')::boolean and not (perms->'technician'->>'stats_view_store')::boolean;
  assert (perms->'manager'->>'member_recharge_refund')::boolean;
  perms:=public.save_staff_permissions(shop,'technician','{"stats_view_store":true}');
  assert (perms->'technician'->>'stats_view_store')::boolean;
  assert public.staff_has_permission(shop,'technician','stats_view_store');
  assert not public.staff_has_permission(other_shop,'technician','stats_view_store');
  caught:=false; begin perform public.save_staff_permissions(shop,'manager','{"cashier":false}'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'店长权限固定';
  caught:=false; begin perform public.save_staff_permissions(shop,'cashier','{"fly":true}'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'未知权限被拒绝';

  -- 提成方案校验。
  caught:=false; begin perform public.save_staff_commission(shop,tech_id,'{"mode":"flat","rate":120}'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught;
  caught:=false; begin perform public.save_staff_commission(shop,tech_id,jsonb_build_object('mode','custom','overrides',jsonb_build_object(gen_random_uuid(),10))); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'自定义提成只能指向本店项目';

  -- 预约结算生成提成快照：跟随项目 → 镀晶 8% 实收，洗车 ¥8/单。
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,bay_id,status,arrived_at)
    values(shop,'散客',array[svc,svc2],jsonb_build_array(jsonb_build_object('name','镀晶'),jsonb_build_object('name','洗车')),
      now()-interval '1 hour',60,1100,'c-1',res_id,bay,'waiting',null) returning id into a;
  perform public.change_appointment(shop,a,'arrive');
  r:=public.checkout_appointment(shop,a,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1),jsonb_build_object('service_id',svc2,'qty',2)),
    '现金',null,null,'沪A12345','店主','c-1-pay');
  assert (select sum(amount) from public.staff_commissions where staff_id=tech_id)=96,'80 + 8×2';
  assert (select count(*) from public.staff_commissions where staff_id=tech_id and rule='project_percent')=1;
  -- 修改方案后只影响之后的订单，已有快照不重算。
  perform public.save_staff_commission(shop,tech_id,'{"mode":"flat","rate":10}');
  assert (select sum(amount) from public.staff_commissions where staff_id=tech_id)=96;
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,bay_id,status)
    values(shop,'散客2',array[svc],jsonb_build_array(jsonb_build_object('name','镀晶')),now()-interval '2 hour',30,1000,'c-2',res_id,bay,'waiting') returning id into a;
  perform public.change_appointment(shop,a,'arrive');
  perform public.checkout_appointment(shop,a,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金',null,null,'沪B12345','店主','c-2-pay');
  assert (select amount from public.staff_commissions where staff_id=tech_id and rule='flat_percent')=100;
  -- 无技师的预约不产生提成。
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,status)
    values(shop,'散客3',array[svc],jsonb_build_array(jsonb_build_object('name','镀晶')),now()-interval '3 hour',30,1000,'c-3','waiting') returning id into a;
  perform public.change_appointment(shop,a,'arrive');
  perform public.checkout_appointment(shop,a,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金',null,null,'沪C12345','店主','c-3-pay');
  assert (select count(*) from public.staff_commissions where store_id=shop)=3;

  -- 记录与汇总。
  r:=public.staff_records(shop,tech_id,'month');
  assert (r->'summary'->>'orders')::int=2 and (r->'summary'->>'commission')::numeric=196;
  assert jsonb_array_length(r->'rows')=2;
  assert public.staff_records(shop,tech_id,'last')->'summary'->>'orders'='0';
  assert (public.staff_detail(shop,tech_id)->>'total_orders')::int=2;
  assert jsonb_array_length(public.staff_detail(shop,tech_id)->'services')=2 and (public.staff_detail(shop,tech_id)->>'last_month_commission')::numeric=0;

  -- 停用：有待办必须转交；转交后停用资源，启用恢复。
  tech2:=public.save_staff(shop,jsonb_build_object('name','王磊','phone','13800005555','role','technician','skills','洗车'),'店主');
  tech2_id:=(tech2->>'id')::uuid;
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,status,arrived_at)
    values(shop,'施工中',array[svc],jsonb_build_array(jsonb_build_object('name','镀晶')),now()-interval '10 minutes',60,1000,'c-4',res_id,'arrived',now()-interval '10 minutes') returning id into a;
  assert (public.staff_json(shop,tech_id)->>'busy')::boolean;
  assert jsonb_array_length(public.staff_open_work(shop,tech_id))=1;
  caught:=false; begin perform public.set_staff_status(shop,tech_id,'disabled','离职',null,'店主'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'有进行中订单必须先转交';
  caught:=false; begin perform public.set_staff_status(shop,tech_id,'disabled','离职',tech_id,'店主'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'不能转交给自己';
  r:=public.set_staff_status(shop,tech_id,'disabled','已离职',tech2_id,'店主');
  assert r->>'status'='disabled' and r->>'disable_reason'='已离职' and r->>'disabled_by'='店主';
  assert (select technician_id from public.appointments where id=a)=(tech2->>'resource_id')::uuid;
  assert not (select active from public.appointment_resources where id=res_id);
  caught:=false; begin perform public.save_staff(shop,jsonb_build_object('id',tech_id,'name','x','phone','13800001111','role','technician'),'店主'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'停用员工不能编辑';
  caught:=false; begin perform public.create_staff_invite(shop,tech_id,'hash-9','店主'); exception when sqlstate 'P0001' then caught:=true; end;
  assert caught,'停用员工不发邀请';
  r:=public.set_staff_status(shop,tech_id,'enabled',null,null,'店主');
  assert r->>'status'='pending' and (select active from public.appointment_resources where id=res_id);
  assert public.staff_records(shop,tech_id,'all')->'summary'->>'orders'='2','历史记录在停用启用后保留';

  -- 列表与权限。
  r:=public.staff_list(shop);
  assert jsonb_array_length(r->'staff')=4 and jsonb_array_length(r->'services')=2;
  assert not has_function_privilege('authenticated','public.save_staff(uuid,jsonb,text)','execute');
  assert not has_function_privilege('anon','public.staff_list(uuid)','execute');
  assert has_function_privilege('service_role','public.set_staff_status(uuid,uuid,text,text,uuid,text)','execute');
  -- RLS：店主只读本店；令牌哈希表不开放。
  insert into public.store_staff(store_id,name,phone,role) values(other_shop,'他店员工','13800009999','cashier');
  insert into auth.sessions(id,user_id) values(sess,u);
  perform set_config('request.jwt.claim.sub',u::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'session_id',sess)::text,true);
  execute 'set local role authenticated';
  assert (select count(*) from public.store_staff where store_id=shop)=4;
  assert (select count(*) from public.store_staff where store_id=other_shop)=0,'RLS 必须隔离门店';
  caught:=false; begin perform count(*) from public.store_staff_invites; exception when insufficient_privilege then caught:=true; end;
  assert caught,'邀请表不向客户端开放';
  caught:=false; begin update public.store_staff set name='黑客' where store_id=shop; exception when insufficient_privilege then caught:=true; end;
  assert caught,'客户端不能直接写员工';
  execute 'reset role';
end $$;
rollback;
