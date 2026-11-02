// Validation of members and their vehicles as sent by the app. Pure, so it can be unit tested.

export const HONORIFICS = ['', '先生', '女士'] as const;
export const SOURCES = ['', '到店自然客', '老客推荐', '团购平台', '短视频'] as const;
export const ENERGIES = ['fuel', 'ev'] as const;

export interface MemberValues {
  phone: string;
  name: string;
  honorific: string;
  birthday: string | null; // yyyy-mm-dd
  source: string;
  referrer_id: string | null;
  note: string;
}
export interface VehicleValues {
  plate: string;
  energy: string;
  brand_model: string;
  color: string;
  vin: string;
  mileage: number | null;
}

const UUID = /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i;
const text = (v: unknown) => (typeof v === 'string' ? v.trim() : '');
// 省份简称 + 发牌机关字母 + 5 位（燃油）或 6 位（新能源）字母数字
const PLATE = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼][A-Z][A-Z0-9]{5,6}$/;
const VIN = /^[A-HJ-NPR-Z0-9]{17}$/;

/** Plate as typed: spaces and the dot are dropped, letters upper-cased. */
export const normalizePlate = (v: unknown) => text(v).replace(/[\s·.]/g, '').toUpperCase();

export function parseBirthday(v: unknown, today = new Date()): string | null | undefined {
  const s = text(v).replace(/\./g, '-');
  if (s === '') return null;
  const m = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(s);
  if (!m) return undefined;
  const [y, mo, d] = [Number(m[1]), Number(m[2]), Number(m[3])];
  const date = new Date(Date.UTC(y, mo - 1, d));
  if (date.getUTCFullYear() !== y || date.getUTCMonth() !== mo - 1 || date.getUTCDate() !== d) return undefined;
  if (y < 1900 || date.getTime() > today.getTime()) return undefined;
  return `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

/** Returns the values to store, or a message for the user. */
export function parseMember(input: Record<string, unknown>, today = new Date()): MemberValues | string {
  const phone = text(input.phone).replace(/\s/g, '');
  if (!/^1[3-9]\d{9}$/.test(phone)) return '请输入正确的 11 位手机号';
  const name = text(input.name);
  if (name.length < 1 || name.length > 30) return '请输入客户姓名（30 字以内）';
  const honorific = input.honorific === undefined ? '' : text(input.honorific);
  if (!(HONORIFICS as readonly string[]).includes(honorific)) return '称呼无效';
  const birthday = parseBirthday(input.birthday, today);
  if (birthday === undefined) return '生日无效';
  const source = input.source === undefined ? '' : text(input.source);
  if (!(SOURCES as readonly string[]).includes(source)) return '客户来源无效';
  let referrer: string | null = null;
  if (input.referrer_id != null && input.referrer_id !== '') {
    if (typeof input.referrer_id !== 'string' || !UUID.test(input.referrer_id)) return '推荐人无效';
    referrer = input.referrer_id;
  }
  if (referrer && source !== '老客推荐') return '只有“老客推荐”可以选择推荐人';
  const note = text(input.note);
  if (note.length > 200) return '备注不能超过 200 字';
  return { phone, name, honorific, birthday, source, referrer_id: referrer, note };
}

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
  const vin = text(input.vin).toUpperCase();
  if (vin !== '' && !VIN.test(vin)) return '车架号为 17 位字母数字（不含 I、O、Q）';
  let mileage: number | null = null;
  if (input.mileage != null && input.mileage !== '') {
    const n = Number(String(input.mileage).replace(/,/g, ''));
    if (!Number.isInteger(n) || n < 0 || n > 2_000_000) return '当前里程无效';
    mileage = n;
  }
  return { plate, energy, brand_model: brand, color, vin, mileage };
}

// ───────── 储值充值 / 调整 ─────────
export const PAY_METHODS = ['微信', '支付宝', '现金', 'POS 刷卡'] as const;
export const ADJUST_REASONS = ['活动补发', '客诉补偿', '录入错误', '其他'] as const;
export const MAX_RECHARGE = 1_000_000;
export const MAX_POINTS_ADJUST = 1_000_000;

/** 充值档位与赠送金额（设计稿的四档；自定义金额不享赠送）。赠送的服务次数暂未实现。 */
export const RECHARGE_PRESETS = [
  { amount: 1000, gift: 100 },
  { amount: 2000, gift: 300 },
  { amount: 5000, gift: 1000 },
  { amount: 10000, gift: 2500 },
] as const;

export const giftFor = (amount: number) => RECHARGE_PRESETS.find((p) => p.amount === amount)?.gift ?? 0;

export interface RechargeValues {
  amount: number;
  gift: number;
  method: string;
  note: string;
}

export function parseRecharge(input: Record<string, unknown>): RechargeValues | string {
  const amount = Number(String(input.amount ?? '').replace(/,/g, ''));
  if (!Number.isFinite(amount) || amount <= 0) return '请输入充值金额';
  if (amount > MAX_RECHARGE) return '单笔充值不能超过 100 万';
  if (Math.round(amount * 100) !== amount * 100) return '充值金额最多两位小数';
  const method = typeof input.method === 'string' ? input.method.trim() : '';
  if (!(PAY_METHODS as readonly string[]).includes(method)) return '请选择收款方式';
  const note = typeof input.note === 'string' ? input.note.trim() : '';
  if (note.length > 200) return '备注不能超过 200 字';
  return { amount, gift: giftFor(amount), method, note };
}

export interface AdjustValues {
  tier_id: string | null;
  points: number;
  reason: string;
  note: string;
}

export function parseAdjust(input: Record<string, unknown>): AdjustValues | string {
  let tier: string | null = null;
  if (input.tier_id != null && input.tier_id !== '') {
    if (typeof input.tier_id !== 'string' || !UUID.test(input.tier_id)) return '卡种无效';
    tier = input.tier_id;
  }
  const points = input.points == null || input.points === '' ? 0 : Number(input.points);
  if (!Number.isInteger(points) || Math.abs(points) > MAX_POINTS_ADJUST) return '积分调整数量无效';
  if (tier == null && points === 0) return '请选择要调整的卡种或填写积分';
  const reason = typeof input.reason === 'string' ? input.reason.trim() : '';
  if (!(ADJUST_REASONS as readonly string[]).includes(reason)) return '请选择调整原因';
  const note = typeof input.note === 'string' ? input.note.trim() : '';
  if (note.length > 200) return '备注不能超过 200 字';
  return { tier_id: tier, points, reason, note };
}
