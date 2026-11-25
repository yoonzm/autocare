-- 预约通知记录：记录预约确认、改期、到店前提醒与取消短信的发送结果。
create table public.appointment_notices (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  kind text not null check (kind in ('confirm', 'reschedule', 'remind', 'cancel')),
  channel text not null default 'sms' check (channel in ('sms', 'wechat')),
  status text not null check (status in ('pending', 'sent', 'failed', 'skipped')),
  recipient text not null default '',
  error text not null default '',
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create index appointment_notices_appt_idx
  on public.appointment_notices(appointment_id, created_at desc);

alter table public.appointment_notices enable row level security;
revoke all on public.appointment_notices from public, anon, authenticated;
grant select, insert, update on public.appointment_notices to service_role;

create or replace function public.appointment_detail(p_store uuid, p_id uuid) returns jsonb
language sql stable security definer set search_path=public as $$
  select to_jsonb(a) || jsonb_build_object(
    'status', case when a.status = 'waiting' and a.starts_at + make_interval(mins => coalesce(s.grace_minutes, 15)) < now()
      then 'late' else a.status end,
    'level', coalesce(c.name, '散客'),
    'bay_name', (select name from public.appointment_resources where id = a.bay_id),
    'technician_name', (select name from public.appointment_resources where id = a.technician_id),
    'notices', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', n.id,
        'kind', n.kind,
        'channel', n.channel,
        'status', n.status,
        'recipient', n.recipient,
        'error', n.error,
        'sent_at', n.sent_at,
        'created_at', n.created_at
      ) order by n.created_at desc, n.id desc)
      from public.appointment_notices n
      where n.appointment_id = a.id and n.store_id = a.store_id
    ), '[]'::jsonb))
  from public.appointments a
    left join public.appointment_settings s on s.store_id = a.store_id
    left join public.members m on m.id = a.member_id
    left join public.card_types c on c.id = m.card_type_id
  where a.store_id = p_store and a.id = p_id
$$;
