import { consumableError, parseConsumables } from './service_rules.ts';
const a = 'aaaaaaaa-0000-0000-0000-000000000001';
const b = 'aaaaaaaa-0000-0000-0000-000000000002';
const assert = (ok: boolean) => {
  if (!ok) throw new Error('assertion failed');
};
Deno.test('consumables: undefined keeps, empty clears, validates ids, quantity and duplicates', () => {
  assert(parseConsumables(undefined) === undefined);
  assert(Array.isArray(parseConsumables([])) && (parseConsumables([]) as unknown[]).length === 0);
  const ok = parseConsumables([{ product_id: a, quantity: 1.5 }, { product_id: b, quantity: 2 }]);
  assert(Array.isArray(ok) && ok.length === 2 && ok[0].quantity === 1.5);
  for (
    const bad of [
      'x',
      [{ product_id: 'bad', quantity: 1 }],
      [{ product_id: a, quantity: 0 }],
      [{ product_id: a, quantity: -1 }],
      [{ product_id: a, quantity: 1.2345 }],
      [{ product_id: a, quantity: 1_000_000 }],
      [{ product_id: a, quantity: 1 }, { product_id: a, quantity: 2 }],
      Array.from({ length: 21 }, (_, i) => ({ product_id: `aaaaaaaa-0000-0000-0000-0000000000${(10 + i).toString()}`, quantity: 1 })),
    ]
  ) assert(typeof parseConsumables(bad) === 'string');
});
Deno.test('consumable database errors map to readable messages', () => {
  assert(consumableError('product_disabled').includes('停用'));
  assert(consumableError('weird') === '耗材保存失败');
});
