// 由 tools/design_to_flutter.py 生成，请勿手工修改。
import 'package:flutter/widgets.dart';
import 'st_arrivals_page.dart';
import 'st_auth_page.dart';
import 'st_auth_fail_page.dart';
import 'st_cash_queue_page.dart';
import 'st_done_page.dart';
import 'st_finish_page.dart';
import 'st_front_home_page.dart';
import 'st_home_page.dart';
import 'st_identity_page.dart';
import 'st_member_page.dart';
import 'st_member_info_page.dart';
import 'st_mine_page.dart';
import 'st_msgs_page.dart';
import 'st_no_perm_page.dart';
import 'st_order_page.dart';
import 'st_perf_page.dart';
import 'st_plan_expired_page.dart';
import 'st_task_detail_page.dart';
import 'st_tasks_page.dart';
import 'st_verify_page.dart';
import 'st_verify_code_page.dart';
import 'st_progress_sheet.dart';
import 'st_scan_code_sheet.dart';
import 'st_scan_plate_sheet.dart';

final Map<String, WidgetBuilder> genRoutes = {
  'StArrivals': (_) => const StArrivalsPage(),
  'StAuth': (_) => const StAuthPage(),
  'StAuthFail': (_) => const StAuthFailPage(),
  'StCashQueue': (_) => const StCashQueuePage(),
  'StDone': (_) => const StDonePage(),
  'StFinish': (_) => const StFinishPage(),
  'StFrontHome': (_) => const StFrontHomePage(),
  'StHome': (_) => const StHomePage(),
  'StIdentity': (_) => const StIdentityPage(),
  'StMember': (_) => const StMemberPage(),
  'StMemberInfo': (_) => const StMemberInfoPage(),
  'StMine': (_) => const StMinePage(),
  'StMsgs': (_) => const StMsgsPage(),
  'StNoPerm': (_) => const StNoPermPage(),
  'StOrder': (_) => const StOrderPage(),
  'StPerf': (_) => const StPerfPage(),
  'StPlanExpired': (_) => const StPlanExpiredPage(),
  'StTaskDetail': (_) => const StTaskDetailPage(),
  'StTasks': (_) => const StTasksPage(),
  'StVerify': (_) => const StVerifyPage(),
  'StVerifyCode': (_) => const StVerifyCodePage(),
};

/// 底部弹层（设计稿中叠在其他页面上的界面）。
final Map<String, WidgetBuilder> genSheets = {
  'StProgress': (_) => const StProgressSheet(),
  'StScanCode': (_) => const StScanCodeSheet(),
  'StScanPlate': (_) => const StScanPlateSheet(),
};

/// 弹层所属的页面（设计稿里的遮罩点击目标）。
const Map<String, String> sheetParents = {
  'StProgress': 'StTaskDetail',
  'StScanCode': 'StVerifyCode',
  'StScanPlate': 'StVerify',
};
