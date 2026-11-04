import { PAGE_SIZE, parseOrderDetail, parseOrderQuery, parseOrderRefund, rangeOf } from './order_rules.ts';

function check(v: unknown, message: string) {
  if (!v) throw new Error(message);
}
// 2026-11-03 周二 12:00（北京时间）
const now = Date.parse('2026-11-03T12:00:00+08:00');

Deno.test('时间范围按北京时间计日：今日 / 昨日 / 本周从周一 / 本月从 1 号', () => {
  const iso = (ms: number) => new Date(ms + 8 * 3600000).toISOString().slice(0, 16);
  const t = rangeOf('today', '', '', now) as { from: number; to: number };
  check(iso(t.from) === '2026-11-03T00:00' && iso(t.to) === '2026-11-04T00:00', 'today');
  const y = rangeOf('yesterday', '', '', now) as { from: number; to: number };
  check(iso(y.from) === '2026-11-02T00:00' && iso(y.to) === '2026-11-03T00:00', 'yesterday');
  const w = rangeOf('week', '', '', now) as { from: number; to: number };
  check(iso(w.from) === '2026-11-02T00:00' && iso(w.to) === '2026-11-04T00:00', 'week starts Monday');
  const m = rangeOf('month', '', '', now) as { from: number; to: number };
  check(iso(m.from) === '2026-11-01T00:00', 'month');
});

Deno.test('周日算上一周的最后一天，周一当天从当天开始', () => {
  const sunday = Date.parse('2026-11-08T10:00:00+08:00');
  const w = rangeOf('week', '', '', sunday) as { from: number };
  check(new Date(w.from + 8 * 3600000).toISOString().slice(0, 10) === '2026-11-02', 'sunday');
  const monday = Date.parse('2026-11-09T00:30:00+08:00');
  const m = rangeOf('week', '', '', monday) as { from: number };
  check(new Date(m.from + 8 * 3600000).toISOString().slice(0, 10) === '2026-11-09', 'monday');
});

Deno.test('自定义范围含首尾两天，缺日期 / 倒序 / 超过 366 天被拒', () => {
  const r = rangeOf('custom', '2026-10-01', '2026-10-03', now) as { from: number; to: number };
  check((r.to - r.from) / 86400000 === 3, 'inclusive');
  check(typeof rangeOf('custom', '', '', now) === 'string', 'missing');
  check(typeof rangeOf('custom', '2026-10-03', '2026-10-01', now) === 'string', 'reversed');
  check(typeof rangeOf('custom', '2024-01-01', '2026-01-01', now) === 'string', 'too long');
  check(typeof rangeOf('forever', '', '', now) === 'string', 'unknown');
});

Deno.test('订单查询：默认今日全部；类型 / 收款方式 / 状态只接受白名单', () => {
  const q = parseOrderQuery({}, now);
  check(typeof q !== 'string' && q.kind === 'all' && q.limit === PAGE_SIZE && q.before === null, 'defaults');
  check(typeof parseOrderQuery({ type: 'x' }, now) === 'string', 'bad type');
  check(typeof parseOrderQuery({ method: 'POS 刷卡' }, now) === 'string', 'bad method');
  check(typeof parseOrderQuery({ status: 'pending' }, now) === 'string', 'bad status');
  check(typeof parseOrderQuery({ q: 'x'.repeat(31) }, now) === 'string', 'long q');
  check(typeof parseOrderQuery({ before: 'nope' }, now) === 'string', 'bad before');
  const ok = parseOrderQuery({ type: 'consume', method: '储值抵扣', status: 'refunded', operator: '陈明', q: '沪A', before: '2026-11-03T10:00:00Z' }, now);
  check(typeof ok !== 'string' && ok.method === '储值抵扣' && ok.before === '2026-11-03T10:00:00.000Z', 'valid');
});

Deno.test('订单详情和退款参数：id 必须是 UUID，部分退款被明确拒绝，原因要从列表里选', () => {
  const id = '10000000-0000-0000-0000-000000000001';
  check(typeof parseOrderDetail({ type: 'consume', id }) !== 'string', 'detail ok');
  check(typeof parseOrderDetail({ type: 'refund', id }) === 'string', 'refund type has no detail');
  check(typeof parseOrderDetail({ type: 'consume', id: '1' }) === 'string', 'bad id');
  check(typeof parseOrderRefund({ id, reason: '服务问题' }) !== 'string', 'refund ok');
  check(typeof parseOrderRefund({ id, reason: '服务问题', scope: 'partial' }) === 'string', 'partial rejected');
  check(typeof parseOrderRefund({ id, reason: '随便' }) === 'string', 'bad reason');
  check(typeof parseOrderRefund({ id: 'x', reason: '服务问题' }) === 'string', 'bad id');
});
