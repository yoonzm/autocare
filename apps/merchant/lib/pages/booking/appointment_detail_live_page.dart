import '../../kit/kit.dart' show ConfirmDiscard;
import 'reschedule_controller.dart';
import 'appointment_reschedule_template.dart';

import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/mutation_request.dart';
import '../../backend/merchant_api.dart';
import '../../backend/member_flow.dart';
import '../../kit/async_kit.dart';
import '../../theme.dart';
import '../orders/order_page.dart';
import 'appointment_detail_template.dart';

Future<void> openAppointmentOrder(
  BuildContext context,
  Appointment a, {
  bool Function()? isCurrent,
}) async {
  try {
    final member = a.row['member_id'] == null
        ? null
        : await merchantApi.member(a.row['member_id'] as String);
    if (!context.mounted || isCurrent?.call() == false) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          appointment: a.row,
          member: member == null ? null : memberFromRow(member),
        ),
      ),
    );
  } catch (e) {
    if (context.mounted && isCurrent?.call() != false) {
      AppToast.error(context, e);
    }
  }
}

class AppointmentDetailLivePage extends StatefulWidget {
  final String id;
  const AppointmentDetailLivePage({super.key, required this.id});
  @override
  State<AppointmentDetailLivePage> createState() => _DetailState();
}

class _DetailState extends State<AppointmentDetailLivePage> {
  var _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  bool _busy = false, _refreshPending = false;
  int _targetVersion = 0;
  var _write = MutationRequest();
  var _actionKey = 'appointment-detail:${UniqueKey()}';
  @override
  void initState() {
    super.initState();
    AppointmentFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_reload);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppointmentDetailLivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _targetVersion++;
      _busy = false;
      _refreshPending = false;
      _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
      _write = MutationRequest();
      _actionKey = 'appointment-detail:${UniqueKey()}';
    }
  }

  void _reload() {
    if (_key.currentState?.busy == true) {
      _refreshPending = true;
    } else {
      _key.currentState?.reload();
    }
  }

  Future<void> _order(Appointment a) async {
    if (_busy) return;
    if (['done', 'cancelled'].contains(a.row['status'])) {
      AppToast.show(context, '该预约已结束');
      return;
    }
    final owner = _targetVersion;
    setState(() => _busy = true);
    try {
      await runBusy(_actionKey, () async {
        try {
          if (a.row['status'] != 'arrived') {
            final result = await _write.send({
              'action': 'appointment_arrive',
              'id': a.id,
              'reason': '',
            });
            a = Appointment(Map<String, dynamic>.from(result['item']));
            AppointmentFlow.notify();
          }
          if (mounted && owner == _targetVersion) {
            await openAppointmentOrder(
              context,
              a,
              isCurrent: () => owner == _targetVersion,
            );
          }
        } catch (e) {
          if (mounted && owner == _targetVersion) AppToast.error(context, e);
        }
      });
    } finally {
      if (mounted && owner == _targetVersion) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: _key,
      onSettled: () {
        if (_refreshPending && mounted) {
          _refreshPending = false;
          _key.currentState?.reload();
        }
      },
      load: () => merchantApi.appointment('get', {'id': widget.id}),
      isEmpty: (_) => false,
      skeletonPadding: EdgeInsets.zero,
      skeleton: const SkeletonDataPage(title: '预约详情', detail: true),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, row) {
        final a = Appointment(row);
        return AsyncActionScope(
          actionKey: _actionKey,
          child: AppointmentDetailTemplate(
            a: a,
            actionKey: _actionKey,
            onOrder: () => _order(a),
            onReschedule: () => showAppointmentReschedule(context, a),
          ),
        );
      },
    ),
  );
}

Future<void> showAppointmentReschedule(
  BuildContext context,
  Appointment a, {
  bool Function()? isCurrent,
}) async {
  if (!['waiting', 'late'].contains(a.row['status'])) {
    AppToast.show(context, '仅待到店预约可改期或取消');
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _Reschedule(a),
  );
}

class _Reschedule extends StatefulWidget {
  final Appointment a;
  const _Reschedule(this.a);
  @override
  State<_Reschedule> createState() => _RescheduleState();
}

class _RescheduleState extends State<_Reschedule> {
  late final c = RescheduleController(widget.a);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([c, busyActions]),
    builder: (_, _) => ConfirmDiscard(
      busy: c.locked,
      dirty: c.dirty,
      child: AbsorbPointer(
        absorbing: c.locked,
        child: SingleChildScrollView(
          child: AppointmentRescheduleTemplate(c: c),
        ),
      ),
    ),
  );
}
