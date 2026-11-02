import { admin, fail, json, uuid } from './shared.ts';
import { parseMember, parseVehicle } from './member_rules.ts';
import type { Input } from './types.ts';

const MEMBER_SELECT =
  '*, card:card_types(name, color, discount, points_multiplier), vehicles:member_vehicles(id, plate, energy, brand_model, color, vin, mileage, created_at)';
const MAX_LIST = 200;

// PostgREST `or` filters are comma separated; drop what could break out of the pattern.
const safeLike = (q: string) => q.replace(/[,()%*_\\"']/g, ' ').trim();

function uniqueProblem(message: string): string {
  if (message.includes('member_vehicles_store_plate')) return '该车牌已登记在其他会员名下';
  if (message.includes('members_store_phone')) return '该手机号已是会员';
  return '保存失败';
}

export async function handleMembers(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const limit = Math.min(Math.max(Number(input.limit) || 100, 1), MAX_LIST);
    let query = admin.from('members').select(MEMBER_SELECT)
      .eq('store_id', storeId).is('deleted_at', null)
      .order('created_at', { ascending: false }).limit(limit);
    if (input.card_type_id != null) {
      if (!uuid(input.card_type_id)) return fail('卡种无效');
      query = query.eq('card_type_id', input.card_type_id);
    }
    const q = typeof input.q === 'string' ? safeLike(input.q) : '';
    if (q) {
      // name / phone on the member, or the plate of one of their vehicles
      const { data: byPlate } = await admin.from('member_vehicles').select('member_id')
        .eq('store_id', storeId).ilike('plate', `%${q.replace(/[\s·.]/g, '').toUpperCase()}%`).limit(MAX_LIST);
      const ids = [...new Set((byPlate ?? []).map((r) => r.member_id as string))];
      const parts = [`name.ilike.%${q}%`, `phone.ilike.%${q}%`];
      if (ids.length) parts.push(`id.in.(${ids.join(',')})`);
      query = query.or(parts.join(','));
    }
    const { data, error } = await query;
    if (error) return fail('读取失败', 500);
    // 各卡种的会员数（不受搜索影响），用于筛选条上的数字
    const { data: all } = await admin.from('members').select('card_type_id')
      .eq('store_id', storeId).is('deleted_at', null).limit(100000);
    const counts: Record<string, number> = {};
    for (const r of all ?? []) counts[r.card_type_id as string] = (counts[r.card_type_id as string] ?? 0) + 1;
    return json({ items: data ?? [], counts, total: all?.length ?? 0 });
  }
  if (input.action === 'get') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.from('members').select(MEMBER_SELECT)
      .eq('id', input.id).eq('store_id', storeId).is('deleted_at', null).maybeSingle();
    return error ? fail('读取失败', 500) : data ? json({ item: data }) : fail('会员不存在', 404);
  }
  if (input.action === 'save') {
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const values = parseMember(input);
    if (typeof values === 'string') return fail(values);
    if (input.id == null) {
      // 办卡：建档 + 发放起始卡种，可同时登记一辆车
      let vehicle = null;
      if (input.vehicle != null) {
        if (typeof input.vehicle !== 'object' || Array.isArray(input.vehicle)) return fail('车辆信息无效');
        const parsed = parseVehicle(input.vehicle as Record<string, unknown>);
        if (typeof parsed === 'string') return fail(parsed);
        vehicle = parsed;
      }
      const { data: id, error } = await admin.rpc('create_member', {
        p_store: storeId, p_values: values, p_vehicle: vehicle,
      });
      if (error) {
        if (error.code === 'P0002') {
          return fail(error.message.includes('referrer') ? '推荐人不存在' : '请先创建会员卡种', 400);
        }
        if (error.code === '23505') return fail(uniqueProblem(error.message), 409);
        return fail('保存失败', 400);
      }
      const { data, error: readError } = await admin.from('members').select(MEMBER_SELECT)
        .eq('id', id).eq('store_id', storeId).single();
      return readError ? fail('保存失败', 500) : json({ item: data });
    }
    // 修改资料：手机号、姓名、称呼、生日、备注（来源和推荐人办卡后不再修改）
    const { phone, name, honorific, birthday, note } = values;
    const { data: updated, error } = await admin.from('members')
      .update({ phone, name, honorific, birthday, note, updated_at: new Date().toISOString() })
      .eq('id', input.id).eq('store_id', storeId).is('deleted_at', null)
      .select('id').maybeSingle();
    if (error) return fail(error.code === '23505' ? uniqueProblem(error.message) : '保存失败', error.code === '23505' ? 409 : 400);
    if (!updated) return fail('会员不存在', 404);
    const { data, error: readError } = await admin.from('members').select(MEMBER_SELECT)
      .eq('id', input.id).eq('store_id', storeId).single();
    return readError ? fail('保存失败', 500) : json({ item: data });
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.rpc('delete_member', { p_store: storeId, p_id: input.id });
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('会员不存在', 404);
  }
  return fail('不支持的操作');
}

/** 会员名下的车辆：新增 / 修改 / 删除。 */
export async function handleVehicles(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'save') {
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    if (!uuid(input.member_id)) return fail('会员无效');
    const values = parseVehicle(input);
    if (typeof values === 'string') return fail(values);
    const { data: member } = await admin.from('members').select('id')
      .eq('id', input.member_id).eq('store_id', storeId).is('deleted_at', null).maybeSingle();
    if (!member) return fail('会员不存在', 404);
    const query = input.id == null
      ? admin.from('member_vehicles').insert({ ...values, store_id: storeId, member_id: input.member_id })
      : admin.from('member_vehicles').update(values)
        .eq('id', input.id).eq('store_id', storeId).eq('member_id', input.member_id);
    const { data, error } = await query.select('id, plate, energy, brand_model, color, vin, mileage').maybeSingle();
    if (error) return fail(error.code === '23505' ? uniqueProblem(error.message) : '保存失败', error.code === '23505' ? 409 : 400);
    return data ? json({ item: data }) : fail('车辆不存在', 404);
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.from('member_vehicles').delete()
      .eq('id', input.id).eq('store_id', storeId).select('id').maybeSingle();
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('车辆不存在', 404);
  }
  return fail('不支持的操作');
}
