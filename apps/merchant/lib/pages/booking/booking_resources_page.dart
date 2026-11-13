import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show ConfirmDiscard;
import '../staff/staff_skeletons.dart';
import 'booking_settings_controller.dart';
import 'business_hours_template.dart';
import 'bay_edit_template.dart';
import 'appointment_settings_skeleton.dart';

class BusinessHoursPage extends StatelessWidget {
  const BusinessHoursPage({super.key});
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: 'business',
    builder: (c) => BusinessHoursTemplate(c: c),
  );
}

class BayEditorPage extends StatelessWidget {
  final Map<String, dynamic>? row, options;
  const BayEditorPage({super.key, this.row, this.options});
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: 'bay',
    row: row,
    options: options,
    builder: (c) => BayEditorTemplate(c: c),
  );
}

class BookingLiveHost extends StatefulWidget {
  final String mode;
  final Map<String, dynamic>? row, options;
  final Widget Function(BookingSettingsController) builder;
  const BookingLiveHost({
    super.key,
    required this.mode,
    required this.builder,
    this.row,
    this.options,
  });
  @override
  State<BookingLiveHost> createState() => _BookingHostState();
}

class _BookingHostState extends State<BookingLiveHost> {
  var _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  BookingSettingsController? c;
  bool pending = false;
  bool get listing => widget.mode == 'business';
  @override
  void initState() {
    super.initState();
    AppointmentFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_reload);
    c?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BookingLiveHost old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.row?['id'] != widget.row?['id']) {
      c?.dispose();
      c = null;
      pending = false;
      _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
    }
  }

  void _reload() {
    if (!listing || !mounted) return;
    if (_key.currentState?.busy == true) {
      pending = true;
      return;
    }
    _key.currentState?.reload();
  }

  void _settled() {
    if (pending && mounted) {
      pending = false;
      _reload();
    }
  }

  void _bind(Map<String, dynamic> data) {
    c ??= BookingSettingsController(data, widget.mode, widget.row);
    c!.options = dataSnapshot(data);
    final controller = c!;
    controller.onEdit = (context, row) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BayEditorPage(row: row, options: controller.options),
      ),
    );
  }

  Widget _view() => KeyedSubtree(
    key: ObjectKey(c),
    child: ListenableBuilder(
      listenable: Listenable.merge([c!, busyActions]),
      builder: (_, _) => ConfirmDiscard(
        busy: c!.locked,
        dirty: c!.dirty,
        child: AbsorbPointer(absorbing: c!.locked, child: widget.builder(c!)),
      ),
    ),
  );
  Widget skeleton(bool blocks) => widget.mode == 'settings'
      ? AppointmentSettingsSkeleton(showBlocks: blocks)
      : ResourceSkeleton(
          kind: widget.mode == 'bay'
              ? ResourceSkeletonKind.bayForm
              : ResourceSkeletonKind.business,
          showBlocks: blocks,
        );
  @override
  Widget build(BuildContext context) {
    if (widget.options != null) {
      if (c == null) _bind(widget.options!);
      return Scaffold(body: _view());
    }
    return Scaffold(
      body: AsyncView<Map<String, dynamic>>(
        key: _key,
        load: () => merchantApi.appointment('options'),
        isEmpty: (_) => false,
        skeletonPadding: EdgeInsets.zero,
        waiting: skeleton(false),
        skeleton: skeleton(true),
        skeletonScrollable: false,
        pullToRefresh: listing,
        empty: (_) => const SizedBox.shrink(),
        onLoaded: _bind,
        onSettled: _settled,
        builder: (_, _) => _view(),
      ),
    );
  }
}
