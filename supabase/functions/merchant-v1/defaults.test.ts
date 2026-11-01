import { BUSINESS_TYPES, DEFAULT_CARDS, defaultServices } from './defaults.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('the default business types give the design\'s 8 services, in the design order', () => {
  const s = defaultServices(['洗车美容', '镀晶镀膜', '隐形车衣']);
  eq(s.map((x) => x.name), [
    '全车镀晶 · 9H 陶瓷', '石墨烯镀膜', '漆面抛光', '精致洗车', '快速洗车',
    '发动机舱清洗', '全车隐形车衣', '内饰深度清洁',
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
  eq(defaultServices(['镀晶镀膜']).map((x) => x.category), ['镀晶镀膜', '镀晶镀膜', '镀晶镀膜'], '镀晶镀膜');
  eq(defaultServices(['洗车美容']).map((x) => x.name), ['精致洗车', '快速洗车', '发动机舱清洗', '内饰深度清洁'], '洗车美容');
  eq(defaultServices(['隐形车衣']).map((x) => x.name), ['全车隐形车衣'], '隐形车衣');
});

Deno.test('types without design data, unknown types and empty choice give nothing', () => {
  eq(defaultServices(['改色膜', '保养维修']).length, 0, 'no design data');
  eq(defaultServices(['不存在']).length, 0, 'unknown');
  eq(defaultServices([]).length, 0, 'empty');
});

Deno.test('choosing all types does not duplicate services', () => {
  const s = defaultServices([...BUSINESS_TYPES]);
  eq(s.length, 8, 'count');
  eq(new Set(s.map((x) => x.name)).size, 8, 'unique');
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
