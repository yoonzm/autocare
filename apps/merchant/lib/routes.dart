import 'pages/inventory_management_page.dart';
import 'pages/inventory_pickers.dart' show SupplierEditPage;
import 'pages/inventory_live_page.dart';
import 'pages/expense_live_page.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'kit/sheet_route.dart';

import 'backend/merchant_api.dart';
import 'backend/subscription_flow.dart';
import 'pages/subscription_live_host.dart';
import 'kit/async_kit.dart';
import 'kit/kit.dart' show hToast;
import 'backend/catalog_draft.dart';
import 'backend/member_flow.dart';
import 'backend/forgot_flow.dart';
import 'backend/registration_draft.dart';
import 'backend/store_profile.dart';
import 'mock/mock_data.dart';
import 'pages/appointment_add_page.dart';
import 'pages/appointments_page.dart';
import 'pages/appointment_settings_live_page.dart';
import 'pages/booking_resources_page.dart';
import 'pages/card_tiers_live_page.dart';
import 'pages/gen/gen_routes.dart';
import 'pages/gen/pay_config_unopened_page.dart';
import 'pages/login_page.dart';
import 'pages/member_detail_page.dart';
import 'pages/card_packages_live_page.dart';
import 'pages/member_add_page.dart';
import 'pages/member_records_live_page.dart';
import 'pages/order_page.dart';
import 'pages/order_live_pages.dart';
import 'pages/product_edit_live_page.dart';
import 'pages/product_list_live_page.dart';
import 'pages/store_switch_live_sheet.dart';
import 'pages/staff_live.dart';
import 'pages/staff_tabs.dart';
import 'pages/st_live.dart' show stLoadTask;
import 'pages/st_progress_template.dart';
import 'backend/access_flow.dart';
import 'pages/staff_detail_template.dart';
import 'pages/staff_detail_off_template.dart';
import 'pages/staff_commission_template.dart';
import 'pages/staff_records_template.dart';
import 'pages/staff_invite_template.dart';
import 'pages/role_permission_template.dart';
import 'pages/disable_staff_template.dart';
import 'pages/staff_transfer_template.dart';
import 'pages/staff_enable_template.dart';
import 'pages/package_svc_pick_live.dart';
import 'pages/services_page.dart';
import 'pages/settings_page.dart';
import 'pages/scan_page.dart';
import 'pages/plate_scan_result_live_sheet.dart';
import 'backend/scan_flow.dart';
import 'pages/shell.dart';
import 'pages/theme_sheet.dart';

final Map<String, WidgetBuilder> _allSheets = {
  ...genSheets,
  for (final name in [
    'ProductPicker',
    'SupplierPicker',
    'StockVoid',
    'StockOutShort',
    'StockCheckInput',
    'ScanProductResult',
    'ScanProductNotFound',
  ])
    name: (context) => ErrorView(
      error: const AppError('请先从库存页面选择商品或单据', type: AppErrorType.notFound),
      onNext: () => Navigator.maybePop(context),
    ),
  'Renew': (_) => const SubscriptionLiveHost('Renew'),
  'FindResult': (context) =>
      merchantApi.hasSession && ScanFlow.matched && ScanFlow.member != null
      ? genSheets['FindResult']!(context)
      : ErrorView(error: const AppError('请先扫描车牌')),
  'FindNotFound': (context) =>
      merchantApi.hasSession && ScanFlow.last != null && !ScanFlow.matched
      ? genSheets['FindNotFound']!(context)
      : ErrorView(error: const AppError('请先扫描车牌')),
  'ScanPlateResult': (_) =>
      merchantApi.hasSession && ScanFlow.matched && ScanFlow.member != null
      ? const PlateScanResultLiveSheet()
      : ErrorView(error: const AppError('请先扫描车牌')),
  'OrderFilter': (_) => const OrderFilterLiveSheet(),
  'StoreSwitch': (_) => const StoreSwitchLiveSheet(),
  'StProgress': (_) => StaffLiveHost(
    sheet: true,
    needsId: false,
    load: (_) => stLoadTask(),
    builder: (_, d) => StProgressTemplate(d: d),
  ),
  'DisableStaff': (_) => StaffLiveHost(
    sheet: true,
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => DisableStaffTemplate(d: d),
  ),
  'StaffEnable': (_) => StaffLiveHost(
    sheet: true,
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffEnableTemplate(d: d),
  ),
  'StaffTransfer': (_) => StaffLiveHost(
    sheet: true,
    load: loadTransferData,
    builder: (_, d) => StaffTransferTemplate(d: d),
  ),
  'BudgetAdjust': (_) => const ExpenseLivePage(mode: 'adjust'),
  // TODO: 字符串路由没有预约 ID；改期必须从真实预约卡片或详情进入。
  'AppointmentReschedule': (context) => ErrorView(
    error: const AppError('请先选择预约', type: AppErrorType.notFound),
    onNext: () => Navigator.of(context).maybePop(),
  ),
  'ThemeSheet': (_) => const ThemeSheet(),
  // 登录后用真实服务项目；未登录（设计预览）仍用设计稿的示例数据
  'PackageSvcPick': (ctx) => merchantApi.hasSession
      ? const PackageSvcPickLive()
      : genSheets['PackageSvcPick']!(ctx),
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

Widget? pageFor(String name) {
  switch (name) {
    case 'Plans':
    case 'PlanCheckout':
    case 'Subscription':
      return SubscriptionLiveHost(name);
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
    // TODO: 微信支付开通（进件）依赖服务商接口，目前没有开通能力，支付与收款的真实状态就是“未开通”，
    // 所以这里显示设计稿的“未开通”状态；已开通状态（PayConfig）等进件接通后再按真实状态切换。
    case 'PayConfig':
      return const PayConfigUnopenedPage();
    case 'OrderList':
      return const OrderListLivePage();
    case 'OrderDetail':
      return const OrderDetailLivePage();
    case 'Expenses':
      return const ExpenseLivePage(mode: 'list');
    case 'ExpenseAdd':
      return const ExpenseLivePage(mode: 'add');
    case 'ExpenseDetail':
      return const ExpenseLivePage(mode: 'detail');
    case 'ExpenseBudget':
      return const ExpenseLivePage(mode: 'budget');
    case 'BudgetTotal':
      return const ExpenseLivePage(mode: 'total');
    case 'BudgetEdit':
      return const ExpenseLivePage(mode: 'category');
    case 'StockDocs':
      return const InventoryManagementPage(mode: 'docs');
    case 'StockDocsOut':
      return const InventoryManagementPage(mode: 'docs', initialTab: 1);
    case 'StockDocsCheck':
      return const InventoryManagementPage(mode: 'docs', initialTab: 2);
    case 'CategoryManage':
      return const InventoryManagementPage(mode: 'categories');
    case 'StockAlertSettings':
      return const InventoryManagementPage(mode: 'settings');
    case 'StockCheckNew':
      return const InventoryManagementPage(mode: 'new');
    case 'ScanProduct':
      return const InventoryManagementPage(mode: 'scan');
    case 'StockInDetail':
    case 'StockOutDetail':
    case 'StockCheckResult':
      return const InventoryManagementPage(mode: 'document');
    case 'StockIn':
      return const InventoryLivePage(mode: 'in');
    case 'StockOut':
      return const InventoryLivePage(mode: 'out');
    case 'StockCheck':
      return const InventoryLivePage(mode: 'check');
    case 'ProductDetail':
      return const InventoryLivePage(mode: 'detail');
    case 'Login':
      return const LoginPage();
    case 'Order':
      // 登录后从会员详情 / 次卡详情 / 收款成功页进入时，沿用当前会员
      final cur = MemberFlow.current;
      return OrderPage(
        member: merchantApi.hasSession && cur != null
            ? memberFromRow(cur)
            : null,
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
      return const BookingResourcesPage(kind: 'bay');
    case 'Staff':
      return const BookingResourcesPage(kind: 'technician');
    case 'StaffAdd':
      return const BookingResourceEditor(kind: 'technician');
    case 'StaffEdit':
      return const StaffEditLivePage();
    case 'StaffDetail':
      return const StaffDetailLivePage();
    case 'StaffDetailOff':
      return const StaffDetailOffLivePage();
    case 'StaffCommission':
      return const StaffCommissionLivePage();
    case 'StaffRecords':
      return const StaffRecordsLivePage();
    case 'StaffInvite':
      return const StaffInviteLivePage();
    case 'RolePermission':
      return const RolePermissionLivePage();
    case 'BayEdit':
      return const BookingResourceEditor(kind: 'bay');
    case 'MemberDetail':
      final live = MemberFlow.current;
      return MemberDetailPage(
        member: merchantApi.hasSession && live != null
            ? memberFromRow(live)
            : members.first,
      );
    case 'MemberAdd':
      return ValueListenableBuilder<int>(
        valueListenable: ScanFlow.prefillTick,
        builder: (_, tick, _) => MemberAddPage(key: ValueKey(tick)),
      );
    case 'MemberRecords':
      // 登录后看真实流水；设计预览沿用设计稿的示例记录
      if (merchantApi.hasSession) return const MemberRecordsLivePage();
    case 'Services':
      return const ServicesPage();
    case 'Settings':
      return const SettingsPage();
    case 'FindScanPlate':
      return const ScanPage(ScanKind.findPlate);
    case 'FindScanCode':
      return const ScanPage(ScanKind.findCode);
    case 'ScanLicense':
      return const ScanPage(ScanKind.licenseCard);
    case 'ScanPlate':
      return const ScanPage(ScanKind.plateCard);
  }
  final st = stPageFor(name);
  if (st != null) return st;
  final b = genRoutes[name];
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
  'PayUnbound',
  'RechargeSuccess',
  'PlanPaid',
  'RenewPaid',
  'RegDone',
  'ForgotDone',
  'MemberAddDone',
  'BindDone',
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
  'StockCheck',
  'ExpenseAdd',
  'BudgetTotal',
  'BudgetEdit',
  'StoreEdit',
  'ServiceEdit',
  'CardTierEdit',
  'MemberEdit',
  'MemberAdjust',
  'MemberVisit',
  'MemberSendMsg',
  'PackageEdit',
  'StaffAdd',
  'StaffEdit',
  'StaffInvite',
  'StoreAdd',
};

/// 全屏流程（相机扫描页）：从底部滑入，左上角是 ✕，全屏显示（设计稿“页面出场方式”第 4 类）。
const Set<String> _modalPages = {
  'ScanProduct',
  'ScanLicense',
  'ScanPlate',
  'FindScanPlate',
  'FindScanCode',
};

/// 同一页面里的两个 Tab：设计稿把它们画成两张图，实际是一个页面里切换。
/// 键是页面（路由）名，值是依次对应的两个设计稿页面。
const Map<String, List<String>> _pairs = {
  'Recharge': ['Recharge', 'RechargeCard'],
  'CardTiers': ['CardTiers', 'CardPackages'],

  // 库存单据的三个页签（入库 / 出库 / 盘点）：设计稿把每个状态画成一张图，实际是同一个页面里切换。
  // （商品列表的四个筛选是 ProductListLivePage 里的页签。）
};
final Map<String, ValueNotifier<int>> pairTabs = {
  for (final k in _pairs.keys) k: ValueNotifier<int>(0),
};

/// 未选会员时的充值页：两个页签是 RechargeEmpty / RechargeEmptyCard，和 Recharge / RechargeCard 共用一个页面。
const Map<String, (String, int)> _pairAlias = {
  'RechargeEmpty': ('Recharge', 0),
  'RechargeEmptyCard': ('Recharge', 1),
};
String? _pairOf(String name) {
  if (_pairAlias.containsKey(name)) return _pairAlias[name]!.$1;
  for (final e in _pairs.entries) {
    if (e.value.contains(name)) return e.key;
  }
  return null;
}

int _pairIndex(String pairId, String name) =>
    _pairAlias[name]?.$2 ?? _pairs[pairId]!.indexOf(name);

class PairPage extends StatefulWidget {
  final String id;
  final int initial;
  const PairPage(this.id, this.initial, {super.key});
  @override
  State<PairPage> createState() => _PairPageState();
}

class _PairPageState extends State<PairPage> {
  @override
  void initState() {
    super.initState();
    pairTabs[widget.id]!.value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    // 会员充值：从首页进入时还没选会员，显示设计稿的“未选会员”页；选了会员后换成充值页
    if (widget.id == 'Recharge' && merchantApi.hasSession) {
      return ListenableBuilder(
        listenable: MemberFlow.memberTick,
        builder: (context, _) => MemberFlow.current == null
            ? ValueListenableBuilder<int>(
                valueListenable: pairTabs[widget.id]!,
                builder: (context, i, _) => IndexedStack(
                  index: i,
                  children: [
                    Builder(builder: genRoutes['RechargeEmpty']!),
                    Builder(builder: genRoutes['RechargeEmptyCard']!),
                  ],
                ),
              )
            : _tabs(),
      );
    }
    return _tabs();
  }

  Widget _tabs() => ValueListenableBuilder<int>(
    valueListenable: pairTabs[widget.id]!,
    builder: (context, i, _) => IndexedStack(
      index: i,
      children: [
        for (final n in _pairs[widget.id]!)
          n == 'CardTiers' && merchantApi.hasSession
              ? const CardTiersLivePage()
              : n == 'CardPackages' && merchantApi.hasSession
              ? const CardPackagesLivePage()
              : Builder(builder: genRoutes[n]!),
      ],
    ),
  );
}

String? _routeName(BuildContext context) =>
    ModalRoute.of(context)?.settings.name;

/// 按设计稿里的页面名跳转：
/// - 设计稿里叠在别的页面上的弹层，用底部弹层打开；
/// - 目标页已在栈中时回退到它，避免循环叠页；
/// - 同一界面的不同视图 / 结果页采用替换，保持返回逻辑与设计一致。
void openRoute(BuildContext context, String name) {
  final current = ModalRoute.of(context)?.settings.name;
  if (name == 'Renew') {
    if (storeProfile.plan == 'trial') {
      openRoute(context, 'Plans');
      return;
    }
    subscriptionFlow.plan = storeProfile.plan;
    subscriptionFlow.months = 12;
  }
  if (name == 'RegShop' && current == 'RegPhone') {
    final problem = RegistrationDraft.phoneStepError();
    if (problem != null) {
      hToast(context, problem);
      return;
    }
    unawaited(_continueToShop(context));
    return;
  }
  if (name == 'RegDone' && current == 'RegShop') {
    final problem = RegistrationDraft.shopStepError();
    if (problem != null) {
      hToast(context, problem);
      return;
    }
  }
  if (name == 'RegDone' && ModalRoute.of(context)?.settings.name == 'RegShop') {
    unawaited(_completeRegistration(context));
    return;
  }
  // 忘记密码（登录页和修改密码页两个入口共用这三页，不需要登录）
  if (name == 'ForgotReset' && current == 'ForgotVerify') {
    final problem = RegistrationDraft.forgotVerifyError();
    if (problem != null) {
      AppToast.show(context, problem, kind: ToastKind.error);
      return;
    }
    unawaited(_forgotVerify(context));
    return;
  }
  if (name == 'ForgotDone' && current == 'ForgotReset') {
    if (!forgotFlow.live) {
      AppToast.show(context, '请先验证手机号', kind: ToastKind.error);
      return;
    }
    final problem = RegistrationDraft.forgotResetError(forgotFlow.phone);
    if (problem != null) {
      AppToast.show(context, problem, kind: ToastKind.error);
      return;
    }
    unawaited(_forgotReset(context));
    return;
  }
  // 账号与安全：这几个页面的主按钮都接了真实后端（需已登录）。
  if (merchantApi.hasSession) {
    if (name == 'Security' && current == 'ChangePassword') {
      unawaited(_changePassword(context));
      return;
    }
    if (name == 'Security' && current == 'ChangePhone') {
      unawaited(_changePhone(context));
      return;
    }
    if (name == 'Login' && current == 'DeleteAccount') {
      unawaited(_deleteAccount(context));
      return;
    }
    if (name == 'Login' && current == 'Security') {
      unawaited(_signOutEverywhere(context));
      return;
    }
  }
  if (merchantApi.hasSession &&
      name == 'ServiceEdit' &&
      CatalogDraft.current?.kind != 'services') {
    CatalogDraft.begin('services');
  }
  if (merchantApi.hasSession &&
      name == 'CardTierEdit' &&
      CatalogDraft.current?.kind != 'cards') {
    CatalogDraft.begin('cards');
  }
  if (merchantApi.hasSession &&
      name == 'PackageEdit' &&
      CatalogDraft.current?.kind != 'packages') {
    CatalogDraft.begin('packages');
  }
  // 记录回访 / 回访提醒：进入时读取历史回访 / 今日提醒
  if (merchantApi.hasSession && name == 'MemberVisit') {
    unawaited(MemberFlow.beginVisit());
  }
  if (merchantApi.hasSession && name == 'MemberFollowUp') {
    MemberFlow.reminderTab.value = 0;
    unawaited(MemberFlow.loadReminders());
  }
  // 次卡延期 / 退款：每次打开都重新开始（原因要自己选）
  if (merchantApi.hasSession && name == 'PackageExtend') {
    MemberFlow.beginExtend();
  }
  if (merchantApi.hasSession && name == 'PackageRefund') {
    MemberFlow.beginRefund();
  }
  // 调整卡种与积分：每次进入都重新开始，并读取本店卡种
  if (merchantApi.hasSession && name == 'MemberAdjust') {
    unawaited(MemberFlow.beginAdjust());
  }
  // 从首页等没带会员的入口进入充值 / 开单：不沿用上次看过的会员，先选会员
  if (merchantApi.hasSession &&
      (name == 'Recharge' || name == 'RechargeCard' || name == 'Order') &&
      (current == null || current == '/') &&
      context.findAncestorWidgetOfExactType<MemberDetailPage>() == null) {
    MemberFlow.current = null;
    MemberFlow.memberTick.value++;
  }
  // 充值表单每次进入都重新开始（默认 ¥2,000、微信）
  if (merchantApi.hasSession &&
      (name == 'Recharge' || name == 'RechargeCard')) {
    MemberFlow.beginRecharge();
  }
  // 新增会员从任何入口进入都从空白草稿开始（上次没保存的内容不带过来）
  if (merchantApi.hasSession && name == 'MemberAdd') {
    if (current == 'sheet:FindNotFound' &&
        navTracker.has('MemberAdd') &&
        CatalogDraft.current?.kind == 'members') {
      // A member form can open the scanner. Keep its existing customer inputs
      // and rebind its vehicle controls when returning with recognition data.
      MemberFlow.applyRecognizedVehicle();
      ScanFlow.prefillTick.value++;
    } else {
      MemberFlow.beginAdd();
    }
  }
  if (merchantApi.hasSession &&
      name == 'MemberEdit' &&
      MemberFlow.current != null &&
      CatalogDraft.current?.id != MemberFlow.current!['id']) {
    MemberFlow.beginEdit(MemberFlow.current!);
  }
  _openRouteCore(context, name);
}

/// Rejects a wrong or expired code now instead of at the very last step.
Future<void> _continueToShop(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('RegPhone>RegShop', () async {
    try {
      await merchantApi.checkCode(
        RegistrationDraft.get('RegPhone', '请输入手机号'),
        RegistrationDraft.get('RegPhone', '6 位数字'),
      );
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (ok && context.mounted) _openRouteCore(context, 'RegShop');
}

Future<void> _completeRegistration(BuildContext context) async {
  final phone = RegistrationDraft.get('RegPhone', '请输入手机号');
  final code = RegistrationDraft.get('RegPhone', '6 位数字');
  final password = RegistrationDraft.getRaw('RegPhone', '8-20 位，含字母和数字');
  final storeName = RegistrationDraft.get('RegShop', '如：驰光汽车美容');
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('RegShop>RegDone', () async {
    try {
      final created = await merchantApi.register(
        phone: phone,
        code: code,
        password: password,
        storeName: storeName,
        profile: RegistrationDraft.profile(),
      );
      await merchantApi.loginPassword(phone, password);
      await storeProfile.load(); // 「开通成功」页展示真实的门店名、手机号和试用期
      final seeded = created['services'];
      if (seeded is num) storeProfile.seededServices = seeded.toInt();
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        '开通失败：${AppError.from(e).message}',
        kind: ToastKind.error,
      );
    }
  });
  if (!ok || !context.mounted) return;
  RegistrationDraft.clear();
  _openRouteCore(context, 'RegDone');
}

/// 忘记密码第 1 步：服务端校验验证码，且该手机号是已开通门店的账号。
Future<void> _forgotVerify(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final phone = RegistrationDraft.get('ForgotVerify', '请输入手机号');
  final code = RegistrationDraft.get('ForgotVerify', '6 位数字');
  var ok = false;
  await runBusy('ForgotVerify>ForgotReset', () async {
    try {
      await merchantApi.forgotVerify(phone, code);
      forgotFlow.verified(phone, code);
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (ok && context.mounted) _openRouteCore(context, 'ForgotReset');
}

/// 忘记密码第 2 步：设置新密码。成功后所有设备（包括当前设备）都要重新登录。
Future<void> _forgotReset(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('ForgotReset>ForgotDone', () async {
    try {
      await merchantApi.resetPassword(
        phone: forgotFlow.phone,
        code: forgotFlow.code,
        newPassword: RegistrationDraft.getRaw('ForgotReset', '8-20 位，含字母和数字'),
      );
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (!ok) return;
  // 服务端已让所有会话失效；本机若还登录着，也清掉本地登录态
  if (merchantApi.hasSession) {
    try {
      await merchantApi.signOut();
    } catch (_) {
      // 会话已被服务端作废，本地退出失败不影响结果
    }
  }
  storeProfile.clear();
  forgotFlow.clear();
  RegistrationDraft.clearRoute('ForgotVerify');
  RegistrationDraft.clearRoute('ForgotReset');
  if (context.mounted) _openRouteCore(context, 'ForgotDone');
}

Future<void> _changePassword(BuildContext context) async {
  final problem = RegistrationDraft.passwordChangeError(
    storeProfile.localPhone,
  );
  if (problem != null) {
    AppToast.show(context, problem, kind: ToastKind.error);
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('ChangePassword>Security', () async {
    try {
      await merchantApi.changePassword(
        RegistrationDraft.getRaw('ChangePassword', '请输入当前密码'),
        RegistrationDraft.getRaw('ChangePassword', '8-20 位，含字母和数字'),
      );
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (!ok || !context.mounted) return;
  RegistrationDraft.clearRoute('ChangePassword');
  AppToast.showOn(messenger, '密码已修改', kind: ToastKind.success);
  _openRouteCore(context, 'Security');
}

Future<void> _changePhone(BuildContext context) async {
  final problem = RegistrationDraft.phoneChangeError(storeProfile.localPhone);
  if (problem != null) {
    AppToast.show(context, problem, kind: ToastKind.error);
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('ChangePhone>Security', () async {
    try {
      await merchantApi.changePhone(
        code: RegistrationDraft.get('ChangePhone', '6 位数字'),
        newPhone: RegistrationDraft.get('ChangePhone', '请输入新手机号'),
        newCode: RegistrationDraft.get('ChangePhone', '6 位数字', 1),
      );
      await storeProfile.load();
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (!ok || !context.mounted) return;
  RegistrationDraft.clearRoute('ChangePhone');
  AppToast.showOn(messenger, '手机号已更换，请用新手机号登录', kind: ToastKind.success);
  _openRouteCore(context, 'Security');
}

/// 申请注销：设计稿此页没有“获取验证码”按钮，所以验证码为空时点“申请注销”
/// 会先把验证码发到当前手机号，填好后再点一次才真正提交。
/// TODO: 注销前置条件（挂单 / 欠费）目前是设计稿示例，没有真实校验。
Future<void> _deleteAccount(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('DeleteAccount>Login', () async {
    try {
      final problem = RegistrationDraft.deleteError();
      if (problem != null) {
        AppToast.showOn(messenger, problem, kind: ToastKind.error);
        return;
      }
      await merchantApi.deleteAccount(
        RegistrationDraft.get('DeleteAccount', '6 位数字'),
      );
      try {
        await merchantApi.signOut();
      } catch (_) {
        // 服务端已作废全部会话，本地退出失败不影响结果。
      }
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  });
  if (!ok || !context.mounted) return;
  RegistrationDraft.clearRoute('DeleteAccount');
  AppToast.showOn(messenger, '已提交注销申请，15 天内重新登录可撤销', kind: ToastKind.success);
  _openRouteCore(context, 'Login');
}

Future<void> _signOutEverywhere(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  await runBusy('Security>Login', () async {
    try {
      await merchantApi.signOutAll();
      ok = true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        '退出失败：${AppError.from(e).message}',
        kind: ToastKind.error,
      );
    }
  });
  if (ok && context.mounted) _openRouteCore(context, 'Login');
}

/// 没有对应权限时直达这些页面：显示「暂无权限访问」（设计稿 StNoPerm），入口本身已按权限隐藏。
const Map<String, (String, String)> _routeCaps = {
  'Staff': ('staff_view', '查看员工列表'),
  'Stats': ('stats_view_store', '查看门店营业统计'),
  'Expenses': ('expense', '开支管理'),
  'Inventory': ('stock_manage', '库存管理'),
  'Services': ('catalog_manage', '服务项目'),
  'CardTiers': ('catalog_manage', '会员卡种'),
  'AppointmentSettings': ('appt_settings', '预约设置'),
  'Plans': ('owner', '套餐与订阅'),
  'Subscription': ('owner', '套餐与订阅'),
};

void _openRouteCore(BuildContext context, String name) {
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
    // 选择会员弹层的关闭按钮指向“未选会员的充值页”；不是从充值页打开的（如开单页），只关闭弹层
    if (cur == 'sheet:MemberPicker' &&
        name == 'RechargeEmpty' &&
        !navTracker.has('Recharge')) {
      return;
    }
  }
  final pairId = _pairOf(name);
  if (pairId != null) {
    final idx = _pairIndex(pairId, name);
    if (navTracker.has(pairId)) {
      nav.popUntil((r) => r.settings.name == pairId || r.isFirst);
      pairTabs[pairId]!.value = idx;
    } else {
      nav.push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: pairId),
          builder: (_) => PairPage(pairId, idx),
        ),
      );
    }
    return;
  }
  if (_allSheets.containsKey(name)) {
    if (navTracker.has('sheet:$name')) {
      return; // 防止连点叠出两层遮罩
    }
    final nc = nav.context;
    showModalBottomSheet<void>(
      context: nc,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: RouteSettings(name: 'sheet:$name'),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.94,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: _allSheets[name]!(ctx),
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
  final page = pageFor(name);
  if (page == null) return;
  if (name == 'PlanPaid' || name == 'RenewPaid') {
    if (subscriptionFlow.receipt.isEmpty) {
      AppToast.show(context, '请先完成订阅');
      return;
    }
  }
  // 结果页（第 5 类）禁止下拉 / 侧滑返回，只能点主按钮或 ✕
  final locked = resultPages.contains(name);
  final Route<void> route = _cupertinoSheetPages.contains(name)
      ? appSheetRoute<void>(
          settings: RouteSettings(name: name),
          page: page,
        )
      : MaterialPageRoute<void>(
          settings: RouteSettings(name: name),
          fullscreenDialog: locked || _modalPages.contains(name),
          builder: (_) => locked ? PopScope(canPop: false, child: page) : page,
        );
  final found = navTracker.has(name);
  if (found) {
    nav.popUntil((r) => r.settings.name == name || r.isFirst);
    return;
  }
  if (resultPages.contains(name) && nav.canPop()) {
    nav.pushReplacement(route);
    return;
  }
  nav.push(route);
}
