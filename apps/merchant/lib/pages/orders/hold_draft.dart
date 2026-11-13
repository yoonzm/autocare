import '../../backend/data_snapshot.dart';

/// 开单页准备挂起的一单（只有选择，没有价格：估价由云函数按服务端价格算）。
class HoldDraft {
  /// 为空 = 散客挂单。
  final String? memberId;
  final String memberName;
  final String level;

  /// 页面上显示的车牌（`沪A·8K29M` / `未登记车辆`）。
  final String plateLabel;
  final String plate;
  final List<Map<String, dynamic>> lines;

  /// 开单页当前显示的应收（仅用于挂单弹层的展示，真正的估价在云函数）。
  final String payableText;
  final String? holdId;
  final Map<String, dynamic>? original;
  HoldDraft({
    this.memberId,
    required this.memberName,
    required this.level,
    required this.plateLabel,
    required this.plate,
    required List<Map<String, dynamic>> lines,
    required this.payableText,
    this.holdId,
    Map<String, dynamic>? original,
  }) : lines = List.unmodifiable(
         lines.map((r) => Map<String, dynamic>.unmodifiable(r)),
       ),
       original = original == null ? null : dataSnapshot(original);
}

/// 挂单保存弹层里的文字（来自调用方传入的 [HoldDraft]）。
class HoldView {
  final HoldDraft _d;
  const HoldView(this._d);
  String get avatar => _d.memberId == null || _d.memberName.isEmpty
      ? '客'
      : _d.memberName.substring(0, 1);
  String get name => _d.memberName;
  String get plate => _d.plateLabel;
  String get countText => '${_d.lines.length} 项服务';
  String get payableText => '¥${_d.payableText}';
}
