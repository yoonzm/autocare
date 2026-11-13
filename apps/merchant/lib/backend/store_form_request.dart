import 'dart:convert';

import 'merchant_api.dart';

/// 单份门店表单的提交器；仅在本实例内为内容相同的失败重试复用请求编号。
class StoreFormRequest {
  final String? storeId;
  final MerchantApi api;
  String? _body, _requestId;
  StoreFormRequest.update({required this.storeId, MerchantApi? api})
    : api = api ?? merchantApi;
  Future<void> save({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (name.trim().isEmpty || address.trim().isEmpty) {
      throw const AppError('请填写门店名称和地址');
    }
    if (storeId == null || storeId!.isEmpty) {
      throw const AppError('请先选择要编辑的门店');
    }
    final values = <String, dynamic>{
      'id': storeId,
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
    };
    final body = jsonEncode(values);
    if (_body != body) {
      _body = body;
      _requestId = MerchantApi.newRequestId();
    }
    await api.storeMutation('update', values, requestId: _requestId);
    _body = _requestId = null;
  }
}
