import { admin, fail, json, nameOf, uuid } from './shared.ts';
import { consumableError, parseConsumables } from './service_rules.ts';
import { parseServiceCommission } from './staff_rules.ts';
import type { Input, ServiceItemRow } from './types.ts';

export async function handleServices(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const { data, error } = await admin.from('service_items').select('*')
      .eq('store_id', storeId).order('created_at', { ascending: false });
    if (error) return fail('读取失败', 500);
    // 每个服务绑定的耗材（库存商品 + 用量），带上当前库存和安全库存，页面据此显示「偏低」。
    const bound = await admin.from('service_consumables')
      .select('service_id, product_id, quantity, inventory_products(name, unit, stock, safe, active, allow_decimal)')
      .eq('store_id', storeId);
    if (bound.error) return fail('读取失败', 500);
    const byService = new Map<string, unknown[]>();
    for (const row of (bound.data ?? []) as Array<Record<string, unknown>>) {
      const list = byService.get(String(row.service_id)) ?? [];
      list.push({ product_id: row.product_id, quantity: Number(row.quantity), ...(row.inventory_products as object) });
      byService.set(String(row.service_id), list);
    }
    const items = (data as ServiceItemRow[]).map((s) => ({ ...s, consumables: byService.get(s.id) ?? [] }));
    return json({ items });
  }
  if (input.action === 'save') {
    const name = nameOf(input.name);
    const price = Number(input.price);
    if (!name || name.length > 100) return fail('名称长度须为 1–100 字');
    if (!Number.isFinite(price) || price < 0 || price > 99999999.99) return fail('价格无效');
    const duration = input.duration_minutes == null ? null : Number(input.duration_minutes);
    if (duration != null && (!Number.isInteger(duration) || duration < 15 || duration > 720)) return fail('标准工时须为 15–720 分钟');
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const commission = parseServiceCommission(input);
    if (typeof commission === 'string') return fail(commission);
    if (input.active != null && typeof input.active !== 'boolean') return fail('上架状态无效');
    const consumables = parseConsumables(input.consumables);
    if (typeof consumables === 'string') return fail(consumables);
    const values = {
      name, price, category: nameOf(input.category) || '其他',
      description: nameOf(input.description),
      ...(duration == null ? {} : { duration_minutes: duration }),
      ...commission,
      ...(typeof input.active === 'boolean' ? { active: input.active } : {}),
    };
    const query = input.id == null
      ? admin.from('service_items').insert({ ...values, store_id: storeId })
      : admin.from('service_items').update(values).eq('id', input.id).eq('store_id', storeId);
    const { data, error } = await query.select('*').single();
    if (error) return fail('保存失败', 400);
    const item = data as ServiceItemRow;
    if (consumables !== undefined) {
      const saved = await admin.rpc('save_service_consumables', {
        p_store: storeId, p_service: item.id, p_items: consumables,
      });
      if (saved.error) {
        // 新建的服务耗材保存失败时撤销，避免重试产生重复服务。
        if (input.id == null) await admin.from('service_items').delete().eq('id', item.id).eq('store_id', storeId);
        return fail(consumableError(saved.error.message), 400);
      }
    }
    return json({ item });
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.from('service_items').delete()
      .eq('id', input.id).eq('store_id', storeId).select('id').maybeSingle();
    // 23503: a package still includes this service
    if (error?.code === '23503') return fail('该服务项目已被次卡套餐使用，请先从套餐中移除', 409);
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('记录不存在', 404);
  }
  return fail('不支持的操作');
}
