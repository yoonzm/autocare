-- 订单中心的数据范围：只有「查看全部订单」权限的身份能读全店；只有「查看本人订单」的员工只能读自己的。
-- 本人订单 = 关联到派给该技师的预约的消费订单（及其退款行）。充值、次卡售卖 / 退款、没有关联预约的直接订单
-- 不属于任何技师，本人范围看不到；订单详情同理，越范围一律按「订单不存在」处理，不暴露存在性。
-- 范围由云函数按已认证会话的员工身份传入，客户端不能指定。
create or replace function public.order_in_scope(p_order uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select case
    when nullif(current_setting('autocare.order_scope', true), '') is null then true
    else exists (
      select 1 from public.orders o join public.appointments a on a.id = o.appointment_id
      where o.id = p_order and a.technician_id = nullif(current_setting('autocare.order_scope', true), '')::uuid
    )
  end
$$;
revoke all on function public.order_in_scope(uuid) from public, anon, authenticated;
grant execute on function public.order_in_scope(uuid) to service_role;

do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.order_rows(uuid,timestamptz,timestamptz)'::regprocedure) into def;
  patched := replace(def, 'where o.store_id = p_store and o.created_at >= p_from and o.created_at < p_to',
    'where o.store_id = p_store and o.created_at >= p_from and o.created_at < p_to and public.order_in_scope(o.id)');
  if patched = def then raise exception 'consume anchor not found'; end if;
  def := patched;
  patched := replace(def, 'where o.store_id = p_store and o.status = ''refunded'' and o.refunded_at >= p_from and o.refunded_at < p_to',
    'where o.store_id = p_store and o.status = ''refunded'' and o.refunded_at >= p_from and o.refunded_at < p_to and public.order_in_scope(o.id)');
  if patched = def then raise exception 'refund anchor not found'; end if;
  def := patched;
  patched := replace(def, 'where l.store_id = p_store and l.kind = ''recharge'' and l.created_at >= p_from and l.created_at < p_to',
    'where l.store_id = p_store and l.kind = ''recharge'' and l.created_at >= p_from and l.created_at < p_to and nullif(current_setting(''autocare.order_scope'', true), '''') is null');
  if patched = def then raise exception 'recharge anchor not found'; end if;
  def := patched;
  patched := replace(def, 'where p.store_id = p_store and p.purchased_at >= p_from and p.purchased_at < p_to',
    'where p.store_id = p_store and p.purchased_at >= p_from and p.purchased_at < p_to and nullif(current_setting(''autocare.order_scope'', true), '''') is null');
  if patched = def then raise exception 'package anchor not found'; end if;
  def := patched;
  patched := replace(def, 'where p.store_id = p_store and p.refunded_at >= p_from and p.refunded_at < p_to',
    'where p.store_id = p_store and p.refunded_at >= p_from and p.refunded_at < p_to and nullif(current_setting(''autocare.order_scope'', true), '''') is null');
  if patched = def then raise exception 'package refund anchor not found'; end if;
  execute patched;
end $$;

-- 带范围的入口：事务内设置范围，调用原函数，调用结束立即清掉。
create function public.order_feed_scoped(
  p_store uuid, p_from timestamptz, p_to timestamptz, p_kind text, p_method text, p_status text,
  p_operator text, p_q text, p_before timestamptz, p_limit int, p_resource uuid
) returns jsonb language plpgsql security definer set search_path = public as $$
declare result jsonb;
begin
  perform set_config('autocare.order_scope', p_resource::text, true);
  result := public.order_feed(p_store, p_from, p_to, p_kind, p_method, p_status, p_operator, p_q, p_before, p_limit);
  perform set_config('autocare.order_scope', '', true);
  return result;
end $$;

create function public.order_detail_scoped(p_store uuid, p_kind text, p_id uuid, p_resource uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare result jsonb;
begin
  -- 本人范围只有消费订单：充值、次卡不属于任何技师。
  if p_kind <> 'consume' then raise exception 'order_not_found' using errcode = 'P0002'; end if;
  perform set_config('autocare.order_scope', p_resource::text, true);
  if not public.order_in_scope(p_id) then
    perform set_config('autocare.order_scope', '', true);
    raise exception 'order_not_found' using errcode = 'P0002';
  end if;
  result := public.order_detail(p_store, p_kind, p_id);
  perform set_config('autocare.order_scope', '', true);
  return result;
end $$;
revoke all on function public.order_feed_scoped(uuid, timestamptz, timestamptz, text, text, text, text, text, timestamptz, int, uuid) from public, anon, authenticated;
revoke all on function public.order_detail_scoped(uuid, text, uuid, uuid) from public, anon, authenticated;
grant execute on function public.order_feed_scoped(uuid, timestamptz, timestamptz, text, text, text, text, text, timestamptz, int, uuid) to service_role;
grant execute on function public.order_detail_scoped(uuid, text, uuid, uuid) to service_role;
