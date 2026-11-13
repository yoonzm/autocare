import '../../backend/member_flow.dart' show money2;
import '../../backend/package_calc.dart' show formatMoney;
import 'order_route_data.dart';

class OrderReceiptView {
  final OrderReceipt receipt;
  const OrderReceiptView(this.receipt);
  Map<String, dynamic> get _o => receipt.data;
  num _n(String k) => num.tryParse('${_o[k] ?? 0}') ?? 0;

  String get payable => '¥${money2(_n('payable'))}';
  String get balancePaid => '¥${money2(_n('balance_paid'))}';
  // 散客没有储值余额和积分
  String get balance =>
      _o['balance'] == null ? '—' : '¥${money2(_n('balance'))}';
  String get points =>
      _o['balance'] == null ? '—' : '+${formatMoney(_n('points_gained'))}';
  String get items => '${_o['items'] ?? ''}';

  String get _payText {
    final m = '${_o['pay_method'] ?? ''}';
    return switch (m) {
      '会员余额' => '储值支付',
      '微信' || '支付宝' => '$m支付',
      _ => m,
    };
  }

  String get subtitle {
    final at = _o['at'] is DateTime ? _o['at'] as DateTime : DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final plate = '${_o['plate'] ?? ''}';
    return [
      if (plate.isNotEmpty && plate != '未登记车辆') plate,
      '${_o['member_name'] ?? ''}',
      _payText,
      '${two(at.hour)}:${two(at.minute)}',
    ].join(' · ');
  }

  /// `黑金卡 9 折 −¥158.00`；有次卡抵扣时在前面加上 `次卡抵扣 −¥68.00`。
  String get discountLine {
    final parts = <String>[];
    final card = _n('card_off');
    final off = _n('discount_off');
    if (card > 0) parts.add('次卡抵扣 −¥${money2(card)}');
    if (off > 0) {
      final d = _n('discount') * 10;
      final n = d == d.roundToDouble()
          ? d.round().toString()
          : d.toStringAsFixed(1);
      parts.add('${_o['card_name'] ?? ''} $n 折 −¥${money2(off)}');
    }
    return parts.isEmpty ? '无优惠' : parts.join(' · ');
  }
}
