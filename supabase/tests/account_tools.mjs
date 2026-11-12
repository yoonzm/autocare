// Isolated Postgres checks for account/session isolation and cancellation conditions.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const ids = Array.from({length:9},()=>crypto.randomUUID());
const [a,b,sa,sa2,sb,expired,storeA,storeB,archived] = ids;
const scalar = async (sql,args=[]) => (await db.query(sql,args)).rows[0].value;
try {
  await db.exec(`create role anon; create role authenticated; create role service_role;
    create schema auth;
    create table auth.users(id uuid primary key);
    create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id),
      created_at timestamptz default now(),refreshed_at timestamptz,not_after timestamptz);
    create function public.staff_session_valid(p_user uuid,p_session uuid) returns boolean
      language sql as 'select exists(select 1 from auth.sessions where id=p_session and user_id=p_user and (not_after is null or not_after>now()))';
    create table public.merchant_accounts(owner_id uuid primary key,phone text);
    create table public.stores(id uuid primary key,owner_id uuid,archived_at timestamptz);
    create table public.held_orders(id uuid primary key default gen_random_uuid(),store_id uuid,settled_at timestamptz,cancelled_at timestamptz);
    create table public.appointments(id uuid primary key default gen_random_uuid(),store_id uuid,status text);
    create table public.account_cancellations(user_id uuid primary key,phone text,source text,reason text);
    create function public.account_release_login(p_user uuid) returns void language plpgsql as $$
      begin delete from auth.sessions where user_id=p_user;
      update merchant_accounts set phone='cancelled-'||phone where owner_id=p_user; end $$;
  `);
  await db.exec(readFileSync(new URL('../migrations/202611120001_account_tools.sql',import.meta.url),'utf8'));
  for(const id of [a,b]) await db.query('insert into auth.users values($1)',[id]);
  for(const [id,user] of [[sa,a],[sa2,a],[sb,b],[expired,a]]) {
    await db.query('insert into auth.sessions(id,user_id) values($1,$2)',[id,user]);
  }
  await db.query("update auth.sessions set not_after=now()-interval '1 hour' where id=$1",[expired]);
  const devices = (user=a,session=sa,platform='Android') => scalar('select account_devices($1,$2,$3) as value',[user,session,platform]);
  let d=await devices();
  assert.equal(d.items.length,2); assert.equal(d.items[0].id,sa); assert.equal(d.items[0].current,true);
  assert.equal(d.items[0].name,'Android');
  assert.deepEqual(Object.keys(d.items[0]).sort(),['id','current','name','created_at','active_at'].sort());
  assert.equal((await devices(a,sb)).status,401);
  assert.equal((await devices(a,expired)).status,401);
  const revoke=(target,user=a,session=sa)=>scalar('select account_device_revoke($1,$2,$3) as value',[user,session,target]);
  assert.equal((await revoke(sa)).status,400);
  await revoke(sb);
  assert.equal(await scalar('select count(*)::int as value from auth.sessions where id=$1',[sb]),1);
  await revoke(sa2); await revoke(sa2);
  assert.equal((await devices()).items.length,1);
  assert.equal((await devices(a,sa2)).status,401);
  await db.query("insert into merchant_accounts values($1,'+8613800138000'),($2,'+8613800138001')",[a,b]);
  await db.query('insert into stores values($1,$2,null),($3,$4,null),($5,$2,now())',[storeA,a,storeB,b,archived]);
  await db.query('insert into held_orders(store_id) values($1),($2)',[archived,storeB]);
  await db.query("insert into appointments(store_id,status) values($1,'waiting'),($2,'waiting')",[storeA,storeB]);
  const check=()=>scalar('select account_cancel_check($1) as value',[a]);
  let c=await check(); assert.equal(c.holds,1); assert.equal(c.appointments,1); assert.equal(c.can_cancel,false);
  const cancel=()=>scalar('select account_cancel_self($1) as value',[a]);
  await assert.rejects(cancel,/account_has_pending_work/);
  await db.query('update held_orders set settled_at=now() where store_id=$1',[archived]);
  await assert.rejects(cancel,/account_has_pending_work/);
  await db.query("update appointments set status='cancelled' where store_id=$1",[storeA]);
  c=await check();assert.equal(c.can_cancel,true);
  assert.equal(await cancel(),true);assert.equal(await cancel(),false);
  assert.equal(await scalar('select count(*)::int as value from auth.sessions where user_id=$1',[a]),0);
  assert.equal(await scalar('select count(*)::int as value from auth.sessions where user_id=$1',[b]),1);
  assert.equal(await scalar('select count(*)::int as value from held_orders'),2);
  assert.equal(await scalar('select count(*)::int as value from appointments'),2);
  assert.equal(await scalar('select count(*)::int as value from stores'),3);
  await db.exec('set role authenticated');
  await assert.rejects(()=>db.query('select * from account_session_devices'),/permission denied/);
  await assert.rejects(()=>devices(b,sb),/permission denied/);
  await assert.rejects(()=>cancel(),/permission denied/);
  await db.exec('reset role');
  console.log('account tools: session isolation, revocation, cancellation and RPC privileges passed');
} finally { await db.close(); }
