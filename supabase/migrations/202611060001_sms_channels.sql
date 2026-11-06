-- OTP delivery is separate from Auth's native SMS provider. Existing accounts keep
-- their email aliases; switching Auth identity providers would strand sessions.
alter table public.phone_otps
  add column purpose text not null default 'legacy',
  add column request_id uuid,
  add column delivery_state text not null default 'failed',
  add column provider text,
  add column consumed_at timestamptz;
alter table public.phone_otps drop constraint phone_otps_pkey;
alter table public.phone_otps add primary key (phone,purpose);
alter table public.phone_otps add constraint phone_otps_purpose_check check
  (purpose in ('legacy','register','login','reset_password','change_phone_old','change_phone_new','delete_account'));
alter table public.phone_otps add constraint phone_otps_delivery_check check (delivery_state in ('pending','sent','failed'));

-- One reservation per phone every 60s, at most 10/day per phone and 200/day
-- globally, across all purposes. Attempts count even when a provider times out.
create function public.reserve_phone_otp(p_phone text,p_purpose text,p_hash text,p_request uuid)
returns jsonb language plpgsql security definer set search_path=public as $$
declare d date := (now() at time zone 'Asia/Shanghai')::date; latest timestamptz;
begin
  if p_phone !~ '^\+861[3-9][0-9]{9}$' or p_purpose not in
    ('register','login','reset_password','change_phone_old','change_phone_new','delete_account')
    or p_hash !~ '^[0-9a-f]{64}$' or p_request is null then
    raise exception 'invalid_sms_reservation';
  end if;
  -- Short global reservation transaction prevents quota/cooldown races across workers.
  perform pg_advisory_xact_lock(79433701);
  select max(created_at) into latest from public.phone_otps where phone=p_phone;
  if latest > now()-interval '60 seconds' then
    return jsonb_build_object('error','cooldown','retry_after',greatest(1,ceil(extract(epoch from latest+interval '60 seconds'-now()))::int));
  end if;
  if coalesce((select count from public.phone_sms_quota where phone=p_phone and day=d),0)>=10 then
    return jsonb_build_object('error','phone_quota');
  end if;
  if coalesce((select count from public.phone_sms_quota where phone='__autocare_global__' and day=d),0)>=200 then
    return jsonb_build_object('error','global_quota');
  end if;
  perform public.take_sms_quota(p_phone,d,10);
  perform public.take_sms_quota('__autocare_global__',d,200);
  insert into public.phone_otps(phone,purpose,code_hash,request_id,delivery_state,attempts,created_at,expires_at,consumed_at,provider)
    values(p_phone,p_purpose,p_hash,p_request,'pending',0,now(),now()+interval '5 minutes',null,null)
    on conflict(phone,purpose) do update set code_hash=excluded.code_hash,request_id=excluded.request_id,
      delivery_state='pending',attempts=0,created_at=excluded.created_at,expires_at=excluded.expires_at,consumed_at=null,provider=null;
  return '{}'::jsonb;
end $$;

create function public.finish_phone_otp(p_phone text,p_purpose text,p_request uuid,p_sent boolean,p_provider text)
returns boolean language plpgsql security definer set search_path=public as $$
begin
  update public.phone_otps set delivery_state=case when p_sent then 'sent' else 'failed' end,provider=p_provider
    where phone=p_phone and purpose=p_purpose and request_id=p_request and delivery_state='pending';
  return found;
end $$;

-- Wrong guesses are incremented under a row lock. Correct final verification
-- consumes the code in the same transaction, so parallel submissions cannot reuse it.
create function public.verify_phone_otp(p_phone text,p_purpose text,p_hash text,p_consume boolean default false)
returns text language plpgsql security definer set search_path=public as $$
declare r public.phone_otps;
begin
  select * into r from public.phone_otps where phone=p_phone and purpose=p_purpose for update;
  if not found then return 'missing'; end if;
  if r.delivery_state<>'sent' then return 'not_sent'; end if;
  if r.consumed_at is not null then return 'consumed'; end if;
  if r.expires_at<=now() then return 'expired'; end if;
  if r.attempts>=5 then return 'attempts'; end if;
  if r.code_hash is distinct from p_hash then
    update public.phone_otps set attempts=attempts+1 where phone=p_phone and purpose=p_purpose;
    return 'invalid';
  end if;
  if p_consume then
    update public.phone_otps set consumed_at=now() where phone=p_phone and purpose=p_purpose;
  end if;
  return 'ok';
end $$;

create function public.consume_phone_change_otps(p_old_phone text,p_old_hash text,p_new_phone text,p_new_hash text)
returns text language plpgsql security definer set search_path=public as $$
declare result text;
begin
  -- Stable row-lock order for requests involving the same two numbers.
  perform 1 from public.phone_otps where
    (phone=p_old_phone and purpose='change_phone_old') or (phone=p_new_phone and purpose='change_phone_new')
    order by phone,purpose for update;
  result:=public.verify_phone_otp(p_old_phone,'change_phone_old',p_old_hash,false);
  if result<>'ok' then return 'old:'||result; end if;
  result:=public.verify_phone_otp(p_new_phone,'change_phone_new',p_new_hash,false);
  if result<>'ok' then return 'new:'||result; end if;
  update public.phone_otps set consumed_at=now() where
    (phone=p_old_phone and purpose='change_phone_old') or (phone=p_new_phone and purpose='change_phone_new');
  return 'ok';
end $$;

revoke all on function public.reserve_phone_otp(text,text,text,uuid) from public,anon,authenticated;
revoke all on function public.finish_phone_otp(text,text,uuid,boolean,text) from public,anon,authenticated;
revoke all on function public.verify_phone_otp(text,text,text,boolean) from public,anon,authenticated;
revoke all on function public.consume_phone_change_otps(text,text,text,text) from public,anon,authenticated;
grant execute on function public.reserve_phone_otp(text,text,text,uuid) to service_role;
grant execute on function public.finish_phone_otp(text,text,uuid,boolean,text) to service_role;
grant execute on function public.verify_phone_otp(text,text,text,boolean) to service_role;
grant execute on function public.consume_phone_change_otps(text,text,text,text) to service_role;
