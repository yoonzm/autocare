import { notifyAppointmentManagers, type ManagerNoticeDependencies } from './appointment_manager_notice.ts';
import { admin, fail, json, storeFor, uuid } from './shared.ts';
import { operatorOf } from './members.ts';
import { hasCap, technicianScope } from './staff_access.ts';
import { parseBooking, parseBookingSettings, parseResource, validDay } from './appointment_rules.ts';
import { parseOrderTechnicians } from './ops_rules.ts';
import { SmsError } from './sms.ts';
import { normalizeCnPhone, recordAppointmentNotice, sendStoreNotice, sendTransactionNotice } from './sms_notice.ts';
import type { Input } from './types.ts';

const managerNoticeDeps: ManagerNoticeDependencies = {
  async load(storeId) {
    const settings = await admin.from('appointment_settings').select('notify_manager').eq('store_id', storeId).maybeSingle();
    if (settings.error) throw settings.error;
    if (!settings.data?.notify_manager) return { enabled: false, name: '', phones: [] };
    const [staff, store] = await Promise.all([
      admin.from('store_staff').select('phone').eq('store_id', storeId).eq('role', 'manager').eq('status', 'active'),
      admin.from('stores').select('name').eq('id', storeId).single(),
    ]);
    if (staff.error || store.error) throw staff.error || store.error;
    return { enabled: true, name: String(store.data.name), phones: (staff.data ?? []).map((s) => s.phone) };
  },
  async previous(requestId) {
    const { data, error } = await admin.from('sms_logs').select('status').eq('request_id', requestId).maybeSingle();
    if (error) throw error;
    return data?.status ?? null;
  },
  send: sendStoreNotice,
};

const rpcError = (e: { message: string; code?: string }) => {
  const messages: Record<string, string> = {
    slot_unavailable: '该时段、工位或技师已不可预约，请重新选择',
    appointment_closed: '预约状态已变化，请刷新后重试',
    reminder_phone_required: '客户手机号无效，无法开启到店提醒',
    appointment_manager_required: '请先在员工管理中配置已启用的店长，再开启店长通知',
    appointment_not_arrived: '请先标记客户到店',
    arrival_too_early: '不能提前标记未来日期的预约到店',
    capacity_conflict: '已有预约超过新的接待上限，请先调整预约',
    resource_busy: '该工位或技师还有未完成预约，暂不能停用',
    resource_assignment_conflict: '该技师有固定工位，请选择对应工位',
    resource_limit: '已达到工位或技师数量上限',
    resource_kind_invalid: '资源类型不能更改',
    cancel_reason_required: '请选择取消原因',
    request_reused: '请求标识已用于其他订单，请重新提交',
    service_not_found: '服务项目不存在或已下架',
    member_not_found: '会员不存在',
    appointment_not_found: '预约不存在',
    resource_not_found: '工位或技师不存在',
    order_technician_unavailable: '所选技师不可用，请重新选择',
  };
  const key = Object.keys(messages).find((k) => e.message.includes(k));
  if (key) return fail(messages[key], 400);
  if (e.code === '23505') return fail('名称或手机号已存在，请检查后重试', 409);
  if (e.message.includes('balance')) return fail('储值余额不足');
  if (e.message.includes('package')) return fail('次卡不可用或次数不足');
  if (e.code === '23514' || e.code === '22P02') return fail('输入参数无效');
  return fail('预约操作失败，请稍后重试', 500);
};

export async function handleAppointments(input: Input, request: Request): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  const action = String(input.action);
  const settings = async () => {
    const { error } = await admin.from('appointment_settings').upsert({ store_id: store }, {
      onConflict: 'store_id',
      ignoreDuplicates: true,
    });
    if (error) throw error;
    const result = await admin.from('appointment_settings').select('*').eq('store_id', store).single();
    if (result.error) throw result.error;
    return result.data;
  };
  try {
    if (action === 'appointment_options') {
      const [s, services, resources, canEditAppt] = await Promise.all([
        settings(),
        admin.from('service_items').select('*').eq('store_id', store).eq('active', true).order('created_at'),
        admin.rpc('appointment_resource_list', { p_store: store }),
        hasCap(request, 'appt_edit'),
      ]);
      if (services.error || resources.error) return fail('读取预约选项失败', 500);
      const list = Array.isArray(resources.data) ? resources.data : [];
      const sanitized = canEditAppt
        ? list
        : list.map((r: Record<string, unknown>) => {
            const { phone: _phone, ...rest } = r;
            return rest;
          });
      return json({ item: { settings: s, services: services.data, resources: sanitized } });
    }
    if (action === 'appointment_board') {
      if (!validDay(input.day)) return fail('日期无效');
      const { data, error } = await admin.rpc('appointment_board', { p_store: store, p_day: input.day });
      if (error) return rpcError(error);
      // 数据范围：技师只看与自己任务相关的预约
      const scope = await technicianScope(request);
      if (scope !== null) {
        return json({ item: { ...data, items: (data?.items ?? []).filter((a: { technician_id?: string }) => a.technician_id === scope) } });
      }
      return json({ item: data });
    }
    if (action === 'appointment_summary') {
      const today = new Date(Date.now() + 8 * 3600000).toISOString().slice(0, 10);
      const { data, error } = await admin.rpc('appointment_board', { p_store: store, p_day: today });
      if (error) return rpcError(error);
      const scope = await technicianScope(request);
      const rows = (data?.items ?? []).filter((a: { starts_at: string; status: string; technician_id?: string }) =>
        (scope === null || a.technician_id === scope) &&
        new Date(new Date(a.starts_at).getTime() + 8 * 3600000).toISOString().startsWith(today) &&
        ['waiting', 'late'].includes(a.status)
      );
      return json({ item: { count: rows.length, next: rows[0] ?? null } });
    }
    if (action === 'appointment_get') {
      if (!uuid(input.id)) return fail('预约 ID 无效');
      const { data, error } = await admin.rpc('appointment_detail', { p_store: store, p_id: input.id });
      if (error) return rpcError(error);
      const scope = await technicianScope(request);
      if (data && scope !== null && data.technician_id !== scope) return fail('预约不存在', 404);
      return data ? json({ item: data }) : fail('预约不存在', 404);
    }
    if (action === 'appointment_slots') {
      if (
        !validDay(input.day) || !Array.isArray(input.service_ids) || input.service_ids.length < 1 ||
        input.service_ids.length > 20 || !input.service_ids.every(uuid)
      ) return fail('请选择日期和服务项目');
      for (const k of ['exclude', 'bay_id', 'technician_id']) {
        if (input[k] != null && !uuid(input[k])) return fail('资源 ID 无效');
      }
      await settings();
      const { data, error } = await admin.rpc('appointment_slots', {
        p_store: store,
        p_day: input.day,
        p_services: input.service_ids,
        p_exclude: input.exclude ?? null,
        p_bay: input.bay_id ?? null,
        p_tech: input.technician_id ?? null,
      });
      return error ? rpcError(error) : json({ item: data });
    }
    if (action === 'appointment_save') {
      const value = parseBooking(input);
      if (typeof value === 'string') return fail(value);
      const { data, error } = await admin.rpc('save_merchant_appointment', {
        p_store: store,
        p_input: value,
        p_request: request.headers.get('x-request-id'),
      });
      if (error) return rpcError(error);
      let sms_sent = false;
      let sms_error = '';
      const isEdit = input.id != null;
      const shouldNotify = (isEdit ? input.notify === true : data?.notify_confirm === true) && !!data;
      if (shouldNotify && normalizeCnPhone(data.phone)) {
        const dt = new Date(new Date(String(data.starts_at)).getTime() + 8 * 3600000);
        const timeStr = `${dt.toISOString().slice(0, 10)} ${dt.toISOString().slice(11, 16)}`;
        const items = Array.isArray(data.items) ? (data.items as { name?: string }[]).map((x) => x.name).filter(Boolean).join('、') : '';
        const { data: storeRow } = await admin.from('stores').select('name').eq('id', store).maybeSingle();
        const storeName = String(storeRow?.name ?? '门店').trim() || '门店';
        const content = isEdit
          ? `您的预约时间已调整为 ${timeStr}，如有疑问请联系${storeName}。`
          : `您已成功预约 ${timeStr} 到店${items ? `（${items}）` : ''}，如需改期请提前联系${storeName}。`;
        try {
          await sendStoreNotice({
            storeId: store,
            phone: data.phone,
            purpose: isEdit ? 'appointment_reschedule' : 'appointment_confirm',
            content,
            storeName,
            requestId: request.headers.get('x-request-id'),
          });
          sms_sent = true;
          await recordAppointmentNotice({
            storeId: store,
            appointmentId: String(data.id),
            kind: isEdit ? 'reschedule' : 'confirm',
            status: 'sent',
            recipient: String(data.phone ?? ''),
          });
        } catch (err) {
          sms_error = err instanceof SmsError ? err.message : '短信发送失败';
          await recordAppointmentNotice({
            storeId: store,
            appointmentId: String(data.id),
            kind: isEdit ? 'reschedule' : 'confirm',
            status: 'failed',
            recipient: String(data.phone ?? ''),
            error: sms_error,
          });
        }
      } else if (shouldNotify) {
        await recordAppointmentNotice({
          storeId: store,
          appointmentId: String(data.id),
          kind: isEdit ? 'reschedule' : 'confirm',
          status: 'skipped',
          recipient: String(data.phone ?? ''),
          error: '客户未登记有效手机号',
        });
      }
      const managerNotice = await notifyAppointmentManagers({ storeId: store, appointment: data,
        event: input.id == null ? 'created' : 'rescheduled',
        version: input.id == null ? String(data.id) : request.headers.get('x-request-id') ?? String(data.updated_at),
      }, managerNoticeDeps);
      return json({ item: { ...data, sms_sent, ...(sms_error ? { sms_error } : {}), ...managerNotice } });
    }
    if (action === 'appointment_arrive' || action === 'appointment_cancel') {
      if (!uuid(input.id)) return fail('预约 ID 无效');
      const { data, error } = await admin.rpc('change_appointment', {
        p_store: store,
        p_id: input.id,
        p_action: action === 'appointment_arrive' ? 'arrive' : 'cancel',
        p_reason: String(input.reason ?? '').trim(),
      });
      if (error) return rpcError(error);
      let sms_sent = false;
      let sms_error = '';
      if (action === 'appointment_cancel' && input.notify === true && data && normalizeCnPhone(data.phone)) {
        const dt = new Date(new Date(String(data.starts_at)).getTime() + 8 * 3600000);
        const timeStr = `${dt.toISOString().slice(0, 10)} ${dt.toISOString().slice(11, 16)}`;
        const { data: storeRow } = await admin.from('stores').select('name').eq('id', store).maybeSingle();
        const storeName = String(storeRow?.name ?? '门店').trim() || '门店';
        try {
          await sendStoreNotice({
            storeId: store,
            phone: data.phone,
            purpose: 'appointment_cancel',
            content: `您预约的 ${timeStr} 到店服务已取消，如需重新预约请联系${storeName}。`,
            storeName,
            requestId: request.headers.get('x-request-id'),
          });
          sms_sent = true;
          await recordAppointmentNotice({
            storeId: store,
            appointmentId: String(data.id),
            kind: 'cancel',
            status: 'sent',
            recipient: String(data.phone ?? ''),
          });
        } catch (err) {
          sms_error = err instanceof SmsError ? err.message : '短信发送失败';
          await recordAppointmentNotice({
            storeId: store,
            appointmentId: String(data.id),
            kind: 'cancel',
            status: 'failed',
            recipient: String(data.phone ?? ''),
            error: sms_error,
          });
        }
      } else if (action === 'appointment_cancel' && input.notify === true && data) {
        await recordAppointmentNotice({
          storeId: store,
          appointmentId: String(data.id),
          kind: 'cancel',
          status: 'skipped',
          recipient: String(data.phone ?? ''),
          error: '客户未登记有效手机号',
        });
      }
      const managerNotice = action === 'appointment_cancel'
        ? await notifyAppointmentManagers({ storeId: store, appointment: data, event: 'cancelled',
          version: String(data.cancelled_at),
        }, managerNoticeDeps) : {};
      return json({ item: { ...data, sms_sent, ...(sms_error ? { sms_error } : {}), ...managerNotice } });
    }
    if (action === 'appointment_settings_save') {
      const value = parseBookingSettings(input);
      if (typeof value === 'string') return fail(value);
      const { data, error } = await admin.rpc('save_appointment_settings', {
        p_store: store,
        p_input: value,
      });
      return error ? rpcError(error) : json({ item: data });
    }
    if (action === 'appointment_resource_save') {
      const value = parseResource(input);
      if (typeof value === 'string') return fail(value);
      // 技师统一经员工管理（staff_save）维护，保证员工与排班资源同步。
      if (value.kind === 'technician') return fail('请在“员工与权限”中维护技师');
      const { data, error } = await admin.rpc('save_appointment_resource', {
        p_store: store,
        p_input: value,
      });
      return error ? rpcError(error) : json({ item: data });
    }
    if (action === 'appointment_checkout') {
      if (
        !uuid(input.id) || !Array.isArray(input.lines) || input.lines.length < 1 || input.lines.length > 50 ||
        !input.lines.every((l) =>
          l && uuid(l.service_id) && Number.isInteger(l.qty) && l.qty >= 1 && l.qty <= 99 &&
          (l.member_package_id == null || uuid(l.member_package_id))
        )
      ) return fail('订单项目无效');
      if (!['微信', '支付宝', '现金', '会员余额'].includes(String(input.method))) {
        return fail('收款方式无效');
      }
      const technicians = parseOrderTechnicians(input.technician_ids);
      if (typeof technicians === 'string') return fail(technicians);
      const reqId = request.headers.get('x-request-id');
      const { data, error } = await admin.rpc('checkout_with_technicians', {
        p_store: store,
        p_appointment: input.id,
        p_hold: null,
        p_member: null,
        p_lines: input.lines,
        p_method: input.method,
        p_balance_part: null,
        p_other: null,
        p_plate: String(input.plate ?? '').slice(0, 10),
        p_remark: '',
        p_operator: await operatorOf(store),
        p_request: reqId,
        p_technician_ids: technicians,
      });
      if (error) return rpcError(error);
      const row = (data ?? {}) as Record<string, unknown>;
      const { data: apptRow } = await admin
        .from('appointments')
        .select('member_id')
        .eq('id', input.id)
        .eq('store_id', store)
        .maybeSingle();
      const memberId = typeof row.member_id === 'string'
        ? row.member_id
        : typeof apptRow?.member_id === 'string'
        ? apptRow.member_id
        : null;
      const payable = Number(row.payable ?? 0).toFixed(2);
      const method = String(row.pay_method ?? input.method ?? '');
      const balText = row.balance != null ? `，当前余额 ¥${Number(row.balance).toFixed(2)}` : '';
      const sms = await sendTransactionNotice({
        storeId: store,
        memberId,
        settingKey: 'notify_consume',
        purpose: 'order_consume',
        requestId: reqId,
        buildContent: (storeName) => `您在${storeName}本次消费 ¥${payable}（${method}）已完成${balText}。感谢光临！`,
      });
      return json({ item: { ...row, ...sms } });
    }
    return fail('不支持的预约操作');
  } catch (e) {
    return rpcError(e as { message: string; code?: string });
  }
}
