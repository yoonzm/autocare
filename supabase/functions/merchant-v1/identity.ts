import { admin, authOnly, fail, failCode, json, resolveSession, uuid } from './shared.ts';
import type { Input } from './types.ts';

const rpcFail = (data: { error: string; status?: number; code?: string }) =>
  failCode(data.error, data.status ?? 400, data.code);

/** 登录后的身份：列出「门店 + 身份」、选择身份、首次确认加入门店、读取当前身份上下文与工作台。 */
export async function handleIdentity(input: Input, request: Request): Promise<Response> {
  const action = String(input.action);
  const auth = await authOnly(request);
  if ('response' in auth) return auth.response;
  const { user, token, session } = auth;
  try {
    if (action === 'identity_list') {
      const { data, error } = await admin.rpc('staff_identities', { p_user: user.id, p_session: session });
      if (error) return fail('读取身份失败，请稍后重试', 500);
      return data.error ? rpcFail(data) : json({ item: data });
    }
    if (action === 'identity_select') {
      // staff_id 为空表示回到老板身份
      if (input.staff_id != null && !uuid(input.staff_id)) return fail('身份无效');
      const { data, error } = await admin.rpc('select_staff_identity', {
        p_user: user.id, p_session: session, p_staff: input.staff_id ?? null,
      });
      if (error) return fail('切换身份失败，请稍后重试', 500);
      return data.error ? rpcFail(data) : json({ item: data });
    }
    if (action === 'identity_join') {
      const { data, error } = await admin.rpc('staff_join_confirm', { p_user: user.id, p_session: session });
      if (error) return fail('加入门店失败，请稍后重试', 500);
      return data.error ? rpcFail(data) : json({ item: data });
    }
    if (action === 'identity_context' || action === 'staff_home') {
      // 业务以外的状态（套餐到期、待确认）也要能读到身份，所以这里不做套餐校验
      const state = await resolveSession(user.id, token, action === 'staff_home');
      if (state instanceof Response) return state;
      if (action === 'identity_context') {
        const { data, error } = await admin.rpc('staff_context', { p_store: state.store, p_role: state.role, p_staff: state.staffId });
        return error ? fail('读取身份失败，请稍后重试', 500) : json({ item: data });
      }
      if (state.role === 'owner' || !state.staffId) return fail('老板请使用商家首页', 403);
      const { data, error } = await admin.rpc('staff_home', { p_store: state.store, p_staff: state.staffId });
      return error ? fail('读取工作台失败，请稍后重试', 500) : json({ item: data });
    }
    return fail('不支持的身份操作');
  } catch {
    return fail('身份操作失败，请稍后重试', 500);
  }
}
