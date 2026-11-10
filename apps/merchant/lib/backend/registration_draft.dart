import 'dart:async';

import 'package:flutter/foundation.dart';

/// Holds input from the existing generated screens (sign-up, change password,
/// change phone, delete account) without changing their layout or modifying
/// generated page source.
class RegistrationDraft {
  /// Routes whose inputs are real forms: they start empty instead of showing
  /// the design's sample text, and their values are kept here.
  static const formRoutes = {
    'RegPhone',
    'RegShop',
    'ChangePassword',
    'ChangePhone',
    'DeleteAccount',
    'ForgotVerify',
    'ForgotReset',
    'StoreAdd',
    'StoreEdit',
    'ProfileEdit',
  };

  static const cityPlaceholder = '请选择所在城市';
  static const roles = ['老板', '店长', '前台'];
  static const bays = ['1-3 个', '4-6 个', '7-10 个', '10 个以上'];
  static const business = ['洗车美容', '镀晶镀膜', '隐形车衣', '改色膜', '保养维修'];

  static final Map<String, String> _fields = {};
  static final Map<String, bool> _checks = {};
  static final Map<String, List<Object>> _owners = {};

  /// 注册第二页：城市文本，以及三组选项当前选中的序号（与界面共用同一个集合）。
  static String city = '';
  static String provinceCode = '';
  static String cityCode = '';
  static Set<int>? roleSel, baySel, businessSel;

  // ───────── 同一页里 hint 相同的输入框（如两个“6 位数字”）按出现顺序区分 ─────────
  static int claim(String key, Object owner) {
    final list = _owners.putIfAbsent(key, () => []);
    if (!list.contains(owner)) list.add(owner);
    return list.indexOf(owner);
  }

  static void release(String key, Object owner) => _owners[key]?.remove(owner);

  static String _key(String route, String hint, int slot) =>
      slot == 0 ? '$route:$hint' : '$route:$hint#$slot';

  static void remember(
    String route,
    String hint,
    String initial, [
    int slot = 0,
  ]) {
    if (formRoutes.contains(route)) {
      _fields.putIfAbsent(_key(route, hint, slot), () => initial);
    }
  }

  /// 页面新打开时把草稿清空，避免上次没提交的残留值与空白输入框不一致。
  static void reset(String route, String hint, [int slot = 0]) {
    if (formRoutes.contains(route)) _fields[_key(route, hint, slot)] = '';
  }

  /// 表单内容有变化（按钮的可点状态据此刷新，如注销账号的“申请注销”）。
  static final changes = ValueNotifier<int>(0);
  static bool _notifyQueued = false;

  /// 输入框 / 勾选框可能在构建期间写入草稿，通知延后到微任务里，避免“构建中刷新”。
  static void _notifyChanged() {
    if (_notifyQueued) return;
    _notifyQueued = true;
    scheduleMicrotask(() {
      _notifyQueued = false;
      changes.value++;
    });
  }

  static void set(String route, String hint, String value, [int slot = 0]) {
    if (formRoutes.contains(route)) {
      _fields[_key(route, hint, slot)] = value;
      _notifyChanged();
    }
  }

  static String get(String route, String hint, [int slot = 0]) =>
      _fields[_key(route, hint, slot)]?.trim() ?? '';

  /// 密码不能随意去掉首尾空格。
  static String getRaw(String route, String hint, [int slot = 0]) =>
      _fields[_key(route, hint, slot)] ?? '';

  // ───────── 勾选框（同意协议 / 同意注销） ─────────
  static void setChecked(String route, bool on) {
    _checks[route] = on;
    _notifyChanged();
  }

  static bool checked(String route) => _checks[route] ?? false;

  /// Whether the user ticked 《用户服务协议》/《隐私政策》 on RegPhone.
  static bool get agreed => checked('RegPhone');
  static set agreed(bool on) => setChecked('RegPhone', on);

  // ───────── 校验 ─────────
  static final _phoneRe = RegExp(r'^1[3-9]\d{9}$');
  static final _codeRe = RegExp(r'^\d{6}$');

  static String? passwordRuleError(String pw) {
    if (pw.length < 8 || pw.length > 20) return '密码需 8–20 位';
    if (!RegExp(r'[A-Za-z]').hasMatch(pw) || !RegExp(r'\d').hasMatch(pw)) {
      return '密码需同时包含字母和数字';
    }
    return null;
  }

  /// Client-side checks for the first sign-up step. Returns the first problem
  /// found, or null when the form may proceed.
  static String? phoneStepError() {
    final phone = get('RegPhone', '请输入手机号');
    final code = get('RegPhone', '6 位数字');
    final password = getRaw('RegPhone', '8-20 位，含字母和数字');
    if (phone.isEmpty) return '请输入手机号';
    if (!_phoneRe.hasMatch(phone)) return '请输入正确的 11 位手机号';
    if (code.isEmpty) return '请输入验证码';
    if (!_codeRe.hasMatch(code)) return '验证码为 6 位数字';
    if (password.isEmpty) return '请设置登录密码';
    final rule = passwordRuleError(password);
    if (rule != null) return rule;
    if (!agreed) return '请先阅读并同意用户服务协议和隐私政策';
    return null;
  }

  static String? shopStepError() {
    if (get('RegShop', '如：驰光汽车美容').isEmpty) return '请输入门店名称';
    if (city.isEmpty ||
        city == cityPlaceholder ||
        provinceCode.isEmpty ||
        cityCode.isEmpty) {
      return '请选择所在城市';
    }
    if (get('RegShop', '您的姓名').isEmpty) return '请输入联系人姓名';
    if ((businessSel ?? const <int>{}).isEmpty) return '请至少选择一项主营业务';
    return null;
  }

  /// Store profile sent along with the sign-up request.
  static Map<String, dynamic> profile() => {
    'city': city,
    'province_code': provinceCode,
    'city_code': cityCode,
    'address': get('RegShop', '街道、门牌号（选填）'),
    'contact_name': get('RegShop', '您的姓名'),
    'contact_role': _pick(roles, roleSel),
    'bay_range': _pick(bays, baySel),
    'business_types': [
      for (final i in ((businessSel ?? <int>{}).toList()..sort()))
        if (i >= 0 && i < business.length) business[i],
    ],
  };

  static String _pick(List<String> all, Set<int>? sel) {
    final i = (sel == null || sel.isEmpty) ? -1 : sel.first;
    return i >= 0 && i < all.length ? all[i] : '';
  }

  /// 新密码里不能出现手机号中的连续 6 位数字。
  static bool containsPhoneDigits(String password, String phone) {
    for (var i = 0; i + 6 <= phone.length; i++) {
      if (password.contains(phone.substring(i, i + 6))) return true;
    }
    return false;
  }

  /// 忘记密码第 1 步（验证手机号）的本地校验。
  static String? forgotVerifyError() {
    final phone = get('ForgotVerify', '请输入手机号');
    final code = get('ForgotVerify', '6 位数字');
    if (phone.isEmpty) return '请输入手机号';
    if (!_phoneRe.hasMatch(phone)) return '请输入正确的 11 位手机号';
    if (code.isEmpty) return '请输入验证码';
    if (!_codeRe.hasMatch(code)) return '验证码为 6 位数字';
    return null;
  }

  /// 忘记密码第 2 步（设置新密码）的本地校验。
  static String? forgotResetError(String phone) {
    final next = getRaw('ForgotReset', '8-20 位，含字母和数字');
    final again = getRaw('ForgotReset', '再次输入新密码');
    if (next.isEmpty) return '请输入新密码';
    final rule = passwordRuleError(next);
    if (rule != null) return rule.replaceFirst('密码', '新密码');
    if (containsPhoneDigits(next, phone)) return '新密码不能包含手机号中的连续数字';
    if (again != next) return '两次输入的新密码不一致';
    return null;
  }

  static String? passwordChangeError(String ownPhone) {
    final old = getRaw('ChangePassword', '请输入当前密码');
    final next = getRaw('ChangePassword', '8-20 位，含字母和数字');
    final again = getRaw('ChangePassword', '再次输入新密码');
    if (old.isEmpty) return '请输入当前密码';
    if (next.isEmpty) return '请输入新密码';
    final rule = passwordRuleError(next);
    if (rule != null) return rule.replaceFirst('密码', '新密码');
    if (next == old) return '新密码不能与当前密码相同';
    if (containsPhoneDigits(next, ownPhone)) return '新密码不能包含手机号中的连续数字';
    if (again != next) return '两次输入的新密码不一致';
    return null;
  }

  static String? phoneChangeError(String ownPhone) {
    final oldCode = get('ChangePhone', '6 位数字');
    final next = get('ChangePhone', '请输入新手机号');
    final newCode = get('ChangePhone', '6 位数字', 1);
    if (oldCode.isEmpty) return '请输入当前号码的验证码';
    if (!_codeRe.hasMatch(oldCode)) return '当前号码的验证码为 6 位数字';
    if (next.isEmpty) return '请输入新手机号';
    if (!_phoneRe.hasMatch(next)) return '请输入正确的 11 位新手机号';
    if (next == ownPhone) return '新手机号不能与当前手机号相同';
    if (newCode.isEmpty) return '请输入新号码的验证码';
    if (!_codeRe.hasMatch(newCode)) return '新号码的验证码为 6 位数字';
    return null;
  }

  static String? deleteError() {
    final code = get('DeleteAccount', '6 位数字');
    if (!_codeRe.hasMatch(code)) return '请输入 6 位短信验证码';
    if (!checked('DeleteAccount')) return '请先勾选“我已了解注销后果”';
    return null;
  }

  static void clearRoute(String route) {
    _fields.removeWhere((k, _) => k.startsWith('$route:'));
    _checks.remove(route);
  }

  static void clear() {
    _fields.clear();
    _checks.clear();
    city = '';
    provinceCode = cityCode = '';
    roleSel = baySel = businessSel = null;
  }
}
