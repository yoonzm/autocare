/// 仅在重置页面之间传递，不存入全局状态；提交时后端再次校验并消费验证码。
class PasswordResetChallenge {
  final String phone;
  final String code;
  const PasswordResetChallenge({required this.phone, required this.code});

  String get maskedPhone => phone.length == 11
      ? '${phone.substring(0, 3)} **** ${phone.substring(7)}'
      : phone;
}
