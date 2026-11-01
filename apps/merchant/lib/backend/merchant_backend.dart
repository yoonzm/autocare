import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://wghsytekrmpcofpugyua.supabase.co',
);
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_tc78tqPIqF7dPAkA5oRiMg_KlE4UT2y',
);

class MerchantBackend {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<String> storeId() async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('请先登录');
    final row = await client
        .from('stores')
        .select('id')
        .eq('owner_id', user.id)
        .single();
    return row['id'] as String;
  }

  static Future<List<Map<String, dynamic>>> list(String table) async {
    final id = await storeId();
    final rows = await client
        .from(table)
        .select()
        .eq('store_id', id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> save(
    String table,
    Map<String, dynamic> values, {
    String? id,
  }) async {
    final store = await storeId();
    if (id == null) {
      await client.from(table).insert({...values, 'store_id': store});
    } else {
      await client
          .from(table)
          .update(values)
          .eq('id', id)
          .eq('store_id', store);
    }
  }

  static Future<void> delete(String table, String id) async {
    final store = await storeId();
    await client.from(table).delete().eq('id', id).eq('store_id', store);
  }
}
