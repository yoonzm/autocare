/** 订单中心的数据范围：老板和有「查看全部订单」权限的身份看全店；只有「查看本人订单」的员工只看派给自己的订单；其余看不到。 */
export type OrderScope =
  | { kind: 'all' }
  | { kind: 'own'; resource: string }
  | { kind: 'none' };

export function orderScopeFor(
  role: string,
  caps: Record<string, boolean> | null | undefined,
  resourceId: string | null | undefined,
): OrderScope {
  if (role === 'owner') return { kind: 'all' };
  if (caps?.order_view_all === true) return { kind: 'all' };
  // 本人订单靠员工对应的排班资源（技师）识别；没有排班资源的员工没有「本人订单」。
  if (caps?.order_view_own === true && resourceId) return { kind: 'own', resource: resourceId };
  return { kind: 'none' };
}
