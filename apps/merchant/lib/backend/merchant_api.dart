import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://wghsytekrmpcofpugyua.supabase.co',
);
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_tc78tqPIqF7dPAkA5oRiMg_KlE4UT2y',
);

/// Only calls the V1 cloud function. Business tables are never written here.
class MerchantApi {
  SupabaseClient get client => Supabase.instance.client;

  bool get hasSession {
    try {
      return client.auth.currentSession != null;
    } catch (_) {
      return false; // Widget tests may construct the app without main().
    }
  }

  Future<Map<String, dynamic>> invoke(Map<String, dynamic> body) async {
    final response = await client.functions.invoke('merchant-v1', body: body);
    final data = Map<String, dynamic>.from(response.data as Map);
    if (response.status < 200 ||
        response.status >= 300 ||
        data['error'] != null) {
      throw StateError(data['error']?.toString() ?? '后端请求失败');
    }
    return data;
  }

  Future<String> sendMockCode(String phone) async {
    final data = await invoke({'action': 'send_mock_code', 'phone': phone});
    return data['code'] as String;
  }

  Future<void> register({
    required String phone,
    required String code,
    required String password,
    required String storeName,
  }) async {
    await invoke({
      'action': 'register',
      'phone': phone,
      'code': code,
      'password': password,
      'store_name': storeName,
    });
  }

  Future<void> loginPassword(String phone, String password) async {
    final data = await invoke({
      'action': 'login_password',
      'phone': phone,
      'password': password,
    });
    await client.auth.setSession(
      data['refresh_token'] as String,
      accessToken: data['access_token'] as String,
    );
  }

  Future<void> signOut() => client.auth.signOut();

  Future<List<Map<String, dynamic>>> list(String kind) async {
    final data = await invoke({'action': 'list', 'kind': kind});
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  Future<Map<String, dynamic>> save(String kind, Map<String, dynamic> values) =>
      invoke({'action': 'save', 'kind': kind, ...values});

  Future<void> delete(String kind, String id) async {
    await invoke({'action': 'delete', 'kind': kind, 'id': id});
  }
}

MerchantApi merchantApi = MerchantApi();
