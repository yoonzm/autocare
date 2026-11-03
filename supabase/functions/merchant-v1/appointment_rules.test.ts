import { parseBooking, parseBookingSettings, parseResource, validDay } from './appointment_rules.ts';
const id = 'aaaaaaaa-0000-0000-0000-000000000001';
const assert = (ok: boolean) => {
  if (!ok) throw new Error('assertion failed');
};
Deno.test('booking input: explicit timezone, member/resource IDs, services and note limits', () => {
  const base = { starts_at: '2026-11-05T10:00:00+08:00', service_ids: [id] };
  assert(typeof parseBooking(base) === 'object');
  for (
    const input of [
      { ...base, starts_at: '2026-11-05 10:00' },
      { ...base, member_id: 'bad' },
      { ...base, service_ids: [] },
      { ...base, note: 'a'.repeat(201) },
      { ...base, bay_id: 'bad' },
      { ...base, notify: true },
      { ...base, remind: true },
      { ...base, deposit: true },
    ]
  ) assert(typeof parseBooking(input) === 'string');
  const result = parseBooking({ ...base, estimate: 1, duration_minutes: 1, store_id: id }) as Record<
    string,
    unknown
  >;
  assert(!('estimate' in result) && !('duration_minutes' in result) && !('store_id' in result));
});
Deno.test('calendar validates actual dates and leap days', () => {
  assert(validDay('2028-02-29'));
  assert(!validDay('2026-02-29'));
  assert(!validDay('2026-13-01'));
  assert(!validDay('2026-2-1'));
});
Deno.test('settings validates ranges, order, weekdays and strips unsupported fields', () => {
  const base = {
    opens_at: '09:00',
    closes_at: '20:00',
    slot_minutes: 30,
    capacity: 2,
    lead_hours: 0,
    advance_days: 30,
    grace_minutes: 15,
    closed_days: [1],
  };
  assert(typeof parseBookingSettings(base) === 'object');
  for (
    const input of [{ ...base, closes_at: '08:00' }, { ...base, slot_minutes: 7 }, { ...base, capacity: 0 }, {
      ...base,
      lead_hours: -1,
    }, { ...base, closed_days: [8] }]
  ) assert(typeof parseBookingSettings(input) === 'string');
});
Deno.test('resource names, phone, linked resource and immutability inputs', () => {
  assert(typeof parseResource({ kind: 'bay', name: '1 号工位' }) === 'object');
  assert(typeof parseResource({ kind: 'technician', name: '技师', phone: '13912345678' }) === 'object');
  for (
    const input of [
      { kind: 'bay', name: '' },
      { kind: 'technician', name: '技师' },
      { kind: 'bay', name: 'x', linked_id: 'bad' },
      { kind: 'bay', name: 'x', position: -1 },
      { kind: 'bay', name: 'x', joined_on: '2026-02-30' },
    ]
  ) assert(typeof parseResource(input) === 'string');
});
