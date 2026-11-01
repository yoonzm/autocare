import 'dart:async';

import 'package:flutter/material.dart';

import 'backend/merchant_api.dart';
import 'backend/registration_draft.dart';
import 'mock/app_state.dart';
import 'mock/mock_data.dart';
import 'pages/appointment_add_page.dart';
import 'pages/appointments_page.dart';
import 'pages/gen/gen_routes.dart';
import 'pages/login_page.dart';
import 'pages/member_detail_page.dart';
import 'pages/order_page.dart';
import 'pages/services_page.dart';
import 'pages/settings_page.dart';
import 'pages/scan_page.dart';
import 'pages/shell.dart';
import 'pages/theme_sheet.dart';

final Map<String, WidgetBuilder> _allSheets = {
  ...genSheets,
  'ThemeSheet': (_) => const ThemeSheet(),
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
    case 'Login':
      return const LoginPage();
    case 'Order':
      return const OrderPage();
    case 'Appointments':
      return const AppointmentsPage();
    case 'AppointmentSchedule':
      return const AppointmentsPage(initialView: 1);
    case 'AppointmentAdd':
      return const AppointmentAddPage();
    case 'MemberDetail':
      return MemberDetailPage(member: members.first);
    case 'Services':
      // TODO: Bind the existing designed list/edit screens to merchantApi.list/save.
      // The generated edit form has no stable record ID or input contract yet.
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
  'MemberAddDone',
  'BindDone',
  'PackageSold',
};

/// 表单卡片 / 全屏流程：从底部滑入，左上角是 ✕（设计稿“页面出场方式”第 3、4 类）。
const Set<String> _modalPages = {
  'MemberAdd',
  'VehicleAdd',
  'AppointmentAdd',
  'StockIn',
  'StockOut',
  'ExpenseAdd',
  'BudgetTotal',
  'BudgetEdit',
  'StoreEdit',
  'ServiceEdit',
  'CardTierEdit',
  'StockCheck',
  'MemberEdit',
  'MemberAdjust',
  'MemberVisit',
  'MemberSendMsg',
  'PackageEdit',
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
};
final Map<String, ValueNotifier<int>> pairTabs = {
  for (final k in _pairs.keys) k: ValueNotifier<int>(0),
};
String? _pairOf(String name) {
  for (final e in _pairs.entries) {
    if (e.value.contains(name)) return e.key;
  }
  return null;
}

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
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: pairTabs[widget.id]!,
    builder: (context, i, _) => IndexedStack(
      index: i,
      children: [
        for (final n in _pairs[widget.id]!) Builder(builder: genRoutes[n]!),
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
  if (name == 'RegDone' && ModalRoute.of(context)?.settings.name == 'RegShop') {
    unawaited(_completeRegistration(context));
    return;
  }
  // TODO: Generated service/card edit and card list pages still show fixed
  // design-sample values. Bind them through a stable page adapter before
  // enabling save; never imply their prototype buttons persisted data.
  if (name == 'ServiceEdit' || name == 'CardTiers' || name == 'CardTierEdit') {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('此页面暂为设计预览，数据编辑尚未接通')));
  }
  if ((name == 'Services' && _routeName(context) == 'ServiceEdit') ||
      (name == 'CardTiers' && _routeName(context) == 'CardTierEdit')) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('此编辑页尚未接通，未保存更改')));
  }
  _openRouteCore(context, name);
}

Future<void> _completeRegistration(BuildContext context) async {
  final phone = RegistrationDraft.get('RegPhone', '请输入手机号');
  final code = RegistrationDraft.get('RegPhone', '6 位数字');
  final password = RegistrationDraft.get('RegPhone', '8-20 位，含字母和数字');
  final storeName = RegistrationDraft.get('RegShop', '如：驰光汽车美容');
  try {
    await merchantApi.register(
      phone: phone,
      code: code,
      password: password,
      storeName: storeName,
    );
    await merchantApi.loginPassword(phone, password);
    if (!context.mounted) return;
    RegistrationDraft.clear();
    _openRouteCore(context, 'RegDone');
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('开通失败：$e')));
    }
  }
}

void _openRouteCore(BuildContext context, String name) {
  final nav = Navigator.of(context);
  final cur = _routeName(context);
  final inSheet = cur != null && cur.startsWith('sheet:');
  if (inSheet) {
    nav.pop(); // 先收起当前弹层
    if (sheetParents[cur.substring(6)] == name ||
        (cur == 'sheet:ThemeSheet' && name == 'Settings')) {
      return; // 点遮罩 / 取消：回到所属页面
    }
  }
  final pairId = _pairOf(name);
  if (pairId != null) {
    // TODO: Bind CardTiers/CardTierEdit to merchantApi without changing design.
    final idx = _pairs[pairId]!.indexOf(name);
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
  if (name == 'Login') {
    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Login'),
        builder: (_) => const LoginPage(),
      ),
      (_) => false,
    );
    return;
  }
  final page = pageFor(name);
  if (page == null) return;
  if (name == 'PlanPaid' || name == 'RenewPaid') {
    subState.value = SubState.normal;
  }
  // 结果页（第 5 类）禁止下拉 / 侧滑返回，只能点主按钮或 ✕
  final locked = resultPages.contains(name);
  final route = MaterialPageRoute<void>(
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
