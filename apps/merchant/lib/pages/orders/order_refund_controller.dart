import 'package:flutter/foundation.dart';

import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../members/member_events.dart';

class OrderRefundController extends ChangeNotifier {
  final Map<String, dynamic> order;
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  OrderRefundController(Map<String, dynamic> order)
    : order = dataSnapshot(order);

  // 支付 label 是现有 order_detail 的明确协议值。
  static String destination(Object? label) => switch (label) {
    '储值余额' => '退回储值余额',
    '现金支付' => '现金交还',
    '次卡抵扣' => '退回次卡次数',
    _ => '原路退回',
  };

  num get refundable {
    final raw = order['refundable_amount'];
    if (raw is num) return raw < 0 ? 0 : raw;
    final total = order['amount'] as num? ?? 0;
    final refunded = order['refunded_amount'] as num? ?? 0;
    return (total - refunded) < 0 ? 0 : (total - refunded);
  }

  Future<bool> submit(String reason, {num? amount}) async {
    if (busy || disposed) return false;
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (order['kind'] != 'consume' || order['can_refund'] != true) {
      throw const AppError('这笔订单不能退款');
    }
    if (amount != null) {
      if (amount <= 0 || amount > refundable) {
        throw const AppError('退款金额须大于 0 且不超过可退金额');
      }
    }
    final intent = '${order['id']}:$reason:${amount ?? 'full'}';
    if (_intent != intent) {
      _intent = intent;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      await merchantApi.refundOrder(
        '${order['id']}',
        reason,
        amount: amount != null && amount < refundable ? amount : null,
        requestId: _requestId,
      );
      memberChanged.value++;
      return true;
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
