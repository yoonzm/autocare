import { parseCheckout, parseExtend, parseFollowUp, parseRefund, parseSell } from './ops_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};
const M = '11111111-1111-1111-1111-111111111111';
const P = '22222222-2222-2222-2222-222222222222';
const S1 = '33333333-3333-3333-3333-333333333333';
const S2 = '44444444-4444-4444-4444-444444444444';

Deno.test('sell: member, package and a pay method are required (余额 is allowed)', () => {
  eq(typeof parseSell({ member_id: M, package_id: P, method: '会员余额' }), 'object', 'balance');
  eq(typeof parseSell({ member_id: M, package_id: P, method: '微信' }), 'object', 'wechat');
  eq(typeof parseSell({ member_id: M, package_id: P, method: '赊账' }), 'string', 'bad method');
  eq(typeof parseSell({ member_id: M, method: '微信' }), 'string', 'no package');
  eq(typeof parseSell({ package_id: P, method: '微信' }), 'string', 'no member');
});

Deno.test('extend: whole days, design reasons only', () => {
  eq(typeof parseExtend({ days: 30, reason: '会员长期出差' }), 'object', 'ok');
  for (const d of [0, -1, 1.5, 4000, 'x', undefined]) {
    eq(typeof parseExtend({ days: d, reason: '其他' }), 'string', String(d));
  }
  eq(typeof parseExtend({ days: 30, reason: '随便' }), 'string', 'reason');
});

Deno.test('refund: needs a way back and a reason', () => {
  eq(typeof parseRefund({ to: '储值余额', reason: '搬家 / 换车' }), 'object', 'ok');
  eq(typeof parseRefund({ to: '现金', reason: '搬家 / 换车' }), 'string', 'bad to');
  eq(typeof parseRefund({ to: '原路退回', reason: '' }), 'string', 'no reason');
});

Deno.test('checkout: lines, quantities and payment are validated; prices are never read', () => {
  const ok = parseCheckout({
    member_id: M, method: '会员余额',
    lines: [{ service_id: S1, qty: 1, member_package_id: P, price: 0.01 }, { service_id: S2 }],
  });
  if (typeof ok === 'string') throw new Error(ok);
  eq(ok.lines, [
    { service_id: S1, qty: 1, member_package_id: P },
    { service_id: S2, qty: 1, member_package_id: null },
  ], 'lines carry no price');
  eq(typeof parseCheckout({ member_id: M, method: '现金', lines: [] }), 'string', 'empty');
  eq(typeof parseCheckout({ member_id: M, method: '现金', lines: [{ service_id: S1, qty: 0 }] }), 'string', 'qty 0');
  eq(typeof parseCheckout({ member_id: M, method: '现金', lines: [{ service_id: S1, qty: 100 }] }), 'string', 'qty 100');
  eq(typeof parseCheckout({ member_id: M, method: '现金', lines: [{ service_id: S1 }, { service_id: S1 }] }), 'string', 'dup');
  eq(typeof parseCheckout({ member_id: M, method: '赊账', lines: [{ service_id: S1 }] }), 'string', 'method');
  eq(typeof parseCheckout({ member_id: M, method: '现金', lines: [{ service_id: 'x' }] }), 'string', 'id');
});

Deno.test('checkout: combined payment needs a balance part and another method', () => {
  const lines = [{ service_id: S1 }];
  eq(typeof parseCheckout({ member_id: M, method: '组合支付', lines, balance_part: 100, other: '微信' }), 'object', 'ok');
  eq(typeof parseCheckout({ member_id: M, method: '组合支付', lines, other: '微信' }), 'string', 'no balance');
  eq(typeof parseCheckout({ member_id: M, method: '组合支付', lines, balance_part: 100 }), 'string', 'no other');
  eq(typeof parseCheckout({ member_id: M, method: '组合支付', lines, balance_part: 10.123, other: '现金' }), 'string', 'cents');
});

Deno.test('follow-up: method / result from the design, date not in the past', () => {
  const today = new Date('2026-11-02T00:00:00Z');
  const base = { member_id: M, method: '电话', result: '已接通 · 有意向' };
  const r = parseFollowUp({ ...base, next_at: '2026.11.08' }, today);
  eq(typeof r === 'object' && r.next_at, '2026-11-08', 'dotted date');
  eq(typeof parseFollowUp({ ...base, next_at: '2026-10-01' }, today), 'string', 'past');
  eq(typeof parseFollowUp({ ...base, method: '短信' }, today), 'string', 'method');
  eq(typeof parseFollowUp({ ...base, result: '随便' }, today), 'string', 'result');
  eq(typeof parseFollowUp({ ...base, content: 'a'.repeat(501) }, today), 'string', 'long');
  eq(typeof parseFollowUp(base, today), 'object', 'no date is fine');
});
