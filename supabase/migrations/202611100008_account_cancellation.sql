-- 后台「用户账号」：查看所有账号，并支持强制注销。
-- 注销只处理账号：停用该账号并让所有设备退出，不删除、不改动任何门店、订单、会员数据。
-- TODO account_cancel_expired: 用户自助注销的 15 天冷静期到期后自动注销，仍缺定时任务（沿用同一张表，source = 'self'）。
create table public.account_cancellations (
  user_id uuid primary key,
  phone text not null,
  source text not null check (source in ('admin', 'self')),
  reason text not null default '' check (reason in ('', 'user_request', 'violation', 'other')),
  note text not null default '' check (length(note) <= 200),
  actor_id uuid references public.admin_accounts(id),
  cancelled_at timestamptz not null default now()
);
create index account_cancellations_phone_idx on public.account_cancellations (phone);
alter table public.account_cancellations enable row level security;
revoke all on public.account_cancellations from public, anon, authenticated;
grant select, insert on public.account_cancellations to service_role;

-- 账号 = 一个登录用户：老板（有门店账号）或员工（有门店身份）。后台运营账号不在其中。
-- 用普通函数而不是视图：函数体在调用时才解析，避免精简版 auth 表结构的数据库测试在建视图时失败。
create function public.admin_user_accounts() returns table(
  user_id uuid, created_at timestamptz, last_sign_in_at timestamptz, phone text, name text, role text,
  identities jsonb, store_names text, frozen boolean, delete_requested_at timestamptz,
  cancelled_at timestamptz, cancel_source text, cancel_reason text, cancel_note text, status text)
language plpgsql stable security definer set search_path=public as $fn$
#variable_conflict use_column
begin
  return query
with owners as (
  select a.owner_id as user_id, a.phone, a.frozen,
    (select s.contact_name from public.stores s where s.id = a.primary_store_id) as name,
    (select min(s.delete_requested_at) from public.stores s where s.owner_id = a.owner_id and s.archived_at is null) as delete_requested_at
  from public.merchant_accounts a
), staff as (
  select t.user_id, min(t.phone) as phone, (array_agg(t.name order by t.created_at))[1] as name
  from public.store_staff t where t.user_id is not null group by t.user_id
), ids as (
  select user_id from owners union select user_id from staff
), identities as (
  select o.user_id, jsonb_build_object('kind', 'owner', 'role', 'owner', 'store_id', s.id, 'store_name', s.name,
    'joined_on', (s.created_at at time zone 'Asia/Shanghai')::date, 'status', 'active') as item, s.created_at as at
  from owners o join public.stores s on s.owner_id = o.user_id and s.archived_at is null
  union all
  select t.user_id, jsonb_build_object('kind', 'staff', 'role', t.role, 'store_id', t.store_id, 'store_name', st.name,
    'joined_on', t.joined_on, 'status', t.status), t.created_at
  from public.store_staff t join public.stores st on st.id = t.store_id where t.user_id is not null
), grouped as (
  select user_id, jsonb_agg(item order by at) as identities,
    string_agg(item->>'store_name', ' ') as store_names,
    case when bool_or(item->>'role' = 'owner') then 'owner'
      when bool_or(item->>'role' = 'manager') then 'manager'
      when bool_or(item->>'role' = 'cashier') then 'cashier' else 'technician' end as role
  from identities group by user_id
)
select u.id as user_id, u.created_at, u.last_sign_in_at,
  right(regexp_replace(coalesce(o.phone, s.phone, u.phone, ''), '\D', '', 'g'), 11) as phone,
  coalesce(nullif(o.name, ''), s.name, '') as name,
  coalesce(g.role, 'technician') as role, coalesce(g.identities, '[]'::jsonb) as identities, coalesce(g.store_names, '') as store_names,
  coalesce(o.frozen, false) as frozen, o.delete_requested_at,
  c.cancelled_at, c.source as cancel_source, c.reason as cancel_reason, c.note as cancel_note,
  case when c.user_id is not null then 'cancelled'
    when o.delete_requested_at is not null then 'cooling'
    when coalesce(o.frozen, false) then 'frozen' else 'active' end as status
from ids i
join auth.users u on u.id = i.user_id
left join owners o on o.user_id = i.user_id
left join staff s on s.user_id = i.user_id
left join grouped g on g.user_id = i.user_id
left join public.account_cancellations c on c.user_id = i.user_id;
end $fn$;
revoke all on function public.admin_user_accounts() from public, anon, authenticated;
grant execute on function public.admin_user_accounts() to service_role;

create function public.admin_require_super(p_actor uuid, p_session uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a jsonb;
begin
  a := public.admin_identity(p_actor, p_session);
  if (a->>'must_change')::boolean then raise exception '请先修改初始或临时密码' using errcode='42501'; end if;
  if a->>'role' <> 'superAdmin' then raise exception '需要超级管理员权限' using errcode='42501'; end if;
  return a;
end $$;

create function public.admin_user_list(p_actor uuid, p_session uuid, p_status text default 'all', p_q text default '',
  p_before_at timestamptz default null, p_before_id uuid default null, p_limit integer default 30)
returns jsonb language plpgsql security definer set search_path=public as $$
declare q text := trim(coalesce(p_q, '')); digits text := regexp_replace(coalesce(p_q, ''), '\D', '', 'g');
  lim integer := least(greatest(coalesce(p_limit, 30), 1), 50); rows jsonb; n integer; counts jsonb;
begin
  perform public.admin_require_super(p_actor, p_session);
  if p_status not in ('all', 'cooling', 'cancelled', 'frozen') then raise exception '账号状态无效'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.user_id desc), '[]'::jsonb), count(*) into rows, n from (
    select user_id, created_at, last_sign_in_at, phone, name, role, identities, frozen, delete_requested_at, cancelled_at, cancel_source, status
    from public.admin_user_accounts()
    where (p_status = 'all' or status = p_status)
      and (q = '' or (digits <> '' and phone like '%' || digits || '%') or name ilike '%' || q || '%' or store_names ilike '%' || q || '%')
      and (p_before_at is null or (created_at, user_id) < (p_before_at, coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid)))
    order by created_at desc, user_id desc limit lim + 1) x;
  select jsonb_build_object('total', count(*), 'cooling', count(*) filter (where status = 'cooling'),
    'cancelled', count(*) filter (where status = 'cancelled'), 'frozen', count(*) filter (where status = 'frozen'))
    into counts from public.admin_user_accounts();
  return jsonb_build_object('items', case when n > lim then rows - lim else rows end, 'more', n > lim, 'counts', counts, 'now', now());
end $$;

create function public.admin_user_get(p_actor uuid, p_session uuid, p_id uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare r record; events jsonb := '[]'::jsonb; holds integer := 0; appts integer := 0; devices integer;
begin
  perform public.admin_require_super(p_actor, p_session);
  select * into r from public.admin_user_accounts() x where x.user_id = p_id;
  if not found then raise exception '账号不存在' using errcode='P0002'; end if;
  select count(*) into devices from auth.sessions where user_id = p_id and (not_after is null or not_after > now());
  -- 进行中的事项：老板看自己门店的挂单与待到店预约；员工看分配给自己的待到店预约。
  if r.role = 'owner' then
    select count(*) into holds from public.held_orders h join public.stores s on s.id = h.store_id
      where s.owner_id = p_id and h.settled_at is null and h.cancelled_at is null;
    select count(*) into appts from public.appointments a join public.stores s on s.id = a.store_id
      where s.owner_id = p_id and a.status in ('waiting', 'arrived');
  else
    select count(*) into appts from public.appointments a join public.store_staff t on t.resource_id = a.technician_id and t.store_id = a.store_id
      where t.user_id = p_id and a.status in ('waiting', 'arrived');
  end if;
  select coalesce(jsonb_agg(e order by (e->>'at') desc), '[]'::jsonb) into events from (
    select jsonb_build_object('text', '后台强制注销' || case l.detail->>'reason' when 'user_request' then '（用户要求）'
        when 'violation' then '（违规处理）' else '（其他）' end,
      'at', l.created_at, 'by', coalesce(ad.name, '运营')) as e
    from public.admin_audit_logs l left join public.admin_accounts ad on ad.id = l.actor_id
    where l.action = 'user_cancel' and l.target = p_id::text
    union all
    select jsonb_build_object('text', '用户自助申请注销', 'at', r.delete_requested_at, 'by', '用户本人') where r.delete_requested_at is not null) x;
  return jsonb_build_object('item', to_jsonb(r) - 'store_names', 'devices', devices, 'events', events,
    'open_holds', holds, 'open_appointments', appts, 'now', now());
end $$;

create function public.admin_user_cancel(p_actor uuid, p_session uuid, p_user uuid, p_reason text, p_note text, p_request uuid)
returns jsonb language plpgsql security definer set search_path=public as $$
declare a jsonb; r record; prev public.admin_requests; result jsonb; input jsonb; note text := trim(coalesce(p_note, ''));
begin
  a := public.admin_require_super(p_actor, p_session);
  if p_request is null then raise exception '缺少请求编号'; end if;
  perform pg_advisory_xact_lock(hashtextextended('user-cancel:' || p_user::text, 0));
  input := jsonb_build_object('id', p_user, 'reason', p_reason, 'note', note);
  select * into prev from public.admin_requests where actor_id = p_actor and request_id = p_request;
  if found then
    if prev.action <> 'user_cancel' or prev.input <> input then raise exception '请求编号已用于其他操作' using errcode='23505'; end if;
    return prev.result || '{"replayed":true}'::jsonb;
  end if;
  if p_reason not in ('user_request', 'violation', 'other') then raise exception '请选择注销原因'; end if;
  if length(note) > 200 then raise exception '备注不能超过 200 字'; end if;
  select * into r from public.admin_user_accounts() x where x.user_id = p_user;
  if not found then raise exception '账号不存在' using errcode='P0002'; end if;
  if r.status = 'cancelled' then raise exception '账号已注销'; end if;
  -- 只停用账号：记录注销、让所有设备退出；门店、订单、会员等数据一律不动。
  insert into public.account_cancellations(user_id, phone, source, reason, note, actor_id)
    values (p_user, r.phone, 'admin', p_reason, note, p_actor);
  delete from auth.sessions where user_id = p_user;
  insert into public.admin_audit_logs(actor_id, action, target, detail)
    values (p_actor, 'user_cancel', p_user::text, jsonb_build_object('phone', r.phone, 'role', r.role, 'reason', p_reason, 'note', note, 'request_id', p_request));
  result := jsonb_build_object('ok', true, 'id', p_user);
  insert into public.admin_requests(actor_id, request_id, action, input, result) values (p_actor, p_request, 'user_cancel', input, result);
  return result;
end $$;

revoke all on function public.admin_require_super(uuid,uuid), public.admin_user_list(uuid,uuid,text,text,timestamptz,uuid,integer),
  public.admin_user_get(uuid,uuid,uuid), public.admin_user_cancel(uuid,uuid,uuid,text,text,uuid) from public, anon, authenticated;
grant execute on function public.admin_require_super(uuid,uuid), public.admin_user_list(uuid,uuid,text,text,timestamptz,uuid,integer),
  public.admin_user_get(uuid,uuid,uuid), public.admin_user_cancel(uuid,uuid,uuid,text,text,uuid) to service_role;
