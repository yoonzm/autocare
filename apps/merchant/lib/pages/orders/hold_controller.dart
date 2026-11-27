import 'dart:convert';

import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/hold_store.dart';
import '../../backend/merchant_api.dart';
import '../../backend/task_flow.dart';
import '../../kit/async_kit.dart';
import 'hold_draft.dart';

class HoldController extends ChangeNotifier {
  final HoldDraft draft;
  final note = TextEditingController();
  int status = HoldStore.defaultStatus;
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  HoldController(this.draft) {
    final original = draft.original;
    if (original != null) {
      status = HoldStore.statuses
          .indexOf('${original['status']}')
          .clamp(0, HoldStore.statuses.length - 1);
      note.text = '${original['note'] ?? ''}';
    }
  }
  String get actionKey => 'hold-save-${identityHashCode(this)}';
  void chooseStatus(int index) {
    if (!busy && !disposed) {
      status = index;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> save() async {
    if (busy || disposed) return null;
    if (draft.lines.isEmpty) throw const AppError('请先在开单页选择项目');
    if (note.text.trim().length > 200) throw const AppError('备注不能超过 200 字');
    final body = jsonEncode({
      'id': draft.holdId,
      'appointment': draft.appointmentId,
      'member': draft.memberId,
      'lines': draft.lines,
      'status': status,
      'note': note.text.trim(),
      'plate': draft.plate,
      'technicians': draft.technicianIds,
      'bay': draft.bayId,
      'estimatedFinish': draft.estimatedFinish,
    });
    if (_intent != body) {
      _intent = body;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      final row = await merchantApi.saveHold(
        holdId: draft.holdId,
        appointmentId: draft.appointmentId,
        memberId: draft.memberId,
        lines: draft.lines,
        status: HoldStore.statuses[status],
        remind: '不提醒',
        note: note.text.trim(),
        plate: draft.plate,
        technicianIds: draft.technicianIds,
        bayId: draft.bayId,
        estimatedFinish: draft.estimatedFinish,
        requestId: _requestId,
      );
      _intent = null;
      _requestId = null;
      HoldStore.recordSaved(row);
      if (draft.appointmentId != null) AppointmentFlow.notify();
      TaskFlow.notify();
      return row;
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<void> submit(BuildContext context) => runBusy(actionKey, () async {
    try {
      final row = await save();
      if (row != null && context.mounted && !disposed) {
        AppToast.show(context, '已挂单', kind: ToastKind.success);
        Navigator.of(context).pop(row);
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
