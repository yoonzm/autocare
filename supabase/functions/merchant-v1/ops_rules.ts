// Validation of the member operations: selling / extending / refunding 次卡, checkout, follow-ups.
// Pure, so it can be unit tested. Prices, discounts and balances are never taken from the client.

import { PAY_METHODS } from './member_rules.ts';

const UUID = /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i;
const text = (v: unknown) => (typeof v === 'string' ? v.trim() : '');

export const EXTEND_REASONS = ['会员长期出差', '门店服务延误', '其他'] as const;
export const REFUND_TO = ['原路退回', '储值余额'] as const;
export const REFUND_REASONS = ['会员不再需要', '搬家 / 换车', '服务问题'] as const;
export const VISIT_METHODS = ['电话', '微信', '到店'] as const;
export const VISIT_RESULTS = ['已接通 · 有意向', '已接通 · 暂无需求', '未接通', '已预约到店'] as const;
export const MAX_LINES = 30;

export interface SellValues {
  member_id: string;
  package_id: string;
  method: string;
}
export function parseSell(input: Record<string, unknown>): SellValues | string {
  if (typeof input.member_id !== 'string' || !UUID.test(input.member_id)) return '会员无效';
  if (typeof input.package_id !== 'string' || !UUID.test(input.package_id)) return '请选择次卡套餐';
  const method = text(input.method);
  const methods = [...PAY_METHODS, '会员余额'] as readonly string[];
  if (!methods.includes(method)) return '请选择收款方式';
  return { member_id: input.member_id, package_id: input.package_id, method };
}

export function parseExtend(input: Record<string, unknown>): { days: number; reason: string } | string {
  const days = Number(input.days);
  if (!Number.isInteger(days) || days < 1 || days > 3650) return '延期天数须为 1–3650 天';
  const reason = text(input.reason);
  if (!(EXTEND_REASONS as readonly string[]).includes(reason)) return '请选择延期原因';
  return { days, reason };
}

export function parseRefund(input: Record<string, unknown>): { to: string; reason: string } | string {
  const to = text(input.to);
  if (!(REFUND_TO as readonly string[]).includes(to)) return '请选择退回方式';
  const reason = text(input.reason);
  if (!(REFUND_REASONS as readonly string[]).includes(reason)) return '请选择退款原因';
  return { to, reason };
}

export interface CheckoutLine {
  service_id: string;
  qty: number;
  member_package_id: string | null;
}
export interface CheckoutValues {
  member_id: string;
  lines: CheckoutLine[];
  method: string;
  balance_part: number | null;
  other: string | null;
  plate: string;
  remark: string;
  hold_id: string | null;
}

function parseLines(input: Record<string, unknown>): CheckoutLine[] | string {
  if (!Array.isArray(input.lines) || input.lines.length < 1) return '请先选择服务项目';
  if (input.lines.length > MAX_LINES) return `一次最多 ${MAX_LINES} 个项目`;
  const lines: CheckoutLine[] = [];
  const seen = new Set<string>();
  for (const raw of input.lines) {
    if (raw == null || typeof raw !== 'object') return '服务项目无效';
    const l = raw as Record<string, unknown>;
    if (typeof l.service_id !== 'string' || !UUID.test(l.service_id)) return '服务项目无效';
    const qty = l.qty == null ? 1 : Number(l.qty);
    if (!Number.isInteger(qty) || qty < 1 || qty > 99) return '数量须为 1–99';
    let pkg: string | null = null;
    if (l.member_package_id != null && l.member_package_id !== '') {
      if (typeof l.member_package_id !== 'string' || !UUID.test(l.member_package_id)) return '次卡无效';
      pkg = l.member_package_id;
    }
    const key = `${l.service_id}:${pkg ?? ''}`;
    if (seen.has(key)) return '同一个项目不能重复添加';
    seen.add(key);
    lines.push({ service_id: l.service_id, qty, member_package_id: pkg });
  }
  return lines;
}

export const HOLD_STATUSES = ['待施工', '施工中', '待结算'] as const;
export const HOLD_REMINDS = ['不提醒', '30 分钟', '1 小时', '完工时'] as const;

export interface HoldValues {
  hold_id: string | null;
  member_id: string;
  lines: CheckoutLine[];
  status: string;
  note: string;
  remind: string;
  plate: string;
}
export function parseHold(input: Record<string, unknown>): HoldValues | string {
  if (typeof input.member_id !== 'string' || !UUID.test(input.member_id)) return '会员无效';
  let holdId: string | null = null;
  if (input.hold_id != null && input.hold_id !== '') {
    if (typeof input.hold_id !== 'string' || !UUID.test(input.hold_id)) return '挂单无效';
    holdId = input.hold_id;
  }
  const lines = parseLines(input);
  if (typeof lines === 'string') return lines;
  const status = text(input.status) || '待施工';
  if (!(HOLD_STATUSES as readonly string[]).includes(status)) return '请选择挂单状态';
  const remind = text(input.remind) || '不提醒';
  if (!(HOLD_REMINDS as readonly string[]).includes(remind)) return '请选择到点提醒';
  const note = text(input.note);
  if (note.length > 200) return '备注不能超过 200 字';
  const plate = text(input.plate).replace(/[\s·.]/g, '').toUpperCase();
  if (plate.length > 10) return '车牌号无效';
  return { hold_id: holdId, member_id: input.member_id, lines, status, note, remind, plate };
}

export function parseCheckout(input: Record<string, unknown>): CheckoutValues | string {
  if (typeof input.member_id !== 'string' || !UUID.test(input.member_id)) return '会员无效';
  const lines = parseLines(input);
  if (typeof lines === 'string') return lines;
  const method = text(input.method);
  const methods = [...PAY_METHODS, '会员余额', '组合支付'] as readonly string[];
  if (!methods.includes(method)) return '请选择收款方式';
  let balancePart: number | null = null;
  let other: string | null = null;
  if (method === '组合支付') {
    balancePart = Number(input.balance_part);
    if (!Number.isFinite(balancePart) || balancePart <= 0 || Math.round(balancePart * 100) !== balancePart * 100) {
      return '请填写使用的余额金额';
    }
    other = text(input.other);
    if (!(PAY_METHODS as readonly string[]).includes(other)) return '请选择其余部分的收款方式';
  }
  const plate = text(input.plate).replace(/[\s·.]/g, '').toUpperCase();
  if (plate.length > 10) return '车牌号无效';
  const remark = text(input.remark);
  if (remark.length > 200) return '备注不能超过 200 字';
  let holdId: string | null = null;
  if (input.hold_id != null && input.hold_id !== '') {
    if (typeof input.hold_id !== 'string' || !UUID.test(input.hold_id)) return '挂单无效';
    holdId = input.hold_id;
  }
  return { member_id: input.member_id, lines, method, balance_part: balancePart, other, plate, remark, hold_id: holdId };
}

export interface FollowUpValues {
  member_id: string;
  method: string;
  result: string;
  content: string;
  next_at: string | null;
}

export function parseFollowUp(input: Record<string, unknown>, today = new Date()): FollowUpValues | string {
  if (typeof input.member_id !== 'string' || !UUID.test(input.member_id)) return '会员无效';
  const method = text(input.method);
  if (!(VISIT_METHODS as readonly string[]).includes(method)) return '请选择回访方式';
  const result = text(input.result);
  if (!(VISIT_RESULTS as readonly string[]).includes(result)) return '请选择回访结果';
  const content = text(input.content);
  if (content.length > 500) return '回访内容不能超过 500 字';
  let next: string | null = null;
  const raw = text(input.next_at).replace(/\./g, '-');
  if (raw !== '') {
    const m = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(raw);
    if (!m) return '下次回访日期无效';
    const [y, mo, d] = [Number(m[1]), Number(m[2]), Number(m[3])];
    const dt = new Date(Date.UTC(y, mo - 1, d));
    if (dt.getUTCFullYear() !== y || dt.getUTCMonth() !== mo - 1 || dt.getUTCDate() !== d) return '下次回访日期无效';
    const floor = Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate());
    if (dt.getTime() < floor) return '下次回访日期不能早于今天';
    next = `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
  }
  return { member_id: input.member_id, method, result, content, next_at: next };
}
