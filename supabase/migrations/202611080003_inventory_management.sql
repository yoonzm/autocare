-- Inventory metadata, settings, audit and reversals. All writes remain service-only.
alter table inventory_products drop constraint inventory_products_category_check;
alter table inventory_products add column active boolean not null default true,
 add column metadata_revision integer not null default 0,
 add column allow_decimal boolean not null default true,
 add column shelf_life boolean not null default false,
 add column expiry_days integer check(expiry_days between 1 and 3650);
update inventory_products set sku='SKU-'||replace(id::text,'-','') where trim(sku)='';
-- Preserve legacy duplicate user codes without silently merging products.
with ranked as (select id,row_number() over(partition by store_id,sku order by id) n from inventory_products)
update inventory_products p set sku=p.sku||'-'||replace(p.id::text,'-','') from ranked r where p.id=r.id and r.n>1;
create unique index inventory_product_sku on inventory_products(store_id,sku);
create function inventory_product_code() returns trigger language plpgsql set search_path=public as $$
begin if trim(new.sku)='' then new.sku:='SKU-'||replace(new.id::text,'-',''); end if;return new;end $$;
create trigger inventory_product_code before insert or update of sku on inventory_products for each row execute function inventory_product_code();
revoke all on function inventory_product_code() from public,anon,authenticated;
create table inventory_categories (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references stores(id),
 name text not null check(length(trim(name)) between 1 and 40), position integer not null default 0,
 unique(store_id,name)
);
create table inventory_suppliers (
 id uuid primary key, store_id uuid not null references stores(id),
 name text not null check(length(trim(name)) between 1 and 120), contact text not null default '',
 phone text not null default '', note text not null default '', revision integer not null default 0,
 unique(store_id,name), check(length(contact)<=120 and length(phone)<=40 and length(note)<=1000)
);
create table inventory_settings (
 store_id uuid primary key references stores(id), low_enabled boolean not null default true,
 expiry_enabled boolean not null default true, expiry_days integer not null default 30 check(expiry_days in (7,15,30,60)),
 home_enabled boolean not null default true, list_enabled boolean not null default true,
 message_enabled boolean not null default false check(not message_enabled), revision integer not null default 0
);
create table inventory_requests (
 store_id uuid not null references stores(id), request_id text not null, input jsonb not null, result jsonb not null,
 primary key(store_id,request_id)
);
create table inventory_document_audit (
 document_id uuid primary key references inventory_documents(id), store_id uuid not null references stores(id),
 before_products jsonb not null, before_batches jsonb not null, after_versions jsonb not null
);
insert into inventory_categories(store_id,name) select id,n from stores cross join unnest(array['贴膜','镀晶','洗护','配件','其他']) n;
insert into inventory_categories(store_id,name) select distinct store_id,category from inventory_products on conflict do nothing;
insert into inventory_suppliers(id,store_id,name) select gen_random_uuid(),store_id,supplier from inventory_products where trim(supplier)<>'' group by store_id,supplier;
alter table inventory_documents drop constraint inventory_documents_status_check;
alter table inventory_documents add constraint inventory_documents_status_check check(status in ('draft','posted','void'));
alter table inventory_documents add column void_reason text, add column voided_at timestamptz;
-- Existing parallel count drafts are retained but only the newest can be resumed.
with ranked as (select id,row_number() over(partition by store_id order by created_at desc,id) n from inventory_documents where kind='check' and status='draft')
update inventory_documents d set status='void',void_reason='历史重复盘点草稿',voided_at=now() from ranked r where d.id=r.id and r.n>1;
create unique index inventory_one_count on inventory_documents(store_id) where kind='check' and status='draft';
do $$ declare t text; begin
 foreach t in array array['inventory_categories','inventory_suppliers','inventory_settings','inventory_requests','inventory_document_audit'] loop
 execute format('alter table %I enable row level security',t);
 execute format('revoke all on %I from public,anon,authenticated',t);
 execute format('grant all on %I to service_role',t);
 if t not in ('inventory_requests','inventory_document_audit') then
 execute format('grant select on %I to authenticated',t);
 execute format('create policy inventory_current_store on %I for select to authenticated using (platform_store_access(store_id))',t);
 end if;
 end loop;
end $$;

create function inventory_options(p_store uuid) returns jsonb language plpgsql security definer set search_path=public as $$
begin
 insert into inventory_categories(store_id,name) select p_store,n from unnest(array['贴膜','镀晶','洗护','配件','其他']) n
 where not exists(select 1 from inventory_categories where store_id=p_store) on conflict do nothing;
 insert into inventory_settings(store_id) values(p_store) on conflict do nothing;
 return jsonb_build_object('categories',(select coalesce(jsonb_agg(to_jsonb(c)||jsonb_build_object('count',(select count(*) from inventory_products p where p.store_id=p_store and p.category=c.name)) order by position,name),'[]') from inventory_categories c where store_id=p_store),
 'suppliers',(select coalesce(jsonb_agg(to_jsonb(s) order by name),'[]') from inventory_suppliers s where store_id=p_store),
 'settings',(select to_jsonb(s) from inventory_settings s where store_id=p_store));
end $$;
create function inventory_mutate(p_store uuid,p_request text,p_action text,p_data jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare result jsonb; previous inventory_requests; p inventory_products; c inventory_categories; s inventory_suppliers; d inventory_documents; audit inventory_document_audit; item jsonb; before_p jsonb; before_b jsonb; versions jsonb; code text; rid uuid; q numeric;
begin
 if p_request is null or length(p_request) not between 1 and 100 then raise exception 'invalid_request'; end if;
 perform pg_advisory_xact_lock(hashtextextended('inventory:'||p_store::text,0));
 select * into previous from inventory_requests where store_id=p_store and request_id=p_request;
 if found then
 if previous.input<>jsonb_build_object('action',p_action,'data',p_data) then raise exception 'request_conflict'; end if;
 return previous.result; end if;
 perform inventory_options(p_store);
 if p_action in ('create','update','disable','enable') then
 rid:=(p_data->>'id')::uuid;
 select * into p from inventory_products where id=rid and store_id=p_store for update;
 if p_action<>'create' and not found then raise exception 'product_not_found'; end if;
 if p_action<>'create' and p.metadata_revision is distinct from (p_data->>'metadata_revision')::integer then raise exception 'product_changed'; end if;
 if p_action in ('disable','enable') then
 if p_action='disable' and p.stock<>0 then raise exception 'nonzero_stock'; end if;
 update inventory_products set active=p_action='enable',metadata_revision=metadata_revision+1 where id=rid returning to_jsonb(inventory_products.*) into result;
 else
 if length(trim(p_data->>'name')) not between 1 and 120 or length(trim(p_data->>'unit')) not between 1 and 12
 or not exists(select 1 from inventory_categories where store_id=p_store and name=p_data->>'category') then raise exception 'invalid_product'; end if;
 if (p_data->>'safe')::numeric<0 or (p_data->>'safe')::numeric<>round((p_data->>'safe')::numeric,3) or (p_data->>'cost')::numeric<0 then raise exception 'invalid_amount'; end if;
 if p_action='update' and (p.stock<>0 and (p.unit<>p_data->>'unit' or (not coalesce((p_data->>'allow_decimal')::boolean,true) and p.stock<>trunc(p.stock)))) then raise exception 'unit_in_use'; end if;
 code:=coalesce(nullif(trim(p_data->>'sku'),''),'SKU-'||replace(rid::text,'-',''));
 if p_action='create' then
 insert into inventory_products(id,store_id,name,category,unit,safe,cost,sku,specification,location,supplier,allow_decimal,shelf_life,expiry_days)
 values(rid,p_store,trim(p_data->>'name'),p_data->>'category',trim(p_data->>'unit'),(p_data->>'safe')::numeric,(p_data->>'cost')::numeric,code,coalesce(p_data->>'specification',''),coalesce(p_data->>'location',''),coalesce(p_data->>'supplier',''),coalesce((p_data->>'allow_decimal')::boolean,true),coalesce((p_data->>'shelf_life')::boolean,false),(p_data->>'expiry_days')::integer) returning to_jsonb(inventory_products.*) into result;
 else
 update inventory_products set name=trim(p_data->>'name'),category=p_data->>'category',unit=trim(p_data->>'unit'),safe=(p_data->>'safe')::numeric,sku=code,
 specification=coalesce(p_data->>'specification',''),location=coalesce(p_data->>'location',''),supplier=coalesce(p_data->>'supplier',''),allow_decimal=coalesce((p_data->>'allow_decimal')::boolean,true),shelf_life=coalesce((p_data->>'shelf_life')::boolean,false),expiry_days=(p_data->>'expiry_days')::integer,metadata_revision=metadata_revision+1 where id=rid returning to_jsonb(inventory_products.*) into result;
 end if;
 end if;
 elsif p_action='supplier_save' then
 rid:=(p_data->>'id')::uuid;
 select * into s from inventory_suppliers where store_id=p_store and id=rid for update;
 if found and s.revision is distinct from (p_data->>'revision')::integer then raise exception 'supplier_changed'; end if;
 insert into inventory_suppliers(id,store_id,name,contact,phone,note) values(rid,p_store,trim(p_data->>'name'),coalesce(p_data->>'contact',''),coalesce(p_data->>'phone',''),coalesce(p_data->>'note',''))
 on conflict(id) do update set name=excluded.name,contact=excluded.contact,phone=excluded.phone,note=excluded.note,revision=inventory_suppliers.revision+1 where inventory_suppliers.store_id=p_store returning to_jsonb(inventory_suppliers.*) into result;
 if result is null then raise exception 'supplier_not_found'; end if;
 elsif p_action in ('category_save','category_delete') then
 rid:=(p_data->>'id')::uuid;
 select * into c from inventory_categories where store_id=p_store and id=rid for update;
 if p_action='category_delete' then
 if not found then raise exception 'category_not_found'; end if;
 if exists(select 1 from inventory_products where store_id=p_store and category=c.name) then raise exception 'category_in_use'; end if;
 delete from inventory_categories where id=rid; result:='{}';
 else
 if found and c.name is distinct from p_data->>'previous_name' then raise exception 'category_changed'; end if;
 insert into inventory_categories(id,store_id,name) values(rid,p_store,trim(p_data->>'name')) on conflict(id) do update set name=excluded.name where inventory_categories.store_id=p_store returning to_jsonb(inventory_categories.*) into result;
 if result is null then raise exception 'category_not_found'; end if;
 if c.id is not null then update inventory_products set category=trim(p_data->>'name'),metadata_revision=metadata_revision+1 where store_id=p_store and category=c.name; end if;
 end if;
 elsif p_action='settings_save' then
 if coalesce((p_data->>'message_enabled')::boolean,false) then raise exception 'notifications_unavailable'; end if;
 update inventory_settings set low_enabled=(p_data->>'low_enabled')::boolean,expiry_enabled=(p_data->>'expiry_enabled')::boolean,expiry_days=(p_data->>'expiry_days')::integer,home_enabled=(p_data->>'home_enabled')::boolean,list_enabled=(p_data->>'list_enabled')::boolean,revision=revision+1 where store_id=p_store and revision=(p_data->>'revision')::integer returning to_jsonb(inventory_settings.*) into result;
 if result is null then raise exception 'settings_changed'; end if;
 elsif p_action='void' then
 select * into d from inventory_documents where store_id=p_store and id=(p_data->>'id')::uuid for update;
 if not found then raise exception 'document_not_found'; end if;
 if d.status='void' then raise exception 'document_closed'; end if;
 if length(trim(p_data->>'reason')) not between 1 and 1000 then raise exception 'reason_required'; end if;
 if d.status='posted' then
 select * into audit from inventory_document_audit where document_id=d.id and store_id=p_store;
 if not found then raise exception 'legacy_document'; end if;
 for item in select value from jsonb_array_elements(audit.before_products) order by value->>'id' loop
 select * into p from inventory_products where id=(item->>'id')::uuid and store_id=p_store for update;
 if p.version<>(audit.after_versions->>p.id::text)::integer or p.unit<>item->>'unit' or (not p.allow_decimal and (item->>'stock')::numeric<>trunc((item->>'stock')::numeric)) then raise exception 'document_in_use'; end if;
 if not p.active then raise exception 'product_disabled'; end if;
 update inventory_batches set quantity=0 where product_id=p.id and store_id=p_store;
 update inventory_batches b set quantity=(v->>'quantity')::numeric from jsonb_array_elements(audit.before_batches) v where b.id=(v->>'id')::uuid and b.product_id=p.id;
 update inventory_products set stock=(item->>'stock')::numeric,cost=(item->>'cost')::numeric,expires_on=nullif(item->>'expires_on','')::date,version=version+1 where id=p.id;
 insert into inventory_movements(store_id,product_id,request_id,payload,before_stock,after_stock,document_id,cost) values(p_store,p.id,'void:'||d.id||':'||p.id,jsonb_build_object('kind','void','reason',p_data->>'reason'),p.stock,(item->>'stock')::numeric,d.id,0);
 end loop;
 update expense_entries set deleted=true,revision=revision+1,updated_at=now() where source_document=d.id and store_id=p_store;
 end if;
 update inventory_documents set status='void',void_reason=trim(p_data->>'reason'),voided_at=now(),revision=revision+1 where id=d.id returning to_jsonb(inventory_documents.*) into result;
 else raise exception 'invalid_action'; end if;
 insert into inventory_requests values(p_store,p_request,jsonb_build_object('action',p_action,'data',p_data),result);
 return result;
end $$;

alter function inventory_document_save(uuid,uuid,text,jsonb,integer,boolean) rename to inventory_document_save_base;
revoke all on function inventory_document_save_base(uuid,uuid,text,jsonb,integer,boolean) from service_role;
create function inventory_document_save(p_store uuid,p_id uuid,p_kind text,p_payload jsonb,p_revision integer,p_post boolean) returns jsonb language plpgsql security definer set search_path=public as $$
declare submitted jsonb:=p_payload; l jsonb; p inventory_products; before_p jsonb; before_b jsonb; versions jsonb; result jsonb; d inventory_documents; path text;
begin
 perform pg_advisory_xact_lock(hashtextextended('inventory:'||p_store::text,0));
 select * into d from inventory_documents where id=p_id;
 if found and d.store_id<>p_store then raise exception 'document_not_found'; end if;
 if d.status='void' then raise exception 'document_closed'; end if;
 if d.status='posted' then
 if p_post and coalesce(d.submitted_payload,d.payload)=p_payload and d.kind=p_kind then return to_jsonb(d); end if;
 raise exception 'document_closed'; end if;
 if p_kind<>'check' and exists(select 1 from inventory_documents where store_id=p_store and kind='check' and status='draft' and coalesce((payload->>'freeze')::boolean,false)) then raise exception 'count_locked'; end if;
 if nullif(p_payload->>'technician_id','') is not null and not exists(select 1 from appointment_resources where store_id=p_store and id=(p_payload->>'technician_id')::uuid and kind='technician' and active) then raise exception 'technician_not_found'; end if;
 if nullif(p_payload->>'order_id','') is not null and not exists(select 1 from orders where store_id=p_store and id=(p_payload->>'order_id')::uuid) then raise exception 'order_not_found'; end if;
 if nullif(p_payload->>'technician_id','') is not null then p_payload:=jsonb_set(p_payload,'{technician}',to_jsonb((select name from appointment_resources where id=(p_payload->>'technician_id')::uuid and store_id=p_store))); end if;
 if nullif(p_payload->>'order_id','') is not null then p_payload:=jsonb_set(p_payload,'{workorder}',to_jsonb((select coalesce(nullif(vehicle_plate,''),'工单')||' · '||left(id::text,8) from orders where id=(p_payload->>'order_id')::uuid and store_id=p_store))); end if;
 if p_kind='check' and exists(select 1 from inventory_documents where store_id=p_store and kind='check' and status='draft' and id<>p_id) then raise exception 'count_in_progress'; end if;
 for l in select value from jsonb_array_elements(p_payload->'lines') loop
 select * into p from inventory_products where store_id=p_store and id=(l->>'id')::uuid for update;
 if not found then raise exception 'product_not_found'; end if;
 if not p.active then raise exception 'product_disabled'; end if;
 if not p.allow_decimal and (l->>'quantity')::numeric<>trunc((l->>'quantity')::numeric) then raise exception 'integer_quantity'; end if;
 if p_post and p_kind='in' and p.shelf_life and coalesce(l->>'expires_on','')='' then raise exception 'expiry_required'; end if;
 end loop;
 if p_payload ? 'attachments' then
 if jsonb_typeof(p_payload->'attachments')<>'array' or jsonb_array_length(p_payload->'attachments')>6 then raise exception 'invalid_attachments'; end if;
 for path in select jsonb_array_elements_text(p_payload->'attachments') loop
 if path !~ ('^'||p_store::text||'/[0-9a-f-]+\.(png|jpg)$') or not exists(select 1 from storage.objects where bucket_id='expense-vouchers' and name=path) then raise exception 'invalid_attachments'; end if;
 end loop;
 end if;
 if p_post then
 select coalesce(jsonb_agg(to_jsonb(prod)),'[]') into before_p from inventory_products prod where store_id=p_store and id in(select (x->>'id')::uuid from jsonb_array_elements(p_payload->'lines') x);
 select coalesce(jsonb_agg(to_jsonb(b)),'[]') into before_b from inventory_batches b where store_id=p_store and product_id in(select (x->>'id')::uuid from jsonb_array_elements(p_payload->'lines') x);
 end if;
 if d.id is not null and d.kind='check' and d.payload ? 'product_ids' and coalesce(d.payload->'product_ids','[]')<>coalesce(p_payload->'product_ids','[]') then raise exception 'count_scope_changed'; end if;
 if p_kind='check' and p_payload ? 'product_ids' and exists(select 1 from jsonb_array_elements(p_payload->'lines') elem where not (p_payload->'product_ids' @> jsonb_build_array(elem->>'id'))) then raise exception 'count_scope_changed'; end if;
 result:=inventory_document_save_base(p_store,p_id,p_kind,p_payload,p_revision,p_post);
 if p_post then
 select jsonb_object_agg(id::text,version) into versions from inventory_products where store_id=p_store and id in(select (x->>'id')::uuid from jsonb_array_elements(p_payload->'lines') x);
 update expense_entries set attachments=coalesce(p_payload->'attachments','[]') where source_document=p_id and store_id=p_store;
 insert into inventory_document_audit values(p_id,p_store,before_p,before_b,versions);
 update inventory_documents set submitted_payload=submitted,payload=payload||jsonb_build_object('snapshots',before_p) where id=p_id returning to_jsonb(inventory_documents.*) into result;
 -- Replay checks must compare the original submitted input, not enriched historical snapshots.
 end if;
 return result;
end $$;
-- Preserve the exact request for retry checks separately from immutable display snapshots.
alter table inventory_documents add column submitted_payload jsonb;
create or replace function inventory_read(p_store uuid,p_id uuid default null) returns jsonb language sql stable security definer set search_path=public as $$
 select case when p_id is null then jsonb_build_object('items',coalesce(jsonb_agg(item order by item->>'name'),'[]'::jsonb)) else jsonb_build_object('item',(jsonb_agg(item))->0) end from (
 select to_jsonb(p)||jsonb_build_object(
 'month_used',(select coalesce(sum(m.before_stock-m.after_stock),0) from inventory_movements m left join inventory_documents doc on doc.id=m.document_id where m.product_id=p.id and m.store_id=p_store and m.after_stock<m.before_stock and coalesce(doc.status,'posted')='posted' and m.payload->>'kind'<>'void' and m.created_at>=date_trunc('month',now() at time zone 'Asia/Shanghai') at time zone 'Asia/Shanghai'),
 'stock_value',(select coalesce(sum(b.quantity*b.cost),0) from inventory_batches b where b.product_id=p.id and b.store_id=p_store),
 'low',p.active and coalesce(s.low_enabled,true) and p.stock<p.safe,
 'expiring',p.active and coalesce(s.expiry_enabled,true) and exists(select 1 from inventory_batches b where b.product_id=p.id and b.store_id=p_store and b.quantity>0 and b.expires_on<=(now() at time zone 'Asia/Shanghai')::date+coalesce(p.expiry_days,s.expiry_days,30)),
 'batches',case when p_id is not null then (select coalesce(jsonb_agg(to_jsonb(b) order by received_on,created_at,id),'[]') from inventory_batches b where b.product_id=p.id and b.store_id=p_store and quantity>0) else '[]'::jsonb end,
 'movements',case when p_id is not null then (select coalesce(jsonb_agg(to_jsonb(m) order by created_at desc,id),'[]') from inventory_movements m where m.product_id=p.id and m.store_id=p_store) else '[]'::jsonb end) item
 from inventory_products p left join inventory_settings s on s.store_id=p.store_id where p.store_id=p_store and (p_id is null or p.id=p_id)) rows;
$$;
create function inventory_documents_read(p_store uuid,p_id uuid default null) returns jsonb language sql stable security definer set search_path=public as $$
 select case when p_id is null then jsonb_build_object('items',coalesce(jsonb_agg(to_jsonb(d) order by created_at desc,id),'[]')) else jsonb_build_object('item',(jsonb_agg(to_jsonb(d)||jsonb_build_object('movements',(select coalesce(jsonb_agg(to_jsonb(m) order by m.id),'[]') from inventory_movements m where document_id=d.id and store_id=p_store),'can_void',d.status='draft' or (d.status='posted' and exists(select 1 from inventory_document_audit a where a.document_id=d.id and not exists(select 1 from jsonb_each_text(a.after_versions) v join inventory_products p on p.id=v.key::uuid where p.version<>v.value::integer or not p.active))),'expense',(select to_jsonb(e) from expense_entries e where source_document=d.id and store_id=p_store))))->0) end from inventory_documents d where store_id=p_store and (p_id is null or id=p_id);
$$;
revoke all on function inventory_options(uuid),inventory_mutate(uuid,text,text,jsonb),inventory_document_save(uuid,uuid,text,jsonb,integer,boolean),inventory_documents_read(uuid,uuid) from public,anon,authenticated;
grant execute on function inventory_options(uuid),inventory_mutate(uuid,text,text,jsonb),inventory_document_save(uuid,uuid,text,jsonb,integer,boolean),inventory_documents_read(uuid,uuid) to service_role;
