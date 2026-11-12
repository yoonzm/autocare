import { admin, authOnly, fail, json, resolveSession, uuid } from './shared.ts';
import type { Input } from './types.ts';

export async function handleAccountTools(input: Input, request: Request): Promise<Response> {
  const auth = await authOnly(request);
  if ('response' in auth) return auth.response;
  if (input.action === 'account_contact') {
    const phone = (Deno.env.get('MERCHANT_SUPPORT_PHONE') ?? '').trim();
    // TODO: configure the actual support number in production; never substitute an example number.
    return json({ phone: /^\+?[0-9][0-9 -]{4,24}$/.test(phone) ? phone : '' });
  }
  let result;
  if (input.action === 'account_devices') {
    result = await admin.rpc('account_devices', { p_user: auth.user.id, p_session: auth.session,
      p_platform: typeof input.platform === 'string' ? input.platform : '' });
  } else if (input.action === 'account_device_revoke') {
    if (!uuid(input.id)) return fail('请选择要移除的设备');
    result = await admin.rpc('account_device_revoke', { p_user: auth.user.id, p_session: auth.session, p_target: input.id });
  } else if (input.action === 'account_cancel_check') {
    const state = await resolveSession(auth.user.id, auth.token, false);
    if (state instanceof Response) return state;
    if (state.role !== 'owner') return fail('仅店主可注销商户账号',403);
    result = await admin.rpc('account_cancel_check', { p_user: auth.user.id });
  } else return fail('不支持的操作');
  if (result.error || !result.data) return fail('读取或更新账号状态失败，请重试',503);
  if (result.data.error) return fail(result.data.error,result.data.status ?? 400);
  return json(result.data);
}
