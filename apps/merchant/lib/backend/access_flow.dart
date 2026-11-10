import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../kit/async_kit.dart';
import '../pages/access_pages.dart';
import '../pages/login_page.dart';
import '../pages/shell.dart';
import '../pages/staff_tabs.dart';
import 'merchant_api.dart';
import 'store_context.dart';
import 'store_profile.dart';

/// 登录后的身份与权限（合并后的 App：老板 / 店长 / 前台收银 / 施工技师）。
/// 页面入口只用 [Access.can] 决定显示什么；权限由服务端逐请求校验，前端隐藏不是安全边界。
class Access {
  Access._();

  /// owner | manager | cashier | technician
  static String role = 'owner';
  static Map<String, bool> caps = const {};
  static Map<String, dynamic> context = const {};

  /// 重新读取身份后通知外壳（权限调整、停用、套餐到期）。
  static final changed = ValueNotifier<int>(0);

  static bool get isOwner => role == 'owner';

  /// 员工外壳（前台 / 技师）；老板与店长使用商家外壳。
  static bool get usesStaffShell => role == 'cashier' || role == 'technician';
  static String get storeName => '${context['store_name'] ?? ''}';
  static String get userName => '${context['name'] ?? ''}';
  static bool get planExpired => context['plan_expired'] == true;

  /// 老板拥有全部权限；其余身份取服务端算好的生效权限。
  static bool can(String key) => isOwner || caps[key] == true;

  static String roleName([String? r]) => switch (r ?? role) {
    'owner' => '老板',
    'manager' => '店长',
    'cashier' => '前台收银',
    _ => '施工技师',
  };

  /// 页头里的简称（设计稿写「技师」而不是「施工技师」）。
  static String roleBrief([String? r]) => (r ?? role) == 'technician' ? '技师' : roleName(r);

  static const _kRole = 'access_role';

  static void apply(Map<String, dynamic> ctx) {
    context = ctx;
    role = '${ctx['role'] ?? 'owner'}';
    caps = {
      for (final e in ((ctx['caps'] as Map?) ?? const {}).entries)
        '${e.key}': e.value == true,
    };
    final store = ctx['store_id'];
    if (store != null) StoreContext.bind('$store');
    changed.value++;
  }

  static void clear() {
    // 只有保存过员工 / 店长身份时才需要清本机记录
    final persisted = role != 'owner';
    role = 'owner';
    caps = const {};
    context = const {};
    changed.value++;
    if (persisted) _persist(null);
  }

  /// 启动时读回上次的身份类型：员工身份走员工启动流程，其余沿用商家启动流程。
  static Future<String?> restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_kRole);
      if (saved != null) role = saved;
      return saved;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persist(String? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value == null) {
        await prefs.remove(_kRole);
      } else {
        await prefs.setString(_kRole, value);
      }
    } catch (_) {
      // 本机存储不可用时，下次启动重新选择身份
    }
  }

  static Future<void> remember() => _persist(role);
}

/// 登录后的分流：没有身份 → 登录失败页；一个身份 → 直接进入；多个 → 选择身份。
class AccessFlow {
  AccessFlow._();

  static List<Map<String, dynamic>> items = const [];
  static String phone = '';

  static Future<void> afterLogin(BuildContext context, String phone) async {
    AccessFlow.phone = phone;
    final data = await merchantApi.identity('list');
    items = [
      for (final i in (data['items'] as List)) Map<String, dynamic>.from(i as Map),
    ];
    if (!context.mounted) return;
    if (items.isEmpty) {
      _replace(context, StAuthFailTemplate(phone: phone));
    } else if (items.length == 1) {
      await enter(context, items.first);
    } else {
      _replace(context, const StIdentityLivePage());
    }
  }

  /// 选择身份并进入对应外壳。待确认加入的员工身份先到「加入门店」。
  static Future<void> enter(BuildContext context, Map<String, dynamic> item) async {
    final staffId = item['kind'] == 'staff' ? '${item['staff_id']}' : null;
    await merchantApi.identity('select', {'staff_id': staffId});
    final ctx = await merchantApi.identity('context');
    Access.apply(ctx);
    await Access.remember();
    if (!context.mounted) return;
    if (ctx['status'] == 'pending') {
      _replace(context, const StAuthLivePage());
      return;
    }
    await open(context);
  }

  /// 加入确认之后 / 重新读取身份之后：按身份进入外壳。
  static Future<void> open(BuildContext context) async {
    if (Access.planExpired && !Access.isOwner) {
      _replace(context, const StPlanExpiredLivePage());
      return;
    }
    if (Access.usesStaffShell) {
      _replace(context, const StaffTabs());
      return;
    }
    await storeProfile.load();
    if (!context.mounted) return;
    _replace(context, const Shell());
  }

  static void _replace(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
  }

  /// 员工确认加入门店（首次登录）。
  static Future<void> join(BuildContext context) async {
    await merchantApi.identity('join');
    final ctx = await merchantApi.identity('context');
    Access.apply(ctx);
    if (!context.mounted) return;
    await open(context);
  }

  /// 刷新身份与权限（套餐到期页「刷新状态」、下拉刷新、被调整权限后）。
  static Future<void> refresh(BuildContext context) async {
    final ctx = await merchantApi.identity('context');
    Access.apply(ctx);
    if (!context.mounted) return;
    await open(context);
  }

  /// 「我的 → 切换身份」：重新列出身份。
  static Future<void> switchIdentity(BuildContext context) async {
    final data = await merchantApi.identity('list');
    items = [
      for (final i in (data['items'] as List)) Map<String, dynamic>.from(i as Map),
    ];
    if (!context.mounted) return;
    _replace(context, const StIdentityLivePage());
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await merchantApi.signOut();
    } catch (_) {
      // 会话已被服务端作废，本地退出失败不影响结果
    }
    Access.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  static void toastError(BuildContext context, Object e) {
    if (context.mounted) AppToast.error(context, e);
  }
}
