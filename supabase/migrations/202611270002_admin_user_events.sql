-- 扩展后台「账号详情 -> 操作记录」查询：
-- 除后台强制注销外，补充账号生命周期（注册、创建/加入门店、用户自助注销）及后续后台冻结/解冻记录，按时间倒序最多返回 20 条。
create or replace function public.admin_user_get(p_actor uuid, p_session uuid, p_id uuid) returns jsonb
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
  select coalesce(jsonb_agg(jsonb_build_object('text', x.text, 'at', x.at, 'by', x.by) order by x.at desc, x.ord desc), '[]'::jsonb)
  into events
  from (
    select * from (
      -- 1. 后台运营处置：强制注销、冻结/解冻
      select
        case l.action
          when 'user_cancel' then '后台强制注销' || case l.detail->>'reason'
            when 'user_request' then '（用户要求）'
            when 'violation' then '（违规处理）'
            else '（其他）' end
          when 'user_freeze' then '后台冻结账号'
          when 'user_unfreeze' then '后台解冻账号'
        end as text,
        l.created_at as at,
        coalesce(ad.name, '运营') as by,
        50 as ord
      from public.admin_audit_logs l
      left join public.admin_accounts ad on ad.id = l.actor_id
      where l.action in ('user_cancel', 'user_freeze', 'user_unfreeze')
        and l.target = p_id::text

      union all

      -- 2. 用户自助注销（立即注销写入 account_cancellations.source = 'self'）
      select
        '用户自助注销' as text,
        c.cancelled_at as at,
        '用户本人' as by,
        45 as ord
      from public.account_cancellations c
      where c.user_id = p_id and c.source = 'self'

      union all

      -- 3. 兼容历史冷静期申请注销记录
      select
        '用户自助申请注销' as text,
        r.delete_requested_at as at,
        '用户本人' as by,
        40 as ord
      where r.delete_requested_at is not null
        and not exists (
          select 1 from public.account_cancellations c
          where c.user_id = p_id and c.source = 'self'
        )

      union all

      -- 4. 老板创建门店
      select
        '创建门店「' || s.name || '」' as text,
        s.created_at as at,
        '用户本人' as by,
        30 as ord
      from public.stores s
      where s.owner_id = p_id

      union all

      -- 5. 员工加入门店
      select
        '加入门店「' || st.name || '」（' || case t.role
          when 'manager' then '店长'
          when 'cashier' then '前台'
          when 'technician' then '技师'
          else t.role end || '）' as text,
        t.created_at as at,
        '门店邀请' as by,
        20 as ord
      from public.store_staff t
      join public.stores st on st.id = t.store_id
      where t.user_id = p_id

      union all

      -- 6. 注册账号
      select
        '注册账号' as text,
        r.created_at as at,
        '用户本人' as by,
        10 as ord
      where r.created_at is not null
    ) all_events
    order by at desc, ord desc
    limit 20
  ) x;

  return jsonb_build_object('item', to_jsonb(r) - 'store_names', 'devices', devices, 'events', events,
    'open_holds', holds, 'open_appointments', appts, 'now', now());
end $$;
