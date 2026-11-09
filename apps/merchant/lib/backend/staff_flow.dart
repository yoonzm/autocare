import 'package:flutter/foundation.dart';

import '../kit/async_kit.dart' show kIndicatorMinShow;
import 'merchant_api.dart';

/// 员工模块的跨页状态：当前查看的员工、邀请结果、转交目标。
/// 业务规则（角色、权限、提成、停用与转交）都在云函数 / 数据库事务里执行，这里只提交输入。
class StaffFlow {
  StaffFlow._();

  /// 员工数据变化（新增 / 编辑 / 停用 / 启用 / 提成 / 权限）后通知各页面重新读取。
  static final changed = ValueNotifier<int>(0);
  static void notify() => changed.value++;

  /// 正在查看 / 编辑 / 停用的员工 ID（跨路由名传递，路由名不带参数）。
  static String? currentId;

  /// 刚新增的员工（邀请页展示）：后端返回的整条员工记录。
  static Map<String, dynamic>? invited;

  /// 停用时选择的接手技师（员工 ID）。
  static String? transferTo;

  /// 角色权限页默认打开的角色：cashier / technician。
  static String permissionRole = 'technician';

  /// 从「角色下无员工」点「添加店长」等进入新增页时，预选该角色（只用一次）。
  static String? presetRole;
  static String? takePresetRole() {
    final r = presetRole;
    presetRole = null;
    return r;
  }

  static void reset() {
    presetRole = null;
    currentId = null;
    invited = null;
    transferTo = null;
    permissionRole = 'technician';
    notify();
  }

  static const roleNames = {
    'manager': '店长',
    'cashier': '前台收银',
    'technician': '施工技师',
  };
  static String roleName(Object? role) => roleNames['$role'] ?? '$role';

  static String maskedPhone(Object? phone) {
    final p = '$phone';
    return p.length == 11 ? '${p.substring(0, 3)} **** ${p.substring(7)}' : p;
  }

  /// 后端日期 2022-03-14 → 设计稿格式 2022.03.14。
  static String dotDate(Object? iso, {bool monthOnly = false}) {
    final s = '${iso ?? ''}';
    if (s.length < 10) return '—';
    final d = s.substring(0, 10).replaceAll('-', '.');
    return monthOnly ? d.substring(0, 7) : d;
  }

  /// 金额：¥8,640（整数不带小数，非整数保留两位）。
  static String money(Object? v) {
    final n = (v as num?) ?? 0;
    final fixed = n == n.truncate() ? n.toInt().toString() : n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '¥$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  static Future<T> _min<T>(Future<T> pending) async {
    final out = await Future.wait<Object?>([
      pending,
      Future<void>.delayed(kIndicatorMinShow),
    ]);
    return out.first as T;
  }

  static Future<Map<String, dynamic>> save(Map<String, dynamic> input) async {
    final r = await _min(merchantApi.staff('save', input));
    notify();
    return r;
  }

  static Future<Map<String, dynamic>> setStatus(
    String id,
    String status, {
    String reason = '',
    String? transferTo,
  }) async {
    final r = await _min(
      merchantApi.staff('status', {
        'id': id,
        'status': status,
        'reason': reason,
        'transfer_to': transferTo,
      }),
    );
    notify();
    return r;
  }

  static Future<Map<String, dynamic>> saveCommission(
    String id,
    String mode, {
    num rate = 0,
    Map<String, num> overrides = const {},
  }) async {
    final r = await _min(
      merchantApi.staff('commission_save', {
        'id': id,
        'mode': mode,
        'rate': rate,
        'overrides': overrides,
      }),
    );
    notify();
    return r;
  }

  static Future<Map<String, dynamic>> savePermissions(
    String role,
    Map<String, bool> permissions,
  ) async {
    final r = await _min(
      merchantApi.staff('permissions_save', {
        'role': role,
        'permissions': permissions,
      }),
    );
    notify();
    return r;
  }

  static Future<Map<String, dynamic>> invite(String id) async {
    final r = await _min(merchantApi.staff('invite', {'id': id}));
    notify();
    return r;
  }
}
