-- Inventory documents are committed atomically. Browser roles have no write privileges.
alter table public.inventory_products alter column stock type numeric(14,3), alter column safe type numeric(14,3);
alter table public.inventory_movements alter column before_stock type numeric(14,3), alter column after_stock type numeric(14,3);
alter table public.inventory_products add column sku text not null default '', add column specification text not null default '', add column location text not null default '', add column supplier text not null default '';
create table public.inventory_documents (
 id uuid primary key, store_id uuid not null references public.stores(id),
 kind text not null check(kind in ('in','out','check')),
 status text not null default 'draft' check(status in ('draft','posted')),
 revision integer not null default 0,
 payload jsonb not null, total numeric(16,2),
 created_at timestamptz not null default now(), posted_at timestamptz
);
create table public.inventory_batches (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id),
 product_id uuid not null references public.inventory_products(id),
 document_id uuid references public.inventory_documents(id),
 quantity numeric(14,3) not null check(quantity>=0), cost numeric(14,2) not null check(cost>=0),
 expires_on date, received_on date not null default current_date,
 created_at timestamptz not null default now()
);
alter table public.inventory_movements add column document_id uuid references public.inventory_documents(id), add column cost numeric(16,2) not null default 0;
insert into public.inventory_batches(store_id,product_id,quantity,cost,expires_on)
 select store_id,id,stock,cost,expires_on from public.inventory_products where stock>0;
create index inventory_batches_fifo on public.inventory_batches(store_id,product_id,received_on,created_at,id);
create index inventory_movement_history on public.inventory_movements(store_id,product_id,created_at desc);
do $$ declare t text; begin
 foreach t in array array['inventory_documents','inventory_batches'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('create policy %I on public.%I for select to authenticated using (exists (select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())))',t||'_owner',t);
 execute format('revoke all on public.%I from public,anon,authenticated',t);
 execute format('grant select on public.%I to authenticated',t);
 execute format('grant all on public.%I to service_role',t);
 end loop;
end $$;

create function public.inventory_document_save(p_store uuid,p_id uuid,p_kind text,p_payload jsonb,p_revision integer,p_post boolean) returns jsonb
language plpgsql security definer set search_path=public as $$
declare d inventory_documents; p inventory_products; b inventory_batches; l jsonb;
 q numeric; n numeric; delta numeric; remaining numeric; take numeric; line_cost numeric; total_cost numeric:=0; unit_cost numeric;
begin
 perform pg_advisory_xact_lock(hashtextextended(p_store::text||p_id::text,0));
 select * into d from inventory_documents where id=p_id for update;
 if found then
   if d.store_id<>p_store or d.kind<>p_kind then raise exception 'document_not_found'; end if;
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
revoke all on function public.inventory_document_save(uuid,uuid,text,jsonb,integer,boolean) from public,anon,authenticated;
grant execute on function public.inventory_document_save(uuid,uuid,text,jsonb,integer,boolean) to service_role;
-- Superseded single-item mutation cannot bypass FIFO.
revoke execute on function public.inventory_move(uuid,text,jsonb) from service_role;

create function public.inventory_read(p_store uuid,p_id uuid default null) returns jsonb
language sql stable security definer set search_path=public as $$
 select case when p_id is null then jsonb_build_object('items',coalesce(jsonb_agg(to_jsonb(p)||jsonb_build_object(
   'stock_value',(select coalesce(sum(b.quantity*b.cost),0) from inventory_batches b where b.product_id=p.id),
   'expiring',(select exists(select 1 from inventory_batches b where b.product_id=p.id and b.quantity>0 and b.expires_on between (now() at time zone 'Asia/Shanghai')::date and (now() at time zone 'Asia/Shanghai')::date+30))
 ) order by p.name),'[]'::jsonb)) else jsonb_build_object('item',(jsonb_agg(to_jsonb(p)||jsonb_build_object(
   'batches',(select coalesce(jsonb_agg(to_jsonb(b) order by b.received_on,b.created_at,b.id),'[]'::jsonb) from inventory_batches b where b.product_id=p.id and b.quantity>0),
   'movements',(select coalesce(jsonb_agg(to_jsonb(m) order by m.created_at desc,m.id),'[]'::jsonb) from inventory_movements m where m.product_id=p.id)
 )))->0) end from inventory_products p where p.store_id=p_store and (p_id is null or p.id=p_id);
$$;
revoke all on function public.inventory_read(uuid,uuid) from public,anon,authenticated;
grant execute on function public.inventory_read(uuid,uuid) to service_role;

create function public.inventory_quote(p_store uuid,p_kind text,p_payload jsonb) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare l jsonb; p inventory_products; q numeric; delta numeric; amount numeric; total numeric:=0; items jsonb:='{}';
begin
 for l in select value from jsonb_array_elements(p_payload->'lines') loop
   select * into p from inventory_products where store_id=p_store and id=(l->>'id')::uuid;
   if not found then raise exception 'product_not_found'; end if;
   q:=(l->>'quantity')::numeric;
   delta:=case p_kind when 'in' then q when 'out' then -q else q-p.stock end;
   if delta>=0 then amount:=delta*case when p_kind='in' then (l->>'cost')::numeric else p.cost end;
   else
     if -delta>p.stock then raise exception 'insufficient_stock'; end if;
     select coalesce(sum(greatest(0,least(quantity,-delta-used))*cost),0) into amount from (
       select quantity,cost,coalesce(sum(quantity) over(order by received_on,created_at,id rows between unbounded preceding and 1 preceding),0) used
       from inventory_batches where product_id=p.id and quantity>0
     ) batches;
     if p_kind='check' then amount:=-amount; end if;
   end if;
   items:=items||jsonb_build_object(p.id::text,round(amount,2)); total:=total+round(amount,2);
 end loop;
 return jsonb_build_object('subtotal',round(total,2),'total',round(total+case when p_kind='in' then coalesce((p_payload->>'freight')::numeric,0) else 0 end,2),'lines',items);
end $$;
revoke all on function public.inventory_quote(uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.inventory_quote(uuid,text,jsonb) to service_role;
