-- 会员钱包：储值余额、积分、累计消费 / 充值、到店次数，以及所有变动的流水。
-- 余额和积分只能经由下面的 SECURITY DEFINER 函数（云函数以 service_role 调用）修改，
-- 客户端和 RLS 都只有读权限。收款方式只是记账，不接真实支付通道。

alter table public.members
  add column if not exists balance numeric(12, 2) not null default 0 check (balance >= 0),
  add column if not exists points int not null default 0 check (points >= 0),
  add column if not exists total_recharged numeric(12, 2) not null default 0,
  add column if not exists total_spent numeric(12, 2) not null default 0,
  add column if not exists visit_count int not null default 0,
  add column if not exists last_visit_at timestamptz;

create table if not exists public.member_ledger (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  -- recharge 储值充值 / adjust_points 调整积分 / adjust_card 调整卡种 / upgrade 自动升级
  kind text not null check (kind in ('recharge', 'adjust_points', 'adjust_card', 'upgrade')),
  -- 实收金额（充值）
  amount numeric(12, 2) not null default 0,
  -- 赠送金额
  gift numeric(12, 2) not null default 0,
  balance_delta numeric(12, 2) not null default 0,
  balance_after numeric(12, 2) not null default 0,
  points_delta int not null default 0,
  points_after int not null default 0,
  pay_method text not null default '',
  operator text not null default '',
  reason text not null default '',
  note text not null default '' check (length(note) <= 200),
  -- 卡种变动：变更前后的卡种名称
  card_from text not null default '',
  card_to text not null default '',
  -- 客户端为同一次点击生成的幂等标识：重试不会重复入账
  request_id text,
  created_at timestamptz not null default now()
);
create index if not exists member_ledger_member_idx on public.member_ledger(member_id, created_at desc);
create unique index if not exists member_ledger_request_uidx
  on public.member_ledger(store_id, request_id) where request_id is not null;

alter table public.member_ledger enable row level security;
create policy member_ledger_owner on public.member_ledger for select to authenticated
  using (exists (select 1 from public.stores s where s.id = store_id and s.owner_id = (select auth.uid())));
revoke all on public.member_ledger from public, anon, authenticated;
grant select on public.member_ledger to authenticated;
grant select, insert, update, delete on public.member_ledger to service_role;

-- 升级门槛的高低：单次充值门槛越高，卡种越高；没有门槛的是起始卡种。
create or replace function public.card_rank(t public.card_types) returns numeric
language sql immutable as $$
  select coalesce(t.upgrade_recharge, 0) * 1000000 + coalesce(t.upgrade_cumulative, 0)
$$;

-- 储值充值：入账 + 流水 + 自动升级，一个事务。
-- p_gift 由云函数按赠送规则算出，客户端不能指定。重复的 request_id 直接返回第一次的结果。
-- 错误：P0002 = 会员不存在。
create or replace function public.recharge_member(
  p_store uuid, p_member uuid, p_amount numeric, p_gift numeric,
  p_method text, p_operator text, p_note text, p_request text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.members;
  cur public.card_types;
  best public.card_types;
  auto boolean;
  v_points int;
  v_ledger uuid;
  v_upgraded text := null;
  prior public.member_ledger;
begin
  if p_request is not null then
    select * into prior from public.member_ledger where store_id = p_store and request_id = p_request;
    if found then
      select * into m from public.members where id = prior.member_id;
      return jsonb_build_object(
        'ledger_id', prior.id, 'balance', m.balance, 'gift', prior.gift,
        'points_gained', prior.points_delta, 'upgraded_to', null, 'repeated', true
      );
    end if;
  end if;

  select * into m from public.members
  where id = p_member and store_id = p_store and deleted_at is null for update;
  if not found then
    raise exception 'member_not_found' using errcode = 'P0002';
  end if;
  select * into cur from public.card_types where id = m.card_type_id;

  -- 积分 = 实收金额 × 卡种积分倍率（向下取整）
  v_points := floor(p_amount * coalesce(cur.points_multiplier, 1));

  update public.members set
    balance = balance + p_amount + p_gift,
    total_recharged = total_recharged + p_amount,
    points = points + v_points,
    updated_at = now()
  where id = m.id
  returning * into m;

  insert into public.member_ledger (
    store_id, member_id, kind, amount, gift, balance_delta, balance_after,
    points_delta, points_after, pay_method, operator, note, request_id
  ) values (
    p_store, m.id, 'recharge', p_amount, p_gift, p_amount + p_gift, m.balance,
    v_points, m.points, p_method, p_operator, coalesce(p_note, ''), p_request
  ) returning id into v_ledger;

  -- 自动升级：单次充值满额或累计消费满额，立即升到达标的最高卡种；只升不降。
  select card_auto_upgrade into auto from public.stores where id = p_store;
  if auto then
    select t.* into best from public.card_types t
    where t.store_id = p_store and t.active
      and ((t.upgrade_recharge is not null and p_amount >= t.upgrade_recharge)
        or (t.upgrade_cumulative is not null and m.total_spent >= t.upgrade_cumulative))
    order by public.card_rank(t) desc limit 1;
    if found and public.card_rank(best) > public.card_rank(cur) then
      update public.members set card_type_id = best.id, updated_at = now() where id = m.id;
      insert into public.member_ledger (
        store_id, member_id, kind, balance_after, points_after, operator, reason, card_from, card_to
      ) values (
        p_store, m.id, 'upgrade', m.balance, m.points, '系统', '充值达标自动升级', cur.name, best.name
      );
      v_upgraded := best.name;
    end if;
  end if;

  return jsonb_build_object(
    'ledger_id', v_ledger, 'balance', m.balance, 'gift', p_gift,
    'points_gained', v_points, 'upgraded_to', v_upgraded, 'repeated', false
  );
end;
$$;
revoke all on function public.recharge_member(uuid, uuid, numeric, numeric, text, text, text, text) from public, anon, authenticated;
grant execute on function public.recharge_member(uuid, uuid, numeric, numeric, text, text, text, text) to service_role;

-- 调整卡种与积分（手动）：必须填原因；积分不能扣成负数。
-- p_tier 为空 = 不改卡种；p_points 为 0 = 不改积分。错误：P0002 = 会员 / 卡种不存在；P0001 = 积分不足。
create or replace function public.adjust_member(
  p_store uuid, p_member uuid, p_tier uuid, p_points int,
  p_reason text, p_note text, p_operator text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.members;
  cur public.card_types;
  target public.card_types;
begin
  select * into m from public.members
  where id = p_member and store_id = p_store and deleted_at is null for update;
  if not found then
    raise exception 'member_not_found' using errcode = 'P0002';
  end if;
  select * into cur from public.card_types where id = m.card_type_id;

  if p_tier is not null and p_tier <> m.card_type_id then
    select * into target from public.card_types where id = p_tier and store_id = p_store and active;
    if not found then
      raise exception 'tier_not_found' using errcode = 'P0002';
    end if;
    update public.members set card_type_id = target.id, updated_at = now() where id = m.id;
    insert into public.member_ledger (
      store_id, member_id, kind, balance_after, points_after, operator, reason, note, card_from, card_to
    ) values (
      p_store, m.id, 'adjust_card', m.balance, m.points, p_operator, p_reason, coalesce(p_note, ''),
      cur.name, target.name
    );
  end if;

  if coalesce(p_points, 0) <> 0 then
    if m.points + p_points < 0 then
      raise exception 'points_not_enough' using errcode = 'P0001';
    end if;
    update public.members set points = points + p_points, updated_at = now()
    where id = m.id returning * into m;
    insert into public.member_ledger (
      store_id, member_id, kind, balance_after, points_delta, points_after, operator, reason, note
    ) values (
      p_store, m.id, 'adjust_points', m.balance, p_points, m.points, p_operator, p_reason, coalesce(p_note, '')
    );
  end if;
  return jsonb_build_object('points', m.points);
end;
$$;
revoke all on function public.adjust_member(uuid, uuid, uuid, int, text, text, text) from public, anon, authenticated;
grant execute on function public.adjust_member(uuid, uuid, uuid, int, text, text, text) to service_role;
