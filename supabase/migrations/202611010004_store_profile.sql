-- Store profile captured at sign-up, trial period and account-deletion cooling-off.
alter table public.stores
  add column if not exists city text not null default '',
  add column if not exists address text not null default '',
  add column if not exists contact_name text not null default '',
  add column if not exists contact_role text not null default '',
  add column if not exists bay_range text not null default '',
  add column if not exists business_types text[] not null default '{}',
  add column if not exists plan text not null default 'trial',
  add column if not exists trial_ends_at timestamptz,
  -- Set when the owner requests deletion; logging in again cancels it.
  -- TODO: a scheduled job must purge accounts 15 days after this timestamp.
  add column if not exists delete_requested_at timestamptz;
