-- 店长默认具备开支管理权限；同步修正已有门店保存的旧默认关闭值。
-- 前台、技师以及其他权限保持不变，后端仍按 expense capability 校验。
create or replace function public.staff_permission_default(p_role text, p_permission text) returns boolean
language sql immutable as $$
  select case p_role
    when 'manager' then p_permission not in ('order_refund','member_refund_adjust','member_delete','staff_manage','export')
    when 'cashier' then p_permission in ('order_view_all','cashier','member_view','member_recharge_refund','arrivals_today','order_submit',
      'cash_queue','member_lookup','member_edit','appt_view','appt_edit','perf_view_own')
    else p_permission in ('order_view_own','progress_update','cashier','stock_use','perf_view_own','arrivals_today','order_submit','member_lookup','appt_view')
  end
$$;

update public.store_role_permissions
set allowed = true, updated_at = now()
where role = 'manager' and permission = 'expense' and not allowed;
