import 'dart:async';

import 'package:flutter/material.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart';

import 'async_kit.dart';

/// 页面持有的发送状态与倒计时；请求由调用者传入，不推断手机号或短信用途。
class SmsCodeController extends ChangeNotifier {
  int seconds = 0;
  bool sending = false;
  bool sent = false;
  bool _disposed = false;
  Timer? _timer;

  void setSending(bool value) {
    if (_disposed || sending == value) return;
    sending = value;
    notifyListeners();
  }

  void start({int seconds = 60}) {
    if (_disposed) return;
    this.seconds = seconds;
    sent = true;
    _timer?.cancel();
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      this.seconds--;
      if (this.seconds <= 0) timer.cancel();
      notifyListeners();
    });
  }

  Future<bool> send(Future<void> Function() request) async {
    if (_disposed || sending || seconds > 0) return false;
    setSending(true);
    try {
      await Future.wait<void>([
        Future<void>.sync(request),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
      if (_disposed) return false;
      setSending(false);
      start();
      return true;
    } finally {
      setSending(false);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

/// 页面控制器到纯展示组件的薄适配，不改变发送或错误处理。
Widget smsCodeButton(SmsCodeController controller, {VoidCallback? onPressed}) =>
    ListenableBuilder(
      listenable: controller,
      builder: (_, _) => AppSmsCodeButton(
        sending: controller.sending,
        seconds: controller.seconds,
        sent: controller.sent,
        onPressed: onPressed,
      ),
    );
