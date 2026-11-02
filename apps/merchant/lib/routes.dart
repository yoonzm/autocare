import 'dart:async';

import 'package:flutter/material.dart';

import 'backend/merchant_api.dart';
import 'kit/async_kit.dart';
import 'kit/kit.dart' show hToast;
import 'backend/catalog_draft.dart';
import 'backend/forgot_flow.dart';
import 'backend/registration_draft.dart';
import 'backend/store_profile.dart';
import 'mock/app_state.dart';
import 'mock/mock_data.dart';
import 'pages/appointment_add_page.dart';
import 'pages/appointments_page.dart';
import 'pages/card_tiers_live_page.dart';
import 'pages/gen/gen_routes.dart';
import 'pages/login_page.dart';
import 'pages/member_detail_page.dart';
import 'pages/card_packages_live_page.dart';
import 'pages/order_page.dart';
import 'pages/package_svc_pick_live.dart';
import 'pages/services_page.dart';
import 'pages/settings_page.dart';
import 'pages/scan_page.dart';
import 'pages/shell.dart';
import 'pages/theme_sheet.dart';

final Map<String, WidgetBuilder> _allSheets = {
  ...genSheets,
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
  'ForgotDone',
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
      if (RegistrationDraft.get('DeleteAccount', '6 位数字').isEmpty) {
        final code = await merchantApi.sendMockCode(storeProfile.localPhone);
        AppToast.showOn(
          messenger,
          '验证码已发送至 ${storeProfile.maskedPhone}（开发环境：$code），填写后再次点击“申请注销”',
        );
        return;
      }
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
