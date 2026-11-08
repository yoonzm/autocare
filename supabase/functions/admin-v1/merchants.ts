import { executeCommand } from './commands.ts';
import { fail, json, rpcError } from './shared.ts';
import { SmsDeliveryError } from './sms.ts';
import type { Input, WriteContext } from './types.ts';

export const merchantActions = new Set([
  'merchant_extend',
  'merchant_pause',
  'merchant_freeze',
  'merchant_revoke',
  'merchant_upgrade',
  'merchant_send_code',
  'follow_save',
]);

export async function handleMerchants(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  if (action !== 'merchant_send_code') {
    return executeCommand(action, input, context);
  }
  const { me, services, command, requestId } = context;
  const { db } = services;
  const done = await command(action, { id: input.id });
  if (done.error) return rpcError(done.error);
  if (done.data.replayed) return fail('该发送请求已处理，请勿重复发送', 409);
  const { data: store, error } = await db.from('stores').select('owner_id').eq(
    'id',
    input.id,
  ).single();
  if (error || !store?.owner_id) return fail('门店没有有效店主账号');
  const { data: account, error: accountError } = await db.from('merchant_accounts').select('phone').eq('owner_id', store.owner_id).single();
  if (accountError || !account?.phone) return fail('账号没有有效登录手机号');
  try {
    const result = await services.sendLoginCode(account.phone, requestId);
    await db.from('admin_audit_logs').insert({
      actor_id: me.id,
      action: 'merchant_sms_sent',
      target: input.id,
    });
    return json(result);
  } catch (error) {
    await db.from('admin_audit_logs').insert({
      actor_id: me.id,
      action: 'merchant_sms_failed',
      target: input.id,
    });
    return error instanceof SmsDeliveryError
      ? fail(error.message, error.status)
      : fail('短信暂不可用，请稍后重试', 503);
  }
}
