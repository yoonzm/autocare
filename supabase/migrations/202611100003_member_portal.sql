-- 会员端小程序：会员身份会话、会员码，以及会员自助预约 / 改约 / 取消 / 订单查询。
-- 会员 = 门店下的 members 记录，以手机号识别；同一手机号可以在多家门店各有一条会员档案。
-- 手机号只来自微信手机号授权（云函数校验），客户端不能指定。所有写入都经下面的 SECURITY DEFINER 函数，
-- 云函数以 service_role 调用；表对 anon / authenticated 无任何权限。

-- ───────── 微信身份与会话 ─────────
create table public.member_wechat (
  openid text primary key check (length(openid) between 5 and 100),
  phone text not null check (phone ~ '^1[3-9][0-9]{9}$'),
  created_at timestamptz not null default now(),
  last_login_at timestamptz not null default now()
);
create index member_wechat_phone_idx on public.member_wechat(phone);

create table public.member_sessions (
  id uuid primary key default gen_random_uuid(),
  phone text not null check (phone ~ '^1[3-9][0-9]{9}$'),
  openid text not null references public.member_wechat(openid) on delete cascade,
  -- 令牌只存 SHA-256；明文只在登录响应里出现一次
  token_hash text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  last_used_at timestamptz not null default now(),
  revoked_at timestamptz
);
create index member_sessions_phone_idx on public.member_sessions(phone) where revoked_at is null;

-- 会员码：短时有效的一次性随机码，只存哈希。店员端扫码核销属于员工端 / 收银，见 docs/member-mini-integration.md。
create table public.member_codes (
  code_hash text primary key check (code_hash ~ '^[0-9a-f]{64}$'),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null
);
create index member_codes_member_idx on public.member_codes(member_id, created_at desc);

alter table public.member_wechat enable row level security;
alter table public.member_sessions enable row level security;
alter table public.member_codes enable row level security;
revoke all on public.member_wechat, public.member_sessions, public.member_codes from public, anon, authenticated;
grant select, insert, update, delete on public.member_wechat, public.member_sessions, public.member_codes to service_role;

-- 默认车辆：预约时默认选择
alter table public.member_vehicles add column is_default boolean not null default false;
create unique index member_vehicles_default_uidx on public.member_vehicles(member_id) where is_default;

-- ───────── 会话 ─────────
-- 登录：同一微信换绑手机号以微信授权结果为准；每个手机号最多保留 5 个有效会话（挤掉最旧的）。
create function public.member_portal_login(p_phone text, p_openid text, p_hash text, p_days integer default 30)
returns jsonb language plpgsql security definer set search_path = public as $$
begin
  if p_phone !~ '^1[3-9][0-9]{9}$' or p_hash !~ '^[0-9a-f]{64}$' or p_openid is null or length(p_openid) not between 5 and 100 then
    raise exception 'invalid_login';
  end if;
  insert into public.member_wechat(openid, phone) values (p_openid, p_phone)
    on conflict (openid) do update set phone = excluded.phone, last_login_at = now();
  insert into public.member_sessions(phone, openid, token_hash, expires_at)
    values (p_phone, p_openid, p_hash, now() + make_interval(days => p_days));
  update public.member_sessions set revoked_at = now()
  where phone = p_phone and revoked_at is null and id not in (
    select id from public.member_sessions where phone = p_phone and revoked_at is null
    order by created_at desc limit 5);
  return jsonb_build_object('phone', p_phone, 'expires_at', now() + make_interval(days => p_days));
end $$;

-- 校验会话并滑动续期（一天内不重复写）。无效返回 null。
create function public.member_portal_session(p_hash text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare s public.member_sessions;
begin
  select * into s from public.member_sessions
  where token_hash = p_hash and revoked_at is null and expires_at > now();
  if not found then return null; end if;
  if s.last_used_at < now() - interval '1 day' then
    update public.member_sessions set last_used_at = now(), expires_at = now() + interval '30 days' where id = s.id;
  end if;
  return jsonb_build_object('phone', s.phone, 'openid', s.openid);
end $$;

create function public.member_portal_logout(p_hash text) returns boolean
language sql security definer set search_path = public as $$
  with r as (update public.member_sessions set revoked_at = now()
    where token_hash = p_hash and revoked_at is null returning 1)
  select exists(select 1 from r)
$$;

-- ───────── 门店与会员 ─────────
create function public.member_portal_resolve(p_phone text, p_store uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select m.id from public.members m
  where m.store_id = p_store and m.phone = p_phone and m.deleted_at is null
$$;

-- 这个手机号作为会员的所有门店
create function public.member_portal_stores(p_phone text) returns jsonb
language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'store_id', s.id, 'name', s.name, 'address', s.address, 'member_id', m.id,
    'level', c.name) order by m.created_at), '[]'::jsonb)
  from public.members m
  join public.stores s on s.id = m.store_id
  left join public.card_types c on c.id = m.card_type_id
  where m.phone = p_phone and m.deleted_at is null
$$;

create function public.member_portal_appt_json(a public.appointments) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'id', a.id, 'code', upper(left(replace(a.id::text, '-', ''), 6)),
    'status', a.status, 'starts_at', a.starts_at, 'duration_minutes', a.duration_minutes,
    'estimate', a.estimate, 'note', a.note, 'cancel_reason', a.cancel_reason,
    'plate', a.vehicle_plate, 'arrived_at', a.arrived_at, 'completed_at', a.completed_at,
    'items', (select coalesce(jsonb_agg(jsonb_build_object('name', i->>'name', 'price', i->'price', 'service_id', i->>'service_id')), '[]'::jsonb)
              from jsonb_array_elements(a.items) i),
    'bay_name', (select name from public.appointment_resources where id = a.bay_id),
    'technician_name', (select name from public.appointment_resources where id = a.technician_id),
    'vehicle', (select jsonb_build_object('brand_model', v.brand_model, 'color', v.color, 'energy', v.energy)
                from public.member_vehicles v where v.store_id = a.store_id and v.member_id = a.member_id and v.plate = a.vehicle_plate),
    'store_name', (select name from public.stores where id = a.store_id))
$$;

create function public.member_portal_appointment(p_store uuid, p_member uuid, p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare a public.appointments;
begin
  select * into a from public.appointments where id = p_id and store_id = p_store and member_id = p_member;
  if not found then raise exception 'appointment_not_found' using errcode = 'P0002'; end if;
  return public.member_portal_appt_json(a);
end $$;

-- 首页 / 我的共用的概览：门店、会员资料、数量角标、施工中的预约
create function public.member_portal_overview(p_store uuid, p_member uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare m public.members; c public.card_types; s public.stores; st public.appointment_settings;
  v_local time := (now() at time zone 'Asia/Shanghai')::time; v_open boolean; v_work public.appointments;
begin
  select * into m from public.members where id = p_member and store_id = p_store and deleted_at is null;
  if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  select * into c from public.card_types where id = m.card_type_id;
  select * into s from public.stores where id = p_store;
  select * into st from public.appointment_settings where store_id = p_store;
  v_open := v_local >= coalesce(st.opens_at, '09:00') and v_local < coalesce(st.closes_at, '20:00')
    and extract(isodow from (now() at time zone 'Asia/Shanghai'))::int <> all (coalesce(st.closed_days, '{}'::integer[]));
  select * into v_work from public.appointments
    where store_id = p_store and member_id = p_member and status = 'arrived' order by arrived_at desc nulls last limit 1;
  return jsonb_build_object(
    'store', jsonb_build_object('id', s.id, 'name', s.name, 'address', s.address, 'phone', s.phone,
      'opens_at', to_char(coalesce(st.opens_at, '09:00'), 'HH24:MI'), 'closes_at', to_char(coalesce(st.closes_at, '20:00'), 'HH24:MI'),
      'open_now', v_open),
    'member', jsonb_build_object('id', m.id, 'name', m.name, 'phone', m.phone, 'honorific', m.honorific,
      'balance', m.balance, 'points', m.points, 'total_spent', m.total_spent, 'visit_count', m.visit_count,
      'joined_at', m.created_at, 'birthday', m.birthday,
      'level', jsonb_build_object('id', c.id, 'name', c.name, 'discount', c.discount, 'color', c.color)),
    'counts', jsonb_build_object(
      'waiting', (select count(*) from public.appointments where store_id = p_store and member_id = p_member and status = 'waiting'),
      'in_progress', (select count(*) from public.appointments where store_id = p_store and member_id = p_member and status = 'arrived'),
      'packages', (select count(*) from public.member_packages p where p.store_id = p_store and p.member_id = p_member
        and p.refunded_at is null and (p.expires_at is null or p.expires_at > now()) and p.used_count < p.total_count),
      'vehicles', (select count(*) from public.member_vehicles where store_id = p_store and member_id = p_member)),
    'in_progress', case when v_work.id is null then null else public.member_portal_appt_json(v_work) end);
end $$;

-- ───────── 预约 ─────────
-- 自助预约：时段容量、营业时间、提前量等规则全部沿用 save_appointment / appointment_slot_available。
-- 改约（p_replace）在同一事务里先取消原预约再创建新预约，失败整体回滚。幂等：同一请求编号返回第一次的结果。
create function public.member_portal_book(p_store uuid, p_member uuid, p_vehicle uuid, p_input jsonb, p_request text,
  p_replace uuid default null) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v public.member_vehicles; a public.appointments; r jsonb; v_id uuid;
begin
  select * into a from public.appointments where store_id = p_store and request_id = p_request;
  if found then
    if a.member_id is distinct from p_member then raise exception 'request_reused'; end if;
    return public.member_portal_appt_json(a);
  end if;
  select * into v from public.member_vehicles where id = p_vehicle and member_id = p_member and store_id = p_store;
  if not found then raise exception 'vehicle_required' using errcode = 'P0002'; end if;
  if p_replace is not null then
    select * into a from public.appointments where id = p_replace and store_id = p_store and member_id = p_member for update;
    if not found then raise exception 'appointment_not_found' using errcode = 'P0002'; end if;
    if a.status <> 'waiting' then raise exception 'appointment_closed'; end if;
    if a.starts_at < now() + interval '2 hours' then raise exception 'cancel_too_late'; end if;
    perform public.change_appointment(p_store, p_replace, 'cancel', '会员改约');
  elsif (select count(*) from public.appointments
         where store_id = p_store and member_id = p_member and status = 'waiting') >= 5 then
    raise exception 'too_many_appointments';
  end if;
  r := public.save_appointment(p_store, (p_input - 'id' - 'bay_id' - 'technician_id') || jsonb_build_object('member_id', p_member), p_request);
  v_id := (r->>'id')::uuid;
  update public.appointments set vehicle_plate = v.plate, updated_at = now() where id = v_id and store_id = p_store;
  return public.member_portal_appt_json((select x from public.appointments x where x.id = v_id));
end $$;

create function public.member_portal_cancel(p_store uuid, p_member uuid, p_id uuid, p_reason text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare a public.appointments;
begin
  if p_reason not in ('时间有变', '已在别处完成', '其他原因') then raise exception 'cancel_reason_required'; end if;
  select * into a from public.appointments where id = p_id and store_id = p_store and member_id = p_member;
  if not found then raise exception 'appointment_not_found' using errcode = 'P0002'; end if;
  if a.status = 'cancelled' then return public.member_portal_appt_json(a); end if;
  if a.status <> 'waiting' then raise exception 'appointment_closed'; end if;
  if a.starts_at < now() + interval '2 hours' then raise exception 'cancel_too_late'; end if;
  perform public.change_appointment(p_store, p_id, 'cancel', p_reason);
  return public.member_portal_appt_json((select x from public.appointments x where x.id = p_id));
end $$;

-- tab: pending 待到店 / done 已完成 / cancelled 已取消
create function public.member_portal_appointments(p_store uuid, p_member uuid, p_tab text, p_limit integer default 50) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if p_tab not in ('pending', 'done', 'cancelled') then raise exception 'invalid_tab'; end if;
  return jsonb_build_object(
    'counts', jsonb_build_object(
      'pending', (select count(*) from public.appointments where store_id = p_store and member_id = p_member and status = 'waiting'),
      'done', (select count(*) from public.appointments where store_id = p_store and member_id = p_member and status = 'done'),
      'cancelled', (select count(*) from public.appointments where store_id = p_store and member_id = p_member and status = 'cancelled')),
    'items', (select coalesce(jsonb_agg(x.j order by
        case when p_tab = 'pending' then x.starts_at end asc, case when p_tab <> 'pending' then x.starts_at end desc), '[]'::jsonb)
      from (select public.member_portal_appt_json(a) as j, a.starts_at from public.appointments a
            where a.store_id = p_store and a.member_id = p_member
              and a.status = case p_tab when 'pending' then 'waiting' when 'done' then 'done' else 'cancelled' end
            order by case when p_tab = 'pending' then a.starts_at end asc, case when p_tab <> 'pending' then a.starts_at end desc
            limit least(greatest(p_limit, 1), 100)) x));
end $$;

-- ───────── 车辆 ─────────
create function public.member_portal_vehicles(p_store uuid, p_member uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', v.id, 'plate', v.plate, 'energy', v.energy, 'brand_model', v.brand_model, 'color', v.color,
    'is_default', v.is_default,
    'visits', (select count(*) from public.orders o where o.store_id = v.store_id and o.member_id = v.member_id
               and o.vehicle_plate = v.plate and o.status = 'completed'))
    order by v.is_default desc, v.created_at), '[]'::jsonb)
  from public.member_vehicles v where v.store_id = p_store and v.member_id = p_member
$$;

-- 新增车辆：第一辆自动成为默认车辆；p_default 为真时设为默认并取消其它。车牌在本店唯一。
create function public.member_portal_save_vehicle(p_store uuid, p_member uuid, p_values jsonb, p_default boolean) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_first boolean;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_member::text, 0));
  if (select count(*) from public.member_vehicles where store_id = p_store and member_id = p_member) >= 10 then
    raise exception 'vehicle_limit';
  end if;
  v_first := not exists(select 1 from public.member_vehicles where store_id = p_store and member_id = p_member);
  if p_default and not v_first then
    update public.member_vehicles set is_default = false where store_id = p_store and member_id = p_member and is_default;
  end if;
  insert into public.member_vehicles(store_id, member_id, plate, energy, brand_model, color, is_default)
    values (p_store, p_member, p_values->>'plate', coalesce(p_values->>'energy', 'fuel'),
      coalesce(p_values->>'brand_model', ''), coalesce(p_values->>'color', ''), v_first or coalesce(p_default, false))
    returning id into v_id;
  return jsonb_build_object('id', v_id);
end $$;

-- ───────── 订单（消费记录） ─────────
-- kind: all / service 服务 / recharge 充值。按时间倒序，p_before 为上一页最后一条的时间。
create function public.member_portal_orders(p_store uuid, p_member uuid, p_kind text, p_before timestamptz default null,
  p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare v_lim integer := least(greatest(p_limit, 1), 50); v_rows jsonb; v_month timestamptz :=
  date_trunc('month', now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai'; v_summary jsonb;
begin
  if p_kind not in ('all', 'service', 'recharge') then raise exception 'invalid_kind'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.at desc), '[]'::jsonb) into v_rows from (
    select * from (
      select 'order'::text as kind, o.id, o.created_at as at,
        coalesce((select string_agg(i.name, ' + ' order by i.position) from public.order_items i where i.order_id = o.id), '消费') as title,
        o.payable as amount, o.vehicle_plate as plate, o.status,
        exists(select 1 from public.order_items i where i.order_id = o.id and i.member_package_id is not null) as by_package,
        public.order_no(o.created_at, o.seq) as order_no
      from public.orders o where o.store_id = p_store and o.member_id = p_member and p_kind in ('all', 'service')
      union all
      select 'recharge', l.id, l.created_at, '储值充值', l.balance_delta, ''::text, 'completed', false,
        public.order_no(l.created_at, l.seq)
      from public.member_ledger l where l.store_id = p_store and l.member_id = p_member and l.kind = 'recharge'
        and p_kind in ('all', 'recharge')
      union all
      select 'package', p.id, p.purchased_at, '购买次卡 · ' || p.name, p.price_paid, ''::text,
        case when p.refunded_at is null then 'completed' else 'refunded' end, false, public.order_no(p.purchased_at, p.seq)
      from public.member_packages p where p.store_id = p_store and p.member_id = p_member and p_kind = 'all'
    ) u where p_before is null or u.at < p_before order by u.at desc limit v_lim + 1) x;
  if p_before is null then
    select jsonb_build_object(
      'orders', count(*), 'paid', coalesce(sum(payable), 0),
      'saved', coalesce(sum(card_off + discount_off), 0), 'points', coalesce(sum(points_gained), 0))
    into v_summary from public.orders where store_id = p_store and member_id = p_member and status = 'completed' and created_at >= v_month;
  end if;
  return jsonb_build_object('items', v_rows, 'summary', v_summary);
end $$;

create function public.member_portal_order(p_store uuid, p_member uuid, p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare o public.orders; v_tech text;
begin
  select * into o from public.orders where id = p_id and store_id = p_store and member_id = p_member;
  if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
  select r.name into v_tech from public.appointments a join public.appointment_resources r on r.id = a.technician_id
    where a.id = o.appointment_id;
  return jsonb_build_object(
    'id', o.id, 'order_no', public.order_no(o.created_at, o.seq), 'at', o.created_at, 'status', o.status,
    'subtotal', o.subtotal, 'card_off', o.card_off, 'discount_off', o.discount_off, 'payable', o.payable,
    'balance_paid', o.balance_paid, 'pay', public.order_pay_label(o.pay_method), 'points', o.points_gained,
    'plate', o.vehicle_plate, 'technician', v_tech,
    'store_name', (select name from public.stores where id = p_store),
    'items', (select coalesce(jsonb_agg(jsonb_build_object('name', i.name, 'qty', i.qty, 'total', i.line_total,
        'by_package', i.member_package_id is not null) order by i.position), '[]'::jsonb)
      from public.order_items i where i.order_id = o.id));
end $$;

-- 充值记录详情（来自流水）
create function public.member_portal_recharge(p_store uuid, p_member uuid, p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare l public.member_ledger;
begin
  select * into l from public.member_ledger where id = p_id and store_id = p_store and member_id = p_member and kind = 'recharge';
  if not found then raise exception 'order_not_found' using errcode = 'P0002'; end if;
  return jsonb_build_object('id', l.id, 'amount', l.amount, 'gift', l.gift, 'pay', l.pay_method,
    'balance_after', l.balance_after, 'at', l.created_at, 'order_no', public.order_no(l.created_at, l.seq));
end $$;

-- ───────── 次卡 ─────────
create function public.member_portal_packages(p_store uuid, p_member uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'mine', (select coalesce(jsonb_agg(jsonb_build_object(
        'id', p.id, 'name', p.name, 'total', p.total_count, 'used', p.used_count, 'expires_at', p.expires_at,
        'items', (select coalesce(jsonb_agg(jsonb_build_object('name', i.service_name, 'total', i.total, 'used', i.used) order by i.position), '[]'::jsonb)
                  from public.member_package_items i where i.member_package_id = p.id))
        order by p.expires_at nulls last, p.purchased_at), '[]'::jsonb)
      from public.member_packages p where p.store_id = p_store and p.member_id = p_member and p.refunded_at is null
        and (p.expires_at is null or p.expires_at > now()) and p.used_count < p.total_count),
    'offers', (select coalesce(jsonb_agg(jsonb_build_object(
        'id', k.id, 'name', k.name, 'price', k.price, 'validity_months', k.validity_months,
        'description', k.description, 'purchase_limit', k.purchase_limit,
        'items', (select coalesce(jsonb_agg(jsonb_build_object('name', s.name, 'count', i.count, 'price', s.price) order by i.position), '[]'::jsonb)
                  from public.card_package_items i join public.service_items s on s.id = i.service_id where i.package_id = k.id))
        order by k.created_at), '[]'::jsonb)
      from public.card_packages k where k.store_id = p_store and k.active and k.deleted_at is null and k.show_in_mini))
$$;

-- ───────── 会员码 ─────────
create function public.member_portal_issue_code(p_store uuid, p_member uuid, p_hash text, p_seconds integer default 60) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_exp timestamptz := now() + make_interval(secs => p_seconds);
begin
  if p_hash !~ '^[0-9a-f]{64}$' then raise exception 'invalid_code'; end if;
  delete from public.member_codes where member_id = p_member and expires_at < now();
  -- 同一会员最多保留 5 个有效码，防止刷新风暴
  delete from public.member_codes where member_id = p_member and code_hash in (
    select code_hash from public.member_codes where member_id = p_member order by created_at desc offset 4);
  insert into public.member_codes(code_hash, store_id, member_id, expires_at) values (p_hash, p_store, p_member, v_exp);
  return jsonb_build_object('expires_at', v_exp);
end $$;

-- ───────── 权限：只有云函数（service_role）可执行 ─────────
do $$ declare f text; begin
  foreach f in array array[
    'member_portal_login(text,text,text,integer)', 'member_portal_session(text)', 'member_portal_logout(text)',
    'member_portal_resolve(text,uuid)', 'member_portal_stores(text)', 'member_portal_appt_json(public.appointments)',
    'member_portal_appointment(uuid,uuid,uuid)', 'member_portal_overview(uuid,uuid)', 'member_portal_book(uuid,uuid,uuid,jsonb,text,uuid)',
    'member_portal_cancel(uuid,uuid,uuid,text)', 'member_portal_appointments(uuid,uuid,text,integer)',
    'member_portal_vehicles(uuid,uuid)', 'member_portal_save_vehicle(uuid,uuid,jsonb,boolean)',
    'member_portal_orders(uuid,uuid,text,timestamptz,integer)', 'member_portal_order(uuid,uuid,uuid)',
    'member_portal_recharge(uuid,uuid,uuid)', 'member_portal_packages(uuid,uuid)',
    'member_portal_issue_code(uuid,uuid,text,integer)'] loop
    execute format('revoke all on function public.%s from public, anon, authenticated', f);
    execute format('grant execute on function public.%s to service_role', f);
  end loop;
end $$;
