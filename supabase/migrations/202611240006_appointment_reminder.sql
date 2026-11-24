-- Merchant reminders live on appointments. No client can claim or send jobs.
alter table public.appointments
  add column remind_enabled boolean not null default false,
  add column remind_at timestamptz,
  add column remind_state text not null default 'disabled'
    check (remind_state in ('disabled','pending','sending','sent','failed','unknown','skipped','cancelled')),
  add column remind_request uuid,
  add column remind_claimed_at timestamptz,
  add column remind_attempts integer not null default 0,
  add column remind_next_at timestamptz;
create index appointments_reminder_due on public.appointments(remind_next_at)
  where remind_state='pending';

create function public.appointment_reminder_sync() returns trigger
language plpgsql set search_path=public as $$
begin
  if TG_OP='UPDATE' then
    if new.starts_at is not distinct from old.starts_at
      and new.status is not distinct from old.status
      and new.remind_enabled is not distinct from old.remind_enabled then return new; end if;
  end if;
  new.remind_at := new.starts_at - interval '2 hours';
  new.remind_next_at := new.remind_at;
  new.remind_request := gen_random_uuid();
  new.remind_claimed_at := null;
  new.remind_attempts := 0;
  new.remind_state := case
    when not new.remind_enabled then 'disabled'
    when new.status <> 'waiting' then 'cancelled'
    when new.remind_at < now() then 'skipped'
    else 'pending' end;
  return new;
end $$;
create trigger appointment_reminder_sync before insert or update on public.appointments
for each row execute function public.appointment_reminder_sync();

-- Only the merchant endpoint uses this wrapper; member booking stays unchanged.
create function public.save_merchant_appointment(p_store uuid,p_input jsonb,p_request text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare result jsonb; a public.appointments;
begin
  perform pg_advisory_xact_lock(hashtextextended(p_store::text,0));
  select * into a from public.appointments where store_id=p_store and request_id=p_request;
  if found then return public.appointment_detail(p_store,a.id); end if;
  result := public.save_appointment(p_store,p_input,p_request);
  if p_input ? 'remind' then
    if jsonb_typeof(p_input->'remind') <> 'boolean' then raise exception 'invalid_reminder'; end if;
    select * into a from public.appointments where id=(result->>'id')::uuid for update;
    if (p_input->>'remind')::boolean and a.phone !~ '^(\+?86)?1[3-9][0-9]{9}$' then
      raise exception 'reminder_phone_required';
    end if;
    update public.appointments set remind_enabled=(p_input->>'remind')::boolean where id=a.id;
  end if;
  return public.appointment_detail(p_store,(result->>'id')::uuid);
end $$;

create function public.claim_appointment_reminders() returns setof public.appointments
language plpgsql security definer set search_path=public as $$
begin
  -- Never retry an abandoned send: the provider may already have accepted it.
  update public.appointments set remind_state='unknown'
    where remind_state='sending' and remind_claimed_at < now()-interval '5 minutes';
  update public.appointments set remind_state='skipped'
    where remind_state='pending' and starts_at<=now();
  return query
    with due as (
      select id from public.appointments where remind_enabled and status='waiting'
        and remind_state='pending' and remind_next_at<=now() and starts_at>now()
      order by remind_next_at limit 20 for update skip locked
    )
    update public.appointments a set remind_state='sending',remind_claimed_at=now(),
      remind_attempts=remind_attempts+1 from due where a.id=due.id returning a.*;
end $$;

create function public.finish_appointment_reminder(p_id uuid,p_request uuid,p_state text) returns void
language plpgsql security definer set search_path=public as $$
begin
  if p_state not in ('sent','failed','unknown','pending','skipped') then raise exception 'invalid_reminder_state'; end if;
  update public.appointments set
    remind_state=case when p_state='pending' and (remind_attempts>=3 or now()+interval '1 minute'>=starts_at)
      then 'failed' else p_state end,
    remind_next_at=case when p_state='pending' then now()+interval '1 minute' else remind_next_at end
    where id=p_id and remind_request=p_request and remind_state='sending';
end $$;
revoke all on function public.save_merchant_appointment(uuid,jsonb,text),public.claim_appointment_reminders(),
  public.finish_appointment_reminder(uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.save_merchant_appointment(uuid,jsonb,text),public.claim_appointment_reminders(),
  public.finish_appointment_reminder(uuid,uuid,text) to service_role;

-- A duplicate request must stop BEFORE calling the provider or consuming quota.
do $$
declare definition text; patched text;
begin
  select pg_get_functiondef('public.reserve_notice_sms(text,text,uuid,text,text,text)'::regprocedure) into definition;
  patched := replace(definition,'perform pg_advisory_xact_lock(79433702);',
    'perform pg_advisory_xact_lock(79433702);'
    || ' if exists(select 1 from public.sms_logs where request_id=p_request) then'
    || ' return jsonb_build_object(''error'',''duplicate_request''); end if;');
  if patched=definition then raise exception 'notice reservation lock not found'; end if;
  execute patched;
end $$;
