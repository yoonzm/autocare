import { BAY_COUNTS, BUSINESS_TYPES, DEFAULT_CARDS, DEFAULT_PACKAGES, defaultBays, defaultPackages, defaultProducts, defaultServices } from './defaults.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('registration creates sequential bays up to the selected range maximum', () => {
  eq(BAY_COUNTS, { '1-3 个': 3, '4-6 个': 6, '7-10 个': 10, '10 个以上': 20 }, 'range sizes');
  for (const [range, count] of Object.entries(BAY_COUNTS)) {
    const bays = defaultBays(range);
    eq(bays.length, count, `${range} count`);
    eq(bays.map((b) => b.name), Array.from({ length: count }, (_, i) => `${i + 1} 号工位`), `${range} names`);
    eq(bays.map((b) => b.position), Array.from({ length: count }, (_, i) => i + 1), `${range} positions`);
    eq(bays.every((b) => b.kind === 'bay'), true, `${range} kind`);
  }
  eq(defaultBays('unknown'), [], 'invalid range');
});

Deno.test('registration creates inventory catalogue by selected businesses without fake stock or cost', () => {
  const names = (types: string[]) => defaultProducts(types).map((p) => p.name);
  eq(names(['洗车美容']), ['中性洗车液 20L', '超细纤维擦车巾'], 'wash');
  eq(names(['镀晶镀膜']), ['超细纤维擦车巾', '9H 陶瓷镀晶液 50ml', '玻璃镀膜剂'], 'coating');
  eq(names(['隐形车衣']), ['TPU 隐形车衣 7.5mil'], 'ppf');
  eq(names(['改色膜']), ['改色膜 · 哑光灰'], 'wrap');
  eq(defaultProducts(['保养维修']).map((p) => [p.name, p.category]),
    [['机油滤芯', '配件'], ['空气滤芯', '配件']], 'maintenance');
  const all = defaultProducts([...BUSINESS_TYPES]);
  eq(all.length, 8, 'all count');
  eq(new Set(all.map((p) => p.name)).size, all.length, 'multi-select deduplicates shared items');
  eq(all.every((p) => p.stock === 0 && p.safe === 0 && p.cost === 0), true, 'zero quantities and cost');
  eq(all.every((p) => ['洗护', '镀晶', '贴膜', '配件'].includes(p.category)), true, 'existing categories');
  eq(defaultProducts(['不存在']), [], 'unknown');
  eq(defaultProducts([]), [], 'no businesses');
});

Deno.test('the default business types give the design\'s 10 services, in the design order', () => {
  const s = defaultServices(['洗车美容', '镀晶镀膜', '隐形车衣']);
  eq(s.map((x) => x.name), [
    '全车镀晶 · 9H 陶瓷', '石墨烯镀膜', '漆面抛光', '镀晶养护', '精致洗车', '快速洗车',
    '发动机舱清洗', '全车隐形车衣', '内饰深度清洁', '空调杀菌',
  ], 'names');
});

Deno.test('prices and the off-shelf item match the design', () => {
  const byName = Object.fromEntries(defaultServices([...BUSINESS_TYPES]).map((x) => [x.name, x]));
  eq(byName['全车镀晶 · 9H 陶瓷'].price, 1580, 'price');
  eq(byName['全车隐形车衣'].price, 18800, 'price');
  eq(byName['发动机舱清洗'].active, false, 'off-shelf');
  eq(byName['精致洗车'].active, true, 'on-shelf');
});

Deno.test('each business type brings its own categories', () => {
  eq(defaultServices(['镀晶镀膜']).map((x) => x.category), ['镀晶镀膜', '镀晶镀膜', '镀晶镀膜', '镀晶镀膜'], '镀晶镀膜');
  eq(defaultServices(['洗车美容']).map((x) => x.name), ['精致洗车', '快速洗车', '发动机舱清洗', '内饰深度清洁', '空调杀菌'], '洗车美容');
  eq(defaultServices(['隐形车衣']).map((x) => x.name), ['全车隐形车衣'], '隐形车衣');
});

Deno.test('types without design data, unknown types and empty choice give nothing', () => {
  eq(defaultServices(['改色膜', '保养维修']).length, 0, 'no design data');
  eq(defaultServices(['不存在']).length, 0, 'unknown');
  eq(defaultServices([]).length, 0, 'empty');
});

Deno.test('choosing all types does not duplicate services', () => {
  const s = defaultServices([...BUSINESS_TYPES]);
  eq(s.length, 10, 'count');
  eq(new Set(s.map((x) => x.name)).size, 10, 'unique');
});

Deno.test('default cards are the design\'s four tiers', () => {
  eq(DEFAULT_CARDS.map((c) => c.name), ['黑金卡', '金卡', '银卡', '普通会员'], 'names');
  eq(DEFAULT_CARDS.map((c) => c.discount), [0.9, 0.95, 0.98, 1], 'discounts');
  eq(DEFAULT_CARDS.map((c) => c.color), ['black', 'champagne', 'silver', 'white'], 'colors');
  eq(DEFAULT_CARDS.map((c) => c.upgrade_recharge), [10000, 5000, 2000, null], 'recharge');
  eq(DEFAULT_CARDS.map((c) => c.upgrade_cumulative), [30000, 10000, 3000, null], 'cumulative');
  eq(DEFAULT_CARDS.map((c) => c.points_multiplier), [2, 1.5, 1, 1], 'points');
  eq(DEFAULT_CARDS[3].description, '扫码免费注册 · 消费累积积分', 'base tier text');
});

Deno.test('design packages: six of them, the sale prices and the off-shelf one match the design', () => {
  eq(DEFAULT_PACKAGES.map((p) => p.name), [
    '精致洗车年卡', '精致洗车 10 次卡', '内饰深度清洁 6 次卡', '镀晶养护 3 次卡', '空调杀菌 4 次卡', '新客体验卡',
  ], 'names');
  eq(DEFAULT_PACKAGES.map((p) => p.price), [1080, 580, 1380, 2980, 380, 99], 'prices');
  eq(DEFAULT_PACKAGES.map((p) => p.validity_months), [12, 6, 12, 12, 6, 3], 'validity');
  eq(DEFAULT_PACKAGES.map((p) => p.active), [true, true, true, true, true, false], 'on shelf');
});

Deno.test('packages are only created when all their services exist', () => {
  const names = (types: string[]) => defaultPackages(defaultServices(types).map((s) => s.name)).map((p) => p.name);
  eq(names(['洗车美容']), [
    '精致洗车年卡', '精致洗车 10 次卡', '内饰深度清洁 6 次卡', '空调杀菌 4 次卡', '新客体验卡',
  ], '洗车美容');
  eq(names(['镀晶镀膜']), ['镀晶养护 3 次卡'], '镀晶镀膜');
  eq(names(['洗车美容', '镀晶镀膜', '隐形车衣']), DEFAULT_PACKAGES.map((p) => p.name), 'default types give all six');
  eq(names(['隐形车衣']), [], '隐形车衣 has none of the design\'s package services');
  eq(names([]), [], 'no services, no packages');
  // every package item must be a service of the design's service list or the design's sheet
  for (const p of DEFAULT_PACKAGES) eq(p.items.length >= 1, true, p.name);
});

Deno.test('published DB starter snapshot equals the registration defaults', async () => {
  const { default: snapshot } = await import('../../data/store_starter_v1.json', { with: { type: 'json' } });
  const { storeStarterTemplate } = await import('./defaults.ts');
  eq(snapshot, storeStarterTemplate(), 'shared starter snapshot');
});
