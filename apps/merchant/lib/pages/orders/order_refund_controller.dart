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

  // 支付 label 是现有 order_detail 的明确协议值。未知方式不能默认为可退。
  static String destination(Object? label) => switch (label) {
    '储值余额' => '退回储值余额',
    '现金支付' => '现金交还',
    '次卡抵扣' => '退回次卡次数',
    _ => '原路退款渠道尚未接通',
  };

  Future<bool> submit(String reason) async {
    if (busy || disposed) return false;
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (order['kind'] != 'consume' || order['can_refund'] != true) {
      throw const AppError('这笔订单不能退款');
    }
    final payments = order['payments'] as List? ?? const [];
    // TODO: order_refund 目前只做记账，没有微信/支付宝等原路退款渠道闭环。
    // 不调用该记账接口冒充实际到账；支付渠道接通后再启用对应方式。
    const supported = ['储值余额', '现金支付', '次卡抵扣'];
    if ((payments.isEmpty && (order['amount'] as num? ?? 0) > 0) ||
        payments.any((e) => !supported.contains((e as Map)['label']))) {
      throw const AppError('原路退款渠道尚未接通，未发起退款');
    }
    final intent = '${order['id']}:$reason';
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
