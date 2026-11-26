import { parseStoreNotifySettings, STORE_NOTIFY_SETTING_KEYS } from './store_notify_rules.ts';
import { decide } from './staff_gate.ts';

const assert = (ok: boolean, message = 'assertion failed') => {
  if (!ok) throw new Error(message);
};

Deno.test('parseStoreNotifySettings accepts partial boolean updates and strips unknown fields', () => {
  for (const key of STORE_NOTIFY_SETTING_KEYS) {
    const res = parseStoreNotifySettings({ [key]: false, opens_at: '09:00:00', unknown: 123 });
    assert(typeof res === 'object', `expected object for ${key}`);
    const obj = res as Record<string, unknown>;
    assert(obj[key] === false, `expected ${key}=false`);
    assert(Object.keys(obj).length === 1, 'should only keep the submitted notify key');
  }
  const multi = parseStoreNotifySettings({ notify_consume: true, notify_recharge: false });
  assert(typeof multi === 'object');
  assert((multi as Record<string, unknown>).notify_consume === true);
  assert((multi as Record<string, unknown>).notify_recharge === false);
});

Deno.test('parseStoreNotifySettings rejects empty or non-boolean inputs', () => {
  assert(typeof parseStoreNotifySettings({}) === 'string');
  assert(typeof parseStoreNotifySettings({ opens_at: '09:00' }) === 'string');
  for (const key of STORE_NOTIFY_SETTING_KEYS) {
    assert(typeof parseStoreNotifySettings({ [key]: 'true' }) === 'string');
    assert(typeof parseStoreNotifySettings({ [key]: 1 }) === 'string');
    assert(typeof parseStoreNotifySettings({ [key]: null }) === 'string');
  }
});

Deno.test('store notify settings actions require owner or manager, independent of appt_settings', () => {
  for (const action of ['store_sms_overview', 'store_sms_logs', 'store_notify_settings_save']) {
    assert(decide('owner', {}, { action }).allowed === true);
    assert(decide('manager', { appt_settings: false }, { action }).allowed === true);
    assert(decide('cashier', { appt_settings: true }, { action }).allowed === false);
    assert(decide('technician', { appt_settings: true }, { action }).allowed === false);
  }
});
