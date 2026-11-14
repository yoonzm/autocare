-- 会员列表的“次卡状态”和“车辆与项目”筛选。
-- merchant-v1 在这两类筛选生效时改为查询本视图（其余情况仍查 members），筛选条件是视图里的布尔列。
-- 注意：视图在创建时固定了 members 的列；以后给 members 加列并要出现在会员列表里时，需要新增迁移重建本视图。
--
-- 次卡状态：
--   f_pkg_expiring  有未退款、还有剩余次数的次卡，7 天内到期（已过期的不算）
--   f_pkg_low       有未退款、未过期的次卡，剩余次数 1～2
--   f_pkg_used_up   有未退款次卡，且全部次卡都已用完
-- 车辆与项目：
--   f_ev            名下有新能源车辆
--   f_multi         名下车辆不少于 2 辆
--   f_coating       做过镀晶镀膜类服务（订单明细）
--   f_wrap_warranty 近 36 个月内做过贴膜 / 改色膜类服务（车衣质保期内，质保期暂按 3 年计）
create or replace view public.members_filterable with (security_invoker = false) as
select
  m.*,
  exists (
    select 1 from public.member_packages p
    where p.member_id = m.id and p.refunded_at is null
      and p.used_count < p.total_count
      and p.expires_at is not null
      and p.expires_at >= now() and p.expires_at < now() + interval '7 days'
  ) as f_pkg_expiring,
  exists (
    select 1 from public.member_packages p
    where p.member_id = m.id and p.refunded_at is null
      and (p.expires_at is null or p.expires_at >= now())
      and p.total_count - p.used_count between 1 and 2
  ) as f_pkg_low,
  (
    exists (select 1 from public.member_packages p
            where p.member_id = m.id and p.refunded_at is null)
    and not exists (select 1 from public.member_packages p
            where p.member_id = m.id and p.refunded_at is null
              and p.used_count < p.total_count)
  ) as f_pkg_used_up,
  exists (
    select 1 from public.member_vehicles v where v.member_id = m.id and v.energy = 'ev'
  ) as f_ev,
  (select count(*) from public.member_vehicles v where v.member_id = m.id) >= 2 as f_multi,
  exists (
    select 1 from public.orders o
    join public.order_items i on i.order_id = o.id
    join public.service_items s on s.id = i.service_id
    where o.member_id = m.id and s.category = '镀晶镀膜'
  ) as f_coating,
  exists (
    select 1 from public.orders o
    join public.order_items i on i.order_id = o.id
    join public.service_items s on s.id = i.service_id
    where o.member_id = m.id and s.category in ('贴膜', '改色膜')
      and o.created_at >= now() - interval '36 months'
  ) as f_wrap_warranty
from public.members m;
revoke all on public.members_filterable from public, anon, authenticated;
grant select on public.members_filterable to service_role;
