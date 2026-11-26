import { fail, json, rpcError } from './shared.ts';
import type { Input, ReadContext, WriteContext } from './types.ts';

export const notificationReadActions = new Set([
  'notification_list',
  'notification_recipients',
  'notification_preview',
]);

export const notificationWriteActions = new Set([
  'notification_send',
  'notification_revoke_popup',
]);

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const validAudiences = new Set(['users', 'store', 'role', 'all']);
const validRoles = new Set(['owner', 'manager', 'cashier', 'technician']);
const validChannels = new Set(['inbox', 'push', 'sms', 'popup']);

function parseAudience(input: Input): {
  audienceType: string;
  storeId: string | null;
  role: string | null;
  targets: Array<Record<string, unknown>>;
} | string {
  const audienceType = String(input.audience_type ?? '').trim();
  if (!validAudiences.has(audienceType)) return '请选择有效的发送对象';

  const rawStore = input.store_id == null ? '' : String(input.store_id).trim();
  const storeId = rawStore || null;
  if (storeId && !uuidPattern.test(storeId)) return '门店参数无效';

  const rawRole = input.role == null ? '' : String(input.role).trim();
  const role = rawRole && rawRole !== 'all' ? rawRole : null;
  if (role && !validRoles.has(role)) return '角色参数无效';

  const rawTargets = Array.isArray(input.targets) ? input.targets : [];
  const targets: Array<Record<string, unknown>> = [];
  for (const t of rawTargets) {
    if (!t || typeof t !== 'object') return '目标用户参数无效';
    const item = t as Record<string, unknown>;
    const sid = String(item.store_id ?? '').trim();
    const staffId = item.staff_id == null ? '' : String(item.staff_id).trim();
    const ownerId = item.owner_id == null ? '' : String(item.owner_id).trim();
    if (!uuidPattern.test(sid)) return '目标用户门店无效';
    if ((staffId === '') === (ownerId === '')) return '目标用户身份无效';
    if (staffId && !uuidPattern.test(staffId)) return '目标员工无效';
    if (ownerId && !uuidPattern.test(ownerId)) return '目标老板无效';
    targets.push({
      store_id: sid,
      staff_id: staffId || null,
      owner_id: ownerId || null,
      label: typeof item.label === 'string' ? item.label.slice(0, 60) : '',
    });
  }

  if (audienceType === 'users' && targets.length === 0) return '请至少选择一位接收人';
  if (audienceType === 'store' && !storeId) return '请选择目标门店';
  if (audienceType === 'role' && !role) return '请选择目标角色';

  return { audienceType, storeId, role, targets };
}

export async function handleNotificationRead(
  action: string,
  input: Input,
  context: ReadContext,
): Promise<Response> {
  const { db } = context.services;

  if (action === 'notification_recipients') {
    const q = typeof input.q === 'string' ? input.q.trim() : '';
    if (q.length > 40) return fail('搜索关键词过长');
    const { data, error } = await db.rpc('admin_notification_recipients_search', {
      p_q: q,
      p_limit: 30,
    });
    return error ? rpcError(error) : json({ items: data ?? [] });
  }

  if (action === 'notification_preview') {
    const parsed = parseAudience(input);
    if (typeof parsed === 'string') return fail(parsed);
    const { data, error } = await db.rpc('admin_notification_preview', {
      p_audience_type: parsed.audienceType,
      p_store_id: parsed.storeId,
      p_role: parsed.role,
      p_targets: parsed.targets,
    });
    return error ? rpcError(error) : json({ item: data });
  }

  // notification_list
  const before = input.before as Record<string, unknown> | null | undefined;
  let beforeAt: string | null = null;
  let beforeId: string | null = null;
  if (before != null) {
    if (
      typeof before !== 'object' ||
      typeof before.at !== 'string' ||
      Number.isNaN(Date.parse(before.at)) ||
      typeof before.id !== 'string' ||
      !uuidPattern.test(before.id)
    ) {
      return fail('分页参数无效');
    }
    beforeAt = before.at;
    beforeId = before.id;
  }
  const { data, error } = await db.rpc('admin_notification_list', {
    p_before_at: beforeAt,
    p_before_id: beforeId,
    p_limit: 20,
  });
  return error ? rpcError(error) : json(data);
}

export async function handleNotificationWrite(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  const { db } = context.services;

  if (action === 'notification_revoke_popup') {
    const id = String(input.id ?? '').trim();
    if (!uuidPattern.test(id)) return fail('通知不存在', 404);
    const { data, error } = await db.rpc('admin_notification_revoke_popup', { p_id: id });
    if (error) return rpcError(error);
    await db.from('admin_audit_logs').insert({
      actor_id: context.me.id,
      action: 'notification_revoke_popup',
      target: id,
    });
    return json({ item: data });
  }

  // notification_send
  const title = typeof input.title === 'string' ? input.title.trim() : '';
  const body = typeof input.body === 'string' ? input.body.trim() : '';
  if (title.length < 1 || title.length > 60) return fail('通知标题需在 1~60 字之间');
  if (body.length < 1 || body.length > 500) return fail('通知内容需在 1~500 字之间');

  const parsed = parseAudience(input);
  if (typeof parsed === 'string') return fail(parsed);

  const rawChannels = Array.isArray(input.channels) ? input.channels : [];
  const channels = Array.from(
    new Set(rawChannels.map((c) => String(c).trim()).filter((c) => validChannels.has(c))),
  );
  if (channels.length === 0) return fail('请至少选择一种发送渠道');

  let popupExpiresAt: string | null = null;
  if (channels.includes('popup') && input.popup_expires_at != null && String(input.popup_expires_at).trim() !== '') {
    const exp = String(input.popup_expires_at).trim();
    if (Number.isNaN(Date.parse(exp))) return fail('弹窗截止时间无效');
    popupExpiresAt = exp;
  }

  const { data, error } = await db.rpc('admin_notification_create', {
    p_actor_id: context.me.id,
    p_actor_name: context.me.name,
    p_title: title,
    p_body: body,
    p_audience_type: parsed.audienceType,
    p_store_id: parsed.storeId,
    p_role: parsed.role,
    p_targets: parsed.targets,
    p_channels: channels,
    p_popup_expires_at: popupExpiresAt,
  });
  if (error) return rpcError(error);

  const created = data as {
    id: string;
    recipient_count: number;
    inbox_count: number;
    push_count: number;
    popup_count: number;
    sms_targets?: Array<{ phone: string; store_name?: string }>;
  };

  let smsSent = 0;
  let smsFailed = 0;
  if (channels.includes('sms') && Array.isArray(created.sms_targets) && created.sms_targets.length > 0) {
    try {
      const [{ zhutongNoticeProvider }, { sendNoticeSms }] = await Promise.all([
        import('../merchant-v1/sms_zhutong.ts'),
        import('../merchant-v1/sms.ts'),
      ]);
      const provider = zhutongNoticeProvider((name) => Deno.env.get(name));
      const noticeStore = {
        async reserve(req: {
          phone: string;
          purpose: string;
          requestId: string;
          content: string;
          sign: string;
          storeName: string;
          storeId?: string;
        }) {
          const { data: resData, error: resError } = await db.rpc('reserve_notice_sms', {
            p_phone: req.phone,
            p_purpose: req.purpose,
            p_request: req.requestId,
            p_content: req.content,
            p_sign: req.sign,
            p_store_name: req.storeName,
            p_store_id: req.storeId ?? null,
          });
          if (resError || !resData) throw new Error('Notice SMS reservation failed');
          return resData as { error?: string; retry_after?: number };
        },
        async finish(
          requestId: string,
          sent: boolean,
          providerName: string,
          failure?: string,
          providerMsgId?: string,
        ) {
          const { data: finData, error: finError } = await db.rpc('finish_notice_sms', {
            p_request: requestId,
            p_sent: sent,
            p_provider: providerName,
            p_error: failure ?? null,
            p_provider_msg_id: providerMsgId ?? null,
          });
          if (finError || finData !== true) throw new Error('Notice SMS persistence failed');
        },
      };
      const smsContent = title === body ? body : `${title}：${body}`;
      for (const target of created.sms_targets) {
        const digits = String(target.phone ?? '').replace(/\D/g, '');
        const local = digits.startsWith('86') && digits.length === 13 ? digits.slice(2) : digits;
        if (!/^1[3-9]\d{9}$/.test(local)) {
          smsFailed++;
          continue;
        }
        try {
          await sendNoticeSms(provider, noticeStore, {
            phone: `+86${local}`,
            purpose: 'admin_notice',
            content: smsContent,
            storeName: String(target.store_name ?? '').trim() || '平台通知',
            requestId: crypto.randomUUID(),
          });
          smsSent++;
        } catch {
          smsFailed++;
        }
      }
    } catch {
      smsFailed = created.sms_targets.length;
    }
    await db.rpc('admin_notification_sms_stats', {
      p_id: created.id,
      p_sent: smsSent,
      p_failed: smsFailed,
    });
  }

  await db.from('admin_audit_logs').insert({
    actor_id: context.me.id,
    action: 'notification_send',
    target: created.id,
    detail: {
      audience_type: parsed.audienceType,
      channels,
      recipient_count: created.recipient_count,
      inbox_count: created.inbox_count,
      push_count: created.push_count,
      popup_count: created.popup_count,
      sms_sent: smsSent,
      sms_failed: smsFailed,
    },
  });

  return json({
    item: {
      id: created.id,
      recipient_count: created.recipient_count,
      inbox_count: created.inbox_count,
      push_count: created.push_count,
      popup_count: created.popup_count,
      sms_sent: smsSent,
      sms_failed: smsFailed,
    },
  });
}
