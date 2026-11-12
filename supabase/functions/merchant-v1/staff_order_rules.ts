/** 员工端开单 / 核销的输入校验（纯函数，便于单测）。价格、折扣、次卡抵扣一律由数据库计算。 */
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export const isUuid = (v: unknown): v is string => typeof v === 'string' && UUID.test(v);

export type StaffLine = { service_id: string; qty: number; member_package_id?: string };

export function parseStaffLines(value: unknown): StaffLine[] | string {
  if (!Array.isArray(value) || value.length === 0) return '请先选择服务项目';
  if (value.length > 20) return '一次最多提交 20 个项目';
  const out: StaffLine[] = [];
  for (const raw of value) {
    if (raw == null || typeof raw !== 'object') return '服务项目无效';
    const l = raw as Record<string, unknown>;
    if (!isUuid(l.service_id)) return '服务项目无效';
    const qty = l.qty == null ? 1 : Number(l.qty);
    if (!Number.isInteger(qty) || qty < 1 || qty > 20) return '数量无效';
    if (l.member_package_id != null && l.member_package_id !== '' && !isUuid(l.member_package_id)) return '次卡无效';
    out.push({
      service_id: l.service_id, qty,
      ...(isUuid(l.member_package_id) ? { member_package_id: l.member_package_id } : {}),
    });
  }
  return out;
}

export interface StaffOrderInput { member_id: string; lines: StaffLine[]; plate: string; note: string }

export function parseStaffOrder(i: Record<string, unknown>): StaffOrderInput | string {
  if (!isUuid(i.member_id)) return '请先选择会员';
  const lines = parseStaffLines(i.lines);
  if (typeof lines === 'string') return lines;
  const plate = typeof i.plate === 'string' ? i.plate.replace(/[\s·.]/g, '').toUpperCase() : '';
  if (plate.length > 10) return '车牌无效';
  const note = typeof i.note === 'string' ? i.note.trim() : '';
  if (note.length > 200) return '备注最多 200 字';
  return { member_id: i.member_id, lines, plate, note };
}

export interface RedeemInput { member_id: string; member_package_id: string; service_id: string; qty: number; code: string; plate: string }

export function parseRedeem(i: Record<string, unknown>): RedeemInput | string {
  if (!isUuid(i.member_id)) return '请先选择会员';
  if (!isUuid(i.member_package_id)) return '请选择要核销的次卡';
  if (!isUuid(i.service_id)) return '请选择要核销的项目';
  const qty = i.qty == null ? 1 : Number(i.qty);
  if (!Number.isInteger(qty) || qty < 1 || qty > 10) return '核销次数无效';
  if (typeof i.code !== 'string' || !/^\d{6}$/.test(i.code)) return '请输入 6 位数字验证码';
  const plate = typeof i.plate === 'string' ? i.plate.replace(/[\s·.]/g, '').toUpperCase().slice(0, 10) : '';
  return { member_id: i.member_id, member_package_id: i.member_package_id, service_id: i.service_id, qty, code: i.code, plate };
}
