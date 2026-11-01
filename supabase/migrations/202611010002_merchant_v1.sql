-- V1 only: merchant store, services and card types. No member data.
create extension if not exists pgcrypto;

drop trigger if exists on_merchant_created on auth.users;
drop function if exists public.create_merchant_store();

create table if not exists public.stores (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  phone text,
  created_at timestamptz not null default now()
);

create table if not exists public.service_items (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  category text not null default '其他',
  description text not null default '',
  price numeric(10,2) not null check (price >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.card_types (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  description text not null default '',
  discount numeric(4,2) not null default 1 check (discount > 0 and discount <= 1),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists service_items_store_id_idx on public.service_items(store_id);
create index if not exists card_types_store_id_idx on public.card_types(store_id);
alter table public.stores enable row level security;
alter table public.service_items enable row level security;
alter table public.card_types enable row level security;

-- Remove the superseded prototype policies if they were applied to a dev DB.
drop policy if exists stores_owner on public.stores;
drop policy if exists service_items_store_owner on public.service_items;
drop policy if exists card_types_store_owner on public.card_types;
drop policy if exists service_items_owner on public.service_items;
drop policy if exists card_types_owner on public.card_types;
create policy stores_owner on public.stores for select to authenticated
  using (owner_id = (select auth.uid()));
create policy service_items_owner on public.service_items for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
create policy card_types_owner on public.card_types for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));

grant usage on schema public to authenticated;
revoke all on public.stores, public.service_items, public.card_types from public, anon, authenticated;
grant select on public.stores to authenticated;
grant select on public.service_items, public.card_types to authenticated;
grant select, insert, update, delete on public.stores, public.service_items, public.card_types to service_role;
