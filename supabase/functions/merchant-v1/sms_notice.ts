import { admin } from './shared.ts';
import { sendNoticeSms, smsNoticeProvider, type NoticeSendStore } from './sms.ts';

export const noticeStore: NoticeSendStore = {
  async reserve({ phone, purpose, requestId, content, sign, storeName }) {
    const { data, error } = await admin.rpc('reserve_notice_sms', {
      p_phone: phone,
      p_purpose: purpose,
      p_request: requestId,
      p_content: content,
      p_sign: sign,
      p_store_name: storeName,
    });
    if (error || !data) throw new Error('Notice SMS reservation failed');
    return data;
  },
  async finish(requestId, sent, provider, failure) {
    const { data, error } = await admin.rpc('finish_notice_sms', {
      p_request: requestId,
      p_sent: sent,
      p_provider: provider,
      p_error: failure ?? null,
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
