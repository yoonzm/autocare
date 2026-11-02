import { admin, fail, json, nameOf, uuid } from './shared.ts';
import type { Input, ServiceItemRow } from './types.ts';

export async function handleServices(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const { data, error } = await admin.from('service_items').select('*')
      .eq('store_id', storeId).order('created_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data as ServiceItemRow[] });
  }
  if (input.action === 'save') {
    const name = nameOf(input.name);
    const price = Number(input.price);
    if (!name || name.length > 100) return fail('名称长度须为 1–100 字');
    if (!Number.isFinite(price) || price < 0 || price > 99999999.99) return fail('价格无效');
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const values = {
      name, price, category: nameOf(input.category) || '其他',
      description: nameOf(input.description),
    };
    const query = input.id == null
      ? admin.from('service_items').insert({ ...values, store_id: storeId })
      : admin.from('service_items').update(values).eq('id', input.id).eq('store_id', storeId);
    const { data, error } = await query.select('*').single();
    return error ? fail('保存失败', 400) : json({ item: data as ServiceItemRow });
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
