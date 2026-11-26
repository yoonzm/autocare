-- 预约改期与取消短信通知开关（默认开启）。
alter table public.appointment_settings
  add column if not exists notify_reschedule boolean not null default true,
  add column if not exists notify_cancel boolean not null default true;

do $$
declare definition text; patched text;
begin
  select pg_get_functiondef('public.save_appointment_settings(uuid,jsonb)'::regprocedure) into definition;
  patched := replace(
    definition,
    'notify_manager=s.notify_manager',
    'notify_manager=s.notify_manager,notify_reschedule=coalesce(s.notify_reschedule,true),notify_cancel=coalesce(s.notify_cancel,true)'
  );
  if patched = definition then
    raise exception 'save_appointment_settings notify_manager patch target not found';
  end if;
  execute patched;
end $$;
