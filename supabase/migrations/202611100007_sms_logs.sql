-- 后台「短信记录」：每次验证码短信的发送记录。
-- 按用户决定，验证码明文保存、手机号不脱敏，仅超级管理员经 admin-v1 查看；表本身只对 service_role 开放。
-- TODO sms_log_cleanup: 验证码明文尚无定时清理任务，需要后续补充保留期与清理。
create table public.sms_logs (
  id uuid primary key default gen_random_uuid(),
  request_id uuid unique,
  phone text not null,
  purpose text not null,
  kind text not null default 'code' check (kind in ('code', 'notice')),
  code text,
  content text not null default '',
  provider text,
  sign_name text not null default '',
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  error text not null default '',
  attempts integer not null default 0,
  store_name text not null default '',
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  expires_at timestamptz,
  consumed_at timestamptz
);
create index sms_logs_created_idx on public.sms_logs (created_at desc, id desc);
create index sms_logs_phone_idx on public.sms_logs (phone, created_at desc);
create index sms_logs_failed_idx on public.sms_logs (created_at desc) where status = 'failed';
alter table public.sms_logs enable row level security;
revoke all on public.sms_logs from public, anon, authenticated;
grant select, insert, update on public.sms_logs to service_role;

-- 预留：同时写入明文验证码与短信内容（旧调用方不传则为空）。
drop function public.reserve_phone_otp(text, text, text, uuid);
create function public.reserve_phone_otp(p_phone text, p_purpose text, p_hash text, p_request uuid,
  p_code text default null, p_content text default '', p_sign text default '')
returns jsonb language plpgsql security definer set search_path=public as $$
declare d date := (now() at time zone 'Asia/Shanghai')::date; latest timestamptz;
begin
  if p_phone !~ '^\+861[3-9][0-9]{9}$' or p_purpose not in
    ('register','login','reset_password','change_phone_old','change_phone_new','delete_account')
    or p_hash !~ '^[0-9a-f]{64}$' or p_request is null then
    raise exception 'invalid_sms_reservation';
  end if;
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
  insert into public.sms_logs(request_id, phone, purpose, code, content, sign_name, expires_at)
    values(p_request, p_phone, p_purpose, p_code, coalesce(p_content, ''), coalesce(p_sign, ''), now()+interval '5 minutes')
    on conflict (request_id) do nothing;
  return '{}'::jsonb;
end $$;

drop function public.finish_phone_otp(text, text, uuid, boolean, text);
create function public.finish_phone_otp(p_phone text, p_purpose text, p_request uuid, p_sent boolean, p_provider text,
  p_error text default null)
returns boolean language plpgsql security definer set search_path=public as $$
begin
  update public.phone_otps set delivery_state=case when p_sent then 'sent' else 'failed' end,provider=p_provider
    where phone=p_phone and purpose=p_purpose and request_id=p_request and delivery_state='pending';
  if not found then return false; end if;
  update public.sms_logs set status=case when p_sent then 'sent' else 'failed' end, provider=p_provider,
    sent_at=case when p_sent then now() else null end, error=coalesce(left(p_error, 300), '')
    where request_id=p_request;
  return true;
end $$;

create or replace function public.verify_phone_otp(p_phone text,p_purpose text,p_hash text,p_consume boolean default false)
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
    update public.sms_logs set attempts=attempts+1 where request_id=r.request_id;
    return 'invalid';
  end if;
  if p_consume then
    update public.phone_otps set consumed_at=now() where phone=p_phone and purpose=p_purpose;
    update public.sms_logs set consumed_at=now() where request_id=r.request_id;
  end if;
  return 'ok';
end $$;

create or replace function public.consume_phone_change_otps(p_old_phone text,p_old_hash text,p_new_phone text,p_new_hash text)
returns text language plpgsql security definer set search_path=public as $$
declare result text;
begin
  perform 1 from public.phone_otps where
    (phone=p_old_phone and purpose='change_phone_old') or (phone=p_new_phone and purpose='change_phone_new')
    order by phone,purpose for update;
  result:=public.verify_phone_otp(p_old_phone,'change_phone_old',p_old_hash,false);
  if result<>'ok' then return 'old:'||result; end if;
  result:=public.verify_phone_otp(p_new_phone,'change_phone_new',p_new_hash,false);
  if result<>'ok' then return 'new:'||result; end if;
  update public.sms_logs set consumed_at=now() where request_id in (
    select request_id from public.phone_otps where
      (phone=p_old_phone and purpose='change_phone_old') or (phone=p_new_phone and purpose='change_phone_new'));
  update public.phone_otps set consumed_at=now() where
    (phone=p_old_phone and purpose='change_phone_old') or (phone=p_new_phone and purpose='change_phone_new');
  return 'ok';
end $$;

revoke all on function public.reserve_phone_otp(text,text,text,uuid,text,text,text) from public,anon,authenticated;
revoke all on function public.finish_phone_otp(text,text,uuid,boolean,text,text) from public,anon,authenticated;
grant execute on function public.reserve_phone_otp(text,text,text,uuid,text,text,text) to service_role;
grant execute on function public.finish_phone_otp(text,text,uuid,boolean,text,text) to service_role;

-- 后台读取：只有启用的超级管理员，且已改过初始密码。
create function public.admin_sms_guard(p_actor uuid, p_session uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a jsonb;
begin
  a := public.admin_identity(p_actor, p_session);
  if (a->>'must_change')::boolean then raise exception '请先修改初始或临时密码' using errcode='42501'; end if;
  if a->>'role' <> 'superAdmin' then raise exception '需要超级管理员权限' using errcode='42501'; end if;
  return a;
end $$;

create function public.admin_sms_list(p_actor uuid, p_session uuid, p_kind text default 'all', p_phone text default '',
  p_before_at timestamptz default null, p_before_id uuid default null, p_limit integer default 30)
returns jsonb language plpgsql security definer set search_path=public as $$
declare digits text := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g'); lim integer := least(greatest(coalesce(p_limit, 30), 1), 50);
  rows jsonb; n integer; failed integer;
begin
  perform public.admin_sms_guard(p_actor, p_session);
  if p_kind not in ('all', 'code', 'notice', 'failed') then raise exception '短信类型无效'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id desc), '[]'::jsonb), count(*) into rows, n from (
    select id, phone, purpose, kind, code, content, provider, sign_name, status, error, attempts, store_name,
      created_at, sent_at, expires_at, consumed_at
    from public.sms_logs
    where (p_kind = 'all' or (p_kind = 'failed' and status = 'failed') or (p_kind in ('code', 'notice') and kind = p_kind))
      and (digits = '' or regexp_replace(phone, '\D', '', 'g') like '%' || digits || '%')
      and (p_before_at is null or (created_at, id) < (p_before_at, coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid)))
    order by created_at desc, id desc limit lim + 1) x;
  select count(*) into failed from public.sms_logs where status = 'failed';
  -- 取了 lim+1 条判断是否还有更多，返回前去掉多出的一条
  return jsonb_build_object('items', case when n > lim then rows - lim else rows end, 'more', n > lim,
    'failed_count', failed, 'now', now());
end $$;

create function public.admin_sms_get(p_actor uuid, p_session uuid, p_id uuid) returns jsonb
language plpgsql security definer set search_path=public as $$
declare a jsonb; r public.sms_logs;
begin
  a := public.admin_sms_guard(p_actor, p_session);
  select * into r from public.sms_logs where id = p_id;
  if not found then raise exception '短信记录不存在' using errcode='P0002'; end if;
  insert into public.admin_audit_logs(actor_id, action, target, detail)
    values((a->>'id')::uuid, 'sms_view', p_id::text, jsonb_build_object('phone', r.phone, 'purpose', r.purpose));
  return jsonb_build_object('item', to_jsonb(r), 'now', now());
end $$;

revoke all on function public.admin_sms_guard(uuid,uuid), public.admin_sms_list(uuid,uuid,text,text,timestamptz,uuid,integer),
  public.admin_sms_get(uuid,uuid,uuid) from public,anon,authenticated;
grant execute on function public.admin_sms_guard(uuid,uuid), public.admin_sms_list(uuid,uuid,text,text,timestamptz,uuid,integer),
  public.admin_sms_get(uuid,uuid,uuid) to service_role;
