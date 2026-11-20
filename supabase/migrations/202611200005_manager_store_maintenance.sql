-- 店长可维护当前门店基本信息及照片；门店生命周期仍仅老板可操作。
create or replace function public.merchant_store_mutate(p_user uuid,p_session uuid,p_action text,p_input jsonb,p_request text) returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb;a merchant_accounts;u account_subscriptions;r merchant_store_requests;s stores;target uuid;n int;lim int;v_name text;v_phone text;v_address text;result jsonb;v_owner uuid;begin
 state:=platform_merchant_session(p_user,p_session,p_action='update');
 if state?'error' then return state;end if;
 if coalesce(state->>'role','owner') not in ('owner','manager') or
    (state->>'role'='manager' and p_action<>'update') then
  raise exception '该功能无权访问' using errcode='42501';
 end if;
 if p_request is null or length(p_request)<1 or length(p_request)>128 then raise exception '缺少请求编号';end if;
 if state->>'role'='manager' then
  -- 身份来自有效会话；不能传入其他门店，也不能重放其他身份的请求。
  if p_input->>'id' is distinct from state->>'store_id' then
   raise exception '当前门店已变化，请重新打开页面' using errcode='40001';
  end if;
  select owner_id into v_owner from stores where id=(state->>'store_id')::uuid;
  p_request:='manager:'||p_user::text||':'||(state->>'staff_id')||':'||p_request;
 else v_owner:=p_user; end if;
 -- 与老板的门店维护共用账号锁，串行校验同名门店及幂等请求。
 select * into a from merchant_accounts where owner_id=v_owner for update;
 select * into r from merchant_store_requests where owner_id=v_owner and request_id=p_request;
 if found then if r.action<>p_action or r.input<>p_input then raise exception '请求编号已用于其他操作';end if;return r.result;end if;
 target:=nullif(p_input->>'id','')::uuid;
 if p_action='switch' then
 select * into s from stores where id=target and owner_id=v_owner and archived_at is null;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 insert into merchant_store_sessions values(p_session,s.id) on conflict(session_id) do update set store_id=excluded.store_id;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('archive','restore') then
 select * into s from stores where id=target and owner_id=v_owner;
 if s.id is null then raise exception '门店不存在或无权访问' using errcode='42501';end if;
 if p_action='archive' then
 if s.id=a.primary_store_id then raise exception '原门店需保留供旧版本访问，暂不能归档';end if;
 if exists(select 1 from merchant_store_sessions where store_id=s.id) then raise exception '请先将使用该门店的设备切换到其他门店';end if;
 update stores set archived_at=now() where id=s.id;
 else
 select * into u from account_subscriptions where owner_id=v_owner for update;
 if u.ends_at<=now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 if s.archived_at is not null and (select count(*) from stores where owner_id=v_owner and archived_at is null)>=lim then raise exception '已达套餐门店上限';end if;
 if exists(select 1 from stores where owner_id=v_owner and archived_at is null and id<>s.id and name=s.name) then raise exception '已有同名门店';end if;
 update stores set archived_at=null where id=s.id;
 end if;
 result:=jsonb_build_object('id',s.id);
 elsif p_action in ('create','update') then
 if p_action='create' then
 target:=null; -- A supplied ID cannot bypass duplicate-name checks on creation.
 select * into u from account_subscriptions where owner_id=v_owner for update;
 if u.ends_at is null or u.ends_at<=now() or u.starts_at>now() then raise exception '订阅已到期，请先续费';end if;
 select (snapshot->>'store_limit')::int into lim from platform_plan_versions where kind=u.plan and version=u.plan_version;
 select count(*) into n from stores where owner_id=v_owner and archived_at is null;
 if n>=coalesce(lim,1) then raise exception '已达套餐门店上限，请升级套餐';end if;
 else
 target:=(state->>'store_id')::uuid;
 if p_input->>'id' is distinct from target::text then raise exception '当前门店已变化，请重新打开页面' using errcode='40001';end if;
 end if;
 v_name:=trim(coalesce(p_input->>'name',''));v_phone:=trim(coalesce(p_input->>'phone',''));v_address:=trim(coalesce(p_input->>'address',''));
 if length(v_name) not between 1 and 30 then raise exception '门店名称须为 1–30 字';end if;
 if length(v_address) not between 1 and 300 then raise exception '请选择或输入门店地址';end if;
 if v_phone<>'' and v_phone!~'^[0-9+ -]{6,20}$' then raise exception '请输入正确的门店电话';end if;
 if exists(select 1 from stores where owner_id=v_owner and archived_at is null and stores.name=v_name and (target is null or id<>target)) then raise exception '已有同名门店';end if;
 if p_action='create' then
 insert into stores(owner_id,name,phone,address,contact_name,contact_role,business_types,bay_range) select v_owner,v_name,v_phone,v_address,contact_name,contact_role,business_types,case when bay_range='' then '1-3 个' else bay_range end from stores where id=a.primary_store_id returning * into s;
 perform initialize_store_catalog(s.id);
 else update stores set name=v_name,phone=v_phone,address=v_address where id=target returning * into s;end if;
 result:=jsonb_build_object('id',s.id);
 else raise exception '不支持的操作';end if;
 insert into merchant_store_requests values(v_owner,p_request,p_action,p_input,result);return result;
end $$;

create or replace function public.merchant_media_access(p_store uuid,p_user uuid,p_staff uuid,p_kind text,p_target uuid)
returns void language plpgsql security definer set search_path=public as $$
begin
 if p_kind='store' then
  if p_target is null or p_target<>p_store or not exists(select 1 from stores where id=p_store and archived_at is null and (owner_id=p_user or exists(
    select 1 from store_staff st where st.id=p_staff and st.store_id=p_store
      and st.user_id=p_user and st.role='manager' and st.status='active'))) then
   raise exception 'media_forbidden' using errcode='42501';
  end if;
 elsif p_kind='task' then
  if not exists(select 1 from appointments a join store_staff s on s.store_id=a.store_id and s.resource_id=a.technician_id
   where a.id=p_target and a.store_id=p_store and s.id=p_staff and s.status='active' and a.status in ('waiting','arrived','done')) then
   raise exception 'media_forbidden' using errcode='42501';
  end if;
 else raise exception 'media_kind_invalid'; end if;
end $$;
