import { parsePackage } from './package_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};
const S1 = '11111111-1111-1111-1111-111111111111';
const S2 = '22222222-2222-2222-2222-222222222222';
const ok = { name: '精致洗车年卡', price: 1080, items: [{ service_id: S1, count: 20 }] };

Deno.test('a minimal package gets the design defaults', () => {
  const r = parsePackage(ok);
  if (typeof r === 'string') throw new Error(r);
  eq(r.values, {
    name: '精致洗车年卡', price: 1080, validity_months: 12, purchase_limit: null,
    vehicle_scope: '全部车型', show_in_mini: true, description: '', active: true,
  }, 'values');
  eq(r.items, [{ service_id: S1, count: 20 }], 'items');
});

Deno.test('validity only allows the design choices', () => {
  for (const m of [0, 3, 6, 12, 24]) eq(typeof parsePackage({ ...ok, validity_months: m }), 'object', `m=${m}`);
  for (const m of [1, 5, 36, -1, 'x']) eq(parsePackage({ ...ok, validity_months: m }), '有效期无效', `m=${m}`);
});

Deno.test('name, price and limit are validated', () => {
  eq(parsePackage({ ...ok, name: '  ' }), '套餐名称长度须为 1–100 字', 'blank name');
  eq(parsePackage({ ...ok, name: 'x'.repeat(101) }), '套餐名称长度须为 1–100 字', 'long name');
  eq(parsePackage({ ...ok, price: -1 }), '套餐售价无效', 'negative');
  eq(parsePackage({ ...ok, price: '' }), '套餐售价无效', 'empty');
  eq(parsePackage({ ...ok, price: 0 }) !== '套餐售价无效', true, 'free is allowed');
  eq(parsePackage({ ...ok, purchase_limit: 0 }), '每人限购份数无效', 'limit 0');
  eq(parsePackage({ ...ok, purchase_limit: 1.5 }), '每人限购份数无效', 'limit fraction');
  const r = parsePackage({ ...ok, purchase_limit: 2 });
  if (typeof r === 'string') throw new Error(r);
  eq(r.values.purchase_limit, 2, 'limit');
  const u = parsePackage({ ...ok, purchase_limit: null });
  if (typeof u === 'string') throw new Error(u);
  eq(u.values.purchase_limit, null, 'unlimited');
});

Deno.test('services: at least one, valid ids, counts 1-999, no duplicates', () => {
  eq(parsePackage({ ...ok, items: [] }), '请至少添加一个包含服务', 'empty');
  eq(parsePackage({ ...ok, items: undefined }), '请至少添加一个包含服务', 'missing');
  eq(parsePackage({ ...ok, items: [{ service_id: 'nope', count: 1 }] }), '包含的服务无效', 'bad id');
  eq(parsePackage({ ...ok, items: [{ service_id: S1, count: 0 }] }), '服务次数须为 1–999', 'zero');
  eq(parsePackage({ ...ok, items: [{ service_id: S1, count: 1000 }] }), '服务次数须为 1–999', 'too many');
  eq(parsePackage({ ...ok, items: [{ service_id: S1, count: 1 }, { service_id: S1, count: 2 }] }), '同一个服务不能重复添加', 'dup');
  eq(typeof parsePackage({ ...ok, items: [{ service_id: S1, count: 3 }, { service_id: S2, count: 1 }] }), 'object', 'two');
});

Deno.test('switches must be booleans and the description is capped', () => {
  eq(parsePackage({ ...ok, active: 'yes' }), '开关设置无效', 'active');
  eq(parsePackage({ ...ok, show_in_mini: 1 }), '开关设置无效', 'mini');
  eq(parsePackage({ ...ok, description: 'x'.repeat(501) }), '套餐说明不能超过 500 字', 'description');
});
