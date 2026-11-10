// Run: node supabase/tests/account_cancellation.mjs /path/to/@electric-sql/pglite/dist/index.js
// Isolated local Postgres; verifies account listing and force cancellation touch only the account.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const uuid = () => crypto.randomUUID();
const scalar = async (sql, args = []) => (await db.query(sql, args)).rows[0].value;
const file = (name) => readFileSync(new URL('../migrations/' + name, import.meta.url), 'utf8');
const [superId, opsId, ownerA, ownerB, techU, bothU] = [uuid(), uuid(), uuid(), uuid(), uuid(), uuid()];
const [superS, opsS, techS, ownerAS] = [uuid(), uuid(), uuid(), uuid()];
try {
  await db.exec(`create role anon;create role authenticated;create role service_role;
    create schema auth;
    create table auth.users(id uuid primary key,phone text,created_at timestamptz default now(),last_sign_in_at timestamptz);
    create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id) on delete cascade,not_after timestamptz);
    create function auth.jwt() returns jsonb language sql stable as 'select coalesce(nullif(current_setting(''request.jwt.claims'',true),''''),''{}'')::jsonb';
    create function auth.uid() returns uuid language sql stable as 'select nullif(auth.jwt()->>''sub'','''')::uuid';
    grant usage on schema auth to authenticated;grant execute on function auth.jwt(),auth.uid() to authenticated;
    create table public.stores(id uuid primary key default gen_random_uuid(),owner_id uuid references auth.users(id),name text not null,
      phone text,city text default '',contact_name text default '',created_at timestamptz default now(),plan text default 'trial',
      trial_ends_at timestamptz,archived_at timestamptz,delete_requested_at timestamptz);
    create table members(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),deleted_at timestamptz);
    create table orders(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),created_at timestamptz default now());
    create table public.merchant_accounts(owner_id uuid primary key references auth.users(id),phone text unique not null,primary_store_id uuid,frozen boolean not null default false);
    create table public.store_staff(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id) on delete cascade,name text not null,phone text not null,
      role text not null,resource_id uuid,joined_on date,status text not null default 'active',user_id uuid,created_at timestamptz default now());
    create table public.held_orders(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),settled_at timestamptz,cancelled_at timestamptz);
    create table public.appointments(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),technician_id uuid,status text not null default 'waiting');`);
  await db.query('insert into auth.users(id,phone,created_at,last_sign_in_at) values($1,null,now(),null),($2,null,now(),null),($3,$7,now()-interval \'3 days\',now()),($4,$8,now()-interval \'2 days\',null),($5,$9,now()-interval \'1 day\',null),($6,$10,now(),null)',
    [superId, opsId, ownerA, ownerB, techU, bothU, '8613800137712', '8613911223344', '8613677889900', '8613500001111']);
  await db.query('insert into auth.sessions values($1,$2,null),($3,$4,null),($5,$6,null),($7,$8,null)',
    [superS, superId, opsS, opsId, techS, techU, ownerAS, ownerA]);
  await db.exec(file('202611060004_admin_platform.sql'));
  await db.query("insert into admin_accounts(id,username,name,role,must_change) values($1,'super_test','Test Super','superAdmin',false),($2,'ops_test','Test Ops','ops',false)", [superId, opsId]);
  await db.exec(file('202611100008_account_cancellation.sql'));

  // 数据：老板 A（2 家店，其中一家有挂单和待到店预约）、老板 B（已申请注销）、技师、既是老板又是前台的人。
  const storeA1 = uuid(), storeA2 = uuid(), storeB = uuid(), storeC = uuid();
  await db.query("insert into stores(id,owner_id,name,contact_name,created_at) values($1,$3,'驰光汽车美容','陈明',now()-interval '3 days'),($2,$3,'驰光汽车美容 · 二店','陈明',now()-interval '2 days')", [storeA1, storeA2, ownerA]);
  await db.query("insert into stores(id,owner_id,name,contact_name,delete_requested_at) values($1,$2,'蓝鲸汽车美容','周老板',now()-interval '6 days')", [storeB, ownerB]);
  await db.query("insert into stores(id,owner_id,name,contact_name) values($1,$2,'星航汽车养护','孙老板')", [storeC, bothU]);
  await db.query("insert into merchant_accounts values($1,'+8613800137712',$2,false),($3,'+8613911223344',$4,false),($5,'+8613500001111',$6,false)", [ownerA, storeA1, ownerB, storeB, bothU, storeC]);
  const res = uuid();
  await db.query("insert into store_staff(store_id,name,phone,role,user_id,resource_id,joined_on) values($1,'吴师傅','13677889900','technician',$2,$3,'2026-07-02'),($4,'孙前台','13500001111','cashier',$5,null,'2026-08-01')", [storeA1, techU, res, storeA1, bothU]);
  await db.query("insert into held_orders(store_id) values($1),($1)", [storeA1]);
  await db.query("insert into held_orders(store_id,settled_at) values($1,now())", [storeA1]);
  await db.query("insert into appointments(store_id,technician_id,status) values($1,$2,'waiting'),($1,$2,'done'),($1,null,'arrived')", [storeA1, res]);
  await db.query("insert into members(store_id) values($1)", [storeA1]);

  const list = (args = {}, actor = superId, session = superS) =>
    scalar('select public.admin_user_list($1,$2,$3,$4,$5,$6,$7) as value',
      [actor, session, args.status ?? 'all', args.q ?? '', args.at ?? null, args.id ?? null, args.limit ?? 30]);
  const get = (id, actor = superId, session = superS) => scalar('select public.admin_user_get($1,$2,$3) as value', [actor, session, id]);
  const cancel = (id, reason = 'violation', note = '', request = uuid(), actor = superId, session = superS) =>
    scalar('select public.admin_user_cancel($1,$2,$3,$4,$5,$6) as value', [actor, session, id, reason, note, request]);

  // 列表：只包含老板和员工账号（不含运营账号），主角色取最高，状态与计数正确。
  let r = await list();
  assert.equal(r.items.length, 4); assert.equal(r.counts.total, 4);
  assert.deepEqual([r.counts.cooling, r.counts.cancelled, r.counts.frozen], [1, 0, 0]);
  assert.equal(r.items.some((x) => x.user_id === superId || x.user_id === opsId), false);
  const byId = Object.fromEntries(r.items.map((x) => [x.user_id, x]));
  assert.equal(byId[ownerA].role, 'owner'); assert.equal(byId[ownerA].phone, '13800137712'); assert.equal(byId[ownerA].name, '陈明');
  assert.equal(byId[ownerA].identities.length, 2, '老板的两家店');
  assert.equal(byId[ownerB].status, 'cooling'); assert.ok(byId[ownerB].delete_requested_at);
  assert.equal(byId[techU].role, 'technician'); assert.equal(byId[techU].phone, '13677889900');
  assert.equal(byId[bothU].role, 'owner'); assert.equal(byId[bothU].identities.length, 2, '同一账号的老板与前台两个身份');
  // 筛选、搜索（手机号 / 姓名 / 门店名）、分页
  assert.equal((await list({ status: 'cooling' })).items.length, 1);
  assert.equal((await list({ q: '1380013' })).items[0].user_id, ownerA);
  assert.equal((await list({ q: '周老板' })).items[0].user_id, ownerB);
  assert.equal((await list({ q: '星航' })).items[0].user_id, bothU);
  assert.equal((await list({ q: '二店' })).items[0].user_id, ownerA);
  assert.equal((await list({ q: '不存在' })).items.length, 0);
  r = await list({ limit: 2 });
  assert.equal(r.items.length, 2); assert.equal(r.more, true);
  const last = r.items.at(-1);
  r = await list({ limit: 2, at: last.created_at, id: last.user_id });
  assert.equal(r.items.length, 2); assert.equal(r.more, false);
  assert.equal(r.items.some((x) => x.user_id === last.user_id), false);
  await assert.rejects(() => list({ status: 'x' }), /账号状态无效/);
  await assert.rejects(() => list({}, opsId, opsS), /需要超级管理员权限/);
  await assert.rejects(() => list({}, superId, uuid()), /登录已过期/);

  // 详情：身份、在线设备、进行中的事项、操作记录。
  let d = await get(ownerA);
  assert.equal(d.devices, 1); assert.equal(d.open_holds, 2); assert.equal(d.open_appointments, 2);
  d = await get(techU);
  assert.equal(d.open_holds, 0); assert.equal(d.open_appointments, 1, '只统计分配给该技师且待到店的预约');
  d = await get(ownerB);
  assert.equal(d.events[0].text, '用户自助申请注销');
  await assert.rejects(() => get(uuid()), /账号不存在/);
  await assert.rejects(() => get(ownerA, opsId, opsS), /需要超级管理员权限/);

  // 强制注销：只停用账号并让所有设备退出，门店数据原样保留；幂等；不可重复注销。
  const before = {
    stores: await scalar('select count(*)::int as value from stores'), members: await scalar('select count(*)::int as value from members'),
    holds: await scalar('select count(*)::int as value from held_orders'), appts: await scalar('select count(*)::int as value from appointments'),
    staff: await scalar('select count(*)::int as value from store_staff'), accounts: await scalar('select count(*)::int as value from merchant_accounts'),
  };
  const request = uuid();
  assert.deepEqual(await cancel(ownerA, 'user_request', '用户电话要求', request), { ok: true, id: ownerA });
  assert.equal(await scalar('select count(*)::int as value from auth.sessions where user_id=$1', [ownerA]), 0, '所有设备退出');
  assert.equal(await scalar('select count(*)::int as value from auth.sessions where user_id=$1', [techU]), 1, '其他账号不受影响');
  assert.deepEqual({
    stores: await scalar('select count(*)::int as value from stores'), members: await scalar('select count(*)::int as value from members'),
    holds: await scalar('select count(*)::int as value from held_orders'), appts: await scalar('select count(*)::int as value from appointments'),
    staff: await scalar('select count(*)::int as value from store_staff'), accounts: await scalar('select count(*)::int as value from merchant_accounts'),
  }, before, '店铺数据全部保留');
  assert.equal((await db.query('select * from account_cancellations where user_id=$1', [ownerA])).rows[0].reason, 'user_request');
  assert.equal((await cancel(ownerA, 'user_request', '用户电话要求', request)).replayed, true, '同一请求编号重放');
  await assert.rejects(() => cancel(ownerA, 'other', '', request), /请求编号已用于其他操作/);
  await assert.rejects(() => cancel(ownerA, 'other'), /账号已注销/);
  d = await get(ownerA);
  assert.equal(d.item.status, 'cancelled'); assert.equal(d.devices, 0);
  assert.match(d.events[0].text, /后台强制注销（用户要求）/); assert.equal(d.events[0].by, 'Test Super');
  assert.equal((await list({ status: 'cancelled' })).items.length, 1);
  assert.equal((await list()).counts.cancelled, 1);
  assert.equal(await scalar("select count(*)::int as value from admin_audit_logs where action='user_cancel'"), 1);
  // 冷静期中的账号可以立即强制注销；参数与权限校验。
  await cancel(ownerB, 'violation', '');
  assert.equal((await get(ownerB)).item.status, 'cancelled', '注销优先于冷静期状态');
  await assert.rejects(() => cancel(techU, 'bad'), /请选择注销原因/);
  await assert.rejects(() => cancel(techU, 'other', 'x'.repeat(201)), /备注不能超过 200 字/);
  await assert.rejects(() => cancel(uuid(), 'other'), /账号不存在/);
  await assert.rejects(() => cancel(techU, 'other', '', uuid(), opsId, opsS), /需要超级管理员权限/);
  await assert.rejects(() => cancel(techU, 'other', '', null), /缺少请求编号/);
  assert.equal((await get(techU)).item.status, 'active', '被拒绝的操作不改变账号');
  console.log('PASS account list, filters, search, paging, detail, force cancellation keeps all store data, idempotency and super-admin only');
} finally {
  await db.close();
}
