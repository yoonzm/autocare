// Run: node supabase/tests/sms_logs.mjs /path/to/@electric-sql/pglite/dist/index.js
// Isolated local Postgres; no production connection and no outbound SMS.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const uuid = () => crypto.randomUUID();
const scalar = async (sql, args = []) => (await db.query(sql, args)).rows[0].value;
const file = (name) => readFileSync(new URL('../migrations/' + name, import.meta.url), 'utf8');
const superId = uuid(), opsId = uuid(), superSession = uuid(), opsSession = uuid();
try {
  await db.exec(`create role anon;create role authenticated;create role service_role;
    create schema auth;create table auth.users(id uuid primary key);
    create table auth.sessions(id uuid primary key,user_id uuid references auth.users(id));
    create function auth.jwt() returns jsonb language sql stable as 'select coalesce(nullif(current_setting(''request.jwt.claims'',true),''''),''{}'')::jsonb';
    create function auth.uid() returns uuid language sql stable as 'select nullif(auth.jwt()->>''sub'','''')::uuid';
    grant usage on schema auth to authenticated;grant execute on function auth.jwt(),auth.uid() to authenticated;
    create table public.stores(id uuid primary key default gen_random_uuid(),owner_id uuid unique references auth.users(id),name text not null,
    phone text,city text default '',contact_name text default '',created_at timestamptz default now(),plan text default 'trial',trial_ends_at timestamptz);
    create table members(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),deleted_at timestamptz);
    create table orders(id uuid primary key default gen_random_uuid(),store_id uuid references stores(id),created_at timestamptz default now());`);
  await db.query('insert into auth.users values($1),($2)', [superId, opsId]);
  await db.query('insert into auth.sessions values($1,$2),($3,$4)', [superSession, superId, opsSession, opsId]);
  await db.exec(file('202611060004_admin_platform.sql'));
  await db.query("insert into admin_accounts(id,username,name,role,must_change) values($1,'super_test','Test Super','superAdmin',false),($2,'ops_test','Test Ops','ops',false)", [superId, opsId]);
  for (const name of ['202611010003_phone_otp.sql', '202611010006_forgot_password.sql', '202611060001_sms_channels.sql', '202611100007_sms_logs.sql']) {
    await db.exec(file(name));
  }
  const hash = 'a'.repeat(64), wrong = 'b'.repeat(64);
  const reserve = (phone, purpose, id, code = '482916') =>
    scalar('select public.reserve_phone_otp($1,$2,$3,$4,$5,$6,$7) as value', [phone, purpose, hash, id, code, `【汽美管家】验证码 ${code}`, '汽美管家']);
  const finish = (phone, purpose, id, sent, error = null) =>
    scalar('select public.finish_phone_otp($1,$2,$3,$4,$5,$6) as value', [phone, purpose, id, sent, 'zhutong', error]);
  const list = (args = {}, actor = superId, session = superSession) =>
    scalar('select public.admin_sms_list($1,$2,$3,$4,$5,$6,$7) as value',
      [actor, session, args.kind ?? 'all', args.phone ?? '', args.at ?? null, args.id ?? null, args.limit ?? 30]);

  // 发送：预留即写入明文验证码，完成后记录结果与时间；失败带原因。
  const a = uuid(), b = uuid();
  assert.deepEqual(await reserve('+8613800137712', 'login', a), {});
  let row = (await db.query('select * from sms_logs where request_id=$1', [a])).rows[0];
  assert.equal(row.status, 'pending'); assert.equal(row.code, '482916'); assert.equal(row.phone, '+8613800137712');
  assert.equal(await finish('+8613800137712', 'login', a, true), true);
  row = (await db.query('select * from sms_logs where request_id=$1', [a])).rows[0];
  assert.equal(row.status, 'sent'); assert.ok(row.sent_at); assert.equal(row.provider, 'zhutong');
  assert.deepEqual(await reserve('+8613677889900', 'login', b, '123456'), {});
  assert.equal(await finish('+8613677889900', 'login', b, false, '短信发送失败，请稍后重试（provider_rejected）'), true);
  assert.equal((await db.query('select * from sms_logs where request_id=$1', [b])).rows[0].error, '短信发送失败，请稍后重试（provider_rejected）');
  assert.equal(await finish('+8613677889900', 'login', uuid(), true), false, '陌生请求编号不能改记录');

  // 验证：错误次数与使用状态同步到记录。
  await db.query("update public.phone_otps set delivery_state='sent' where phone='+8613800137712'");
  await scalar('select public.verify_phone_otp($1,$2,$3,false) as value', ['+8613800137712', 'login', wrong]);
  assert.equal((await db.query('select attempts,consumed_at from sms_logs where request_id=$1', [a])).rows[0].attempts, 1);
  assert.equal(await scalar('select public.verify_phone_otp($1,$2,$3,true) as value', ['+8613800137712', 'login', hash]), 'ok');
  assert.ok((await db.query('select consumed_at from sms_logs where request_id=$1', [a])).rows[0].consumed_at);

  // 查询：筛选、手机号检索、失败计数、分页、权限。
  let r = await list();
  assert.equal(r.items.length, 2); assert.equal(r.failed_count, 1); assert.equal(r.more, false);
  assert.equal(r.items[0].phone, '+8613677889900', '最新的在前');
  assert.equal(r.items[1].code, '482916', '验证码明文返回');
  assert.equal((await list({ kind: 'failed' })).items.length, 1);
  assert.equal((await list({ kind: 'code' })).items.length, 2);
  assert.equal((await list({ kind: 'notice' })).items.length, 0);
  assert.equal((await list({ phone: '138 0013' })).items.length, 1);
  assert.equal((await list({ phone: '7712' })).items[0].phone, '+8613800137712');
  for (let i = 0; i < 3; i++) await db.query("insert into sms_logs(phone,purpose,created_at) values('+8613900000000','login',now()-make_interval(mins=>$1))", [i + 10]);
  r = await list({ limit: 2 });
  assert.equal(r.items.length, 2); assert.equal(r.more, true);
  const last = r.items.at(-1);
  r = await list({ limit: 2, at: last.created_at, id: last.id });
  assert.equal(r.items.length, 2); assert.equal(r.more, true);
  assert.equal(r.items.some((x) => x.id === last.id), false, '游标之后不重复');
  await assert.rejects(() => list({}, opsId, opsSession), /需要超级管理员权限/);
  await assert.rejects(() => list({}, superId, uuid()), /登录已过期/);
  await assert.rejects(() => list({ kind: 'x' }), /短信类型无效/);

  // 详情：返回完整记录并留审计；运营不可读；不存在 404。
  const detail = await scalar('select public.admin_sms_get($1,$2,$3) as value', [superId, superSession, row.id]);
  assert.equal(detail.item.code, '482916'); assert.ok(detail.now);
  assert.equal(await scalar("select count(*)::int as value from admin_audit_logs where action='sms_view'"), 1);
  await assert.rejects(() => scalar('select public.admin_sms_get($1,$2,$3) as value', [opsId, opsSession, row.id]), /需要超级管理员权限/);
  await assert.rejects(() => scalar('select public.admin_sms_get($1,$2,$3) as value', [superId, superSession, uuid()]), /短信记录不存在/);
  // 必须改密后才能读
  await db.query("update admin_accounts set must_change=true where id=$1", [superId]);
  await assert.rejects(() => list(), /请先修改初始或临时密码/);
  console.log('PASS sms log write, delivery result, verification sync, filters, paging, audit and super-admin only access');
} finally {
  await db.close();
}
