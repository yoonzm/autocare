// Isolated PostgreSQL: never connects to production or copies real trading data.
import {readFileSync,readdirSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const {PGlite}=await import(pathToFileURL(process.argv[2]).href);
const db=new PGlite();const id=()=>crypto.randomUUID();
const value=async(sql,args=[])=>(await db.query(sql,args)).rows[0].value;
const owner=id(),primary=id(),branch=id(),session=id();
const types=['洗车美容','镀晶镀膜','隐形车衣'];
const migration='202611080002_store_catalog_initialization.sql';
try{
 await db.exec(`create role anon;create role authenticated;create role service_role;create schema auth;
 create table auth.users(id uuid primary key,phone text);create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id));
 create function auth.jwt() returns jsonb language sql stable as $$select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb$$;
 create function auth.uid() returns uuid language sql stable as $$select nullif(auth.jwt()->>'sub','')::uuid$$;
 create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid primary key,bucket_id text,name text,owner uuid);
 alter table storage.objects enable row level security;
 create function storage.foldername(text) returns text[] language sql immutable as $$select string_to_array($1,'/')$$;`);
 const folder=new URL('../migrations/',import.meta.url);
 for(const file of readdirSync(folder).filter(f=>f.endsWith('.sql')&&f>='202611010002').sort()){
  if(file==='202611030007_expense_automation.sql')continue;
  if(file===migration){
   await db.query('insert into auth.users(id,phone) values($1,$2)',[owner,'8613900000001']);
   await db.query("insert into stores(id,owner_id,name,phone,business_types,bay_range) values($1,$2,'首店','+8613900000001',$3,'4-6 个')",[primary,owner,types]);
   await db.query('insert into auth.sessions values($1,$2)',[session,owner]);
   await db.query("update account_subscriptions set plan='pro',plan_version=1 where owner_id=$1",[owner]);
   // Existing branch with the old three bays and some manually edited catalogues.
   await db.query("insert into stores(id,owner_id,name,phone,business_types) values($1,$2,'旧分店','021-12345678',$3)",[branch,owner,types]);
   await db.query("insert into appointment_resources(store_id,kind,name) values($1,'bay','自定义工位')",[branch]);
   await db.query("insert into service_items(store_id,name,price,active) values($1,'精致洗车',88,false)",[branch]);
   await db.query("insert into inventory_products(store_id,name,category,unit,stock,safe,cost) values($1,'中性洗车液 20L','洗护','桶',7,2,20)",[branch]);
   await db.query("insert into card_types(store_id,name,discount,active) values($1,'普通会员',0.9,false)",[branch]);
   await db.query("insert into card_packages(store_id,name,price,active,deleted_at) values($1,'精致洗车年卡',555,false,now())",[branch]);
  }
  await db.exec(readFileSync(new URL(file,folder),'utf8').replace(/^\uFEFF/,'').replace(/create extension if not exists pgcrypto;/g,''));
 }
 assert.deepEqual(await value('select data value from store_starter_templates where version=1'),JSON.parse(readFileSync(new URL('../data/store_starter_v1.json',import.meta.url),'utf8')));
 const init=store=>value('select initialize_store_catalog($1) value',[store]);
 const counts=async store=>({
  services:await value('select count(*)::int value from service_items where store_id=$1',[store]),
  products:await value('select count(*)::int value from inventory_products where store_id=$1',[store]),
  cards:await value('select count(*)::int value from card_types where store_id=$1',[store]),
  packages:await value('select count(*)::int value from card_packages where store_id=$1',[store]),
  bays:await value("select count(*)::int value from appointment_resources where store_id=$1 and kind='bay'",[store]),
 });
 // Backfill adds missing definitions without changing any edited value/resource.
 assert.deepEqual(await counts(branch),{services:10,products:5,cards:4,packages:6,bays:1});
 assert.equal(await value("select price value from service_items where store_id=$1 and name='精致洗车'",[branch]),'88.00');
 assert.equal(Number(await value("select stock value from inventory_products where store_id=$1 and name='中性洗车液 20L'",[branch])),7);
 assert.equal(await value("select active value from card_types where store_id=$1 and name='普通会员'",[branch]),false);
 assert.equal(await value("select price value from card_packages where store_id=$1 and name='精致洗车年卡'",[branch]),'555.00');
 assert.equal(await value("select count(*)::int value from store_catalog_initializations where store_id=$1",[primary]),0,'migration does not restore defaults in an already-managed primary store');
 const first=await init(primary);assert.deepEqual(first,{services:10,products:5,cards:4,packages:6,bays:6});
 const create=(name,request=id())=>value('select merchant_store_mutate($1,$2,$3,$4,$5) value',[owner,session,'create',{name,phone:'',address:'真实地址'},request]);
 const newBranch=(await create('新分店')).id;
 assert.deepEqual(await counts(newBranch),await counts(primary));
 for(const table of ['service_items','card_types','card_packages']){
  const rows=await db.query(`select to_jsonb(t)-'id'-'store_id'-'created_at' value from ${table} t where store_id=$1 order by name`,[primary]);
  const newRows=await db.query(`select to_jsonb(t)-'id'-'store_id'-'created_at' value from ${table} t where store_id=$1 order by name`,[newBranch]);
  assert.deepEqual(newRows.rows,rows.rows);
 }
 assert.equal(await value('select count(*)::int value from inventory_products where store_id=$1 and (stock<>0 or safe<>0 or cost<>0)',[newBranch]),0);
 assert.equal(await value('select count(*)::int value from members where store_id=$1',[newBranch]),0);
 assert.equal(await value('select count(*)::int value from orders where store_id=$1',[newBranch]),0);
 assert.equal(await value('select count(*)::int value from card_package_items i join card_packages p on p.id=i.package_id join service_items s on s.id=i.service_id where p.store_id=$1 and s.store_id<>p.store_id',[newBranch]),0,'package services belong to the new branch');
 assert.deepEqual(await init(primary),first);
 await db.query("delete from service_items where store_id=$1 and name='发动机舱清洗'",[primary]);
 await init(primary);assert.equal((await counts(primary)).services,9,'retry must not restore a deliberately deleted service');
 assert.equal(await value("select has_function_privilege('authenticated','initialize_store_catalog(uuid)','execute') value"),false);
 // Separate account: failure of any starter insert rolls the whole branch back.
 const secondOwner=id(),secondPrimary=id(),secondSession=id();
 await db.query('insert into auth.users(id,phone) values($1,$2)',[secondOwner,'8613900000002']);
 await db.query("insert into stores(id,owner_id,name,phone,business_types,bay_range) values($1,$2,'另一个首店','+8613900000002',$3,'1-3 个')",[secondPrimary,secondOwner,types]);
 await db.query('insert into auth.sessions values($1,$2)',[secondSession,secondOwner]);
 await db.query("update account_subscriptions set plan='pro',plan_version=1 where owner_id=$1",[secondOwner]);
 await db.exec(`create function test_seed_failure() returns trigger language plpgsql as $$begin raise exception 'seed_fixture_failure';end$$;create trigger test_seed_failure before insert on card_types for each row execute function test_seed_failure();`);
 const req=id(),payload={name:'失败重试分店',phone:'',address:'地址'};
 const attempt=()=>value('select merchant_store_mutate($1,$2,$3,$4,$5) value',[secondOwner,secondSession,'create',payload,req]);
 await assert.rejects(attempt,/seed_fixture_failure/);
 assert.equal(await value('select count(*)::int value from stores where owner_id=$1',[secondOwner]),1);
 await db.exec('drop trigger test_seed_failure on card_types;drop function test_seed_failure()');
 const retried=await attempt();assert.deepEqual(await counts(retried.id),{services:10,products:5,cards:4,packages:6,bays:3});
 assert.equal((await attempt()).id,retried.id);
 console.log('PASS first/branch template parity, partial backfill preservation, zero inventory, tenant-owned package services, retry, rollback and RPC permissions');
}finally{await db.close();}
