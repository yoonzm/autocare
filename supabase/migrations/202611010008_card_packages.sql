-- 次卡套餐 (multi-use card packages): the package definition and what it includes.
-- Selling, using, extending and refunding packages belong to the member / order
-- modules and are not part of this migration.

create table if not exists public.card_packages (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  price numeric(10, 2) not null check (price >= 0),
  -- 0 = never expires
  validity_months int not null default 12 check (validity_months in (0, 3, 6, 12, 24)),
  -- null = unlimited
  purchase_limit int check (purchase_limit is null or purchase_limit between 1 and 99),
  vehicle_scope text not null default '全部车型' check (length(vehicle_scope) between 1 and 50),
  show_in_mini boolean not null default true,
  description text not null default '' check (length(description) <= 500),
  -- on sale; turning it off stops new sales only
  active boolean not null default true,
  -- soft delete: packages already sold must keep their definition
  deleted_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.card_package_items (
  package_id uuid not null references public.card_packages(id) on delete cascade,
  service_id uuid not null references public.service_items(id) on delete restrict,
  count int not null check (count between 1 and 999),
  position int not null default 0,
  primary key (package_id, service_id)
);

create index if not exists card_packages_store_id_idx on public.card_packages(store_id);
create index if not exists card_package_items_service_id_idx on public.card_package_items(service_id);

alter table public.card_packages enable row level security;
alter table public.card_package_items enable row level security;
create policy card_packages_owner on public.card_packages for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
create policy card_package_items_owner on public.card_package_items for select to authenticated
  using (exists (
    select 1 from public.card_packages p join public.stores s on s.id = p.store_id
    where p.id = package_id and s.owner_id = (select auth.uid())
  ));
revoke all on public.card_packages, public.card_package_items from public, anon, authenticated;
grant select on public.card_packages, public.card_package_items to authenticated;
grant select, insert, update, delete on public.card_packages, public.card_package_items to service_role;

-- Creates or updates a package together with its services in one transaction.
-- Raises P0002 when the package or one of the services does not belong to the store.
create or replace function public.save_card_package(
  p_store uuid, p_id uuid, p_values jsonb, p_items jsonb
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if exists (
    select 1
    from jsonb_array_elements(p_items) e
    left join public.service_items s
      on s.id = (e->>'service_id')::uuid and s.store_id = p_store
    where s.id is null
  ) then
    raise exception 'service_not_found' using errcode = 'P0002';
  end if;

  if p_id is null then
    insert into public.card_packages (
      store_id, name, price, validity_months, purchase_limit, vehicle_scope,
      show_in_mini, description, active
    ) values (
      p_store, p_values->>'name', (p_values->>'price')::numeric,
      (p_values->>'validity_months')::int, nullif(p_values->>'purchase_limit', '')::int,
      p_values->>'vehicle_scope', (p_values->>'show_in_mini')::boolean,
      coalesce(p_values->>'description', ''), (p_values->>'active')::boolean
    ) returning id into v_id;
  else
    update public.card_packages set
      name = p_values->>'name',
      price = (p_values->>'price')::numeric,
      validity_months = (p_values->>'validity_months')::int,
      purchase_limit = nullif(p_values->>'purchase_limit', '')::int,
      vehicle_scope = p_values->>'vehicle_scope',
      show_in_mini = (p_values->>'show_in_mini')::boolean,
      description = coalesce(p_values->>'description', ''),
      active = (p_values->>'active')::boolean
    where id = p_id and store_id = p_store and deleted_at is null
    returning id into v_id;
    if v_id is null then
      raise exception 'package_not_found' using errcode = 'P0002';
    end if;
    delete from public.card_package_items where package_id = v_id;
  end if;

  insert into public.card_package_items (package_id, service_id, count, position)
  select v_id, (e.value->>'service_id')::uuid, (e.value->>'count')::int, (e.ordinality - 1)::int
  from jsonb_array_elements(p_items) with ordinality as e(value, ordinality);
  return v_id;
end;
$$;
revoke all on function public.save_card_package(uuid, uuid, jsonb, jsonb) from public, anon, authenticated;
grant execute on function public.save_card_package(uuid, uuid, jsonb, jsonb) to service_role;
