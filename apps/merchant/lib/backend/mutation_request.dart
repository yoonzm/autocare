import 'dart:convert';

import 'data_snapshot.dart';
import 'merchant_api.dart';

/// One caller-owned write intent. A repeated body keeps its request identifier.
/// Whether replay is safe is still enforced by the specific backend transaction.
class MutationRequest {
  String? _intent, _id;
  Future<Map<String, dynamic>> send(Map<String, dynamic> body) {
    final snapshot = dataSnapshot(body);
    final intent = jsonEncode(snapshot);
    if (intent != _intent) {
      _intent = intent;
      _id = MerchantApi.newRequestId();
    }
    return merchantApi.invoke(snapshot, requestId: _id);
  }
}
