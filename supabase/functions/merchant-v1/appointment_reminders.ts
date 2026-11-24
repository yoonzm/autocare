import { admin, fail, json } from './shared.ts';
import { sendStoreNotice } from './sms_notice.ts';
import { SmsError } from './sms_types.ts';

export async function handleAppointmentReminders(request: Request): Promise<Response> {
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!key || request.headers.get('authorization') !== `Bearer ${key}`) return fail('Forbidden', 403);
  const { data, error } = await admin.rpc('claim_appointment_reminders');
  if (error) return fail('提醒任务领取失败', 500);
  try {
    await Promise.all((data ?? []).map(async (job: { id: string; remind_request: string }) => {
      // Re-read after claiming so cancellation/rescheduling invalidates the old generation.
      const { data: a, error: readError } = await admin.from('appointments').select('*')
        .eq('id', job.id).eq('remind_request', job.remind_request)
        .eq('remind_state', 'sending').eq('status', 'waiting').eq('remind_enabled', true)
        .gt('starts_at', new Date().toISOString()).maybeSingle();
      if (readError) throw readError;
      if (!a) {
        const { error: skippedError } = await admin.rpc('finish_appointment_reminder', {
          p_id: job.id, p_request: job.remind_request, p_state: 'skipped',
        });
        if (skippedError) throw skippedError;
        return;
      }
      let state = 'sent';
      try {
        const dt = new Date(new Date(a.starts_at).getTime() + 8 * 3600000);
        const time = `${dt.toISOString().slice(0, 10)} ${dt.toISOString().slice(11, 16)}`;
        await sendStoreNotice({ storeId: a.store_id, phone: a.phone,
          purpose: 'appointment_reminder', requestId: job.remind_request,
          content: `温馨提醒：您预约的到店服务时间为 ${time}，请按时到店。如需改期，请联系门店。` });
      } catch (e) {
        // Cooldown is a confirmed pre-send refusal. Transport/persistence failures are ambiguous.
        state = e instanceof SmsError
          ? e.reason === 'cooldown' ? 'pending'
          : ['configuration_missing', 'phone_quota', 'global_quota', 'provider_rejected'].includes(e.reason)
          ? 'failed' : 'unknown'
          : 'unknown';
      }
      const { error: finishError } = await admin.rpc('finish_appointment_reminder', {
        p_id: job.id, p_request: job.remind_request, p_state: state,
      });
      if (finishError) throw finishError;
    }));
    return json({ ok: true, item: { count: data?.length ?? 0 } });
  } catch {
    return fail('提醒处理结果未确认，请检查任务状态', 500);
  }
}
