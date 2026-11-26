begin;
do $$
declare u uuid:=gen_random_uuid(); u2 uuid:=gen_random_uuid(); shop uuid; shop2 uuid; tech uuid; tech2 uuid; cash uuid; res uuid; svc uuid;
 h uuid; msg uuid; foreign_msg uuid; owner_msg uuid; r jsonb; page2 jsonb; page3 jsonb; before_at timestamptz; caught boolean; n int;
begin
 insert into auth.users(id,phone) values(u,'8613901000001'),(u2,'8613901000002');
 insert into stores(owner_id,name,phone) values(u,'消息测试店','13901000001') returning id into shop;
 insert into stores(owner_id,name,phone) values(u2,'其他店','13901000002') returning id into shop2;
 tech:=(save_staff(shop,'{"name":"技师","phone":"13801000001","role":"technician"}','老板')->>'id')::uuid;
 tech2:=(save_staff(shop,'{"name":"另一个技师","phone":"13801000002","role":"technician"}','老板')->>'id')::uuid;
 cash:=(save_staff(shop,'{"name":"前台","phone":"13801000003","role":"cashier"}','老板')->>'id')::uuid;
 update store_staff set status='active',activated_at=now() where store_id=shop;
 select resource_id into res from store_staff where id=tech;
 insert into service_items(store_id,name,category,price,duration_minutes) values(shop,'洗车','洗车',38,30) returning id into svc;
 -- 同一时间戳也不能漏页或重复。
 insert into staff_messages(store_id,staff_id,kind,title,created_at)
 select shop,tech,'system','分页 '||x,'2026-01-01'::timestamptz from generate_series(1,65) x;
 insert into staff_messages(store_id,staff_id,kind,title) values(shop,tech2,'system','他人私有') returning id into foreign_msg;
 insert into staff_messages(store_id,owner_id,kind,title) values(shop,u,'system','老板私有') returning id into owner_msg;
 r:=inbox_list(shop,tech,null); assert jsonb_array_length(r->'items')=30 and (r->>'unread')::int=65;
 page2:=inbox_list(shop,tech,null,null,(r->'next'->>'at')::timestamptz,(r->'next'->>'id')::uuid);
 page3:=inbox_list(shop,tech,null,null,(page2->'next'->>'at')::timestamptz,(page2->'next'->>'id')::uuid);
 assert jsonb_array_length(page2->'items')=30 and jsonb_array_length(page3->'items')=5 and page3->'next'='null'::jsonb;
 select count(distinct v->>'id') into n from jsonb_array_elements((r->'items')||(page2->'items')||(page3->'items')) v;
 assert n=65;
 assert (inbox_list(shop,null,u)->>'unread')::int=1;
 caught:=false;begin perform inbox_list(shop2,tech,null); exception when insufficient_privilege then caught:=true;end;assert caught;
 caught:=false;begin perform inbox_list(shop,null,u2); exception when insufficient_privilege then caught:=true;end;assert caught;
 caught:=false;begin perform inbox_read(shop,tech,null,foreign_msg,null); exception when no_data_found then caught:=true;end;assert caught;
 caught:=false;begin perform inbox_read(shop,tech,null,owner_msg,null); exception when no_data_found then caught:=true;end;assert caught;
 msg:=(r->'items'->0->>'id')::uuid;
 assert (inbox_read(shop,tech,null,msg,null)->>'unread')::int=64;
 assert (inbox_read(shop,tech,null,msg,null)->>'unread')::int=64;
 before_at:=clock_timestamp();
 insert into staff_messages(store_id,staff_id,kind,title,created_at) values(shop,tech,'system','新到的消息',before_at+interval '1 second');
 assert (inbox_read(shop,tech,null,null,before_at)->>'unread')::int=1,'全部已读不能吞掉随后到达的新消息';
 assert (inbox_unread(shop,tech2,null)->>'unread')::int=1;
 -- 挂单派工、完工各收一条；其他字段更新不重复发待结算通知。
 h:=hold_order_with_technicians(shop,null,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'施工中','','不提醒','沪A11111',null,array[res]);
 select id into msg from staff_messages where staff_id=tech and link='StTaskDetail:'||h;
 assert inbox_target(shop,tech,null,msg)->>'type'='task';
 caught:=false;begin perform staff_task_detail(shop,cash,h); exception when no_data_found then caught:=true;end;assert caught,'无技师资源的前台不能读取技师任务';
 perform staff_task_finish(shop,tech,h);
 assert (select count(*) from staff_messages where staff_id=cash and link='Hold:'||h)=1;
 assert (select count(*) from staff_messages where owner_id=u and link='Hold:'||h)=1;
 update held_orders set note='只改备注' where id=h;
 assert (select count(*) from staff_messages where staff_id=cash and link='Hold:'||h)=1;
 select id into owner_msg from staff_messages where owner_id=u and link='Hold:'||h;
 assert inbox_target(shop,null,u,owner_msg)->>'type'='holds';
 update held_orders set technician_ids='{}' where id=h;
 assert inbox_target(shop,tech,null,msg)->>'type'='unavailable';
 update held_orders set cancelled_at=now() where id=h;
 assert inbox_target(shop,null,u,owner_msg)->>'type'='unavailable';
 -- 实际结算产生老板通知，提交技师可看自己的消费单，不能越权看他人单。
 h:=hold_order_with_technicians(shop,null,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'待结算','','不提醒','沪A22222',null,array[res]);
 update held_orders set submitted_by=tech where id=h;
 r:=checkout_with_technicians(shop,jsonb_build_array(jsonb_build_object('service_id',svc,'qty',1)),'现金','沪A22222','','老板','inbox-pay',array[res],null,h,null,null,null);
 select id into owner_msg from staff_messages where owner_id=u and link='Order:'||(r->>'order_id');
 assert owner_msg is not null;
 assert inbox_target(shop,null,u,owner_msg)->>'type'='order';
 select id into msg from staff_messages where staff_id=tech and title='订单已收银' and link='Order:'||(r->>'order_id');
 assert inbox_target(shop,tech,null,msg)->>'type'='order';
 assert not has_table_privilege('authenticated','staff_messages','select');
 assert not has_function_privilege('authenticated','inbox_read(uuid,uuid,uuid,uuid,timestamptz)','execute');
 assert has_function_privilege('service_role','inbox_list(uuid,uuid,uuid,text,timestamptz,uuid)','execute');
 -- iOS 推送设备绑定、站内信自动入队与同设备切换身份覆盖。
 assert (push_register(shop,tech,null,'ios','aliyun-ios-token-1')->>'ok')::boolean;
 insert into staff_messages(store_id,staff_id,kind,title,body,link) values(shop,tech,'system','推送测试','测试内容','');
 assert (select count(*) from push_outbox where staff_id=tech and title='推送测试' and status='pending')=1;
 assert jsonb_array_length(push_claim_outbox(10))=1;
 -- 同一设备切换为老板登录后，旧员工绑定被覆盖，不再串推。
 assert (push_register(shop,null,u,'ios','aliyun-ios-token-1')->>'ok')::boolean;
 assert (select count(*) from push_devices where device_token='aliyun-ios-token-1' and owner_id=u and staff_id is null and disabled_at is null)=1;
 assert (push_unregister(shop,null,u,'ios','aliyun-ios-token-1')->>'ok')::boolean;
 assert (select disabled_at is not null from push_devices where device_token='aliyun-ios-token-1')=true;
 assert not has_table_privilege('authenticated','push_devices','select');
 assert not has_table_privilege('authenticated','push_outbox','select');
 assert not has_function_privilege('authenticated','push_register(uuid,uuid,uuid,text,text)','execute');
end $$;
rollback;
