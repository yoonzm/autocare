import '../../backend/member_flow.dart' show money2, plateText;
import '../../backend/package_calc.dart' show formatMoney;

String _number(num value) =>
    value == value.roundToDouble() ? '${value.round()}' : '$value';

class MemberView {
  final Map<String, dynamic> row;
  const MemberView(this.row);

  Map<String, dynamic> get _card =>
      Map<String, dynamic>.from((row['card'] as Map?) ?? const {});
  List<Map<String, dynamic>> get _vehicles =>
      List<Map<String, dynamic>>.from((row['vehicles'] as List?) ?? const []);

  String get name => '${row['name'] ?? ''}';

  /// 头像上的字：姓氏。
  String get avatar => name.isEmpty ? '' : name.substring(0, 1);

  /// `李女士` / `王先生`；没填称呼时就是全名。
  String get honorificName {
    final h = '${row['honorific'] ?? ''}';
    return h.isEmpty ? name : '$avatar$h';
  }

  String get level => '${_card['name'] ?? ''}';

  /// `黑金卡会员` / `普通会员`（卡种名已带“会员”时不再重复）。
  String get levelMember => level.endsWith('会员') ? level : '$level会员';

  String get maskedPhone {
    final p = '${row['phone'] ?? ''}';
    return p.length == 11 ? '${p.substring(0, 3)} **** ${p.substring(7)}' : p;
  }

  /// `服务原价 · 积分 1 倍` / `服务 9 折 · 积分 2 倍`
  String get benefits {
    final d = num.tryParse('${_card['discount'] ?? 1}') ?? 1;
    final m = num.tryParse('${_card['points_multiplier'] ?? 1}') ?? 1;
    final discount = d >= 1 ? '服务原价' : '服务 ${_number(d * 10)} 折';
    return '$discount · 积分 ${_number(m)} 倍';
  }

  /// `11月1日 12:02`
  String get openedAt {
    final t = DateTime.tryParse('${row['created_at'] ?? ''}')?.toLocal();
    if (t == null) return '';
    return '${t.month}月${t.day}日 ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  num _num(String k) => num.tryParse('${row[k] ?? 0}') ?? 0;

  /// `¥3,680.00`
  String get balanceText => '¥${money2(_num('balance'))}';
  String get pointsText => formatMoney(_num('points'));
  String get totalSpentText => '¥${formatMoney(_num('total_spent'))}';
  String get totalRechargedText => '¥${formatMoney(_num('total_recharged'))}';
  String get visitText => '${_num('visit_count').toInt()} 次';

  String get plate =>
      _vehicles.isEmpty ? '未登记车辆' : plateText('${_vehicles.first['plate']}');
  String get vehicleModel {
    if (_vehicles.isEmpty) return '可在会员详情里添加';
    final m = '${_vehicles.first['brand_model'] ?? ''}';
    return m.isEmpty ? '未填写车型' : m;
  }

  String get vehicleLabel => _vehicles.isEmpty ? '' : '已登记车辆';
}
