import { admin, fail, json, nameOf, uuid } from './shared.ts';
import type { CardTypeRow, Input } from './types.ts';

export async function handleCards(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const { data, error } = await admin.from('card_types').select('*')
      .eq('store_id', storeId).eq('active', true)
      .order('created_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data as CardTypeRow[] });
  }
  if (input.action === 'save') {
    const name = nameOf(input.name);
    const discount = Number(input.discount);
    if (!name || name.length > 100) return fail('名称长度须为 1–100 字');
    if (!Number.isFinite(discount) || discount <= 0 || discount > 1) return fail('折扣系数无效');
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const values = { name, discount, description: nameOf(input.description) };
    const query = input.id == null
      ? admin.from('card_types').insert({ ...values, store_id: storeId })
      : admin.from('card_types').update(values).eq('id', input.id).eq('store_id', storeId);
    const { data, error } = await query.select('*').single();
    return error ? fail('保存失败', 400) : json({ item: data as CardTypeRow });
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    // Existing UI says "停用此卡种"; soft-delete to preserve future member history.
    const { data, error } = await admin.from('card_types').update({ active: false })
      .eq('id', input.id).eq('store_id', storeId).eq('active', true)
      .select('id').maybeSingle();
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('记录不存在', 404);
  }
  return fail('不支持的操作');
}
