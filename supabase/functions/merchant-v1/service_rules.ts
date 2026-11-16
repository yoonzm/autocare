import type { Input } from './types.ts';

const uuid = (v: unknown) => typeof v === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(v);

/** 耗材绑定输入：[{ product_id, quantity }]；未传（undefined）表示不修改；传空数组表示清空。 */
export function parseConsumables(v: unknown): { product_id: string; quantity: number }[] | string | undefined {
  if (v === undefined) return undefined;
  if (!Array.isArray(v) || v.length > 20) return '耗材最多 20 种';
  const seen = new Set<string>();
  const items: { product_id: string; quantity: number }[] = [];
  for (const raw of v as Input[]) {
    if (!raw || !uuid(raw.product_id)) return '耗材商品无效';
    const q = Number(raw.quantity);
    if (!Number.isFinite(q) || q <= 0 || q > 999999 || Math.round(q * 1000) / 1000 !== q) {
      return '耗材用量须大于 0，最多三位小数';
    }
    const id = String(raw.product_id);
    if (seen.has(id)) return '同一商品不能重复添加';
    seen.add(id);
    items.push({ product_id: id, quantity: q });
  }
  return items;
}

/** 数据库异常 → 面向用户的说明。 */
export function consumableError(message: string): string {
  const map: Record<string, string> = {
    service_not_found: '服务项目不存在',
    product_not_found: '耗材商品不存在',
    product_disabled: '耗材商品已停用，请先启用或移除',
    duplicate_product: '同一商品不能重复添加',
    invalid_quantity: '耗材用量须大于 0，最多三位小数',
    integer_quantity: '该商品不允许小数用量',
    invalid_consumables: '耗材最多 20 种',
  };
  return map[message] ?? '耗材保存失败';
}
