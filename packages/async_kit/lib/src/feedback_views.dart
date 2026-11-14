import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'async_theme.dart';
import 'errors.dart';
import 'spinner.dart';
import 'toast.dart';

enum EmptyKind { first, search, filter, cleared, locked }

/// 空数据：图标 + 说明 + 可选动作。空状态不等于失败，视觉上与 [ErrorView] 区分。
class EmptyView extends StatelessWidget {
  final EmptyKind kind;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  /// 卡片 / 分区内的局部为空：只用一行文字，不放大图标。
  final bool inline;
  const EmptyView({
    super.key,
    required this.title,
    this.kind = EmptyKind.first,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.inline = false,
  });

  /// 首次为空：引导新建（主按钮）。
  const EmptyView.firstTime({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  }) : kind = EmptyKind.first,
       inline = false;

  /// 筛选无结果：保持筛选条可见，只给“重置筛选”。
  const EmptyView.filtered({super.key, this.onAction})
    : kind = EmptyKind.filter,
      title = '当前筛选下没有数据',
      message = '放宽筛选条件试试',
      actionLabel = '重置筛选',
      icon = null,
      inline = false;

  (Color, Color, IconData) _look(BuildContext context) => switch (kind) {
    EmptyKind.first => (
      AsyncKitTheme.of(context).primarySoft,
      AsyncKitTheme.of(context).primaryInk,
      icon ?? Icons.inbox_outlined,
    ),
    EmptyKind.search => (
      AsyncKitTheme.of(context).amberSoft,
      AsyncKitTheme.of(context).amberInk,
      icon ?? Icons.search_rounded,
    ),
    EmptyKind.filter => (
      AsyncKitTheme.of(context).amberSoft,
      AsyncKitTheme.of(context).amberInk,
      icon ?? Icons.filter_alt_outlined,
    ),
    EmptyKind.cleared => (
      AsyncKitTheme.of(context).greenSoft,
      AsyncKitTheme.of(context).greenInk,
      icon ?? Icons.check_circle_outline_rounded,
    ),
    EmptyKind.locked => (
      AsyncKitTheme.of(context).amberSoft,
      AsyncKitTheme.of(context).amberInk,
      icon ?? Icons.workspace_premium_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return Row(
        children: [
          Text(
            title,
            style: AsyncKitTheme.of(context)
                .textStyle(13, color: AsyncKitTheme.of(context).muted, h: 19),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AsyncKitTheme.of(context).textStyle(
                  13,
                  w: FontWeight.w600,
                  color: AsyncKitTheme.of(context).primaryInk,
                  h: 19,
                ),
              ),
            ),
          ],
        ],
      );
    }
    final (bg, fg, ic) = _look(context);
    final primary = kind == EmptyKind.first || kind == EmptyKind.locked;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(ic, size: 30, color: fg),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AsyncKitTheme.of(context)
                  .textStyle(16, w: FontWeight.w600, h: 23),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AsyncKitTheme.of(context)
                    .textStyle(13, color: AsyncKitTheme.of(context).sub, h: 19),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              _PillButton(actionLabel!, onTap: onAction, filled: primary),
            ],
          ],
        ),
      ),
    );
  }
}

/// 空 / 错误视图里的小号圆角按钮（40 高，点击区不小于 44）。
class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool busy;
  const _PillButton(
    this.label, {
    this.onTap,
    this.filled = true,
    this.busy = false,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: busy ? '$label中' : label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 96, minHeight: 44),
        alignment: Alignment.center,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled
                ? AsyncKitTheme.of(context).primary
                : AsyncKitTheme.of(context).chip,
            borderRadius: BorderRadius.circular(20),
          ),
          child: busy
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSpinner(
                      size: 14,
                      color: filled
                          ? Colors.white
                          : AsyncKitTheme.of(context).ink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$label中…',
                      style: AsyncKitTheme.of(context).textStyle(
                        14,
                        w: FontWeight.w600,
                        color: filled
                            ? Colors.white
                            : AsyncKitTheme.of(context).ink,
                        h: 20,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: AsyncKitTheme.of(context).textStyle(
                    14,
                    w: FontWeight.w600,
                    color: filled
                        ? Colors.white
                        : AsyncKitTheme.of(context).ink,
                    h: 20,
                  ),
                ),
        ),
      ),
    ),
  );
}

// ───────── 错误 ─────────
/// 按错误类型给出固定文案和动作：能重试的给“重试”，不能重试的给明确的下一步。
class ErrorView extends StatelessWidget {
  final bool inline;
  final AppError error;
  final VoidCallback? onRetry;

  /// 重试进行中：按钮显示 loading 且不可再点。
  final bool retrying;

  /// 登录失效 / 无权限 / 不存在时的下一步（重新登录 / 返回）。
  final VoidCallback? onNext;
  const ErrorView({
    super.key,
    this.inline = false,
    required this.error,
    this.onRetry,
    this.retrying = false,
    this.onNext,
  });

  (Color, Color, IconData, String) _look(BuildContext context) =>
      switch (error.type) {
        AppErrorType.network => (
          AsyncKitTheme.of(context).primarySoft,
          AsyncKitTheme.of(context).primaryInk,
          Icons.wifi_off_rounded,
          '请检查网络设置后重试',
        ),
        AppErrorType.timeout => (
          AsyncKitTheme.of(context).amberSoft,
          AsyncKitTheme.of(context).amberInk,
          Icons.schedule_rounded,
          '当前网络较慢，请稍后重试',
        ),
        AppErrorType.server => (
          AsyncKitTheme.of(context).redSoft,
          AsyncKitTheme.of(context).redInk,
          Icons.dns_outlined,
          '我们正在处理，请稍后再试',
        ),
        AppErrorType.auth => (
          AsyncKitTheme.of(context).chip,
          AsyncKitTheme.of(context).sub,
          Icons.lock_outline_rounded,
          '请重新登录后继续使用',
        ),
        AppErrorType.forbidden => (
          AsyncKitTheme.of(context).chip,
          AsyncKitTheme.of(context).sub,
          Icons.shield_outlined,
          AsyncKitTheme.of(context).permissionHint,
        ),
        AppErrorType.notFound => (
          AsyncKitTheme.of(context).chip,
          AsyncKitTheme.of(context).sub,
          Icons.description_outlined,
          '返回上一页看看其他内容',
        ),
        AppErrorType.business => (
          AsyncKitTheme.of(context).redSoft,
          AsyncKitTheme.of(context).redInk,
          Icons.error_outline,
          error.message,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, ic, hint) = _look(context);
    final retry = error.retryable && onRetry != null;
    final nextLabel = switch (error.type) {
      AppErrorType.auth => '重新登录',
      AppErrorType.forbidden || AppErrorType.notFound => '返回',
      _ => null,
    };
    if (inline) {
      return Row(
        children: [
          Icon(ic, size: 20, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.title,
              style: AsyncKitTheme.of(context)
                  .textStyle(13, color: AsyncKitTheme.of(context).sub, h: 18),
            ),
          ),
          if (retry) _PillButton('重试', onTap: onRetry, busy: retrying),
          if (!retry && nextLabel != null && onNext != null)
            _PillButton(nextLabel, onTap: onNext),
        ],
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(ic, size: 30, color: fg),
            ),
            const SizedBox(height: 12),
            Text(
              error.title,
              textAlign: TextAlign.center,
              style: AsyncKitTheme.of(context)
                  .textStyle(16, w: FontWeight.w600, h: 23),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: AsyncKitTheme.of(context)
                  .textStyle(13, color: AsyncKitTheme.of(context).sub, h: 19),
            ),
            if (retry) ...[
              const SizedBox(height: 14),
              _PillButton('重试', onTap: onRetry, busy: retrying),
            ] else if (nextLabel != null && onNext != null) ...[
              const SizedBox(height: 14),
              _PillButton(
                nextLabel,
                onTap: onNext,
                filled: error.type == AppErrorType.auth,
              ),
            ],
            if (error.code != null) ...[
              const SizedBox(height: 10),
              // 长按可复制，便于客服排查
              GestureDetector(
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: error.code!));
                  AppToast.show(context, '已复制错误码', kind: ToastKind.success);
                },
                child: Text(
                  error.code!,
                  style: AsyncKitTheme.of(context).textStyle(
                    11,
                    color: AsyncKitTheme.of(context).faint,
                    h: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
