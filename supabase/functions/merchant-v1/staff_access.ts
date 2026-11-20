import { admin, fail, failCode, resolveSession } from './shared.ts';
import { orderScopeFor, type OrderScope } from './order_scope.ts';
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

/** 订单中心的数据范围：按已认证会话的员工身份推出，不接受客户端传入。老板返回全部。 */
export async function orderScopeOf(request: Request): Promise<OrderScope> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return { kind: 'none' };
  const { data: auth } = await admin.auth.getUser(token);
  if (!auth?.user) return { kind: 'none' };
  const state = await resolveSession(auth.user.id, token, false);
  if (state instanceof Response) return { kind: 'none' };
  if (state.role === 'owner') return { kind: 'all' };
  const { data: caps } = await admin.rpc('staff_caps', { p_store: state.store, p_role: state.role });
  let resource: string | null = null;
  if (state.staffId) {
    const { data } = await admin.from('store_staff').select('resource_id').eq('id', state.staffId).maybeSingle();
    resource = data?.resource_id ?? null;
  }
  return orderScopeFor(state.role, caps as Record<string, boolean> | null, resource);
}

/** 当前会话是否具备指定权限（老板固定返回 true）。用于决定是否返回手机号等敏感字段。 */
export async function hasCap(request: Request, cap: string): Promise<boolean> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return false;
  const { data: auth } = await admin.auth.getUser(token);
  if (!auth?.user) return false;
  const state = await resolveSession(auth.user.id, token, false);
  if (state instanceof Response) return false;
  if (state.role === 'owner') return true;
  const { data: caps } = await admin.rpc('staff_caps', { p_store: state.store, p_role: state.role });
  return Boolean((caps as Record<string, boolean> | null)?.[cap]);
}
