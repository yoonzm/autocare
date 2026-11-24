alter table public.appointment_settings
  add column notify_confirm_default boolean not null default false,
  add column remind_default boolean not null default false,
  add column notify_manager boolean not null default false;
alter table public.appointments add column notify_confirm boolean not null default false;

-- Preserve the existing capacity/closed-date validation and older clients' omitted flags.
do $$
declare definition text; patched text;
begin
  select pg_get_functiondef('public.save_appointment_settings(uuid,jsonb)'::regprocedure) into definition;
  patched:=replace(definition,'closed_days=s.closed_days,closed_dates=coalesce(s.closed_dates,''{}'')',
    'closed_days=s.closed_days,closed_dates=coalesce(s.closed_dates,''{}''),'
    || 'notify_confirm_default=s.notify_confirm_default,remind_default=s.remind_default,notify_manager=s.notify_manager');
  if patched=definition then raise exception 'settings update not found'; end if;
  patched:=replace(patched,'  update public.appointment_settings set',
    '  if s.notify_manager and not exists(select 1 from public.store_staff where store_id=p_store and role=''manager'' and status=''active'') then'
    || ' raise exception ''appointment_manager_required''; end if;'
    || ' update public.appointment_settings set');
  execute patched;
end $$;

create or replace function public.save_merchant_appointment(p_store uuid,p_input jsonb,p_request text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare result jsonb; a public.appointments; s public.appointment_settings;
  creating boolean:=p_input->>'id' is null;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  select * into a from public.appointments where store_id=p_store and request_id=p_request;
  if found then return public.appointment_detail(p_store,a.id); end if;
  if creating then
    insert into public.appointment_settings(store_id) values(p_store) on conflict do nothing;
    select * into s from public.appointment_settings where store_id=p_store;
    -- Explicit false always wins. Member portal keeps using save_appointment directly.
    p_input:=jsonb_build_object('remind',s.remind_default,'notify',s.notify_confirm_default)||p_input;
  end if;
  if p_input ? 'notify' and jsonb_typeof(p_input->'notify') <> 'boolean' then raise exception 'invalid_notification'; end if;
  if p_input ? 'remind' and jsonb_typeof(p_input->'remind') <> 'boolean' then raise exception 'invalid_reminder'; end if;
  result := public.save_appointment(p_store,p_input,p_request);
  if p_input ? 'remind' then
    select * into a from public.appointments where id=(result->>'id')::uuid for update;
    if (p_input->>'remind')::boolean and a.phone !~ '^(\+?86)?1[3-9][0-9]{9}$' then
      raise exception 'reminder_phone_required';
    end if;
    update public.appointments set remind_enabled=(p_input->>'remind')::boolean where id=a.id;
  end if;
  if creating then
    update public.appointments set notify_confirm=(p_input->>'notify')::boolean where id=(result->>'id')::uuid;
  end if;
  return public.appointment_detail(p_store,(result->>'id')::uuid);
end $$;
