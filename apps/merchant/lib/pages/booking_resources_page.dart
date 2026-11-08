import '../kit/kit.dart' show ConfirmDiscard;

import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/staff_flow.dart';
import '../routes.dart' show openRoute;
import 'staff_invite_template.dart';
import '../kit/async_kit.dart';
import '../kit/sheet_route.dart';
import '../widgets/booking_template_bindings.dart';
import 'business_hours_template.dart';
import 'staff_list_template.dart';
import 'staff_add_template.dart';
import 'staff_edit_template.dart';
import 'bay_edit_template.dart';
import 'appointment_settings_skeleton.dart';
import 'staff_skeletons.dart';

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

  /// 从列表页进入时带上已读到的预约选项：编辑页直接显示，不再整页等待、不出骨架。
  final Map<String, dynamic>? options;
  const BookingResourceEditor({
    super.key,
    required this.kind,
    this.row,
    this.options,
  });
  @override
  Widget build(BuildContext context) => BookingLiveHost(
    mode: kind == 'bay' ? 'bay' : 'staff',
    row: row,
    options: options,
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
  final Map<String, dynamic>? options;
  final Widget Function(BookingTemplateController) builder;
  const BookingLiveHost({
    super.key,
    required this.mode,
    required this.builder,
    this.row,
    this.options,
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
    if (widget.mode == 'staff_list') StaffFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_reload);
    StaffFlow.changed.removeListener(_reload);
    c?.dispose();
    super.dispose();
  }

  void _reload() => _key.currentState?.reload();

  void _bind(Map<String, dynamic> data) {
    c ??= BookingTemplateController(data, widget.mode, widget.row);
    c!.options.addAll(data);
    if (widget.mode == 'staff') {
      c!.onAdded = (context) => Navigator.of(context).pushReplacement(
        appSheetRoute<void>(
          settings: const RouteSettings(name: 'StaffInvite'),
          page: const StaffInviteLivePage(),
        ),
      );
      c!.onDisable = (context) {
        StaffFlow.currentId = widget.row?['id'] as String?;
        openRoute(context, 'DisableStaff');
      };
    }
    c!.onEdit = (context, row) {
      final bay = widget.mode == 'business';
      final editor = BookingResourceEditor(
        kind: bay ? 'bay' : 'technician',
        row: row,
        options: c!.options,
      );
      // 新增 / 编辑员工左上角是 ✕：整页 sheet；编辑工位是返回箭头，保持推入
      Navigator.of(context).push(
        bay
            ? MaterialPageRoute<void>(builder: (_) => editor)
            : appSheetRoute<void>(page: editor),
      );
    };
  }

  Widget _view() => ListenableBuilder(
    listenable: c!,
    builder: (_, _) => ConfirmDiscard(
      busy: c!.busy,
      dirty: c!.dirty,
      child: AbsorbPointer(absorbing: c!.busy, child: widget.builder(c!)),
    ),
  );

  ResourceSkeleton? _resourceSkeleton({bool blocks = true}) =>
      switch (widget.mode) {
        'staff_list' => ResourceSkeleton(
          kind: ResourceSkeletonKind.staffList,
          showBlocks: blocks,
        ),
        'staff' => ResourceSkeleton(
          kind: ResourceSkeletonKind.staffForm,
          editing: widget.row != null,
          showBlocks: blocks,
        ),
        'bay' => ResourceSkeleton(
          kind: ResourceSkeletonKind.bayForm,
          showBlocks: blocks,
        ),
        'business' => ResourceSkeleton(
          kind: ResourceSkeletonKind.business,
          showBlocks: blocks,
        ),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final preset = widget.options;
    if (preset != null) {
      _bind(preset);
      return Scaffold(body: _view());
    }
    return _asyncBuild(context);
  }

  Widget _asyncBuild(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: _key,
      load: () => widget.mode == 'staff' || widget.mode == 'staff_list'
          ? merchantApi.staff('list')
          : merchantApi.appointment('options'),
      isEmpty: (_) => false,
      skeletonPadding: EdgeInsets.zero,
      waiting: widget.mode == 'settings'
          ? const AppointmentSettingsSkeleton(showBlocks: false)
          : _resourceSkeleton(blocks: false),
      skeletonScrollable: false,
      skeleton: widget.mode == 'settings'
          ? const AppointmentSettingsSkeleton()
          : _resourceSkeleton() ?? SkeletonDataPage(title: '', detail: listing),
      empty: (_) => const SizedBox.shrink(),
      onLoaded: _bind,
      builder: (_, data) => _view(),
    ),
  );
}
