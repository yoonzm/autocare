-- 完整迁移后执行；所有断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); tech_u uuid:=gen_random_uuid(); both_u uuid:=gen_random_uuid();
  shop uuid; shop2 uuid; owner_s uuid:=gen_random_uuid(); tech_s uuid:=gen_random_uuid(); both_s uuid:=gen_random_uuid();
  tech jsonb; cash jsonb; r jsonb; ids jsonb; caps jsonb; tech_id uuid; cash_id uuid; bay uuid; caught boolean;
begin
  insert into auth.users(id,phone) values(owner_u,'8613900000001'),(tech_u,'8613800001111'),(both_u,'8613800002222');
  insert into auth.sessions(id,user_id) values(owner_s,owner_u),(tech_s,tech_u),(both_s,both_u);
  insert into public.stores(owner_id,name,phone) values(owner_u,'老板的店','13900000001') returning id into shop;
  insert into public.stores(owner_id,name,phone) values(both_u,'兼职老板的店','13800002222') returning id into shop2;
  bay:=(public.save_appointment_resource(shop,'{"kind":"bay","name":"1 号工位"}')->>'id')::uuid;
  tech:=public.save_staff(shop,jsonb_build_object('name','老周','phone','13800001111','role','technician','bay_id',bay),'店主');
  cash:=public.save_staff(shop,jsonb_build_object('name','小刘','phone','13800002222','role','cashier'),'店主');
  tech_id:=(tech->>'id')::uuid; cash_id:=(cash->>'id')::uuid;

  -- 登录：员工手机号有身份才允许走员工登录；未登记的不行。
  assert public.staff_login_exists('13800001111') and not public.staff_login_exists('13700000000');

  -- 身份列表：纯员工 1 个；老板兼前台 2 个（老板 + 前台）。
  ids:=public.staff_identities(tech_u,tech_s);
  assert jsonb_array_length(ids->'items')=1 and ids->'items'->0->>'role'='technician' and ids->'items'->0->>'status'='pending';
  ids:=public.staff_identities(both_u,both_s);
  assert jsonb_array_length(ids->'items')=2 and ids->'items'->0->>'kind'='owner' and ids->'items'->1->>'role'='cashier';
  assert public.staff_identities(tech_u,gen_random_uuid())->>'status'='401','会话不属于该用户';

  -- 未选身份的员工用户没有任何业务会话。
  assert public.platform_merchant_session(tech_u,tech_s,true)->>'status'='403';
  -- 选择身份后：待确认时业务请求被拦截（join_required），个人上下文仍可读。
  assert (public.select_staff_identity(tech_u,tech_s,tech_id))->>'ok'='true';
  r:=public.platform_merchant_session(tech_u,tech_s,true);
  assert r->>'code'='join_required';
  r:=public.platform_merchant_session(tech_u,tech_s,false);
  assert r->>'role'='technician' and (r->>'store_id')::uuid=shop and (r->>'staff_id')::uuid=tech_id;
  -- 不能选别人的身份。
  assert public.select_staff_identity(tech_u,tech_s,cash_id)->>'status'='403';
  -- 确认加入：激活，之后业务请求可用，邀请记为已接受。
  perform public.create_staff_invite(shop,tech_id,'tok-1','店主');
  assert public.staff_join_confirm(tech_u,tech_s)->>'ok'='true';
  assert (select status from public.store_staff where id=tech_id)='active' and (select user_id from public.store_staff where id=tech_id)=tech_u;
  assert exists(select 1 from public.store_staff_invites where staff_id=tech_id and accepted_at is not null);
  r:=public.platform_merchant_session(tech_u,tech_s,true);
  assert r->>'role'='technician' and (r->>'store_id')::uuid=shop;

  -- 生效权限：技师不能看会员完整资料 / 营业额 / 收银，即使保存了开关。
  caps:=public.staff_caps(shop,'technician');
  assert (caps->>'order_view_own')::boolean and (caps->>'order_submit')::boolean and (caps->>'member_lookup')::boolean;
  assert not (caps->>'member_view')::boolean and not (caps->>'cashier')::boolean and not (caps->>'stats_view_store')::boolean;
  assert not (caps->>'member_refund_adjust')::boolean and not (caps->>'staff_manage')::boolean;
  update public.store_role_permissions set allowed=true where store_id=shop and role='technician' and permission in ('member_view','stats_view_store');
  assert not (public.staff_caps(shop,'technician')->>'member_view')::boolean,'不可开启的项不受已保存开关影响';
  -- 技师可由老板打开「开单收银」（设计稿：可配·默认关）。
  perform public.save_staff_permissions(shop,'technician','{"cashier":true}');
  assert (public.staff_caps(shop,'technician')->>'cashier')::boolean;
  caps:=public.staff_caps(shop,'cashier');
  assert (caps->>'cashier')::boolean and (caps->>'member_recharge_refund')::boolean and (caps->>'cash_queue')::boolean;
  assert not (caps->>'order_refund')::boolean and not (caps->>'stock_manage')::boolean and not (caps->>'expense')::boolean;
  caps:=public.staff_caps(shop,'manager');
  assert (caps->>'staff_view')::boolean and (caps->>'catalog_manage')::boolean and not (caps->>'order_refund')::boolean;
  assert (select bool_and(value::text='true') from jsonb_each(public.staff_caps(shop,'owner')));

  -- 上下文：角色、门店名、权限、套餐状态。
  r:=public.staff_context(shop,'technician',tech_id);
  assert (r->>'identity_count')::int=1,'纯员工只有一个身份';
  assert (public.staff_context(shop2,'owner',null)->>'identity_count')::int=2,'兼职老板有老板 + 前台两个身份';
  assert r->>'role'='technician' and r->>'store_name'='老板的店' and r->>'name'='老周' and not (r->>'plan_expired')::boolean;

  -- 工作台：技师只看自己的任务；前台看全店今日待到店 / 施工中，只给笔数。
  insert into public.appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,status,vehicle_plate)
    values(shop,'李梅','{}',jsonb_build_array(jsonb_build_object('name','精致洗车')),now()+interval '1 minute',30,68,'h-1',(tech->>'resource_id')::uuid,'waiting','沪AF09316'),
          (shop,'他人','{}','[]',now()+interval '2 minute',30,68,'h-2',null,'waiting','沪B1');
  r:=public.staff_home(shop,tech_id);
  assert (r->>'waiting')::int=1 and jsonb_array_length(r->'tasks')=1 and r->'tasks'->0->>'plate'='沪AF09316' and (r->>'done_today')::int=0;
  r:=public.staff_home(shop,cash_id);
  assert (r->>'waiting')::int>=1 and r ? 'orders_today' and not (r ? 'revenue_today'),'前台不返回营业额';
  caught:=false; begin perform public.staff_home(shop2,tech_id); exception when sqlstate 'P0002' then caught:=true; end;
  assert caught,'不能读取他店员工的工作台';

  -- 套餐到期：员工业务请求返回 plan_expired；老板的退出/读取走非业务路径不受影响。
  update public.account_subscriptions set ends_at=now()-interval '1 day' where owner_id=owner_u;
  r:=public.platform_merchant_session(tech_u,tech_s,true);
  assert r->>'code'='plan_expired' and (r->>'status')::int=403;
  assert public.platform_merchant_session(tech_u,tech_s,false)->>'role'='technician';
  assert (public.staff_context(shop,'technician',tech_id)->>'plan_expired')::boolean;
  update public.account_subscriptions set ends_at=now()+interval '30 days' where owner_id=owner_u;

  -- 兼职老板：默认老板身份；切换到前台后只有员工权限，切回来恢复。
  r:=public.platform_merchant_session(both_u,both_s,true);
  assert r->>'role'='owner' and (r->>'store_id')::uuid=shop2;
  perform public.select_staff_identity(both_u,both_s,cash_id);
  perform public.staff_join_confirm(both_u,both_s);
  r:=public.platform_merchant_session(both_u,both_s,true);
  assert r->>'role'='cashier' and (r->>'store_id')::uuid=shop;
  assert public.select_staff_identity(both_u,both_s,null)->>'ok'='true';
  assert public.platform_merchant_session(both_u,both_s,true)->>'role'='owner';
  -- 非店主不能切回老板身份。
  assert public.select_staff_identity(tech_u,tech_s,null)->>'status'='403';

  -- 停用：身份会话被清除，下一次请求即身份失效。（有待到店预约时必须先转交，这里先取消）
  update public.appointments set status='cancelled' where request_id='h-1';
  perform public.set_staff_status(shop,tech_id,'disabled','已离职',null,'店主');
  r:=public.platform_merchant_session(tech_u,tech_s,true);
  assert (r->>'status')::int in (401,403) and r->>'error' is not null;
  assert not exists(select 1 from public.staff_sessions where staff_id=tech_id);
  assert jsonb_array_length(public.staff_identities(tech_u,tech_s)->'items')=0,'停用身份不出现在选择页';
  caught:=false; begin perform public.select_staff_identity(tech_u,tech_s,tech_id); caught:=true; exception when others then null; end;
  assert public.select_staff_identity(tech_u,tech_s,tech_id)->>'status'='403','停用身份不能再选';

  -- 已注销账号绑定的员工身份：同一手机号（含注销后新建的用户）不能再顶替登录；老板身份另算。
  perform public.select_staff_identity(both_u,both_s,cash_id);
  insert into public.account_cancellations(user_id,phone,source,reason) values(both_u,'13800002222','admin','violation');
  assert not public.staff_login_exists('13800002222'),'已注销员工不能再走员工登录';
  assert (public.platform_merchant_session(both_u,both_s,true)->>'status')::int=401,'已选身份的会话立即失效';
  assert not exists(select 1 from jsonb_array_elements(public.staff_identities(both_u,both_s)->'items') i where i->>'kind'='staff');
  declare new_u uuid:=gen_random_uuid(); new_s uuid:=gen_random_uuid();
  begin
    insert into auth.users(id,phone) values(new_u,'8613800002222');
    insert into auth.sessions(id,user_id) values(new_s,new_u);
    assert jsonb_array_length(public.staff_identities(new_u,new_s)->'items')=0,'新用户拿不到已注销员工的身份';
    assert public.select_staff_identity(new_u,new_s,cash_id)->>'status'='403';
  end;

  -- 函数权限：仅 service_role。
  assert not has_function_privilege('authenticated','public.staff_identities(uuid,uuid)','execute');
  assert not has_function_privilege('anon','public.platform_merchant_session(uuid,uuid,boolean)','execute');
  assert has_function_privilege('service_role','public.select_staff_identity(uuid,uuid,uuid)','execute');
end $$;
rollback;
