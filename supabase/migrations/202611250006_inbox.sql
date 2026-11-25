-- 站内消息：员工与老板独立收件箱；旧员工接口仍可使用。
alter table public.staff_messages alter column staff_id drop not null;
alter table public.staff_messages add column owner_id uuid references auth.users(id) on delete cascade;
alter table public.staff_messages add constraint staff_messages_recipient_check check ((staff_id is null) <> (owner_id is null));
create index staff_messages_recipient_page_idx on public.staff_messages(store_id,staff_id,created_at desc,id desc) where staff_id is not null;
create index staff_messages_owner_page_idx on public.staff_messages(store_id,owner_id,created_at desc,id desc) where owner_id is not null;

-- 接收人只能由云函数的已验证会话确定，客户端不得指定。
create function public.inbox_assert_recipient(p_store uuid,p_staff uuid,p_owner uuid) returns void
language plpgsql stable security definer set search_path=public as $$
begin
 if (p_staff is null) = (p_owner is null) then raise exception 'inbox_forbidden' using errcode='42501'; end if;
 if p_owner is not null then
  if not exists(select 1 from stores where id=p_store and owner_id=p_owner) then raise exception 'inbox_forbidden' using errcode='42501'; end if;
 elsif not exists(select 1 from store_staff where id=p_staff and store_id=p_store and status='active') then
  raise exception 'inbox_forbidden' using errcode='42501';
 end if;
end $$;

create function public.inbox_list(p_store uuid,p_staff uuid,p_owner uuid,p_kind text default null,p_before_at timestamptz default null,p_before_id uuid default null)
returns jsonb language plpgsql stable security definer set search_path=public as $$
declare rows jsonb; last_row jsonb; unread bigint;
begin
 perform inbox_assert_recipient(p_store,p_staff,p_owner);
 if p_kind is not null and p_kind not in ('task','arrival','system') then raise exception 'inbox_invalid'; end if;
 if (p_before_at is null) <> (p_before_id is null) then raise exception 'inbox_invalid'; end if;
 select coalesce(jsonb_agg(to_jsonb(m) order by m.created_at desc,m.id desc),'[]'::jsonb) into rows from (
  select id,kind,title,body,created_at,read_at from staff_messages
  where store_id=p_store and (staff_id=p_staff or owner_id=p_owner)
   and (p_kind is null or kind=p_kind)
   and (p_before_at is null or (created_at,id)<(p_before_at,p_before_id))
  order by created_at desc,id desc limit 31
 ) m;
 select count(*) into unread from staff_messages where store_id=p_store and (staff_id=p_staff or owner_id=p_owner) and read_at is null;
 if jsonb_array_length(rows)>30 then
  rows:=rows-30;last_row:=rows->29;
 end if;
 return jsonb_build_object('items',rows,'unread',unread,'snapshot_at',clock_timestamp(),'latest',(select id from staff_messages where store_id=p_store and (staff_id=p_staff or owner_id=p_owner) order by created_at desc,id desc limit 1),
  'next',case when last_row is not null then jsonb_build_object('at',last_row->>'created_at','id',last_row->>'id') else null end);
end $$;

create function public.inbox_unread(p_store uuid,p_staff uuid,p_owner uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
begin
 perform inbox_assert_recipient(p_store,p_staff,p_owner);
 return jsonb_build_object('unread',(select count(*) from staff_messages where store_id=p_store and (staff_id=p_staff or owner_id=p_owner) and read_at is null),'latest',(select id from staff_messages where store_id=p_store and (staff_id=p_staff or owner_id=p_owner) order by created_at desc,id desc limit 1));
end $$;

create function public.inbox_read(p_store uuid,p_staff uuid,p_owner uuid,p_id uuid default null,p_before timestamptz default null) returns jsonb
language plpgsql security definer set search_path=public as $$
begin
 perform inbox_assert_recipient(p_store,p_staff,p_owner);
 if (p_id is null) = (p_before is null) or p_before>clock_timestamp() then raise exception 'inbox_invalid'; end if;
 if p_id is not null and not exists(select 1 from staff_messages where id=p_id and store_id=p_store and (staff_id=p_staff or owner_id=p_owner)) then
  raise exception 'inbox_not_found' using errcode='P0002';
 end if;
 update staff_messages set read_at=clock_timestamp()
 where store_id=p_store and (staff_id=p_staff or owner_id=p_owner) and read_at is null
 and ((p_id is not null and id=p_id) or (p_id is null and created_at<=p_before));
 return inbox_unread(p_store,p_staff,p_owner);
end $$;

-- 链接白名单；每次点击重新核对门店、角色权限和业务归属。
create function public.inbox_target(p_store uuid,p_staff uuid,p_owner uuid,p_id uuid) returns jsonb
language plpgsql stable security definer set search_path=public as $$
declare m staff_messages; s store_staff; target uuid; h held_orders; role_name text;
begin
 perform inbox_assert_recipient(p_store,p_staff,p_owner);
 select * into m from staff_messages where id=p_id and store_id=p_store and (staff_id=p_staff or owner_id=p_owner);
 if not found then raise exception 'inbox_not_found' using errcode='P0002'; end if;
 if p_staff is not null then select * into s from store_staff where id=p_staff; end if;
 role_name:=coalesce(s.role,'owner');
 if m.link='' then return jsonb_build_object('type','none'); end if;
 if m.link ~ '^(StTaskDetail|Hold|Order):[0-9a-fA-F-]{36}$' then
  begin target:=split_part(m.link,':',2)::uuid; exception when invalid_text_representation then return jsonb_build_object('type','unavailable','message','这条消息的业务链接已失效'); end;
  if m.link like 'Order:%' then
   if exists(select 1 from orders o where o.id=target and o.store_id=p_store and (role_name='owner' or staff_has_permission(p_store,role_name,'order_view_all') or (staff_has_permission(p_store,role_name,'order_view_own') and s.resource_id=any(o.technician_ids)))) then
    return jsonb_build_object('type','order','id',target);
   end if;
  else
   select * into h from held_orders where store_id=p_store and cancelled_at is null and (id=target or appointment_id=target) order by (id=target) desc,created_at desc limit 1;
   if h.id is not null then
    if m.link like 'StTaskDetail:%' and s.resource_id=any(h.technician_ids) and staff_has_permission(p_store,role_name,'order_view_own') then
     return jsonb_build_object('type','task','id',h.id);
    elsif m.link like 'Hold:%' and (role_name='owner' or staff_has_permission(p_store,role_name,'cashier')) then
     if h.settled_at is null then return jsonb_build_object('type','holds');
     elsif h.order_id is not null and (role_name='owner' or staff_has_permission(p_store,role_name,'order_view_all')) then return jsonb_build_object('type','order','id',h.order_id); end if;
    end if;
   elsif m.link like 'StTaskDetail:%' and p_staff is not null and staff_has_permission(p_store,role_name,'arrivals_today') and exists(select 1 from appointments where id=target and store_id=p_store and technician_id=s.resource_id and status in ('waiting','arrived')) then
    return jsonb_build_object('type','arrivals');
   end if;
  end if;
 elsif m.link='StCashQueue' and (role_name='owner' or staff_has_permission(p_store,role_name,'cashier')) then
  return jsonb_build_object('type','holds');
 elsif m.link='StPerf' and p_staff is not null and staff_has_permission(p_store,role_name,'perf_view_own') then
  return jsonb_build_object('type','performance');
 elsif m.link='StMine' and p_staff is not null then return jsonb_build_object('type','profile');
 end if;
 return jsonb_build_object('type','unavailable','message','该业务已删除、已转交，或你已无权查看');
end $$;

-- 统一待结算事件：老板、店长、前台各收一条，不因其他字段更新重复发送。
create function public.inbox_hold_ready() returns trigger language plpgsql security definer set search_path=public as $$
begin
 if new.status<>'待结算' or new.cancelled_at is not null or new.settled_at is not null then return new; end if;
 if tg_op='UPDATE' and old.status='待结算' then return new; end if;
 insert into staff_messages(store_id,owner_id,kind,title,body,link)
 select new.store_id,owner_id,'system','有订单待收银',coalesce(nullif(new.vehicle_plate,''),'车辆')||' 已进入待结算，请核对后收银。','Hold:'||new.id from stores where id=new.store_id;
 insert into staff_messages(store_id,staff_id,kind,title,body,link)
 select new.store_id,id,'system','施工已完成待收银',coalesce(nullif(new.vehicle_plate,''),'车辆')||' 已进入待结算，请核对后收银。','Hold:'||new.id
 from store_staff where store_id=new.store_id and status='active' and role in ('manager','cashier') and staff_has_permission(new.store_id,role,'cashier');
 return new;
end $$;
create trigger held_orders_inbox_ready after insert or update of status on held_orders for each row execute function inbox_hold_ready();
-- 由上述状态触发器发送，移除完工函数内的旧通知，避免同一完工发两次。
do $$ declare src text; next_src text; begin
 src:=pg_get_functiondef('public.staff_task_finish(uuid,uuid,uuid)'::regprocedure);
 next_src:=regexp_replace(src,'  insert into public.staff_messages\(store_id, staff_id, kind, title, body, link\)[\s\S]*?x.role in \(''cashier'', ''manager''\);','');
 if src=next_src then raise exception 'staff_task_finish message block not found'; end if;
 execute next_src;
end $$;

create function public.inbox_owner_checkout() returns trigger language plpgsql security definer set search_path=public as $$
begin
 if new.status<>'completed' then return new; end if;
 insert into staff_messages(store_id,owner_id,kind,title,body,link)
 select new.store_id,owner_id,'system','订单已收银',coalesce(nullif(new.vehicle_plate,''),'车辆')||' 已完成收银。','Order:'||new.id from stores where id=new.store_id;
 return new;
end $$;
create trigger orders_owner_inbox after insert on orders for each row execute function inbox_owner_checkout();

revoke all on function inbox_assert_recipient(uuid,uuid,uuid),inbox_list(uuid,uuid,uuid,text,timestamptz,uuid),inbox_unread(uuid,uuid,uuid),inbox_read(uuid,uuid,uuid,uuid,timestamptz),inbox_target(uuid,uuid,uuid,uuid),inbox_hold_ready(),inbox_owner_checkout() from public,anon,authenticated;
grant execute on function inbox_list(uuid,uuid,uuid,text,timestamptz,uuid),inbox_unread(uuid,uuid,uuid),inbox_read(uuid,uuid,uuid,uuid,timestamptz),inbox_target(uuid,uuid,uuid,uuid) to service_role;

-- 非技师没有 resource_id；SQL NULL 不能被当作归属校验通过。
do $$ declare fn text; src text; patched text; begin
 foreach fn in array array['staff_hold_task_json(uuid,uuid,uuid)','staff_task_detail(uuid,uuid,uuid)','staff_task_progress(uuid,uuid,uuid,integer)','staff_task_finish(uuid,uuid,uuid)'] loop
  src:=pg_get_functiondef(('public.'||fn)::regprocedure);
  patched:=replace(src,'not (s.resource_id = any(h.technician_ids))','not coalesce(s.resource_id = any(h.technician_ids), false)');
  if src<>patched then execute patched; end if;
 end loop;
end $$;

-- 收银通知关联真实消费单，技师只能打开归属自己的订单。
create or replace function public.held_order_settled_message() returns trigger
language plpgsql security definer set search_path=public as $$
begin
 if new.submitted_by is not null and old.settled_at is null and new.settled_at is not null then
  insert into staff_messages(store_id,staff_id,kind,title,body,link)
  values(new.store_id,new.submitted_by,'system','订单已收银',left(new.vehicle_plate||' 已完成收银',300),coalesce('Order:'||new.order_id,''));
 end if;
 return new;
end $$;
