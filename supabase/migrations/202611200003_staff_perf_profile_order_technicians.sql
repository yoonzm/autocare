-- Reconcile production definitions with versioned source and current order technician arrays.
-- Keep legacy appointment attribution only when no explicit order technicians are recorded.

create or replace function public.staff_json(p_store uuid,p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select to_jsonb(s)-'resource_id'||jsonb_build_object(
    'resource_id',s.resource_id,
    'invite',(select jsonb_build_object('expires_at',i.expires_at,'created_at',i.created_at,
        'expired',i.expires_at<=now()) from public.store_staff_invites i
      where i.staff_id=s.id and i.accepted_at is null and i.revoked_at is null order by i.created_at desc limit 1),
    'month_orders',coalesce((select count(*) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
      where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id))
        and o.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0),
    'month_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id
        and c.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0),
    'total_orders',coalesce((select count(*) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
      where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id))),0),
    'total_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id),0),
    'busy',exists(select 1 from public.appointments a where a.store_id=p_store and a.status='arrived'
      and a.technician_id=s.resource_id and a.starts_at<=now() and a.starts_at+make_interval(mins=>a.duration_minutes)>now()),
    'bay_name',(select b.name from public.appointment_resources b where b.id=s.bay_id)
  ) from public.store_staff s where s.id=p_id and s.store_id=p_store
$$;

revoke all on function public.staff_json(uuid,uuid) from public,anon,authenticated;
grant execute on function public.staff_json(uuid,uuid) to service_role;

create or replace function public.staff_perf(p_store uuid,p_staff uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare s public.store_staff; m0 timestamptz; d0 timestamptz; days jsonb; rows jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  m0:=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  d0:=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai');
  select jsonb_agg(jsonb_build_object('day',to_char(dd,'YYYY-MM-DD'),'amount',coalesce((select sum(c.amount) from public.staff_commissions c
      where c.staff_id=s.id and c.created_at>=(dd::timestamp at time zone 'Asia/Shanghai')
        and c.created_at<((dd+1)::timestamp at time zone 'Asia/Shanghai')),0)) order by dd)
    into days from (select ((now() at time zone 'Asia/Shanghai')::date-g) dd from generate_series(0,6) g) x;
  select coalesce(jsonb_agg(jsonb_build_object('service',coalesce(i.name,'服务'),'plate',coalesce(ap.vehicle_plate,o.vehicle_plate,''),
      'at',c.created_at,'amount',c.amount) order by c.created_at desc),'[]'::jsonb) into rows
    from (select * from public.staff_commissions where staff_id=s.id and created_at>=m0 order by created_at desc limit 50) c
    join public.orders o on o.id=c.order_id
    left join public.order_items i on i.order_id=c.order_id and i.position=c.position
    left join public.appointments ap on ap.id=c.appointment_id;
  return jsonb_build_object('month_commission',coalesce((select sum(amount) from public.staff_commissions where staff_id=s.id and created_at>=m0),0),
    'month_orders',(select count(distinct o.id) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
      where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id)) and o.created_at>=m0),
    'month_revenue',coalesce((select sum(o.payable) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
      where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id)) and o.created_at>=m0),0),
    'days',days,'rows',rows,'month',to_char(now() at time zone 'Asia/Shanghai','YYYY-MM'));
end $$;

revoke all on function public.staff_perf(uuid,uuid) from public,anon,authenticated;
grant execute on function public.staff_perf(uuid,uuid) to service_role;
