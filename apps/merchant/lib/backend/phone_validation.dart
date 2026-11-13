final _phonePattern = RegExp(r'^1[3-9]\d{9}$');
final _codePattern = RegExp(r'^\d{6}$');

bool isMobileNumber(String value) => _phonePattern.hasMatch(value);

String? phoneVerificationError({required String phone, required String code}) {
  if (phone.isEmpty) return '请输入手机号';
  if (!isMobileNumber(phone)) return '请输入正确的 11 位手机号';
  if (code.isEmpty) return '请输入验证码';
  if (!_codePattern.hasMatch(code)) return '验证码为 6 位数字';
  return null;
}

/// 只作即时反馈；验证码消费与手机号变更由后端校验执行。
String? phoneChangeError({
  required String currentCode,
  required String nextPhone,
  required String nextCode,
  required String currentPhone,
}) {
  if (currentCode.isEmpty) return '请输入当前号码的验证码';
  if (!_codePattern.hasMatch(currentCode)) return '当前号码的验证码为 6 位数字';
  if (nextPhone.isEmpty) return '请输入新手机号';
  if (!isMobileNumber(nextPhone)) return '请输入正确的 11 位新手机号';
  if (nextPhone == currentPhone) return '新手机号不能与当前手机号相同';
  if (nextCode.isEmpty) return '请输入新号码的验证码';
  if (!_codePattern.hasMatch(nextCode)) return '新号码的验证码为 6 位数字';
  return null;
}
