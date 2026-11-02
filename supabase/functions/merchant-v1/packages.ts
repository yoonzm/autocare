import { admin, fail, json, uuid } from './shared.ts';
import { parsePackage } from './package_rules.ts';
import type { Input, PackageRow } from './types.ts';

// A package with its services and their current name / price (used for the list and the preview).
const SELECT =
  '*, items:card_package_items(service_id, count, position, service:service_items(name, price, active))';

export async function handlePackages(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const { data, error } = await admin.from('card_packages').select(SELECT)
      .eq('store_id', storeId).is('deleted_at', null)
      .order('created_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data as unknown as PackageRow[] });
  }
  if (input.action === 'save') {
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const parsed = parsePackage(input);
    if (typeof parsed === 'string') return fail(parsed);
    const { data: id, error } = await admin.rpc('save_card_package', {
      p_store: storeId, p_id: input.id ?? null, p_values: parsed.values, p_items: parsed.items,
    });
    if (error) {
      if (error.code === 'P0002') {
        return fail(error.message.includes('service_not_found') ? '包含的服务不存在' : '套餐不存在', 404);
      }
      return fail('保存失败', 400);
    }
    const { data, error: readError } = await admin.from('card_packages').select(SELECT)
      .eq('id', id).eq('store_id', storeId).single();
    return readError ? fail('保存失败', 500) : json({ item: data as unknown as PackageRow });
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    // Soft delete: packages that were already sold must keep their definition.
    const { data, error } = await admin.from('card_packages')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', input.id).eq('store_id', storeId).is('deleted_at', null)
      .select('id').maybeSingle();
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('记录不存在', 404);
  }
  return fail('不支持的操作');
}
