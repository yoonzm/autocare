-- 修复：staff_list 会通过 staff_permissions 补写本店默认角色权限，却声明成 STABLE。
-- PostgREST 对 STABLE 函数使用只读事务，线上调用会报“cannot execute INSERT in a read-only transaction”（SRV_500）。
-- 改为默认的 VOLATILE（CREATE OR REPLACE 保留原有授权）。
create or replace function public.staff_list(p_store uuid) returns jsonb
language sql security definer set search_path=public as $$
  select jsonb_build_object(
    'staff',coalesce((select jsonb_agg(public.staff_json(p_store,s.id) order by s.status='disabled',s.created_at) from public.store_staff s where s.store_id=p_store),'[]'::jsonb),
    'permissions',public.staff_permissions(p_store),
    'services',coalesce((select jsonb_agg(jsonb_build_object('id',v.id,'name',v.name,'commission_type',v.commission_type,
      'commission_value',v.commission_value) order by v.created_at) from public.service_items v where v.store_id=p_store and v.active),'[]'::jsonb),
    'bays',coalesce((select jsonb_agg(jsonb_build_object('id',b.id,'name',b.name) order by b.position,b.created_at)
      from public.appointment_resources b where b.store_id=p_store and b.kind='bay' and b.active),'[]'::jsonb))
$$;
revoke all on function public.staff_list(uuid) from public,anon,authenticated;
grant execute on function public.staff_list(uuid) to service_role;
