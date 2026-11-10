import { admin, fail, failCode, resolveSession } from './shared.ts';
import { decide, type Role } from './staff_gate.ts';
import type { Input } from './types.ts';

/** 员工身份的权限校验：返回 Response 表示拒绝；老板（或无需校验）返回 null。 */
export async function gateStaff(request: Request, input: Input): Promise<Response | null> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  // 未登录的请求（登录、注册、验证码）不在这里处理；各业务处理器会返回它们既有的提示
  if (!token) return null;
  const { data: auth, error: authError } = await admin.auth.getUser(token);
  if (authError || !auth.user) return null;
  const state = await resolveSession(auth.user.id, token, false);
  if (state instanceof Response) return null;
  if (state.role === 'owner') return null;
  const { data, error } = await admin.rpc('staff_caps', { p_store: state.store, p_role: state.role });
  if (error || !data) return fail('权限校验失败，请稍后重试', 503);
  const decision = decide(state.role as Role, data as Record<string, boolean>, input);
  return decision.allowed ? null : failCode(decision.message ?? '暂无权限', 403, 'no_permission');
}

/** 技师只能看到派给自己的预约：返回其排班资源 ID；非技师返回 null（不限范围）。 */
export async function technicianScope(request: Request): Promise<string | null | 'none'> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return null;
  const { data: auth } = await admin.auth.getUser(token);
  if (!auth?.user) return null;
  const state = await resolveSession(auth.user.id, token, false);
  if (state instanceof Response || state.role !== 'technician' || !state.staffId) return null;
  const { data } = await admin.from('store_staff').select('resource_id').eq('id', state.staffId).maybeSingle();
  return data?.resource_id ?? 'none';
}
