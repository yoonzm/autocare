import { admin, fail, json, resolveSession, uuid } from './shared.ts';
import { authOnly } from './shared.ts';
import type { Input } from './types.ts';

const messages: Record<string, string> = {
  task_not_found: '任务不存在或不是派给你的',
  task_not_working: '该任务还没开工或已结束，不能更新',
  task_finished: '该任务已提交完工',
  stage_invalid: '请选择有效的施工阶段',
  stage_backward: '施工进度不能倒退',
  staff_not_found: '员工不存在',
  kind_invalid: '消息类型无效',
};
const rpcError = (e: { message: string; code?: string }) => {
  const key = Object.keys(messages).find((k) => e.message.includes(k));
  if (key) return fail(messages[key], e.code === 'P0002' ? 404 : 400);
  return fail('操作失败，请稍后重试', 500);
};

/** 员工端工作流：技师任务 / 进度 / 完工、业绩提成、消息。权限由 index.ts 的网关先校验，这里再按身份取数据范围。 */
export async function handleStaffWork(input: Input, request: Request): Promise<Response> {
  const auth = await authOnly(request);
  if ('response' in auth) return auth.response;
  const state = await resolveSession(auth.user.id, auth.token, true);
  if (state instanceof Response) return state;
  if (!state.staffId) return fail('请使用员工身份', 403);
  const store = state.store;
  const staff = state.staffId;
  const action = String(input.action);
  const call = async (fn: string, args: Record<string, unknown>, wrap = (d: unknown) => d) => {
    const { data, error } = await admin.rpc(fn, { p_store: store, p_staff: staff, ...args });
    return error ? rpcError(error) : json({ item: wrap(data) } as never);
  };
  try {
    if (action === 'staff_task_list') return await call('staff_task_list', {});
    if (action === 'staff_task_detail' || action === 'staff_task_progress' || action === 'staff_task_finish') {
      if (!uuid(input.id)) return fail('任务 ID 无效');
      if (action === 'staff_task_detail') return await call('staff_task_detail', { p_id: input.id });
      if (action === 'staff_task_finish') return await call('staff_task_finish', { p_id: input.id });
      const stage = Number(input.stage);
      if (!Number.isInteger(stage) || stage < 1 || stage > 3) return fail('请选择有效的施工阶段');
      return await call('staff_task_progress', { p_id: input.id, p_stage: stage });
    }
    if (action === 'staff_perf') return await call('staff_perf', {});
    if (action === 'staff_messages') {
      const kind = input.kind == null || input.kind === 'all' ? null : String(input.kind);
      return await call('staff_messages_list', { p_kind: kind });
    }
    if (action === 'staff_messages_read') {
      if (input.id != null && !uuid(input.id)) return fail('消息 ID 无效');
      return await call('staff_messages_read', { p_id: input.id ?? null });
    }
    return fail('不支持的员工操作');
  } catch (e) {
    return rpcError(e as { message: string; code?: string });
  }
}
