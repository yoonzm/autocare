alter table public.inventory_products drop constraint inventory_products_category_check;
alter table public.inventory_products add constraint inventory_products_category_check check(category in ('洗护','清洁用品','镀晶','贴膜','配件','工具','其他'));
alter table public.inventory_products add column active boolean not null default true,
 add column allow_decimal boolean not null default true,
 add column manage_expiry boolean not null default false;
update public.inventory_products set sku='SKU-'||replace(id::text,'-','') where trim(sku)='';
create unique index inventory_product_sku on public.inventory_products(store_id,sku) where sku<>'';
create table public.inventory_suppliers (
 id uuid primary key, store_id uuid not null references public.stores(id),
 name text not null check(length(trim(name)) between 1 and 120),
 contact text not null default '', phone text not null default '', note text not null default '',
 created_at timestamptz not null default now(), unique(store_id,name)
);
alter table public.inventory_suppliers enable row level security;
create policy supplier_owner on public.inventory_suppliers for select to authenticated using(exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())));
revoke all on public.inventory_suppliers from public,anon,authenticated;
grant select on public.inventory_suppliers to authenticated;
grant all on public.inventory_suppliers to service_role;
-- Enforce product settings inside the same transaction as stock changes.
create function public.inventory_validate_settings() returns trigger language plpgsql set search_path=public as $$
declare l jsonb; p inventory_products;
begin
 for l in select value from jsonb_array_elements(new.payload->'lines') order by value->>'id' loop
  select * into p from inventory_products where id=(l->>'id')::uuid and store_id=new.store_id for update;
  if not found then raise exception 'product_not_found'; end if;
  if not p.active then raise exception 'product_disabled'; end if;
  if not p.allow_decimal and (l->>'quantity')::numeric<>trunc((l->>'quantity')::numeric) then raise exception 'integer_required'; end if;
  if new.kind='in' and p.manage_expiry and nullif(l->>'expires_on','') is null then raise exception 'expiry_required'; end if;
 end loop;
 return new;
end $$;
create trigger inventory_settings before insert or update of payload on public.inventory_documents for each row execute function public.inventory_validate_settings();

alter table public.inventory_documents drop constraint inventory_documents_status_check;
alter table public.inventory_documents add constraint inventory_documents_status_check check(status in ('draft','posted','void'));
create or replace function public.inventory_document_save(p_store uuid,p_id uuid,p_kind text,p_payload jsonb,p_revision integer,p_post boolean) returns jsonb
language plpgsql security definer set search_path=public as $$
declare d inventory_documents; p inventory_products; b inventory_batches; l jsonb;
 q numeric; n numeric; delta numeric; remaining numeric; take numeric; line_cost numeric; total_cost numeric:=0; unit_cost numeric;
begin
 perform pg_advisory_xact_lock(hashtextextended(p_store::text||p_id::text,0));
 select * into d from inventory_documents where id=p_id for update;
 if found then
   if d.store_id<>p_store or d.kind<>p_kind then raise exception 'document_not_found'; end if;
   if d.status='void' then raise exception 'document_closed'; end if;
   if d.status='posted' then
     if p_post and d.payload=p_payload then return to_jsonb(d); end if;
     raise exception 'document_closed';
   end if;
   if not p_post and d.payload=p_payload then return to_jsonb(d); end if;
   if d.revision<>p_revision then raise exception 'document_changed'; end if;
 end if;
 if p_kind not in ('in','out','check') or jsonb_typeof(p_payload->'lines') is distinct from 'array'
 or jsonb_array_length(p_payload->'lines')>200 then raise exception 'invalid_document'; end if;
 if p_post and jsonb_array_length(p_payload->'lines')=0 then raise exception 'empty_document'; end if;
 if (select count(*)<>count(distinct x->>'id') from jsonb_array_elements(p_payload->'lines') x) then raise exception 'duplicate_product'; end if;
 if p_kind='in' and p_post and coalesce(trim(p_payload->>'supplier'),'')='' then raise exception 'supplier_required'; end if;
 if coalesce((p_payload->>'freight')::numeric,0)<0 then raise exception 'invalid_amount'; end if;
 insert into inventory_documents(id,store_id,kind,payload) values(p_id,p_store,p_kind,p_payload)
 on conflict(id) do update set payload=excluded.payload,revision=inventory_documents.revision+1 returning * into d;
 -- Lock products in stable order to prevent opposite multi-line documents deadlocking.
 for l in select value from jsonb_array_elements(p_payload->'lines') order by value->>'id' loop
   select * into p from inventory_products where store_id=p_store and id=(l->>'id')::uuid for update;
   if not found then raise exception 'product_not_found'; end if;
   q:=(l->>'quantity')::numeric;
   if q is null or q<0 or q>999999999 or q<>round(q,3) or (p_kind<>'check' and q=0) then raise exception 'invalid_quantity'; end if;
   if not p_post then continue; end if;
   if p_kind='check' and (l->>'version')::integer is distinct from p.version then raise exception 'stock_changed'; end if;
   n:=case p_kind when 'in' then p.stock+q when 'out' then p.stock-q else q end;
   if n<0 then raise exception 'insufficient_stock'; end if;
   delta:=n-p.stock; line_cost:=0;
   if delta>0 then
     unit_cost:=case when p_kind='in' then (l->>'cost')::numeric else p.cost end;
     if unit_cost is null or unit_cost<0 or unit_cost>999999999 or unit_cost<>round(unit_cost,2) then raise exception 'invalid_amount'; end if;
     insert into inventory_batches(store_id,product_id,document_id,quantity,cost,expires_on,received_on)
       values(p_store,p.id,p_id,delta,unit_cost,nullif(l->>'expires_on','')::date,coalesce(nullif(p_payload->>'date','')::date,current_date));
     line_cost:=delta*unit_cost;
   elsif delta<0 then
     remaining:=-delta;
     for b in select * from inventory_batches where store_id=p_store and product_id=p.id and quantity>0 order by received_on,created_at,id for update loop
       take:=least(remaining,b.quantity);
       update inventory_batches set quantity=quantity-take where id=b.id;
       line_cost:=line_cost+take*b.cost; remaining:=remaining-take;
       exit when remaining=0;
     end loop;
     if remaining<>0 then raise exception 'batch_mismatch'; end if;
   end if;
   update inventory_products set stock=n,version=version+1,
     cost=coalesce((select sum(quantity*cost)/nullif(sum(quantity),0) from inventory_batches where product_id=p.id and quantity>0),p.cost),
     expires_on=(select min(expires_on) from inventory_batches where product_id=p.id and quantity>0),
     supplier=case when p_kind='in' then p_payload->>'supplier' else supplier end where id=p.id;
   insert into inventory_movements(store_id,product_id,request_id,payload,before_stock,after_stock,document_id,cost)
     values(p_store,p.id,p_id::text||':'||p.id::text,p_payload||jsonb_build_object('kind',p_kind),p.stock,n,p_id,round(line_cost,2));
   total_cost:=total_cost+case when p_kind='check' and delta<0 then -round(line_cost,2) else round(line_cost,2) end;
 end loop;
 if p_post then
   update inventory_documents set status='posted',posted_at=now(),total=round(total_cost+case when p_kind='in' then coalesce((p_payload->>'freight')::numeric,0) else 0 end,2) where id=p_id returning * into d;
 end if;
 return to_jsonb(d);
end $$;
