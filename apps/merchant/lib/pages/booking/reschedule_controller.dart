import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/mutation_request.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show hConfirm;

class RescheduleController extends ChangeNotifier {
  final Appointment booking;
  final DateTime today = bookingToday;
  final request = MutationRequest();
  final actionKey = 'reschedule:${UniqueKey()}';
  int? rescheduleDay, cancelReason;
  String selectedTime = '';
  bool busy = false, dirty = false, disposed = false;
  bool _committed = false;
  bool get locked => busy || isBusy(actionKey);
  RescheduleController(Appointment booking)
    : booking = Appointment(dataSnapshot(booking.row));
  DateTime date(int index) => today.add(Duration(days: index));
  String dateLabel(int i) {
    final d = date(i);
    return '${i == 0
        ? '今天'
        : i == 1
        ? '明天'
        : '周${'一二三四五六日'[d.weekday - 1]}'} ${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  void changed() {
    if (!disposed) notifyListeners();
  }

  void deferred(BuildContext context) {
    // TODO: reschedule/cancellation notifications have no connected delivery channel.
    AppToast.show(context, 'TODO：预约通知尚未接通，当前未发送通知');
  }

  void edited() {
    dirty = true;
    _committed = false;
    if (!disposed) notifyListeners();
  }

  Future<Map<String, dynamic>?> persist() async {
    if (busy || disposed || _committed) return null;
    if (rescheduleDay == null || selectedTime.isEmpty) {
      throw const AppError('请选择新日期和时间');
    }
    busy = true;
    notifyListeners();
    try {
      final result = await request.send({
        'action': 'appointment_save',
        'id': booking.id,
        'starts_at':
            '${bookingDay(date(rescheduleDay!))}T$selectedTime:00+08:00',
        'bay_id': booking.row['bay_id'],
        'technician_id': booking.row['technician_id'],
      });
      dirty = false;
      _committed = true;
      AppointmentFlow.notify();
      return result;
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  Future<void> save(BuildContext context) async {
    if (locked) return;
    bool saved = false;
    await runBusy(actionKey, () async {
      try {
        saved = await persist() != null;
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      }
    });
    if (saved && context.mounted && !disposed) {
      AppToast.show(context, '已保存', kind: ToastKind.success);
      Navigator.of(context).pop();
    }
  }

  Future<void> cancelBooking(BuildContext context) async {
    if (cancelReason == null || locked) return;
    final reason = ['客户有事', '时间冲突', '联系不上', '其他'][cancelReason!];
    final ok = await hConfirm(
      context,
      '确认取消预约？',
      message: '取消后将释放预约时段',
      onConfirm: () async {
        busy = true;
        if (!disposed) notifyListeners();
        try {
          await request.send({
            'action': 'appointment_cancel',
            'id': booking.id,
            'reason': reason,
          });
          dirty = false;
          AppointmentFlow.notify();
        } finally {
          busy = false;
          if (!disposed) notifyListeners();
        }
      },
    );
    if (ok && context.mounted && !disposed) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
