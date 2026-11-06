import 'package:flutter/material.dart';

import 'async_theme.dart';
import 'spinner.dart';
import 'timing.dart';
import 'toast.dart';

final ValueNotifier<Set<String>> busyActions = ValueNotifier(const {});

bool isBusy(String key) => busyActions.value.contains(key);

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

/// 异步动作进行中时拦截点击（防连点），尺寸和外观不变。
/// loading 的视觉由 [hBusy] 画在按钮内容上；同一动作的其他按钮（如取消 ✕）
/// 只是不可点，不显示转圈。
class BusyOverlay extends StatelessWidget {
  final String actionKey;
  final Widget child;
  const BusyOverlay({super.key, required this.actionKey, required this.child});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: busyActions,
    child: child,
    builder: (context, keys, child) =>
        AbsorbPointer(absorbing: keys.contains(actionKey), child: child),
  );
}

/// Adapts an existing designed control to async actions without changing its
/// dimensions. Synchronous navigation does not display a loading indicator.
class AsyncAction extends StatefulWidget {
  final String? actionKey;
  final Function()? onTap;
  final Widget Function(String actionKey, VoidCallback? onTap) builder;
  const AsyncAction({
    super.key,
    this.actionKey,
    required this.onTap,
    required this.builder,
  });
  @override
  State<AsyncAction> createState() => _AsyncActionState();
}

class _AsyncActionState extends State<AsyncAction> {
  late final keyName = widget.actionKey ?? 'control-${identityHashCode(this)}';
  Future<void> _tap() async {
    if (isBusy(keyName) || widget.onTap == null) return;
    try {
      final result = widget.onTap!();
      if (result is Future) {
        await runBusy(keyName, () async {
          await result;
        });
      }
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(keyName, widget.onTap == null ? null : _tap);
}

/// Prevent closing or editing a confirmation while its one submit control waits.
class AsyncActionScope extends StatelessWidget {
  final String actionKey;
  final Widget child;
  const AsyncActionScope({
    super.key,
    required this.actionKey,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: busyActions,
    child: child,
    builder: (context, keys, child) => PopScope(
      canPop: !keys.contains(actionKey),
      child: AbsorbPointer(absorbing: keys.contains(actionKey), child: child!),
    ),
  );
}

/// 按钮内容在 [actionKey] 忙碌时的 loading（设计稿“按钮提交”规范）：
/// 原内容（文字 / 图标）隐藏，只显示转圈，按钮的宽高和背景保持不变。
///
/// 由既有按钮传入内容及样式，组件只处理忙碌状态。
/// [spinner] 为 false 时只隐藏内容（同一个按钮里有多个子元素时，只有第一个画转圈）。
Widget hBusy(
  String actionKey,
  Widget child, {
  TextStyle? style,
  bool icon = false,
  bool spinner = true,

  /// 全宽底栏按钮的加载文案（设计稿“提交中…”）：转圈在左、文字在右，整体居中。
  /// 顶部的小按钮不传，只显示转圈。
  String? label,

  /// 顶部的“保存”胶囊按钮：加载时变成设计稿图标按钮的样子（44×44 的圆 + 20px 转圈）。
  /// 胶囊左右各有 18px 内边距，内容收成 8px 宽，整个按钮正好是 44 宽。
  bool round = false,
}) => ValueListenableBuilder<Set<String>>(
  valueListenable: busyActions,
  child: child,
  builder: (context, keys, child) {
    if (!keys.contains(actionKey)) return child!;
    // 文字按钮的转圈和文字同色（主按钮是白色）；图标按钮按设计稿用主色
    final color = icon
        ? AsyncKitTheme.of(context).primary
        : (style?.color ?? AsyncKitTheme.of(context).ink);
    if (round && spinner && !icon) {
      return SizedBox(
        width: 8,
        height: 20,
        child: OverflowBox(
          maxWidth: 20,
          maxHeight: 20,
          child: Semantics(
            label: '处理中',
            liveRegion: true,
            child: AppSpinner(size: 20, color: color),
          ),
        ),
      );
    }
    if (label != null && spinner && !icon) {
      // 转圈 + 文字（设计稿：“提交中…”“保存中…”）。原内容仍隐藏着占位，
      // 加载内容比原内容宽时按钮随之撑开，不会比原来更小。
      return Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: child),
          Semantics(
            label: '处理中',
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSpinner(size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: style, softWrap: false, maxLines: 1),
              ],
            ),
          ),
        ],
      );
    }
    return Stack(
      // passthrough：沿用外层给的约束，按钮不会因为内容变成转圈而缩成小圆
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0, child: child),
        // Positioned 不参与 Stack 的尺寸计算，转圈只是画在原内容的位置上
        if (spinner)
          Positioned.fill(
            child: Center(
              child: Semantics(
                label: '处理中',
                liveRegion: true,
                child: AppSpinner(size: icon ? 20 : 18, color: color),
              ),
            ),
          ),
      ],
    );
  },
);
