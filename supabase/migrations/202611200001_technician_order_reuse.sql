-- 技师端开单直接复用商家端开单页：
-- 1. staff_context 返回当前员工的排班资源 ID（resource_id），供开单页默认选中当前技师；
-- 2. 技师默认开启 cashier 权限（允许直接开单、挂单与收款；老板仍可在角色权限页调整）。

create or replace function public.staff_permission_default(p_role text, p_permission text) returns boolean
language sql immutable as $$
  select case p_role
    when 'manager' then p_permission not in ('order_refund','member_refund_adjust','member_delete','staff_manage','expense','export')
    when 'cashier' then p_permission in ('order_view_all','cashier','member_view','member_recharge_refund','arrivals_today','order_submit',
      'cash_queue','member_lookup','member_edit','appt_view','appt_edit','perf_view_own')
    else p_permission in ('order_view_own','progress_update','cashier','stock_use','perf_view_own','arrivals_today','order_submit','member_lookup','appt_view')
  end
$$;

update public.store_role_permissions
set allowed = true, updated_at = now()
where role = 'technician' and permission = 'cashier';

create or replace function public.staff_context(p_store uuid, p_role text, p_staff uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare s public.store_staff; t public.stores; u public.account_subscriptions;
begin
  select * into t from public.stores where id = p_store;
  select * into u from public.account_subscriptions where owner_id = t.owner_id;
  if p_staff is not null then select * into s from public.store_staff where id = p_staff; end if;
  return jsonb_build_object(
    'role', p_role,
    'store_id', p_store,
    'store_name', t.name,
    'caps', public.staff_caps(p_store, p_role),
    'staff_id', p_staff,
    'resource_id', s.resource_id,
    'name', coalesce(s.name, t.contact_name),
    'phone', coalesce(s.phone, t.phone),
    'joined_on', s.joined_on,
    'status', coalesce(s.status, 'active'),
    'plan_expired', coalesce(u.ends_at <= now() or u.starts_at > now(), false),
    'plan_ends_at', u.ends_at,
    'identity_count', (case when p_role = 'owner' then 1 else 0 end)
      + (select count(*) from public.store_staff x join public.stores xs on xs.id = x.store_id
         where x.phone = coalesce(s.phone, t.phone) and x.status in ('pending','active') and xs.archived_at is null)
      + case when p_role <> 'owner' and exists(select 1 from public.merchant_accounts m join auth.users au on au.id = m.owner_id
          where right(regexp_replace(coalesce(au.phone, ''), '\D', '', 'g'), 11) = s.phone) then 1 else 0 end
  );
end $$;

revoke all on function public.staff_context(uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.staff_context(uuid, text, uuid) to service_role;
