import 'package:flutter/material.dart';

import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show ConfirmDiscard;
import '../../kit/sheet_route.dart';
import '../../routes.dart' show openRoute;
import 'staff_add_template.dart';
import 'staff_edit_template.dart';
import 'staff_list_template.dart';
import 'staff_editor_controller.dart';
import 'staff_invite_template.dart';
import 'staff_route_data.dart';
import 'staff_skeletons.dart';

class StaffResourcesPage extends StatelessWidget {
  const StaffResourcesPage({super.key});
  @override
  Widget build(BuildContext context) => const _StaffEditorHost(listing: true);
}

class StaffEditorPage extends StatelessWidget {
  final Map<String, dynamic>? row, options;
  final String? initialRole;
  const StaffEditorPage({super.key, this.row, this.options, this.initialRole});
  @override
  Widget build(BuildContext context) =>
      _StaffEditorHost(row: row, options: options, initialRole: initialRole);
}

class _StaffEditorHost extends StatefulWidget {
  final bool listing;
  final Map<String, dynamic>? row, options;
  final String? initialRole;
  const _StaffEditorHost({
    this.listing = false,
    this.row,
    this.options,
    this.initialRole,
  });
  @override
  State<_StaffEditorHost> createState() => _StaffEditorHostState();
}

class _StaffEditorHostState extends State<_StaffEditorHost> {
  var _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  StaffEditorController? c;
  bool pending = false;
  @override
  void initState() {
    super.initState();
    StaffFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    StaffFlow.changed.removeListener(_reload);
    c?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _StaffEditorHost old) {
    super.didUpdateWidget(old);
    if (old.listing != widget.listing ||
        old.row?['id'] != widget.row?['id'] ||
        old.initialRole != widget.initialRole) {
      c?.dispose();
      c = null;
      pending = false;
      _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
    }
  }

  void _reload() {
    if (!widget.listing || !mounted) return;
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
    c ??= StaffEditorController(
      data,
      row: widget.row,
      initialRole: widget.initialRole,
    );
    c!.options = dataSnapshot(data);
    final controller = c!;
    controller.onAdded = (context, row) =>
        Navigator.of(context).pushReplacement(
          appSheetRoute<void>(
            settings: const RouteSettings(name: 'StaffInvite'),
            page: StaffInviteLivePage(employee: row),
          ),
        );
    controller.onDisable = (context) => openRoute(
      context,
      'DisableStaff',
      arguments: StaffRouteData(staffId: controller.draft['id'] as String?),
    );
    controller.onEdit = (context, row) => Navigator.of(context).push(
      appSheetRoute<void>(
        page: StaffEditorPage(
          row: row,
          options: controller.options,
          initialRole: controller.roleKey,
        ),
      ),
    );
  }

  Widget _view() => KeyedSubtree(
    key: ObjectKey(c),
    child: ListenableBuilder(
      listenable: Listenable.merge([c!, busyActions]),
      builder: (_, _) => ConfirmDiscard(
        dirty: c!.dirty,
        busy: c!.locked,
        child: AbsorbPointer(
          absorbing: c!.locked,
          child: widget.listing
              ? StaffListTemplate(c: c!)
              : widget.row == null
              ? StaffAddTemplate(c: c!)
              : StaffEditTemplate(c: c!),
        ),
      ),
    ),
  );
  Widget skeleton(bool blocks) => ResourceSkeleton(
    kind: widget.listing
        ? ResourceSkeletonKind.staffList
        : ResourceSkeletonKind.staffForm,
    editing: widget.row != null,
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
        load: () => merchantApi.staff('list'),
        isEmpty: (_) => false,
        skeletonPadding: EdgeInsets.zero,
        skeletonScrollable: false,
        waiting: skeleton(false),
        skeleton: skeleton(true),
        pullToRefresh: widget.listing,
        empty: (_) => const SizedBox.shrink(),
        onLoaded: _bind,
        onSettled: _settled,
        builder: (_, _) => _view(),
      ),
    );
  }
}
