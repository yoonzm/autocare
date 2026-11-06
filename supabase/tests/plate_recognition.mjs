// Isolated Postgres: no production credentials, photos or paid API calls.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const store = '11111111-1111-4111-8111-111111111111';
const other = '22222222-2222-4222-8222-222222222222';
try {
  await db.exec(`create role anon; create role authenticated; create role service_role;
    create table public.stores(id uuid primary key);
    insert into public.stores values('${store}'),('${other}');`);
  await db.exec(readFileSync(new URL('../migrations/202611060002_plate_recognition.sql', import.meta.url), 'utf8'));
  const scalar = async (sql, values = []) => (await db.query(sql, values)).rows[0].value;
  const reserve = (id = store) => scalar('select public.reserve_plate_recognition($1) as value', [id]);
  const concurrent = await Promise.all(Array.from({ length: 20 }, () => reserve()));
  assert.equal(concurrent.filter((v) => v === 'ok').length, 10);
  assert.equal(concurrent.filter((v) => v === 'minute').length, 10);
  assert.equal(await reserve(other), 'ok');
  await db.query("update public.plate_recognition_limits set minute_start=minute_start-interval '2 minutes' where store_id=$1", [store]);
  assert.equal(await reserve(), 'ok');
  await db.query('update public.plate_recognition_limits set day_count=500 where store_id=$1', [store]);
  assert.equal(await reserve(), 'day');
  await db.query("update public.plate_recognition_limits set day=day-1, minute_start=minute_start-interval '2 minutes' where store_id=$1", [store]);
  assert.equal(await reserve(), 'ok');
  assert.equal(await scalar('select day_count as value from public.plate_recognition_limits where store_id=$1', [store]), 1);
  for (const role of ['anon', 'authenticated']) {
    assert.equal(await scalar("select has_function_privilege($1,'public.reserve_plate_recognition(uuid)','EXECUTE') as value", [role]), false);
    assert.equal(await scalar("select has_table_privilege($1,'public.plate_recognition_limits','SELECT') as value", [role]), false);
  }
  assert.equal(await scalar("select has_function_privilege('service_role','public.reserve_plate_recognition(uuid)','EXECUTE') as value"), true);
  assert.equal(await scalar("select relrowsecurity as value from pg_class where oid='public.plate_recognition_limits'::regclass"), true);
  console.log('PASS plate recognition quotas: concurrent calls, store isolation, minute/day rollover, RLS and service-only RPC');
} finally { await db.close(); }
