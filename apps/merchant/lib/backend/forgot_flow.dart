import 'package:flutter/foundation.dart';

/// “忘记密码”三步（验证手机号 -> 设置新密码 -> 重置成功）之间传递的状态。
/// 验证码在第一步经服务端校验，第二步提交新密码时再校验一次（一次性），
/// 所以这里要把手机号和验证码保留到重置完成。
class ForgotFlow extends ChangeNotifier {
  bool live = false;
  String phone = '';
  String code = '';

  /// `138 **** 1234`
  String get maskedPhone => phone.length == 11
      ? '${phone.substring(0, 3)} **** ${phone.substring(7)}'
      : phone;

  void verified(String phone, String code) {
    live = true;
    this.phone = phone;
    this.code = code;
    notifyListeners();
  }

  void clear() {
    live = false;
    phone = '';
    code = '';
    notifyListeners();
  }
}

final ForgotFlow forgotFlow = ForgotFlow();
