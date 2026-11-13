import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../kit/kit.dart' show dk, hsvg, hts;
import '../booking/appointments_page.dart';
import '../../resources/staff_svgs.dart';
import '../members/members_page.dart';
import 'st_front_home_template.dart';
import 'st_home_template.dart';
import '../scan/scan_page.dart';
import 'st_arrivals_template.dart';
import 'st_cash_queue_template.dart';
import 'st_order_template.dart';
import 'st_member_info_template.dart';
import 'st_member_template.dart';
import 'st_done_template.dart';
import 'st_finish_template.dart';
import 'st_mine_template.dart';
import 'st_msgs_template.dart';
import 'st_no_perm_template.dart';
import 'st_perf_template.dart';
import 'st_task_detail_template.dart';
import 'st_tasks_template.dart';
import 'task_route_data.dart';
import 'st_member_route_data.dart';
import '../../routes.dart' show openRoute;

/// 员工外壳（前台收银 / 施工技师）当前选中的底部 Tab。
final ValueNotifier<int> staffTab = ValueNotifier<int>(0);

/// 员工外壳里的 Tab 路由名 → 下标。前台与技师的第 2、3 个 Tab 不同。
int? staffTabIndex(String name) => switch (Access.role) {
  'technician' => const {
    'StHome': 0,
    'StTasks': 1,
    'StMember': 2,
    'StMine': 3,
  }[name],
  'cashier' => const {
    'StFrontHome': 0,
    'Appointments': 1,
    'Members': 2,
    'StMine': 3,
  }[name],
  _ => null,
};

class StaffTabs extends StatefulWidget {
  const StaffTabs({super.key});

  @override
  State<StaffTabs> createState() => _StaffTabsState();
}

class _StaffTabsState extends State<StaffTabs> {
  @override
  void initState() {
    super.initState();
    staffTab.value = 0;
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

  List<Widget> get _pages => Access.role == 'technician'
      ? const [
          StHomeLivePage(),
          StTasksLivePage(),
          StMemberLivePage(),
          StMineLivePage(),
        ]
      : const [
          StFrontHomeLivePage(),
          AppointmentsPage(),
          MembersPage(),
          StMineLivePage(),
        ];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: staffTab,
    builder: (context, idx, _) => Scaffold(
      body: IndexedStack(index: idx, children: _pages),
      bottomNavigationBar: StaffNavBar(
        index: idx,
        role: Access.role,
        onTap: (i) => staffTab.value = i,
      ),
    ),
  );
}

/// 设计稿底部导航（84 高，含安全区）：工作台 · 任务 / 预约 · 会员 · 我的。
class StaffNavBar extends StatelessWidget {
  final int index;
  final String role;
  final ValueChanged<int> onTap;
  const StaffNavBar({
    super.key,
    required this.index,
    required this.role,
    required this.onTap,
  });

  // 设计稿的图标是描边 SVG；选中态只是把灰色描边换成主色。
  static String _blue(String svg) =>
      svg.replaceAll('#71717A', '#0485F7').replaceAll('#9A9AA3', '#0485F7');

  @override
  Widget build(BuildContext context) {
    final tabs = role == 'technician'
        ? [
            ('工作台', Svgs.s51, Svgs.s52),
            ('任务', Svgs.s43, Svgs.s44),
            ('会员', Svgs.s34, Svgs.s35),
            ('我的', Svgs.s34, Svgs.s35),
          ]
        : [
            ('工作台', Svgs.s51, Svgs.s52),
            ('预约', Svgs.s32, Svgs.s33),
            ('会员', Svgs.s34, Svgs.s35),
            ('我的', Svgs.s34, Svgs.s35),
          ];
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 84 - 34 + (bottom > 0 ? bottom : 34),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
        border: Border(
          top: BorderSide(
            color: dk(
              context,
              const Color(0xFFE8E8EA),
              const Color(0xFF26262B),
            ),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                label: tabs[i].$1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        hsvg(
                          i == index
                              ? _blue(tabs[i].$2)
                              : dk(context, tabs[i].$2, tabs[i].$3),
                          w: 24,
                          h: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tabs[i].$1,
                          style: hts(
                            11,
                            i == index
                                ? const Color(0xFF0485F7)
                                : dk(
                                    context,
                                    const Color(0xFF71717A),
                                    const Color(0xFF9A9AA3),
                                  ),
                            w: i == index ? FontWeight.w600 : FontWeight.w500,
                            lh: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
  // 扫车牌 / 会员码找会员沿用商家端真实识别流程，服务端校验「会员查询」权限。
  'StVerify' => ScanPage(
    ScanKind.findPlate,
    onViewMember: (context, m) => openRoute(
      context,
      'StMemberInfo',
      arguments: StMemberRouteData('${m['id']}'),
    ),
    onOrderMember: (context, m) => openRoute(
      context,
      'StOrder',
      arguments: StMemberRouteData('${m['id']}'),
    ),
  ),
  'StVerifyCode' => const ScanPage(ScanKind.findCode),
  'StOrder' =>
    member == null
        ? const StMemberLivePage(forOrder: true)
        : StOrderLivePage(memberId: member.memberId),
  'StCashQueue' => const StCashQueueLivePage(),
  'StPerf' => const StPerfLivePage(),
  'StMsgs' => const StMsgsLivePage(),
  _ => null,
};
