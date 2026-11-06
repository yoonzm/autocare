-- Merchant feedback shares the platform support queue; attachments are private.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('support-attachments','support-attachments',false,5242880,array['image/jpeg','image/png'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

alter table public.support_tickets add column category text
 check(category in ('功能建议','问题报告','账号与付费','其他'));
alter table public.support_tickets add column contact text not null default '' check(length(contact)<=200);
create table public.support_uploads (
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id),
 actor_id uuid not null references auth.users(id),
 path text not null unique,
 message_id uuid references public.support_messages(id),
 created_at timestamptz not null default now()
);
create index on public.support_uploads(message_id);
alter table public.support_uploads enable row level security;
revoke all on public.support_uploads from anon,authenticated;
grant all on public.support_uploads to service_role;

alter function public.merchant_support(uuid,uuid,text,jsonb,uuid) rename to merchant_support_legacy;
revoke all on function public.merchant_support_legacy(uuid,uuid,text,jsonb,uuid) from public,anon,authenticated,service_role;
create function public.merchant_support(p_actor uuid,p_session uuid,p_action text,p_input jsonb,p_request uuid default null)
returns jsonb language plpgsql security definer set search_path=public as $$
declare state jsonb; shop uuid; prior support_requests; result jsonb; ticket uuid; message uuid;
 category text:=coalesce(p_input->>'category','其他'); content text:=trim(p_input->>'text');
 contact text:=trim(coalesce(p_input->>'contact','')); files jsonb:=coalesce(p_input->'attachments','[]'::jsonb); n integer;
begin
 if p_action<>'support_create' then
 return merchant_support_legacy(p_actor,p_session,p_action,p_input,p_request);
 end if;
 state:=platform_merchant_session(p_actor,p_session,false);
 if state?'error' then raise exception '%',state->>'error' using errcode='42501'; end if;
 shop:=(state->>'store_id')::uuid;
 if p_request is null then raise exception '缺少请求编号'; end if;
 perform pg_advisory_xact_lock(hashtextextended('support:'||p_actor::text,0));
 select * into prior from support_requests where actor_id=p_actor and request_id=p_request;
 if found then
 if prior.action<>p_action or prior.input<>p_input then raise exception '请求编号已用于其他操作'; end if;
 return prior.result;
 end if;
 if category not in ('功能建议','问题报告','账号与付费','其他') then raise exception '反馈类型无效'; end if;
 if content is null or length(content) not between 1 and 5000 then raise exception '请填写 1–5000 字的问题描述'; end if;
 if length(contact)>200 then raise exception '联系方式不能超过 200 字'; end if;
 if jsonb_typeof(files)<>'array' then raise exception '截图参数无效'; end if;
 if jsonb_array_length(files)>3 then raise exception '最多上传 3 张截图'; end if;
 if exists(select 1 from jsonb_array_elements(files) f where jsonb_typeof(f)<>'string') then raise exception '截图参数无效'; end if;
 if (select count(distinct f) from jsonb_array_elements_text(files) f)<>jsonb_array_length(files) then raise exception '截图不能重复'; end if;
 -- Lock uploaded records before claiming them. A screenshot may belong to one message only.
 perform 1 from support_uploads where id::text in (select jsonb_array_elements_text(files)) order by id for update;
 select count(*) into n from support_uploads where id::text in (select jsonb_array_elements_text(files))
 and store_id=shop and actor_id=p_actor and message_id is null;
 if n<>jsonb_array_length(files) then raise exception '截图不存在、已使用或无权访问'; end if;
 insert into support_tickets(store_id,title,category,contact)
 values(shop,category||' · '||left(regexp_replace(content,'\s+',' ','g'),80),category,contact) returning id into ticket;
 insert into support_messages(ticket_id,from_merchant,actor_id,text) values(ticket,true,p_actor,content) returning id into message;
 update support_uploads set message_id=message where id::text in (select jsonb_array_elements_text(files));
 result:=jsonb_build_object('id',ticket);
 insert into support_requests values(p_actor,p_request,p_action,p_input,result);
 return result;
end $$;
revoke all on function public.merchant_support(uuid,uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function public.merchant_support(uuid,uuid,text,jsonb,uuid) to service_role;

-- Keep the existing snapshot and visual layout. Feedback metadata is included
-- in the first message; private screenshot IDs are resolved by admin-v1 only.
alter function public.admin_snapshot(uuid,uuid,integer) rename to admin_snapshot_legacy;
revoke all on function public.admin_snapshot_legacy(uuid,uuid,integer) from public,anon,authenticated,service_role;
create function public.admin_snapshot(p_actor uuid,p_session uuid,p_offset integer default 0)
returns jsonb language plpgsql security definer set search_path=public as $$
declare result jsonb; tickets jsonb;
begin
 result:=admin_snapshot_legacy(p_actor,p_session,p_offset);
 select coalesce(jsonb_agg(entry.value||jsonb_build_object('msgs',(
 select coalesce(jsonb_agg(jsonb_build_object('from_merchant',m.from_merchant,'text',m.text||
 case when t.category is not null and m.id=(select id from support_messages where ticket_id=t.id order by created_at,id limit 1)
 then E'\n\n反馈类型：'||t.category||case when t.contact<>'' then E'\n联系方式：'||t.contact else '' end else '' end,
 'attachments',coalesce((select jsonb_agg(u.id order by u.created_at,u.id) from support_uploads u where u.message_id=m.id),'[]')) order by m.created_at,m.id),'[]')
 from support_tickets t join support_messages m on m.ticket_id=t.id where t.id=(entry.value->>'id')::uuid
 )) order by entry.ord),'[]') into tickets
 from jsonb_array_elements(result->'tickets') with ordinality entry(value,ord);
 return jsonb_set(result,'{tickets}',tickets);
end $$;
revoke all on function public.admin_snapshot(uuid,uuid,integer) from public,anon,authenticated;
grant execute on function public.admin_snapshot(uuid,uuid,integer) to service_role;
