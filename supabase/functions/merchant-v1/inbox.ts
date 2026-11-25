import { admin, authOnly, resolveSession, fail, json } from './shared.ts';
import { inboxArgs } from './inbox_rules.ts';
import type { Input } from './types.ts';
export async function handleInbox(input: Input, request: Request): Promise<Response> {
  const auth = await authOnly(request);
  if ('response' in auth) return auth.response;
  const state = await resolveSession(auth.user.id, auth.token, true);
  if (state instanceof Response) return state;
  const args = inboxArgs(input as Record<string, unknown>);
  if (typeof args === 'string') return fail(args);
  const { data, error } = await admin.rpc(String(input.action), {
    ...args, p_store: state.store, p_staff: state.role === 'owner' ? null : state.staffId,
    p_owner: state.role === 'owner' ? auth.user.id : null,
  });
  if (error) {
    if (error.code === '42501') return fail('暂无权限查看这些消息', 403);
    if (error.code === 'P0002') return fail('消息不存在或已不可访问', 404);
    if (error.message.includes('inbox_invalid')) return fail('消息请求参数无效');
    return fail('消息操作失败，请稍后重试', 500);
  }
  return json({ item: data });
}
