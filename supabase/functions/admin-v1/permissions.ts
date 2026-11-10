import { sessionId } from './rules.ts';
import { fail, rpcError } from './shared.ts';
import type { AdminAccount, AdminServices, ReadContext } from './types.ts';

const privileged = new Set([
  'account_create',
  'account_role',
  'account_enabled',
  'account_reset',
  'plan_save',
  'refund',
  'sms_list',
  'sms_get',
  'sms_resend',
  'user_list',
  'user_get',
  'user_cancel',
]);

/** Verify the JWT before using session metadata; SQL checks the live session and profile. */
export async function adminFor(
  request: Request,
  services: AdminServices,
): Promise<ReadContext | Response> {
  const token =
    request.headers.get('authorization')?.replace(/^Bearer\s+/i, '') ?? '';
  if (!token) return fail('请先登录', 401);
  const { db } = services;
  const { data: auth, error: authError } = await db.auth.getUser(token);
  const sid = sessionId(token);
  if (authError || !auth.user || !sid) return fail('登录已过期', 401);
  const { data: me, error } = await db.rpc('admin_identity', {
    p_actor: auth.user.id,
    p_session: sid,
  });
  if (error) return rpcError(error);
  return { services, me: me as AdminAccount, sessionId: sid };
}

export async function authorizeAction(
  action: string,
  context: ReadContext,
): Promise<Response | null> {
  const { me, services } = context;
  if (me.must_change && !['change_password', 'logout'].includes(action)) {
    return fail('请先修改初始或临时密码', 403);
  }
  if (privileged.has(action) && me.role !== 'superAdmin') {
    await services.db.from('admin_audit_logs').insert({
      actor_id: me.id,
      action: 'permission_denied',
      target: action,
    });
    return fail('需要超级管理员权限', 403);
  }
  return null;
}
