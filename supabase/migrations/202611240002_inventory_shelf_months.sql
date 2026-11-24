-- 商品增加保质期月数字段（shelf_months），用于入库快捷到期日推算。
alter table public.inventory_products
  add column if not exists shelf_months integer
  check (shelf_months is null or shelf_months between 1 and 120);

create or replace function inventory_mutate(p_store uuid, p_request text, p_action text, p_data jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  result jsonb;
  previous inventory_requests;
  p inventory_products;
  c inventory_categories;
  s inventory_suppliers;
  d inventory_documents;
  audit inventory_document_audit;
  item jsonb;
  code text;
  rid uuid;
  v_shelf_months integer;
begin
  if p_request is null or length(p_request) not between 1 and 100 then raise exception 'invalid_request'; end if;
  perform pg_advisory_xact_lock(hashtextextended('inventory:' || p_store::text, 0));
  select * into previous from inventory_requests where store_id = p_store and request_id = p_request;
  if found then
    if previous.input <> jsonb_build_object('action', p_action, 'data', p_data) then raise exception 'request_conflict'; end if;
    return previous.result;
  end if;
  perform inventory_options(p_store);
  if p_action in ('create', 'update', 'disable', 'enable') then
    rid := (p_data->>'id')::uuid;
    select * into p from inventory_products where id = rid and store_id = p_store for update;
    if p_action <> 'create' and not found then raise exception 'product_not_found'; end if;
    if p_action <> 'create' and p.metadata_revision is distinct from (p_data->>'metadata_revision')::integer then raise exception 'product_changed'; end if;
    if p_action in ('disable', 'enable') then
      if p_action = 'disable' and p.stock <> 0 then raise exception 'nonzero_stock'; end if;
      update inventory_products set active = p_action = 'enable', metadata_revision = metadata_revision + 1
      where id = rid returning to_jsonb(inventory_products.*) into result;
    else
      if length(trim(p_data->>'name')) not between 1 and 120 or length(trim(p_data->>'unit')) not between 1 and 12
        or not exists(select 1 from inventory_categories where store_id = p_store and name = p_data->>'category') then raise exception 'invalid_product'; end if;
      if (p_data->>'safe')::numeric < 0 or (p_data->>'safe')::numeric <> round((p_data->>'safe')::numeric, 3)
        or (p_data->>'cost')::numeric < 0 then raise exception 'invalid_amount'; end if;
      if p_action = 'update' and (p.stock <> 0 and (p.unit <> p_data->>'unit' or (not coalesce((p_data->>'allow_decimal')::boolean, true) and p.stock <> trunc(p.stock)))) then raise exception 'unit_in_use'; end if;
      v_shelf_months := case when coalesce((p_data->>'shelf_life')::boolean, false) then nullif(p_data->>'shelf_months', '')::integer else null end;
      if v_shelf_months is not null and (v_shelf_months < 1 or v_shelf_months > 120) then raise exception 'invalid_product'; end if;
      code := coalesce(nullif(trim(p_data->>'sku'), ''), 'SKU-' || replace(rid::text, '-', ''));
      if p_action = 'create' then
        insert into inventory_products(id, store_id, name, category, unit, safe, cost, sku, specification, location, supplier, allow_decimal, shelf_life, expiry_days, shelf_months)
        values(rid, p_store, trim(p_data->>'name'), p_data->>'category', trim(p_data->>'unit'), (p_data->>'safe')::numeric, (p_data->>'cost')::numeric,
          code, coalesce(p_data->>'specification', ''), coalesce(p_data->>'location', ''), coalesce(p_data->>'supplier', ''),
          coalesce((p_data->>'allow_decimal')::boolean, true), coalesce((p_data->>'shelf_life')::boolean, false),
          (p_data->>'expiry_days')::integer, v_shelf_months)
        returning to_jsonb(inventory_products.*) into result;
      else
        update inventory_products set name = trim(p_data->>'name'), category = p_data->>'category', unit = trim(p_data->>'unit'),
          safe = (p_data->>'safe')::numeric, sku = code, specification = coalesce(p_data->>'specification', ''),
          location = coalesce(p_data->>'location', ''), supplier = coalesce(p_data->>'supplier', ''),
          allow_decimal = coalesce((p_data->>'allow_decimal')::boolean, true),
          shelf_life = coalesce((p_data->>'shelf_life')::boolean, false),
          expiry_days = (p_data->>'expiry_days')::integer,
          shelf_months = v_shelf_months,
          metadata_revision = metadata_revision + 1
        where id = rid returning to_jsonb(inventory_products.*) into result;
      end if;
    end if;
  elsif p_action = 'supplier_save' then
    rid := (p_data->>'id')::uuid;
    select * into s from inventory_suppliers where store_id = p_store and id = rid for update;
    if found and s.revision is distinct from (p_data->>'revision')::integer then raise exception 'supplier_changed'; end if;
    insert into inventory_suppliers(id, store_id, name, contact, phone, note)
    values(rid, p_store, trim(p_data->>'name'), coalesce(p_data->>'contact', ''), coalesce(p_data->>'phone', ''), coalesce(p_data->>'note', ''))
    on conflict(id) do update set name = excluded.name, contact = excluded.contact, phone = excluded.phone, note = excluded.note, revision = inventory_suppliers.revision + 1
    where inventory_suppliers.store_id = p_store returning to_jsonb(inventory_suppliers.*) into result;
    if result is null then raise exception 'supplier_not_found'; end if;
  elsif p_action in ('category_save', 'category_delete') then
    rid := (p_data->>'id')::uuid;
    select * into c from inventory_categories where store_id = p_store and id = rid for update;
    if p_action = 'category_delete' then
      if not found then raise exception 'category_not_found'; end if;
      if exists(select 1 from inventory_products where store_id = p_store and category = c.name) then raise exception 'category_in_use'; end if;
      delete from inventory_categories where id = rid; result := '{}';
    else
      if found and c.name is distinct from p_data->>'previous_name' then raise exception 'category_changed'; end if;
      insert into inventory_categories(id, store_id, name) values(rid, p_store, trim(p_data->>'name'))
      on conflict(id) do update set name = excluded.name where inventory_categories.store_id = p_store returning to_jsonb(inventory_categories.*) into result;
      if result is null then raise exception 'category_not_found'; end if;
      if c.id is not null then update inventory_products set category = trim(p_data->>'name'), metadata_revision = metadata_revision + 1 where store_id = p_store and category = c.name; end if;
    end if;
  elsif p_action = 'settings_save' then
    if coalesce((p_data->>'message_enabled')::boolean, false) then raise exception 'notifications_unavailable'; end if;
    update inventory_settings set low_enabled = (p_data->>'low_enabled')::boolean, expiry_enabled = (p_data->>'expiry_enabled')::boolean,
      expiry_days = (p_data->>'expiry_days')::integer, home_enabled = (p_data->>'home_enabled')::boolean,
      list_enabled = (p_data->>'list_enabled')::boolean, revision = revision + 1
    where store_id = p_store and revision = (p_data->>'revision')::integer returning to_jsonb(inventory_settings.*) into result;
    if result is null then raise exception 'settings_changed'; end if;
  elsif p_action = 'void' then
    select * into d from inventory_documents where store_id = p_store and id = (p_data->>'id')::uuid for update;
    if not found then raise exception 'document_not_found'; end if;
    if d.status = 'void' then raise exception 'document_closed'; end if;
    if length(trim(p_data->>'reason')) not between 1 and 1000 then raise exception 'reason_required'; end if;
    if d.status = 'posted' then
      select * into audit from inventory_document_audit where document_id = d.id and store_id = p_store;
      if not found then raise exception 'legacy_document'; end if;
      for item in select value from jsonb_array_elements(audit.before_products) order by value->>'id' loop
        select * into p from inventory_products where id = (item->>'id')::uuid and store_id = p_store for update;
        if p.version <> (audit.after_versions->>p.id::text)::integer or p.unit <> item->>'unit' or (not p.allow_decimal and (item->>'stock')::numeric <> trunc((item->>'stock')::numeric)) then raise exception 'document_in_use'; end if;
        if not p.active then raise exception 'product_disabled'; end if;
        update inventory_batches set quantity = 0 where product_id = p.id and store_id = p_store;
        update inventory_batches b set quantity = (v->>'quantity')::numeric from jsonb_array_elements(audit.before_batches) v where b.id = (v->>'id')::uuid and b.product_id = p.id;
        update inventory_products set stock = (item->>'stock')::numeric, cost = (item->>'cost')::numeric, expires_on = nullif(item->>'expires_on', '')::date, version = version + 1 where id = p.id;
        insert into inventory_movements(store_id, product_id, request_id, payload, before_stock, after_stock, document_id, cost)
        values(p_store, p.id, 'void:' || d.id || ':' || p.id, jsonb_build_object('kind', 'void', 'reason', p_data->>'reason'), p.stock, (item->>'stock')::numeric, d.id, 0);
      end loop;
      update expense_entries set deleted = true, revision = revision + 1, updated_at = now() where source_document = d.id and store_id = p_store;
    end if;
    update inventory_documents set status = 'void', void_reason = trim(p_data->>'reason'), voided_at = now(), revision = revision + 1
    where id = d.id returning to_jsonb(inventory_documents.*) into result;
  else raise exception 'invalid_action';
  end if;
  insert into inventory_requests values(p_store, p_request, jsonb_build_object('action', p_action, 'data', p_data), result);
  return result;
end $$;

revoke all on function inventory_mutate(uuid, text, text, jsonb) from public, anon, authenticated;
grant execute on function inventory_mutate(uuid, text, text, jsonb) to service_role;
