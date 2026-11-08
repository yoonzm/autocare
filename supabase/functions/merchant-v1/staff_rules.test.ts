import {
  inviteHash, inviteLink, newInviteToken, parseCommission, parsePermissions, parseRecords, parseServiceCommission,
  parseStaff, parseStatus,
} from './staff_rules.ts';
const id = 'aaaaaaaa-0000-0000-0000-000000000001';
const assert = (ok: boolean) => {
  if (!ok) throw new Error('assertion failed');
};
Deno.test('staff input: role, name, phone, skills and bay are validated; sensitive fields dropped', () => {
  const base = { name: ' 李国强 ', phone: '13812342207', role: 'technician', skills: ['镀晶', '抛光', '镀晶'], bay_id: id, joined_on: '2022-03-14' };
  const ok = parseStaff({ ...base, store_id: 'x', status: 'active', commission_rate: 99 }) as Record<string, unknown>;
  assert(typeof ok === 'object' && ok.name === '李国强' && ok.skills === '镀晶 / 抛光');
  assert(!('store_id' in ok) && !('status' in ok) && !('commission_rate' in ok));
  for (const bad of [
    { ...base, role: 'boss' }, { ...base, name: '' }, { ...base, name: 'x'.repeat(31) }, { ...base, phone: '123' },
    { ...base, skills: ['喷漆'] }, { ...base, bay_id: 'bad' }, { ...base, joined_on: '2022-13-40' }, { ...base, id: 'bad' },
  ]) assert(typeof parseStaff(bad) === 'string');
  const cashier = parseStaff({ ...base, role: 'cashier' }) as Record<string, unknown>;
  assert(cashier.skills === '' && cashier.bay_id === null);
  assert((parseStaff({ ...base, skills: '镀晶 / 抛光' }) as Record<string, unknown>).skills === '镀晶 / 抛光');
});
Deno.test('commission, status, permissions and records inputs', () => {
  assert(typeof parseCommission({ id, mode: 'flat', rate: 12 }) === 'object');
  assert(typeof parseCommission({ id, mode: 'custom', overrides: { [id]: 15 } }) === 'object');
  for (const bad of [
    { id, mode: 'x' }, { id, mode: 'flat', rate: 101 }, { id, mode: 'flat', rate: -1 },
    { id, mode: 'custom', overrides: { bad: 5 } }, { id, mode: 'custom', overrides: { [id]: '5' } },
    { id, mode: 'custom', overrides: [1] }, { id: 'bad', mode: 'follow' },
  ]) assert(typeof parseCommission(bad) === 'string');
  assert(typeof parseStatus({ id, status: 'disabled', reason: '离职', transfer_to: id }) === 'object');
  assert(typeof parseStatus({ id, status: 'gone' }) === 'string');
  assert(typeof parseStatus({ id, status: 'disabled', reason: 'x'.repeat(101) }) === 'string');
  assert(typeof parseStatus({ id, status: 'disabled', transfer_to: 'bad' }) === 'string');
  assert(typeof parsePermissions({ role: 'technician', permissions: { cashier: true } }) === 'object');
  for (const bad of [
    { role: 'manager', permissions: {} }, { role: 'technician', permissions: { fly: true } },
    { role: 'technician', permissions: { cashier: 'yes' } }, { role: 'technician' },
  ]) assert(typeof parsePermissions(bad) === 'string');
  assert(typeof parseRecords({ id }) === 'object' && typeof parseRecords({ id, range: 'year' }) === 'string');
});
Deno.test('invite token is random, hashed and only links over https', async () => {
  const a = newInviteToken(), b = newInviteToken();
  assert(a.length === 64 && a !== b);
  assert((await inviteHash(a)).length === 64 && (await inviteHash(a)) === (await inviteHash(a)) && (await inviteHash(a)) !== a);
  assert(inviteLink('https://staff.example.com/login', a) === `https://staff.example.com/login?invite=${a}`);
  assert(inviteLink(undefined, a) === null && inviteLink('http://x.com', a) === null && inviteLink('nope', a) === null);
});
Deno.test('service commission: type and range', () => {
  const none = parseServiceCommission({});
  assert(typeof none === 'object' && Object.keys(none).length === 0);
  const ok = parseServiceCommission({ commission_type: 'percent', commission_value: 8.456 }) as Record<string, unknown>;
  assert(ok.commission_value === 8.46);
  assert(typeof parseServiceCommission({ commission_type: 'percent', commission_value: 101 }) === 'string');
  assert(typeof parseServiceCommission({ commission_type: 'fixed', commission_value: 60 }) === 'object');
  assert(typeof parseServiceCommission({ commission_type: 'x', commission_value: 1 }) === 'string');
  assert(typeof parseServiceCommission({ commission_type: 'fixed' }) === 'string');
});
