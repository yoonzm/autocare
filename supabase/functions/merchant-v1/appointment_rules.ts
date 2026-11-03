import type { Input } from './types.ts';
const id = (v: unknown) => typeof v === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(v);
export const validDay = (v: unknown): v is string =>
  typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v) &&
  !Number.isNaN(Date.parse(v)) && new Date(v).toISOString().slice(0, 10) === v;
export function parseBooking(i: Input): Input | string {
  if (i.notify === true || i.remind === true || i.deposit === true) return '通知和定金尚未接通';
  for (const k of ['id', 'member_id', 'bay_id', 'technician_id']) {
    if (i[k] != null && !id(i[k])) return '预约或资源 ID 无效';
  }
  if (
    typeof i.starts_at !== 'string' ||
    !validDay(i.starts_at.slice(0, 10)) ||
    !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/.test(i.starts_at) ||
    !Number.isFinite(Date.parse(i.starts_at))
  ) return '预约时间无效';
  if (
    i.id == null &&
    (!Array.isArray(i.service_ids) || i.service_ids.length < 1 || i.service_ids.length > 20 ||
      !i.service_ids.every(id))
  ) return '请选择服务项目';
  if (i.note != null && (typeof i.note !== 'string' || i.note.length > 200)) return '备注最多 200 字';
  return {
    id: i.id ?? null,
    member_id: i.member_id ?? null,
    bay_id: i.bay_id ?? null,
    technician_id: i.technician_id ?? null,
    starts_at: i.starts_at,
    service_ids: i.service_ids ?? [],
    note: i.note ?? '',
  };
}
export function parseBookingSettings(i: Input): Input | string {
  for (const k of ['opens_at', 'closes_at']) {
    if (typeof i[k] !== 'string' || !/^([01]\d|2[0-3]):[0-5]\d$/.test(i[k] as string)) return '营业时间无效';
  }
  if (String(i.opens_at) >= String(i.closes_at)) return '结束时间须晚于开始时间';
  if (![15, 30, 60].includes(i.slot_minutes as number)) return '时间间隔无效';
  for (
    const [k, min, max] of [['capacity', 1, 20], ['lead_hours', 0, 168], ['advance_days', 1, 90], [
      'grace_minutes',
      0,
      120,
    ]] as const
  ) {
    if (!Number.isInteger(i[k]) || Number(i[k]) < min || Number(i[k]) > max) return '接待规则无效';
  }
  if (
    !Array.isArray(i.closed_days) || i.closed_days.length > 7 ||
    !i.closed_days.every((d) => Number.isInteger(d) && d >= 1 && d <= 7)
  ) return '定休日无效';
  return Object.fromEntries(
    [
      'opens_at',
      'closes_at',
      'slot_minutes',
      'capacity',
      'lead_hours',
      'advance_days',
      'grace_minutes',
      'closed_days',
    ].map((k) => [k, i[k]]),
  );
}
export function parseResource(i: Input): Input | string {
  if (i.id != null && !id(i.id)) return '资源 ID 无效';
  if (!['bay', 'technician'].includes(String(i.kind))) return '资源类型无效';
  if (typeof i.name !== 'string' || i.name.trim().length < 1 || i.name.trim().length > 30) {
    return '请填写名称（最多 30 字）';
  }
  if (
    i.phone != null && (typeof i.phone !== 'string' || (i.phone !== '' && !/^1[3-9]\d{9}$/.test(i.phone)))
  ) return '手机号无效';
  if (i.active != null && typeof i.active !== 'boolean') return '启用状态无效';
  if (
    i.position != null &&
    (!Number.isInteger(i.position) || Number(i.position) < 0 || Number(i.position) > 100)
  ) return '排序无效';
  if (i.category != null && (typeof i.category !== 'string' || i.category.length > 100)) return '类别无效';
  if (i.kind === 'technician' && (typeof i.phone !== 'string' || !/^1[3-9]\d{9}$/.test(i.phone))) {
    return '请填写技师手机号';
  }
  if (i.linked_id != null && !id(i.linked_id)) return '关联资源 ID 无效';
  if (i.joined_on != null && !validDay(i.joined_on)) return '入职日期无效';
  if (i.online != null && typeof i.online !== 'boolean') return '预约开放状态无效';
  return {
    id: i.id ?? null,
    kind: i.kind,
    name: i.name.trim(),
    phone: i.phone ?? '',
    category: i.category ?? '',
    position: i.position ?? 0,
    active: i.active ?? true,
    linked_id: i.linked_id ?? null,
    joined_on: i.joined_on ?? null,
    online: i.online ?? false,
  };
}
