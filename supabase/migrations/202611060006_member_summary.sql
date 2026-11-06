-- Whole-store aggregates must not depend on PostgREST's returned-row limit.
-- p_at is a server-only clock override for deterministic boundary tests.
-- The Edge Function supplies only p_store, derived from the verified session.
create function public.merchant_member_summary(p_store uuid, p_at timestamptz default now())
returns jsonb
language sql stable security definer
set search_path = ''
as $$
  with bounds as (
    select date_trunc('month', p_at at time zone 'Asia/Shanghai') as month_start
  ), grouped as (
    select m.card_type_id, count(*) as members,
      sum(m.balance) as balance,
      count(*) filter (
        where m.created_at >= (b.month_start at time zone 'Asia/Shanghai')
          and m.created_at < ((b.month_start + interval '1 month') at time zone 'Asia/Shanghai')
      ) as new_members
    from public.members m cross join bounds b
    where m.store_id = p_store and m.deleted_at is null
    group by m.card_type_id
  )
  select jsonb_build_object(
    'total', coalesce(sum(members), 0),
    'total_balance', coalesce(sum(balance), 0),
    'new_this_month', coalesce(sum(new_members), 0),
    'counts', coalesce(jsonb_object_agg(card_type_id::text, members), '{}'::jsonb)
  ) from grouped;
$$;

revoke all on function public.merchant_member_summary(uuid, timestamptz) from public, anon, authenticated;
grant execute on function public.merchant_member_summary(uuid, timestamptz) to service_role;
