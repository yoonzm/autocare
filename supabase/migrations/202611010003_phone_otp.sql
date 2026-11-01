-- One-time phone verification codes. Only the Edge Function (service_role) can touch it.
-- Codes are stored as SHA-256 hashes; a phone has at most one live code.
create table if not exists public.phone_otps (
  phone text primary key,
  code_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.phone_otps enable row level security;
revoke all on public.phone_otps from public, anon, authenticated;
grant select, insert, update, delete on public.phone_otps to service_role;
