-- 注销（自助或后台强制）都释放登录用的手机号 / 邮箱别名：旧账号保留并停用，
-- 同一手机号之后重新注册是一个全新账号。门店、会员、订单等业务数据一律不动。

create function public.account_release_login(p_user uuid) returns void
language plpgsql security definer set search_path = public as $$
declare a public.merchant_accounts; v_email text;
begin
  select * into a from public.merchant_accounts where owner_id = p_user for update;
  -- 老板账号的手机号唯一：改成带原号码后缀的占位值（后台列表取末 11 位仍是原号码）。
  if found and a.phone not like 'cancelled-%' then
    update public.merchant_accounts set phone = 'cancelled-' || p_user::text || '-' || a.phone where owner_id = p_user;
  end if;
  v_email := 'cancelled+' || p_user::text || '@example.invalid';
  update auth.identities set identity_data = identity_data || jsonb_build_object('email', v_email)
    where user_id = p_user and provider = 'email';
  delete from auth.identities where user_id = p_user and provider = 'phone';
  update auth.users set email = v_email, phone = null, banned_until = 'infinity'::timestamptz, updated_at = now()
    where id = p_user;
  delete from auth.sessions where user_id = p_user;
end $$;
revoke all on function public.account_release_login(uuid) from public, anon, authenticated;
grant execute on function public.account_release_login(uuid) to service_role;

-- 自助注销改为复用同一个释放函数（行为不变）。
create or replace function public.account_cancel_self(p_user uuid) returns boolean
language plpgsql security definer set search_path = public as $$
declare a public.merchant_accounts;
begin
  perform pg_advisory_xact_lock(hashtextextended('account-cancel:' || p_user::text, 0));
  select * into a from public.merchant_accounts where owner_id = p_user for update;
  if not found then raise exception 'account_not_found' using errcode = 'P0002'; end if;
  if exists (select 1 from public.account_cancellations where user_id = p_user) then return false; end if;
  insert into public.account_cancellations(user_id, phone, source, reason)
    values (p_user, right(regexp_replace(a.phone, '\D', '', 'g'), 11), 'self', 'user_request');
  perform public.account_release_login(p_user);
  return true;
end $$;

-- 后台强制注销：原先只删除会话，现在同样释放手机号（其余逻辑与审计不变）。
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.admin_user_cancel(uuid,uuid,uuid,text,text,uuid)'::regprocedure) into def;
  patched := replace(def, 'delete from auth.sessions where user_id = p_user;', 'perform public.account_release_login(p_user);');
  if patched = def then raise exception 'admin_user_cancel session cleanup not found'; end if;
  execute patched;
end $$;

-- 已被后台强制注销、手机号仍被占用的账号：补做释放，之后这些手机号可以重新注册。单个失败只告警。
do $$
declare r record;
begin
  for r in select c.user_id from public.account_cancellations c
  loop
    begin
      perform public.account_release_login(r.user_id);
    exception when others then
      raise warning 'release login of % skipped: %', r.user_id, sqlerrm;
    end;
  end loop;
end $$;
