// Exercises the published hosted-dev schema and the exact atomic bridge plan.
import {readFileSync,readdirSync} from 'node:fs';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import assert from 'node:assert/strict';
const {PGlite}=await import(pathToFileURL(process.argv[2]).href);
const db=new PGlite(),id=()=>crypto.randomUUID();
const value=async(sql,args=[])=>(await db.query(sql,args)).rows[0].value;
const migrations=new URL('../migrations/',import.meta.url);
try {
 await db.exec(`create role anon;create role authenticated;create role service_role;create schema auth;
 create table auth.users(id uuid primary key,phone text);create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id));
 create function auth.jwt() returns jsonb language sql stable as $$select coalesce(nullif(current_setting('request.jwt.claims',true),''),'{}')::jsonb$$;
 create function auth.uid() returns uuid language sql stable as $$select nullif(auth.jwt()->>'sub','')::uuid$$;
 create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
 create table storage.objects(id uuid primary key,bucket_id text,name text,owner uuid);alter table storage.objects enable row level security;
 create function storage.foldername(text) returns text[] language sql immutable as $$select string_to_array($1,'/')$$;
 create schema supabase_migrations;create table supabase_migrations.schema_migrations(version text primary key,name text,statements text[]);`);
 for(const file of readdirSync(migrations).filter(f=>f.endsWith('.sql')&&f>='202611010002'&&f<'202611060001').sort()){
  if(file!=='202611030007_expense_automation.sql')await db.exec(readFileSync(new URL(file,migrations),'utf8').replace(/^\uFEFF/,'').replace(/create extension if not exists pgcrypto;/g,''));
  await db.query('insert into supabase_migrations.schema_migrations(version,name) values($1,$2)',[file.split('_')[0],file.replace(/^\d+_|\.sql$/g,'')]);
 }
 for(const file of ['202611050001_inventory_catalog.sql','202611050002_inventory_counts_scan.sql']){
  await db.exec(readFileSync(new URL('../deploy/legacy_inventory/'+file,import.meta.url),'utf8'));
  await db.query('insert into supabase_migrations.schema_migrations(version,name) values($1,$2)',[file.split('_')[0],file.replace(/^\d+_|\.sql$/g,'')]);
 }
 const owner=id(),store=id(),product=id(),countedProduct=id(),supplier=id(),count=id();
 await db.query('insert into auth.users values($1,$2)',[owner,'8613900000040']);
 await db.query("insert into stores(id,owner_id,name,phone) values($1,$2,'已有门店','+8613900000040')",[store,owner]);
 await db.query("insert into inventory_products(id,store_id,name,category,unit,safe,active,allow_decimal,manage_expiry,sku,barcode,supplier) values($1,$2,'保留设置','洗护','瓶',2,false,false,true,'OLD-SKU','OLD-BARCODE','保留供应商')",[product,store]);
 await db.query("insert into inventory_suppliers(id,store_id,name,contact,phone,note) values($1,$2,'保留供应商','联系人','13912340000','结算备注')",[supplier,store]);
 await db.query("insert into inventory_products(id,store_id,name,category,unit,stock,cost) values($1,$2,'盘点商品','配件','件',3,4)",[countedProduct,store]);
 await db.query('insert into inventory_batches(store_id,product_id,quantity,cost) values($1,$2,3,4)',[store,countedProduct]);
 const snapshot=[{id:countedProduct,name:'盘点商品',unit:'件',stock:3,cost:4,version:0,quantity:2,note:'保留盘点备注'}];
 await db.query("insert into inventory_counts(id,store_id,scope,blind,pause_movements,revision,snapshot) values($1,$2,'all',true,true,4,$3)",[count,store,snapshot]);
 const history=(await db.query('select version,name from supabase_migrations.schema_migrations')).rows;
 const script="import json,sys;from pathlib import Path;sys.path.insert(0,sys.argv[1]);import bridge_dev_inventory as b;print(b.plan(b.ROOT/'supabase/migrations',json.loads(sys.argv[2])) or '')";
 const sql=execFileSync('python3',['-c',script,fileURLToPath(new URL('../deploy/',import.meta.url)),JSON.stringify(history)],{encoding:'utf8'});
 // A failure even at the very end rolls back all schema/data/history changes.
 await assert.rejects(()=>db.exec(sql.replace(/COMMIT;\s*$/,()=>"DO $$ BEGIN RAISE EXCEPTION 'fixture_failure'; END $$; COMMIT;")),/fixture_failure/);
 await db.exec('rollback');
 assert.equal(await value("select exists(select 1 from information_schema.columns where table_name='inventory_products' and column_name='active') value"),true);
 assert.equal(await value("select to_regclass('legacy_inventory_suppliers_20261105') is null value"),true);
 assert.equal(await value("select count(*)::int value from supabase_migrations.schema_migrations where version>='202611060001'"),0);
 await db.exec(sql);
 const saved=(await db.query('select active,allow_decimal,shelf_life,barcode,sku from inventory_products where id=$1',[product])).rows[0];
 assert.deepEqual(saved,{active:false,allow_decimal:false,shelf_life:true,barcode:'OLD-BARCODE',sku:'OLD-SKU'});
 const kept=(await db.query('select id,contact,phone,note from inventory_suppliers where store_id=$1',[store])).rows[0];
 assert.deepEqual(kept,{id:supplier,contact:'联系人',phone:'13912340000',note:'结算备注'});
 const draft=await value('select to_jsonb(d) value from inventory_documents d where id=$1',[count]);
 assert.equal(draft.revision,4);assert.equal(draft.payload.blind,true);assert.equal(draft.payload.freeze,true);
 assert.equal(draft.payload.lines[0].quantity,2);assert.equal(draft.payload.lines[0].note,'保留盘点备注');
 assert.deepEqual(draft.payload.product_ids,[countedProduct]);
 assert.equal(await value('select count(*)::int value from inventory_counts where id=$1',[count]),1);
 assert.equal(Number(await value('select stock value from inventory_products where id=$1',[countedProduct])),3);
 assert.equal(await value("select has_function_privilege('service_role','inventory_count_action(uuid,text,uuid,jsonb)','execute') value"),false);
 await assert.rejects(()=>db.query("select inventory_document_save($1,$2,'out',$3,0,true)",[store,id(),{lines:[{id:countedProduct,quantity:1}]}]),/count_locked/);
 await db.query("select inventory_mutate($1,$2,'void',$3)",[store,id(),{id:count,reason:'取消已迁移草稿'}]);
 const out=await value("select inventory_document_save($1,$2,'out',$3,0,true) value",[store,id(),{lines:[{id:countedProduct,quantity:1}]}]);
 assert.equal(out.status,'posted');assert.equal(Number(out.total),4);
 console.log('PASS legacy inventory bridge: atomic rollback, original settings, barcode, supplier IDs/contact, count draft/notes, freeze, FIFO and revoked legacy writes');
}finally{await db.close();}
