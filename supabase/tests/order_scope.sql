-- 完整迁移后执行；断言失败即中止，测试数据回滚。
begin;
do $$
declare owner_u uuid:=gen_random_uuid(); shop uuid; svc uuid; ta uuid; tb uuid; ap_a uuid:=gen_random_uuid(); ap_b uuid:=gen_random_uuid();
  tier uuid; o_a uuid; o_b uuid; o_direct uuid; feed jsonb; feed_a jsonb; feed_b jsonb; r jsonb; caught boolean; m uuid;
  from_ts timestamptz:=now()-interval '1 day'; to_ts timestamptz:=now()+interval '1 day'; nobody uuid:='00000000-0000-0000-0000-000000000000';
begin
  insert into auth.users(id,phone) values(owner_u,'8613900000051');
  insert into public.stores(owner_id,name,phone) values(owner_u,'订单范围测试店','13900000051') returning id into shop;
  insert into public.service_items(store_id,name,category,price) values(shop,'精致洗车','洗车',100) returning id into svc;
  insert into public.appointment_resources(store_id,kind,name,category) values(shop,'technician','技师甲','洗车') returning id into ta;
  insert into public.appointment_resources(store_id,kind,name,category) values(shop,'technician','技师乙','洗车') returning id into tb;
  insert into public.appointments(id,store_id,customer_name,vehicle_plate,service_ids,items,starts_at,duration_minutes,estimate,status,technician_id,request_id)
    values(ap_a,shop,'散客甲','沪A1111A',array[svc],'[]'::jsonb,now(),30,100,'arrived',ta,'s-1'),
          (ap_b,shop,'散客乙','沪B2222B',array[svc],'[]'::jsonb,now(),30,100,'arrived',tb,'s-2');
  -- 三笔消费：派给甲、派给乙、直接开单（没有预约）
  o_a:=(public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'微信','沪A1111A','','店长','os-1')->>'order_id')::uuid;
  o_b:=(public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'微信','沪B2222B','','店长','os-2')->>'order_id')::uuid;
  o_direct:=(public.checkout_walkin(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金','沪C3333C','','店长','os-3')->>'order_id')::uuid;
  update public.orders set appointment_id=ap_a where id=o_a;
  update public.orders set appointment_id=ap_b where id=o_b;
  -- 一笔充值和一笔次卡售卖（不属于任何技师）
  insert into public.card_types(store_id,name,discount) values(shop,'普通会员',1) returning id into tier;
  insert into public.members(store_id,name,phone,card_type_id) values(shop,'会员','13900000052',tier) returning id into m;
  insert into public.member_ledger(store_id,member_id,kind,amount,gift,balance_after,pay_method,operator,note)
    values(shop,m,'recharge',500,0,500,'微信','店长','');

  -- 复现：不带范围（老板 / 有「查看全部订单」权限）读到全店
  feed:=public.order_feed(shop,from_ts,to_ts,'all','','','','',null,50);
  assert jsonb_array_length(feed->'items')=4,'全店 3 笔消费 + 1 笔充值，实际 '||jsonb_array_length(feed->'items');

  -- 修复：技师甲只能看到派给自己的消费订单
  feed_a:=public.order_feed_scoped(shop,from_ts,to_ts,'all','','','','',null,50,ta);
  assert jsonb_array_length(feed_a->'items')=1 and (feed_a->'items'->0->>'id')::uuid=o_a,'甲只能看到自己的订单';
  assert (feed_a->'summary'->>'received')::numeric=100,'汇总也只算甲的订单，实际 '||(feed_a->'summary'->>'received');
  feed_b:=public.order_feed_scoped(shop,from_ts,to_ts,'all','','','','',null,50,tb);
  assert jsonb_array_length(feed_b->'items')=1 and (feed_b->'items'->0->>'id')::uuid=o_b,'乙只能看到自己的订单';
  -- 范围用完立即清掉：同一事务里接着不带范围读，仍是全店
  assert jsonb_array_length(public.order_feed(shop,from_ts,to_ts,'all','','','','',null,50)->'items')=4,'范围没有泄漏到后面的调用';
  -- 用筛选条件也绕不开（按类型 / 搜索别人的车牌）
  assert jsonb_array_length(public.order_feed_scoped(shop,from_ts,to_ts,'recharge','','','','',null,50,ta)->'items')=0,'本人范围看不到充值';
  assert jsonb_array_length(public.order_feed_scoped(shop,from_ts,to_ts,'all','','','','沪B2222B',null,50,ta)->'items')=0,'搜别人的车牌也是空';
  -- 没有对应排班资源（传不存在的资源）：什么也看不到
  assert jsonb_array_length(public.order_feed_scoped(shop,from_ts,to_ts,'all','','','','',null,50,nobody)->'items')=0;

  -- 详情：自己的可以看；别人的、直接开单的、充值的一律「订单不存在」
  r:=public.order_detail_scoped(shop,'consume',o_a,ta);
  assert (r->>'id')::uuid=o_a,'自己的订单详情可读';
  caught:=false; begin perform public.order_detail_scoped(shop,'consume',o_b,ta); exception when others then caught:=sqlerrm='order_not_found'; end;
  assert caught,'看不到别的技师的订单详情';
  caught:=false; begin perform public.order_detail_scoped(shop,'consume',o_direct,ta); exception when others then caught:=sqlerrm='order_not_found'; end;
  assert caught,'看不到没有关联预约的直接订单';
  caught:=false; begin perform public.order_detail_scoped(shop,'recharge',(select id from public.member_ledger where kind='recharge' limit 1),ta); exception when others then caught:=sqlerrm='order_not_found'; end;
  assert caught,'看不到充值详情';
  -- 报错后范围也已清掉
  assert (public.order_detail(shop,'consume',o_b)->>'id')::uuid=o_b,'报错后范围没有残留';

  -- 退款行同样按范围：甲的订单退款后，乙看不到这条退款
  perform public.refund_order(shop,o_a,'录入错误','店长','rf-1');
  assert jsonb_array_length(public.order_feed_scoped(shop,from_ts,to_ts,'refund','','','','',null,50,ta)->'items')=1,'甲能看到自己订单的退款';
  assert jsonb_array_length(public.order_feed_scoped(shop,from_ts,to_ts,'refund','','','','',null,50,tb)->'items')=0,'乙看不到甲订单的退款';

  assert not has_function_privilege('authenticated','public.order_feed_scoped(uuid,timestamptz,timestamptz,text,text,text,text,text,timestamptz,int,uuid)','execute');
  assert not has_function_privilege('authenticated','public.order_detail_scoped(uuid,text,uuid,uuid)','execute');
end $$;
rollback;
