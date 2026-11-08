-- Retain legacy data and IDs; the old table remains as a private archive.
update inventory_products set active=legacy_active_20261105,
 allow_decimal=legacy_allow_decimal_20261105,shelf_life=manage_expiry;
insert into inventory_suppliers(id,store_id,name,contact,phone,note)
 select id,store_id,name,contact,phone,note from legacy_inventory_suppliers_20261105
 on conflict(store_id,name) do update set id=excluded.id,contact=excluded.contact,phone=excluded.phone,note=excluded.note;
-- Do not silently supersede another draft or overwrite an existing document.
-- Any unexpected collision aborts and rolls the entire bridge back.
insert into inventory_documents(id,store_id,kind,status,revision,payload,created_at)
 select c.id,c.store_id,'check','draft',c.revision,jsonb_build_object(
 'product_ids',(select coalesce(jsonb_agg(l->>'id'),'[]') from jsonb_array_elements(c.snapshot) l),
 'lines',(select coalesce(jsonb_agg(l),'[]') from jsonb_array_elements(c.snapshot) l where l->'quantity'<>'null'::jsonb),
 'blind',c.blind,'freeze',c.pause_movements,'scope',case when c.scope='all' then '全部商品' else c.scope_value end,
 'date',(c.created_at at time zone 'Asia/Shanghai')::date::text),c.created_at
 from inventory_counts c where c.status='active';
