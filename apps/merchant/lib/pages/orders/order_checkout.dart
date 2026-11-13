import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/hold_store.dart';
import '../../backend/merchant_api.dart';
import '../members/member_events.dart';
import 'order_route_data.dart';

/// 只提交选择并交付本次服务端回执；价格、权限、余额和核销由服务端决定。
class OrderCheckout extends ChangeNotifier {
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  Future<OrderReceipt?> pay({
    Map<String, dynamic>? member,
    required List<Map<String, dynamic>> lines,
    required String method,
    num? balancePart,
    String? other,
    String plate = '',
    String? holdId,
    String? appointmentId,
  }) async {
    if (busy || disposed) return null;
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (lines.isEmpty) throw const AppError('请先选择服务项目');
    final snapshot = member == null
        ? null
        : Map<String, dynamic>.unmodifiable(member);
    final items = List<Map<String, dynamic>>.unmodifiable(
      lines.map((row) => Map<String, dynamic>.unmodifiable(row)),
    );
    final intent = jsonEncode({
      'member': snapshot?['id'],
      'lines': items,
      'method': method,
      'balance': balancePart,
      'other': other,
      'plate': plate,
      'hold': holdId,
      'appointment': appointmentId,
    });
    if (_intent != intent) {
      _intent = intent;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      final Map<String, dynamic> result;
      if (appointmentId != null) {
        result = await merchantApi.checkoutAppointment({
          'id': appointmentId,
          'lines': items,
          'method': method,
          'balance_part': balancePart,
          'other': other,
          'plate': plate,
        }, requestId: _requestId);
      } else if (snapshot == null) {
        result = await merchantApi.checkoutWalkIn(
          lines: items,
          method: method,
          plate: plate,
          holdId: holdId,
          requestId: _requestId,
        );
      } else {
        result = await merchantApi.checkout(
          memberId: '${snapshot['id']}',
          lines: items,
          method: method,
          balancePart: balancePart,
          other: other,
          plate: plate,
          holdId: holdId,
          requestId: _requestId,
        );
      }
      _intent = null;
      _requestId = null;
      memberChanged.value++;
      if (appointmentId != null) AppointmentFlow.notify();
      if (holdId != null) HoldStore.recordRemoved(holdId);
      return OrderReceipt({
        ...result,
        'member_name': snapshot?['name'] ?? '散客',
        'plate': plate,
        'at': DateTime.now(),
      });
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
