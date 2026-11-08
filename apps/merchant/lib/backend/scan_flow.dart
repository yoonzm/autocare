import 'merchant_api.dart';
import 'member_flow.dart' show plateText;

import 'package:flutter/foundation.dart' show ValueNotifier;

/// 扫码找会员（车牌识别）的结果，以及从“没找到会员”继续办卡 / 散客开单时要带过去的信息。
///
/// 识别和按本店车辆匹配会员由云函数 `recognize_plate` 完成。
class ScanFlow {
  ScanFlow._();

  /// 最近一次识别的结果：`matched`、`plate`，匹配时还有 `member`、`package_summary`、`last_visit_text`。
  static Map<String, dynamic>? last;

  static String? _prefillPlate;
  static String? _prefillModel;
  static String? _prefillColor;
  static bool _walkIn = false;
  static void resetStore() {
    last = null;
    _prefillPlate = null;
    _prefillModel = null;
    _prefillColor = null;
    _walkIn = false;
  }

  /// Rebind an already-open member form after returning from its scanner.
  static final prefillTick = ValueNotifier(0);

  static Future<Map<String, dynamic>> recognize(String imagePath) =>
      merchantApi.recognizePlate(imagePath);

  static bool get matched => last?['matched'] == true;
  static Map<String, dynamic>? get member {
    if (last?['member'] is! Map) return null;
    final row = Map<String, dynamic>.from(last!['member'] as Map);
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
  static String get rawPlate => '${last?['plate'] ?? ''}';

  /// “创建会员”：办卡页的车牌从识别结果带入（只用一次）。
  static void prefillPlateForAdd() {
    _prefillPlate = rawPlate;
    _prefillModel = '${last?['vehicle_model'] ?? ''}';
    _prefillColor = '${last?['vehicle_color'] ?? ''}';
  }

  static String? takePrefillColor() {
    final color = _prefillColor;
    _prefillColor = null;
    return color;
  }

  static String? takePrefillModel() {
    final model = _prefillModel;
    _prefillModel = null;
    return model;
  }

  static String? takePrefillPlate() {
    final p = _prefillPlate;
    _prefillPlate = null;
    return p;
  }

  /// “散客结账”：开单页直接进入散客状态（只用一次）。
  static void startWalkInOrder() => _walkIn = true;
  static bool takeWalkIn() {
    final w = _walkIn;
    _walkIn = false;
    return w;
  }
}

/// 识别结果弹层里的文字。
class ScanView {
  const ScanView();
  String get plate => rawPlatePretty;
  String get rawPlatePretty => plateText(ScanFlow.rawPlate);

  String get plateKind => switch (ScanFlow.last?['plate_color']) {
    'blue' => '蓝牌',
    'green' => '绿牌（新能源）',
    'yellow' => '黄牌',
    'white' => '白牌',
    'black' => '黑牌',
    _ => '—',
  };

  Map<String, dynamic>? get _vehicle {
    final vs = List<Map<String, dynamic>>.from(
      (ScanFlow.member?['vehicles'] as List?) ?? const [],
    );
    for (final v in vs) {
      if ('${v['plate']}' == ScanFlow.rawPlate) return v;
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

  String get packageSummary => '${ScanFlow.last?['package_summary'] ?? '无次卡'}';
  String get lastVisit => '${ScanFlow.last?['last_visit_text'] ?? '还没到过店'}';
}
