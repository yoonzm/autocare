-- 完整迁移后执行；断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); shop uuid; pa uuid; pb uuid; pc uuid; d jsonb; d2 jsonb; id1 uuid:=gen_random_uuid(); id2 uuid:=gen_random_uuid();
  payload jsonb;
begin
  insert into auth.users(id,phone) values(owner_u,'8613900000041');
  insert into public.stores(owner_id,name,phone) values(owner_u,'运费测试店','13900000041') returning id into shop;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(shop,'商品A','洗护','件',0,0) returning id into pa;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(shop,'商品B','洗护','件',0,0) returning id into pb;
  insert into public.inventory_products(store_id,name,category,unit,safe,cost) values(shop,'赠品C','洗护','件',0,0) returning id into pc;
  payload:=jsonb_build_object('supplier','运费供应商','date','2026-11-17','payment','微信','sync_expense',true,'freight',10,'freight_to_cost',true,
    'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',3,'cost',10),jsonb_build_object('id',pb,'quantity',2,'cost',3.33),jsonb_build_object('id',pc,'quantity',1,'cost',0)));

  -- 运费计入成本：按金额比例摊入批次，赠品不分摊；应付合计 = 商品合计 + 运费
  d:=public.inventory_document_save(shop,id1,'in',payload,0,true);
  assert (d->>'total')::numeric=46.66,'应付合计仍是 商品合计 36.66 + 运费 10，实际 '||(d->>'total');
  assert (select cost from public.inventory_batches where product_id=pa)=12.72,'A 批次成本含运费';
  assert (select cost from public.inventory_batches where product_id=pb)=4.23,'B 批次成本含运费';
  assert (select cost from public.inventory_batches where product_id=pc)=0,'赠品不分摊运费';
  assert (select amount from public.expense_entries where source_document=id1)=46.66,'同步开支等于应付合计（含运费）';
  assert (d->'payload'->>'freight')::numeric=10 and (d->'payload'->>'freight_to_cost')::boolean,'单据保留页面提交的运费和开关';
  assert (d->'payload'->'lines'->0->>'cost')::numeric=10,'单据明细保留页面提交的入库单价';
  assert (select cost from public.inventory_products where id=pa)=12.72,'商品成本价按批次';

  -- 同一请求重放：不重复入库
  d2:=public.inventory_document_save(shop,id1,'in',payload,0,true);
  assert d2->>'id'=d->>'id' and (select stock from public.inventory_products where id=pa)=3,'重放不重复入库';

  -- 不计入成本：批次成本就是入库单价，应付合计一样含运费
  d:=public.inventory_document_save(shop,id2,'in',jsonb_set(payload,'{freight_to_cost}','false'),0,true);
  assert (d->>'total')::numeric=46.66;
  assert (select count(*) from public.inventory_batches where product_id=pa and cost=10)=1,'不计入成本时批次成本不变';

  -- 草稿不分摊，原样保存
  d:=public.inventory_document_save(shop,gen_random_uuid(),'in',payload,0,false);
  assert (d->'payload'->'lines'->0->>'cost')::numeric=10 and d->>'status'='draft','草稿保存原样';

  assert not has_function_privilege('authenticated','public.inventory_allocate_freight(jsonb,numeric)','execute');
end $$;
rollback;
