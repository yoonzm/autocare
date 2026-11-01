-- The base tier created for every new store ("普通会员") uses the plain white card
-- from the design. It cannot be picked in the editor, but it must be storable.
alter table public.card_types drop constraint if exists card_types_color_check;
alter table public.card_types
  add constraint card_types_color_check
  check (color in ('black', 'champagne', 'silver', 'blue', 'white'));
