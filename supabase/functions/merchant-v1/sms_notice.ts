import { SmsError } from './sms_types.ts';
import { admin } from './shared.ts';
import { sendNoticeSms, smsNoticeProvider, type NoticeSendStore } from './sms.ts';

export const noticeStore: NoticeSendStore = {
  async reserve({ phone, purpose, requestId, content, sign, storeName, storeId }) {
    const { data, error } = await admin.rpc('reserve_notice_sms', {
      p_phone: phone,
      p_purpose: purpose,
      p_request: requestId,
      p_content: content,
      p_sign: sign,
      p_store_name: storeName,
      p_store_id: storeId ?? null,
    });
    if (error || !data) throw new Error('Notice SMS reservation failed');
    return data;
  },
  async finish(requestId, sent, provider, failure, providerMsgId) {
    const { data, error } = await admin.rpc('finish_notice_sms', {
      p_request: requestId,
      p_sent: sent,
      p_provider: provider,
      p_error: failure ?? null,
      p_provider_msg_id: providerMsgId ?? null,
    });
    if (error || data !== true) throw new Error('Notice SMS persistence failed');
  },
};

export function normalizeCnPhone(raw: unknown): string | null {
  if (typeof raw !== 'string') return null;
  const digits = raw.replace(/\D/g, '');
  const local = digits.startsWith('86') && digits.length === 13 ? digits.slice(2) : digits;
  return /^1[3-9]\d{9}$/.test(local) ? `+86${local}` : null;
}

export async function sendStoreNotice(args: {
  storeId: string;
  phone: unknown;
  purpose: string;
  content: string;
  storeName?: string;
  requestId?: string | null;
}): Promise<{ ok: true }> {
  const phone = normalizeCnPhone(args.phone);
  if (!phone) throw new Error('invalid_phone');
  let storeName = args.storeName?.trim() ?? '';
  if (!storeName) {
    const { data } = await admin.from('stores').select('name').eq('id', args.storeId).maybeSingle();
    storeName = String(data?.name ?? '门店').trim() || '门店';
  }
  const provider = smsNoticeProvider((name) => Deno.env.get(name));
  const requestId = args.requestId && /^[0-9a-f-]{36}$/i.test(args.requestId)
    ? args.requestId
    : crypto.randomUUID();
  return await sendNoticeSms(provider, noticeStore, {
    phone,
    purpose: args.purpose,
    content: args.content,
    storeName,
    requestId,
    storeId: args.storeId,
  });
}

export async function recordAppointmentNotice(args: {
  storeId: string;
  appointmentId: string;
  kind: 'confirm' | 'reschedule' | 'remind' | 'cancel';
  channel?: 'sms' | 'wechat';
  status: 'pending' | 'sent' | 'failed' | 'skipped';
  recipient?: string;
  error?: string;
  sentAt?: string | null;
}): Promise<void> {
  try {
    await admin.from('appointment_notices').insert({
      store_id: args.storeId,
      appointment_id: args.appointmentId,
      kind: args.kind,
      channel: args.channel ?? 'sms',
      status: args.status,
      recipient: args.recipient ?? '',
      error: args.error ?? '',
      sent_at: args.sentAt ?? (args.status === 'sent' ? new Date().toISOString() : null),
    });
  } catch {
    // 通知记录写入失败不阻塞主流程或覆盖短信已发送状态。
  }
}

export type TxSmsResult = {
  sms_status: 'sent' | 'failed' | 'skipped';
  sms_phone_masked?: string;
  sms_error?: string;
};

function maskCnPhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  const local = digits.startsWith('86') && digits.length === 13 ? digits.slice(2) : digits;
  return local.length === 11 ? `${local.slice(0, 3)}****${local.slice(7)}` : local;
}

async function deterministicNoticeUuid(parts: string[]): Promise<string> {
  const bytes = new Uint8Array(
    await crypto.subtle.digest('SHA-256', new TextEncoder().encode(JSON.stringify(parts))),
  );
  bytes[6] = (bytes[6] & 15) | 80;
  bytes[8] = (bytes[8] & 63) | 128;
  const hex = [...bytes.slice(0, 16)].map((x) => x.toString(16).padStart(2, '0')).join('');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

/**
 * 消费/充值/购卡完成后的非阻塞短信通知：
 * 即使开关关闭、未登记手机号或渠道失败，也不回滚已完成的主账务。
 */
export async function sendTransactionNotice(args: {
  storeId: string;
  memberId?: string | null;
  settingKey: 'notify_consume' | 'notify_recharge';
  purpose: 'order_consume' | 'member_recharge' | 'package_buy';
  buildContent: (storeName: string) => string;
  requestId?: string | null;
}): Promise<TxSmsResult> {
  try {
    const [settingsRes, storeRes, memberRes] = await Promise.all([
      admin.from('store_notify_settings')
        .select('notify_consume, notify_recharge')
        .eq('store_id', args.storeId)
        .maybeSingle(),
      admin.from('stores')
        .select('name')
        .eq('id', args.storeId)
        .maybeSingle(),
      args.memberId
        ? admin.from('members').select('phone').eq('id', args.memberId).eq('store_id', args.storeId).maybeSingle()
        : Promise.resolve({ data: null }),
    ]);

    const enabled = settingsRes.data == null
      ? true
      : settingsRes.data[args.settingKey] !== false;
    if (!enabled) {
      return {
        sms_status: 'skipped',
        sms_error: args.settingKey === 'notify_consume'
          ? '门店已关闭消费短信通知'
          : '门店已关闭充值/购卡短信通知',
      };
    }

    const rawPhone = memberRes.data?.phone;
    const normalized = normalizeCnPhone(rawPhone);
    if (!normalized) {
      return {
        sms_status: 'skipped',
        sms_error: args.memberId ? '会员未登记有效手机号，未发送短信' : '散客未登记手机号，未发送短信',
      };
    }

    const storeName = String(storeRes.data?.name ?? '门店').trim() || '门店';
    const masked = maskCnPhone(normalized);
    const noticeReqId = args.requestId
      ? await deterministicNoticeUuid(['tx-sms', args.storeId, args.purpose, args.requestId])
      : crypto.randomUUID();

    try {
      await sendStoreNotice({
        storeId: args.storeId,
        phone: normalized,
        purpose: args.purpose,
        content: args.buildContent(storeName),
        storeName,
        requestId: noticeReqId,
      });
      return { sms_status: 'sent', sms_phone_masked: masked };
    } catch (err) {
      return {
        sms_status: 'failed',
        sms_phone_masked: masked,
        sms_error: err instanceof SmsError ? err.message : '短信发送失败',
      };
    }
  } catch {
    return { sms_status: 'failed', sms_error: '短信通知处理失败' };
  }
}
