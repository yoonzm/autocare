import { operatorOf } from './members.ts';
import { PAGE_SIZE, parseOrderDetail, parseOrderQuery, parseOrderRefund } from './order_rules.ts';
import { orderScopeOf } from './staff_access.ts';
import { admin, fail, json, storeFor } from './shared.ts';
import type { Input } from './types.ts';

const refundFail = (error: { code?: string; message: string }) => {
  if (error.code === 'P0002') return fail('订单不存在', 404);
  if (error.code === 'P0001') {
    if (error.message.includes('already_refunded')) return fail('这笔订单已经退款，不能重复退款', 400);
    return fail('请选择退款原因', 400);
  }
  return fail('退款失败', 500);
};

/** 订单中心：统一订单列表（消费 / 充值 / 次卡 / 退款）、详情、消费订单整单退款。
 *  汇总口径、状态变更、退回方式都在数据库函数里执行，这里只校验入参并转发。 */
export async function handleOrderCenter(input: Input, request: Request): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  const action = String(input.action);
  // 数据范围由已认证会话的身份决定：只有「查看全部订单」才能读全店，「查看本人订单」只读派给自己的。
  const scope = await orderScopeOf(request);
  if (scope.kind === 'none') return fail('暂无权限', 403);
  if (action === 'order_list') {
    const q = parseOrderQuery(input);
    if (typeof q === 'string') return fail(q);
    const feedArgs = {
      p_store: store, p_from: q.from, p_to: q.to, p_kind: q.kind, p_method: q.method, p_status: q.status,
      p_operator: q.operator, p_q: q.q, p_before: q.before, p_limit: q.limit,
    };
    const { data, error } = scope.kind === 'own'
      ? await admin.rpc('order_feed_scoped', { ...feedArgs, p_resource: scope.resource })
      : await admin.rpc('order_feed', feedArgs);
    if (error) return fail('读取订单失败', 500);
    const rows = (data?.items ?? []) as unknown[];
    // 多取一条用来判断是否还有下一页
    const hasMore = rows.length > PAGE_SIZE;
    // 经办人选项是全店信息，只给能看全店订单的身份。
    const operators = scope.kind === 'all' && input.with_options === true ? (await admin.rpc('order_operators', { p_store: store })).data : undefined;
    return json({
      item: { items: rows.slice(0, PAGE_SIZE), summary: data?.summary, has_more: hasMore, ...(operators ? { operators } : {}) },
    });
  }
  if (action === 'order_detail') {
    const v = parseOrderDetail(input);
    if (typeof v === 'string') return fail(v);
    const { data, error } = scope.kind === 'own'
      ? await admin.rpc('order_detail_scoped', { p_store: store, p_kind: v.kind, p_id: v.id, p_resource: scope.resource })
      : await admin.rpc('order_detail', { p_store: store, p_kind: v.kind, p_id: v.id });
    if (error) return error.code === 'P0002' ? fail('订单不存在', 404) : fail('读取订单失败', 500);
    return json({ item: data });
  }
  if (action === 'order_refund') {
    const v = parseOrderRefund(input);
    if (typeof v === 'string') return fail(v);
    // 幂等标识只取请求头（同一次点击带同一个 X-Request-Id）
    const requestId = request.headers.get('x-request-id');
    if (scope.kind === 'own') {
      // 只能退自己范围内的订单：越范围按「订单不存在」处理。
      const probe = await admin.rpc('order_detail_scoped', { p_store: store, p_kind: 'consume', p_id: v.id, p_resource: scope.resource });
      if (probe.error) return probe.error.code === 'P0002' ? fail('订单不存在', 404) : fail('退款失败', 500);
    }
    const { data, error } = await admin.rpc('refund_order', {
      p_store: store, p_order: v.id, p_reason: v.reason, p_operator: await operatorOf(store), p_request: requestId,
    });
    return error ? refundFail(error) : json({ item: data });
  }
  return fail('不支持的操作');
}
