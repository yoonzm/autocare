import 'navigation/catalog_route.dart';
import 'pages/staff/staff_editor_page.dart';
import 'pages/orders/pay_success_page.dart';
import 'pages/orders/order_route_data.dart';
import 'pages/orders/order_detail_ref.dart';
import 'pages/members/member_adjust_page.dart';
import 'pages/members/member_visit_page.dart';
import 'pages/members/wallet_page.dart';
import 'pages/members/wallet_controller.dart';
import 'pages/members/recharge_success_page.dart';
import 'pages/members/packages/package_sold_page.dart';
import 'pages/members/packages/package_detail_page.dart';
import 'pages/members/packages/package_extend_sheet.dart';
import 'pages/members/packages/package_refund_sheet.dart';
import 'pages/members/packages/member_package_route_data.dart';
import 'pages/members/member_more_sheet.dart';
import 'pages/members/member_delete_sheet.dart';
import 'pages/members/member_route_data.dart';
import 'pages/members/member_edit_page.dart';
import 'pages/members/vehicle_add_page.dart';
import 'pages/members/member_add_done_page.dart';
import 'pages/staff_app/task_route_data.dart';
import 'pages/staff_app/st_member_route_data.dart';
import 'pages/inventory/inventory_management_page.dart';
import 'pages/inventory/inventory_pickers.dart' show SupplierEditPage;
import 'pages/inventory/inventory_live_page.dart';
import 'pages/expenses/expense_live_page.dart';

import 'package:flutter/material.dart';

import 'kit/sheet_route.dart';

import 'backend/merchant_api.dart';
import 'kit/async_kit.dart';
import 'backend/member_flow.dart';
import 'pages/booking/appointment_add_page.dart';
import 'pages/booking/appointments_page.dart';
import 'pages/booking/appointment_settings_live_page.dart';
import 'pages/booking/booking_resources_page.dart';
import 'navigation/page_registry.dart';
import 'pages/account/login_page.dart';
import 'pages/members/member_detail_page.dart';
import 'pages/members/member_add_page.dart';
import 'pages/members/member_records_live_page.dart';
import 'pages/orders/order_page.dart';
import 'pages/orders/order_live_pages.dart';
import 'pages/inventory/product_edit_live_page.dart';
import 'pages/inventory/product_list_live_page.dart';
import 'pages/staff/staff_route_data.dart';
import 'pages/staff_app/staff_tabs.dart';
import 'pages/staff_app/st_progress_template.dart';
import 'backend/access_flow.dart';
import 'pages/staff/staff_detail_template.dart';
import 'pages/staff/staff_detail_off_template.dart';
import 'pages/staff/staff_commission_template.dart';
import 'pages/staff/staff_records_template.dart';
import 'pages/staff/staff_invite_template.dart';
import 'pages/staff/role_permission_template.dart';
import 'pages/staff/disable_staff_template.dart';
import 'pages/staff/staff_transfer_template.dart';
import 'pages/staff/staff_enable_template.dart';
import 'pages/catalog/services_page.dart';
import 'pages/shared/settings_page.dart';
import 'pages/scan/scan_page.dart';
import 'pages/shared/shell.dart';
import 'pages/shared/theme_sheet.dart';

final Map<String, WidgetBuilder> sheetRoutes = {
  ...sheetBuilders,
  for (final name in [
    'ProductPicker',
    'SupplierPicker',
    'StockVoid',
    'StockOutShort',
    'ScanProductResult',
    'ScanProductNotFound',
  ])
    name: (context) => ErrorView(
      error: const AppError('请先从库存页面选择商品或单据', type: AppErrorType.notFound),
      onNext: () => Navigator.maybePop(context),
    ),
  'OrderRefund': (_) => ErrorView(error: const AppError('请先选择可退款订单')),
  'FindResult': (_) => ErrorView(error: const AppError('请先扫描车牌')),
  'FindNotFound': (_) => ErrorView(error: const AppError('请先扫描车牌')),
  'ScanPlateResult': (_) => ErrorView(error: const AppError('请先扫描车牌')),
  'OrderFilter': (_) => ErrorView(error: const AppError('请从订单列表打开筛选')),
  'StProgress': (_) => const StProgressSheet(),
  'DisableStaff': (_) => const DisableStaffSheet(),
  'StaffEnable': (_) => const StaffEnableSheet(),
  'StaffTransfer': (_) => const StaffTransferSheet(),
  // TODO: 字符串路由没有预约 ID；改期必须从真实预约卡片或详情进入。
  'AppointmentReschedule': (context) => ErrorView(
    error: const AppError('请先选择预约', type: AppErrorType.notFound),
    onNext: () => Navigator.of(context).maybePop(),
  ),
  'ThemeSheet': (_) => const ThemeSheet(),
  // 字符串路由没有选择上下文，正式编辑页使用类型化弹层。
  'PackageSvcPick': (_) => ErrorView(error: const AppError('请从套餐编辑页选择包含服务')),
};

/// 主 Tab 页面（首页 / 会员 / 库存 / 统计）。
const Map<String, int> tabRoutes = {
  'Main': 0,
  'Members': 1,
  'Inventory': 2,
  'Stats': 3,
};

/// Shell 是否在导航栈中（用于从登录/注册流程进入主界面）。
bool shellMounted = false;

Widget? pageFor(String name, {Object? arguments}) {
  final staff = arguments is StaffRouteData ? arguments : null;
  final task = arguments is TaskRouteData ? arguments : null;
  final memberData = arguments is MemberRouteData ? arguments : null;
  final receipt = arguments is WalletReceipt ? arguments : null;
  final orderData = arguments is OrderRouteData ? arguments : null;
  final memberPackage = arguments is MemberPackageRouteData ? arguments : null;
  switch (name) {
    case 'PaySuccess':
      return PaySuccessPage(
        receipt: arguments is OrderReceipt ? arguments : null,
      );
    case 'MemberAdjust':
      return MemberAdjustPage(member: memberData?.member);
    case 'MemberVisit':
      return MemberVisitPage(member: memberData?.member);
    case 'Recharge':
    case 'RechargeEmpty':
      return WalletPage(member: memberData?.member);
    case 'RechargeCard':
    case 'RechargeEmptyCard':
      return WalletPage(member: memberData?.member, initial: 1);
    case 'RechargeSuccess':
      return RechargeSuccessPage(receipt: receipt);
    case 'PackageSold':
      return PackageSoldPage(receipt: receipt);
    case 'PackageDetail':
      return PackageDetailPage(data: memberPackage);
    case 'ProductList':
      return const ProductListLivePage();
    case 'SupplierEdit':
      return const SupplierEditPage();
    case 'ProductEditExist':
      return ErrorView(
        error: const AppError('请先选择商品', type: AppErrorType.notFound),
      );
    case 'ProductEdit':
      return const ProductEditLivePage();
    case 'OrderList':
      return const OrderListLivePage();
    case 'OrderDetail':
      return OrderDetailLivePage(
        order: arguments is OrderDetailRef ? arguments : null,
      );
    case 'Expenses':
      return const ExpenseLivePage(mode: 'list');
    case 'ExpenseAdd':
      return const ExpenseLivePage(mode: 'add');
    case 'ExpenseDetail':
      return const ExpenseLivePage(mode: 'detail');
    case 'StockDocs':
      return const InventoryManagementPage(mode: 'docs');
    case 'StockDocsOut':
      return const InventoryManagementPage(mode: 'docs', initialTab: 1);
    case 'CategoryManage':
      return const InventoryManagementPage(mode: 'categories');
    case 'StockAlertSettings':
      return const InventoryManagementPage(mode: 'settings');
    case 'ScanProduct':
      return const InventoryManagementPage(mode: 'scan');
    case 'StockInDetail':
    case 'StockOutDetail':
      return const InventoryManagementPage(mode: 'document');
    case 'StockIn':
      return const InventoryLivePage(mode: 'in');
    case 'StockOut':
      return const InventoryLivePage(mode: 'out');
    case 'ProductDetail':
      return const InventoryLivePage(mode: 'detail');
    case 'Login':
      return const LoginPage();
    case 'Order':
      final customer = orderData?.member ?? memberData?.member;
      return OrderPage(
        member: customer == null ? null : memberFromRow(customer),
        hold: orderData?.hold,
        appointment: orderData?.appointment,
        walkIn: orderData?.walkIn ?? false,
        plate: orderData?.plate ?? '',
      );
    case 'Appointments':
      return const AppointmentsPage();
    case 'AppointmentSchedule':
      return const AppointmentsPage(initialView: 1);
    case 'AppointmentAdd':
      return const AppointmentAddPage();
    case 'AppointmentDetail':
      // TODO: 深链需要 appointment_id 参数；不再回退到生成页的示例客户。
      return Builder(
        builder: (context) => Scaffold(
          body: ErrorView(
            error: const AppError('请先选择预约', type: AppErrorType.notFound),
            onNext: () => openRoute(context, 'Appointments'),
          ),
        ),
      );
    case 'AppointmentSettings':
      return const AppointmentSettingsLivePage();
    case 'BusinessHours':
      return const BusinessHoursPage();
    case 'Staff':
      return const StaffResourcesPage();
    case 'StaffAdd':
      return StaffEditorPage(initialRole: staff?.role);
    case 'StaffEdit':
      return StaffEditLivePage(staffId: staff?.staffId);
    case 'StaffDetail':
      return StaffDetailLivePage(staffId: staff?.staffId);
    case 'StaffDetailOff':
      return StaffDetailOffLivePage(staffId: staff?.staffId);
    case 'StaffCommission':
      return StaffCommissionLivePage(staffId: staff?.staffId);
    case 'StaffRecords':
      return StaffRecordsLivePage(staffId: staff?.staffId);
    case 'StaffInvite':
      return StaffInviteLivePage(employee: staff?.employee);
    case 'RolePermission':
      return RolePermissionLivePage(initialRole: staff?.role ?? 'technician');
    case 'BayEdit':
      return const BayEditorPage();
    case 'MemberDetail':
      final live = memberData?.member;
      return merchantApi.hasSession && live != null
          ? MemberDetailPage(member: memberFromRow(live))
          : ErrorView(
              error: const AppError('请先选择会员', type: AppErrorType.notFound),
            );
    case 'MemberAdd':
      return MemberAddPage(vehicle: memberData?.vehicle);
    case 'MemberEdit':
      return MemberEditPage(member: memberData?.member);
    case 'VehicleAdd':
      return VehicleAddPage(
        member: memberData?.member,
        vehicle: memberData?.vehicle,
      );
    case 'MemberAddDone':
      return MemberAddDonePage(member: memberData?.member);
    case 'MemberRecords':
      return merchantApi.hasSession
          ? MemberRecordsLivePage(member: memberData?.member)
          : ErrorView(error: const AppError('请先登录', type: AppErrorType.auth));
    case 'Services':
      return const ServicesPage();
    case 'Settings':
      return const SettingsPage();
    case 'FindScanPlate':
      return const ScanPage(ScanKind.findPlate);
    case 'ScanPlate':
      return const ScanPage(ScanKind.plateCard);
  }
  final st = stPageFor(
    name,
    task: task,
    member: arguments is StMemberRouteData ? arguments : null,
  );
  if (st != null) return st;
  final b = pageBuilders[name];
  return b == null ? null : Builder(builder: b);
}

/// 记录导航栈中的页面名，用来判断“目标页是否已经打开过”。
class NavTracker extends NavigatorObserver {
  final List<Route<dynamic>> stack = [];
  bool has(String name) => stack.any((r) => r.settings.name == name);
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.add(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : stack.indexOf(oldRoute);
    if (i >= 0) {
      if (newRoute != null) {
        stack[i] = newRoute;
      } else {
        stack.removeAt(i);
      }
    } else if (newRoute != null) {
      stack.add(newRoute);
    }
  }
}

final NavTracker navTracker = NavTracker();

/// 结果页：覆盖在提交它的表单页之上，返回时不再回到表单。
const Set<String> resultPages = {
  'PaySuccess',
  'RechargeSuccess',
  'RegDone',
  'ForgotDone',
  'MemberAddDone',
  'PackageSold',
};

/// 左上角是 ✕ 的表单 / 流程页：用 iOS 整页 sheet 出场（`appSheetRoute`，见 lib/kit/sheet_route.dart）。
/// 不含结果页（禁止下拉返回）和相机扫描页（全屏相机）。
const Set<String> _cupertinoSheetPages = {
  'MemberAdd',
  'VehicleAdd',
  'AppointmentAdd',
  'StockIn',
  'StockOut',
  'ExpenseAdd',
  'StoreEdit',
  'ServiceEdit',
  'CardTierEdit',
  'MemberEdit',
  'MemberAdjust',
  'MemberVisit',
  'PackageEdit',
  'StaffAdd',
  'StaffEdit',
  'StaffInvite',
};

/// 全屏流程（相机扫描页）：从底部滑入，左上角是 ✕，全屏显示（设计稿“页面出场方式”第 4 类）。
const Set<String> _modalPages = {'ScanProduct', 'ScanPlate', 'FindScanPlate'};

String? _routeName(BuildContext context) =>
    ModalRoute.of(context)?.settings.name;

/// 按设计稿里的页面名跳转：
/// - 设计稿里叠在别的页面上的弹层，用底部弹层打开；
/// - 目标页已在栈中时回退到它，避免循环叠页；
/// - 同一界面的不同视图 / 结果页采用替换，保持返回逻辑与设计一致。
void openRoute(BuildContext context, String name, {Object? arguments}) =>
    _openRouteCore(context, name, arguments: arguments);

/// 没有对应权限时直达这些页面：显示「暂无权限访问」（设计稿 StNoPerm），入口本身已按权限隐藏。
const Map<String, (String, String)> _routeCaps = {
  'Staff': ('staff_view', '查看员工列表'),
  'Stats': ('stats_view_store', '查看门店营业统计'),
  'Expenses': ('expense', '开支管理'),
  'Inventory': ('stock_manage', '库存管理'),
  'Services': ('catalog_manage', '服务项目'),
  'CardTiers': ('catalog_manage', '会员卡种'),
  'CardPackages': ('catalog_manage', '次卡套餐'),
  'AppointmentSettings': ('appt_settings', '预约设置'),
};

bool _sameRoute(Route<dynamic> route, String name, Object? arguments) =>
    route.settings.name == name &&
    ((arguments is! StaffRouteData &&
            arguments is! TaskRouteData &&
            arguments is! MemberRouteData &&
            arguments is! WalletReceipt &&
            arguments is! MemberPackageRouteData &&
            arguments is! OrderRouteData &&
            arguments is! OrderReceipt &&
            arguments is! OrderDetailRef &&
            arguments is! StMemberRouteData) ||
        route.settings.arguments == arguments);

void _openRouteCore(BuildContext context, String name, {Object? arguments}) {
  final staff = arguments is StaffRouteData ? arguments : null;
  final task = arguments is TaskRouteData ? arguments : null;
  final memberData = arguments is MemberRouteData ? arguments : null;
  final memberPackage = arguments is MemberPackageRouteData ? arguments : null;
  final nav = Navigator.of(context);
  if (!Access.isOwner) {
    final need = _routeCaps[name];
    if (need != null && (need.$1 == 'owner' || !Access.can(need.$1))) {
      nav.push(MaterialPageRoute<void>(builder: (_) => staffNoPerm(need.$2)));
      return;
    }
    // 员工外壳的 Tab：切换底部导航，而不是再压一层页面
    final tab = staffTabIndex(name);
    if (tab != null && Access.usesStaffShell) {
      staffTab.value = tab;
      nav.popUntil((r) => r.isFirst);
      return;
    }
  }
  final cur = _routeName(context);
  final inSheet = cur != null && cur.startsWith('sheet:');
  if (inSheet) {
    nav.pop(); // 先收起当前弹层
    if (sheetParents[cur.substring(6)] == name ||
        (cur == 'sheet:ThemeSheet' && name == 'Settings')) {
      return; // 点遮罩 / 取消：回到所属页面
    }
  }
  if (name == 'CardTiers' || name == 'CardPackages') {
    final tab = name == 'CardTiers' ? CatalogTab.tiers : CatalogTab.packages;
    final existing = navTracker.stack
        .whereType<CatalogRoute>()
        .where((route) => route.navigator == nav)
        .lastOrNull;
    if (existing != null) {
      existing.select(tab);
      nav.popUntil((route) => identical(route, existing) || route.isFirst);
    } else {
      nav.push(CatalogRoute(tab));
    }
    return;
  }
  if (sheetRoutes.containsKey(name)) {
    if (navTracker.stack.any(
      (route) => _sameRoute(route, 'sheet:$name', arguments),
    )) {
      return; // 防止连点叠出两层遮罩
    }
    final nc = nav.context;
    showModalBottomSheet<void>(
      context: nc,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: RouteSettings(name: 'sheet:$name', arguments: arguments),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.94,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: switch (name) {
              'PackageExtend' => PackageExtendSheet(data: memberPackage),
              'PackageRefund' => PackageRefundSheet(data: memberPackage),
              'MemberMore' => MemberMoreSheet(member: memberData?.member),
              'MemberDelete' => MemberDeleteSheet(member: memberData?.member),
              'StProgress' => StProgressSheet(taskId: task?.taskId),
              'DisableStaff' => DisableStaffSheet(staffId: staff?.staffId),
              'StaffEnable' => StaffEnableSheet(staffId: staff?.staffId),
              'StaffTransfer' => StaffTransferSheet(staffId: staff?.staffId),
              _ => sheetRoutes[name]!(ctx),
            },
          ),
        ),
      ),
    );
    return;
  }
  if (tabRoutes.containsKey(name)) {
    tabIndex.value = tabRoutes[name]!;
    if (shellMounted) {
      nav.popUntil((r) => r.isFirst);
    } else {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Shell()),
        (_) => false,
      );
    }
    return;
  }
  if (name == 'Login' || name == 'LoginPwd') {
    // LoginPwd 是“密码登录”标签，与验证码登录是同一个登录页
    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Login'),
        builder: (_) => LoginPage(initialTab: name == 'LoginPwd' ? 1 : 0),
      ),
      (_) => false,
    );
    return;
  }
  final page = pageFor(name, arguments: arguments);
  if (page == null) return;
  if (const [
    'RechargeCard',
    'RechargeEmpty',
    'RechargeEmptyCard',
  ].contains(name)) {
    name = 'Recharge';
  }
  // 结果页（第 5 类）禁止下拉 / 侧滑返回，只能点主按钮或 ✕
  final locked = resultPages.contains(name);
  final Route<void> route = _cupertinoSheetPages.contains(name)
      ? appSheetRoute<void>(
          settings: RouteSettings(name: name, arguments: arguments),
          page: page,
        )
      : MaterialPageRoute<void>(
          settings: RouteSettings(name: name, arguments: arguments),
          fullscreenDialog: locked || _modalPages.contains(name),
          builder: (_) => locked ? PopScope(canPop: false, child: page) : page,
        );
  final found = navTracker.stack.any(
    (route) => _sameRoute(route, name, arguments),
  );
  if (found) {
    nav.popUntil((r) => _sameRoute(r, name, arguments) || r.isFirst);
    return;
  }
  if (resultPages.contains(name) && nav.canPop()) {
    nav.pushReplacement(route);
    return;
  }
  nav.push(route);
}
