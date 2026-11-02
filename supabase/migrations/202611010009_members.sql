-- 会员（核心维护）：会员档案、车辆、办卡（建档并发放起始卡种）。
-- 充值 / 余额 / 次卡 / 订单 / 回访 / 微信绑定属于其他模块，不在本迁移内。

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  phone text not null check (phone ~ '^1[3-9][0-9]{9}$'),
  name text not null check (length(trim(name)) between 1 and 30),
  honorific text not null default '' check (honorific in ('', '先生', '女士')),
  birthday date,
  source text not null default '' check (source in ('', '到店自然客', '老客推荐', '团购平台', '短视频')),
  referrer_id uuid references public.members(id) on delete set null,
  note text not null default '' check (length(note) <= 200),
  -- 办卡时发放的卡种；卡种下还有会员时不能停用 / 删除
  card_type_id uuid not null references public.card_types(id) on delete restrict,
  -- 软删除：历史订单和财务流水要保留，会员显示为“已删除会员”
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists members_store_phone_uidx
  on public.members(store_id, phone) where deleted_at is null;
create index if not exists members_store_id_idx on public.members(store_id);
create index if not exists members_card_type_id_idx on public.members(card_type_id);

create table if not exists public.member_vehicles (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  plate text not null check (length(plate) between 5 and 10),
  -- 新能源（绿牌）车牌 8 位，燃油车 7 位
  energy text not null default 'fuel' check (energy in ('fuel', 'ev')),
  brand_model text not null default '' check (length(brand_model) <= 50),
  color text not null default '' check (length(color) <= 20),
  vin text not null default '' check (vin = '' or length(vin) = 17),
  mileage int check (mileage is null or mileage between 0 and 2000000),
  created_at timestamptz not null default now()
);
-- 同一家店里一个车牌只属于一位会员
create unique index if not exists member_vehicles_store_plate_uidx
  on public.member_vehicles(store_id, plate);
create index if not exists member_vehicles_member_id_idx on public.member_vehicles(member_id);

alter table public.members enable row level security;
alter table public.member_vehicles enable row level security;
create policy members_owner on public.members for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
create policy member_vehicles_owner on public.member_vehicles for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
revoke all on public.members, public.member_vehicles from public, anon, authenticated;
grant select on public.members, public.member_vehicles to authenticated;
grant select, insert, update, delete on public.members, public.member_vehicles to service_role;

-- 办卡：建立会员档案并发放起始卡种（门店里没有升级门槛的卡种，即“普通会员”），可同时登记一辆车。
-- 单次充值 / 累计消费后的自动升级依赖充值和订单模块，目前只在这里发放起始卡种。
-- 错误：P0002 = 没有可发放的卡种 / 推荐人不存在。
create or replace function public.create_member(p_store uuid, p_values jsonb, p_vehicle jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tier uuid;
  v_id uuid;
begin
  select id into v_tier from public.card_types
  where store_id = p_store and active
  order by (upgrade_recharge is not null or upgrade_cumulative is not null),
           coalesce(upgrade_recharge, 0) + coalesce(upgrade_cumulative, 0), created_at
  limit 1;
  if v_tier is null then
    raise exception 'no_card_tier' using errcode = 'P0002';
  end if;

  if nullif(p_values->>'referrer_id', '') is not null and not exists (
    select 1 from public.members
    where id = (p_values->>'referrer_id')::uuid and store_id = p_store and deleted_at is null
  ) then
    raise exception 'referrer_not_found' using errcode = 'P0002';
  end if;

  insert into public.members (
    store_id, phone, name, honorific, birthday, source, referrer_id, note, card_type_id
  ) values (
    p_store, p_values->>'phone', p_values->>'name', coalesce(p_values->>'honorific', ''),
    nullif(p_values->>'birthday', '')::date, coalesce(p_values->>'source', ''),
    nullif(p_values->>'referrer_id', '')::uuid, coalesce(p_values->>'note', ''), v_tier
  ) returning id into v_id;

  if p_vehicle is not null and jsonb_typeof(p_vehicle) = 'object' then
    insert into public.member_vehicles (store_id, member_id, plate, energy, brand_model, color, vin, mileage)
    values (
      p_store, v_id, p_vehicle->>'plate', coalesce(p_vehicle->>'energy', 'fuel'),
      coalesce(p_vehicle->>'brand_model', ''), coalesce(p_vehicle->>'color', ''),
      coalesce(p_vehicle->>'vin', ''), nullif(p_vehicle->>'mileage', '')::int
    );
  end if;
  return v_id;
end;
$$;
revoke all on function public.create_member(uuid, jsonb, jsonb) from public, anon, authenticated;
grant execute on function public.create_member(uuid, jsonb, jsonb) to service_role;

-- 删除会员：档案软删除（保留历史订单关联），车辆一并移除；推荐关系清空。
create or replace function public.delete_member(p_store uuid, p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.members set deleted_at = now(), updated_at = now()
  where id = p_id and store_id = p_store and deleted_at is null;
  if not found then
    return false;
  end if;
  delete from public.member_vehicles where member_id = p_id and store_id = p_store;
  update public.members set referrer_id = null where referrer_id = p_id and store_id = p_store;
  return true;
end;
$$;
revoke all on function public.delete_member(uuid, uuid) from public, anon, authenticated;
grant execute on function public.delete_member(uuid, uuid) to service_role;
