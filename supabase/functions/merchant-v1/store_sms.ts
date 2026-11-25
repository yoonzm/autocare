import { admin, fail, json, storeFor } from './shared.ts';
import type { Input } from './types.ts';

const purposeLabels: Record<string, string> = {
  appointment_confirm: '预约成功通知',
  appointment_reschedule: '预约改期通知',
  appointment_cancel: '预约取消通知',
  appointment_reminder: '预约到店提醒',
  appointment_manager_created: '新增预约通知店长',
  appointment_manager_rescheduled: '预约改期通知店长',
  appointment_manager_cancelled: '预约取消通知店长',
  hold_pickup: '完工取车通知',
  staff_invite: '员工短信邀请',
  order_consume: '消费结账通知',
  member_recharge: '储值充值通知',
  package_buy: '购买次卡通知',
  member_visit: '会员回访通知',
  member_reminder: '会员提醒通知',
  member_followup: '会员跟进通知',
};

function purposeLabel(purpose: string): string {
  if (Object.hasOwn(purposeLabels, purpose)) return purposeLabels[purpose];
  if (purpose.startsWith('member_')) return '会员跟进通知';
  if (purpose.startsWith('appointment_manager_')) return '预约变动通知店长';
  return '门店通知短信';
}

function maskPhone(raw: string): string {
  const digits = raw.replace(/\D/g, '');
  const local = digits.startsWith('86') && digits.length === 13 ? digits.slice(2) : digits;
  if (local.length === 11) {
    return `${local.slice(0, 3)}****${local.slice(7)}`;
  }
  return local || '未知号码';
}

function monthStartUtcIso(): string {
  // 北京时间当月 1 日 00:00:00 对应的 UTC 时间
  const cnNow = new Date(Date.now() + 8 * 3600 * 1000);
  const year = cnNow.getUTCFullYear();
  const month = cnNow.getUTCMonth();
  const cnStartUtcMs = Date.UTC(year, month, 1, 0, 0, 0) - 8 * 3600 * 1000;
  return new Date(cnStartUtcMs).toISOString();
}

export async function handleStoreSms(input: Input, request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;

  if (input.action === 'store_sms_overview') {
    const monthStart = monthStartUtcIso();
    const [logsRes, settingsRes, storeRes] = await Promise.all([
      admin
        .from('sms_logs')
        .select('status, delivery_status')
        .eq('store_id', storeId)
        .eq('kind', 'notice')
        .gte('created_at', monthStart),
      admin
        .from('appointment_settings')
        .select('*')
        .eq('store_id', storeId)
        .maybeSingle(),
      admin
        .from('stores')
        .select('name')
        .eq('id', storeId)
        .maybeSingle(),
    ]);

    if (logsRes.error) return fail('读取短信统计失败，请重试', 500);
    if (settingsRes.error) return fail('读取通知设置失败，请重试', 500);

    const rows = logsRes.data ?? [];
    let delivered = 0;
    let failed = 0;
    let pending = 0;
    for (const row of rows) {
      if (row.status === 'failed' || row.delivery_status === 'failed') {
        failed++;
      } else if (row.delivery_status === 'delivered') {
        delivered++;
      } else {
        pending++;
      }
    }

    const providerConfigured = Boolean(Deno.env.get('SMS_PROVIDER')?.trim());
    const signName = Deno.env.get('ZHUTONG_SIGN_NAME')?.trim() || '';
    const storeName = String(storeRes.data?.name ?? '当前门店').trim() || '当前门店';
    const bs = settingsRes.data ?? {
      notify_customer: true,
      notify_reschedule: true,
      notify_cancel: true,
      notify_remind: true,
      remind_minutes: 60,
      notify_manager: true,
      notify_consume: true,
      notify_recharge: true,
    };

    return json({
      item: {
        store_name: storeName,
        provider: {
          name: 'zhutong',
          label: '助通短信',
          configured: providerConfigured,
          signature: signName,
        },
        month_stats: {
          total: rows.length,
          delivered,
          failed,
          pending,
        },
        booking_settings: bs,
        scenarios: [
          {
            key: 'order_consume',
            group: 'transaction',
            title: '消费结账通知客户',
            setting_key: 'notify_consume',
            enabled: bs.notify_consume !== false,
            template_preview: `您在${storeName}本次消费 ¥{金额}（{支付方式}）已完成，当前余额 ¥{余额}。感谢光临！`,
          },
          {
            key: 'member_recharge',
            group: 'transaction',
            title: '储值充值与购卡通知',
            setting_key: 'notify_recharge',
            enabled: bs.notify_recharge !== false,
            template_preview: `您在${storeName}充值 ¥{金额}（赠送 ¥{赠送}）已到账，当前余额 ¥{余额}；购买次卡时提示套餐已开通。`,
          },
          {
            key: 'appointment_confirm',
            group: 'booking',
            title: '预约成功通知客户',
            setting_key: 'notify_customer',
            enabled: Boolean(bs.notify_customer),
            template_preview: `您在${storeName}预约了{时间}到店服务，如需改期请提前联系门店。`,
          },
          {
            key: 'appointment_reschedule',
            group: 'booking',
            title: '预约改期通知客户',
            setting_key: 'notify_reschedule',
            enabled: Boolean(bs.notify_reschedule),
            template_preview: `您在${storeName}的预约已改期至{时间}，请按时到店。`,
          },
          {
            key: 'appointment_cancel',
            group: 'booking',
            title: '预约取消通知客户',
            setting_key: 'notify_cancel',
            enabled: Boolean(bs.notify_cancel),
            template_preview: `您预约的{时间}到店服务已取消，如需重新预约请联系${storeName}。`,
          },
          {
            key: 'appointment_reminder',
            group: 'booking',
            title: `到店前提醒（提前 ${Number(bs.remind_minutes ?? 60)} 分钟）`,
            setting_key: 'notify_remind',
            enabled: Boolean(bs.notify_remind),
            template_preview: '温馨提醒：您预约的到店服务时间为{时间}，请按时到店。如需改期，请联系门店。',
          },
          {
            key: 'appointment_manager',
            group: 'booking',
            title: '预约变动通知店长',
            setting_key: 'notify_manager',
            enabled: Boolean(bs.notify_manager),
            template_preview: `${storeName}：{新增/改期/取消}预约，客户{姓名}，预约时间{时间}。请在商户 App 查看详情。`,
          },
          {
            key: 'hold_pickup',
            group: 'business',
            title: '完工取车通知',
            trigger_hint: '在待取车/挂单页点击发送',
            template_preview: `您的爱车{车牌}在${storeName}已施工完成，请方便时到店取车。`,
          },
          {
            key: 'staff_invite',
            group: 'business',
            title: '员工短信邀请',
            trigger_hint: '在员工邀请页发送登录邀请',
            template_preview: `${storeName}邀请您加入团队（{角色}），请下载并打开“我的汽美管家”App，使用本手机号验证码登录即可激活。`,
          },
          {
            key: 'member_followup',
            group: 'business',
            title: '会员回访与跟进通知',
            trigger_hint: '在会员回访/提醒页点击发送',
            template_preview: '由门店跟进/回访动作触发，发送对应关怀与到店提醒短信。',
          },
          {
            key: 'auth_otp',
            group: 'otp',
            title: '账号安全与次卡核销验证码',
            trigger_hint: '注册、登录、找回密码、换号、注销、次卡核销（平台固定模板）',
            template_preview: '验证码 {6位数字}，5 分钟内有效，请勿泄露给他人。',
          },
        ],
      },
    });
  }

  if (input.action === 'store_sms_logs') {
    const statusFilter = typeof input.status === 'string' ? input.status : 'all';
    const rawLimit = typeof input.limit === 'number' ? input.limit : 20;
    const limit = Math.min(50, Math.max(1, Math.trunc(rawLimit)));
    const offset = typeof input.offset === 'number' && input.offset >= 0 ? Math.trunc(input.offset) : 0;

    let query = admin
      .from('sms_logs')
      .select('id, phone, purpose, content, status, delivery_status, delivery_code, error, created_at, sent_at, delivered_at')
      .eq('store_id', storeId)
      .eq('kind', 'notice')
      .order('created_at', { ascending: false })
      .order('id', { ascending: false })
      .range(offset, offset + limit);

    if (statusFilter === 'failed') {
      query = query.or('status.eq.failed,delivery_status.eq.failed');
    } else if (statusFilter === 'delivered') {
      query = query.eq('delivery_status', 'delivered');
    }

    const { data, error } = await query;
    if (error) return fail('读取短信记录失败，请重试', 500);

    const rows = data ?? [];
    const hasMore = rows.length > limit;
    const items = rows.slice(0, limit).map((row) => ({
      id: row.id,
      phone_masked: maskPhone(String(row.phone ?? '')),
      purpose: row.purpose,
      purpose_label: purposeLabel(String(row.purpose ?? '')),
      content: row.content,
      status: row.status,
      delivery_status: row.delivery_status,
      delivery_code: row.delivery_code,
      error: row.error,
      created_at: row.created_at,
      sent_at: row.sent_at,
      delivered_at: row.delivered_at,
    }));

    return json({
      item: {
        items,
        has_more: hasMore,
        next_offset: offset + items.length,
      },
    });
  }

  return fail('不支持的操作');
}
