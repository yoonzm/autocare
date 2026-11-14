import 'package:flutter/material.dart';

import 'errors.dart';
import 'async_theme.dart';
import 'spinner.dart';

enum ToastKind { success, error, info, loading }

class AppToast {
  AppToast._();

  /// 成功 / 信息 3s，失败 5s（带操作 8s）；同一时刻最多一条，新的替换旧的。
  static Duration durationOf(ToastKind kind, {bool hasAction = false}) {
    if (hasAction) return const Duration(seconds: 8);
    return switch (kind) {
      ToastKind.error => const Duration(seconds: 5),
      ToastKind.loading => const Duration(seconds: 10),
      _ => const Duration(seconds: 3),
    };
  }

  static void show(
    BuildContext context,
    String message, {
    ToastKind kind = ToastKind.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) => showOn(
    ScaffoldMessenger.of(context),
    message,
    kind: kind,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void error(BuildContext context, Object e) =>
      show(context, AppError.from(e).message, kind: ToastKind.error);

  static void showOn(
    ScaffoldMessengerState messenger,
    String message, {
    ToastKind kind = ToastKind.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final hasAction = actionLabel != null && onAction != null;
    // 应用最外层有 [ToastHost] 时，提示条显示在屏幕顶部（状态栏下方），
    // 不会被操作中的手指和底部按钮遮挡；没有时（单独测试页面）退回底部 SnackBar。
    final host = ToastHost._current;
    if (host != null) {
      host._show(message, kind, actionLabel: actionLabel, onAction: onAction);
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kind == ToastKind.loading) ...[
                const AppSpinner(size: 16, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          action: hasAction
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: const Color(0xFF6AB4FA),
                  onPressed: onAction,
                )
              : null,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(32, 0, 32, 104),
          duration: durationOf(kind, hasAction: hasAction),
          elevation: 0,
          backgroundColor: AsyncKitTheme.of(messenger.context).toastBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      );
  }
}

/// 提示条的显示层：放在 MaterialApp 的 builder 里，提示条从屏幕顶部（状态栏下方）滑入。
/// 同一时刻最多一条，新的替换旧的；上滑可关闭；带“重试”等操作时停留 5 秒。
class ToastHost extends StatefulWidget {
  final Widget child;
  const ToastHost({super.key, required this.child});

  static ToastHostState? _current;

  @override
  State<ToastHost> createState() => ToastHostState();
}

class ToastHostState extends State<ToastHost> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  // 停留时间用动画控制器计时（不产生 Timer）
  late final AnimationController _life = AnimationController(vsync: this)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _in.reverse();
    });
  ({String text, ToastKind kind, String? action, VoidCallback? onAction})? _t;

  @override
  void initState() {
    super.initState();
    ToastHost._current = this;
    _in.addStatusListener((s) {
      if (s == AnimationStatus.dismissed && _t != null && mounted) {
        setState(() => _t = null);
      }
    });
  }

  @override
  void dispose() {
    if (ToastHost._current == this) ToastHost._current = null;
    _in.dispose();
    _life.dispose();
    super.dispose();
  }

  void _show(
    String text,
    ToastKind kind, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final hasAction = actionLabel != null && onAction != null;
    setState(() {
      _t = (
        text: text,
        kind: kind,
        action: hasAction ? actionLabel : null,
        onAction: hasAction ? onAction : null,
      );
    });
    _life
      ..stop()
      ..duration = AppToast.durationOf(kind, hasAction: hasAction)
      ..value = 0
      ..forward();
    _in.forward();
  }

  void _dismiss() {
    _life.stop();
    _in.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final top = MediaQuery.maybeOf(context)?.padding.top ?? 0;
    return Stack(
      children: [
        widget.child,
        if (t != null)
          Positioned(
            top: top + 12,
            left: 32,
            right: 32,
            child: FadeTransition(
              opacity: _in,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: _in, curve: Curves.easeOut)),
                child: GestureDetector(
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0) < 0) _dismiss();
                  },
                  child: Material(
                    color: AsyncKitTheme.of(context).toastBackground,
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (t.kind == ToastKind.loading) ...[
                              const AppSpinner(size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                t.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            if (t.action != null) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _dismiss();
                                  t.onAction?.call();
                                },
                                child: Text(
                                  t.action!,
                                  style: const TextStyle(
                                    color: Color(0xFF6AB4FA),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
