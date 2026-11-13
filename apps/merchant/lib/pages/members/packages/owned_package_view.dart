import '../../../backend/package_calc.dart' show formatMoney;
import '../member_view.dart';

class OwnedPackageView {
  final Map<String, dynamic> _p, member;
  final int extendDays;
  const OwnedPackageView(this._p, {required this.member, this.extendDays = 30});
  num _n(String k) => num.tryParse('${_p[k] ?? 0}') ?? 0;
  int get total => _n('total_count').toInt();
  int get used => _n('used_count').toInt();
  int get remaining => total - used;
  num get paid => _n('price_paid');
  String get name => '${_p['name'] ?? ''}';
  DateTime? get _exp =>
      DateTime.tryParse('${_p['expires_at'] ?? ''}')?.toLocal();
  bool get refunded => _p['refunded_at'] != null;
  bool get expired => _exp != null && _exp!.isBefore(DateTime.now());

  String get status => refunded
      ? '已退款'
      : used >= total
      ? '已用完'
      : expired
      ? '已过期'
      : '使用中';

  static String _d(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';

  String get expiresAt => _exp == null ? '永久有效' : _d(_exp!);
  String get purchasedAt {
    final t = DateTime.tryParse('${_p['purchased_at'] ?? ''}')?.toLocal();
    return t == null ? '' : _d(t);
  }

  String get expiryNote {
    if (refunded) return '已退款';
    final e = _exp;
    if (e == null) return '永久有效';
    final days = e.difference(DateTime.now()).inDays;
    return days < 0 ? '已过期' : (days == 0 ? '今天到期' : '$days 天后到期');
  }

  String get owner =>
      '${_p['member']?['name'] ?? member['name'] ?? ''} · ${MemberView(member).levelMember}';
  String get paidText => '¥${formatMoney(paid)}';
  double get ringFraction =>
      total == 0 ? 0 : (remaining / total).clamp(0, 1).toDouble();

  // 延期
  String get extendSubtitle => '$name · 当前到期日 $expiresAt';
  String get extendedExpiry {
    final base = _exp == null || _exp!.isBefore(DateTime.now())
        ? DateTime.now()
        : _exp!;
    return _d(base.add(Duration(days: extendDays)));
  }
}
