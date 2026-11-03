import '../kit/kit.dart' show ConfirmDiscard;

import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../widgets/booking_template_bindings.dart';
import 'business_hours_template.dart';
import 'staff_list_template.dart';
import 'staff_add_template.dart';
import 'staff_edit_template.dart';
import 'bay_edit_template.dart';

class BookingResourcesPage extends StatelessWidget {
  final String kind;
  const BookingResourcesPage({super.key, required this.kind});
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: kind == 'bay' ? 'business' : 'staff_list',
    builder: (c) =>
        kind == 'bay' ? BusinessHoursTemplate(c: c) : StaffListTemplate(c: c),
  );
}

class BookingResourceEditor extends StatelessWidget {
  final String kind;
  final Map<String, dynamic>? row;
  const BookingResourceEditor({super.key, required this.kind, this.row});
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: kind == 'bay' ? 'bay' : 'staff',
    row: row,
    builder: (c) => kind == 'bay'
        ? BayEditorTemplate(c: c)
        : row == null
        ? StaffAddTemplate(c: c)
        : StaffEditTemplate(c: c),
  );
}

class BookingLiveHost extends StatefulWidget {
  final String mode;
  final Map<String, dynamic>? row;
  final Widget Function(BookingTemplateController) builder;
  const BookingLiveHost({
    super.key,
    required this.mode,
    required this.builder,
    this.row,
  });
  @override
  State<BookingLiveHost> createState() => _HostState();
}

class _HostState extends State<BookingLiveHost> {
  final _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  BookingTemplateController? c;
  bool get listing => widget.mode == 'business' || widget.mode == 'staff_list';
  @override
  void initState() {
    super.initState();
    if (listing) AppointmentFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_reload);
    c?.dispose();
    super.dispose();
  }

  void _reload() => _key.currentState?.reload();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: _key,
      load: () => merchantApi.appointment('options'),
      isEmpty: (_) => false,
      skeletonPadding: EdgeInsets.zero,
      skeleton: SkeletonDataPage(
        title: switch (widget.mode) {
          'business' => '营业时间与工位',
          'staff_list' => '员工与权限',
          'bay' => '编辑工位',
          'staff' => widget.row == null ? '新增员工' : '编辑员工',
          _ => '',
        },
        detail: listing,
      ),
      empty: (_) => const SizedBox.shrink(),
      onLoaded: (data) {
        c ??= BookingTemplateController(data, widget.mode, widget.row);
        c!.options.addAll(data);
        c!.onEdit = (context, row) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookingResourceEditor(
              kind: widget.mode == 'business' ? 'bay' : 'technician',
              row: row,
            ),
          ),
        );
      },
      builder: (_, data) => ListenableBuilder(
        listenable: c!,
        builder: (_, _) => ConfirmDiscard(
          busy: c!.busy,
          dirty: c!.dirty,
          child: AbsorbPointer(absorbing: c!.busy, child: widget.builder(c!)),
        ),
      ),
    ),
  );
}
