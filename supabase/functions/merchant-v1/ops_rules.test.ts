import { parseCheckout, parseHold, parseWalkIn, parseExtend, parseFollowUp, parseRefund, parseSell } from './ops_rules.ts';

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

Deno.test('refund: retired for every destination, including old clients', () => {
  for (const to of ['原路退回', '储值余额', '现金', undefined]) {
    eq(parseRefund({ to, reason: '搬家 / 换车' }), '次卡退款功能已下线', String(to));
  }
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

Deno.test('hold: lines + status / remind from the design; hold_id optional; no prices', () => {
  const ok = parseHold({ member_id: M, lines: [{ service_id: S1, price: 1 }], status: '施工中', remind: '1 小时', plate: '沪a 8k29m', note: ' 划痕 ' });
  if (typeof ok === 'string') throw new Error(ok);
  eq([ok.hold_id, ok.status, ok.remind, ok.plate, ok.note], [null, '施工中', '1 小时', '沪A8K29M', '划痕'], 'fields');
  eq(ok.lines, [{ service_id: S1, qty: 1, member_package_id: null }], 'no price');
  const d = parseHold({ member_id: M, lines: [{ service_id: S1 }] });
  eq(typeof d === 'object' && [d.status, d.remind], ['待施工', '不提醒'], 'defaults');
  eq(typeof parseHold({ member_id: M, lines: [] }), 'string', 'empty');
  eq(typeof parseHold({ member_id: M, lines: [{ service_id: S1 }], status: '已完成' }), 'string', 'status');
  eq(typeof parseHold({ member_id: M, lines: [{ service_id: S1 }], remind: '明天' }), 'string', 'remind');
  eq(typeof parseHold({ member_id: M, lines: [{ service_id: S1 }], hold_id: 'x' }), 'string', 'hold id');
  eq(typeof parseHold({ member_id: M, lines: [{ service_id: S1 }], note: 'a'.repeat(201) }), 'string', 'note');
  const c = parseCheckout({ member_id: M, method: '现金', lines: [{ service_id: S1 }], hold_id: P });
  eq(typeof c === 'object' && c.hold_id, P, 'checkout hold id');
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

Deno.test('walk-in: no member, no package, cash-type methods only', () => {
  const ok = parseWalkIn({ method: '微信', lines: [{ service_id: S1, price: 1 }], plate: '苏k 5f218' });
  if (typeof ok === 'string') throw new Error(ok);
  eq([ok.method, ok.plate, ok.lines], ['微信', '苏K5F218', [{ service_id: S1, qty: 1, member_package_id: null }]], 'values');
  eq(typeof parseWalkIn({ method: '会员余额', lines: [{ service_id: S1 }] }), 'string', 'balance');
  eq(typeof parseWalkIn({ method: '组合支付', lines: [{ service_id: S1 }] }), 'string', 'combo');
  eq(typeof parseWalkIn({ method: '现金', lines: [{ service_id: S1, member_package_id: P }] }), 'string', 'package');
  eq(typeof parseWalkIn({ method: '现金', lines: [] }), 'string', 'empty');
});

Deno.test('walk-in hold: no member needed, no package, hold_id optional on walk-in checkout', () => {
  const h = parseHold({ walk_in: true, lines: [{ service_id: S1 }], plate: '苏k5f218' });
  if (typeof h === 'string') throw new Error(h);
  eq([h.member_id, h.plate], [null, '苏K5F218'], 'walk-in hold');
  eq(typeof parseHold({ walk_in: true, lines: [{ service_id: S1, member_package_id: P }] }), 'string', 'package');
  eq(typeof parseHold({ lines: [{ service_id: S1 }] }), 'string', 'member still required without walk_in');
  const w = parseWalkIn({ method: '现金', lines: [{ service_id: S1 }], hold_id: P });
  eq(typeof w === 'object' && w.hold_id, P, 'settle walk-in hold');
});
