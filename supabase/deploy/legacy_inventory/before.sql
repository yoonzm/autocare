-- Only used for the known hosted development database with both historical
-- inventory migrations. Preserve the legacy values while the canonical schema
-- is installed in this same transaction.
do $$ begin
 if to_regclass('public.inventory_counts') is null or to_regclass('public.inventory_suppliers') is null
 or not exists(select 1 from information_schema.columns where table_schema='public' and table_name='inventory_products' and column_name='manage_expiry')
 or exists(select 1 from information_schema.columns where table_schema='public' and table_name='inventory_products' and column_name='metadata_revision')
 or exists(select 1 from information_schema.columns where table_schema='public' and table_name='inventory_suppliers' and column_name='revision') then
 raise exception 'unrecognized_legacy_inventory_schema'; end if;
end $$;
alter table inventory_products rename column active to legacy_active_20261105;
alter table inventory_products rename column allow_decimal to legacy_allow_decimal_20261105;
alter index inventory_product_sku rename to legacy_inventory_product_sku_20261105;
alter table inventory_suppliers rename to legacy_inventory_suppliers_20261105;
revoke all on legacy_inventory_suppliers_20261105 from public,anon,authenticated;
drop trigger inventory_settings on inventory_documents;
revoke all on function inventory_document_save_core(uuid,uuid,text,jsonb,integer,boolean),
 inventory_count_action(uuid,text,uuid,jsonb),inventory_count_list(uuid,integer),inventory_count_view(inventory_counts,boolean)
 from public,anon,authenticated,service_role;
