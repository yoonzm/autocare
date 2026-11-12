import { parseRedeem, parseStaffLines, parseStaffOrder } from './staff_order_rules.ts';

const assert = (ok: boolean, msg = 'assertion failed') => {
  if (!ok) throw new Error(msg);
};
const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';

Deno.test('lines: required, bounded, only ids and quantities are accepted', () => {
  assert(typeof parseStaffLines([]) === 'string');
  assert(typeof parseStaffLines([{ service_id: 'x' }]) === 'string');
  assert(typeof parseStaffLines([{ service_id: A, qty: 0 }]) === 'string');
  assert(typeof parseStaffLines([{ service_id: A, qty: 21 }]) === 'string');
  const ok = parseStaffLines([{ service_id: A, qty: 2, price: 1, member_package_id: B }]);
  assert(Array.isArray(ok) && ok.length === 1 && !('price' in ok[0]), 'client prices are dropped');
  assert(Array.isArray(ok) && ok[0].member_package_id === B);
});

Deno.test('order: member, plate and note rules', () => {
  assert(typeof parseStaffOrder({ lines: [{ service_id: A }] }) === 'string');
  const v = parseStaffOrder({ member_id: A, lines: [{ service_id: B }], plate: '沪a·8k29m', note: ' 备注 ' });
  assert(typeof v !== 'string' && v.plate === '沪A8K29M' && v.note === '备注');
  assert(typeof parseStaffOrder({ member_id: A, lines: [{ service_id: B }], note: 'x'.repeat(201) }) === 'string');
});

Deno.test('redeem: six digit code required', () => {
  const base = { member_id: A, member_package_id: B, service_id: A, qty: 1 };
  assert(typeof parseRedeem({ ...base, code: '12345' }) === 'string');
  assert(typeof parseRedeem({ ...base, code: 'abcdef' }) === 'string');
  assert(typeof parseRedeem({ ...base, code: '123456', qty: 11 }) === 'string');
  assert(typeof parseRedeem({ ...base, code: '123456' }) !== 'string');
});
