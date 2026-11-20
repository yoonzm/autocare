import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import 'st_front_home_template.dart';
import 'st_home_template.dart';
import '../scan/scan_page.dart';
import 'st_arrivals_template.dart';
import 'st_cash_queue_template.dart';
import '../orders/order_route_data.dart';
import 'st_member_info_template.dart';
import 'st_member_template.dart';
import 'st_done_template.dart';
import 'st_finish_template.dart';
import 'st_mine_template.dart';
import 'st_no_perm_template.dart';
import 'st_perf_template.dart';
import 'st_task_detail_template.dart';
import 'st_tasks_template.dart';
import 'task_route_data.dart';
import 'st_member_route_data.dart';
import '../../routes.dart' show openRoute;

/// 是否为当前员工身份的根工作台路由（回到根页时直接回退到栈底）。
bool isStaffRootRoute(String name) => switch (Access.role) {
  'technician' => name == 'StHome' || name == 'Main',
  'cashier' => name == 'StFrontHome' || name == 'Main',
  _ => false,
};

/// 员工外壳（前台收银 / 施工技师）：无底部 Tab，单工作台首页 + 右上角头像进入「我的」。
class StaffTabs extends StatefulWidget {
  const StaffTabs({super.key});

  @override
  State<StaffTabs> createState() => _StaffTabsState();
}

class _StaffTabsState extends State<StaffTabs> {
  @override
  void initState() {
    super.initState();
    Access.changed.addListener(_onAccess);
  }

  @override
  void dispose() {
    Access.changed.removeListener(_onAccess);
    super.dispose();
  }

  void _onAccess() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Access.role == 'technician'
        ? const StHomeLivePage()
        : const StFrontHomeLivePage(),
  );
}

/// 没有权限的直达路由统一落到这里（设计稿 StNoPerm）。
Widget staffNoPerm(String need) => StNoPermTemplate(need: need);

/// 员工端路由 → 页面。没有后端的页面显示明确的 TODO，不展示设计稿里的示例数据。
Widget? stPageFor(
  String name, {
  TaskRouteData? task,
  StMemberRouteData? member,
}) => switch (name) {
  'StHome' => const StHomeLivePage(),
  'StFrontHome' => const StFrontHomeLivePage(),
  'StMine' => const StMineLivePage(),
  'StNoPerm' => const StNoPermTemplate(),
  'StTasks' => const StTasksLivePage(),
  'StTaskDetail' => StTaskDetailLivePage(taskId: task?.taskId),
  'StFinish' => StFinishLivePage(taskId: task?.taskId),
  'StDone' => StDoneLivePage(result: task?.result),
  'StArrivals' => const StArrivalsLivePage(),
  'StMember' => const StMemberLivePage(),
  'StMemberInfo' => StMemberInfoLivePage(memberId: member?.memberId),
  // 扫车牌找会员沿用商家端真实识别流程，服务端校验「会员查询」权限。
  'StVerify' => ScanPage(
    ScanKind.findPlate,
    onViewMember: (context, m) => openRoute(
      context,
      'StMemberInfo',
      arguments: StMemberRouteData('${m['id']}'),
    ),
    onOrderMember: (context, m) =>
        openRoute(context, 'Order', arguments: OrderRouteData(member: m)),
  ),
  'StCashQueue' => const StCashQueueLivePage(),
  'StPerf' => const StPerfLivePage(),
  _ => null,
};
