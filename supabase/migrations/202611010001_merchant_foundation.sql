-- Merchant-owned foundation. Never expose service-role credentials in the app.
create extension if not exists pgcrypto;

create table public.stores (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  phone text,
  address text,
  created_at timestamptz not null default now()
);

create table public.service_items (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  category text not null default '其他',
  description text not null default '',
  price numeric(10,2) not null default 0 check (price >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.card_types (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  description text not null default '',
  discount numeric(4,2) not null default 1 check (discount > 0 and discount <= 1),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (store_id, id)
);

create table public.members (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  card_type_id uuid,
  name text not null check (length(trim(name)) between 1 and 100),
  phone text not null check (length(trim(phone)) between 1 and 30),
  plate_number text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now(),
  unique (store_id, phone),
  foreign key (store_id, card_type_id) references public.card_types(store_id, id)
);

create index service_items_store_id_idx on public.service_items(store_id);
create index card_types_store_id_idx on public.card_types(store_id);
create index members_store_id_idx on public.members(store_id);

alter table public.stores enable row level security;
alter table public.service_items enable row level security;
alter table public.card_types enable row level security;
alter table public.members enable row level security;

create policy stores_owner on public.stores for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy service_items_store_owner on public.service_items for all to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));

create policy card_types_store_owner on public.card_types for all to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));

create policy members_store_owner on public.members for all to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));

-- A store exists even while email confirmation is pending. User metadata is
-- only used for the initial name; all subsequent writes are protected by RLS.
create or replace function public.create_merchant_store()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.stores (owner_id, name)
  values (new.id, coalesce(nullif(trim(new.raw_user_meta_data ->> 'store_name'), ''), '我的门店'));
  return new;
end;
$$;

create trigger on_merchant_created after insert on auth.users
for each row execute function public.create_merchant_store();

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.stores, public.service_items, public.card_types, public.members to authenticated;
