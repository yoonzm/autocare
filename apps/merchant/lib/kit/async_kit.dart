// 加载与反馈统一组件，规范见 docs/frontend-loading-feedback.md。
//
// 页面不要各自写加载、空、错误处理，统一用这里的组件：
//   AppError      请求失败的统一类型（网络 / 超时 / 服务 / 登录失效 / 无权限 / 不存在 / 业务）
//   AppToast      轻提示（成功 / 失败 / 信息，同一时刻最多一条）
//   AppSkeleton   闪光骨架元素
//   EmptyView     空数据（图标 + 说明 + 可选动作）
//   ErrorView     按错误类型出文案，带重试
//   LoadingButton 点击即 loading、防连点、失败恢复
//   AsyncView<T>  包装一次请求，按状态渲染 骨架 / 内容 / 空 / 错误
import 'dart:async';
import 'dart:io' show HandshakeException, SocketException, TlsException;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, FunctionException;

import '../theme.dart';

// ───────── 时序常量（规范 · 总则） ─────────
/// 少于这个时间的请求不显示任何加载指示，避免闪烁。
const kIndicatorDelay = Duration(milliseconds: 300);

/// 加载指示一旦出现，至少停留这么久。
const kIndicatorMinShow = Duration(milliseconds: 500);

/// 普通请求超时；上传、导出用 [kLongTimeout]。
const kRequestTimeout = Duration(seconds: 15);
const kLongTimeout = Duration(seconds: 60);

/// 内容替换骨架的淡入时长。
const kFadeIn = Duration(milliseconds: 150);

// ───────── 统一错误类型 ─────────
enum AppErrorType {
  network,
  timeout,
  server,
  auth,
  forbidden,
  notFound,
  business,
}

class AppError implements Exception {
  final AppErrorType type;

  /// 可直接展示给用户的文案。
  final String message;

  /// 服务异常时的错误码，如 `SRV_503`，用于客服排查。
  final String? code;
  const AppError(this.message, {this.type = AppErrorType.business, this.code});

  /// 网络 / 超时 / 服务异常可以重试；登录失效、无权限、不存在、业务失败重试也不会成功。
  bool get retryable =>
      type == AppErrorType.network ||
      type == AppErrorType.timeout ||
      type == AppErrorType.server;

  String get title => switch (type) {
    AppErrorType.network => '网络不太给力',
    AppErrorType.timeout => '请求超时',
    AppErrorType.server => '服务开小差了',
    AppErrorType.auth => '登录已过期',
    AppErrorType.forbidden => '暂无权限访问',
    AppErrorType.notFound => '内容不存在或已删除',
    AppErrorType.business => '操作失败',
  };

  const AppError.network()
    : this('网络不太给力，请检查网络后重试', type: AppErrorType.network);
  const AppError.timeout()
    : this('请求超时，当前网络较慢，请稍后重试', type: AppErrorType.timeout);

  /// 把 HTTP 状态和服务端文案映射成统一错误。
  /// 4xx 业务失败直接展示服务端文案；只有 401 视为登录失效。
  factory AppError.fromStatus(int status, [String? serverMessage]) {
    final text = (serverMessage ?? '').trim();
    if (status == 401) {
      return AppError(
        text.isNotEmpty ? text : '登录已过期，请重新登录',
        type: AppErrorType.auth,
      );
    }
    if (status >= 500) {
      return AppError(
        '服务开小差了，请稍后再试',
        type: AppErrorType.server,
        code: 'SRV_$status',
      );
    }
    if (text.isEmpty) {
      if (status == 403) {
        return const AppError('暂无权限访问', type: AppErrorType.forbidden);
      }
      if (status == 404) {
        return const AppError('内容不存在或已删除', type: AppErrorType.notFound);
      }
    }
    return AppError(text.isNotEmpty ? text : '操作失败（$status）');
  }

  /// 任意异常 -> [AppError]。
  static AppError from(Object e) {
    if (e is AppError) return e;
    if (e is TimeoutException) return const AppError.timeout();
    if (e is SocketException || e is HandshakeException || e is TlsException) {
      return const AppError.network();
    }
    if (e is FunctionException) {
      final d = e.details;
      return AppError.fromStatus(
        e.status,
        d is Map ? d['error']?.toString() : null,
      );
    }
    if (e is AuthException) {
      final status = int.tryParse(e.statusCode ?? '');
      if (status != null) return AppError.fromStatus(status, e.message);
      return const AppError.network();
    }
    final s = e.toString();
    if (s.contains('SocketException') ||
        s.contains('ClientException') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection')) {
      return const AppError.network();
    }
    return AppError('操作失败，请稍后重试', type: AppErrorType.server, code: 'UNKNOWN');
  }

  @override
  String toString() => message;
}

// ───────── Toast ─────────
enum ToastKind { success, error, info, loading }

class AppToast {
  AppToast._();

  /// 成功 / 信息 2s，失败 3s（带操作 5s）；同一时刻最多一条，新的替换旧的。
  static Duration durationOf(ToastKind kind, {bool hasAction = false}) {
    if (hasAction) return const Duration(seconds: 5);
    return switch (kind) {
      ToastKind.error => const Duration(seconds: 3),
      ToastKind.loading => const Duration(seconds: 10),
      _ => const Duration(seconds: 2),
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
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kind == ToastKind.loading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
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
          backgroundColor: C.dark
              ? const Color(0xFF3A3A40)
              : const Color(0xFF18181B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      );
  }
}

// ───────── 骨架 ─────────
/// 闪光骨架元素：1.4s 循环；系统开启“减少动态效果”时改为静态灰块。
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const AppSkeleton({super.key, this.width, this.height = 14, this.radius = 7});

  /// 圆形（头像）
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size / 2;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still) {
      _c.stop();
      _started = false;
    } else if (!_started) {
      _c.repeat();
      _started = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = C.dark ? const Color(0xFF2A2A2E) : const Color(0xFFE4E4E7);
    final glow = C.dark ? const Color(0xFF3A3A40) : const Color(0xFFF4F4F5);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _started ? _c.value : 0.0;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: base,
            gradient: _started
                ? LinearGradient(
                    begin: Alignment(-1.6 + 3.2 * t, 0),
                    end: Alignment(-0.6 + 3.2 * t, 0),
                    colors: [base, glow, base],
                    stops: const [0.25, 0.5, 0.75],
                  )
                : null,
          ),
        );
      },
    );
  }
}

/// 列表行骨架：头像 + 两行文字 + 右侧一小段。
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Row(
      children: [
        AppSkeleton.circle(size: 46),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 96, height: 14),
              SizedBox(height: 8),
              AppSkeleton(width: 150, height: 12, radius: 6),
            ],
          ),
        ),
        AppSkeleton(width: 48, height: 14),
      ],
    ),
  );
}

/// 列表骨架：[count] 行，布局与真实列表一致。
class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});
  @override
  Widget build(BuildContext context) => Semantics(
    label: '加载中',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonRow(),
          ],
        ],
      ),
    ),
  );
}

// ───────── 空数据 ─────────
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

  (Color, Color, IconData) get _look => switch (kind) {
    EmptyKind.first => (
      C.primarySoft,
      C.primaryInk,
      icon ?? Icons.inbox_outlined,
    ),
    EmptyKind.search => (C.amberSoft, C.amberInk, icon ?? Icons.search_rounded),
    EmptyKind.filter => (
      C.amberSoft,
      C.amberInk,
      icon ?? Icons.filter_alt_outlined,
    ),
    EmptyKind.cleared => (
      C.greenSoft,
      C.greenInk,
      icon ?? Icons.check_circle_outline_rounded,
    ),
    EmptyKind.locked => (
      C.amberSoft,
      C.amberInk,
      icon ?? Icons.workspace_premium_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return Row(
        children: [
          Text(title, style: ts(13, color: C.muted, h: 19)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: ts(13, w: FontWeight.w600, color: C.primaryInk, h: 19),
              ),
            ),
          ],
        ],
      );
    }
    final (bg, fg, ic) = _look;
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
              style: ts(16, w: FontWeight.w600, h: 23),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: ts(13, color: C.sub, h: 19),
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
            color: filled ? C.primary : C.chip,
            borderRadius: BorderRadius.circular(20),
          ),
          child: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: filled ? Colors.white : C.ink,
                  ),
                )
              : Text(
                  label,
                  style: ts(
                    14,
                    w: FontWeight.w600,
                    color: filled ? Colors.white : C.ink,
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
  final AppError error;
  final VoidCallback? onRetry;

  /// 重试进行中：按钮显示 loading 且不可再点。
  final bool retrying;

  /// 登录失效 / 无权限 / 不存在时的下一步（重新登录 / 返回）。
  final VoidCallback? onNext;
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.retrying = false,
    this.onNext,
  });

  (Color, Color, IconData, String) get _look => switch (error.type) {
    AppErrorType.network => (
      C.primarySoft,
      C.primaryInk,
      Icons.wifi_off_rounded,
      '请检查网络设置后重试',
    ),
    AppErrorType.timeout => (
      C.amberSoft,
      C.amberInk,
      Icons.schedule_rounded,
      '当前网络较慢，请稍后重试',
    ),
    AppErrorType.server => (
      C.redSoft,
      C.redInk,
      Icons.dns_outlined,
      '我们正在处理，请稍后再试',
    ),
    AppErrorType.auth => (
      C.chip,
      C.sub,
      Icons.lock_outline_rounded,
      '请重新登录后继续使用',
    ),
    AppErrorType.forbidden => (
      C.chip,
      C.sub,
      Icons.shield_outlined,
      '请联系店主在“角色权限”中为你开通',
    ),
    AppErrorType.notFound => (
      C.chip,
      C.sub,
      Icons.description_outlined,
      '返回上一页看看其他内容',
    ),
    AppErrorType.business => (
      C.redSoft,
      C.redInk,
      Icons.error_outline,
      error.message,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, ic, hint) = _look;
    final retry = error.retryable && onRetry != null;
    final nextLabel = switch (error.type) {
      AppErrorType.auth => '重新登录',
      AppErrorType.forbidden || AppErrorType.notFound => '返回',
      _ => null,
    };
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
              style: ts(16, w: FontWeight.w600, h: 23),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: ts(13, color: C.sub, h: 19),
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
                child: Text(error.code!, style: ts(11, color: C.faint, h: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────── 按钮 ─────────
enum LoadingButtonStyle { primary, secondary, danger }

/// 会发请求的按钮：点击立即进入 loading，期间禁用（防连点），宽高不变；
/// 成功后可短暂显示结果，失败后恢复可点并用 Toast 说明原因，输入内容保留。
class LoadingButton extends StatefulWidget {
  final String label;
  final String? loadingLabel;
  final String? successLabel;
  final Future<void> Function()? onPressed;
  final LoadingButtonStyle style;
  final double height;

  /// 禁用原因（置灰时说明为什么，如“请先填写手机号”）。
  final String? disabledReason;
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.successLabel,
    this.style = LoadingButtonStyle.primary,
    this.height = 50,
    this.disabledReason,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _busy = false;
  bool _done = false;

  Future<void> _tap() async {
    if (_busy || widget.onPressed == null) return;
    setState(() {
      _busy = true;
      _done = false;
    });
    var ok = true;
    try {
      // 指示一旦出现至少停留 500ms，避免一闪而过
      await Future.wait([
        widget.onPressed!(),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
    } catch (e) {
      ok = false;
      if (mounted) AppToast.error(context, e);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = ok && widget.successLabel != null;
    });
    if (_done) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _done = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final (bg, fg) = switch (widget.style) {
      LoadingButtonStyle.primary => (C.primary, Colors.white),
      LoadingButtonStyle.secondary => (C.chip, C.ink),
      LoadingButtonStyle.danger => (C.red, Colors.white),
    };
    final text = _busy
        ? (widget.loadingLabel ?? widget.label)
        : (_done ? widget.successLabel! : widget.label);
    return Semantics(
      button: true,
      enabled: !disabled && !_busy,
      label: disabled && widget.disabledReason != null
          ? '${widget.label}，${widget.disabledReason}'
          : text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled
            ? () {
                if (widget.disabledReason != null) {
                  AppToast.show(context, widget.disabledReason!);
                }
              }
            : _tap,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: disabled ? C.faint : bg,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_busy) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: ts(16, w: FontWeight.w600, color: fg, h: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── 设计稿生成页上按钮的 loading ─────────
/// 正在执行的异步动作。生成页面的按钮在 hTap 里按 `当前页>目标页` 取这个集合，
/// 命中时显示 loading 并忽略点击。
final ValueNotifier<Set<String>> busyActions = ValueNotifier(const {});

bool isBusy(String key) => busyActions.value.contains(key);

/// 带 loading 的异步动作（`当前页>目标页`）。生成页按钮命中这些键时套 [BusyOverlay]。
const asyncActionKeys = {
  'RegPhone>RegShop',
  'RegShop>RegDone',
  'ChangePassword>Security',
  'ChangePhone>Security',
  'DeleteAccount>Login',
  'Security>Login',
  'ServiceEdit>Services',
  'CardTierEdit>CardTiers',
};

/// 执行异步动作并标记 [key] 为忙碌（loading 至少停留 500ms，重复触发被忽略）。
Future<void> runBusy(String key, Future<void> Function() action) async {
  if (isBusy(key)) return;
  busyActions.value = {...busyActions.value, key};
  try {
    await Future.wait([action(), Future<void>.delayed(kIndicatorMinShow)]);
  } finally {
    busyActions.value = {...busyActions.value}..remove(key);
  }
}

/// 给按钮套上忙碌态：忙碌时内容变淡、中间转圈、不响应点击；尺寸不变。
class BusyOverlay extends StatelessWidget {
  final String actionKey;
  final Widget child;
  const BusyOverlay({super.key, required this.actionKey, required this.child});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: busyActions,
    child: child,
    builder: (_, keys, child) {
      if (!keys.contains(actionKey)) return child!;
      return Semantics(
        label: '处理中',
        liveRegion: true,
        child: AbsorbPointer(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0.55, child: child),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ───────── AsyncView ─────────
/// 包装一次请求，按状态渲染：
/// 加载中（300ms 后才出骨架，出现后至少 500ms）→ 内容（150ms 淡入）/ 空 / 错误（带重试）。
/// 已有数据时的刷新：旧内容保留并变淡 + 顶部细进度条；刷新失败只弹带“重试”的 Toast。
class AsyncView<T> extends StatefulWidget {
  final Future<T> Function() load;
  final bool Function(T data) isEmpty;
  final Widget skeleton;
  final Widget Function(BuildContext context) empty;
  final Widget Function(BuildContext context, T data) builder;

  /// 数据加载成功后回调（用于页面其他位置同步显示条数等）。
  final void Function(T data)? onLoaded;

  /// 空状态 / 错误状态下也可下拉刷新；内容状态需 builder 返回可滚动控件。
  final bool pullToRefresh;

  /// 登录失效 / 无权限 / 不存在时的“下一步”（重新登录 / 返回）。
  final VoidCallback? onNext;
  const AsyncView({
    super.key,
    required this.load,
    required this.isEmpty,
    required this.skeleton,
    required this.empty,
    required this.builder,
    this.onLoaded,
    this.pullToRefresh = true,
    this.onNext,
  });

  @override
  State<AsyncView<T>> createState() => AsyncViewState<T>();
}

class AsyncViewState<T> extends State<AsyncView<T>> {
  T? _data;
  bool _has = false;
  AppError? _error;
  bool _loading = false;
  bool _showIndicator = false;
  DateTime? _indicatorAt;

  bool get busy => _loading;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// 重新请求。已有数据时静默刷新；没有数据时回到加载态（错误页上的“重试”会显示 loading）。
  Future<void> reload() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _showIndicator = false;
      _indicatorAt = null;
    });
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && _loading) {
        setState(() {
          _showIndicator = true;
          _indicatorAt = DateTime.now();
        });
      }
    });
    T? data;
    AppError? err;
    try {
      data = await widget.load();
    } catch (e) {
      err = AppError.from(e);
    }
    timer.cancel();
    // 指示已经出现的话，至少停留到 500ms
    final shownAt = _indicatorAt;
    if (shownAt != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(shownAt);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted) return; // 页面销毁后不再回调
    final failed = err;
    setState(() {
      _loading = false;
      _showIndicator = false;
      if (failed == null) {
        _data = data as T;
        _has = true;
        _error = null;
      } else if (!_has) {
        _error = failed;
      }
    });
    if (failed == null) {
      widget.onLoaded?.call(data as T);
    } else if (_has) {
      // 有旧数据：只弹 Toast（可重试），不替换页面内容
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? reload : null,
      );
    }
  }

  Widget _scrollable(Widget child) {
    if (!widget.pullToRefresh) return child;
    return RefreshIndicator(
      onRefresh: reload,
      child: LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    final Key key;
    if (_has) {
      key = const ValueKey('data');
      final data = _data as T;
      if (widget.isEmpty(data)) {
        body = _scrollable(widget.empty(context));
      } else {
        final content = widget.builder(context, data);
        body = Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: _loading && _showIndicator ? 0.6 : 1,
                child: content,
              ),
            ),
            if (_loading && _showIndicator)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      }
    } else if (_error != null) {
      key = const ValueKey('error');
      body = _scrollable(
        ErrorView(
          error: _error!,
          retrying: _loading,
          onRetry: reload,
          onNext: widget.onNext,
        ),
      );
    } else {
      key = const ValueKey('loading');
      // 300ms 内什么都不显示，之后才出骨架
      body = _showIndicator
          ? SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: widget.skeleton,
            )
          : const SizedBox.expand();
    }
    return AnimatedSwitcher(
      duration: kFadeIn,
      child: KeyedSubtree(key: key, child: body),
    );
  }
}
