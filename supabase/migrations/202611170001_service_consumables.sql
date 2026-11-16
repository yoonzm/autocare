-- 服务项目的耗材绑定：一个服务用哪些库存商品、各多少（按服务一次计）。
-- 员工完工时按预约里的服务自动生成一张「施工领用」出库单（先进先出），库存不够不拦：
-- 扣到 0 为止，差额记入 appointment_work.consumables.short，并写进出库单备注。
create table public.service_consumables (
  service_id uuid not null references public.service_items(id) on delete cascade,
  product_id uuid not null references public.inventory_products(id) on delete restrict,
  store_id uuid not null references public.stores(id) on delete cascade,
  quantity numeric(14,3) not null check (quantity > 0 and quantity <= 999999),
  created_at timestamptz not null default now(),
  primary key (service_id, product_id)
);
create index service_consumables_product_idx on public.service_consumables(product_id);
alter table public.service_consumables enable row level security;
revoke all on public.service_consumables from public, anon, authenticated;
grant select, insert, update, delete on public.service_consumables to service_role;

alter table public.appointment_work add column if not exists consumables jsonb;

-- 整体替换某个服务的耗材（事务内校验商品归属 / 停用 / 小数 / 重复）。
create function public.save_service_consumables(p_store uuid, p_service uuid, p_items jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare it jsonb; p public.inventory_products; q numeric;
begin
  perform pg_advisory_xact_lock(hashtextextended('svc-consumables:' || p_service::text, 0));
  if not exists (select 1 from public.service_items where id = p_service and store_id = p_store) then
    raise exception 'service_not_found' using errcode = 'P0002';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) > 20 then raise exception 'invalid_consumables'; end if;
  if (select count(*) <> count(distinct x->>'product_id') from jsonb_array_elements(p_items) x) then raise exception 'duplicate_product'; end if;
  delete from public.service_consumables where service_id = p_service and store_id = p_store;
  for it in select value from jsonb_array_elements(p_items) loop
    select * into p from public.inventory_products where id = (it->>'product_id')::uuid and store_id = p_store;
    if not found then raise exception 'product_not_found' using errcode = 'P0002'; end if;
    if not p.active then raise exception 'product_disabled'; end if;
    q := (it->>'quantity')::numeric;
    if q is null or q <= 0 or q > 999999 or q <> round(q, 3) then raise exception 'invalid_quantity'; end if;
    if not p.allow_decimal and q <> trunc(q) then raise exception 'integer_quantity'; end if;
    insert into public.service_consumables(service_id, product_id, store_id, quantity) values (p_service, p.id, p_store, q);
  end loop;
  return (select coalesce(jsonb_agg(jsonb_build_object('product_id', c.product_id, 'quantity', c.quantity) order by c.created_at), '[]'::jsonb)
    from public.service_consumables c where c.service_id = p_service);
end $$;
revoke all on function public.save_service_consumables(uuid, uuid, jsonb) from public, anon, authenticated;
grant execute on function public.save_service_consumables(uuid, uuid, jsonb) to service_role;

-- 完工自动扣减：按预约里每个服务各一份用量汇总；库存不够不拦，扣到 0 为止并记录缺口。
-- 出库单失败（如盘点冻结）也不影响完工，错误原因记在 consumables.error。
create function public.service_consumables_deduct(p_store uuid, p_appointment uuid, p_operator text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare a public.appointments; r record; use_q numeric; lines jsonb := '[]'; short jsonb := '[]'; note text := '';
  doc jsonb; err text; result jsonb;
begin
  select * into a from public.appointments where id = p_appointment and store_id = p_store;
  if not found then return null; end if;
  for r in
    select c.product_id, sum(c.quantity) as need, max(p.name) as name, max(p.unit) as unit, max(p.stock) as stock,
      bool_and(p.active) as active, bool_and(p.allow_decimal) as allow_decimal
    from public.service_consumables c join public.inventory_products p on p.id = c.product_id and p.store_id = p_store
    where c.store_id = p_store and c.service_id = any(a.service_ids)
    group by c.product_id
  loop
    if not r.active then
      short := short || jsonb_build_object('product_id', r.product_id, 'name', r.name, 'unit', r.unit, 'need', r.need, 'have', 0, 'reason', '商品已停用');
      continue;
    end if;
    use_q := least(r.need, r.stock);
    if not r.allow_decimal then use_q := floor(use_q); end if;
    use_q := round(use_q, 3);
    if use_q > 0 then lines := lines || jsonb_build_object('id', r.product_id, 'quantity', use_q); end if;
    if use_q < r.need then
      short := short || jsonb_build_object('product_id', r.product_id, 'name', r.name, 'unit', r.unit, 'need', r.need, 'have', r.stock);
      note := note || case when note = '' then '' else '、' end || r.name || '缺 ' || trim(trailing '.' from trim(trailing '0' from (r.need - use_q)::text)) || r.unit;
    end if;
  end loop;
  if jsonb_array_length(lines) > 0 then
    begin
      doc := public.inventory_document_save(p_store, gen_random_uuid(), 'out', jsonb_build_object(
        'lines', lines, 'reason', '施工领用', 'technician_id', a.technician_id, 'operator', p_operator,
        'note', left('完工自动扣减' || case when note = '' then '' else ' · 库存不足：' || note end, 200)), 0, true);
    exception when others then
      err := sqlerrm;
      doc := null;
    end;
  end if;
  result := jsonb_build_object('document_id', doc->>'id', 'deducted', case when doc is null then '[]'::jsonb else lines end,
    'short', short, 'error', err);
  update public.appointment_work set consumables = result where appointment_id = p_appointment;
  return result;
end $$;
revoke all on function public.service_consumables_deduct(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.service_consumables_deduct(uuid, uuid, text) to service_role;

-- 员工提交完工时自动扣减耗材（只在首次完工时执行：重复完工会在此之前被 task_finished 拒绝）。
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.staff_task_finish(uuid,uuid,uuid)'::regprocedure) into def;
  patched := replace(def,
    'update public.appointment_work set stage=4,finished_at=now(),finished_by=s.id,updated_at=now() where appointment_id=p_id;',
    'update public.appointment_work set stage=4,finished_at=now(),finished_by=s.id,updated_at=now() where appointment_id=p_id;'
    || E'\n  perform public.service_consumables_deduct(p_store,p_id,s.name||''（完工自动扣减）'');');
  if patched = def then raise exception 'staff_task_finish anchor not found'; end if;
  execute patched;
end $$;
