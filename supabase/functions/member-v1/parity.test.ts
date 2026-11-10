// member-v1 里保留了几条与商户端相同的规则副本（部署包按函数目录分别拷贝，不能跨目录 import）。
// 这里和 merchant-v1 的原实现比对，任何一边单独修改都会让测试失败。
import { parseVehicle as merchantParse, normalizePlate as merchantNormalize, RECHARGE_PRESETS as merchantPresets } from '../merchant-v1/member_rules.ts';
import { validDay as merchantDay } from '../merchant-v1/appointment_rules.ts';
import { normalizePlate, parseVehicle, RECHARGE_PRESETS, validDay } from './vehicle_rules.ts';

const same = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('plate normalisation and vehicle validation match the merchant implementation', () => {
  const cases: Record<string, unknown>[] = [
    { plate: '沪A8K29M' }, { plate: '沪a·8k29m', brand_model: '宝马 5 系', color: '黑色' }, { plate: '沪AF09316', brand_model: '理想 L7' },
    { plate: '沪AF09316', energy: 'fuel' }, { plate: '沪A8K29M', energy: 'ev' }, { plate: '沪A8K29M', energy: 'x' },
    { plate: '12345' }, { plate: '' }, { plate: '沪A8K29M', brand_model: 'x'.repeat(51) }, { plate: '沪A8K29M', color: 'x'.repeat(21) },
    { plate: ' 京B 12345 ' }, { plate: '粤B·D12345' }, { plate: '沪A8K29M', vin: 'bad', mileage: -1 },
  ];
  for (const c of cases) {
    same(normalizePlate(c.plate), merchantNormalize(c.plate), 'normalize ' + JSON.stringify(c));
    const mine = parseVehicle(c);
    const theirs = merchantParse(c);
    if (typeof mine === 'string' || typeof theirs === 'string') {
      // 会员端额外不接受车架号 / 里程，所以商户端对 vin / mileage 报错而会员端忽略是允许的；其余必须同为错误或同值
      if (typeof mine === 'string' && typeof theirs === 'string') same(mine, theirs, 'error ' + JSON.stringify(c));
      else if (!('vin' in c)) throw new Error('mismatch ' + JSON.stringify(c));
    } else {
      same(mine, { plate: theirs.plate, energy: theirs.energy, brand_model: theirs.brand_model, color: theirs.color }, 'value ' + JSON.stringify(c));
    }
  }
});

Deno.test('recharge presets and day validation match the merchant implementation', () => {
  same(RECHARGE_PRESETS, merchantPresets, 'presets');
  for (const d of ['2026-11-01', '2026-02-30', '2026-13-01', 'x', '', null, 20261101, '2026-1-1']) same(validDay(d), merchantDay(d), 'day ' + String(d));
});
