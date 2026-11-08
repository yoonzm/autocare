import {readFileSync,readdirSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const {PGlite}=await import(pathToFileURL(process.argv[2]).href);
const db=new PGlite();
const id=()=>crypto.randomUUID();
const scalar=async(sql,args=[])=>(await db.query(sql,args)).rows[0].value;
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
 const files=readdirSync(folder).filter(f=>f.endsWith('.sql')&&f>='202611010002').sort();
 // Seed real legacy records BEFORE the new migration to verify preservation.
 const owner=id(),other=id(),first=id(),foreign=id(),session=id(),device2=id();
 for(const f of files){
  if(f==='202611030007_expense_automation.sql')continue; // Scheduler unavailable in embedded Postgres; business functions still execute.
  if(f==='202611070001_account_stores.sql'){
   await db.query('insert into auth.users(id,phone) values($1,$3),($2,$4)',[owner,other,'8613900000001','8613900000002']);
   await db.query('insert into auth.sessions values($1,$2),($3,$2)',[session,owner,device2]);
   await db.query("insert into stores(id,owner_id,name,phone) values($1,$2,'原店','+8613900000001'),($3,$4,'其他账号门店','+8613900000002')",[first,owner,foreign,other]);
   await db.query("update store_subscriptions set plan='pro',plan_version=1,ends_at=now()+interval '10 days' where store_id=$1",[first]);
  }
  let sql=readFileSync(new URL(f,folder),'utf8').replace(/^\uFEFF/,'').replace(/create extension if not exists pgcrypto;/g,'');
  try{await db.exec(sql);}catch(e){console.error('Migration failed:',f,e.message,e.where,e.position);throw e;}
 }
 const call=(action,input={},request=id(),sess=session)=>scalar('select merchant_store_mutate($1,$2,$3,$4,$5) value',[owner,sess,action,input,request]);
 const directory=()=>scalar('select merchant_store_directory($1,$2) value',[owner,session]);
 let d=await directory();assert.equal(d.store_limit,3);assert.equal(d.used,1);assert.equal(d.current_store_id,first);
 assert.equal(await scalar('select count(*)::int value from account_subscriptions'),2);
 const input={name:'第二家',phone:'021-12345678',address:'真实地址'},req=id();
 const second=(await call('create',input,req)).id;assert.equal((await call('create',input,req)).id,second);
 await assert.rejects(()=>call('create',{...input,name:'重用请求'},req),/请求编号/);
 assert.equal((await directory()).used,2);assert.equal((await directory()).current_store_id,first);
 assert.equal(await scalar('select count(*)::int value from appointment_resources where store_id=$1',[second]),3);
 await assert.rejects(()=>call('create',{id:first,name:'原店',address:'地址',phone:''}),/同名/);
 await call('switch',{id:second});assert.equal((await directory()).current_store_id,second);
 assert.equal((await scalar('select platform_merchant_session($1,$2) value',[owner,device2])).store_id,first);
 await assert.rejects(()=>call('switch',{id:foreign}),/无权/);
 await assert.rejects(()=>call('update',{id:first,name:'错店',phone:'',address:'地址'}),/门店已变化/);
 await call('update',{id:second,name:'已修改第二家',phone:'',address:'地址'});
 assert.equal(await scalar('select phone value from merchant_accounts where owner_id=$1',[owner]),'+8613900000001');
 const third=(await call('create',{name:'第三家',phone:'',address:'地址'})).id;
 await assert.rejects(()=>call('create',{name:'第四家',phone:'',address:'地址'}),/上限/);
 await assert.rejects(()=>db.query("update account_subscriptions set plan='basic' where owner_id=$1",[owner]),/超过套餐/);
 // Concurrent creation attempts share the same server-side account lock/quota.
 await db.query("update account_subscriptions set plan='pro',plan_version=1,ends_at=now()+interval '10 days' where owner_id=$1",[other]);
 const otherSession=id();await db.query('insert into auth.sessions values($1,$2)',[otherSession,other]);
 const parallel=await Promise.allSettled(Array.from({length:6},(_,i)=>scalar('select merchant_store_mutate($1,$2,$3,$4,$5) value',[other,otherSession,'create',{name:'并发'+i,address:'地址',phone:''},id()])));
 assert.equal(parallel.filter(r=>r.status==='fulfilled').length,2);
 assert.equal(await scalar('select count(*)::int value from stores where owner_id=$1',[other]),3);
 // Direct PostgREST reads are restricted to the selected store, not every store owned by the account.
 await db.query("select set_config('request.jwt.claims',$1,false)",[JSON.stringify({sub:owner,session_id:session})]);
 await db.exec('set role authenticated');
 assert.equal(await scalar('select count(*)::int value from appointment_resources where store_id=$1',[first]),0);
 assert.equal(await scalar('select count(*)::int value from appointment_resources where store_id=$1',[second]),3);
 await db.exec('reset role');
 await call('switch',{id:first});
 await call('archive',{id:third});assert.equal((await directory()).used,2);
 await call('restore',{id:third});assert.equal((await directory()).used,3);
 await call('archive',{id:third});
 await call('create',{name:'名额复用',phone:'',address:'地址'});
 await assert.rejects(()=>call('restore',{id:third}),/上限/);
 await assert.rejects(()=>call('archive',{id:first}),/原门店/);
 // Legacy admin renewal by either store updates the ONE account subscription and every mirror.
 const admin=id(),adminSession=id();
 await db.query('insert into auth.users(id) values($1)',[admin]);
 await db.query('insert into auth.sessions values($1,$2)',[adminSession,admin]);
 await db.query("insert into admin_accounts(id,username,name,role,must_change) values($1,'multistore_admin','Admin','superAdmin',false)",[admin]);
 const before=await scalar('select ends_at value from account_subscriptions where owner_id=$1',[owner]);
 await scalar('select admin_command($1,$2,$3,$4,$5) value',[admin,adminSession,'merchant_extend',{id:second},id()]);
 const after=await scalar('select ends_at value from account_subscriptions where owner_id=$1',[owner]);
 assert.equal(+new Date(after)-+new Date(before),7*86400000);
 assert.equal(await scalar('select count(distinct ends_at)::int value from store_subscriptions u join stores s on s.id=u.store_id where s.owner_id=$1',[owner]),1);
 const snap=await scalar('select admin_snapshot($1,$2,0) value',[admin,adminSession]);
 assert.equal(snap.stats.paid_count,2); // Three shops do not become three paid subscribers.
 assert.equal(snap.stats.trial_count,0);
 // A failed/rolled back first registration leaves no orphan account or subscription.
 const rollbackOwner=id();await db.query('insert into auth.users(id) values($1)',[rollbackOwner]);
 await db.query("insert into stores(owner_id,name,phone) values($1,'回滚注册','+8613900000099')",[rollbackOwner]);
 await db.query('delete from auth.users where id=$1',[rollbackOwner]);
 assert.equal(await scalar('select count(*)::int value from merchant_accounts where owner_id=$1',[rollbackOwner]),0);
 await db.query("update account_subscriptions set ends_at=now()-interval '1 second' where owner_id=$1",[owner]);
 assert.equal((await directory()).can_add,false);
 await assert.rejects(()=>call('create',{name:'已到期',phone:'',address:'地址'}),/到期/);
 assert.equal((await scalar('select platform_merchant_session($1,$2,true) value',[owner,session])).status,403);
 assert.ok((await scalar('select platform_merchant_session($1,$2,false) value',[owner,session])).store_id);
 for(const sig of ['merchant_store_directory(uuid,uuid)','merchant_store_mutate(uuid,uuid,text,jsonb,text)'])assert.equal(await scalar("select has_function_privilege('authenticated',$1,'execute') value",[sig]),false);
 // Explicitly authorized temporary subscription payment simulation.
 const catalogue=()=>scalar('select subscription_catalog($1,$2) value',[owner,session]);
 const subscribe=(input,request=id())=>scalar('select subscription_simulate($1,$2,$3,$4) value',[owner,session,input,request]);
 let catalogueData=await catalogue();
 assert.equal(catalogueData.plans.length,3);
 const pro=catalogueData.plans.find(p=>p.kind==='pro');
 const payInput={plan:'pro',version:pro.version,months:12,revision:catalogueData.revision,mode:'renew',amount:1};
 const payRequest=id(),paid=await subscribe(payInput,payRequest);
 assert.equal(paid.amount,pro.fee);assert.equal(paid.simulated,true);
 assert.equal((await subscribe(payInput,payRequest)).id,paid.id);
 assert.equal(await scalar('select count(*)::int value from platform_orders'),1);
 await assert.rejects(()=>subscribe(payInput),/订阅已变化/);
 assert.equal(await scalar('select source value from account_subscriptions where owner_id=$1',[owner]),'simulation');
 assert.equal((await scalar('select platform_merchant_session($1,$2,true) value',[owner,session])).store_id,first);
 catalogueData=await catalogue();
 await assert.rejects(()=>subscribe({plan:'basic',version:1,months:12,revision:catalogueData.revision,mode:'subscribe'}),/门店数量/);
 await assert.rejects(()=>subscribe({plan:'pro',version:0,months:12,revision:catalogueData.revision,mode:'renew'}),/价格已更新/);
 await assert.rejects(()=>subscribe({plan:'pro',version:1,months:-1,revision:catalogueData.revision,mode:'renew'}),/请选择/);
 const flagship=catalogueData.plans.find(p=>p.kind==='flagship');
 const upgraded=await subscribe({plan:'flagship',version:flagship.version,months:1,revision:catalogueData.revision,mode:'subscribe'});
 assert.equal(upgraded.store_limit,10);
 assert.equal((await directory()).store_limit,10);
 assert.ok(new Date(upgraded.ends_at)>new Date(paid.ends_at));
 const report=await scalar('select admin_snapshot($1,$2,0) value',[admin,adminSession]);
 assert.equal(report.stats.subs_revenue,0,'simulation is not real cash revenue');
 assert.equal(report.stats.mrr,0,'simulation is not real MRR');
 assert.equal(report.orders.length,2);assert.ok(report.orders.every(o=>o.pay==='模拟支付'));
 assert.equal(await scalar("select has_function_privilege('authenticated','subscription_simulate(uuid,uuid,jsonb,text)','execute') value"),false);
 console.log('PASS subscription catalogue, simulation receipt, renewal, upgrade, downgrade quota, price validation, replay and cash-report exclusion');
 console.log('PASS legacy migration, shared account subscription, quota, idempotency, session switching, tenant checks, expiry and RPC permissions');
}finally{await db.close();}
