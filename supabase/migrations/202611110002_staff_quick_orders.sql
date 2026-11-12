-- 员工端：技师快速开单 → 前台待收银队列，以及次卡核销（会员短信验证码确认）。
-- 待收银队列复用挂单（held_orders）：技师提交的是一张“待结算”挂单，前台用既有的取单结算收款，
-- 价格、折扣、次卡抵扣仍由 quote_order / settle_held_order 在数据库内计算。

-- 1) 短信验证码新增用途 redeem（次卡核销，发给会员本人）
alter table public.phone_otps drop constraint phone_otps_purpose_check;
alter table public.phone_otps add constraint phone_otps_purpose_check check
  (purpose in ('legacy','register','login','reset_password','change_phone_old','change_phone_new','delete_account','redeem'));
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.reserve_phone_otp(text,text,text,uuid,text,text,text)'::regprocedure) into def;
  patched := replace(def, '''delete_account'')', '''delete_account'',''redeem'')');
  if patched = def then raise exception 'reserve_phone_otp purpose list not found'; end if;
  execute patched;
end $$;

-- 2) 挂单记录提交人；已收银 / 已退回会通知提交人
alter table public.held_orders
  add column submitted_by uuid references public.store_staff(id) on delete set null;
create index held_orders_staff_queue_idx on public.held_orders(store_id, created_at desc)
  where submitted_by is not null and settled_at is null and cancelled_at is null;

-- 技师（或前台）提交开单：员工必须是该门店启用中的员工；明细校验与挂单完全一致。
create function public.staff_order_submit(p_store uuid, p_staff uuid, p_member uuid, p_lines jsonb, p_plate text, p_note text)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if not exists (select 1 from public.store_staff where id = p_staff and store_id = p_store and status = 'active') then
    raise exception 'staff_not_found' using errcode = 'P0002';
  end if;
  v_id := public.hold_order(p_store, p_member, p_lines, '待结算', coalesce(p_note, ''), '不提醒', coalesce(p_plate, ''), null);
  update public.held_orders set submitted_by = p_staff where id = v_id;
  return v_id;
end $$;

-- 前台退回：关闭这张待收银单并通知提交人，由技师重新提交。
create function public.staff_order_return(p_store uuid, p_hold uuid, p_reason text)
returns boolean language plpgsql security definer set search_path = public as $$
declare h public.held_orders;
begin
  update public.held_orders set cancelled_at = now(), updated_at = now()
  where id = p_hold and store_id = p_store and submitted_by is not null and settled_at is null and cancelled_at is null
  returning * into h;
  if not found then raise exception 'hold_not_found' using errcode = 'P0002'; end if;
  insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
  select h.store_id, h.submitted_by, 'system', '开单被退回',
    left(coalesce(nullif(trim(p_reason), ''), '请核对后重新提交') || ' · ' || h.vehicle_plate, 300), ''
  where h.submitted_by is not null;
  return true;
end $$;

-- 收银完成后通知提交人
create function public.held_order_settled_message() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.submitted_by is not null and old.settled_at is null and new.settled_at is not null then
    insert into public.staff_messages(store_id, staff_id, kind, title, body, link)
    values (new.store_id, new.submitted_by, 'system', '订单已收银', left(new.vehicle_plate || ' 已完成收银', 300), '');
  end if;
  return new;
end $$;
create trigger held_orders_settled_message after update of settled_at on public.held_orders
  for each row execute function public.held_order_settled_message();

-- 3) 次卡核销（不开单）：次数、记录、流水在同一个事务里；会员确认由云函数先校验短信验证码。
create function public.staff_redeem_package(p_store uuid, p_member uuid, p_member_package uuid, p_service uuid,
  p_qty int, p_plate text, p_operator text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare m public.members; mp public.member_packages; mpi public.member_package_items;
begin
  if p_qty is null or p_qty < 1 or p_qty > 10 then raise exception 'bad_qty' using errcode = 'P0001'; end if;
  select * into m from public.members where id = p_member and store_id = p_store and deleted_at is null for update;
  if not found then raise exception 'member_not_found' using errcode = 'P0002'; end if;
  select * into mp from public.member_packages
  where id = p_member_package and store_id = p_store and member_id = m.id
    and refunded_at is null and (expires_at is null or expires_at > now()) for update;
  if not found then raise exception 'package_not_enough' using errcode = 'P0001'; end if;
  select * into mpi from public.member_package_items
  where member_package_id = mp.id and service_id = p_service for update;
  if not found or mpi.total - mpi.used < p_qty then raise exception 'package_not_enough' using errcode = 'P0001'; end if;
  update public.member_package_items set used = used + p_qty
  where member_package_id = mp.id and position = mpi.position;
  update public.member_packages set used_count = used_count + p_qty where id = mp.id;
  update public.members set last_visit_at = now(), updated_at = now() where id = m.id;
  insert into public.member_package_events(store_id, member_package_id, kind, service_name, count, vehicle_plate, operator)
  values (p_store, mp.id, 'use', mpi.service_name, p_qty, coalesce(p_plate, ''), p_operator);
  insert into public.member_ledger(store_id, member_id, kind, balance_after, points_after, operator, title, note, ref_id)
  values (p_store, m.id, 'package_use', m.balance, m.points, p_operator, mpi.service_name,
    '次卡核销 · 剩 ' || (mpi.total - mpi.used - p_qty) || ' 次', mp.id);
  return jsonb_build_object('package', mp.name, 'service', mpi.service_name, 'remaining', mpi.total - mpi.used - p_qty);
end $$;

revoke all on function public.staff_order_submit(uuid, uuid, uuid, jsonb, text, text),
  public.staff_order_return(uuid, uuid, text),
  public.held_order_settled_message(),
  public.staff_redeem_package(uuid, uuid, uuid, uuid, int, text, text) from public, anon, authenticated;
grant execute on function public.staff_order_submit(uuid, uuid, uuid, jsonb, text, text),
  public.staff_order_return(uuid, uuid, text),
  public.staff_redeem_package(uuid, uuid, uuid, uuid, int, text, text) to service_role;
