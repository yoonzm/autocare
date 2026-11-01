-- Card tier configuration that does not depend on other modules:
-- face colour, upgrade thresholds, points multiplier, birthday gift,
-- priority booking, validity, and the store-wide card rules.
-- How these are applied (billing, points, upgrades, booking) belongs to the
-- order / member / booking modules and is not implemented here.
alter table public.card_types
  add column if not exists color text not null default 'black'
    check (color in ('black', 'champagne', 'silver', 'blue')),
  add column if not exists upgrade_recharge numeric(12, 2)
    check (upgrade_recharge is null or upgrade_recharge >= 0),
  add column if not exists upgrade_cumulative numeric(12, 2)
    check (upgrade_cumulative is null or upgrade_cumulative >= 0),
  add column if not exists points_multiplier numeric(3, 1) not null default 1
    check (points_multiplier >= 0 and points_multiplier <= 10),
  add column if not exists birthday_gift text not null default ''
    check (length(birthday_gift) <= 100),
  add column if not exists priority_booking boolean not null default false,
  add column if not exists validity text not null default 'forever'
    check (validity in ('forever', '1y', '2y'));

alter table public.stores
  add column if not exists card_auto_upgrade boolean not null default true,
  add column if not exists card_balance_refundable boolean not null default false;
