import '../../backend/member_flow.dart' show money2;
import '../../backend/package_calc.dart' show formatMoney;
import 'wallet_controller.dart';

class WalletReceiptView {
  final WalletReceipt receipt;
  const WalletReceiptView(this.receipt);
  // 购买成功页
  Map<String, dynamic> get _s => receipt.data;
  String get soldPaid => '¥${money2(num.tryParse('${_s['price'] ?? 0}') ?? 0)}';
  String get soldName => '${_s['name'] ?? ''}';
  String get soldCount => '${_s['total_count'] ?? 0} 次';
  String get soldExpiry {
    final t = DateTime.tryParse('${_s['expires_at'] ?? ''}')?.toLocal();
    return t == null ? '永久有效' : '至 ${t.year}.${_two(t.month)}.${_two(t.day)}';
  }

  String get soldSaving {
    final off =
        (num.tryParse('${_s['original_price'] ?? 0}') ?? 0) -
        (num.tryParse('${_s['price'] ?? 0}') ?? 0);
    return '−¥${money2(off > 0 ? off : 0)}';
  }

  String get soldSubtitle {
    final at = _s['at'] is DateTime ? _s['at'] as DateTime : DateTime.now();
    final m = '${_s['method'] ?? ''}';
    final pay = m == '微信' || m == '支付宝' ? '$m支付' : m;
    return '${_s['name'] ?? ''} · ${_s['member_name'] ?? ''} · $pay · ${_two(at.hour)}:${_two(at.minute)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  // 结果（成功页）
  Map<String, dynamic> get _r => receipt.data;
  num _n(String k) => num.tryParse('${_r[k] ?? 0}') ?? 0;
  String get doneAmount => '¥${money2(_n('amount'))}';
  String get doneGift => '+¥${money2(_n('gift'))}';
  String get doneTotal => '¥${money2(_n('amount') + _n('gift'))}';
  String get doneBalance => '¥${money2(_n('balance'))}';
  String get donePoints => '+${formatMoney(_n('points_gained'))}';
  String get doneSubtitle {
    final at = _r['at'] is DateTime ? _r['at'] as DateTime : DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final m = '${_r['method'] ?? ''}';
    final pay = m == '微信' || m == '支付宝' ? '$m支付' : m;
    return '${_r['member_name'] ?? ''} · $pay · ${two(at.hour)}:${two(at.minute)}';
  }
}
