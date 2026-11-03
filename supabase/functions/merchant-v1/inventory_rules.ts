export function decimal(
  v: unknown,
  scale: number,
  max = 999999999,
): v is number {
  return typeof v === "number" && Number.isFinite(v) && v >= 0 && v <= max &&
    Math.abs(v * 10 ** scale - Math.round(v * 10 ** scale)) < 0.00001;
}
export function day(v: unknown): boolean {
  if (typeof v !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(v)) return false;
  const d = new Date(`${v}T00:00:00Z`);
  return Number.isFinite(d.getTime()) && d.toISOString().slice(0, 10) === v;
}
export function documentError(
  kind: string,
  payload: Record<string, unknown>,
): string | null {
  if (payload.freight != null && !decimal(payload.freight, 2)) {
    return "运费须为非负金额，最多两位小数";
  }
  if (payload.date != null && !day(payload.date)) return "单据日期无效";
  if (
    payload.payment != null &&
    !["现金", "微信", "对公转账", "挂账"].includes(String(payload.payment))
  ) return "付款方式无效";
  if (
    payload.reason != null &&
    !["施工领用", "损耗报废", "退回供应商", "内部使用"].includes(
      String(payload.reason),
    )
  ) return "出库类型无效";
  if (!Array.isArray(payload.lines)) return "请添加商品";
  for (const line of payload.lines) {
    if (
      !line || !decimal(line.quantity, 3) ||
      (kind !== "check" && line.quantity === 0)
    ) return "数量须大于零，盘点可填零，最多三位小数";
    if (kind === "in" && !decimal(line.cost, 2)) {
      return "成本单价无效，最多两位小数";
    }
    if (
      kind === "check" &&
      (!Number.isSafeInteger(line.version) || line.version < 0)
    ) return "盘点版本无效";
    if (
      line.expires_on != null && line.expires_on !== "" && !day(line.expires_on)
    ) return "有效期无效，请输入 YYYY-MM-DD";
  }
  return null;
}
