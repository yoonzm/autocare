create table public.expense_entries (
 id uuid primary key, store_id uuid not null references public.stores(id),
 amount numeric(14,2) not null check(amount>0),
 category text not null check(category in ('房租','水电','人工','材料采购','设备维修','营销推广','税费','其他','损耗')),
 occurred_on date not null, account text not null check(account in ('现金','微信','支付宝','对公转账','其他')),
 payee text not null default '', status text not null check(status in ('paid','unpaid')),
 note text not null default '', attachments jsonb not null default '[]',
 operator text not null default '店长', source_document uuid unique references public.inventory_documents(id),
 recurrence_id uuid, revision integer not null default 0, deleted boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(recurrence_id,occurred_on), check(length(payee)<=120 and length(note)<=1000)
);
create index expense_store_date on public.expense_entries(store_id,occurred_on desc) where not deleted;
create table public.expense_recurring (
 id uuid primary key references public.expense_entries(id), store_id uuid not null references public.stores(id),
 template jsonb not null, next_month date not null, active boolean not null default true
);
create table public.expense_budgets (
 store_id uuid not null references public.stores(id), month date not null,
 total numeric(14,2) not null default 0 check(total>=0), categories jsonb not null default '{}',
 carry boolean not null default false, remind boolean not null default true,
 revision integer not null default 0, primary key(store_id,month),check(extract(day from month)=1)
);
create table public.expense_requests (
 store_id uuid not null references public.stores(id), request_id text not null, payload jsonb not null, result jsonb not null,
 primary key(store_id,request_id)
);
do $$ declare t text; begin
 foreach t in array array['expense_entries','expense_recurring','expense_budgets','expense_requests'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('revoke all on public.%I from public,anon,authenticated',t);
 execute format('grant all on public.%I to service_role',t);
 if t<>'expense_requests' then
 execute format('create policy %I on public.%I for select to authenticated using (exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())))',t||'_owner',t);
 execute format('grant select on public.%I to authenticated',t);
 end if;
 end loop;
end $$;

create function public.expense_materialize(p_store uuid) returns void language plpgsql security definer set search_path=public as $$
declare r expense_recurring; d date; today date:=(now() at time zone 'Asia/Shanghai')::date; b expense_budgets; cats jsonb; k text; v jsonb; used numeric; rollover_total numeric;
begin
 perform pg_advisory_xact_lock(hashtextextended('expense:'||p_store::text,0));
 for r in select * from expense_recurring where store_id=p_store and active for update loop
   while r.next_month<=today loop
     d:=least((r.next_month + ((r.template->>'day')::integer-1))::date,(r.next_month+interval '1 month -1 day')::date);
     exit when d>today;
     insert into expense_entries(id,store_id,amount,category,occurred_on,account,payee,status,note,recurrence_id)
       values(gen_random_uuid(),p_store,(r.template->>'amount')::numeric,r.template->>'category',d,r.template->>'account',r.template->>'payee','unpaid',r.template->>'note',r.id)
       on conflict(recurrence_id,occurred_on) do nothing;
     r.next_month:=(r.next_month+interval '1 month')::date;
   end loop;
   update expense_recurring set next_month=r.next_month where id=r.id;
 end loop;
 select * into b from expense_budgets where store_id=p_store and month<=date_trunc('month',today)::date order by month desc limit 1;
 while b.month<date_trunc('month',today)::date and (b.carry or exists(select 1 from jsonb_each(b.categories) e where coalesce((e.value->>'repeat')::boolean,false))) loop
   cats:='{}'; rollover_total:=0;
   for k,v in select * from jsonb_each(b.categories) loop
     if b.carry or coalesce((v->>'repeat')::boolean,false) then
       used:=0;
       if coalesce((v->>'rollover')::boolean,false) then
         select greatest(0,(v->>'amount')::numeric-coalesce(sum(amount),0)) into used from expense_entries where store_id=p_store and not deleted and category=k and occurred_on>=b.month and occurred_on<(b.month+interval '1 month');
       end if;
       cats:=cats||jsonb_build_object(k,v||jsonb_build_object('amount',(v->>'amount')::numeric+used));
       rollover_total:=rollover_total+used;
     end if;
   end loop;
   insert into expense_budgets(store_id,month,total,categories,carry,remind)
     values(p_store,(b.month+interval '1 month')::date,case when b.carry then b.total+rollover_total else (select coalesce(sum((value->>'amount')::numeric),0) from jsonb_each(cats)) end,cats,b.carry,b.remind)
     on conflict do nothing;
   select * into b from expense_budgets where store_id=p_store and month=(b.month+interval '1 month')::date;
 end loop;
end $$;

create function public.expense_write(p_store uuid,p_request text,p_action text,p_data jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare cached expense_requests; e expense_entries; b expense_budgets; result jsonb; month_day date; k text; v jsonb; allocated numeric; used numeric; amount numeric; source text; cats jsonb; original jsonb;
begin
 if p_request is null or length(p_request) not between 1 and 100 then raise exception 'invalid_request'; end if;
 perform expense_materialize(p_store);
 select * into cached from expense_requests where store_id=p_store and request_id=p_request;
 if found then if cached.payload<>jsonb_build_object('action',p_action,'data',p_data) then raise exception 'request_reused'; end if; return cached.result; end if;
 if p_action in ('save','delete') then
   select * into e from expense_entries where id=(p_data->>'id')::uuid for update;
   if found then
     if e.store_id<>p_store or e.deleted then raise exception 'expense_not_found'; end if;
     if e.revision is distinct from (p_data->>'revision')::integer then raise exception 'expense_changed'; end if;
   elsif p_action='delete' or coalesce((p_data->>'revision')::integer,0)<>0 then raise exception 'expense_not_found'; end if;
   if p_action='delete' then
     if e.source_document is not null then raise exception 'source_locked'; end if;
     update expense_entries set deleted=true,revision=revision+1,updated_at=now() where id=e.id returning to_jsonb(expense_entries.*) into result;
     update expense_recurring set active=false where id=coalesce(e.recurrence_id,e.id);
   else
     if e.source_document is not null and coalesce((p_data->>'repeat')::boolean,false) then raise exception 'source_locked'; end if;
     if e.source_document is not null and ((p_data->>'amount')::numeric<>e.amount or p_data->>'category'<>e.category or (p_data->>'occurred_on')::date<>e.occurred_on) then raise exception 'source_locked'; end if;
     amount:=(p_data->>'amount')::numeric;
     if amount is null or amount<=0 or amount>999999999 or amount<>round(amount,2) then raise exception 'invalid_amount'; end if;
     month_day:=date_trunc('month',(p_data->>'occurred_on')::date)::date;
     select * into b from expense_budgets where store_id=p_store and month=month_day;
     v:=b.categories->(p_data->>'category');
     select coalesce(sum(ee.amount),0) into used from expense_entries ee where store_id=p_store and not deleted and category=p_data->>'category' and occurred_on>=month_day and occurred_on<month_day+interval '1 month' and id<>(p_data->>'id')::uuid;
     if v->>'policy'='block' and used+amount>(v->>'amount')::numeric then raise exception 'budget_exceeded'; end if;
     insert into expense_entries(id,store_id,amount,category,occurred_on,account,payee,status,note,attachments)
       values((p_data->>'id')::uuid,p_store,amount,p_data->>'category',(p_data->>'occurred_on')::date,p_data->>'account',coalesce(p_data->>'payee',''),p_data->>'status',coalesce(p_data->>'note',''),coalesce(p_data->'attachments','[]'))
       on conflict(id) do update set amount=excluded.amount,category=excluded.category,occurred_on=excluded.occurred_on,account=excluded.account,payee=excluded.payee,status=excluded.status,note=excluded.note,attachments=excluded.attachments,revision=expense_entries.revision+1,updated_at=now()
       returning to_jsonb(expense_entries.*) into result;
     if coalesce((p_data->>'repeat')::boolean,false) and e.source_document is null then
       insert into expense_recurring(id,store_id,template,next_month) values(coalesce(e.recurrence_id,(p_data->>'id')::uuid),p_store,p_data||jsonb_build_object('day',extract(day from (p_data->>'occurred_on')::date)),(date_trunc('month',(p_data->>'occurred_on')::date)+interval '1 month')::date)
         on conflict(id) do update set template=excluded.template,active=true,
           next_month=case when expense_recurring.active then expense_recurring.next_month else greatest(excluded.next_month,(date_trunc('month',now() at time zone 'Asia/Shanghai')+interval '1 month')::date) end;
     else update expense_recurring set active=false where id=coalesce(e.recurrence_id,(p_data->>'id')::uuid); end if;
   end if;
 elsif p_action in ('budget_save','budget_adjust') then
   month_day:=(p_data->>'month')::date;
   if extract(day from month_day)<>1 then raise exception 'invalid_month'; end if;
   select * into b from expense_budgets where store_id=p_store and month=month_day for update;
   if coalesce(b.revision,0) is distinct from (p_data->>'revision')::integer then raise exception 'budget_changed'; end if;
   if p_action='budget_adjust' then
     if b.store_id is null then raise exception 'budget_not_found'; end if;
     cats:=b.categories; k:=p_data->>'category'; amount:=(p_data->>'amount')::numeric; source:=p_data->>'source';
     if amount is null or amount<=0 or cats->k is null then raise exception 'invalid_amount'; end if;
     if source='total' then b.total:=b.total+amount;
     elsif source='remaining' then
       select coalesce(sum((value->>'amount')::numeric),0) into allocated from jsonb_each(cats);
       if b.total-allocated<amount then raise exception 'budget_insufficient'; end if;
     else
       if source=k or cats->source is null then raise exception 'invalid_source'; end if;
       select coalesce(sum(ee.amount),0) into used from expense_entries ee where store_id=p_store and not deleted and category=source and occurred_on>=month_day and occurred_on<month_day+interval '1 month';
       if (cats->source->>'amount')::numeric-used<amount then raise exception 'budget_insufficient'; end if;
       cats:=jsonb_set(cats,array[source,'amount'],to_jsonb((cats->source->>'amount')::numeric-amount));
     end if;
     cats:=jsonb_set(cats,array[k,'amount'],to_jsonb((cats->k->>'amount')::numeric+amount));
     p_data:=p_data||jsonb_build_object('total',b.total,'categories',cats,'carry',b.carry,'remind',b.remind);
   end if;
   allocated:=0;
   for k,v in select * from jsonb_each(p_data->'categories') loop
     if k not in ('房租','水电','人工','材料采购','设备维修','营销推广','税费','其他','损耗') or (v->>'amount')::numeric<0 or (v->>'threshold')::numeric not between 0 and 100 or v->>'policy' not in ('warn','owner','block') then raise exception 'invalid_budget'; end if;
     allocated:=allocated+(v->>'amount')::numeric;
   end loop;
   if allocated>(p_data->>'total')::numeric then raise exception 'allocation_exceeded'; end if;
   insert into expense_budgets(store_id,month,total,categories,carry,remind) values(p_store,month_day,(p_data->>'total')::numeric,p_data->'categories',coalesce((p_data->>'carry')::boolean,false),coalesce((p_data->>'remind')::boolean,true))
     on conflict(store_id,month) do update set total=excluded.total,categories=excluded.categories,carry=excluded.carry,remind=excluded.remind,revision=expense_budgets.revision+1 returning to_jsonb(expense_budgets.*) into result;
 else raise exception 'invalid_action'; end if;
 -- Original input is supplied separately below for append-only idempotency tracking.
 return result;
end $$;

create function public.expense_mutate(p_store uuid,p_request text,p_action text,p_data jsonb) returns jsonb language plpgsql security definer set search_path=public as $$
declare r jsonb; begin
 r:=expense_write(p_store,p_request,p_action,p_data);
 insert into expense_requests values(p_store,p_request,jsonb_build_object('action',p_action,'data',p_data),r) on conflict do nothing;
 return r;
end $$;

create function public.expense_read(p_store uuid,p_month date,p_id uuid default null) returns jsonb language plpgsql security definer set search_path=public as $$
declare result jsonb; begin
 perform expense_materialize(p_store);
 if p_id is not null then
   select to_jsonb(e)||jsonb_build_object('repeat',exists(select 1 from expense_recurring r where r.id=coalesce(e.recurrence_id,e.id) and r.active)) into result from expense_entries e where e.id=p_id and e.store_id=p_store and not e.deleted;
   return jsonb_build_object('item',result);
 end if;
 select jsonb_build_object(
 'month',p_month,'items',coalesce((select jsonb_agg(to_jsonb(e) order by occurred_on desc,created_at desc) from expense_entries e where store_id=p_store and not deleted and occurred_on>=p_month and occurred_on<p_month+interval '1 month'),'[]'),
 'budget',(select to_jsonb(b) from expense_budgets b where store_id=p_store and month=p_month),
 'previous_budget',(select to_jsonb(b) from expense_budgets b where store_id=p_store and month=(p_month-interval '1 month')::date),
 'history',coalesce((select jsonb_agg(t) from (select date_trunc('month',occurred_on)::date as month,category,sum(amount) as amount from expense_entries where store_id=p_store and not deleted and occurred_on>=p_month-interval '6 month' and occurred_on<p_month group by 1,2) t),'[]'),
 'revenue',coalesce((select sum(payable) from orders where store_id=p_store and created_at>=(p_month::timestamp at time zone 'Asia/Shanghai') and created_at<((p_month+interval '1 month')::timestamp at time zone 'Asia/Shanghai')),0)
 ) into result;
 return jsonb_build_object('item',result);
end $$;

create function public.inventory_expense_sync() returns trigger language plpgsql security definer set search_path=public as $$
declare amount numeric; category_name text; day_value date; rule jsonb; used numeric; begin
 if new.status='posted' and old.status<>'posted' then
   if new.kind='in' and coalesce((new.payload->>'sync_expense')::boolean,false) then amount:=new.total;
   elsif new.kind='check' then select coalesce(sum(cost),0) into amount from inventory_movements where document_id=new.id and after_stock<before_stock;
   else return new; end if;
   if amount>0 then
     perform expense_materialize(new.store_id);
     category_name:=case when new.kind='in' then '材料采购' else '损耗' end;
     day_value:=coalesce(nullif(new.payload->>'date','')::date,(now() at time zone 'Asia/Shanghai')::date);
     select categories->category_name into rule from expense_budgets where store_id=new.store_id and month=date_trunc('month',day_value)::date;
     select coalesce(sum(e.amount),0) into used from expense_entries e where store_id=new.store_id and category=category_name and not deleted and occurred_on>=date_trunc('month',day_value)::date and occurred_on<date_trunc('month',day_value)+interval '1 month';
     if rule->>'policy'='block' and used+amount>(rule->>'amount')::numeric then raise exception 'budget_exceeded'; end if;
     insert into expense_entries(id,store_id,amount,category,occurred_on,account,payee,status,note,source_document)
     values(gen_random_uuid(),new.store_id,amount,case when new.kind='in' then '材料采购' else '损耗' end,coalesce(nullif(new.payload->>'date','')::date,(now() at time zone 'Asia/Shanghai')::date),
     case when new.payload->>'payment' in ('现金','微信','对公转账') then new.payload->>'payment' else '其他' end,coalesce(new.payload->>'supplier',''),case when new.payload->>'payment'='挂账' then 'unpaid' else 'paid' end,coalesce(new.payload->>'note',''),new.id) on conflict(source_document) do nothing; end if;
 end if; return new;
end $$;
create trigger inventory_expense_sync after update of status on public.inventory_documents for each row execute function public.inventory_expense_sync();
revoke all on function public.expense_materialize(uuid),public.expense_write(uuid,text,text,jsonb),public.expense_mutate(uuid,text,text,jsonb),public.expense_read(uuid,date,uuid),public.inventory_expense_sync() from public,anon,authenticated;
grant execute on function public.expense_materialize(uuid),public.expense_mutate(uuid,text,text,jsonb),public.expense_read(uuid,date,uuid) to service_role;
