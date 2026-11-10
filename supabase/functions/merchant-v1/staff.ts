import { admin, fail, json, storeFor, uuid } from './shared.ts';
import { operatorOf } from './members.ts';
import {
  inviteHash, inviteLink, newInviteToken, parseCommission, parsePermissions, parseRecords, parseStaff, parseStatus,
} from './staff_rules.ts';
import type { Input } from './types.ts';

const rpcError = (e: { message: string; code?: string }) => {
  const messages: Record<string, string> = {
    staff_not_found: '员工不存在',
    staff_disabled: '员工已停用，请先重新启用',
    staff_has_open_work: '该员工还有进行中或待到店的订单，请先转交',
    staff_state_unchanged: '员工状态已变化，请刷新后重试',
    transfer_target_invalid: '接手技师不可用，请重新选择',
    slot_unavailable: '接手技师在该时段已有安排，请换一位技师',
    invite_not_needed: '该员工无需邀请',
    role_locked: '老板权限固定为全部，不能修改',
    permission_invalid: '权限设置无效',
    role_invalid: '角色无效',
    commission_invalid: '提成设置无效',
    resource_not_found: '工位不存在或已停用',
    resource_busy: '该技师还有未完成预约，暂不能变更',
    resource_limit: '员工数量已达上限',
  };
  const key = Object.keys(messages).find((k) => e.message.includes(k));
  if (key) return fail(messages[key], 400);
  if (e.code === '23505') return fail('该手机号已是本店员工', 409);
  if (e.code === '23514' || e.code === '22P02') return fail('输入参数无效');
  return fail('员工操作失败，请稍后重试', 500);
};

export async function handleStaff(input: Input, request: Request): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  const action = String(input.action);
  const call = async (fn: string, args: Record<string, unknown>) => {
    const { data, error } = await admin.rpc(fn, args);
    return error ? rpcError(error) : json({ item: data });
  };
  try {
    if (action === 'staff_list') return await call('staff_list', { p_store: store });
    if (action === 'staff_get') {
      if (!uuid(input.id)) return fail('员工 ID 无效');
      return await call('staff_detail', { p_store: store, p_id: input.id });
    }
    if (action === 'staff_save') {
      const value = parseStaff(input);
      if (typeof value === 'string') return fail(value);
      return await call('save_staff', { p_store: store, p_input: value, p_operator: await operatorOf(store) });
    }
    if (action === 'staff_records') {
      const value = parseRecords(input);
      if (typeof value === 'string') return fail(value);
      return await call('staff_records', { p_store: store, p_id: value.id, p_range: value.range });
    }
    if (action === 'staff_status') {
      const value = parseStatus(input);
      if (typeof value === 'string') return fail(value);
      return await call('set_staff_status', {
        p_store: store, p_staff: value.id, p_status: value.status, p_reason: value.reason,
        p_transfer_to: value.transfer_to, p_operator: await operatorOf(store),
      });
    }
    if (action === 'staff_commission_save') {
      const value = parseCommission(input);
      if (typeof value === 'string') return fail(value);
      return await call('save_staff_commission', { p_store: store, p_staff: value.id, p_input: value });
    }
    if (action === 'staff_permissions_save') {
      const value = parsePermissions(input);
      if (typeof value === 'string') return fail(value);
      return await call('save_staff_permissions', { p_store: store, p_role: value.role, p_input: value.permissions });
    }
    if (action === 'staff_invite') {
      if (!uuid(input.id)) return fail('员工 ID 无效');
      // TODO: 短信邀请需要在助通登记“员工邀请”模板并为 SmsProvider 增加通知类发送；当前明确阻止，不返回假成功。
      // 预期接口：staff_invite { id, via: 'sms' } → SmsProvider.sendNotice(phone, template, vars)。
      if (input.via === 'sms') return fail('短信邀请尚未接通：缺少助通邀请短信模板', 501);
      // TODO: 员工端登录与激活（staff_activate：校验令牌哈希与手机号，写 activated_at、置 active）依赖员工端小程序，尚未实现。
      const base = Deno.env.get('STAFF_INVITE_BASE_URL');
      const probe = inviteLink(base, 'x');
      if (!probe) return fail('员工端邀请链接域名尚未配置（STAFF_INVITE_BASE_URL，须为 https）', 501);
      const token = newInviteToken();
      const { data, error } = await admin.rpc('create_staff_invite', {
        p_store: store, p_staff: input.id, p_hash: await inviteHash(token), p_operator: await operatorOf(store),
      });
      if (error) return rpcError(error);
      return json({ item: { ...data, link: inviteLink(base, token) } });
    }
    return fail('不支持的员工操作');
  } catch (e) {
    return rpcError(e as { message: string; code?: string });
  }
}
