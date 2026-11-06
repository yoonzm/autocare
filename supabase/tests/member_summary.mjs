// Isolated PostgreSQL test. No production connection or external requests.
// node supabase/tests/member_summary.mjs <path-to-pglite/dist/index.js>
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const shop = crypto.randomUUID(), other = crypto.randomUUID(), empty = crypto.randomUUID();
const tier = crypto.randomUUID(), inactiveTier = crypto.randomUUID();
const summary = async (store, at = '2026-11-30T16:30:00Z') =>
  (await db.query('select public.merchant_member_summary($1, $2) as value', [store, at])).rows[0].value;
try {
  // Minimal schema matches the columns used by the aggregate. Full business
  // migrations are covered separately; no RLS changes are made by this migration.
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create table public.members (
      id uuid primary key default gen_random_uuid(), store_id uuid not null,
      card_type_id uuid not null, balance numeric(12,2) not null default 0,
      created_at timestamptz not null default now(), deleted_at timestamptz
    );
    create index members_store_id_idx on public.members(store_id);
    alter table public.members enable row level security;
  `);
  await db.exec(readFileSync(new URL('../migrations/202611060006_member_summary.sql', import.meta.url), 'utf8'));
  // Above both the usual API row limit and the old .limit(100000) cutoff.
  await db.query(`insert into members(store_id,card_type_id,balance,created_at)
    select $1,$2,0.01,'2026-11-01T00:00:00Z' from generate_series(1,100005)`, [shop,tier]);
  await db.query(`insert into members(store_id,card_type_id,balance,created_at,deleted_at) values
    ($1,$2,0.10,'2026-11-30T15:59:59.999Z',null),
    ($1,$2,0.20,'2026-11-30T16:00:00Z',null),
    ($1,$2,0.30,'2026-12-31T15:59:59.999Z',null),
    ($1,$2,0.40,'2026-12-31T16:00:00Z',null),
    ($1,$2,999,'2026-12-01T00:00:00Z',now()),
    ($3,$2,888,'2026-12-01T00:00:00Z',null)`, [shop,inactiveTier,other]);
  await db.exec('set role service_role');
  assert.deepEqual(await summary(shop), {
    total: 100009, total_balance: 1001.05, new_this_month: 2,
    counts: { [tier]: 100005, [inactiveTier]: 4 },
  });
  assert.deepEqual(await summary(other), {
    total: 1, total_balance: 888, new_this_month: 1, counts: { [inactiveTier]: 1 },
  });
  assert.deepEqual(await summary(empty), {
    total: 0, total_balance: 0, new_this_month: 0, counts: {},
  });
  assert.equal((await summary(shop, '2026-11-30T15:59:59Z')).new_this_month, 100006);
  assert.equal((await summary(shop, '2026-12-31T16:00:00Z')).new_this_month, 1);
  for (const zone of ['UTC', 'Asia/Shanghai', 'America/Los_Angeles']) {
    await db.query("select set_config('TimeZone',$1,false)", [zone]);
    assert.equal((await summary(shop)).new_this_month, 2);
  }
  // Production call omits the test clock and uses database time.
  const live = (await db.query('select public.merchant_member_summary($1) as value', [shop])).rows[0].value;
  assert.equal(live.total, 100009);
  await db.exec('reset role');
  for (const role of ['anon', 'authenticated']) {
    await db.exec(`set role ${role}`);
    await assert.rejects(summary(shop), /permission denied for function merchant_member_summary/);
    await db.exec('reset role');
  }
  console.log('member_summary: large dataset, exact sums, stores, deletion, month boundaries, timezones and grants passed');
} finally {
  await db.close();
}
