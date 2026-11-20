begin;
do $$
declare owner_u uuid:=gen_random_uuid(); manager_u uuid:=gen_random_uuid(); tech_u uuid:=gen_random_uuid();
 owner_s uuid:=gen_random_uuid(); manager_s uuid:=gen_random_uuid(); tech_s uuid:=gen_random_uuid();
 shop uuid; other_shop uuid; manager_id uuid; other_manager uuid; other_staff uuid; employee uuid; tech_id uuid; resource_id uuid;
 r jsonb; op text; caught boolean;
begin
 insert into auth.users(id,phone) values(owner_u,'8613900010001'),(manager_u,'8613800010002'),(tech_u,'8613800010003');
 insert into auth.sessions(id,user_id) values(owner_s,owner_u),(manager_s,manager_u),(tech_s,tech_u);
 insert into stores(owner_id,name,phone) values(owner_u,'员工权限测试店','13900010001') returning id into shop;
 insert into stores(owner_id,name,phone) values(tech_u,'其他门店','13800010003') returning id into other_shop;
 manager_id:=(save_staff(shop,'{"name":"店长","phone":"13800010002","role":"manager"}','老板')->>'id')::uuid;
 other_manager:=(save_staff(shop,'{"name":"其他店长","phone":"13800010004","role":"manager"}','老板')->>'id')::uuid;
 other_staff:=(save_staff(other_shop,'{"name":"他店前台","phone":"13800010005","role":"cashier"}','老板')->>'id')::uuid;
 perform select_staff_identity(manager_u,manager_s,manager_id);
 perform staff_join_confirm(manager_u,manager_s);
 assert staff_has_permission(shop,'manager','staff_manage');
 assert not staff_has_permission(shop,'cashier','staff_manage');
 assert not staff_has_permission(shop,'technician','staff_manage');
 r:=manage_store_staff(manager_u,manager_s,shop,'save','{"name":"前台","phone":"13800010006","role":"cashier"}');
 employee:=(r->>'id')::uuid;
 assert employee is not null;
 r:=manage_store_staff(manager_u,manager_s,shop,'save',jsonb_build_object('id',employee,'name','前台改名','phone','13800010006','role','cashier'));
 assert r->>'name'='前台改名';
 perform manage_store_staff(manager_u,manager_s,shop,'invite',jsonb_build_object('id',employee,'hash','invite-test'));
 assert exists(select 1 from store_staff_invites where staff_id=employee);
 perform manage_store_staff(manager_u,manager_s,shop,'status',jsonb_build_object('id',employee,'status','disabled'));
 assert (select status from store_staff where id=employee)='disabled';
 perform manage_store_staff(manager_u,manager_s,shop,'status',jsonb_build_object('id',employee,'status','enabled'));
 assert (select status from store_staff where id=employee)<>'disabled';
 -- 新增店长、提升普通店员均禁止。
 caught:=false; begin
  perform manage_store_staff(manager_u,manager_s,shop,'save','{"name":"越权","phone":"13800010007","role":"manager"}');
 exception when insufficient_privilege then caught:=true; end; assert caught;
 caught:=false; begin
  perform manage_store_staff(manager_u,manager_s,shop,'save',jsonb_build_object('id',employee,'name','升职','phone','13800010006','role','manager'));
 exception when insufficient_privilege then caught:=true; end; assert caught;
 foreach op in array array['save','status','invite'] loop
  caught:=false; begin
   perform manage_store_staff(manager_u,manager_s,shop,op,jsonb_build_object('id',manager_id,'role','cashier','status','disabled'));
  exception when insufficient_privilege then caught:=true; end; assert caught,'不能管理自己';
  caught:=false; begin
   perform manage_store_staff(manager_u,manager_s,shop,op,jsonb_build_object('id',other_manager,'role','cashier','status','disabled'));
  exception when insufficient_privilege then caught:=true; end; assert caught,'不能管理其他店长';
  caught:=false; begin
   perform manage_store_staff(manager_u,manager_s,shop,op,jsonb_build_object('id',other_staff,'role','cashier','status','disabled'));
  exception when no_data_found then caught:=true; end; assert caught,'不能操作他店员工';
 end loop;
 foreach op in array array['commission','permissions','unknown'] loop
  caught:=false; begin perform manage_store_staff(manager_u,manager_s,shop,op,jsonb_build_object('id',employee));
  exception when insufficient_privilege then caught:=true; end; assert caught;
 end loop;
 caught:=false; begin perform manage_store_staff(manager_u,manager_s,other_shop,'save','{}');
 exception when serialization_failure then caught:=true; end; assert caught,'不能伪造门店';
 assert manage_store_staff(manager_u,gen_random_uuid(),shop,'save','{}') ? 'error';
 -- 老板仍可任命店长；普通技师不能使用入口。
 perform select_staff_identity(owner_u,owner_s,null);
 r:=manage_store_staff(owner_u,owner_s,shop,'save','{"name":"老板任命店长","phone":"13800010008","role":"manager"}');
 assert r->>'role'='manager';
 perform manage_store_staff(owner_u,owner_s,shop,'commission',jsonb_build_object('id',employee,'mode','flat','rate',10));
 assert (select commission_rate from store_staff where id=employee)=10;
 perform manage_store_staff(owner_u,owner_s,shop,'permissions','{"role":"cashier","permissions":{"member_view":true}}');
 assert staff_has_permission(shop,'cashier','member_view');
 r:=manage_store_staff(manager_u,manager_s,shop,'save','{"name":"技师","phone":"13800010003","role":"technician"}');
 tech_id:=(r->>'id')::uuid; resource_id:=(r->>'resource_id')::uuid;
 insert into appointments(store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,request_id,technician_id,status)
 values(shop,'待施工客户','{}','[]',now()+interval '1 hour',30,68,'manager-staff-open-task',resource_id,'waiting');
 caught:=false; begin
  perform manage_store_staff(manager_u,manager_s,shop,'status',jsonb_build_object('id',tech_id,'status','disabled'));
 exception when raise_exception then
  if sqlerrm<>'staff_has_open_work' then raise; end if;
  caught:=true;
 end; assert caught,'店长停用技师仍需处理未完工任务';
 insert into held_orders(store_id,vehicle_plate,status,technician_ids)
 values(shop,'沪A12345','待施工',array[resource_id]);
 caught:=false; begin
  perform manage_store_staff(manager_u,manager_s,shop,'status',jsonb_build_object('id',tech_id,'status','disabled'));
 exception when raise_exception then
  if sqlerrm<>'staff_has_open_tasks' then raise; end if;
  caught:=true;
 end; assert caught,'挂单施工任务不能被停用绕过';
 perform select_staff_identity(tech_u,tech_s,tech_id);
 perform staff_join_confirm(tech_u,tech_s);
 caught:=false; begin perform manage_store_staff(tech_u,tech_s,shop,'save','{}');
 exception when insufficient_privilege then caught:=true; end; assert caught;
 perform set_staff_status(shop,manager_id,'disabled',null,null,'老板');
 assert manage_store_staff(manager_u,manager_s,shop,'save','{}') ? 'error','停用的店长不能继续操作';
 assert not has_function_privilege('authenticated','manage_store_staff(uuid,uuid,uuid,text,jsonb)','EXECUTE');
end $$;
rollback;
