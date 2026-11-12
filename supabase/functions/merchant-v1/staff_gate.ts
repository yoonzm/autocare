import type { Input } from './types.ts';

export type Role = 'owner' | 'manager' | 'cashier' | 'technician';
export const roles: Role[] = ['owner', 'manager', 'cashier', 'technician'];

/** 某个请求对身份的要求。staff 身份（店长 / 前台 / 技师）默认拒绝，只放行下面明确列出的动作；老板不经过此校验。 */
export type Requirement =
  | { kind: 'any' }
  | { kind: 'cap'; cap: string }
  | { kind: 'anyCap'; caps: string[] }
  | { kind: 'owner' }
  | { kind: 'deny' };

const any: Requirement = { kind: 'any' };
const owner: Requirement = { kind: 'owner' };
const cap = (c: string): Requirement => ({ kind: 'cap', cap: c });
const anyCap = (...caps: string[]): Requirement => ({ kind: 'anyCap', caps });
const deny: Requirement = { kind: 'deny' };

const inventoryReads = new Set([
  'inventory_list', 'inventory_get', 'inventory_lookup', 'inventory_options', 'inventory_documents',
  'inventory_document_get', 'inventory_draft', 'inventory_quote', 'inventory_assignments',
]);

/** 目录型业务（kind + action）。 */
const kindRules: Record<string, Record<string, Requirement>> = {
  members: {
    list: cap('member_view'), get: cap('member_view'), ledger: cap('member_view'), save: cap('member_edit'),
    delete: cap('member_delete'), recharge_options: cap('member_recharge_refund'), recharge: cap('member_recharge_refund'),
    adjust: cap('member_refund_adjust'), recognize_plate: cap('member_lookup'),
  },
  vehicles: { save: cap('member_edit'), delete: cap('member_edit') },
  member_packages: {
    list: cap('member_view'), get: cap('member_view'), sell: cap('cashier'),
    extend: cap('member_refund_adjust'), refund: cap('member_refund_adjust'),
  },
  orders: {
    holds: cap('cashier'), hold_get: cap('cashier'), hold: cap('cashier'), hold_cancel: cap('cashier'), checkout: cap('cashier'),
  },
  follow_ups: { list: cap('member_view'), save: cap('member_view'), mark: cap('member_view'), reminders: cap('member_view') },
  // 服务项目、卡种、次卡套餐：开单需要读取，维护需要门店设置权限
  services: { list: any, save: cap('catalog_manage'), delete: cap('catalog_manage') },
  packages: { list: any, save: cap('catalog_manage'), delete: cap('catalog_manage') },
  cards: { list: any, rules: any, save: cap('catalog_manage'), save_rules: cap('catalog_manage'), delete: cap('catalog_manage') },
};

const byAction: Record<string, Requirement> = {
  get_store: any,
  profile_update: any,
  profile_avatar_upload: any,
  staff_home: any,
  staff_task_list: cap('order_view_own'),
  staff_task_detail: cap('order_view_own'),
  staff_task_progress: cap('progress_update'),
  staff_task_finish: cap('progress_update'),
  staff_perf: cap('perf_view_own'),
  staff_arrivals: cap('arrivals_today'),
  staff_member_search: cap('member_lookup'),
  staff_member_info: cap('member_lookup'),
  staff_order_quote: cap('order_submit'),
  staff_order_submit: cap('order_submit'),
  staff_cash_queue: cap('cash_queue'),
  staff_order_return: cap('cash_queue'),
  staff_redeem_send: cap('order_submit'),
  staff_redeem: cap('order_submit'),
  staff_messages: any,
  staff_messages_read: any,
  home_stats: cap('stats_view_store'),
  package_stats: cap('stats_view_store'),
  settings_stats: cap('catalog_manage'),
  change_password: owner,
  change_phone: owner,
  delete_account: owner,
  list_stores: owner,
  get_subscription: owner,
  appointment_board: cap('appt_view'),
  appointment_get: cap('appt_view'),
  // 选项里含全部技师的手机号等，只给能编辑预约的身份
  appointment_options: cap('appt_edit'),
  appointment_slots: cap('appt_edit'),
  appointment_summary: cap('appt_view'),
  appointment_save: cap('appt_edit'),
  appointment_arrive: cap('appt_edit'),
  appointment_cancel: cap('appt_edit'),
  appointment_checkout: cap('cashier'),
  appointment_settings_save: cap('appt_settings'),
  appointment_resource_save: cap('appt_settings'),
  order_list: anyCap('order_view_all', 'order_view_own'),
  order_detail: anyCap('order_view_all', 'order_view_own'),
  order_feed: anyCap('order_view_all', 'order_view_own'),
  order_operators: cap('order_view_all'),
  order_refund: cap('order_refund'),
  staff_list: cap('staff_view'),
  staff_get: cap('staff_view'),
  staff_records: cap('staff_view'),
  staff_save: cap('staff_manage'),
  staff_status: cap('staff_manage'),
  staff_commission_save: cap('staff_manage'),
  staff_invite: cap('staff_manage'),
  staff_permissions_save: owner,
};

export function requirementFor(input: Input): Requirement {
  const action = String(input.action ?? '');
  if (typeof input.kind === 'string') {
    const rule = kindRules[input.kind]?.[action];
    return rule ?? deny;
  }
  if (action.startsWith('subscription_') || action.startsWith('store_') || action.startsWith('support_')) return owner;
  if (action.startsWith('inventory_')) return inventoryReads.has(action) ? anyCap('stock_manage', 'stock_use') : cap('stock_manage');
  if (action.startsWith('expense_')) return cap('expense');
  return byAction[action] ?? deny;
}

export interface Decision {
  allowed: boolean;
  message?: string;
}

/** caps 为服务端算好的生效权限（含「不可开启」）。老板直接放行；技师无论开关如何都拿不到完整会员资料。 */
export function decide(role: Role, caps: Record<string, boolean>, input: Input): Decision {
  if (role === 'owner') return { allowed: true };
  const need = requirementFor(input);
  const refuse = (message = '暂无权限，请联系店长开通'): Decision => ({ allowed: false, message });
  switch (need.kind) {
    case 'any':
      return { allowed: true };
    case 'owner':
      return refuse('该功能仅老板可用');
    case 'cap':
      return caps[need.cap] === true ? { allowed: true } : refuse();
    case 'anyCap':
      return need.caps.some((c) => caps[c] === true) ? { allowed: true } : refuse();
    default:
      return refuse();
  }
}
