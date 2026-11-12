// Run: node supabase/tests/staff_identity.mjs /path/to/@electric-sql/pglite/dist/index.js
// 全部迁移后执行 staff_identity.sql。
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

 await db.exec(readFileSync(new URL('staff_identity.sql',import.meta.url),'utf8'));
 console.log('staff_identity ok');
}finally{await db.close();}
