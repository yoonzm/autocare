import { fail, json, rpcError } from './shared.ts';
import type { Input, ReadContext, WriteContext } from './types.ts';

export const userReadActions = new Set(['user_list', 'user_get']);
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const reasons = ['user_request', 'violation', 'other'];

/** 所有账号（老板与员工）的只读查询；权限由 authorizeAction 与 SQL 双重限定为超级管理员。 */
export async function handleUserRead(
  action: string,
  input: Input,
  context: ReadContext,
): Promise<Response> {
  const { db } = context.services;
  const actor = { p_actor: context.me.id, p_session: context.sessionId };
  if (action === 'user_get') {
    if (typeof input.id !== 'string' || !uuidPattern.test(input.id)) {
      return fail('账号不存在', 404);
    }
    const { data, error } = await db.rpc('admin_user_get', { ...actor, p_id: input.id });
    return error ? rpcError(error) : json(data);
  }
  const status = input.status ?? 'all';
  const q = input.q ?? '';
  const before = input.before;
  const limit = input.limit ?? 30;
  if (
    typeof status !== 'string' || !['all', 'cooling', 'cancelled', 'frozen'].includes(status) ||
    typeof q !== 'string' || q.length > 40 ||
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
  const { data, error } = await db.rpc('admin_user_list', {
    ...actor, p_status: status, p_q: q, p_before_at: beforeAt, p_before_id: beforeId, p_limit: limit,
  });
  return error ? rpcError(error) : json(data);
}

/**
 * 强制注销：只处理账号——记录注销、所有设备退出、登录封禁；不删除、不改动任何门店数据。
 * 数据库事务先提交（幂等），再封禁登录；封禁失败时账号已注销，重试同一请求会补做封禁。
 */
export async function handleUserCancel(
  input: Input,
  context: WriteContext,
): Promise<Response> {
  if (typeof input.id !== 'string' || !uuidPattern.test(input.id)) {
    return fail('账号不存在', 404);
  }
  if (typeof input.reason !== 'string' || !reasons.includes(input.reason)) {
    return fail('请选择注销原因');
  }
  const note = typeof input.note === 'string' ? input.note.trim() : '';
  if (note.length > 200) return fail('备注不能超过 200 字');
  const { db } = context.services;
  const done = await db.rpc('admin_user_cancel', {
    p_actor: context.me.id,
    p_session: context.sessionId,
    p_user: input.id,
    p_reason: input.reason,
    p_note: note,
    p_request: context.requestId,
  });
  if (done.error) {
    await db.from('admin_audit_logs').insert({
      actor_id: context.me.id,
      action: 'user_cancel_failed',
      target: input.id,
      detail: { code: done.error.code, request_id: context.requestId },
    });
    return rpcError(done.error);
  }
  const banned = await db.auth.admin.updateUserById(input.id, { ban_duration: '876000h' });
  if (banned.error) return fail('账号已注销，但登录封禁未完成，请重试', 503);
  return json(done.data);
}
