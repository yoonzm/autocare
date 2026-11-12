import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_tokens.dart';
import 'app_tap_target.dart';

/// 开关：46 × 28，开 = 主色，关 = switchOff，滑块白色；点击热区外扩到 44。
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final enabled = onChanged != null;
    return AppTapTarget(
      toggled: value,
      button: false,
      semanticLabel: semanticLabel,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onChanged!(!value);
            }
          : null,
      builder: (context, pressed) => Opacity(
        opacity: enabled ? 1 : .5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 46,
          height: 28,
          padding: const EdgeInsets.all(3),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? t.primary : t.switchOff,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: t.onPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: t.thumbShadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
