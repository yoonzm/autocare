// 车牌识别结果中的会员摘要。

/** `1234.5` 以内的剩余次数摘要：`洗车年卡 8 次 · 内饰清洁 2 次`；没有则 `无次卡`。 */
export function packageSummary(rows: { name: string; left: number }[]): string {
  const parts = rows.filter((r) => r.left > 0).map((r) => `${r.name} ${r.left} 次`);
  return parts.length ? parts.join(' · ') : '无次卡';
}

/** 最近到店：`10.31 · 精致洗车`（东八区）；没到过店返回 `还没到过店`。 */
export function lastVisitText(at: string | null, items: string): string {
  if (!at) return '还没到过店';
  const t = new Date(new Date(at).getTime() + 8 * 3600000);
  const d = `${String(t.getUTCMonth() + 1).padStart(2, '0')}.${String(t.getUTCDate()).padStart(2, '0')}`;
  return items ? `${d} · ${items}` : d;
}
