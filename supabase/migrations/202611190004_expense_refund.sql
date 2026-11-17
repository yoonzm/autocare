-- 退回供应商的出库单可以同步一笔「退款开支」：负数金额，记在「材料采购」下冲减本月材料采购。
-- 负数只允许由库存单据同步生成（source_document 非空）；手工记账、编辑仍然必须大于 0，这些校验不变。
-- 同步的开支是锁定的（不能直接改），作废出库单时现有逻辑会把它一起标记删除。
alter table public.expense_entries drop constraint expense_entries_amount_check;
alter table public.expense_entries add constraint expense_entries_amount_check
  check (amount <> 0 and (amount > 0 or source_document is not null));

do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.inventory_expense_sync()'::regprocedure) into def;
  patched := replace(def,
    '   elsif new.kind=''check'' then select coalesce(sum(cost),0)',
    E'   elsif new.kind=''out'' and new.payload->>''reason''=''退回供应商'' and coalesce((new.payload->>''sync_expense'')::boolean,false)\n'
    || E'     and coalesce((new.payload->>''refund_amount'')::numeric,0)>0 then amount:=-(new.payload->>''refund_amount'')::numeric;\n'
    || '   elsif new.kind=''check'' then select coalesce(sum(cost),0)');
  if patched = def then raise exception 'refund anchor not found'; end if;
  def := patched;
  patched := replace(def, '   if amount>0 then', '   if amount<>0 then');
  if patched = def then raise exception 'amount anchor not found'; end if;
  def := patched;
  -- 分类：入库和退款都记「材料采购」，盘点亏损记「损耗」。
  patched := replace(def, 'case when new.kind=''in'' then ''材料采购'' else ''损耗'' end', 'case when new.kind in (''in'',''out'') then ''材料采购'' else ''损耗'' end');
  if patched = def then raise exception 'category anchor not found'; end if;
  def := patched;
  -- 退款是减少支出，不受预算上限拦截。
  patched := replace(def, 'if rule->>''policy''=''block'' and used+amount>', 'if amount>0 and rule->>''policy''=''block'' and used+amount>');
  if patched = def then raise exception 'budget anchor not found'; end if;
  def := patched;
  patched := replace(def, 'coalesce(new.payload->>''note'','''')', 'coalesce(nullif(new.payload->>''note'',''''),case when new.kind=''out'' then ''退回供应商退款'' else '''' end)');
  if patched = def then raise exception 'note anchor not found'; end if;
  execute patched;
end $$;
