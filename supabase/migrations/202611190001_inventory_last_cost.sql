-- 入库默认单价：库存读取接口增加 last_cost（该商品最近一次入库批次的单价，没有批次为空）。
-- 商品的 cost 是按现存批次加权平均出来的，不能当作「上次进价」。
do $$
declare def text; patched text;
begin
  select pg_get_functiondef('public.inventory_read(uuid,uuid)'::regprocedure) into def;
  patched := replace(def, E' ''low'',p.active and',
    E' ''last_cost'',(select b.cost from inventory_batches b where b.product_id=p.id and b.store_id=p_store order by b.received_on desc,b.created_at desc,b.id desc limit 1),\n ''low'',p.active and');
  if patched = def then raise exception 'inventory_read anchor not found'; end if;
  execute patched;
end $$;
