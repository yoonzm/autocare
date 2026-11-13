import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_form_controller.dart';

class MemberFormHost extends StatefulWidget {
  final MemberFormKind kind;
  final Map<String, dynamic>? member, vehicle;
  final Widget Function(MemberFormController controller) builder;
  const MemberFormHost({
    super.key,
    required this.kind,
    this.member,
    this.vehicle,
    required this.builder,
  });
  @override
  State<MemberFormHost> createState() => _MemberFormHostState();
}

class _MemberFormHostState extends State<MemberFormHost> {
  late final c = MemberFormController(
    widget.kind,
    member: widget.member,
    vehicle: widget.vehicle,
  );
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession ||
        (widget.kind != MemberFormKind.create &&
            widget.member?['id'] == null)) {
      return Scaffold(
        body: ErrorView(
          error: AppError(
            merchantApi.hasSession ? '请先选择会员' : '请先登录',
            type: merchantApi.hasSession
                ? AppErrorType.notFound
                : AppErrorType.auth,
          ),
          onNext: () => merchantApi.hasSession
              ? Navigator.of(context).maybePop()
              : openRoute(context, 'Login'),
        ),
      );
    }
    return ListenableBuilder(
      listenable: c,
      builder: (_, _) =>
          AsyncActionScope(actionKey: c.actionKey, child: widget.builder(c)),
    );
  }
}
