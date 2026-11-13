/// 注册步骤间的临时输入；注册接口仍再次校验验证码和账号规则。
class RegistrationCredentials {
  final String phone, code, password;
  const RegistrationCredentials({
    required this.phone,
    required this.code,
    required this.password,
  });
}

/// 成功页仅展示实际注册及门店读取结果，不携带密码或验证码。
class RegistrationReceipt {
  final String storeName, maskedPhone;
  final int seededServices;
  const RegistrationReceipt({
    required this.storeName,
    required this.maskedPhone,
    required this.seededServices,
  });
}
