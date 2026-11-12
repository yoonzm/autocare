-- 用户自助注销：去掉 15 天冷静期，提交验证码后立即注销。
-- 只改账号：记录注销、释放登录用的手机号 / 邮箱别名、停用登录并让所有设备退出；
-- 门店、会员、订单、库存等业务数据一律不动。同一手机号之后重新注册得到的是全新账号。

create function public.account_cancel_self(p_user uuid) returns boolean
language plpgsql security definer set search_path = public as $$
declare a public.merchant_accounts; v_email text;
begin
  perform pg_advisory_xact_lock(hashtextextended('account-cancel:' || p_user::text, 0));
  select * into a from public.merchant_accounts where owner_id = p_user for update;
  if not found then raise exception 'account_not_found' using errcode = 'P0002'; end if;
  if exists (select 1 from public.account_cancellations where user_id = p_user) then return false; end if;
  insert into public.account_cancellations(user_id, phone, source, reason)
    values (p_user, right(regexp_replace(a.phone, '\D', '', 'g'), 11), 'self', 'user_request');
  -- 释放手机号：旧记录保留原号码在末尾，后台账号列表仍能取到末 11 位。
  update public.merchant_accounts set phone = 'cancelled-' || p_user::text || '-' || a.phone where owner_id = p_user;
  v_email := 'cancelled+' || p_user::text || '@example.invalid';
  update auth.identities set identity_data = identity_data || jsonb_build_object('email', v_email)
    where user_id = p_user and provider = 'email';
  delete from auth.identities where user_id = p_user and provider = 'phone';
  update auth.users set email = v_email, phone = null, banned_until = 'infinity'::timestamptz, updated_at = now()
    where id = p_user;
  delete from auth.sessions where user_id = p_user;
  return true;
end $$;
revoke all on function public.account_cancel_self(uuid) from public, anon, authenticated;
grant execute on function public.account_cancel_self(uuid) to service_role;

-- 已在冷静期内的账号：按用户当时的申请直接完成注销。单个账号失败只告警，不阻断部署。
do $$
declare r record;
begin
  for r in select distinct s.owner_id from public.stores s
    where s.delete_requested_at is not null
      and exists (select 1 from public.merchant_accounts m where m.owner_id = s.owner_id)
      and not exists (select 1 from public.account_cancellations c where c.user_id = s.owner_id)
  loop
    begin
      perform public.account_cancel_self(r.owner_id);
    exception when others then
      raise warning 'self cancellation of % skipped: %', r.owner_id, sqlerrm;
    end;
  end loop;
  update public.stores set delete_requested_at = null where delete_requested_at is not null;
end $$;
