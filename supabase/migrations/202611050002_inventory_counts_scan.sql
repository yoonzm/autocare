alter table public.inventory_products add column barcode text not null default '' check(length(barcode)<=120);
create unique index inventory_barcode_unique on public.inventory_products(store_id,barcode) where barcode<>'';
create table public.inventory_counts (
 id uuid primary key, store_id uuid not null references stores(id),
 status text not null default 'active' check(status in ('active','posted','void')),
 scope text not null, scope_value text not null default '', blind boolean not null, pause_movements boolean not null,
 revision integer not null default 0, snapshot jsonb not null, result jsonb,
 created_at timestamptz not null default now(), posted_at timestamptz
);
create unique index inventory_one_active_count on public.inventory_counts(store_id) where status='active';
alter table public.inventory_counts enable row level security;
-- Snapshot contains blind-count quantities: no direct client SELECT grant.
revoke all on public.inventory_counts from public,anon,authenticated;
grant all on public.inventory_counts to service_role;
create or replace function public.inventory_document_save_core(p_store uuid,p_id uuid,p_kind text,p_payload jsonb,p_revision integer,p_post boolean) returns jsonb
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
 or jsonb_array_length(p_payload->'lines')>5000 then raise exception 'invalid_document'; end if;
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

revoke all on function public.inventory_document_save_core(uuid,uuid,text,jsonb,integer,boolean) from public,anon,authenticated,service_role;
create or replace function public.inventory_document_save(p_store uuid,p_id uuid,p_kind text,p_payload jsonb,p_revision integer,p_post boolean) returns jsonb
language plpgsql security definer set search_path=public as $$
begin
 perform pg_advisory_xact_lock(hashtextextended('inventory-count:'||p_store::text,0));
 if exists(select 1 from inventory_counts where id=p_id) and coalesce(current_setting('app.inventory_count',true),'')<>p_id::text then raise exception 'count_workflow_required'; end if;
 if p_post and exists(select 1 from inventory_counts where store_id=p_store and status='active' and (pause_movements or p_kind='check') and id<>p_id) then raise exception 'inventory_frozen'; end if;
 return inventory_document_save_core(p_store,p_id,p_kind,p_payload,p_revision,p_post);
end $$;
create function public.inventory_count_view(c public.inventory_counts, reveal boolean default false) returns jsonb
language sql stable set search_path=public as $$
 select (to_jsonb(c)-'snapshot') || jsonb_build_object('lines',coalesce((select jsonb_agg(case when c.blind and not reveal and c.status='active' then l-'stock'-'version'-'cost' else l end) from jsonb_array_elements(c.snapshot) l),'[]'::jsonb));
$$;
revoke all on function public.inventory_count_view(public.inventory_counts,boolean) from public,anon,authenticated;

create function public.inventory_count_action(p_store uuid,p_action text,p_id uuid,p_input jsonb default '{}') returns jsonb
language plpgsql security definer set search_path=public as $$
#variable_conflict use_variable
declare c inventory_counts; l jsonb; p inventory_products; snapshot jsonb; submitted jsonb; q numeric; result jsonb; quoted jsonb; positive numeric:=0; negative numeric:=0; differences jsonb:='[]'; item jsonb;
begin
 perform pg_advisory_xact_lock(hashtextextended('inventory-count:'||p_store::text,0));
 if p_action='start' then
  select * into c from inventory_counts where id=p_id;
  if found then
   if c.store_id<>p_store then raise exception 'count_not_found'; end if;
   return inventory_count_view(c);
  end if;
  if exists(select 1 from inventory_documents d where d.store_id=p_store and d.kind='check' and d.status='draft' and not exists(select 1 from inventory_counts c where c.id=d.id)) then raise exception 'legacy_count_pending'; end if;
  if exists(select 1 from inventory_documents where id=p_id) then raise exception 'count_id_reused'; end if;
  if exists(select 1 from inventory_counts where store_id=p_store and status='active') then raise exception 'count_exists'; end if;
  if coalesce(p_input->>'scope','') not in ('all','category','location') or jsonb_typeof(p_input->'blind') is distinct from 'boolean' or jsonb_typeof(p_input->'freeze') is distinct from 'boolean' then raise exception 'invalid_scope'; end if;
  select coalesce(jsonb_agg(jsonb_build_object('id',id,'name',name,'unit',unit,'location',location,'category',category,'stock',stock,'version',version,'cost',cost,'allow_decimal',allow_decimal,'quantity',null) order by name,id),'[]') into snapshot from inventory_products where store_id=p_store and active and (p_input->>'scope'='all' or (p_input->>'scope'='category' and category=p_input->>'value') or (p_input->>'scope'='location' and location=p_input->>'value'));
  if jsonb_array_length(snapshot)=0 or jsonb_array_length(snapshot)>5000 then raise exception 'invalid_scope'; end if;
  insert into inventory_counts(id,store_id,scope,scope_value,blind,pause_movements,snapshot) values(p_id,p_store,p_input->>'scope',coalesce(p_input->>'value',''),(p_input->>'blind')::boolean,(p_input->>'freeze')::boolean,snapshot) returning * into c;
  return inventory_count_view(c);
 end if;
 select * into c from inventory_counts where id=p_id and store_id=p_store for update;
 if not found then raise exception 'count_not_found'; end if;
 if p_action='get' then return inventory_count_view(c); end if;
 if p_action='post' and c.status='posted' then return inventory_count_view(c,true); end if;
 if p_action='cancel' and c.status='void' then return inventory_count_view(c); end if;
 if c.status<>'active' then raise exception 'count_closed'; end if;
 if p_action='save' and jsonb_typeof(p_input->'lines')='array' and
  (select jsonb_agg(jsonb_build_object('id',x.value->>'id','quantity',x.value->'quantity') order by x.value->>'id') from jsonb_array_elements(p_input->'lines') as x(value)) =
  (select jsonb_agg(jsonb_build_object('id',x.value->>'id','quantity',x.value->'quantity') order by x.value->>'id') from jsonb_array_elements(c.snapshot) as x(value)) then return inventory_count_view(c); end if;
 if (p_input->>'revision')::integer is distinct from c.revision then raise exception 'count_changed'; end if;
 if p_action='save' then
  submitted:=p_input->'lines';
  if jsonb_typeof(submitted) is distinct from 'array' or jsonb_array_length(submitted)<>jsonb_array_length(c.snapshot) or (select count(*)<>count(distinct x.value->>'id') from jsonb_array_elements(submitted) as x(value)) then raise exception 'invalid_lines'; end if;
  snapshot:='[]';
  for l in select value from jsonb_array_elements(c.snapshot) loop
   select value into item from jsonb_array_elements(submitted) where value->>'id'=l->>'id';
   if item is null or not item ? 'quantity' then raise exception 'invalid_lines'; end if;
   if item->'quantity'<>'null'::jsonb then
    if jsonb_typeof(item->'quantity')<>'number' then raise exception 'invalid_quantity'; end if;
    q:=(item->>'quantity')::numeric;
    if q<0 or q>999999999 or q<>round(q,3) or (not (l->>'allow_decimal')::boolean and q<>trunc(q)) then raise exception 'invalid_quantity'; end if;
   end if;
   snapshot:=snapshot||jsonb_build_array(l||jsonb_build_object('quantity',item->'quantity'));
  end loop;
  if snapshot<>c.snapshot then update inventory_counts set snapshot=snapshot,revision=revision+1 where id=c.id returning * into c; end if;
  return inventory_count_view(c);
 end if;
 if p_action='rebase' then
  snapshot:='[]';
  for l in select value from jsonb_array_elements(c.snapshot) order by value->>'id' loop
   select * into p from inventory_products where id=(l->>'id')::uuid and store_id=p_store for update;
   if not found or not p.active then raise exception 'product_disabled'; end if;
   if (l->>'version')::integer<>p.version then l:=l||jsonb_build_object('stock',p.stock,'cost',p.cost,'version',p.version,'quantity',null); end if;
   snapshot:=snapshot||jsonb_build_array(l);
  end loop;
  update inventory_counts set snapshot=snapshot,revision=revision+1 where id=c.id returning * into c;
  return inventory_count_view(c);
 end if;
 if p_action='cancel' then
  update inventory_counts set status='void',revision=revision+1 where id=c.id returning * into c;
  return inventory_count_view(c);
 end if;
 if p_action not in ('review','post') then raise exception 'invalid_action'; end if;
 submitted:='[]';
 for l in select value from jsonb_array_elements(c.snapshot) where value->'quantity'<>'null'::jsonb order by value->>'id' loop
  select * into p from inventory_products where id=(l->>'id')::uuid and store_id=p_store for update;
  if not found or not p.active then raise exception 'product_disabled'; end if;
  if p.version<>(l->>'version')::integer then raise exception 'stock_changed'; end if;
  submitted:=submitted||jsonb_build_array(l);
 end loop;
 if jsonb_array_length(submitted)=0 then raise exception 'empty_count'; end if;
 quoted:=inventory_quote(p_store,'check',jsonb_build_object('lines',submitted));
 for l in select value from jsonb_array_elements(submitted) loop
  q:=(l->>'quantity')::numeric-(l->>'stock')::numeric;
  if q<>0 then
   item:=l||jsonb_build_object('difference',q,'amount',quoted->'lines'->(l->>'id'));
   differences:=differences||jsonb_build_array(item);
   if q>0 then positive:=positive+(item->>'amount')::numeric; else negative:=negative+(item->>'amount')::numeric; end if;
  end if;
 end loop;
 result:=jsonb_build_object('counted',jsonb_array_length(submitted),'total',jsonb_array_length(c.snapshot),'differences',differences,'positive',positive,'negative',negative,'net',positive+negative);
 if p_action='review' then return inventory_count_view(c,true)||jsonb_build_object('result',result); end if;
 perform set_config('app.inventory_count',p_id::text,true);
 perform inventory_document_save(p_store,c.id,'check',jsonb_build_object('lines',submitted,'date',(now() at time zone 'Asia/Shanghai')::date::text,'scope',c.scope,'scope_value',c.scope_value),0,true);
 update inventory_counts set status='posted',posted_at=now(),result=result,revision=revision+1 where id=c.id returning * into c;
 return inventory_count_view(c,true);
end $$;
revoke all on function public.inventory_count_action(uuid,text,uuid,jsonb) from public,anon,authenticated;
grant execute on function public.inventory_count_action(uuid,text,uuid,jsonb) to service_role;
-- Preserve visibility of documents created before count sessions were introduced.
create function public.inventory_count_list(p_store uuid,p_page integer default 0) returns jsonb
language sql stable security definer set search_path=public as $$
 with rows as (
  select c.id,c.status,c.scope,c.scope_value,c.created_at,c.result,
   jsonb_array_length(c.snapshot) as total,
   (select count(*) from jsonb_array_elements(c.snapshot) x where x->'quantity'<>'null'::jsonb) as counted,false as legacy
  from inventory_counts c where c.store_id=p_store
  union all
  select d.id,case d.status when 'draft' then 'active' else d.status end,
   coalesce(d.payload->>'scope','all'),coalesce(d.payload->>'scope_value',''),d.created_at,
   case when d.status='posted' then jsonb_build_object('net',d.total) else null end,
   jsonb_array_length(d.payload->'lines'),jsonb_array_length(d.payload->'lines'),true
  from inventory_documents d where d.store_id=p_store and d.kind='check' and not exists(select 1 from inventory_counts c where c.id=d.id)
 )
 select jsonb_build_object('active',coalesce((select jsonb_agg(to_jsonb(r) order by created_at desc,id) from rows r where status='active'),'[]'),
 'items',coalesce((select jsonb_agg(to_jsonb(r)) from (select * from rows where status<>'active' order by created_at desc,id limit 20 offset greatest(0,p_page)*20) r),'[]'));
$$;
revoke all on function public.inventory_count_list(uuid,integer) from public,anon,authenticated;
grant execute on function public.inventory_count_list(uuid,integer) to service_role;
