import type { SupabaseClient } from 'npm:@supabase/supabase-js@2.118.0';

// Match the destination lists, including inactive technicians/services but
// excluding deleted card types. Exact HEAD counts avoid the REST row limit.
export async function settingsCounts(admin: SupabaseClient, storeId: string) {
  const [staff, services, cards] = await Promise.all([
    admin.from('appointment_resources').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId).eq('kind', 'technician'),
    admin.from('service_items').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId),
    admin.from('card_types').select('id', { count: 'exact', head: true })
      .eq('store_id', storeId).eq('active', true),
  ]);
  if (staff.error || services.error || cards.error) throw new Error('读取门店数量失败');
  return { staff: staff.count, services: services.count, cards: cards.count };
}
