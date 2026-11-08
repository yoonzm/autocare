import type { Input } from './types.ts';

const id = (v: unknown) => typeof v === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(v);
export const staffRoles = ['manager', 'cashier', 'technician'] as const;
export const permissionKeys = [
  'order_view_own', 'order_view_all', 'progress_update', 'cashier', 'member_view',
  'member_recharge_refund', 'stock_use', 'stock_manage', 'perf_view_own', 'stats_view_store',
] as const;
export const skillOptions = ['洗车', '内饰清洁', '镀晶', '抛光', '贴膜', '石墨烯镀膜', '空调杀菌'];
const day = (v: unknown) =>
  typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v) && !Number.isNaN(Date.parse(v)) &&
  new Date(v).toISOString().slice(0, 10) === v;

/** 新增 / 编辑员工。门店、状态、提成等敏感字段不接受客户端传入。 */
export function parseStaff(i: Input): Input | string {
  if (i.id != null && !id(i.id)) return '员工 ID 无效';
  if (!staffRoles.includes(i.role as typeof staffRoles[number])) return '请选择角色';
  const name = typeof i.name === 'string' ? i.name.trim() : '';
  if (name.length < 1 || name.length > 30) return '请填写员工姓名（最多 30 字）';
  if (typeof i.phone !== 'string' || !/^1[3-9]\d{9}$/.test(i.phone)) return '请填写正确的手机号';
  if (i.bay_id != null && i.bay_id !== '' && !id(i.bay_id)) return '工位 ID 无效';
  if (i.joined_on != null && i.joined_on !== '' && !day(i.joined_on)) return '入职日期无效';
  let skills = '';
  if (i.role === 'technician' && i.skills != null) {
    const list = Array.isArray(i.skills) ? i.skills : typeof i.skills === 'string' && i.skills ? i.skills.split(' / ') : [];
    if (!list.every((s) => typeof s === 'string' && skillOptions.includes(s))) return '擅长项目无效';
    skills = [...new Set(list as string[])].join(' / ');
  }
  return {
    id: i.id ?? null,
    name,
    phone: i.phone,
    role: i.role,
    skills,
    bay_id: i.role === 'technician' && i.bay_id ? i.bay_id : null,
    joined_on: i.joined_on ? i.joined_on : null,
  };
}

export function parseCommission(i: Input): Input | string {
  if (!id(i.id)) return '员工 ID 无效';
  if (!['follow', 'flat', 'custom'].includes(String(i.mode))) return '提成方式无效';
  const rate = i.rate == null ? 0 : Number(i.rate);
  if (!Number.isFinite(rate) || rate < 0 || rate > 100) return '提成比例须为 0–100%';
  const overrides: Record<string, number> = {};
  if (i.overrides != null) {
    if (typeof i.overrides !== 'object' || Array.isArray(i.overrides)) return '自定义提成无效';
    for (const [k, v] of Object.entries(i.overrides as Record<string, unknown>)) {
      const n = Number(v);
      if (!id(k) || typeof v !== 'number' || !Number.isFinite(n) || n < 0 || n > 100) return '自定义提成无效';
      overrides[k] = n;
    }
  }
  return { id: i.id, mode: i.mode, rate, overrides };
}

export function parseStatus(i: Input): Input | string {
  if (!id(i.id)) return '员工 ID 无效';
  if (!['disabled', 'enabled'].includes(String(i.status))) return '状态无效';
  if (i.reason != null && (typeof i.reason !== 'string' || i.reason.length > 100)) return '原因最多 100 字';
  if (i.transfer_to != null && !id(i.transfer_to)) return '接手技师无效';
  return {
    id: i.id, status: i.status,
    reason: typeof i.reason === 'string' ? i.reason.trim() : '',
    transfer_to: i.transfer_to ?? null,
  };
}

export function parsePermissions(i: Input): Input | string {
  if (!['cashier', 'technician'].includes(String(i.role))) return '店长权限固定为全部';
  if (i.permissions == null || typeof i.permissions !== 'object' || Array.isArray(i.permissions)) return '权限设置无效';
  const out: Record<string, boolean> = {};
  for (const [k, v] of Object.entries(i.permissions as Record<string, unknown>)) {
    if (!permissionKeys.includes(k as typeof permissionKeys[number]) || typeof v !== 'boolean') return '权限设置无效';
    out[k] = v;
  }
  return { role: i.role, permissions: out };
}

export function parseRecords(i: Input): Input | string {
  if (!id(i.id)) return '员工 ID 无效';
  if (!['month', 'last', 'all'].includes(String(i.range ?? 'month'))) return '时间范围无效';
  return { id: i.id, range: i.range ?? 'month' };
}

/** 邀请令牌：32 字节随机数；服务端只保存 SHA-256，原文只返回一次。 */
export function newInviteToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}
export async function inviteHash(token: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(token));
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, '0')).join('');
}
export function inviteLink(base: string | undefined, token: string): string | null {
  if (!base) return null;
  try {
    const url = new URL(base);
    if (url.protocol !== 'https:') return null;
    url.searchParams.set('invite', token);
    return url.toString();
  } catch {
    return null;
  }
}

/** 服务项目的结构化提成。 */
export function parseServiceCommission(i: Input): { commission_type?: string; commission_value?: number } | string {
  if (i.commission_type == null && i.commission_value == null) return {};
  if (!['percent', 'fixed'].includes(String(i.commission_type))) return '提成方式无效';
  const value = Number(i.commission_value);
  if (!Number.isFinite(value) || value < 0 || value > (i.commission_type === 'percent' ? 100 : 99999999.99)) {
    return i.commission_type === 'percent' ? '提成比例须为 0–100%' : '提成金额无效';
  }
  return { commission_type: String(i.commission_type), commission_value: Math.round(value * 100) / 100 };
}
