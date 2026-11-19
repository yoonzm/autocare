-- IDs refer to appointment_resources, the same technician IDs used by the picker.
alter table public.orders add column technician_ids uuid[] not null default '{}';
alter table public.held_orders add column technician_ids uuid[] not null default '{}';

-- A technician already on the document may be retained after being disabled.
create function public.order_technicians(p_store uuid, p_ids uuid[], p_existing uuid[]) returns uuid[]
language plpgsql set search_path = public as $$
declare
  v_ids uuid[];
  v_id uuid;
begin
  if p_ids is null then return p_existing; end if;
  select coalesce(array_agg(id order by first_position), '{}') into v_ids
  from (select id, min(position) as first_position
        from unnest(p_ids) with ordinality as t(id, position) group by id) ids;
  for v_id in select id from unnest(v_ids) as t(id) order by id loop
    perform 1 from public.appointment_resources
    where id = v_id and store_id = p_store and kind = 'technician'
      and (active or v_id = any(p_existing))
    for share;
    if not found then raise exception 'order_technician_unavailable' using errcode = '22023'; end if;
  end loop;
  return v_ids;
end;
$$;

create function public.hold_order_with_technicians(
  p_store uuid, p_member uuid, p_lines jsonb, p_status text, p_note text, p_remind text,
  p_plate text, p_hold uuid, p_technician_ids uuid[]
) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_existing uuid[];
begin
  v_id := public.hold_order(p_store, p_member, p_lines, p_status, p_note, p_remind, p_plate, p_hold);
  if p_technician_ids is not null then
    select technician_ids into v_existing from public.held_orders where id = v_id and store_id = p_store;
    update public.held_orders set technician_ids = public.order_technicians(p_store, p_technician_ids, v_existing)
    where id = v_id and store_id = p_store;
  end if;
  return v_id;
end;
$$;

create function public.checkout_with_technicians(
  p_store uuid, p_lines jsonb, p_method text, p_plate text, p_remark text, p_operator text,
  p_request text, p_technician_ids uuid[], p_member uuid, p_hold uuid, p_appointment uuid,
  p_balance_part numeric, p_other text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_result jsonb; v_order uuid; v_ids uuid[] := '{}';
begin
  if p_appointment is not null then
    v_result := public.checkout_appointment(p_store, p_appointment, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_operator, p_request);
  elsif p_hold is not null then
    v_result := public.settle_held_order(p_store, p_hold, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_remark, p_operator, p_request);
  elsif p_member is not null then
    v_result := public.checkout_order(p_store, p_member, p_lines, p_method,
      p_balance_part, p_other, p_plate, p_remark, p_operator, p_request);
  else
    v_result := public.checkout_walkin(p_store, p_lines, p_method, p_plate, p_remark, p_operator, p_request);
  end if;

  v_order := (v_result->>'order_id')::uuid;
  if v_result->>'repeated' = 'true' then
    select technician_ids into v_ids from public.orders where id = v_order and store_id = p_store;
  else
    if p_appointment is not null then
      select array_remove(array[technician_id], null) into v_ids
      from public.appointments where id = p_appointment and store_id = p_store;
    elsif p_hold is not null then
      select technician_ids into v_ids from public.held_orders where id = p_hold and store_id = p_store;
    end if;
    v_ids := public.order_technicians(p_store, p_technician_ids, v_ids);
    if cardinality(v_ids) > 0 then
      update public.orders set technician_ids = v_ids where id = v_order and store_id = p_store;
    end if;
  end if;
  return v_result || jsonb_build_object('technician_ids', v_ids);
end;
$$;

revoke all on function public.order_technicians(uuid,uuid[],uuid[]) from public, anon, authenticated;
revoke all on function public.hold_order_with_technicians(uuid,uuid,jsonb,text,text,text,text,uuid,uuid[]) from public, anon, authenticated;
revoke all on function public.checkout_with_technicians(uuid,jsonb,text,text,text,text,text,uuid[],uuid,uuid,uuid,numeric,text) from public, anon, authenticated;
grant execute on function public.hold_order_with_technicians(uuid,uuid,jsonb,text,text,text,text,uuid,uuid[]) to service_role;
grant execute on function public.checkout_with_technicians(uuid,jsonb,text,text,text,text,text,uuid[],uuid,uuid,uuid,numeric,text) to service_role;
