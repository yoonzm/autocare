import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import '../states/states.dart' show AppSpinner;
import 'app_tap_target.dart';

/// 验证码按钮只展示外部状态并回调，不持有计时器或发送请求。
class AppSmsCodeButton extends StatelessWidget {
  final bool sending;
  final int seconds;
  final bool sent;
  final VoidCallback? onPressed;

  const AppSmsCodeButton({
    super.key,
    this.sending = false,
    this.seconds = 0,
    this.sent = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final blocked = sending || seconds > 0 || onPressed == null;
    final label = sending
        ? '发送中…'
        : seconds > 0
        ? '$seconds 秒后重发'
        : sent
        ? '重新发送'
        : '获取验证码';
    final fg = blocked ? t.inkMute : t.primaryText;
    return AppTapTarget(
      onTap: blocked ? null : onPressed,
      semanticLabel: label,
      builder: (context, pressed) => SizedBox(
        width: 132,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              pressed ? t.pressedOverlay : Colors.transparent,
              t.surface,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: t.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sending) ...[
                AppSpinner(size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: t.small.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
