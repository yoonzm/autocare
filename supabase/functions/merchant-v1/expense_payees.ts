// 收款方选择：从历史开支里提取“最近使用”的收款方（不单独建表）。
// 同名（忽略大小写和空格）只保留最近一条，用它的分类、金额、日期帮助区分同名收款方。

export type PayeeRow = {
  payee: string;
  category: string;
  amount: number | string;
  occurred_on: string;
};

export type PayeeItem = {
  name: string;
  category: string;
  amount: number;
  occurred_on: string;
};

export const PAYEE_MAX_LENGTH = 20;
export const PAYEE_LIST_LIMIT = 20;

export function payeeKey(name: string): string {
  return name.replace(/\s+/g, "").toLowerCase();
}

/** rows 需已按“最近使用”倒序。query 为空返回最近的若干条，否则按名称包含过滤。 */
export function recentPayees(
  rows: PayeeRow[],
  query = "",
  limit = PAYEE_LIST_LIMIT,
): PayeeItem[] {
  const needle = payeeKey(query);
  const seen = new Set<string>();
  const items: PayeeItem[] = [];
  for (const row of rows) {
    const name = String(row.payee ?? "").trim();
    const key = payeeKey(name);
    if (!key || seen.has(key)) continue;
    seen.add(key);
    if (needle && !key.includes(needle)) continue;
    items.push({
      name,
      category: row.category,
      amount: Number(row.amount),
      occurred_on: row.occurred_on,
    });
    if (items.length >= limit) break;
  }
  return items;
}
