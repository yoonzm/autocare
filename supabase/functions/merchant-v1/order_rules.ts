// 订单中心的入参校验和时间范围计算。纯函数，可单测；金额 / 状态 / 退回方式都不取自客户端。

const UUID = /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i;
const text = (v: unknown) => (typeof v === 'string' ? v.trim() : '');

export const ORDER_KINDS = ['all', 'consume', 'recharge', 'package', 'refund'] as const;
export const ORDER_METHODS = ['', '微信', '支付宝', '现金', '储值抵扣'] as const;
export const ORDER_STATUSES = ['', 'completed', 'refunded'] as const;
export const ORDER_RANGES = ['today', 'yesterday', 'week', 'month', 'custom'] as const;
export const REFUND_REASONS = ['服务问题', '会员不再需要', '录入错误', '其他'] as const;
export const PAGE_SIZE = 30;
const DAY = 24 * 3600 * 1000;
const OFFSET = 8 * 3600 * 1000; // 门店统一按北京时间计日

export interface OrderQuery {
  from: string;
  to: string;
  kind: string;
  method: string;
  status: string;
  operator: string;
  q: string;
  before: string | null;
  limit: number;
}

/** 北京时间的“今天 0 点”对应的 UTC 毫秒。 */
function startOfDay(ms: number): number {
  return Math.floor((ms + OFFSET) / DAY) * DAY - OFFSET;
}

function dayStart(value: string): number | null {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  const t = Date.parse(value + 'T00:00:00+08:00');
  return Number.isNaN(t) ? null : t;
}

/** 时间范围：今日 / 昨日 / 本周（周一起）/ 本月 / 自定义（含首尾两天，最长 366 天）。 */
export function rangeOf(range: string, from: unknown, to: unknown, now = Date.now()): { from: number; to: number } | string {
  const today = startOfDay(now);
  switch (range) {
    case 'today':
      return { from: today, to: today + DAY };
    case 'yesterday':
      return { from: today - DAY, to: today };
    case 'week': {
      const dow = new Date(today + OFFSET).getUTCDay(); // 0 周日
      const back = (dow + 6) % 7;
      return { from: today - back * DAY, to: today + DAY };
    }
    case 'month': {
      const d = new Date(today + OFFSET);
      const first = Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), 1) - OFFSET;
      return { from: first, to: today + DAY };
    }
    case 'custom': {
      const a = dayStart(text(from));
      const b = dayStart(text(to));
      if (a === null || b === null) return '请选择起止日期';
      if (b < a) return '结束日期不能早于开始日期';
      if ((b - a) / DAY > 365) return '自定义范围最长 366 天';
      return { from: a, to: b + DAY };
    }
  }
  return '时间范围无效';
}

export function parseOrderQuery(input: Record<string, unknown>, now = Date.now()): OrderQuery | string {
  const range = rangeOf(text(input.range) || 'today', input.from, input.to, now);
  if (typeof range === 'string') return range;
  const kind = text(input.type) || 'all';
  if (!(ORDER_KINDS as readonly string[]).includes(kind)) return '订单类型无效';
  const method = text(input.method);
  if (!(ORDER_METHODS as readonly string[]).includes(method)) return '收款方式无效';
  const status = text(input.status);
  if (!(ORDER_STATUSES as readonly string[]).includes(status)) return '订单状态无效';
  const operator = text(input.operator);
  if (operator.length > 20) return '经办人无效';
  const q = text(input.q);
  if (q.length > 30) return '搜索内容太长';
  let before: string | null = null;
  if (input.before !== undefined && input.before !== null && input.before !== '') {
    const t = Date.parse(String(input.before));
    if (Number.isNaN(t)) return '分页参数无效';
    before = new Date(t).toISOString();
  }
  return {
    from: new Date(range.from).toISOString(),
    to: new Date(range.to).toISOString(),
    kind,
    method,
    status,
    operator,
    q,
    before,
    limit: PAGE_SIZE,
  };
}

export function parseOrderDetail(input: Record<string, unknown>): { kind: string; id: string } | string {
  const kind = text(input.type);
  if (!['consume', 'recharge', 'package'].includes(kind)) return '订单类型无效';
  if (typeof input.id !== 'string' || !UUID.test(input.id)) return '订单无效';
  return { kind, id: input.id };
}

/** 退款：只支持消费订单的整单退款；部分退款、充值退款还没有规则，明确拒绝而不是假装成功。 */
export function parseOrderRefund(input: Record<string, unknown>): { id: string; reason: string } | string {
  if (typeof input.id !== 'string' || !UUID.test(input.id)) return '订单无效';
  if (text(input.scope) && text(input.scope) !== 'full') return '部分退款暂未支持，请选择全额退款';
  const reason = text(input.reason);
  if (!(REFUND_REASONS as readonly string[]).includes(reason)) return '请选择退款原因';
  return { id: input.id, reason };
}
