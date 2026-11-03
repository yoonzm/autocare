create table public.inventory_products (
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id) on delete cascade,
 name text not null check(length(trim(name)) between 1 and 120),
 category text not null check(category in ('洗护','镀晶','贴膜','配件')),
 unit text not null check(length(trim(unit)) between 1 and 12),
 stock integer not null default 0 check(stock>=0),
 safe integer not null default 0 check(safe>=0),
 cost numeric(14,2) not null default 0 check(cost>=0),
 expires_on date,
 version integer not null default 0,
 unique(store_id,name)
);
create table public.inventory_movements (
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id),
 product_id uuid not null references public.inventory_products(id),
 request_id text not null,
 payload jsonb not null,
 before_stock integer not null,
 after_stock integer not null,
 created_at timestamptz not null default now(),
 unique(store_id,request_id)
);
do $$ declare t text; begin
 foreach t in array array['inventory_products','inventory_movements'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('create policy %I on public.%I for select to authenticated using (exists (select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())))',t||'_owner',t);
 execute format('revoke all on public.%I from public,anon,authenticated',t);
 execute format('grant select on public.%I to authenticated',t);
 execute format('grant all on public.%I to service_role',t);
 end loop;
end $$;
create function public.inventory_move(p_store uuid,p_request text,p_payload jsonb) returns jsonb
language plpgsql security definer set search_path=public as $$
declare p inventory_products; m inventory_movements; n integer; q integer; k text;
begin
 if p_request is null or length(p_request) not between 1 and 100 then raise exception 'invalid_request'; end if;
 perform pg_advisory_xact_lock(hashtextextended(p_store::text||p_request,0));
 select * into m from inventory_movements where store_id=p_store and request_id=p_request;
 if found then
 if m.payload<>p_payload then raise exception 'request_reused'; end if;
 return to_jsonb(m);
 end if;
 select * into p from inventory_products where store_id=p_store and id=(p_payload->>'id')::uuid for update;
 if not found then raise exception 'product_not_found'; end if;
 q:=(p_payload->>'quantity')::integer; k:=p_payload->>'kind';
 if q is null or q<0 or k is null or k not in ('in','out','check') or (k<>'check' and q=0) then raise exception 'invalid_quantity'; end if;
 if k='check' and (p_payload->>'version')::integer is distinct from p.version then raise exception 'stock_changed'; end if;
 n:=case k when 'in' then p.stock+q when 'out' then p.stock-q else q end;
 if n<0 then raise exception 'insufficient_stock'; end if;
 update inventory_products set stock=n,version=version+1 where id=p.id;
 insert into inventory_movements(store_id,product_id,request_id,payload,before_stock,after_stock)
 values(p_store,p.id,p_request,p_payload,p.stock,n) returning * into m;
 return to_jsonb(m);
end $$;
revoke all on function public.inventory_move(uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.inventory_move(uuid,text,jsonb) to service_role;
