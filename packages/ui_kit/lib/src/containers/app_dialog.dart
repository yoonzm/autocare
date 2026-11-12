import 'package:autocare_async_kit/async_kit.dart' show AppToast;
import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_tokens.dart';

/// 对话框：只用于「确认」类打断（停用、作废、删除），宽 280、圆角 28，居中。
/// 按钮并排，取消在左；危险操作的确认按钮用危险色。能用弹层完成的选择，不用对话框。
/// 返回 true 表示确认。
///
/// 需要在确认后做异步处理时传 [onConfirm]：处理期间确认按钮显示加载中、取消和点遮罩都不响应；
/// 成功后自动关闭并返回 true，失败时弹窗保持打开，错误交给 [onError]（默认用 Toast 展示）。
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = '确认',
  String cancelLabel = '取消',
  bool danger = false,
  Future<void> Function()? onConfirm,
  void Function(Object error)? onError,
}) async {
  final t = AppTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierColor: t.overlay,
    barrierDismissible: true,
    builder: (dialogContext) => _DialogBody(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      danger: danger,
      onConfirm: onConfirm,
      onError: onError,
    ),
  );
  return result ?? false;
}

class _DialogBody extends StatefulWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;
  final Future<void> Function()? onConfirm;
  final void Function(Object error)? onError;
  const _DialogBody({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.danger,
    required this.onConfirm,
    required this.onError,
  });

  @override
  State<_DialogBody> createState() => _DialogBodyState();
}

class _DialogBodyState extends State<_DialogBody> {
  bool _loading = false;

  Future<void> _confirm() async {
    final work = widget.onConfirm;
    if (work == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _loading = true);
    try {
      await work();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      final handler = widget.onError;
      if (handler != null) {
        handler(error);
      } else {
        AppToast.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return PopScope(
      // 处理中不能通过返回键或点遮罩关闭。
      canPop: !_loading,
      child: Dialog(
        backgroundColor: t.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.hero),
          side: BorderSide(color: t.darkMode ? t.fillStrong : Colors.transparent),
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
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: t.title.copyWith(fontSize: 18, height: 26 / 18),
                ),
                if (widget.message != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: t.base.copyWith(
                      color: t.inkSub,
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
                        label: widget.cancelLabel,
                        kind: AppButtonKind.secondary,
                        expanded: true,
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: AppButton(
                        label: widget.confirmLabel,
                        kind: widget.danger
                            ? AppButtonKind.danger
                            : AppButtonKind.primary,
                        expanded: true,
                        loading: _loading,
                        onPressed: _confirm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
