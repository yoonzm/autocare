// Starter data created for every new store. It is exactly the sample data of the design
// (服务项目与价格 / 会员卡种与权益 pages); the owner edits it afterwards.

export const BUSINESS_TYPES = ['洗车美容', '镀晶镀膜', '隐形车衣', '改色膜', '保养维修'] as const;
export type BusinessType = typeof BUSINESS_TYPES[number];

export interface DefaultService {
  name: string;
  category: string;
  description: string;
  price: number;
  active: boolean;
}

// The design's service list, in the design's order.
const DESIGN_SERVICES: DefaultService[] = [
  { category: '镀晶镀膜', name: '全车镀晶 · 9H 陶瓷', description: '工时 4h · 提成 8%', price: 1580, active: true },
  { category: '镀晶镀膜', name: '石墨烯镀膜', description: '工时 6h · 提成 8%', price: 2680, active: true },
  { category: '镀晶镀膜', name: '漆面抛光', description: '工时 3h · 提成 ¥60/单', price: 680, active: true },
  // The two services below only appear in the design's package picker (单次 ¥1,280 · 约 240 分钟,
  // 单次 ¥98 · 约 30 分钟); they are needed by the design's packages.
  { category: '镀晶镀膜', name: '镀晶养护', description: '工时 4h', price: 1280, active: true },
  { category: '洗车', name: '精致洗车', description: '工时 40min · 提成 ¥8/单', price: 68, active: true },
  { category: '洗车', name: '快速洗车', description: '工时 20min · 提成 ¥4/单', price: 38, active: true },
  // The design shows this one as taken off the shelf.
  { category: '洗车', name: '发动机舱清洗', description: '工时 30min', price: 120, active: false },
  { category: '贴膜', name: '全车隐形车衣', description: '工时 2 天 · 提成 6%', price: 18800, active: true },
  { category: '内饰', name: '内饰深度清洁', description: '工时 2h · 提成 ¥40/单', price: 380, active: true },
  { category: '内饰', name: '空调杀菌', description: '工时 30min', price: 98, active: true },
];

// Which design categories each business type brings. The design has no sample data for
// 改色膜 or 保养维修, so choosing only those starts with an empty service list.
const CATEGORIES: Record<BusinessType, string[]> = {
  洗车美容: ['洗车', '内饰'],
  镀晶镀膜: ['镀晶镀膜'],
  隐形车衣: ['贴膜'],
  改色膜: [],
  保养维修: [],
};

/** Design services for the chosen business types, in the design's order. */
export function defaultServices(types: readonly string[]): DefaultService[] {
  const wanted = new Set<string>();
  for (const t of types) for (const c of CATEGORIES[t as BusinessType] ?? []) wanted.add(c);
  return DESIGN_SERVICES.filter((s) => wanted.has(s.category)).map((s) => ({ ...s }));
}

export interface DefaultCard {
  name: string;
  description: string;
  discount: number;
  color: 'black' | 'champagne' | 'silver' | 'blue' | 'white';
  upgrade_recharge: number | null;
  upgrade_cumulative: number | null;
  points_multiplier: number;
  birthday_gift: string;
  priority_booking: boolean;
  validity: 'forever' | '1y' | '2y';
}

// The four tiers of the design's card list, highest tier first.
export const DEFAULT_CARDS: DefaultCard[] = [
  {
    name: '黑金卡', description: '', discount: 0.9, color: 'black',
    upgrade_recharge: 10000, upgrade_cumulative: 30000, points_multiplier: 2,
    birthday_gift: '赠精致洗车 2 次', priority_booking: true, validity: 'forever',
  },
  {
    name: '金卡', description: '', discount: 0.95, color: 'champagne',
    upgrade_recharge: 5000, upgrade_cumulative: 10000, points_multiplier: 1.5,
    birthday_gift: '赠精致洗车 1 次', priority_booking: false, validity: 'forever',
  },
  {
    name: '银卡', description: '', discount: 0.98, color: 'silver',
    upgrade_recharge: 2000, upgrade_cumulative: 3000, points_multiplier: 1,
    birthday_gift: '', priority_booking: false, validity: 'forever',
  },
  {
    name: '普通会员', description: '扫码免费注册 · 消费累积积分', discount: 1, color: 'white',
    upgrade_recharge: null, upgrade_cumulative: null, points_multiplier: 1,
    birthday_gift: '', priority_booking: false, validity: 'forever',
  },
];

export interface DefaultPackage {
  name: string;
  price: number;
  validity_months: number;
  active: boolean;
  /** Included services by name, with how many times each can be used. */
  items: { service: string; count: number }[];
}

// The six packages of the design's 次卡套餐 list (price = the sale price shown there; the
// "original price" is derived from the services' prices, so it is not stored). The sold counts
// and the business overview of that page are statistics, not starter data.
export const DEFAULT_PACKAGES: DefaultPackage[] = [
  { name: '精致洗车年卡', price: 1080, validity_months: 12, active: true, items: [{ service: '精致洗车', count: 20 }] },
  { name: '精致洗车 10 次卡', price: 580, validity_months: 6, active: true, items: [{ service: '精致洗车', count: 10 }] },
  { name: '内饰深度清洁 6 次卡', price: 1380, validity_months: 12, active: true, items: [{ service: '内饰深度清洁', count: 6 }] },
  { name: '镀晶养护 3 次卡', price: 2980, validity_months: 12, active: true, items: [{ service: '镀晶养护', count: 3 }] },
  { name: '空调杀菌 4 次卡', price: 380, validity_months: 6, active: true, items: [{ service: '空调杀菌', count: 4 }] },
  // The design shows this one as taken off the shelf.
  { name: '新客体验卡', price: 99, validity_months: 3, active: false, items: [{ service: '精致洗车', count: 3 }] },
];

/**
 * The design packages whose services all exist in the store's starter services. A package
 * must not be created without its services, so e.g. a store that did not get 精致洗车 gets
 * no 精致洗车 packages.
 */
export function defaultPackages(serviceNames: readonly string[]): DefaultPackage[] {
  const have = new Set(serviceNames);
  return DEFAULT_PACKAGES.filter((p) => p.items.every((i) => have.has(i.service)));
}
