-- 入库「运费计入商品成本」（设计稿 StockInFreight）。
-- payload.freight_to_cost = true 且 freight > 0 且提交入库时：运费按各商品金额占商品合计的比例摊入各批次成本，
-- 批次单价 = 入库单价 + 分摊的运费 ÷ 数量（单价为 0 的赠品不分摊）；
-- 单据 total（应付合计）= 商品合计 + 运费，保持不变，同步开支金额也等于它。
-- 批次单价只有两位小数：向下取整后的尾差记在单据运费里，保证 total 与页面显示的应付合计一致。
create function inventory_allocate_freight(p_lines jsonb, p_freight numeric) returns jsonb
language plpgsql immutable set search_path=public as $$
declare n int; i int; q numeric[]; c numeric[]; nc numeric[]; exact numeric:=0; target numeric:=0; alloc numeric; guard int:=0; worst int; out jsonb:='[]';
begin
 n:=jsonb_array_length(p_lines);
 for i in 1..n loop
   q[i]:=(p_lines->(i-1)->>'quantity')::numeric; c[i]:=(p_lines->(i-1)->>'cost')::numeric;
   exact:=exact+q[i]*c[i]; target:=target+round(q[i]*c[i],2);
 end loop;
 if exact<=0 then return jsonb_build_object('lines',p_lines,'freight',p_freight); end if;
 target:=target+p_freight;
 for i in 1..n loop nc[i]:=floor(c[i]*(1+p_freight/exact)*100)/100; end loop;
 loop
   alloc:=0; for i in 1..n loop alloc:=alloc+round(q[i]*nc[i],2); end loop;
   exit when alloc<=target or guard>500;
   worst:=null;
   for i in 1..n loop if nc[i]>c[i] and (worst is null or nc[i]*q[i]>nc[worst]*q[worst]) then worst:=i; end if; end loop;
   exit when worst is null;
   nc[worst]:=nc[worst]-0.01; guard:=guard+1;
 end loop;
 for i in 1..n loop out:=out||jsonb_set(p_lines->(i-1),'{cost}',to_jsonb(nc[i])); end loop;
 return jsonb_build_object('lines',out,'freight',greatest(target-alloc,0));
end $$;
revoke all on function inventory_allocate_freight(jsonb,numeric) from public,anon,authenticated;
grant execute on function inventory_allocate_freight(jsonb,numeric) to service_role;

do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.inventory_document_save(uuid,uuid,text,jsonb,integer,boolean)'::regprocedure) into def;
  patched := replace(def, 'declare submitted jsonb:=p_payload;', 'declare submitted jsonb:=p_payload; base_payload jsonb; alloc jsonb;');
  if patched = def then raise exception 'declare anchor not found'; end if;
  def := patched;
  patched := replace(def, ' result:=inventory_document_save_base(p_store,p_id,p_kind,p_payload,p_revision,p_post);',
    E' base_payload:=p_payload;\n'
    || E' if p_post and p_kind=''in'' and coalesce((p_payload->>''freight_to_cost'')::boolean,false) and coalesce((p_payload->>''freight'')::numeric,0)>0 then\n'
    || E'   alloc:=inventory_allocate_freight(p_payload->''lines'',(p_payload->>''freight'')::numeric);\n'
    || E'   base_payload:=jsonb_set(jsonb_set(p_payload,''{lines}'',alloc->''lines''),''{freight}'',alloc->''freight'');\n'
    || E' end if;\n'
    || E' result:=inventory_document_save_base(p_store,p_id,p_kind,base_payload,p_revision,p_post);');
  if patched = def then raise exception 'save anchor not found'; end if;
  def := patched;
  patched := replace(def, 'payload=payload||jsonb_build_object(''snapshots'',before_p)', 'payload=p_payload||jsonb_build_object(''snapshots'',before_p)');
  if patched = def then raise exception 'payload anchor not found'; end if;
  execute patched;
end $$;
