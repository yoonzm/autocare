import { day, decimal } from "./inventory_rules.ts";
import type { Input } from "./types.ts";
const uuid = (v: unknown) =>
  typeof v === "string" &&
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
export const expenseCategories = [
  "房租",
  "水电",
  "人工",
  "材料采购",
  "设备维修",
  "营销推广",
  "税费",
  "其他",
  "损耗",
];
export function expenseError(d: Input): string | null {
  if (!uuid(d.id) || !Number.isInteger(d.revision) || Number(d.revision) < 0) {
    return "记录标识无效";
  }
  if (!decimal(d.amount, 2) || d.amount === 0) {
    return "请输入大于零的金额，最多两位小数";
  }
  if (!expenseCategories.includes(String(d.category)) || !day(d.occurred_on)) {
    return "分类或日期无效";
  }
  if (
    !["paid", "unpaid"].includes(String(d.status)) ||
    !["现金", "微信", "支付宝", "对公转账", "其他"].includes(String(d.account))
  ) return "付款状态或账户无效";
  if (
    typeof d.payee !== "string" || d.payee.length > 120 ||
    typeof d.note !== "string" || d.note.length > 1000 ||
    typeof d.repeat !== "boolean"
  ) return "请检查收款方和备注";
  return null;
}
export function budgetError(d: Input): string | null {
  if (typeof d.carry !== "boolean" || typeof d.remind !== "boolean") {
    return "预算规则无效";
  }
  if (
    !day(d.month) || !String(d.month).endsWith("-01") ||
    !Number.isInteger(d.revision)
  ) return "月份或版本无效";
  if (
    !decimal(d.total, 2) || !d.categories || typeof d.categories !== "object" ||
    Array.isArray(d.categories)
  ) return "预算无效";
  let sum = 0;
  for (const [k, raw] of Object.entries(d.categories)) {
    const v = raw as Input;
    if (
      !expenseCategories.includes(k) || !v || !decimal(v.amount, 2) ||
      ![70, 80, 90, 100].includes(Number(v.threshold)) ||
      !["warn", "owner", "block"].includes(String(v.policy)) ||
      typeof v.repeat !== "boolean" || typeof v.rollover !== "boolean"
    ) return "分类预算无效";
    sum += Math.round(Number(v.amount) * 100);
  }
  return sum > Math.round(Number(d.total) * 100)
    ? "分类分配不能超过总预算"
    : null;
}
