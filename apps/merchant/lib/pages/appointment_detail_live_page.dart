import '../kit/kit.dart' show ConfirmDiscard;
import '../widgets/booking_template_bindings.dart';
import 'appointment_reschedule_template.dart';

import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/member_flow.dart';
import '../kit/async_kit.dart';
import '../theme.dart';
import 'order_page.dart';
import 'appointment_detail_template.dart';

Future<void> openAppointmentOrder(BuildContext context, Appointment a) async {
  try {
    final member = a.row['member_id'] == null
        ? null
        : await merchantApi.member(a.row['member_id'] as String);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          appointment: a.row,
          member: member == null ? null : memberFromRow(member),
        ),
      ),
    );
  } catch (e) {
    if (context.mounted) AppToast.error(context, e);
  }
}

class AppointmentDetailLivePage extends StatefulWidget {
  final String id;
  const AppointmentDetailLivePage({super.key, required this.id});
  @override
  State<AppointmentDetailLivePage> createState() => _DetailState();
}

class _DetailState extends State<AppointmentDetailLivePage> {
  final _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  bool _busy = false;
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

  void _reload() => _key.currentState?.reload();
  Future<void> _order(Appointment a) async {
    if (_busy) return;
    if (['done', 'cancelled'].contains(a.row['status'])) {
      AppToast.show(context, '该预约已结束');
      return;
    }
    setState(() => _busy = true);
    try {
      if (a.row['status'] != 'arrived') {
        a = Appointment(await AppointmentFlow.change(a.id, 'arrive'));
      }
      if (mounted) await openAppointmentOrder(context, a);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: _key,
      load: () => merchantApi.appointment('get', {'id': widget.id}),
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 5),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, row) {
        final a = Appointment(row);
        return AppointmentDetailTemplate(
          a: a,
          busy: _busy,
          onOrder: () => _order(a),
          onReschedule: () => showAppointmentReschedule(context, a),
        );
      },
    ),
  );
}

Future<void> showAppointmentReschedule(
  BuildContext context,
  Appointment a,
) async {
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
  late final c = BookingTemplateController({
    'settings': {},
    'resources': [],
  }, 'reschedule')..booking = widget.a;
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (_, _) => ConfirmDiscard(
      busy: c.busy,
      dirty: c.dirty,
      child: AbsorbPointer(
        absorbing: c.busy,
        child: SingleChildScrollView(
          child: AppointmentRescheduleTemplate(c: c),
        ),
      ),
    ),
  );
}
