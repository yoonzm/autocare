import { admin, authOnly, fail, json, storeFor, uuid } from './shared.ts';
import { SmsError } from './sms.ts';
import { sendStoreNotice } from './sms_notice.ts';
import {
  inviteHash, inviteLink, newInviteToken, parseCommission, parsePermissions, parseRecords, parseStaff, parseStatus,
} from './staff_rules.ts';
import type { Input } from './types.ts';

const rpcError = (e: { message: string; code?: string }) => {
  const messages: Record<string, string> = {
    staff_not_found: '员工不存在',
    staff_disabled: '员工已停用，请先重新启用',
    staff_has_open_tasks: '该员工还有未完成施工任务，请先完工或重新分配技师',
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
  if (e.code === '42501') return fail('仅老板可管理店长、设置角色权限或提成', 403);
  if (e.code === '40001') return fail('当前门店已变化，请刷新后重试', 409);
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
  const mutate = async (operation: string, value: Input) => {
    const auth = await authOnly(request);
    if ('response' in auth) return auth.response;
    const { data, error } = await admin.rpc('manage_store_staff', {
      p_user: auth.user.id, p_session: auth.session, p_store: store,
      p_action: operation, p_input: value,
    });
    if (error) return rpcError(error);
    if (data?.error) return json(data, data.status ?? 403);
    return json({ item: data });
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
      return await mutate('save', value);
    }
    if (action === 'staff_records') {
      const value = parseRecords(input);
      if (typeof value === 'string') return fail(value);
      return await call('staff_records', { p_store: store, p_id: value.id, p_range: value.range });
    }
    if (action === 'staff_status') {
      const value = parseStatus(input);
      if (typeof value === 'string') return fail(value);
      return await mutate('status', value);
    }
    if (action === 'staff_commission_save') {
      const value = parseCommission(input);
      if (typeof value === 'string') return fail(value);
      return await mutate('commission', value);
    }
    if (action === 'staff_permissions_save') {
      const value = parsePermissions(input);
      if (typeof value === 'string') return fail(value);
      return await mutate('permissions', value);
    }
    if (action === 'staff_invite') {
      if (!uuid(input.id)) return fail('员工 ID 无效');
      if (input.via === 'sms') {
        const [{ data: staffRow, error: staffErr }, { data: storeRow }] = await Promise.all([
          admin.from('store_staff').select('id, name, phone, role').eq('id', input.id).eq('store_id', store).maybeSingle(),
          admin.from('stores').select('name').eq('id', store).maybeSingle(),
        ]);
        if (staffErr) return fail('读取员工资料失败', 500);
        if (!staffRow) return fail('员工不存在', 404);
        const storeName = String(storeRow?.name ?? '门店').trim() || '门店';
        const roleLabel = staffRow.role === 'manager' ? '店长' : staffRow.role === 'cashier' ? '前台' : '技师';
        try {
          await sendStoreNotice({
            storeId: store,
            phone: staffRow.phone,
            purpose: 'staff_invite',
            content: `${storeName}邀请您加入团队（${roleLabel}），请下载并打开“我的汽美管家”App，使用本手机号验证码登录即可激活。`,
            storeName,
            requestId: typeof input.__request === 'string' ? input.__request : null,
          });
          return json({ ok: true });
        } catch (err) {
          if (err instanceof SmsError) return fail(err.message, err.status);
          return fail('该员工未登记有效手机号，无法发送短信邀请', 400);
        }
      }
      // 员工通过合并 App 的手机号登录与加入确认激活；链接仅在配置真实地址后生成。
      const base = Deno.env.get('STAFF_INVITE_BASE_URL');
      const probe = inviteLink(base, 'x');
      if (!probe) return fail('员工端邀请链接域名尚未配置（STAFF_INVITE_BASE_URL，须为 https）', 501);
      const token = newInviteToken();
      const response = await mutate('invite', { id: input.id, hash: await inviteHash(token) });
      if (!response.ok) return response;
      const data = await response.json();
      return json({ item: { ...data.item, link: inviteLink(base, token) } });
    }
    return fail('不支持的员工操作');
  } catch (e) {
    return rpcError(e as { message: string; code?: string });
  }
}
