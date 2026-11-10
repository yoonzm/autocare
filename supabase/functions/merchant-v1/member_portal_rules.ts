// 会员端小程序的纯规则：令牌、会员码、入参校验、错误文案。不依赖 Deno / 数据库，方便单测。
import { normalizePlate, parseVehicle } from './member_rules.ts';
import { validDay } from './appointment_rules.ts';

const UUID = /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i;
export const isId = (v: unknown): v is string => typeof v === 'string' && UUID.test(v);
const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/;

export const CANCEL_REASONS = ['时间有变', '已在别处完成', '其他原因'] as const;
/** 会员码前缀：版本号，便于以后更换编码格式。店员端扫码时据此识别。 */
export const CODE_PREFIX = 'ACM1:';
export const CODE_SECONDS = 60;
/** 取消 / 改约须提前的小时数（数据库同样校验，这里只用于文案）。 */
export const CANCEL_LEAD_HOURS = 2;

const hex = (bytes: Uint8Array) => Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
const b64url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

/** 会话令牌：256 位随机，客户端保存明文，库里只存哈希。 */
export function newToken(): string {
  return b64url(crypto.getRandomValues(new Uint8Array(32)));
}
export async function sha256(value: string): Promise<string> {
  return hex(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))));
}
/** 会员码：去掉易混淆字符的 20 位大写字母数字，约 100 位熵。 */
export function newCode(): string {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const bytes = crypto.getRandomValues(new Uint8Array(20));
  return Array.from(bytes, (b) => alphabet[b % alphabet.length]).join('');
}

export const maskPhone = (phone: string) =>
  /^\d{11}$/.test(phone) ? `${phone.slice(0, 3)} **** ${phone.slice(7)}` : '';

export type Parsed<T> = T | string;

export function parseStoreId(input: Record<string, unknown>): Parsed<string> {
  return isId(input.store_id) ? input.store_id : '门店无效';
}

export function parseSlots(input: Record<string, unknown>): Parsed<{ day: string; service_ids: string[] }> {
  if (!validDay(input.day)) return '请选择预约日期';
  const ids = parseServiceIds(input.service_ids);
  return typeof ids === 'string' ? ids : { day: input.day, service_ids: ids };
}

export function parseServiceIds(value: unknown): Parsed<string[]> {
  if (!Array.isArray(value) || value.length < 1 || value.length > 20 || !value.every(isId)) return '请选择服务项目';
  return [...new Set(value as string[])];
}

export interface BookValues {
  service_ids: string[];
  starts_at: string;
  vehicle_id: string;
  note: string;
  replace_id: string | null;
}
/** 会员只能决定服务、时间、车辆和备注；工位、技师、报价、会员身份都由服务端定。 */
export function parseBook(input: Record<string, unknown>): Parsed<BookValues> {
  const ids = parseServiceIds(input.service_ids);
  if (typeof ids === 'string') return ids;
  if (typeof input.starts_at !== 'string' || !ISO.test(input.starts_at) || !Number.isFinite(Date.parse(input.starts_at))) {
    return '预约时间无效';
  }
  if (!isId(input.vehicle_id)) return '请选择服务车辆';
  if (input.note != null && (typeof input.note !== 'string' || input.note.length > 200)) return '备注最多 200 字';
  if (input.replace_id != null && !isId(input.replace_id)) return '预约无效';
  return {
    service_ids: ids,
    starts_at: new Date(input.starts_at).toISOString(),
    vehicle_id: input.vehicle_id,
    note: typeof input.note === 'string' ? input.note.trim() : '',
    replace_id: (input.replace_id as string | null | undefined) ?? null,
  };
}

export function parseCancel(input: Record<string, unknown>): Parsed<{ id: string; reason: string }> {
  if (!isId(input.id)) return '预约无效';
  if (!(CANCEL_REASONS as readonly string[]).includes(String(input.reason))) return '请选择取消原因';
  return { id: input.id, reason: String(input.reason) };
}

export function parseTab(input: Record<string, unknown>): Parsed<'pending' | 'done' | 'cancelled'> {
  return input.tab === 'pending' || input.tab === 'done' || input.tab === 'cancelled' ? input.tab : '状态无效';
}

export function parseOrders(input: Record<string, unknown>): Parsed<{ kind: string; before: string | null }> {
  const kind = input.kind ?? 'all';
  if (kind !== 'all' && kind !== 'service' && kind !== 'recharge') return '类型无效';
  if (input.before != null && (typeof input.before !== 'string' || !Number.isFinite(Date.parse(input.before)))) {
    return '分页位置无效';
  }
  return { kind, before: input.before ? new Date(input.before as string).toISOString() : null };
}

export interface CarValues {
  values: { plate: string; energy: string; brand_model: string; color: string };
  is_default: boolean;
}
/** 添加车辆沿用商户端的车牌 / 车型校验；会员端必须填品牌车型（设计稿标注必填）。 */
export function parseCar(input: Record<string, unknown>): Parsed<CarValues> {
  const v = parseVehicle({ plate: input.plate, brand_model: input.brand_model, color: input.color, energy: input.energy });
  if (typeof v === 'string') return v;
  if (!v.brand_model) return '请填写品牌车型';
  return {
    values: { plate: normalizePlate(v.plate), energy: v.energy, brand_model: v.brand_model, color: v.color },
    is_default: input.is_default === true,
  };
}

export const needsPayment = '线上支付暂未开通，请到店办理';

const RPC_ERRORS: [string, number, string][] = [
  ['slot_unavailable', 409, '该时段已约满或不可预约，请重新选择'],
  ['vehicle_required', 400, '请选择自己的服务车辆'],
  ['service_not_found', 400, '服务项目不存在或已下架'],
  ['services_required', 400, '请选择服务项目'],
  ['appointment_not_found', 404, '预约不存在'],
  ['appointment_closed', 409, '预约状态已变化，请刷新后重试'],
  ['cancel_too_late', 409, `距到店不足 ${CANCEL_LEAD_HOURS} 小时，请直接联系门店`],
  ['cancel_reason_required', 400, '请选择取消原因'],
  ['too_many_appointments', 409, '待到店的预约已达上限，请先完成或取消已有预约'],
  ['request_reused', 409, '请求已用于其他预约，请重新提交'],
  ['member_not_found', 403, '您还不是该门店会员，请联系门店办理'],
  ['order_not_found', 404, '记录不存在'],
  ['vehicle_limit', 409, '最多添加 10 辆车'],
  ['member_vehicles_store_plate_uidx', 409, '该车牌已在本店登记，如非本人添加请联系门店'],
];
/** 数据库异常 -> 面向会员的提示；未知错误不泄露细节。 */
export function rpcProblem(e: { message?: string; code?: string }): { message: string; status: number } {
  const text = `${e.message ?? ''}`;
  const hit = RPC_ERRORS.find(([key]) => text.includes(key));
  if (hit) return { status: hit[1], message: hit[2] };
  if (e.code === '23505') return { status: 409, message: '该车牌已在本店登记，如非本人添加请联系门店' };
  if (e.code === '22P02' || e.code === '23514') return { status: 400, message: '输入参数无效' };
  return { status: 500, message: '操作失败，请稍后重试' };
}
