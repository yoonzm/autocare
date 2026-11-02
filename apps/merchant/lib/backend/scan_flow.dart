import 'merchant_api.dart';
import 'member_flow.dart' show plateText;

/// 扫码找会员（车牌识别）的结果，以及从“没找到会员”继续办卡 / 散客开单时要带过去的信息。
///
/// 识别由云函数 `recognize_plate` 完成。目前是开发环境的 mock（不看照片）：约一半概率返回门店已有会员，
/// 否则返回一个库里没有的随机车牌。
class ScanFlow {
  ScanFlow._();

  /// 最近一次识别的结果：`matched`、`plate`，匹配时还有 `member`、`package_summary`、`last_visit_text`。
  static Map<String, dynamic>? last;

  static String? _prefillPlate;
  static bool _walkIn = false;

  static Future<Map<String, dynamic>> recognize() async {
    final res = await merchantApi.recognizePlate();
    last = res;
    return res;
  }

  static bool get matched => last?['matched'] == true;
  static Map<String, dynamic>? get member => last?['member'] is Map
      ? Map<String, dynamic>.from(last!['member'] as Map)
      : null;

  /// 识别出的车牌（不带分隔点，如 `沪A8K29M`）。
  static String get rawPlate => '${last?['plate'] ?? ''}';

  /// “创建会员”：办卡页的车牌从识别结果带入（只用一次）。
  static void prefillPlateForAdd() => _prefillPlate = rawPlate;
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

  /// 新能源（绿牌）车牌 8 位，燃油车 7 位。
  String get plateKind => ScanFlow.rawPlate.length >= 8 ? '绿牌（新能源）' : '蓝牌';

  Map<String, dynamic>? get _vehicle {
    final vs = List<Map<String, dynamic>>.from(
      (ScanFlow.member?['vehicles'] as List?) ?? const [],
    );
    for (final v in vs) {
      if ('${v['plate']}' == ScanFlow.rawPlate) return v;
    }
    return vs.isEmpty ? null : vs.first;
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
