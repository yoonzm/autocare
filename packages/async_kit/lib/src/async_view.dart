import 'dart:async';

import 'package:flutter/material.dart';

import 'errors.dart';
import 'feedback_views.dart';
import 'timing.dart';
import 'toast.dart';

/// 包装一次请求，按状态渲染：
/// 加载中（300ms 后才出骨架，出现后至少 500ms）→ 内容（150ms 淡入）/ 空 / 错误（带重试）。
/// 已有数据时的刷新：旧内容保留并变淡 + 顶部细进度条；刷新失败只弹带“重试”的 Toast。
class AsyncView<T> extends StatefulWidget {
  /// Inline sections inside a scrolling page take the height of their content.
  final bool shrinkWrap;
  final bool inlineError;
  final Future<T> Function() load;
  final bool Function(T data) isEmpty;
  final Widget skeleton;
  final Widget? waiting;
  final bool skeletonScrollable;
  final EdgeInsetsGeometry skeletonPadding;
  final Widget Function(BuildContext context) empty;
  final Widget Function(BuildContext context, T data) builder;

  /// 数据加载成功后回调（用于页面其他位置同步显示条数等）。
  final void Function(T data)? onLoaded;

  /// Called after a request settles, including errors, once the loading lock clears.
  /// Hosts can use this to drain refresh signals received while loading.
  final VoidCallback? onSettled;

  /// 空状态 / 错误状态下也可下拉刷新；内容状态需 builder 返回可滚动控件。
  final bool pullToRefresh;

  /// 登录失效 / 无权限 / 不存在时的“下一步”（重新登录 / 返回）。
  final VoidCallback? onNext;
  const AsyncView({
    super.key,
    this.shrinkWrap = false,
    this.inlineError = false,
    required this.load,
    required this.isEmpty,
    required this.skeleton,
    this.waiting,
    this.skeletonScrollable = true,
    this.skeletonPadding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
    required this.empty,
    required this.builder,
    this.onLoaded,
    this.onSettled,
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
    if (mounted) widget.onSettled?.call();
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
            if (widget.shrinkWrap)
              Opacity(
                opacity: _loading && _showIndicator ? 0.6 : 1,
                child: content,
              )
            else
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
          inline: widget.inlineError,
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
          ? widget.skeletonScrollable
                ? SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: widget.skeletonPadding,
                    child: widget.skeleton,
                  )
                : widget.skeleton
          : widget.waiting ??
                (widget.shrinkWrap
                    ? const SizedBox.shrink()
                    : const SizedBox.expand());
    }
    return AnimatedSwitcher(
      duration: kFadeIn,
      // 默认的布局是居中；骨架屏 / 内容要贴着顶部并占满区域，否则会出现一大块空白
      layoutBuilder: (current, previous) => Stack(
        fit: widget.shrinkWrap ? StackFit.loose : StackFit.expand,
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: KeyedSubtree(key: key, child: body),
    );
  }
}
