/** Notification orchestration is injectable so tests never contact SMS or the database. */
export type ManagerNoticeDependencies = {
  load(storeId: string): Promise<{ enabled: boolean; name: string; phones: string[] }>;
  previous(requestId: string): Promise<string | null>;
  send(args: { storeId: string; phone: string; purpose: string; content: string; storeName: string; requestId: string }): Promise<unknown>;
};

export async function managerNoticeId(store: string, appointment: string, event: string, version: string, phone: string): Promise<string> {
  const bytes = new Uint8Array(await crypto.subtle.digest('SHA-256',
    new TextEncoder().encode(JSON.stringify(['appointment-manager', store, appointment, event, version, phone]))));
  // Deterministic UUID-shaped request ID, independent from the customer's SMS ID.
  bytes[6] = (bytes[6] & 15) | 80;
  bytes[8] = (bytes[8] & 63) | 128;
  const hex = [...bytes.slice(0, 16)].map((x) => x.toString(16).padStart(2, '0')).join('');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

export async function notifyAppointmentManagers(args: {
  storeId: string; appointment: { id: string; starts_at: string; customer_name?: string };
  event: 'created' | 'rescheduled' | 'cancelled'; version: string;
}, deps: ManagerNoticeDependencies): Promise<{ manager_sms_sent: number; manager_sms_error?: string }> {
  try {
    const config = await deps.load(args.storeId);
    if (!config.enabled) return { manager_sms_sent: 0 };
    const phones = [...new Set(config.phones)];
    if (phones.length === 0) return { manager_sms_sent: 0, manager_sms_error: '本店暂无已启用的店长，未发送店长短信' };
    const dt = new Date(new Date(args.appointment.starts_at).getTime() + 8 * 3600000);
    const time = `${dt.toISOString().slice(0, 10)} ${dt.toISOString().slice(11, 16)}`;
    const event = { created: '新增预约', rescheduled: '预约改期', cancelled: '预约取消' }[args.event];
    const content = `${config.name}：${event}，客户${(args.appointment.customer_name || '客户').slice(0, 30)}，预约时间 ${time}。请在商户 App 查看详情。`;
    const results = await Promise.all(phones.map(async (phone) => {
      const requestId = await managerNoticeId(args.storeId, args.appointment.id, args.event, args.version, phone);
      try {
        const previous = await deps.previous(requestId);
        if (previous != null) return previous === 'sent';
        await deps.send({ storeId: args.storeId, phone, purpose: `appointment_manager_${args.event}`,
          content, storeName: config.name, requestId });
        return true;
      } catch { return false; }
    }));
    const sent = results.filter(Boolean).length;
    return { manager_sms_sent: sent, ...(sent < phones.length
      ? { manager_sms_error: `${phones.length - sent} 位店长的短信未确认发送，请查看短信记录` } : {}) };
  } catch {
    return { manager_sms_sent: 0, manager_sms_error: '店长通知处理失败，请查看短信记录' };
  }
}
