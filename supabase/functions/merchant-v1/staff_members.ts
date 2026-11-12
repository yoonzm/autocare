import { admin, fail, json, uuid } from './shared.ts';

/** 员工端会员查询（需要「会员查询」权限，网关先校验）。只返回服务相关、已脱敏的信息，不提供任何修改。 */
export const maskPhone = (phone: unknown): string => {
  const p = String(phone ?? '');
  return /^\d{11}$/.test(p) ? `${p.slice(0, 3)}****${p.slice(7)}` : '—';
};

const safeLike = (q: string) => q.replace(/[,()%*_\\"']/g, ' ').trim();
const LIST_LIMIT = 20;

type Row = {
  id: string;
  name: string;
  phone: string;
  balance?: number | string;
  points?: number;
  card?: { name?: string; color?: string; discount?: number | string } | null;
  vehicles?: { plate: string; brand_model?: string; color?: string; energy?: string }[] | null;
};

const listItem = (m: Row) => ({
  id: m.id,
  name: m.name,
  level: m.card?.name ?? '',
  color: m.card?.color ?? '',
  phone_masked: maskPhone(m.phone),
  plate: m.vehicles?.[0]?.plate ?? '',
});

export async function handleStaffMembers(input: Record<string, unknown>, store: string): Promise<Response> {
  const select = 'id, name, phone, card:card_types(name, color), vehicles:member_vehicles(plate)';
  if (input.action === 'staff_member_search') {
    const q = typeof input.q === 'string' ? safeLike(input.q).slice(0, 30) : '';
    let query = admin.from('members').select(select).eq('store_id', store).is('deleted_at', null).limit(LIST_LIMIT);
    if (!q) {
      // 默认：最近到店
      query = query.order('last_visit_at', { ascending: false, nullsFirst: false });
    } else {
      const plate = q.replace(/[\s·.]/g, '').toUpperCase();
      const { data: byPlate } = await admin.from('member_vehicles').select('member_id')
        .eq('store_id', store).ilike('plate', `%${plate}%`).limit(LIST_LIMIT);
      const ids = [...new Set((byPlate ?? []).map((r) => r.member_id as string))];
      const clauses = [`name.ilike.%${q}%`];
      if (/^\d{1,11}$/.test(q)) clauses.push(`phone.like.%${q}`);
      if (ids.length) clauses.push(`id.in.(${ids.join(',')})`);
      query = query.or(clauses.join(',')).order('updated_at', { ascending: false });
    }
    const { data, error } = await query;
    if (error) return fail('查询失败，请稍后重试', 500);
    return json({ item: { items: (data ?? []).map((m) => listItem(m as unknown as Row)) } } as never);
  }
  if (input.action === 'staff_member_info') {
    if (!uuid(input.id)) return fail('会员 ID 无效');
    const { data: m, error } = await admin.from('members')
      .select('id, name, phone, balance, points, card:card_types(name, color, discount), vehicles:member_vehicles(plate, brand_model, color, energy)')
      .eq('store_id', store).eq('id', input.id as string).is('deleted_at', null).maybeSingle();
    if (error) return fail('查询失败，请稍后重试', 500);
    if (!m) return fail('会员不存在', 404);
    const { data: pkgs } = await admin.from('member_packages')
      .select('id, name, total_count, used_count, expires_at, refunded_at')
      .eq('store_id', store).eq('member_id', input.id as string).is('refunded_at', null)
      .order('purchased_at', { ascending: false });
    const pkgIds = (pkgs ?? []).map((p) => p.id as string);
    const { data: pkgItems } = pkgIds.length
      ? await admin.from('member_package_items').select('member_package_id, service_id, service_name, total, used')
        .in('member_package_id', pkgIds).order('position')
      : { data: [] as { member_package_id: string; service_id: string | null; service_name: string; total: number; used: number }[] };
    const now = Date.now();
    const packages = (pkgs ?? [])
      .filter((p) => p.used_count < p.total_count && (!p.expires_at || Date.parse(p.expires_at as string) > now))
      .map((p) => ({
        id: p.id,
        name: p.name,
        remaining: Number(p.total_count) - Number(p.used_count),
        total: Number(p.total_count),
        expires_at: p.expires_at ?? null,
        // 可核销的项目（服务端只列出还有剩余次数、且仍在售的服务）
        items: (pkgItems ?? [])
          .filter((i) => i.member_package_id === p.id && i.service_id && Number(i.total) > Number(i.used))
          .map((i) => ({ service_id: i.service_id, name: i.service_name, remaining: Number(i.total) - Number(i.used) })),
      }));
    const row = m as unknown as Row;
    return json({
      item: {
        ...listItem(row),
        balance: Number(row.balance ?? 0),
        points: Number(row.points ?? 0),
        discount: Number(row.card?.discount ?? 1),
        vehicles: (row.vehicles ?? []).map((v) => ({
          plate: v.plate, model: v.brand_model ?? '', color: v.color ?? '', ev: v.energy === 'ev',
        })),
        packages,
      },
    } as never);
  }
  return fail('不支持的员工操作');
}
