import 'dart:convert';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/pickers.dart' show pickDate;
import 'member_events.dart';
import 'member_view.dart';

class MemberVisitController extends ChangeNotifier {
  static const methods = ['电话', '微信', '到店'];
  static const results = ['已接通 · 有意向', '已接通 · 暂无需求', '未接通', '已预约到店'];
  final Map<String, dynamic> member;
  final content = TextEditingController();
  int method = 0, result = -1;
  String next = '';
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  MemberVisitController(Map<String, dynamic> member)
    : member = Map.unmodifiable(member);
  MemberView get view => MemberView(member);
  String get actionKey => 'member-visit-${identityHashCode(this)}';
  void chooseMethod(int value) {
    if (!busy && !disposed) {
      method = value;
      notifyListeners();
    }
  }

  void chooseResult(int value) {
    if (!busy && !disposed) {
      result = value;
      notifyListeners();
    }
  }

  Future<void> chooseNext(BuildContext context) async {
    if (busy || disposed) return;
    final value = await pickDate(
      context,
      '选择下次回访',
      birthday: false,
      current: next.replaceAll('-', '.'),
      fullFormat: true,
    );
    if (!disposed && !busy && value != null) {
      next = value.replaceAll('.', '-');
      notifyListeners();
    }
  }

  Future<bool> save() async {
    if (busy || disposed) return false;
    if (result < 0 || result >= results.length) throw const AppError('请选择回访结果');
    final body = jsonEncode({
      'id': member['id'],
      'method': methods[method],
      'result': results[result],
      'content': content.text.trim(),
      'next': next,
    });
    if (_intent != body) {
      _intent = body;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      await merchantApi.saveFollowUp(
        memberId: '${member['id']}',
        method: methods[method],
        result: results[result],
        content: content.text.trim(),
        nextAt: next.isEmpty ? null : next,
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
        AppToast.show(context, '已保存回访', kind: ToastKind.success);
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  });
  @override
  void dispose() {
    disposed = true;
    content.dispose();
    super.dispose();
  }
}
