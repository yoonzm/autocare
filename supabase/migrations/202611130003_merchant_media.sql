-- 门店照片与施工照片：私有存储、服务端归属校验、限额与幂等上传。
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('merchant-media','merchant-media',false,5242880,array['image/jpeg','image/png'])
on conflict(id) do nothing;

create table public.merchant_media (
 id uuid primary key,
 store_id uuid not null references public.stores(id) on delete cascade,
 kind text not null check(kind in ('store','task')),
 target_id uuid not null,
 path text not null unique,
 digest text not null,
 state text not null default 'pending' check(state in ('pending','ready','deleted')),
 created_at timestamptz not null default now()
);
create index merchant_media_target on public.merchant_media(store_id,kind,target_id,created_at);
alter table public.merchant_media enable row level security;
revoke all on public.merchant_media from public,anon,authenticated;
grant all on public.merchant_media to service_role;

create function public.merchant_media_access(p_store uuid,p_user uuid,p_staff uuid,p_kind text,p_target uuid)
returns void language plpgsql security definer set search_path=public as $$
begin
 if p_kind='store' then
  if p_target is null or p_target<>p_store or not exists(select 1 from stores where id=p_store and owner_id=p_user and archived_at is null) then
   raise exception 'media_forbidden' using errcode='42501';
  end if;
 elsif p_kind='task' then
  if not exists(select 1 from appointments a join store_staff s on s.store_id=a.store_id and s.resource_id=a.technician_id
   where a.id=p_target and a.store_id=p_store and s.id=p_staff and s.status='active' and a.status in ('waiting','arrived','done')) then
   raise exception 'media_forbidden' using errcode='42501';
  end if;
 else raise exception 'media_kind_invalid'; end if;
end $$;

create function public.merchant_media_mutate(p_store uuid,p_user uuid,p_staff uuid,p_kind text,p_target uuid,p_action text,
 p_id uuid default null,p_digest text default null,p_extension text default null)
returns jsonb language plpgsql security definer set search_path=public as $$
declare r merchant_media; limit_count integer;
begin
 perform pg_advisory_xact_lock(hashtextextended('media:'||p_store::text||p_kind||p_target::text,0));
 perform merchant_media_access(p_store,p_user,p_staff,p_kind,p_target);
 if p_action='list' then
  return jsonb_build_object('items',coalesce((select jsonb_agg(to_jsonb(m) order by m.created_at,m.id) from merchant_media m
   where m.store_id=p_store and m.kind=p_kind and m.target_id=p_target and m.state='ready'),'[]'::jsonb));
 end if;
 if p_id is null then raise exception 'media_id_invalid'; end if;
 select * into r from merchant_media where id=p_id for update;
 if r.id is not null and (r.store_id<>p_store or r.kind<>p_kind or r.target_id<>p_target) then
  raise exception 'media_forbidden' using errcode='42501';
 end if;
 if p_action='begin' then
  if p_digest is null or p_digest !~ '^[0-9a-f]{64}$' or p_extension not in ('jpg','png') or p_extension is null then raise exception 'media_invalid'; end if;
  if r.id is not null then
   if r.digest<>p_digest or r.state='deleted' then raise exception 'media_request_reused'; end if;
   return to_jsonb(r);
  end if;
  limit_count:=case when p_kind='store' then 9 else 6 end;
  -- 失去客户端的未完成预约占位在24小时后过期，重试仍使用原上传ID。
  update merchant_media set state='deleted' where store_id=p_store and kind=p_kind and target_id=p_target
    and state='pending' and created_at<now()-interval '24 hours';
  if (select count(*) from merchant_media where store_id=p_store and kind=p_kind and target_id=p_target and state<>'deleted')>=limit_count then
   raise exception 'media_limit';
  end if;
  insert into merchant_media(id,store_id,kind,target_id,path,digest)
   values(p_id,p_store,p_kind,p_target,p_store::text||'/'||p_kind||'/'||p_target::text||'/'||p_id::text||'.'||p_extension,p_digest) returning * into r;
 elsif p_action='finish' then
  if r.id is null or r.state='deleted' then raise exception 'media_missing'; end if;
  update merchant_media set state='ready' where id=p_id returning * into r;
 elsif p_action='remove' then
  if r.id is null then return null; end if;
  update merchant_media set state='deleted' where id=p_id returning * into r;
 else raise exception 'media_action_invalid'; end if;
 return to_jsonb(r);
end $$;
revoke all on function public.merchant_media_access(uuid,uuid,uuid,text,uuid),
 public.merchant_media_mutate(uuid,uuid,uuid,text,uuid,text,uuid,text,text) from public,anon,authenticated;
grant execute on function public.merchant_media_access(uuid,uuid,uuid,text,uuid),
 public.merchant_media_mutate(uuid,uuid,uuid,text,uuid,text,uuid,text,text) to service_role;
