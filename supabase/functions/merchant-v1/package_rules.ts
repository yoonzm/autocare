// Validation of a card package (次卡套餐) as sent by the app. Pure, so it can be unit tested.

export const VALIDITY_MONTHS = [0, 3, 6, 12, 24] as const; // 0 = never expires
export const MAX_ITEMS = 30;

export interface PackageValues {
  name: string;
  price: number;
  validity_months: number;
  purchase_limit: number | null;
  vehicle_scope: string;
  show_in_mini: boolean;
  description: string;
  active: boolean;
}
export interface PackageItemInput {
  service_id: string;
  count: number;
}

const UUID = /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i;
const text = (v: unknown) => (typeof v === 'string' ? v.trim() : '');

/** Returns the values to store, or a message for the user. */
export function parsePackage(
  input: Record<string, unknown>,
): { values: PackageValues; items: PackageItemInput[] } | string {
  const name = text(input.name);
  if (!name || name.length > 100) return '套餐名称长度须为 1–100 字';

  const price = Number(input.price);
  if (input.price === '' || input.price == null || !Number.isFinite(price) || price < 0 || price > 99999999.99) {
    return '套餐售价无效';
  }

  const months = input.validity_months === undefined ? 12 : Number(input.validity_months);
  if (!(VALIDITY_MONTHS as readonly number[]).includes(months)) return '有效期无效';

  let limit: number | null = null;
  if (input.purchase_limit !== undefined && input.purchase_limit !== null && input.purchase_limit !== '') {
    limit = Number(input.purchase_limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 99) return '每人限购份数无效';
  }

  const scope = input.vehicle_scope === undefined ? '全部车型' : text(input.vehicle_scope);
  if (!scope || scope.length > 50) return '适用车型无效';

  for (const key of ['show_in_mini', 'active'] as const) {
    if (input[key] !== undefined && typeof input[key] !== 'boolean') return '开关设置无效';
  }
  const description = text(input.description);
  if (description.length > 500) return '套餐说明不能超过 500 字';

  if (!Array.isArray(input.items) || input.items.length < 1) return '请至少添加一个包含服务';
  if (input.items.length > MAX_ITEMS) return `最多包含 ${MAX_ITEMS} 个服务`;
  const items: PackageItemInput[] = [];
  const seen = new Set<string>();
  for (const raw of input.items as Record<string, unknown>[]) {
    const id = raw?.service_id;
    const count = Number(raw?.count);
    if (typeof id !== 'string' || !UUID.test(id)) return '包含的服务无效';
    if (!Number.isInteger(count) || count < 1 || count > 999) return '服务次数须为 1–999';
    if (seen.has(id)) return '同一个服务不能重复添加';
    seen.add(id);
    items.push({ service_id: id, count });
  }

  return {
    values: {
      name,
      price: Math.round(price * 100) / 100,
      validity_months: months,
      purchase_limit: limit,
      vehicle_scope: scope,
      show_in_mini: input.show_in_mini === undefined ? true : (input.show_in_mini as boolean),
      description,
      active: input.active === undefined ? true : (input.active as boolean),
    },
    items,
  };
}
