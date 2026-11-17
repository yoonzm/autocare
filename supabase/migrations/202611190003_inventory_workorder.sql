-- 出库「关联工单」：工单是进行中的预约（客户已到店、尚未完成）。
-- payload.workorder_id = 预约 id，须属于本门店；显示文字 payload.workorder 由数据库按「车牌 + 服务项目」生成，不信任客户端。
-- 旧版的 payload.order_id（订单）校验保持不变，历史单据照常显示。
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.inventory_document_save(uuid,uuid,text,jsonb,integer,boolean)'::regprocedure) into def;
  patched := replace(def,
    ' if p_kind=''check'' and exists(select 1 from inventory_documents where store_id=p_store and kind=''check'' and status=''draft'' and id<>p_id) then raise exception ''count_in_progress''; end if;',
    E' if nullif(p_payload->>''workorder_id'','''') is not null then\n'
    || E'   if not exists(select 1 from appointments where store_id=p_store and id=(p_payload->>''workorder_id'')::uuid) then raise exception ''order_not_found''; end if;\n'
    || E'   p_payload:=jsonb_set(p_payload,''{workorder}'',to_jsonb((select concat_ws('' '',nullif(a.vehicle_plate,''''),nullif((select string_agg(x->>''name'','' · '') from jsonb_array_elements(a.items) x),'''')) from appointments a where a.id=(p_payload->>''workorder_id'')::uuid and a.store_id=p_store)));\n'
    || E' end if;\n'
    || ' if p_kind=''check'' and exists(select 1 from inventory_documents where store_id=p_store and kind=''check'' and status=''draft'' and id<>p_id) then raise exception ''count_in_progress''; end if;');
  if patched = def then raise exception 'workorder anchor not found'; end if;
  execute patched;
end $$;
