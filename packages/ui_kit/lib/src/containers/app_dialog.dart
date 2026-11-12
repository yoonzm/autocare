import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_tokens.dart';

/// 对话框：只用于「确认」类打断（停用、作废、删除），宽 280、圆角 28，居中。
/// 按钮并排，取消在左；危险操作的确认按钮用危险色。能用弹层完成的选择，不用对话框。
/// 返回 true 表示确认。
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = '确认',
  String cancelLabel = '取消',
  bool danger = false,
}) async {
  final t = AppTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierColor: t.overlay,
    builder: (dialogContext) {
      final dt = AppTokens.of(dialogContext);
      return Dialog(
        backgroundColor: dt.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.hero),
          side: BorderSide(color: dt.darkMode ? dt.fillStrong : Colors.transparent),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s24,
              AppSpacing.s20,
              AppSpacing.s20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, textAlign: TextAlign.center, style: dt.title.copyWith(fontSize: 18, height: 26 / 18)),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: dt.base.copyWith(
                      color: dt.inkSub,
                      fontWeight: FontWeight.w400,
                      height: 21 / 14,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        kind: AppButtonKind.secondary,
                        expanded: true,
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: AppButton(
                        label: confirmLabel,
                        kind: danger ? AppButtonKind.danger : AppButtonKind.primary,
                        expanded: true,
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
