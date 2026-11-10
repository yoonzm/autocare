import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
const shop = crypto.randomUUID(), other = crypto.randomUUID(), empty = crypto.randomUUID();
const pack = crypto.randomUUID(), removedPack = crypto.randomUUID();
const stats = async (store, at = '2026-11-10T08:00:00Z') =>
  (await db.query('select public.merchant_package_stats($1,$2) as value', [store, at])).rows[0].value;
try {
  await db.exec(`
    create role anon; create role authenticated; create role service_role;
    create table public.member_packages (
      id uuid primary key default gen_random_uuid(), store_id uuid not null, package_id uuid not null,
      price_paid numeric(12,2) not null, purchased_at timestamptz not null,
      total_count int not null default 10, used_count int not null default 0,
      expires_at timestamptz, refunded_at timestamptz, refund_amount numeric(12,2) not null default 0
    );
    alter table public.member_packages enable row level security;
  `);
  await db.exec(readFileSync(new URL('../migrations/202611100004_package_stats.sql', import.meta.url), 'utf8'));
  assert.deepEqual(await stats(empty), {
    revenue: 0, change_percent: null, sold_month: 0, active_count: 0, expiring_count: 0, sold_by_package: {},
  });
  // 全量精确统计，不受 REST 默认 1000 行限制；永久卡计入在用。
  await db.query(`insert into member_packages(store_id,package_id,price_paid,purchased_at)
    select $1,$2,0.01,'2026-10-31T16:00:00Z' from generate_series(1,1001)`, [shop, pack]);
  await db.query(`insert into member_packages
    (store_id,package_id,price_paid,purchased_at,expires_at,used_count,refunded_at,refund_amount) values
    ($1,$2,100,'2026-10-31T15:59:59.999Z',null,0,'2026-11-01T00:00:00Z',40),
    ($1,$2,20,'2026-10-01T00:00:00Z',null,0,'2026-10-15T00:00:00Z',20),
    ($1,$2,30,'2026-11-01T00:00:00Z','2026-11-10T08:00:00Z',0,null,0),
    ($1,$2,40,'2026-11-01T00:00:00Z',null,10,null,0),
    ($1,$2,50,'2026-11-01T00:00:00Z','2026-11-17T08:00:00Z',0,null,0),
    ($1,$2,60,'2026-11-01T00:00:00Z','2026-11-17T08:00:00.001Z',0,null,0),
    ($1,$2,70,'2026-11-01T00:00:00Z',null,0,'2026-11-02T00:00:00Z',70),
    ($1,$3,80,'2026-11-01T00:00:00Z',null,0,null,0),
    ($1,$2,99999,'2026-11-30T16:00:00Z',null,0,null,0),
    ($4,$2,88888,'2026-11-01T00:00:00Z',null,0,null,0)`, [shop, pack, removedPack, other]);
  const expected = {
    revenue: 230.01, change_percent: 130, sold_month: 1007,
    active_count: 1004, expiring_count: 1, sold_by_package: { [pack]: 1008, [removedPack]: 1 },
  };
  await db.exec('set role service_role');
  for (const zone of ['UTC', 'Asia/Shanghai', 'America/Los_Angeles']) {
    await db.query("select set_config('TimeZone',$1,false)", [zone]);
    assert.deepEqual(await stats(shop), expected);
  }
  assert.equal((await stats(other)).revenue, 88888);
  assert.equal((await stats(shop, '2026-11-30T16:00:00Z')).sold_month, 1);
  assert.equal((await stats(shop, '2026-11-30T15:59:59.999Z')).sold_month, 1007);
  // 仅退款月份允许出现负净额，无上月正基数不展示环比。
  await db.exec('reset role');
  await db.query(`insert into member_packages(store_id,package_id,price_paid,purchased_at,refunded_at,refund_amount)
    values($1,$2,50,'2026-09-01T00:00:00Z','2026-11-09T00:00:00Z',50)`, [empty, pack]);
  const refundOnly = await stats(empty);
  assert.equal(refundOnly.revenue, -50);
  assert.equal(refundOnly.change_percent, null);
  assert.equal(refundOnly.sold_month, 0);
  assert.equal(refundOnly.active_count, 0);
  for (const role of ['anon', 'authenticated']) {
    await db.exec(`set role ${role}`);
    await assert.rejects(stats(shop), /permission denied for function merchant_package_stats/);
    await db.exec('reset role');
  }
  console.log('package_stats: totals, refunds, stores, expiry, month boundaries, timezones and grants passed');
} finally {
  await db.close();
}
