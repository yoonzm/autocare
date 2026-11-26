import { admin, authOnly, fail, json, resolveSession } from './shared.ts';
import { pushIosNotice, readAliyunPushConfig } from './aliyun_push.ts';
import type { Input } from './types.ts';
import { validatePushDeviceInput } from './push_rules.ts';

export async function handlePushDevice(input: Input, request: Request): Promise<Response> {
  const auth = await authOnly(request);
  if ('response' in auth) return auth.response;
  const state = await resolveSession(auth.user.id, auth.token, true);
  if (state instanceof Response) return state;

  const parsed = validatePushDeviceInput(input as Record<string, unknown>);
  if (typeof parsed === 'string') return fail(parsed);

  const fn = input.action === 'push_register' ? 'push_register' : 'push_unregister';
  const { data, error } = await admin.rpc(fn, {
    p_store: state.store,
    p_staff: state.role === 'owner' ? null : state.staffId,
    p_owner: state.role === 'owner' ? auth.user.id : null,
    p_platform: parsed.platform,
    p_token: parsed.token,
  });

  if (error) {
    if (error.code === '42501') return fail('暂无权限绑定推送设备', 403);
    if (error.message.includes('push_invalid')) return fail('推送设备参数无效');
    return fail('推送设备操作失败，请稍后重试', 500);
  }
  return json({ item: data });
}

interface OutboxItem {
  id: string;
  message_id: string;
  title: string;
  body: string;
  ios_tokens: string[];
}

export async function handlePushDispatch(request: Request): Promise<Response> {
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!key || request.headers.get('authorization') !== `Bearer ${key}`) {
    return fail('Forbidden', 403);
  }

  const config = readAliyunPushConfig((name) => Deno.env.get(name));
  if (!config) {
    return json({ ok: true, item: { claimed: 0, sent: 0, skipped: 0, failed: 0, reason: 'aliyun_push_not_configured' } });
  }

  const { data, error } = await admin.rpc('push_claim_outbox', { p_limit: 50 });
  if (error) return fail('读取推送队列失败', 500);

  const items = Array.isArray(data) ? (data as OutboxItem[]) : [];
  let sent = 0;
  let skipped = 0;
  let failed = 0;

  for (const item of items) {
    const tokens = Array.isArray(item.ios_tokens) ? item.ios_tokens.filter(Boolean) : [];
    if (!tokens.length) {
      await admin.rpc('push_mark_outbox', { p_id: item.id, p_status: 'skipped', p_error: 'no_active_ios_device' });
      skipped++;
      continue;
    }

    try {
      const result = await pushIosNotice({
        config,
        deviceTokens: tokens,
        title: item.title,
        body: item.body,
        messageId: item.message_id,
      });
      if (result.ok) {
        await admin.rpc('push_mark_outbox', { p_id: item.id, p_status: 'sent', p_error: '' });
        sent++;
      } else {
        await admin.rpc('push_mark_outbox', { p_id: item.id, p_status: 'failed', p_error: result.error ?? 'push_failed' });
        failed++;
      }
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      await admin.rpc('push_mark_outbox', { p_id: item.id, p_status: 'failed', p_error: msg });
      failed++;
    }
  }

  return json({ ok: true, item: { claimed: items.length, sent, skipped, failed } });
}
