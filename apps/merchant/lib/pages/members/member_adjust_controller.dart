import 'dart:convert';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import 'member_events.dart';
import 'member_view.dart';

class MemberAdjustController extends ChangeNotifier {
  static const reasons = ['活动补发', '客诉补偿', '录入错误', '其他'];
  final Map<String, dynamic> member;
  final note = TextEditingController();
  List<Map<String, dynamic>> tiers = [];
  int tier = -1, direction = 0, points = 0, reason = -1;
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  MemberAdjustController(Map<String, dynamic> member)
    : member = Map.unmodifiable(member);
  MemberView get view => MemberView(member);
  String get actionKey => 'member-adjust-${identityHashCode(this)}';
  String get afterPoints => formatMoney(
    ((member['points'] as num? ?? 0) + (direction == 0 ? points : -points))
        .clamp(0, double.infinity),
  );
  Future<List<Map<String, dynamic>>> loadTiers() async {
    final rows = await merchantApi.list('cards');
    num rank(Map<String, dynamic> t) =>
        (num.tryParse('${t['upgrade_recharge'] ?? 0}') ?? 0) * 1000000 +
        (num.tryParse('${t['upgrade_cumulative'] ?? 0}') ?? 0);
    rows.sort((a, b) => rank(a).compareTo(rank(b)));
    return rows;
  }

  void applyTiers(List<Map<String, dynamic>> rows) {
    if (disposed) return;
    tiers = rows.map((r) => Map<String, dynamic>.unmodifiable(r)).toList();
    tier = tiers.indexWhere((r) => r['id'] == member['card_type_id']);
  }

  String tierName(int index) {
    if (index >= tiers.length) return '—';
    var name = '${tiers[index]['name'] ?? ''}'.replaceAll('会员', '');
    if (name.length > 2 && name.endsWith('卡')) {
      name = name.substring(0, name.length - 1);
    }
    return name;
  }

  void chooseTier(BuildContext context, int index) {
    if (busy || disposed) return;
    if (index < 0 || index >= tiers.length) {
      AppToast.show(context, '这个卡种按钮在本店没有对应的卡种');
      notifyListeners();
      return;
    }
    tier = index;
    notifyListeners();
  }

  void chooseDirection(int value) {
    if (!busy && !disposed) {
      direction = value;
      notifyListeners();
    }
  }

  void chooseReason(int value) {
    if (!busy && !disposed) {
      reason = value;
      notifyListeners();
    }
  }

  void changePoints(int value) {
    if (!busy && !disposed) {
      points = value < 0 ? 0 : value;
      notifyListeners();
    }
  }

  Future<bool> save() async {
    if (busy || disposed) return false;
    final selected = tier >= 0 && tier < tiers.length
        ? tiers[tier]['id']?.toString()
        : null;
    final tierId = selected == member['card_type_id'] ? null : selected;
    final delta = direction == 0 ? points : -points;
    if (tierId == null && delta == 0) throw const AppError('请选择要调整的卡种或积分数量');
    if (reason < 0 || reason >= reasons.length) throw const AppError('请选择调整原因');
    final body = jsonEncode({
      'id': member['id'],
      'tier': tierId,
      'points': delta,
      'reason': reasons[reason],
      'note': note.text.trim(),
    });
    if (_intent != body) {
      _intent = body;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      await merchantApi.adjustMember(
        memberId: '${member['id']}',
        tierId: tierId,
        points: delta,
        reason: reasons[reason],
        note: note.text.trim(),
        requestId: _requestId,
      );
      _intent = null;
      _requestId = null;
      memberChanged.value++;
      return true;
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<void> submit(BuildContext context) => runBusy(actionKey, () async {
    try {
      if (await save() && context.mounted && !disposed) {
        AppToast.show(context, '已调整', kind: ToastKind.success);
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  });
  @override
  void dispose() {
    disposed = true;
    note.dispose();
    super.dispose();
  }
}
