import type { SupabaseClient } from 'npm:@supabase/supabase-js@2.118.0';

// stores.owner_id is unique. Multi-store membership, subscription limits and a
// session-scoped active store must be designed together before allowing switching.
export async function storeDirectory(admin: SupabaseClient, owner: string) {
  const { data: store, error } = await admin.from('stores')
    .select('id,name,service_paused').eq('owner_id', owner).maybeSingle();
  if (error) throw new Error('读取门店失败');
  if (!store) throw new Error('门店不存在');
  const stats = await admin.rpc('merchant_home_stats', { p_store: store.id });
  if (stats.error) throw new Error('读取门店营业额失败');
  return {
    current_store_id: store.id,
    items: [{ id: store.id, name: store.name,
      status_label: store.service_paused ? '服务已暂停' : '当前门店',
      revenue: stats.data.revenue }],
    can_add: false,
    add_hint: '当前账号仅支持一家门店',
  };
}
