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
  { category: '洗车', name: '精致洗车', description: '工时 40min · 提成 ¥8/单', price: 68, active: true },
  { category: '洗车', name: '快速洗车', description: '工时 20min · 提成 ¥4/单', price: 38, active: true },
  // The design shows this one as taken off the shelf.
  { category: '洗车', name: '发动机舱清洗', description: '工时 30min', price: 120, active: false },
  { category: '贴膜', name: '全车隐形车衣', description: '工时 2 天 · 提成 6%', price: 18800, active: true },
  { category: '内饰', name: '内饰深度清洁', description: '工时 2h · 提成 ¥40/单', price: 380, active: true },
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
