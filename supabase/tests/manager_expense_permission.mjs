// Run: node supabase/tests/manager_expense_permission.mjs /path/to/@electric-sql/pglite/dist/index.js
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(process.argv[2]).href);
const db = new PGlite();
try {
  const old = readFileSync(new URL('../migrations/202611200001_technician_order_reuse.sql', import.meta.url), 'utf8');
  await db.exec(old.slice(old.indexOf('create or replace function'), old.indexOf('update public.store_role_permissions')));
  await db.exec(`create table store_role_permissions (
    store_id int, role text, permission text, allowed boolean, updated_at timestamptz default now()
  );
  insert into store_role_permissions(store_id,role,permission,allowed) values
    (1,'manager','expense',false),(2,'manager','expense',true),
    (1,'cashier','expense',false),(1,'technician','expense',false),
    (1,'manager','staff_manage',false),(1,'manager','stock_manage',true);`);
  const snapshot = async () => (await db.query('select store_id,role,permission,allowed from store_role_permissions order by store_id,role,permission')).rows;
  const before = await snapshot();
  const migration = readFileSync(new URL('../migrations/202611200005_manager_expense_permission.sql', import.meta.url), 'utf8');
  await db.exec(migration);
  const expected = before.map(row => row.role === 'manager' && row.permission === 'expense' ? {...row, allowed: true} : row);
  assert.deepEqual(await snapshot(), expected);
  const defaults = (await db.query(`select staff_permission_default('manager','expense') manager,
    staff_permission_default('cashier','expense') cashier,
    staff_permission_default('technician','expense') technician,
    staff_permission_default('technician','cashier') technician_cashier,
    staff_permission_default('manager','staff_manage') staff_manage`)).rows[0];
  assert.deepEqual(defaults, {manager: true, cashier: false, technician: false, technician_cashier: true, staff_manage: false});
  await db.exec(migration);
  assert.deepEqual(await snapshot(), expected);
  console.log('manager expense defaults, existing permissions and idempotency ok');
} finally {
  await db.close();
}
