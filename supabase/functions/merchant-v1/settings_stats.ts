import type { SupabaseClient } from 'npm:@supabase/supabase-js@2.118.0';

// Match the destination lists: staff = 员工与权限 page (store_staff that are not disabled, the owner is
// not a row there); services include inactive ones; deleted card types are excluded.
// Exact HEAD counts avoid the REST row limit.
export async function settingsCounts(admin: SupabaseClient, storeId: string) {
  const [staff, services, cards] = await Promise.all([
    admin.from('store_staff').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId).neq('status', 'disabled'),
    admin.from('service_items').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId),
    admin.from('card_types').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId).eq('active', true),
  ]);
  if (staff.error || services.error || cards.error) throw new Error('读取门店数量失败');
  return { staff: staff.count, services: services.count, cards: cards.count };
}
