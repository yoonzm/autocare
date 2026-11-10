-- 「编辑资料」头像：私有存储桶，路径记在老板账号 / 员工档案上；读取时由云函数签发短期链接。
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('profile-avatars','profile-avatars',false,5242880,array['image/jpeg','image/png'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

alter table public.merchant_accounts add column if not exists avatar_path text not null default '' check (length(avatar_path) <= 200);
alter table public.store_staff add column if not exists avatar_path text not null default '' check (length(avatar_path) <= 200);

create or replace function public.merchant_profile_get(p_user uuid, p_store uuid, p_role text, p_staff uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select case when p_role = 'owner' then (
    select jsonb_build_object(
      'name', s.contact_name, 'email', a.email, 'role', 'owner', 'phone', a.phone, 'avatar_path', a.avatar_path,
      'joined_on', (select (min(x.created_at) at time zone 'Asia/Shanghai')::date from public.stores x where x.owner_id = a.owner_id))
    from public.merchant_accounts a join public.stores s on s.id = p_store and s.owner_id = a.owner_id
    where a.owner_id = p_user)
  else (
    select jsonb_build_object('name', t.name, 'email', t.email, 'role', t.role, 'phone', t.phone, 'avatar_path', t.avatar_path, 'joined_on', t.joined_on)
    from public.store_staff t where t.id = p_staff and t.store_id = p_store)
  end
$$;

-- 记录新头像路径，返回旧路径供云函数清理；只改当前登录身份自己的档案。
create or replace function public.merchant_profile_set_avatar(
  p_user uuid, p_store uuid, p_role text, p_staff uuid, p_path text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_old text;
begin
  if p_role = 'owner' then
    select avatar_path into v_old from public.merchant_accounts where owner_id = p_user for update;
    if not found then return jsonb_build_object('error', '账号不存在', 'status', 403); end if;
    update public.merchant_accounts set avatar_path = p_path where owner_id = p_user;
  else
    select avatar_path into v_old from public.store_staff where id = p_staff and store_id = p_store for update;
    if not found then return jsonb_build_object('error', '员工档案不存在', 'status', 403); end if;
    update public.store_staff set avatar_path = p_path where id = p_staff;
  end if;
  return jsonb_build_object('old', v_old);
end $$;

revoke all on function public.merchant_profile_get(uuid, uuid, text, uuid) from public, anon, authenticated;
revoke all on function public.merchant_profile_set_avatar(uuid, uuid, text, uuid, text) from public, anon, authenticated;
grant execute on function public.merchant_profile_get(uuid, uuid, text, uuid) to service_role;
grant execute on function public.merchant_profile_set_avatar(uuid, uuid, text, uuid, text) to service_role;
