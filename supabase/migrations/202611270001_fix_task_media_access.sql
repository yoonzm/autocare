-- 修复 202611200005 覆盖 merchant_media_access 时丢失 held_orders 施工照片校验的问题。
-- 保留门店照片对老板与活跃店长的访问校验，同时恢复挂单任务（held_orders）与历史预约（appointments）的技师照片访问校验。
create or replace function public.merchant_media_access(
  p_store uuid,
  p_user uuid,
  p_staff uuid,
  p_kind text,
  p_target uuid
)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_kind = 'store' then
    if p_target is null or p_target <> p_store or not exists(
      select 1 from public.stores
      where id = p_store and archived_at is null and (
        owner_id = p_user or exists(
          select 1 from public.store_staff st
          where st.id = p_staff and st.store_id = p_store
            and st.user_id = p_user and st.role = 'manager' and st.status = 'active'
        )
      )
    ) then
      raise exception 'media_forbidden' using errcode = '42501';
    end if;
  elsif p_kind = 'task' then
    if not exists(
      select 1 from public.held_orders h
      join public.store_staff s on s.store_id = h.store_id and s.resource_id = any(h.technician_ids)
      where h.id = p_target and h.store_id = p_store and s.id = p_staff and s.status = 'active' and h.cancelled_at is null
    ) and not exists(
      select 1 from public.appointments a
      join public.store_staff s on s.store_id = a.store_id and s.resource_id = a.technician_id
      where a.id = p_target and a.store_id = p_store and s.id = p_staff and s.status = 'active' and a.status in ('waiting', 'arrived', 'done')
    ) then
      raise exception 'media_forbidden' using errcode = '42501';
    end if;
  else
    raise exception 'media_kind_invalid';
  end if;
end $$;

revoke all on function public.merchant_media_access(uuid, uuid, uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.merchant_media_access(uuid, uuid, uuid, text, uuid) to service_role;
