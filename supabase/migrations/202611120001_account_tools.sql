-- Account device metadata is informational; identity always comes from the verified JWT.
create table public.account_session_devices (
  session_id uuid primary key references auth.sessions(id) on delete cascade,
  platform text not null check (platform in ('Android','iOS','macOS','Windows','Linux','网页端'))
);
alter table public.account_session_devices enable row level security;
revoke all on public.account_session_devices from public, anon, authenticated;
grant all on public.account_session_devices to service_role;

create function public.account_devices(p_user uuid, p_session uuid, p_platform text default '') returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if not public.staff_session_valid(p_user,p_session) or not exists (
    select 1 from auth.sessions where id=p_session and (not_after is null or not_after>now())
  ) then
    return jsonb_build_object('error','登录已过期','status',401);
  end if;
  if p_platform in ('Android','iOS','macOS','Windows','Linux','网页端') then
    insert into public.account_session_devices values(p_session,p_platform)
      on conflict(session_id) do update set platform=excluded.platform;
  end if;
  return jsonb_build_object('items',coalesce((
    select jsonb_agg(jsonb_build_object('id',s.id,'current',s.id=p_session,
      'name',coalesce(d.platform,'未识别设备'), 'created_at',s.created_at,
      'active_at',coalesce(s.refreshed_at,s.created_at)) order by (s.id=p_session) desc,s.created_at desc)
    from auth.sessions s left join public.account_session_devices d on d.session_id=s.id
    where s.user_id=p_user and (s.not_after is null or s.not_after>now())
  ),'[]'::jsonb));
end $$;

create function public.account_device_revoke(p_user uuid,p_session uuid,p_target uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if not public.staff_session_valid(p_user,p_session) or not exists (
    select 1 from auth.sessions where id=p_session and (not_after is null or not_after>now())
  ) then
    return jsonb_build_object('error','登录已过期','status',401);
  end if;
  if p_target=p_session then return jsonb_build_object('error','当前设备请使用退出登录','status',400); end if;
  -- Scope the deletion by user as well as session. A repeated removal is idempotent.
  delete from auth.sessions where id=p_target and user_id=p_user;
  return jsonb_build_object('ok',true);
end $$;

create function public.account_cancel_check(p_user uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_holds bigint; v_appointments bigint;
begin
  if not exists(select 1 from public.merchant_accounts where owner_id=p_user) then
    return jsonb_build_object('error','仅店主可注销商户账号','status',403);
  end if;
  -- Check every store owned by the account, including archived stores with unfinished work.
  select count(*) into v_holds from public.held_orders h join public.stores s on s.id=h.store_id
    where s.owner_id=p_user and h.settled_at is null and h.cancelled_at is null;
  select count(*) into v_appointments from public.appointments a join public.stores s on s.id=a.store_id
    where s.owner_id=p_user and a.status in ('waiting','arrived');
  return jsonb_build_object('holds',v_holds,'appointments',v_appointments,
    'can_cancel',v_holds=0 and v_appointments=0,
    'billing_note','限时免费期间无套餐欠费','data_note','门店经营数据保留，不会被清除');
end $$;

-- Preserve immediate cancellation and phone release, but enforce the displayed conditions at submission.
create or replace function public.account_cancel_self(p_user uuid) returns boolean
language plpgsql security definer set search_path = public as $$
declare a public.merchant_accounts; conditions jsonb; store_row record;
begin
  perform pg_advisory_xact_lock(hashtextextended('account-cancel:' || p_user::text,0));
  select * into a from public.merchant_accounts where owner_id=p_user for update;
  if not found then raise exception 'account_not_found' using errcode='P0002'; end if;
  if exists(select 1 from public.account_cancellations where user_id=p_user) then return false; end if;
  for store_row in select id from public.stores where owner_id=p_user order by id loop
    perform pg_advisory_xact_lock(hashtextextended(store_row.id::text,0));
  end loop;
  conditions := public.account_cancel_check(p_user);
  if conditions->>'can_cancel' <> 'true' then raise exception 'account_has_pending_work'; end if;
  insert into public.account_cancellations(user_id,phone,source,reason)
    values(p_user,right(regexp_replace(a.phone,'\D','','g'),11),'self','user_request');
  perform public.account_release_login(p_user);
  return true;
end $$;

revoke all on function public.account_devices(uuid,uuid,text), public.account_device_revoke(uuid,uuid,uuid), public.account_cancel_check(uuid), public.account_cancel_self(uuid) from public, anon, authenticated;
grant execute on function public.account_devices(uuid,uuid,text), public.account_device_revoke(uuid,uuid,uuid), public.account_cancel_check(uuid), public.account_cancel_self(uuid) to service_role;
