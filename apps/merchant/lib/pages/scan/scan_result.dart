import '../../backend/member_flow.dart' show plateText;
import '../../backend/data_snapshot.dart';

class ScanResult {
  final Map<String, dynamic> data;
  ScanResult(Map<String, dynamic> data) : data = dataSnapshot(data);
  bool get matched => data['matched'] == true;
  Map<String, dynamic>? get member {
    if (!matched || data['member'] is! Map) return null;
    final row = Map<String, dynamic>.from(data['member'] as Map);
    final vehicles = List<Map<String, dynamic>>.from(
      (row['vehicles'] as List?) ?? const [],
    );
    final selected = vehicles.indexWhere((v) => v['plate'] == rawPlate);
    if (selected > 0) vehicles.insert(0, vehicles.removeAt(selected));
    // Existing member/order adapters display the first vehicle. Prefer the
    // scanned vehicle without changing the database or the original response.
    row['vehicles'] = vehicles;
    return row;
  }

  /// 识别出的车牌（不带分隔点，如 `沪A8K29M`）。
  String get rawPlate => '${data['plate'] ?? ''}';

  Map<String, dynamic> get vehicle => {
    'plate': rawPlate,
    'brand_model': data['vehicle_model'],
    'color': data['vehicle_color'],
  };
}

class ScanView {
  final ScanResult result;
  const ScanView(this.result);
  String get plate => rawPlatePretty;
  String get rawPlatePretty => plateText(result.rawPlate);

  String get plateKind => switch (result.data['plate_color']) {
    'blue' => '蓝牌',
    'green' => '绿牌（新能源）',
    'yellow' => '黄牌',
    'white' => '白牌',
    'black' => '黑牌',
    _ => '—',
  };

  Map<String, dynamic>? get _vehicle {
    final vs = List<Map<String, dynamic>>.from(
      (result.member?['vehicles'] as List?) ?? const [],
    );
    for (final v in vs) {
      if ('${v['plate']}' == result.rawPlate) return v;
    }
    return null;
  }

  String get vehicleModel {
    final v = _vehicle;
    if (v == null) return '未登记车型';
    final parts = [
      for (final k in ['brand_model', 'color'])
        if ('${v[k] ?? ''}'.isNotEmpty) '${v[k]}',
    ];
    return parts.isEmpty ? '未登记车型' : parts.join(' · ');
  }

  String get packageSummary => '${result.data['package_summary'] ?? '无次卡'}';
  String get lastVisit => '${result.data['last_visit_text'] ?? '还没到过店'}';
}
