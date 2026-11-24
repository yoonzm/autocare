import { managerNoticeId, notifyAppointmentManagers, type ManagerNoticeDependencies } from './appointment_manager_notice.ts';
const assert = (ok: boolean) => { if (!ok) throw new Error('assertion failed'); };
const args = { storeId: 'store-1', appointment: { id: 'appt-1', starts_at: '2026-11-26T03:00:00Z', customer_name: '张先生' }, event: 'created' as const, version: 'v1' };
function fixture() {
  const sent: Parameters<ManagerNoticeDependencies['send']>[0][] = [];
  const logs = new Map<string, string>();
  const deps: ManagerNoticeDependencies = {
    load: async () => ({ enabled: true, name: '测试门店', phones: ['13900001111', '13900002222', '13900001111'] }),
    previous: async (id) => logs.get(id) ?? null,
    send: async (a) => { sent.push(a); logs.set(a.requestId, 'sent'); },
  };
  return { deps, sent, logs };
}
Deno.test('manager notices deduplicate recipients and retries, use Shanghai time', async () => {
  const { deps, sent } = fixture();
  const result = await notifyAppointmentManagers(args, deps);
  assert(result.manager_sms_sent === 2 && !result.manager_sms_error);
  assert(sent.length === 2 && sent[0].content.includes('2026-11-26 11:00'));
  await notifyAppointmentManagers(args, deps);
  assert(sent.length === 2);
  await notifyAppointmentManagers({ ...args, event: 'rescheduled', version: 'v2' }, deps);
  assert(Number(sent.length) === 4);
  await notifyAppointmentManagers({ ...args, event: 'cancelled', version: 'v3' }, deps);
  assert(Number(sent.length) === 6);
});
Deno.test('disabled and empty manager lists never send; failures do not fail booking', async () => {
  const { deps, sent } = fixture();
  deps.load = async () => ({ enabled: false, name: '', phones: ['13900001111'] });
  assert((await notifyAppointmentManagers(args, deps)).manager_sms_sent === 0);
  assert(sent.length === 0);
  deps.load = async () => ({ enabled: true, name: '', phones: [] });
  assert(!!(await notifyAppointmentManagers(args, deps)).manager_sms_error);
  deps.load = async () => { throw new Error('DB failure'); };
  assert(!!(await notifyAppointmentManagers(args, deps)).manager_sms_error);
});
Deno.test('unknown and failed prior sends are not resent; partial failures are reported', async () => {
  const { deps, logs, sent } = fixture();
  logs.set(await managerNoticeId('store-1', 'appt-1', 'created', 'v1', '13900001111'), 'pending');
  const result = await notifyAppointmentManagers(args, deps);
  assert(result.manager_sms_sent === 1 && !!result.manager_sms_error && sent.length === 1);
  const { deps: failing } = fixture();
  failing.send = async () => { throw new Error('channel failed'); };
  assert((await notifyAppointmentManagers(args, failing)).manager_sms_sent === 0);
});
Deno.test('manager IDs separate stores, appointment events, recipients and request versions', async () => {
  const base = await managerNoticeId('s', 'a', 'created', 'v', '13900001111');
  assert(/^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(base));
  for (const values of [['s2','a','created','v','13900001111'], ['s','b','created','v','13900001111'],
    ['s','a','cancelled','v','13900001111'], ['s','a','created','v2','13900001111'], ['s','a','created','v','13900002222']]) {
    assert(await managerNoticeId(values[0],values[1],values[2],values[3],values[4]) !== base);
  }
});
