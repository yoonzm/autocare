import 'package:flutter/material.dart';

import '../../../backend/merchant_api.dart';
import '../../../kit/async_kit.dart';
import '../member_events.dart';
import 'member_package_route_data.dart';
import 'member_package_controller.dart';

class MemberPackageHost extends StatefulWidget {
  final MemberPackageRouteData? data;
  final bool detail;
  final Widget Function(MemberPackageController controller) builder;
  const MemberPackageHost({
    super.key,
    this.data,
    this.detail = false,
    required this.builder,
  });
  @override
  State<MemberPackageHost> createState() => _MemberPackageHostState();
}

class _MemberPackageHostState extends State<MemberPackageHost> {
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  MemberPackageController? c;
  @override
  void initState() {
    super.initState();
    if (!widget.detail && widget.data?.package != null) {
      c = MemberPackageController(widget.data!, widget.data!.package!);
    }
    if (widget.detail) memberChanged.addListener(_reload);
  }

  void _reload() {
    if (c?.busy != true) key.currentState?.reload();
  }

  @override
  void dispose() {
    memberChanged.removeListener(_reload);
    c?.dispose();
    super.dispose();
  }

  Widget _content() => ListenableBuilder(
    listenable: c!,
    builder: (_, _) =>
        AsyncActionScope(actionKey: c!.actionKey, child: widget.builder(c!)),
  );
  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession || widget.data == null) {
      return ErrorView(
        error: AppError(
          merchantApi.hasSession ? '请先选择次卡' : '请先登录',
          type: merchantApi.hasSession
              ? AppErrorType.notFound
              : AppErrorType.auth,
        ),
      );
    }
    if (!widget.detail) {
      return c == null
          ? ErrorView(
              error: const AppError('请从次卡详情进入', type: AppErrorType.notFound),
            )
          : _content();
    }
    return Scaffold(
      body: AsyncView<Map<String, dynamic>>(
        key: key,
        load: () => merchantApi.memberPackage(widget.data!.id),
        onLoaded: (row) {
          c ??= MemberPackageController(widget.data!, row);
          c!.apply(row);
        },
        isEmpty: (_) => false,
        skeleton: const SkeletonDataPage(title: '次卡详情', detail: true),
        empty: (_) => const SizedBox.shrink(),
        builder: (_, _) => _content(),
      ),
    );
  }
}
