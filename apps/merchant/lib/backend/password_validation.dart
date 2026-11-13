/// 客户端即时反馈；最终密码规则仍由后端校验。
String? passwordRuleError(String password) {
  if (password.length < 8 || password.length > 20) return '密码需 8–20 位';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'\d').hasMatch(password)) {
    return '密码需同时包含字母和数字';
  }
  return null;
}

bool passwordContainsPhoneDigits(String password, String phone) {
  for (var i = 0; i + 6 <= phone.length; i++) {
    if (password.contains(phone.substring(i, i + 6))) return true;
  }
  return false;
}

String? passwordResetError({
  required String next,
  required String confirmation,
  required String phone,
}) {
  if (next.isEmpty) return '请输入新密码';
  final rule = passwordRuleError(next);
  if (rule != null) return rule.replaceFirst('密码', '新密码');
  if (passwordContainsPhoneDigits(next, phone)) return '新密码不能包含手机号中的连续数字';
  if (confirmation != next) return '两次输入的新密码不一致';
  return null;
}

String? passwordChangeError({
  required String current,
  required String next,
  required String confirmation,
  required String phone,
}) {
  if (current.isEmpty) return '请输入当前密码';
  if (next.isEmpty) return '请输入新密码';
  final rule = passwordRuleError(next);
  if (rule != null) return rule.replaceFirst('密码', '新密码');
  if (next == current) return '新密码不能与当前密码相同';
  if (passwordContainsPhoneDigits(next, phone)) return '新密码不能包含手机号中的连续数字';
  if (confirmation != next) return '两次输入的新密码不一致';
  return null;
}
