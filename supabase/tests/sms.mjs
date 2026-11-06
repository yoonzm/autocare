// Run: node supabase/tests/sms.mjs /path/to/@electric-sql/pglite/dist/index.js
// Isolated local Postgres; no production connection and no outbound SMS.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
try {
  await db.exec(`create role anon;create role authenticated;create role service_role;
    create schema auth;create table auth.sessions(user_id uuid);`);
  for (const name of ['202611010003_phone_otp.sql', '202611010006_forgot_password.sql', '202611060001_sms_channels.sql']) {
    await db.exec(readFileSync(new URL('../migrations/' + name, import.meta.url), 'utf8'));
  }
  const scalar = async (sql, values = []) => (await db.query(sql, values)).rows[0].value;
  const hash = 'a'.repeat(64), wrong = 'b'.repeat(64);
  const phone = '+8613900000000';
  const reserve = (number, purpose, id = crypto.randomUUID()) =>
    scalar('select public.reserve_phone_otp($1,$2,$3,$4) as value', [number, purpose, hash, id]);
  const verify = (number, purpose, digest = hash, consume = false) =>
    scalar('select public.verify_phone_otp($1,$2,$3,$4) as value', [number, purpose, digest, consume]);
  const id = crypto.randomUUID();
  assert.deepEqual(await reserve(phone, 'register', id), {});
  assert.equal(await verify(phone, 'register'), 'not_sent');
  assert.equal((await reserve(phone, 'login')).error, 'cooldown');
  assert.equal(await scalar('select public.finish_phone_otp($1,$2,$3,true,$4) as value', [phone,'register',crypto.randomUUID(),'zhutong']), false);
  assert.equal(await scalar('select public.finish_phone_otp($1,$2,$3,true,$4) as value', [phone,'register',id,'zhutong']), true);
  assert.equal(await verify(phone, 'login'), 'missing');
  assert.equal(await verify(phone, 'register'), 'ok');
  assert.equal(await verify(phone, 'register'), 'ok'); // form preflight does not consume
  for (let i = 0; i < 5; i++) assert.equal(await verify(phone, 'register', wrong), 'invalid');
  assert.equal(await verify(phone, 'register'), 'attempts');
  assert.equal(await scalar('select attempts as value from public.phone_otps where phone=$1', [phone]), 5);
  await db.query('update public.phone_otps set attempts=0 where phone=$1', [phone]);
  assert.equal(await verify(phone, 'register', null), 'invalid'); // no SQL NULL bypass
  assert.equal(await verify(phone, 'register', hash, true), 'ok');
  assert.equal(await verify(phone, 'register', hash, true), 'consumed');
  console.log('PASS pending-state protection, purpose separation, attempt limits and one-time consumption');

  await db.query("update public.phone_otps set created_at=now()-interval '61 seconds' where phone=$1", [phone]);
  await db.query('update public.phone_sms_quota set count=10 where phone=$1', [phone]);
  assert.equal((await reserve(phone,'register')).error,'phone_quota');
  await db.exec("update public.phone_sms_quota set count=200 where phone='__autocare_global__';");
  assert.equal((await reserve('+8613900000001','register')).error,'global_quota');
  await db.exec("update public.phone_sms_quota set count=0 where phone='__autocare_global__';");
  console.log('PASS cross-purpose cooldown, phone daily limit and global spending guard');

  const failedPhone='+8613900000002', failedId=crypto.randomUUID();
  await reserve(failedPhone,'login',failedId);
  await scalar('select public.finish_phone_otp($1,$2,$3,false,$4) as value',[failedPhone,'login',failedId,'zhutong']);
  assert.equal(await verify(failedPhone,'login'), 'not_sent');
  await db.query("update public.phone_otps set delivery_state='sent',expires_at=now()-interval '1 second' where phone=$1",[failedPhone]);
  assert.equal(await verify(failedPhone,'login'), 'expired');
  console.log('PASS provider rejection and expired codes cannot authorize actions');

  const oldPhone='+8613900000003', nextPhone='+8613900000004';
  for (const [number,purpose] of [[oldPhone,'change_phone_old'],[nextPhone,'change_phone_new']]) {
    await reserve(number,purpose);
    await db.query("update public.phone_otps set delivery_state='sent' where phone=$1",[number]);
  }
  const consumePair=(newHash)=>scalar('select public.consume_phone_change_otps($1,$2,$3,$4) as value',[oldPhone,hash,nextPhone,newHash]);
  assert.equal(await consumePair(wrong),'new:invalid');
  assert.equal(await verify(oldPhone,'change_phone_old'),'ok'); // neither consumed on pair failure
  assert.equal(await consumePair(hash),'ok');
  assert.equal(await consumePair(hash),'old:consumed');
  for (const signature of ['reserve_phone_otp(text,text,text,uuid)','finish_phone_otp(text,text,uuid,boolean,text)','verify_phone_otp(text,text,text,boolean)','consume_phone_change_otps(text,text,text,text)']) {
    assert.equal(await scalar('select has_function_privilege($1,$2,$3) as value',['anon','public.'+signature,'execute']),false);
    assert.equal(await scalar('select has_function_privilege($1,$2,$3) as value',['authenticated','public.'+signature,'execute']),false);
    assert.equal(await scalar('select has_function_privilege($1,$2,$3) as value',['service_role','public.'+signature,'execute']),true);
  }
  console.log('PASS atomic two-phone verification and service-role-only verification functions');
} finally { await db.close(); }
