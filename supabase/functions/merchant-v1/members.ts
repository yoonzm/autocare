import { admin, fail, json, mockRecognitionEnabled, uuid } from './shared.ts';
import { lastVisitText, packageSummary, randomPlateNotIn, wantsExisting } from './recognize_rules.ts';
import {
  parseAdjust,
  parseMember,
  parseRecharge,
  parseVehicle,
  RECHARGE_PRESETS,
} from './member_rules.ts';
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

/** 经办人：门店联系人和身份，如“陈明（店长）”。 */
export async function operatorOf(storeId: string): Promise<string> {
  const { data } = await admin.from('stores').select('contact_name, contact_role').eq('id', storeId).single();
  const name = String(data?.contact_name ?? '').trim();
  const role = String(data?.contact_role ?? '').trim();
  return name ? (role ? `${name}（${role}）` : name) : '店主';
}

export async function handleMembers(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const limit = Math.min(Math.max(Number(input.limit) || 50, 1), MAX_LIST);
    const offset = Math.max(Number(input.offset) || 0, 0);
    let query = admin.from('members').select(MEMBER_SELECT, { count: 'exact' })
      .eq('store_id', storeId).is('deleted_at', null)
      // sort = recent：最近有充值 / 消费 / 购买变动的在前（“选择会员”里的最近使用）
      .order(input.sort === 'recent' ? 'updated_at' : 'created_at', { ascending: false })
      .range(offset, offset + limit - 1);
    if (input.card_type_id != null) {
      if (!uuid(input.card_type_id)) return fail('卡种无效');
      query = query.eq('card_type_id', input.card_type_id);
    }
    if (Array.isArray(input.card_type_ids) && input.card_type_ids.length) {
      if (!input.card_type_ids.every(uuid)) return fail('卡种无效');
      query = query.in('card_type_id', input.card_type_ids as string[]);
    }
    // 储值余额区间
    const min = input.balance_min == null ? null : Number(input.balance_min);
    const max = input.balance_max == null ? null : Number(input.balance_max);
    if ((min != null && !Number.isFinite(min)) || (max != null && !Number.isFinite(max))) return fail('余额范围无效');
    if (min != null) query = query.gte('balance', min);
    if (max != null) query = query.lt('balance', max);
    // 最近到店：N 天内 / 超过 N 天（没到过店的算超过）
    const within = input.visited_within_days == null ? null : Number(input.visited_within_days);
    const over = input.visited_over_days == null ? null : Number(input.visited_over_days);
    if ((within != null && !(within > 0)) || (over != null && !(over > 0))) return fail('到店时间范围无效');
    if (within != null) query = query.gte('last_visit_at', new Date(Date.now() - within * 86400000).toISOString());
    if (over != null) {
      query = query.or(`last_visit_at.is.null,last_visit_at.lt.${new Date(Date.now() - over * 86400000).toISOString()}`);
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
    const { data, error, count: matched } = await query;
    if (error) return fail('读取失败', 500);
    // 各卡种的会员数、总数、储值余额合计、本月新增（不受搜索和筛选影响）
    const { data: all } = await admin.from('members').select('card_type_id, balance, created_at')
      .eq('store_id', storeId).is('deleted_at', null).limit(100000);
    const counts: Record<string, number> = {};
    let totalBalance = 0;
    let newThisMonth = 0;
    const monthStart = new Date();
    monthStart.setUTCDate(1);
    monthStart.setUTCHours(0, 0, 0, 0);
    // 以东八区的月初为准
    const cnMonthStart = new Date(Date.UTC(monthStart.getUTCFullYear(), monthStart.getUTCMonth(), 1) - 8 * 3600000);
    for (const r of all ?? []) {
      counts[r.card_type_id as string] = (counts[r.card_type_id as string] ?? 0) + 1;
      totalBalance += Number(r.balance);
      if (new Date(r.created_at as string) >= cnMonthStart) newThisMonth++;
    }
    return json({
      items: data ?? [], counts, total: all?.length ?? 0, matched: matched ?? 0,
      total_balance: Math.round(totalBalance * 100) / 100, new_this_month: newThisMonth,
    });
  }
  if (input.action === 'recognize_plate') {
    // TODO: 真实的车牌识别要接图片识别服务：客户端先把照片上传到存储，这里按存储路径识别。
    // 目前只有开发环境的 mock（不看照片）：50% 概率随机取一位已有会员的车牌，否则随机生成一个库里没有的车牌。
    if (!mockRecognitionEnabled()) return fail('车牌识别服务尚未启用', 501);
    const { data: vehicles } = await admin.from('member_vehicles').select('plate, member_id')
      .eq('store_id', storeId).limit(1000);
    const all = vehicles ?? [];
    if (wantsExisting() && all.length > 0) {
      for (let tries = 0; tries < 5; tries++) {
        const v = all[Math.floor(Math.random() * all.length)];
        const { data: member } = await admin.from('members').select(MEMBER_SELECT)
          .eq('id', v.member_id).eq('store_id', storeId).is('deleted_at', null).maybeSingle();
        if (!member) continue;
        const { data: pkgs } = await admin.from('member_packages')
          .select('name, expires_at, items:member_package_items(total, used)')
          .eq('store_id', storeId).eq('member_id', member.id).is('refunded_at', null);
        const live = (pkgs ?? []).filter((p) => !p.expires_at || new Date(p.expires_at as string) > new Date());
        const { data: last } = await admin.from('orders')
          .select('created_at, items:order_items(name, position)')
          .eq('store_id', storeId).eq('member_id', member.id)
          .order('created_at', { ascending: false }).limit(1).maybeSingle();
        const firstItem = [...((last?.items as { name: string; position: number }[] | undefined) ?? [])]
          .sort((a, b) => a.position - b.position)[0]?.name ?? '';
        return json({
          matched: true, mock: true, plate: v.plate, member,
          package_summary: packageSummary(live.map((p) => ({
            name: String(p.name),
            left: ((p.items as { total: number; used: number }[]) ?? []).reduce((s, i) => s + i.total - i.used, 0),
          }))),
          last_visit_text: lastVisitText((member.last_visit_at as string | null) ?? null, firstItem),
        });
      }
    }
    return json({ matched: false, mock: true, plate: randomPlateNotIn(new Set(all.map((v) => String(v.plate)))) });
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
  if (input.action === 'recharge_options') {
    return json({ items: RECHARGE_PRESETS.map((p) => ({ ...p })) });
  }
  if (input.action === 'recharge') {
    if (!uuid(input.id)) return fail('会员无效');
    const values = parseRecharge(input);
    if (typeof values === 'string') return fail(values);
    const { data, error } = await admin.rpc('recharge_member', {
      p_store: storeId, p_member: input.id, p_amount: values.amount, p_gift: values.gift,
      p_method: values.method, p_operator: await operatorOf(storeId), p_note: values.note,
      p_request: typeof input.__request === 'string' ? input.__request : null,
    });
    if (error) {
      if (error.code === 'P0002') return fail('会员不存在', 404);
      return fail('充值失败', 400);
    }
    return json({ item: data });
  }
  if (input.action === 'adjust') {
    if (!uuid(input.id)) return fail('会员无效');
    const values = parseAdjust(input);
    if (typeof values === 'string') return fail(values);
    const { data, error } = await admin.rpc('adjust_member', {
      p_store: storeId, p_member: input.id, p_tier: values.tier_id, p_points: values.points,
      p_reason: values.reason, p_note: values.note, p_operator: await operatorOf(storeId),
    });
    if (error) {
      if (error.code === 'P0001') return fail('积分不足，不能扣减这么多', 400);
      if (error.code === 'P0002') {
        return fail(error.message.includes('tier') ? '卡种不存在' : '会员不存在', 404);
      }
      return fail('调整失败', 400);
    }
    return json({ item: data });
  }
  if (input.action === 'ledger') {
    if (!uuid(input.id)) return fail('会员无效');
    const limit = Math.min(Math.max(Number(input.limit) || 30, 1), 100);
    const offset = Math.max(Number(input.offset) || 0, 0);
    let query = admin.from('member_ledger').select('*', { count: 'exact' })
      .eq('store_id', storeId).eq('member_id', input.id)
      .order('created_at', { ascending: false }).range(offset, offset + limit - 1);
    if (input.filter === 'recharge') query = query.eq('kind', 'recharge');
    const { data, error, count } = await query;
    return error ? fail('读取失败', 500) : json({ items: data ?? [], total: count ?? 0 });
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
