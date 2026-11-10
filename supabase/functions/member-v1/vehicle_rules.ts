// 与商户端共用的几条业务规则。部署包按函数目录分别拷贝，所以这里保留一份小副本；
// parity.test.ts 会和 merchant-v1 的原实现逐项比对，两边改动不同步时测试失败。
//   车牌：merchant-v1/member_rules.ts  充值档位：merchant-v1/member_rules.ts  日期：merchant-v1/appointment_rules.ts

export interface VehicleValues {
  plate: string;
  energy: string;
  brand_model: string;
  color: string;
}

const text = (v: unknown) => (typeof v === 'string' ? v.trim() : '');
// 省份简称 + 发牌机关字母 + 5 位（燃油）或 6 位（新能源）字母数字
const PLATE = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼][A-Z][A-Z0-9]{5,6}$/;
export const ENERGIES = ['fuel', 'ev'] as const;

/** 车牌：去掉空格和圆点，字母大写。 */
export const normalizePlate = (v: unknown) => text(v).replace(/[\s·.]/g, '').toUpperCase();

/** 会员端只允许填车牌、能源类型、品牌车型、颜色（不接受车架号 / 里程）。 */
export function parseVehicle(input: Record<string, unknown>): VehicleValues | string {
  const plate = normalizePlate(input.plate);
  if (!PLATE.test(plate)) return '请输入正确的车牌号';
  const energy = input.energy === undefined ? (plate.length === 8 ? 'ev' : 'fuel') : text(input.energy);
  if (!(ENERGIES as readonly string[]).includes(energy)) return '车牌类型无效';
  if ((energy === 'ev') !== (plate.length === 8)) {
    return energy === 'ev' ? '新能源车牌为 8 位' : '燃油车牌为 7 位';
  }
  const brand = text(input.brand_model);
  if (brand.length > 50) return '品牌车型不能超过 50 字';
  const color = text(input.color);
  if (color.length > 20) return '车身颜色不能超过 20 字';
  return { plate, energy, brand_model: brand, color };
}

/** 充值档位与赠送（线上充值接通前只用于展示；规则以商户端为准）。 */
export const RECHARGE_PRESETS = [
  { amount: 1000, gift: 100 },
  { amount: 2000, gift: 300 },
  { amount: 5000, gift: 1000 },
  { amount: 10000, gift: 2500 },
] as const;

export const validDay = (v: unknown): v is string =>
  typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v) &&
  !Number.isNaN(Date.parse(v)) && new Date(v).toISOString().slice(0, 10) === v;
