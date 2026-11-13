import '../pages/members/member_models.dart';
import 'package_calc.dart' show formatMoney;

/// 后端的会员记录 -> 页面里用的 [Member]。
/// 余额和最近到店使用服务端字段。
Member memberFromRow(Map<String, dynamic> row) {
  final vehicles = List<Map<String, dynamic>>.from(
    (row['vehicles'] as List?) ?? const [],
  );
  final card = Map<String, dynamic>.from((row['card'] as Map?) ?? const {});
  return Member(
    '${row['name'] ?? ''}',
    '${card['name'] ?? ''}',
    vehicles.isEmpty ? '未登记车辆' : _plateText('${vehicles.first['plate']}'),
    _lastVisitText(row['last_visit_at']),
    '¥${formatMoney(num.tryParse('${row['balance'] ?? 0}') ?? 0)}',
    '余额',
    const {},
    phone: '${row['phone'] ?? ''}',
    id: row['id']?.toString(),
    data: Map.unmodifiable(row),
  );
}

/// 最近到店：今天到店 / N 天前 / 还没到过店。到店记录来自开单（订单模块接入后才会有）。
String _lastVisitText(Object? at) {
  final t = DateTime.tryParse('${at ?? ''}')?.toLocal();
  if (t == null) return '还没到过店';
  final days = DateTime.now().difference(t).inDays;
  if (days <= 0) return '今天到店';
  if (days < 14) return '$days 天前';
  return '${days ~/ 7} 周前';
}

/// `沪A8K29M` -> `沪A·8K29M`
String _plateText(String plate) =>
    plate.length < 3 ? plate : '${plate.substring(0, 2)}·${plate.substring(2)}';
String plateText(String plate) => _plateText(plate);

/// `1080` -> `1,080.00`
String money2(num v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$intPart.${parts[1]}';
}
