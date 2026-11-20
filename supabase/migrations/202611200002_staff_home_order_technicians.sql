-- Replace the full definition to reconcile production drift.
-- Explicit order technicians take precedence; legacy orders retain appointment attribution.
create or replace function public.staff_home(p_store uuid,p_staff uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare s public.store_staff; d0 timestamptz; d1 timestamptz; res jsonb; tasks jsonb;
begin
  select * into s from public.store_staff where id=p_staff and store_id=p_store;
  if not found then raise exception 'staff_not_found' using errcode='P0002'; end if;
  d0:=(date_trunc('day',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai'); d1:=d0+interval '1 day';
  if s.role='technician' then
    select coalesce(jsonb_agg(jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'status',a.status,'starts_at',a.starts_at,
        'duration_minutes',a.duration_minutes,'customer',a.customer_name,'items',a.items,
        'bay_name',(select b.name from public.appointment_resources b where b.id=a.bay_id)) order by a.status<>'arrived',a.starts_at),'[]'::jsonb)
      into tasks from public.appointments a
      where a.store_id=p_store and a.technician_id=s.resource_id and a.status in ('waiting','arrived') and a.starts_at>=d0 and a.starts_at<d1;
    res:=jsonb_build_object('tasks',tasks,
      'done_today',(select count(*) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
        where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id)) and o.created_at>=d0 and o.created_at<d1),
      'revenue_today',coalesce((select sum(o.payable) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
        where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id)) and o.created_at>=d0 and o.created_at<d1),0),
      'commission_today',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id and c.created_at>=d0 and c.created_at<d1),0),
      'waiting',(select count(*) from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status='waiting' and a.starts_at>=d0 and a.starts_at<d1),
      'working',(select count(*) from public.appointments a where a.store_id=p_store and a.technician_id=s.resource_id and a.status='arrived' and a.starts_at>=d0 and a.starts_at<d1));
  else
    select coalesce(jsonb_agg(jsonb_build_object('id',a.id,'plate',a.vehicle_plate,'status',a.status,'starts_at',a.starts_at,
        'customer',a.customer_name,'items',a.items) order by a.starts_at),'[]'::jsonb)
      into tasks from (select * from public.appointments where store_id=p_store and status='waiting' and starts_at>=now() and starts_at<d1
        order by starts_at limit 5) a;
    res:=jsonb_build_object('upcoming',tasks,
      'orders_today',(select count(*) from public.orders where store_id=p_store and created_at>=d0 and created_at<d1),
      'waiting',(select count(*) from public.appointments where store_id=p_store and status='waiting' and starts_at>=d0 and starts_at<d1),
      'working',(select count(*) from public.appointments where store_id=p_store and status='arrived' and starts_at>=d0 and starts_at<d1));
  end if;
  return res||jsonb_build_object('role',s.role,'name',s.name,'phone',s.phone,'joined_on',s.joined_on,
    'month_done',(select count(*) from public.orders o left join public.appointments a on a.id=o.appointment_id and a.store_id=o.store_id
      where o.store_id=p_store and (s.resource_id=any(o.technician_ids) or (cardinality(o.technician_ids)=0 and a.technician_id=s.resource_id))
        and o.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),
    'month_commission',coalesce((select sum(c.amount) from public.staff_commissions c where c.staff_id=s.id
        and c.created_at>=(date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai')),0));
end $$;

revoke all on function public.staff_home(uuid,uuid) from public,anon,authenticated;
grant execute on function public.staff_home(uuid,uuid) to service_role;
