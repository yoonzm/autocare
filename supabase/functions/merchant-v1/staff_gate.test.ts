import { decide, requirementFor, type Role } from './staff_gate.ts';
const assert = (ok: boolean, msg = 'assertion failed') => {
  if (!ok) throw new Error(msg);
};
const caps = (on: string[]) => Object.fromEntries(on.map((k) => [k, true]));
const can = (role: Role, on: string[], input: Record<string, unknown>) => decide(role, caps(on), input).allowed;

Deno.test('owner is never gated; unknown actions are denied for staff', () => {
  assert(can('owner', [], { action: 'anything_at_all' }));
  assert(!can('technician', [], { action: 'anything_at_all' }));
  assert(!can('manager', ['member_view'], { kind: 'unknown_kind', action: 'list' }));
  assert(!can('cashier', ['member_view'], { kind: 'members', action: 'unknown_action' }));
});

Deno.test('catalog rules: members, orders, appointments follow capabilities', () => {
  assert(can('cashier', ['member_view'], { kind: 'members', action: 'list' }));
  assert(!can('technician', [], { kind: 'members', action: 'list' }));
  assert(can('technician', ['member_lookup'], { kind: 'members', action: 'recognize_plate' }));
  assert(!can('cashier', ['cashier'], { kind: 'members', action: 'delete' }));
  assert(can('cashier', ['cashier'], { kind: 'orders', action: 'checkout' }));
  assert(!can('technician', ['order_submit'], { kind: 'orders', action: 'checkout' }));
  assert(can('technician', ['appt_view'], { action: 'appointment_board' }));
  assert(!can('technician', ['appt_view'], { action: 'appointment_options' }), '选项含全部技师手机号');
  assert(!can('technician', ['appt_view'], { action: 'appointment_save' }));
  assert(can('cashier', ['appt_edit', 'cashier'], { action: 'appointment_checkout' }));
  assert(!can('manager', ['appt_edit'], { action: 'appointment_settings_save' }));
});

Deno.test('owner-only areas are closed to every staff role even with all caps', () => {
  const all = ['member_view', 'cashier', 'staff_manage', 'stats_view_store', 'stock_manage', 'expense'];
  for (const role of ['manager', 'cashier', 'technician'] as Role[]) {
    for (const action of ['store_create', 'store_switch', 'subscription_pay', 'support_list', 'delete_account', 'get_subscription', 'list_stores', 'staff_permissions_save']) {
      assert(!can(role, all, { action }), `${role} ${action}`);
    }
  }
});

Deno.test('inventory reads accept stock_use, writes need stock_manage; expenses need expense', () => {
  assert(can('technician', ['stock_use'], { action: 'inventory_list' }));
  assert(!can('technician', ['stock_use'], { action: 'inventory_document_save' }));
  assert(can('manager', ['stock_manage'], { action: 'inventory_document_save' }));
  assert(!can('manager', ['stock_manage'], { action: 'expense_board' }));
  assert(can('manager', ['expense'], { action: 'expense_board' }));
});

Deno.test('catalog reads are open to staff, maintenance is not', () => {
  assert(can('technician', [], { kind: 'services', action: 'list' }));
  assert(!can('technician', [], { kind: 'services', action: 'save' }));
  assert(can('manager', ['catalog_manage'], { kind: 'cards', action: 'save' }));
  assert(requirementFor({ kind: 'cards', action: 'rules' }).kind === 'any');
});

Deno.test('staff workflow actions: tasks need task caps, perf needs perf cap, messages are open to any staff', () => {
  assert(can('technician', ['order_view_own'], { action: 'staff_task_list' }));
  assert(!can('technician', ['order_view_own'], { action: 'staff_task_finish' }));
  assert(can('technician', ['progress_update'], { action: 'staff_task_finish' }));
  assert(!can('cashier', [], { action: 'staff_perf' }));
  assert(can('cashier', ['perf_view_own'], { action: 'staff_perf' }));
  assert(can('cashier', [], { action: 'staff_messages' }));
  assert(can('technician', [], { action: 'staff_messages_read' }));
});

Deno.test('refusals carry a message the app can show', () => {
  const d = decide('technician', {}, { kind: 'members', action: 'list' });
  assert(!d.allowed && typeof d.message === 'string' && d.message.length > 0);
  assert(decide('manager', {}, { action: 'get_subscription' }).message === '该功能仅老板可用');
});
