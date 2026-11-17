import { orderScopeFor } from './order_scope.ts';
function equal(a: unknown, b: unknown) {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${JSON.stringify(a)} !== ${JSON.stringify(b)}`);
}
Deno.test('老板和有「查看全部订单」权限的身份看全店', () => {
  equal(orderScopeFor('owner', null, null), { kind: 'all' });
  equal(orderScopeFor('cashier', { order_view_all: true }, null), { kind: 'all' });
  // 同时有两个权限时以全部为准
  equal(orderScopeFor('manager', { order_view_all: true, order_view_own: true }, 'r1'), { kind: 'all' });
});
Deno.test('只有「查看本人订单」的技师只看自己的排班资源', () => {
  equal(orderScopeFor('technician', { order_view_own: true }, 'r1'), { kind: 'own', resource: 'r1' });
});
Deno.test('没有权限、或没有排班资源时什么也看不到', () => {
  equal(orderScopeFor('technician', { order_view_own: true }, null), { kind: 'none' });
  equal(orderScopeFor('technician', { order_view_own: true }, undefined), { kind: 'none' });
  equal(orderScopeFor('cashier', {}, 'r1'), { kind: 'none' });
  equal(orderScopeFor('technician', null, 'r1'), { kind: 'none' });
});
