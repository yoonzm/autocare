import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../widgets/store_session_gate.dart';
import 'access_pages.dart';
import 'login_page.dart';
import '../shared/shell.dart';
import '../staff_app/staff_tabs.dart';

/// 员工 / 店长身份的冷启动：先向服务端读取身份与生效权限（权限缓存只放内存），再进入对应外壳。
/// 身份失效（被停用、门店归档）时回到登录页。
class AccessBoot extends StatelessWidget {
  const AccessBoot({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      load: () => merchantApi.identity('context'),
      isEmpty: (_) => false,
      skeleton: const Center(child: AppSkeleton(width: 180, height: 28)),
      empty: (_) => const SizedBox.shrink(),
      onLoaded: Access.apply,
      onNext: () => AccessFlow.signOut(context),
      builder: (context, ctx) {
        if (ctx['status'] == 'pending') return const StAuthLivePage();
        if (Access.usesStaffShell) return const StaffTabs();
        return const StoreSessionGate(child: Shell());
      },
    ),
  );
}

/// 启动页：已登录时按上次的身份类型进入；老板沿用原来的商家启动流程。
Widget bootPage() {
  if (!merchantApi.hasSession) return const LoginPage();
  if (Access.role == 'owner') return const StoreSessionGate(child: Shell());
  return const AccessBoot();
}
