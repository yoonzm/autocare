import { inboxArgs } from './inbox_rules.ts';
import { decide } from './staff_gate.ts';
const assert = (ok: boolean) => { if (!ok) throw new Error('assertion failed'); };
const id = '11111111-1111-4111-8111-111111111111';
Deno.test('inbox validates paging and read range, rejects broad accidental reads', () => {
  assert(typeof inboxArgs({ action: 'inbox_list', cursor: { at: '2026-11-25T00:00:00Z', id } }) === 'object');
  for (const input of [
    { action: 'inbox_list', kind: 'unknown' }, { action: 'inbox_list', cursor: { at: 'bad', id } },
    { action: 'inbox_list', cursor: [] }, { action: 'inbox_read' },
    { action: 'inbox_read', id, before: '2026-11-25T00:00:00Z' }, { action: 'inbox_target', id: "x');delete" },
    { action: 'inbox_delete' },
  ]) assert(typeof inboxArgs(input) === 'string');
  assert(typeof inboxArgs({ action: 'inbox_read', id }) === 'object');
  assert(typeof inboxArgs({ action: 'inbox_read', before: '2026-11-25T00:00:00Z' }) === 'object');
});
Deno.test('all authenticated roles can use their own inbox; caller identity is not a request argument', () => {
  for (const role of ['owner', 'manager', 'cashier', 'technician'] as const) {
    for (const action of ['inbox_list', 'inbox_read', 'inbox_unread', 'inbox_target']) assert(decide(role, {}, { action }).allowed);
  }
  const args = inboxArgs({ action: 'inbox_read', id, p_store: id, p_owner: id, p_staff: id });
  assert(typeof args === 'object' && !('p_owner' in args) && !('p_staff' in args) && !('p_store' in args));
});
