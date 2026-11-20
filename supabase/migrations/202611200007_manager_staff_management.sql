-- 店长管理本店前台/技师；店长任命、角色授权和提成仅老板可操作。
create or replace function public.staff_permission_default(p_role text, p_permission text) returns boolean
language sql immutable as $$
  select case p_role
    when 'manager' then p_permission not in ('order_refund','member_refund_adjust','member_delete','export')
    when 'cashier' then p_permission in ('order_view_all','cashier','member_view','member_recharge_refund','arrivals_today','order_submit',
      'cash_queue','member_lookup','member_edit','appt_view','appt_edit','perf_view_own')
    else p_permission in ('order_view_own','progress_update','cashier','stock_use','perf_view_own','arrivals_today','order_submit','member_lookup','appt_view')
  end
$$;

update public.store_role_permissions
set allowed = true, updated_at = now()
where role = 'manager' and permission = 'staff_manage' and not allowed;

-- 所有员工写操作共用此入口；身份来自服务端校验后的登录会话。
create function public.manage_store_staff(p_user uuid,p_session uuid,p_store uuid,p_action text,p_input jsonb)
returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb; actor text; target public.store_staff; target_id uuid; operator_name text;
begin
 state:=public.platform_merchant_session(p_user,p_session,true);
 if state ? 'error' then return state; end if;
 if (state->>'store_id')::uuid is distinct from p_store then
  raise exception '当前门店已变化，请刷新后重试' using errcode='40001';
 end if;
 actor:=coalesce(state->>'role','owner');
 if actor not in ('owner','manager') then
  raise exception 'staff_management_forbidden' using errcode='42501';
 end if;
 if p_action not in ('save','status','invite','commission','permissions') then
  raise exception 'staff_management_forbidden' using errcode='42501';
 end if;
 if actor='manager' and (p_action in ('commission','permissions') or
    not public.staff_has_permission(p_store,'manager','staff_manage')) then
  raise exception 'staff_management_forbidden' using errcode='42501';
 end if;
 -- 与 save_staff 使用同一个门店锁，角色校验与写入在同一事务内。
 perform pg_advisory_xact_lock(hashtextextended(p_store::text,2));
 target_id:=nullif(p_input->>'id','')::uuid;
 if p_action<>'permissions' then
  if target_id is not null then
   select * into target from public.store_staff where id=target_id and store_id=p_store for update;
   if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  elsif p_action<>'save' then raise exception 'staff_not_found' using errcode='P0002';
  end if;
  if actor='manager' and (
    (target_id is not null and (target.role not in ('cashier','technician') or target_id=(state->>'staff_id')::uuid)) or
    (p_action='save' and coalesce(p_input->>'role','') not in ('cashier','technician'))
  ) then raise exception 'staff_management_forbidden' using errcode='42501'; end if;
 end if;
 -- 挂单施工任务已与预约分离；未完成的挂单必须先处理，不能遗留给停用账号。
 if target.role='technician' and
    ((p_action='status' and p_input->>'status'='disabled') or
     (p_action='save' and p_input->>'role'<>'technician')) and exists(
   select 1 from public.held_orders h where h.store_id=p_store
     and target.resource_id=any(h.technician_ids)
     and h.cancelled_at is null and h.settled_at is null and h.status in ('待施工','施工中')
 ) then raise exception 'staff_has_open_tasks'; end if;
 if actor='manager' then
  select name into operator_name from public.store_staff where id=(state->>'staff_id')::uuid and store_id=p_store;
 else select coalesce(nullif(contact_name,''),'老板') into operator_name from public.stores where id=p_store;
 end if;
 case p_action
 when 'save' then return public.save_staff(p_store,p_input,operator_name);
 when 'status' then return public.set_staff_status(p_store,target_id,p_input->>'status',p_input->>'reason',nullif(p_input->>'transfer_to','')::uuid,operator_name);
 when 'invite' then return public.create_staff_invite(p_store,target_id,p_input->>'hash',operator_name);
 when 'commission' then return public.save_staff_commission(p_store,target_id,p_input);
 when 'permissions' then return public.save_staff_permissions(p_store,p_input->>'role',p_input->'permissions');
 end case;
end $$;
revoke all on function public.manage_store_staff(uuid,uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.manage_store_staff(uuid,uuid,uuid,text,jsonb) to service_role;
