-- 「我的 · 编辑资料」：当前登录人的姓名与邮箱。
-- 老板：姓名写入账号下所有门店的联系人（contact_name），邮箱保存在账号上；
-- 员工（店长 / 前台 / 技师）：只改自己的员工档案，不影响他人。
alter table public.merchant_accounts
  add column if not exists email text not null default '' check (length(email) <= 120);
alter table public.store_staff
  add column if not exists email text not null default '' check (length(email) <= 120);

create or replace function public.merchant_profile_get(p_user uuid, p_store uuid, p_role text, p_staff uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select case when p_role = 'owner' then (
    select jsonb_build_object(
      'name', s.contact_name, 'email', a.email, 'role', 'owner', 'phone', a.phone,
      'joined_on', (select (min(x.created_at) at time zone 'Asia/Shanghai')::date from public.stores x where x.owner_id = a.owner_id))
    from public.merchant_accounts a join public.stores s on s.id = p_store and s.owner_id = a.owner_id
    where a.owner_id = p_user)
  else (
    select jsonb_build_object('name', t.name, 'email', t.email, 'role', t.role, 'phone', t.phone, 'joined_on', t.joined_on)
    from public.store_staff t where t.id = p_staff and t.store_id = p_store)
  end
$$;

create or replace function public.merchant_profile_update(
  p_user uuid, p_store uuid, p_role text, p_staff uuid, p_name text, p_email text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_name text := trim(coalesce(p_name, '')); v_email text := trim(coalesce(p_email, ''));
begin
  if length(v_name) not between 1 and 30 then return jsonb_build_object('error', '请填写姓名（1–30 个字）', 'status', 400); end if;
  if v_email <> '' and (length(v_email) > 120 or v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$') then
    return jsonb_build_object('error', '请输入正确的邮箱', 'status', 400);
  end if;
  if p_role = 'owner' then
    update public.stores set contact_name = v_name where owner_id = p_user;
    update public.merchant_accounts set email = v_email where owner_id = p_user;
    if not found then return jsonb_build_object('error', '账号不存在', 'status', 403); end if;
  else
    update public.store_staff set name = v_name, email = v_email where id = p_staff and store_id = p_store;
    if not found then return jsonb_build_object('error', '员工档案不存在', 'status', 403); end if;
  end if;
  return public.merchant_profile_get(p_user, p_store, p_role, p_staff);
end $$;

revoke all on function public.merchant_profile_get(uuid, uuid, text, uuid) from public, anon, authenticated;
revoke all on function public.merchant_profile_update(uuid, uuid, text, uuid, text, text) from public, anon, authenticated;
grant execute on function public.merchant_profile_get(uuid, uuid, text, uuid) to service_role;
grant execute on function public.merchant_profile_update(uuid, uuid, text, uuid, text, text) to service_role;
