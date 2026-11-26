-- iOS 推送设备绑定与出站队列（阿里云移动推送 EMAS；与站内信 staff_messages 联动）
create table public.push_devices (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid references public.store_staff(id) on delete cascade,
  owner_id uuid references auth.users(id) on delete cascade,
  platform text not null check (platform in ('ios', 'android')),
  provider text not null default 'aliyun' check (provider in ('aliyun')),
  device_token text not null check (length(trim(device_token)) between 8 and 256),
  disabled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint push_devices_recipient_check check ((staff_id is null) <> (owner_id is null))
);

create unique index push_devices_token_uidx
  on public.push_devices(provider, platform, device_token);

create index push_devices_recipient_idx
  on public.push_devices(store_id, staff_id, owner_id)
  where disabled_at is null;

alter table public.push_devices enable row level security;
revoke all on public.push_devices from public, anon, authenticated;
grant all on public.push_devices to service_role;

create table public.push_outbox (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.staff_messages(id) on delete cascade,
  store_id uuid not null references public.stores(id) on delete cascade,
  staff_id uuid references public.store_staff(id) on delete cascade,
  owner_id uuid references auth.users(id) on delete cascade,
  title text not null,
  body text not null default '',
  status text not null default 'pending' check (status in ('pending', 'sent', 'skipped', 'failed')),
  attempts integer not null default 0,
  last_error text not null default '',
  next_retry_at timestamptz not null default now(),
  sent_at timestamptz,
  created_at timestamptz not null default now(),
  constraint push_outbox_recipient_check check ((staff_id is null) <> (owner_id is null))
);

create index push_outbox_due_idx
  on public.push_outbox(next_retry_at, created_at)
  where status in ('pending', 'failed');

alter table public.push_outbox enable row level security;
revoke all on public.push_outbox from public, anon, authenticated;
grant all on public.push_outbox to service_role;

-- 仅当收件人已绑定有效推送设备时入队，避免无设备时产生空队列。
create function public.push_enqueue_staff_message() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if exists (
    select 1 from public.push_devices d
    where d.store_id = new.store_id
      and d.disabled_at is null
      and ((new.staff_id is not null and d.staff_id = new.staff_id)
        or (new.owner_id is not null and d.owner_id = new.owner_id))
  ) then
    insert into public.push_outbox(message_id, store_id, staff_id, owner_id, title, body)
    values (new.id, new.store_id, new.staff_id, new.owner_id, new.title, new.body);
  end if;
  return new;
end $$;

create trigger staff_messages_push_outbox
  after insert on public.staff_messages
  for each row execute function public.push_enqueue_staff_message();

create function public.push_register(
  p_store uuid,
  p_staff uuid,
  p_owner uuid,
  p_platform text,
  p_token text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_token text := trim(coalesce(p_token, ''));
begin
  perform public.inbox_assert_recipient(p_store, p_staff, p_owner);
  if p_platform not in ('ios', 'android') then
    raise exception 'push_invalid';
  end if;
  if length(v_token) < 8 or length(v_token) > 256 then
    raise exception 'push_invalid';
  end if;
  insert into public.push_devices(store_id, staff_id, owner_id, platform, provider, device_token, disabled_at, updated_at)
  values (p_store, p_staff, p_owner, p_platform, 'aliyun', v_token, null, now())
  on conflict (provider, platform, device_token) do update
    set store_id = excluded.store_id,
        staff_id = excluded.staff_id,
        owner_id = excluded.owner_id,
        disabled_at = null,
        updated_at = now();
  return jsonb_build_object('ok', true);
end $$;

create function public.push_unregister(
  p_store uuid,
  p_staff uuid,
  p_owner uuid,
  p_platform text,
  p_token text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_token text := trim(coalesce(p_token, ''));
begin
  if (p_staff is null) = (p_owner is null) then
    raise exception 'inbox_forbidden' using errcode = '42501';
  end if;
  if p_platform not in ('ios', 'android') or length(v_token) < 8 or length(v_token) > 256 then
    raise exception 'push_invalid';
  end if;
  update public.push_devices
  set disabled_at = now(),
      updated_at = now()
  where provider = 'aliyun'
    and platform = p_platform
    and device_token = v_token
    and store_id = p_store
    and ((p_staff is not null and staff_id = p_staff)
      or (p_owner is not null and owner_id = p_owner))
    and disabled_at is null;
  return jsonb_build_object('ok', true);
end $$;

create function public.push_claim_outbox(p_limit integer default 50) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_limit integer := greatest(1, least(coalesce(p_limit, 50), 200));
  v_rows jsonb;
begin
  with due as (
    select id
    from public.push_outbox
    where (status = 'pending' or (status = 'failed' and attempts < 5 and next_retry_at <= now()))
    order by created_at asc
    limit v_limit
    for update skip locked
  ),
  bumped as (
    update public.push_outbox o
    set attempts = o.attempts + 1
    from due
    where o.id = due.id
    returning o.*
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', b.id,
    'message_id', b.message_id,
    'title', b.title,
    'body', b.body,
    'attempts', b.attempts,
    'ios_tokens', coalesce((
      select jsonb_agg(d.device_token order by d.updated_at desc)
      from public.push_devices d
      where d.store_id = b.store_id
        and d.disabled_at is null
        and d.platform = 'ios'
        and ((b.staff_id is not null and d.staff_id = b.staff_id)
          or (b.owner_id is not null and d.owner_id = b.owner_id))
    ), '[]'::jsonb)
  ) order by b.created_at asc), '[]'::jsonb)
  into v_rows
  from bumped b;

  return v_rows;
end $$;

create function public.push_mark_outbox(p_id uuid, p_status text, p_error text default '') returns void
language plpgsql security definer set search_path = public as $$
begin
  if p_status not in ('sent', 'skipped', 'failed') then
    raise exception 'push_invalid';
  end if;
  update public.push_outbox
  set status = p_status,
      last_error = left(coalesce(p_error, ''), 500),
      sent_at = case when p_status = 'sent' then now() else sent_at end,
      next_retry_at = case
        when p_status = 'failed' then now() + (interval '1 minute' * power(2, least(attempts, 4)))
        else next_retry_at
      end
  where id = p_id;
end $$;

create function public.push_disable_device(p_platform text, p_token text) returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.push_devices
  set disabled_at = now(),
      updated_at = now()
  where provider = 'aliyun'
    and platform = p_platform
    and device_token = trim(coalesce(p_token, ''))
    and disabled_at is null;
end $$;

revoke all on function
  public.push_enqueue_staff_message(),
  public.push_register(uuid, uuid, uuid, text, text),
  public.push_unregister(uuid, uuid, uuid, text, text),
  public.push_claim_outbox(integer),
  public.push_mark_outbox(uuid, text, text),
  public.push_disable_device(text, text)
from public, anon, authenticated;

grant execute on function
  public.push_register(uuid, uuid, uuid, text, text),
  public.push_unregister(uuid, uuid, uuid, text, text),
  public.push_claim_outbox(integer),
  public.push_mark_outbox(uuid, text, text),
  public.push_disable_device(text, text)
to service_role;
