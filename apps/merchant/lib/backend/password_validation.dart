/// 客户端即时反馈；最终密码规则仍由后端校验。
enum PasswordStrength {
  none(0, '强度：—'),
  weak(1, '强度：弱'),
  medium(2, '强度：中'),
  strong(3, '强度：强'),
  veryStrong(4, '强度：极强');

  final int segments;
  final String label;
  const PasswordStrength(this.segments, this.label);
}

class PasswordEvaluation {
  final bool hasLength;
  final bool hasLetterAndDigit;
  final bool differsFromCurrent;
  final bool noPhoneDigits;
  final PasswordStrength strength;

  const PasswordEvaluation({
    required this.hasLength,
    required this.hasLetterAndDigit,
    required this.differsFromCurrent,
    required this.noPhoneDigits,
    required this.strength,
  });
}

String? passwordRuleError(String password) {
  if (password.length < 8 || password.length > 20) return '密码需 8–20 位';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'\d').hasMatch(password)) {
    return '密码需同时包含字母和数字';
  }
  return null;
}

bool passwordContainsPhoneDigits(String password, String phone) {
  final raw = phone.replaceAll(RegExp(r'\D'), '');
  final digits = raw.length > 11 ? raw.substring(raw.length - 11) : raw;
  for (var i = 0; i + 6 <= digits.length; i++) {
    if (password.contains(digits.substring(i, i + 6))) return true;
  }
  return false;
}

PasswordEvaluation evaluatePassword(
  String password, {
  String? current,
  required String phone,
}) {
  if (password.isEmpty) {
    return const PasswordEvaluation(
      hasLength: false,
      hasLetterAndDigit: false,
      differsFromCurrent: false,
      noPhoneDigits: false,
      strength: PasswordStrength.none,
    );
  }
  final hasLength = password.length >= 8 && password.length <= 20;
  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
  final hasLetterAndDigit = (hasLower || hasUpper) && hasDigit;
  final differsFromCurrent = current == null ? true : password != current;
  final noPhoneDigits = !passwordContainsPhoneDigits(password, phone);

  final PasswordStrength strength;
  if (!hasLength ||
      !hasLetterAndDigit ||
      !differsFromCurrent ||
      !noPhoneDigits) {
    strength = PasswordStrength.weak;
  } else {
    final categories =
        (hasLower ? 1 : 0) +
        (hasUpper ? 1 : 0) +
        (hasDigit ? 1 : 0) +
        (hasSymbol ? 1 : 0);
    if ((password.length >= 12 && categories >= 3) ||
        (password.length >= 10 && categories >= 4)) {
      strength = PasswordStrength.veryStrong;
    } else if (password.length >= 11 || categories >= 3) {
      strength = PasswordStrength.strong;
    } else {
      strength = PasswordStrength.medium;
    }
  }

  return PasswordEvaluation(
    hasLength: hasLength,
    hasLetterAndDigit: hasLetterAndDigit,
    differsFromCurrent: differsFromCurrent,
    noPhoneDigits: noPhoneDigits,
    strength: strength,
  );
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
