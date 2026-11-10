import { fail, json, rpcError } from './shared.ts';
import { SmsDeliveryError } from './sms.ts';
import type { Input, ReadContext, WriteContext } from './types.ts';

export const smsReadActions = new Set(['sms_list', 'sms_get']);
export const smsActions = new Set([...smsReadActions, 'sms_resend']);
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** 短信记录（含明文验证码）：权限由 authorizeAction 与 SQL 双重限定为超级管理员。 */
export async function handleSmsRead(
  action: string,
  input: Input,
  context: ReadContext,
): Promise<Response> {
  const { db } = context.services;
  const actor = { p_actor: context.me.id, p_session: context.sessionId };
  if (action === 'sms_get') {
    if (typeof input.id !== 'string' || !uuidPattern.test(input.id)) {
      return fail('短信记录不存在', 404);
    }
    const { data, error } = await db.rpc('admin_sms_get', { ...actor, p_id: input.id });
    return error ? rpcError(error) : json(data);
  }
  const kind = input.kind ?? 'all';
  const phone = input.phone ?? '';
  const before = input.before;
  const limit = input.limit ?? 30;
  if (
    typeof kind !== 'string' || !['all', 'code', 'notice', 'failed'].includes(kind) ||
    typeof phone !== 'string' || phone.length > 20 ||
    typeof limit !== 'number' || !Number.isInteger(limit) || limit < 1 || limit > 50
  ) return fail('查询参数无效');
  let beforeAt: string | null = null;
  let beforeId: string | null = null;
  if (before != null) {
    const cursor = before as Input;
    if (
      typeof before !== 'object' || typeof cursor.at !== 'string' ||
      Number.isNaN(Date.parse(cursor.at)) || typeof cursor.id !== 'string' ||
      !uuidPattern.test(cursor.id)
    ) return fail('分页参数无效');
    beforeAt = cursor.at;
    beforeId = cursor.id;
  }
  const { data, error } = await db.rpc('admin_sms_list', {
    ...actor, p_kind: kind, p_phone: phone, p_before_at: beforeAt, p_before_id: beforeId, p_limit: limit,
  });
  return error ? rpcError(error) : json(data);
}

/** 重发只对验证码短信有效：新验证码经真实渠道发送，遵守冷却和每日额度；结果写入审计。 */
export async function handleSmsResend(
  input: Input,
  context: WriteContext,
): Promise<Response> {
  if (typeof input.id !== 'string' || !uuidPattern.test(input.id)) {
    return fail('短信记录不存在', 404);
  }
  const { db } = context.services;
  const found = await db.rpc('admin_sms_get', {
    p_actor: context.me.id, p_session: context.sessionId, p_id: input.id,
  });
  if (found.error) return rpcError(found.error);
  const item = (found.data as { item: { kind: string; phone: string; purpose: string } }).item;
  if (item.kind !== 'code') return fail('只有验证码短信可以重发');
  try {
    const sent = await context.services.sendCode(item.phone, item.purpose, context.requestId);
    await db.from('admin_audit_logs').insert({
      actor_id: context.me.id,
      action: 'sms_resend',
      target: input.id,
      detail: { phone: item.phone, purpose: item.purpose, request_id: context.requestId },
    });
    return json({ ok: true, retry_after: sent.retry_after ?? 60 });
  } catch (error) {
    if (error instanceof SmsDeliveryError) return fail(error.message, error.status);
    return fail('短信暂不可用，请稍后重试', 503);
  }
}
