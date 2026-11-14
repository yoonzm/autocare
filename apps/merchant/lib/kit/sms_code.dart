import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart' show C;
import 'async_kit.dart';

/// 页面持有的发送状态与倒计时；请求由调用者传入，不推断手机号或短信用途。
class SmsCodeController extends ChangeNotifier {
  int seconds = 0;
  bool sending = false;
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

Widget smsCodeText(SmsCodeController controller, TextStyle style) =>
    ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        if (controller.sending) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpinner(size: 16, color: C.muted),
              const SizedBox(width: 6),
              Text('发送中…', style: style.copyWith(color: C.muted)),
            ],
          );
        }
        return Text(
          controller.seconds > 0 ? '${controller.seconds} 秒后重发' : '获取验证码',
          style: controller.seconds > 0
              ? style.copyWith(color: C.muted)
              : style,
        );
      },
    );
