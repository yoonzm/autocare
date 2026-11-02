-- 卡面颜色除了系统默认配色，还可以自定义（`#RRGGBB`）。
alter table public.card_types drop constraint if exists card_types_color_check;
alter table public.card_types
  add constraint card_types_color_check
  check (color in ('black', 'champagne', 'silver', 'blue', 'white') or color ~ '^#[0-9A-Fa-f]{6}$');
