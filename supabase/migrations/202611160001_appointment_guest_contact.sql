-- 散客预约：姓名、手机号（到店提醒）和车牌随预约一起保存；会员预约仍取会员资料和车辆。
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.save_appointment(uuid,jsonb,text)'::regprocedure) into def;
  patched := replace(def,
    'case when v_member is null then ''散客'' else m.name end,coalesce(m.phone,''''),coalesce(v_plate,''''),',
    'case when v_member is null then coalesce(nullif(trim(p_input->>''guest_name''),''''),''散客'') else m.name end,'
    || 'case when v_member is null then coalesce(nullif(trim(p_input->>''guest_phone''),''''),'''') else coalesce(m.phone,'''') end,'
    || 'case when v_member is null then coalesce(nullif(upper(trim(p_input->>''guest_plate'')),''''),'''') else coalesce(v_plate,'''') end,');
  if patched = def then raise exception 'save_appointment guest insert not found'; end if;
  execute patched;
end $$;
