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


  -- 关联工单（进行中的预约）：显示文字由数据库生成；别家的预约不能关联
  declare appt uuid:=gen_random_uuid(); other_owner uuid:=gen_random_uuid(); other_shop uuid; other_appt uuid:=gen_random_uuid(); caught boolean:=false; d3 jsonb;
  begin
    insert into public.service_items(store_id,name,category,price) values(shop,'镀晶养护','镀晶镀膜',100);
    insert into public.appointments(id,store_id,customer_name,vehicle_plate,service_ids,items,starts_at,duration_minutes,estimate,status,request_id)
      values(appt,shop,'散客','沪A8K29M',array[(select id from public.service_items where store_id=shop limit 1)],
        jsonb_build_array(jsonb_build_object('name','镀晶养护','price',100)),now(),30,100,'arrived','wo-1');
    d3:=public.inventory_document_save(shop,gen_random_uuid(),'out',jsonb_build_object('reason','施工领用','workorder_id',appt,'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',1))),0,true);
    assert d3->'payload'->>'workorder'='沪A8K29M 镀晶养护','工单显示文字由数据库生成，实际 '||coalesce(d3->'payload'->>'workorder','空');
    insert into auth.users(id,phone) values(other_owner,'8613900000042');
    insert into public.stores(owner_id,name,phone) values(other_owner,'别家','13900000042') returning id into other_shop;
    insert into public.appointments(id,store_id,customer_name,service_ids,items,starts_at,duration_minutes,estimate,status,request_id)
      values(other_appt,other_shop,'别人',array[gen_random_uuid()],'[]'::jsonb,now(),30,0,'arrived','wo-2');
    begin perform public.inventory_document_save(shop,gen_random_uuid(),'out',jsonb_build_object('reason','施工领用','workorder_id',other_appt,'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',1))),0,true);
    exception when others then caught:=sqlerrm like '%order_not_found%'; end;
    assert caught,'不能关联别家的工单';
  end;


  -- 退回供应商同步退款开支：负数、记材料采购、不受预算拦截、作废时一起撤销
  declare rd jsonb; rid uuid:=gen_random_uuid(); rd2 jsonb; rid2 uuid:=gen_random_uuid(); rid3 uuid:=gen_random_uuid(); caught boolean:=false;
  begin
    perform public.inventory_document_save(shop,gen_random_uuid(),'in',jsonb_build_object('supplier','运费供应商','date','2026-11-17','lines',
      jsonb_build_array(jsonb_build_object('id',pa,'quantity',20,'cost',10))),0,true);
    rd:=public.inventory_document_save(shop,rid,'out',jsonb_build_object('reason','退回供应商','supplier','运费供应商','refund_amount',80,'sync_expense',true,
      'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',2))),0,true);
    assert (select amount from public.expense_entries where source_document=rid)=-80,'退款开支是负数';
    assert (select category from public.expense_entries where source_document=rid)='材料采购','记在材料采购';
    assert (select payee from public.expense_entries where source_document=rid)='运费供应商' and (select note from public.expense_entries where source_document=rid)='退回供应商退款';
    -- 没开同步 / 应退金额为 0：不记
    rd2:=public.inventory_document_save(shop,rid2,'out',jsonb_build_object('reason','退回供应商','supplier','运费供应商','refund_amount',50,
      'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',1))),0,true);
    assert not exists(select 1 from public.expense_entries where source_document=rid2),'没开同步不记';
    perform public.inventory_document_save(shop,rid3,'out',jsonb_build_object('reason','退回供应商','supplier','运费供应商','refund_amount',0,'sync_expense',true,
      'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',1))),0,true);
    assert not exists(select 1 from public.expense_entries where source_document=rid3),'应退金额为 0 不记';
    -- 其他出库类型不记开支
    perform public.inventory_document_save(shop,gen_random_uuid(),'out',jsonb_build_object('reason','损耗报废','scrap_reason','破损','sync_expense',true,'refund_amount',10,
      'lines',jsonb_build_array(jsonb_build_object('id',pa,'quantity',1))),0,true);
    assert (select count(*) from public.expense_entries where store_id=shop and amount<0)=1,'只有退回供应商才记负数开支';
    -- 手工记账仍然不能是负数
    begin
      perform public.expense_mutate(shop,'rf-'||gen_random_uuid()::text,'save',jsonb_build_object('id',gen_random_uuid(),'amount',-5,'category','其他','occurred_on','2026-11-17','account','现金','status','paid','payee','','note',''));
    exception when others then caught:=sqlerrm like '%invalid_amount%'; end;
    assert caught,'手工记账不能是负数（应报 invalid_amount）';
    assert not exists(select 1 from public.expense_entries where store_id=shop and source_document is null and amount<=0);
  end;

  assert not has_function_privilege('authenticated','public.inventory_allocate_freight(jsonb,numeric)','execute');
end $$;
rollback;
