-- 已注销账号（自助或后台强制）绑定过的员工身份不能再被同一手机号顶替登录。
-- 注销会释放手机号，之后验证码登录会新建一个全新用户；员工身份按手机号匹配，所以必须
-- 排除已注销用户绑定的员工行（store_staff.user_id 在 account_cancellations 中）。
-- 员工档案与门店数据不动；老板之后用同一手机号重新注册、或被重新邀请成新的员工行不受影响。
create function public.staff_user_cancelled(p_user uuid) returns boolean
language sql stable security definer set search_path=public as $$
  select p_user is not null and exists(select 1 from public.account_cancellations where user_id=p_user)
$$;
revoke all on function public.staff_user_cancelled(uuid) from public, anon, authenticated;
grant execute on function public.staff_user_cancelled(uuid) to service_role;

create or replace function public.staff_login_exists(p_phone text) returns boolean
language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.store_staff s join public.stores t on t.id=s.store_id
    where s.phone=p_phone and s.status in ('pending','active') and t.archived_at is null
      and not public.staff_user_cancelled(s.user_id))
$$;

do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.staff_identities(uuid,uuid)'::regprocedure) into def;
  patched := replace(def, 'where s.phone=ph and s.status in (''pending'',''active'') and t.archived_at is null',
    'where s.phone=ph and s.status in (''pending'',''active'') and t.archived_at is null and not public.staff_user_cancelled(s.user_id)');
  if patched = def then raise exception 'staff_identities filter not found'; end if;
  execute patched;

  select pg_get_functiondef('public.select_staff_identity(uuid,uuid,uuid)'::regprocedure) into def;
  patched := replace(def, 'where id=p_staff and phone=ph and status in (''pending'',''active'')',
    'where id=p_staff and phone=ph and status in (''pending'',''active'') and not public.staff_user_cancelled(user_id)');
  if patched = def then raise exception 'select_staff_identity filter not found'; end if;
  execute patched;

  -- 已经选过该身份的会话：下一次请求即失效。
  select pg_get_functiondef('public.platform_merchant_session(uuid,uuid,boolean)'::regprocedure) into def;
  patched := replace(def, 'if st.id is null or st.status=''disabled'' then',
    'if st.id is null or st.status=''disabled'' or public.staff_user_cancelled(st.user_id) then');
  if patched = def then raise exception 'platform_merchant_session guard not found'; end if;
  execute patched;
end $$;
