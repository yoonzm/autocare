import {readFileSync,readdirSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
// 会员端数据库断言：会话、归属隔离、自助预约 / 改约 / 取消、车辆、订单、次卡、会员码。
const {PGlite}=await import(pathToFileURL(process.argv[2]).href);
const db=new PGlite();
const id=()=>crypto.randomUUID();
const hex=(c)=>c.repeat(64);
const one=async(sql,args=[])=>(await db.query(sql,args)).rows[0].value;
try{
 await db.exec(`create role anon;create role authenticated;create role service_role;create schema auth;
 create table auth.users(id uuid primary key,phone text);create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id));
 create function auth.jwt() returns jsonb language sql stable as $$select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb$$;
 create function auth.uid() returns uuid language sql stable as $$select nullif(auth.jwt()->>'sub','')::uuid$$;
 grant usage on schema auth to authenticated;grant execute on function auth.jwt(),auth.uid() to authenticated;
 create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid primary key,bucket_id text,name text,owner uuid);
 alter table storage.objects enable row level security;
 create function storage.foldername(text) returns text[] language sql immutable as $$select string_to_array($1,'/')$$;`);
 const folder=new URL('../migrations/',import.meta.url);
 for(const f of readdirSync(folder).filter(f=>f.endsWith('.sql')&&f>='202611010002').sort()){
  if(f==='202611030007_expense_automation.sql')continue; // 嵌入式 Postgres 没有调度器
  try{await db.exec(readFileSync(new URL(f,folder),'utf8').replace(/^﻿/,'').replace(/create extension if not exists pgcrypto;/g,''));}
  catch(e){console.error('Migration failed:',f,e.message);throw e;}
 }
 // 数据：两家门店，同一手机号在两家都是会员；另一位会员用来验证隔离。
 const u1=id(),u2=id();
 await db.query("insert into auth.users(id,phone) values($1,'8613900000001'),($2,'8613900000002')",[u1,u2]);
 const s1=await one("insert into stores(owner_id,name,phone,address) values($1,'驰光徐汇店','13900000001','漕溪北路 88 号') returning id value",[u1]);
 const s2=await one("insert into stores(owner_id,name,phone) values($1,'另一家店','13900000002') returning id value",[u2]);
 for(const s of [s1,s2]){
  await db.query("insert into card_types(store_id,name,discount) values($1,'普通会员',1)",[s]);
  await db.query("select save_appointment_settings($1,'{\"opens_at\":\"00:00\",\"closes_at\":\"23:59\",\"slot_minutes\":15,\"capacity\":3,\"lead_hours\":0,\"advance_days\":30,\"grace_minutes\":15,\"closed_days\":[]}')",[s]);
  for(const n of [1,2,3])await db.query("select save_appointment_resource($1,$2)",[s,{kind:'bay',name:`${n} 号工位`}]);
 }
 const svc=await one("insert into service_items(store_id,name,category,price,duration_minutes) values($1,'精致洗车','洗车',68,60) returning id value",[s1]);
 const svcOther=await one("insert into service_items(store_id,name,category,price,duration_minutes) values($1,'别家洗车','洗车',50,30) returning id value",[s2]);
 const m1=await one("select create_member($1,'{\"phone\":\"13800000001\",\"name\":\"王建国\"}','{\"plate\":\"沪A8K29M\",\"brand_model\":\"宝马 5 系\",\"color\":\"黑色\"}') value",[s1]);
 const m1b=await one("select create_member($1,'{\"phone\":\"13800000001\",\"name\":\"王建国\"}',null) value",[s2]);
 const m2=await one("select create_member($1,'{\"phone\":\"13800000002\",\"name\":\"李四\"}','{\"plate\":\"沪B12345\"}') value",[s1]);
 const car=await one("select id value from member_vehicles where member_id=$1",[m1]);
 const car2=await one("select id value from member_vehicles where member_id=$1",[m2]);

 // ── 会话：只存哈希，过期 / 注销后无效，最多 5 个有效会话 ──
 await db.query("select member_portal_login('13800000001','openid-a',$1)",[hex('a')]);
 assert.equal((await one("select member_portal_session($1) value",[hex('a')])).phone,'13800000001');
 assert.equal(await one("select member_portal_session($1) value",[hex('b')]),null);
 assert.equal(await one("select member_portal_logout($1) value",[hex('a')]),true);
 assert.equal(await one("select member_portal_session($1) value",[hex('a')]),null);
 await assert.rejects(()=>db.query("select member_portal_login('123','openid-a',$1)",[hex('c')]),/invalid_login/);
 for(const c of ['1','2','3','4','5','6'])await db.query("select member_portal_login('13800000001','openid-a',$1)",[hex(c)]);
 assert.equal(await one("select count(*)::int value from member_sessions where phone='13800000001' and revoked_at is null"),5);
 assert.equal(await one("select member_portal_session($1) value",[hex('1')]),null,'最旧的会话被挤掉');
 await db.query("update member_sessions set expires_at=now()-interval '1 second' where token_hash=$1",[hex('6')]);
 assert.equal(await one("select member_portal_session($1) value",[hex('6')]),null,'过期会话无效');
 // 同一微信换绑手机号：以最新授权为准
 await db.query("select member_portal_login('13800000002','openid-a',$1)",[hex('d')]);
 assert.equal(await one("select phone value from member_wechat where openid='openid-a'"),'13800000002');
 await assert.rejects(()=>db.query("insert into member_sessions(phone,openid,token_hash,expires_at) values('13800000001','nope',$1,now())",[hex('e')]));

 // ── 门店与归属 ──
 const stores=await one("select member_portal_stores('13800000001') value");
 assert.equal(stores.length,2);
 assert.equal(await one("select member_portal_resolve('13800000001',$1) value",[s1]),m1);
 assert.equal(await one("select member_portal_resolve('13800000002',$1) value",[s2]),null,'不是该店会员');
 await db.query("update members set deleted_at=now() where id=$1",[m1b]);
 assert.equal((await one("select member_portal_stores('13800000001') value")).length,1,'已删除会员不列出');
 const ov=await one("select member_portal_overview($1,$2) value",[s1,m1]);
 assert.equal(ov.store.name,'驰光徐汇店');assert.equal(ov.member.name,'王建国');assert.equal(ov.counts.vehicles,1);assert.equal(ov.in_progress,null);
 await assert.rejects(()=>db.query("select member_portal_overview($1,$2)",[s1,m2+'']).then(()=>db.query("select member_portal_overview($1,$2)",[s2,m1])),/member_not_found/);

 // ── 预约：自助预约、车牌取所选车辆、幂等、容量、改约、取消 ──
 const at=(h,days=1)=>one("select (((now() at time zone 'Asia/Shanghai')::date+$2::int+make_interval(hours=>$1)) at time zone 'Asia/Shanghai') value",[h,days]);
 const t10=await at(10),t11=await at(11),t12=await at(12),t14=await at(14),t16=await at(16);
 const input=(start,svcs=[svc])=>({starts_at:new Date(start).toISOString(),service_ids:svcs,note:'车内有宠物毛发',bay_id:id(),technician_id:id(),id:id()});
 const book=(member,vehicle,inp,req,replace=null,store=s1)=>one("select member_portal_book($1,$2,$3,$4,$5,$6) value",[store,member,vehicle,inp,req,replace]);
 const car1b=(await one("select member_portal_save_vehicle($1,$2,'{\"plate\":\"沪C99999\",\"brand_model\":\"奥迪\"}',true) value",[s1,m1])).id;
 const r1=id();
 const a1=await book(m1,car,input(t10),r1);
 assert.equal(a1.status,'waiting');assert.equal(a1.plate,'沪A8K29M','车牌取所选车辆');assert.equal(Number(a1.estimate),68);
 assert.equal(a1.note,'车内有宠物毛发');assert.equal(a1.items[0].name,'精致洗车');assert.equal(a1.items[0].service_id,svc,'改约要用原服务预选');assert.equal(a1.code.length,6);
 assert.equal(await one("select bay_id is null and technician_id is null value from appointments where id=$1",[a1.id]),true,'会员不能指定工位 / 技师');
 assert.equal((await book(m1,car,input(t10),r1)).id,a1.id,'同一请求编号幂等');
 await assert.rejects(()=>book(m2,car2,input(t10),r1),/request_reused/);
 await assert.rejects(()=>book(m1,car2,input(t14),id()),/vehicle_required/,'不能用别人的车');
 await assert.rejects(()=>book(m1,car,input(t14,[svcOther]),id()),/service_not_found/,'不能约别店的服务');
 await assert.rejects(()=>book(m1,car,input(t14,[]),id()),/services_required/);
 await assert.rejects(()=>book(m1,car,input(new Date(Date.now()-3600e3)),id()),/slot_unavailable/,'过去的时间不可约');
 // 容量 3：同一时段 3 人满后第 4 个失败
 const mx=[];for(let i=0;i<3;i++){mx.push(await one("select create_member($1,$2,$3) value",[s1,{phone:`1370000000${i}`,name:`满员${i}`},{plate:`沪D1000${i}`}]));}
 const cx=[];for(const m of mx)cx.push(await one("select id value from member_vehicles where member_id=$1",[m]));
 await book(mx[0],cx[0],input(t16),id());await book(mx[1],cx[1],input(t16),id());await book(m2,car2,input(t16),id());
 await assert.rejects(()=>book(mx[2],cx[2],input(t16),id()),/slot_unavailable/,'超过接待上限');
 // 单会员待到店上限 5
 const t=[];for(let d=2;d<=8;d++)t.push(await at(9,d));
 for(let i=0;i<3;i++)await book(m1,car1b,input(t[i]),id());           // 已有 1 + 3 = 4
 await book(m1,car1b,input(t[3]),id());                                // 5
 await assert.rejects(()=>book(m1,car1b,input(t[4]),id()),/too_many_appointments/);
 // 改约：原预约取消，新预约创建，且原子
 const r2=id();
 const moved=await book(m1,car1b,input(t11),r2,a1.id);
 assert.equal(moved.plate,'沪C99999');assert.equal(moved.status,'waiting');
 assert.equal(await one("select status value from appointments where id=$1",[a1.id]),'cancelled');
 assert.equal(await one("select cancel_reason value from appointments where id=$1",[a1.id]),'会员改约');
 assert.equal((await book(m1,car1b,input(t11),r2,a1.id)).id,moved.id,'改约重试幂等，不报原预约已关闭');
 await assert.rejects(()=>book(m1,car1b,input(t12),id(),a1.id),/appointment_closed/,'已取消的不能再改');
 await assert.rejects(()=>book(m2,car2,input(t12),id(),moved.id),/appointment_not_found/,'不能改别人的预约');
 // 改约失败整体回滚：原预约仍有效
 const before=await one("select status value from appointments where id=$1",[moved.id]);
 await assert.rejects(()=>book(m1,car1b,input(t16),id(),moved.id),/slot_unavailable/);
 assert.equal(await one("select status value from appointments where id=$1",[moved.id]),before,'失败回滚');
 // 2 小时内不能取消 / 改约
 const near=await one("select (date_trunc('minute',now())+interval '90 minutes') value");
 await db.query("insert into appointments(store_id,member_id,customer_name,phone,vehicle_plate,service_ids,items,starts_at,duration_minutes,estimate,request_id) values($1,$2,'王建国','13800000001','沪A8K29M',array[$3::uuid],'[]'::jsonb,$4,60,68,'near')",[s1,m1,svc,near]);
 const nearId=await one("select id value from appointments where request_id='near'");
 await assert.rejects(()=>db.query("select member_portal_cancel($1,$2,$3,'时间有变')",[s1,m1,nearId]),/cancel_too_late/);
 await assert.rejects(()=>book(m1,car,input(t12),id(),nearId),/cancel_too_late/);
 // 取消：原因枚举、归属、幂等
 await assert.rejects(()=>db.query("select member_portal_cancel($1,$2,$3,'随便')",[s1,m1,moved.id]),/cancel_reason_required/);
 await assert.rejects(()=>db.query("select member_portal_cancel($1,$2,$3,'时间有变')",[s1,m2,moved.id]),/appointment_not_found/);
 const c1=await one("select member_portal_cancel($1,$2,$3,'时间有变') value",[s1,m1,moved.id]);
 assert.equal(c1.status,'cancelled');assert.equal(c1.cancel_reason,'时间有变');
 assert.equal((await one("select member_portal_cancel($1,$2,$3,'其他原因') value",[s1,m1,moved.id])).cancel_reason,'时间有变','重复取消返回第一次结果');
 assert.equal((await one("select member_portal_appointment($1,$2,$3) value",[s1,m1,moved.id])).status,'cancelled');
 await assert.rejects(()=>db.query("select member_portal_appointment($1,$2,$3)",[s1,m2,moved.id]),/appointment_not_found/,'不能看别人的预约');
 // 列表按状态与归属
 const pend=await one("select member_portal_appointments($1,$2,'pending') value",[s1,m1]);
 assert.equal(pend.counts.cancelled,2);assert.ok(pend.items.every(i=>i.status==='waiting'));
 assert.ok(pend.items.every((i,k,arr)=>k===0||new Date(arr[k-1].starts_at)<=new Date(i.starts_at)),'待到店按时间升序');
 assert.equal((await one("select member_portal_appointments($1,$2,'pending') value",[s1,m2])).items.every(i=>i.plate==='沪B12345'),true);
 await assert.rejects(()=>db.query("select member_portal_appointments($1,$2,'all')",[s1,m1]),/invalid_tab/);
 // 到店后进入概览的“施工中”
 await db.query("update appointments set status='arrived',arrived_at=now() where id=$1",[nearId]);
 const ov2=await one("select member_portal_overview($1,$2) value",[s1,m1]);
 assert.equal(ov2.counts.in_progress,1);assert.equal(ov2.in_progress.id,nearId);

 // ── 车辆 ──
 let cars=await one("select member_portal_vehicles($1,$2) value",[s1,m1]);
 assert.equal(cars.length,2);assert.equal(cars[0].plate,'沪C99999');assert.equal(cars[0].is_default,true);assert.equal(cars.filter(c=>c.is_default).length,1);
 await db.query("select member_portal_save_vehicle($1,$2,'{\"plate\":\"沪E55555\",\"energy\":\"fuel\"}',false)",[s1,m1]);
 cars=await one("select member_portal_vehicles($1,$2) value",[s1,m1]);assert.equal(cars.filter(c=>c.is_default).length,1);assert.equal(cars[0].plate,'沪C99999');
 await assert.rejects(()=>db.query("select member_portal_save_vehicle($1,$2,'{\"plate\":\"沪E55555\"}',false)",[s1,m2]),/member_vehicles_store_plate_uidx|duplicate/,'车牌在本店唯一');
 const m3=await one("select create_member($1,'{\"phone\":\"13600000003\",\"name\":\"新会员\"}',null) value",[s1]);
 const first=await one("select member_portal_save_vehicle($1,$2,'{\"plate\":\"沪F66666\"}',false) value",[s1,m3]);
 assert.equal(await one("select is_default value from member_vehicles where id=$1",[first.id]),true,'第一辆自动为默认');
 for(let i=0;i<9;i++)await db.query("select member_portal_save_vehicle($1,$2,$3,false)",[s1,m3,{plate:`沪G7000${i}`}]);
 await assert.rejects(()=>db.query("select member_portal_save_vehicle($1,$2,'{\"plate\":\"沪H88888\"}',false)",[s1,m3]),/vehicle_limit/);

 // ── 订单 / 充值 / 次卡（经营数据由收银写入，这里直接造行验证只读视图与归属）──
 const o1=await one("insert into orders(store_id,member_id,subtotal,card_off,discount_off,payable,pay_method,points_gained,vehicle_plate,operator,request_id) values($1,$2,1960,196,342,1422,'会员余额',142,'沪A8K29M','老周','o1') returning id value",[s1,m1]);
 await db.query("insert into order_items(order_id,position,service_id,name,unit_price,qty,line_total) values($1,0,$2,'全车镀晶',1580,1,1580),($1,1,$2,'内饰深度清洁',380,1,380)",[o1,svc]);
 const o2=await one("insert into orders(store_id,member_id,payable,pay_method,vehicle_plate,request_id) values($1,$2,0,'次卡抵扣','沪A8K29M','o2') returning id value",[s1,m2]);
 await db.query("insert into member_ledger(store_id,member_id,kind,amount,gift,balance_delta,balance_after,pay_method) values($1,$2,'recharge',1000,80,1080,1080,'微信')",[s1,m1]);
 const ord=await one("select member_portal_orders($1,$2,'all') value",[s1,m1]);
 assert.equal(ord.items.length,2);assert.equal(ord.summary.orders,1);assert.equal(Number(ord.summary.saved),538);assert.equal(Number(ord.summary.points),142);
 assert.equal(ord.items.find(i=>i.kind==='order').title,'全车镀晶 + 内饰深度清洁');
 assert.equal(Number(ord.items.find(i=>i.kind==='recharge').amount),1080);
 assert.equal((await one("select member_portal_orders($1,$2,'service') value",[s1,m1])).items.length,1);
 assert.equal((await one("select member_portal_orders($1,$2,'recharge') value",[s1,m1])).items.length,1);
 assert.equal((await one("select member_portal_orders($1,$2,'all') value",[s1,m2])).items.length,1,'只看自己的订单');
 const page=await one("select member_portal_orders($1,$2,'all',$3,30) value",[s1,m1,ord.items[0].at]);
 assert.equal(page.items.length,1);assert.equal(page.summary,null,'翻页不重复汇总');
 const det=await one("select member_portal_order($1,$2,$3) value",[s1,m1,o1]);
 assert.equal(det.items.length,2);assert.equal(Number(det.payable),1422);assert.equal(det.pay,'储值');assert.match(det.order_no,/^\d{8}-\d{4}$/);
 await assert.rejects(()=>db.query("select member_portal_order($1,$2,$3)",[s1,m2,o1]),/order_not_found/,'不能看别人的订单');
 await assert.rejects(()=>db.query("select member_portal_order($1,$2,$3)",[s2,m1,o1]),/order_not_found/,'不能跨店看订单');
 const ledger=await one("select id value from member_ledger where member_id=$1 and kind='recharge'",[m1]);
 assert.equal(Number((await one("select member_portal_recharge($1,$2,$3) value",[s1,m1,ledger])).gift),80);
 await assert.rejects(()=>db.query("select member_portal_recharge($1,$2,$3)",[s1,m2,ledger]),/order_not_found/);
 void o2;

 const pkg=await one("insert into card_packages(store_id,name,price,validity_months,show_in_mini) values($1,'精致洗车 10 次卡',580,6,true) returning id value",[s1]);
 await db.query("insert into card_package_items(package_id,service_id,count) values($1,$2,10)",[pkg,svc]);
 await db.query("insert into card_packages(store_id,name,price,validity_months,show_in_mini) values($1,'不展示',100,6,false)",[s1]);
 const mp=await one("insert into member_packages(store_id,member_id,package_id,name,price_paid,total_count,used_count,expires_at) values($1,$2,$3,'精致洗车 10 次卡',580,10,2,now()+interval '60 days') returning id value",[s1,m1,pkg]);
 await db.query("insert into member_package_items(member_package_id,position,service_id,service_name,total,used) values($1,0,$2,'精致洗车',10,2)",[mp,svc]);
 await db.query("insert into member_packages(store_id,member_id,package_id,name,price_paid,total_count,used_count,expires_at) values($1,$2,$3,'已过期',1,5,0,now()-interval '1 day')",[s1,m1,pkg]);
 const pk=await one("select member_portal_packages($1,$2) value",[s1,m1]);
 assert.equal(pk.mine.length,1);assert.equal(pk.mine[0].used,2);assert.equal(pk.offers.length,1,'不在会员端展示的套餐不出现');assert.equal(pk.offers[0].items[0].count,10);
 assert.equal((await one("select member_portal_packages($1,$2) value",[s1,m2])).mine.length,0);
 assert.equal((await one("select member_portal_overview($1,$2) value",[s1,m1])).counts.packages,1);

 // ── 会员码 ──
 await db.query("select member_portal_issue_code($1,$2,$3,60)",[s1,m1,hex('f')]);
 assert.equal(await one("select count(*)::int value from member_codes where member_id=$1",[m1]),1);
 for(let i=0;i<8;i++)await db.query("select member_portal_issue_code($1,$2,$3,60)",[s1,m1,hex(String(i))]);
 assert.ok(await one("select count(*)::int <= 5 value from member_codes where member_id=$1",[m1]),'有效码数量受限');
 await assert.rejects(()=>db.query("select member_portal_issue_code($1,$2,'bad',60)",[s1,m1]),/invalid_code/);

 // ── 权限：匿名 / 登录角色不能直接执行或读表 ──
 for(const role of ['anon','authenticated']){
  await db.exec(`set role ${role}`);
  await assert.rejects(()=>db.query("select member_portal_stores('13800000001')"),/permission denied/);
  await assert.rejects(()=>db.query("select * from member_sessions"),/permission denied/);
  await assert.rejects(()=>db.query("select * from member_codes"),/permission denied/);
  await assert.rejects(()=>db.query("select * from member_wechat"),/permission denied/);
  await db.exec('reset role');
 }
 console.log('member_portal: ok');
}finally{await db.close();}
