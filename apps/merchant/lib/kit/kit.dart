import 'buttons.dart';

import 'dart:async';
// 既有页面的兼容组件；迁移页面使用显式参数与回调。
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/choice_chip_group.dart';
import 'async_kit.dart';
export '../widgets/card_face.dart' show CardPreview;
export 'async_kit.dart' show hBusy;
export '../widgets/color_fields.dart' show CardColorChoices;
export '../widgets/package_widgets.dart' show PackagePreview, PackageItems;
import '../backend/store_profile.dart';
import '../theme.dart' show C;
export 'pickers.dart';
export 'image_pick.dart';

/// 页面骨架：可滚动的正常流内容 + 固定在屏幕上的浮层（底部栏、弹层等）。
class HPage extends StatelessWidget {
  final Color bg;
  final double height;
  final bool fixedHeight;
  final Widget flow;
  final List<Widget> overlays;
  const HPage({
    super.key,
    required this.bg,
    required this.height,
    required this.flow,
    this.fixedHeight = false,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, c) {
          final h = math.max(height, c.maxHeight);
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: fixedHeight
                      ? SizedBox(height: h, width: double.infinity, child: flow)
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: h,
                            minWidth: double.infinity,
                          ),
                          child: flow,
                        ),
                ),
              ),
              ...overlays,
            ],
          );
        },
      ),
    );
  }
}

/// 固定在屏幕底部的浮层，超出屏幕高度时内部可滚动。
class HBottomDock extends StatelessWidget {
  final Widget child;
  final double left, right;
  const HBottomDock({
    super.key,
    required this.child,
    this.left = 0,
    this.right = 0,
  });
  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.94;
    return Positioned(
      left: left,
      right: right,
      bottom: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(reverse: true, child: child),
      ),
    );
  }
}

double bottomInset(BuildContext context, [double min = 16]) =>
    math.max(MediaQuery.of(context).padding.bottom, min);

double topInset(BuildContext context) =>
    MediaQuery.of(context).padding.top + 12;

/// 浅色 / 深色二选一：按当前主题亮度返回对应值（依赖 Theme，主题切换时自动重建）。
T dk<T>(BuildContext context, T light, T dark) =>
    Theme.of(context).brightness == Brightness.dark ? dark : light;

// ───────── 点击与导航 ─────────
void hToast(BuildContext context, String msg) =>
    hToastOn(ScaffoldMessenger.of(context), msg);

/// 提示条（信息类，2s）。成功 / 失败请直接用 [AppToast]，失败提示停留更久。
void hToastOn(ScaffoldMessengerState messenger, String msg) =>
    AppToast.showOn(messenger, msg);

bool _confirming = false;

/// 表单离开保护：提交中禁止返回，有修改时复用统一确认弹窗。
class ConfirmDiscard extends StatefulWidget {
  final bool dirty, busy;
  final Widget child;
  const ConfirmDiscard({
    super.key,
    required this.dirty,
    required this.busy,
    required this.child,
  });
  @override
  State<ConfirmDiscard> createState() => _ConfirmDiscardState();
}

class _ConfirmDiscardState extends State<ConfirmDiscard> {
  bool _allow = false;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.busy && (!widget.dirty || _allow),
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop || widget.busy || _allow || !widget.dirty) return;
      final ok = await hConfirm(context, '放弃未保存的修改？', ok: '放弃', danger: false);
      if (!mounted || !ok) return;
      setState(() => _allow = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    },
    child: widget.child,
  );
}

/// 确认弹窗：居中卡片，标题 + 说明 + 两个胶囊按钮。
Future<bool> hConfirm(
  BuildContext context,
  String title, {
  String ok = '确定',
  String cancel = '取消',
  String? message,
  bool danger = true,

  /// 确认后要等待的异步动作（如调用后端）。传入后确认按钮自带 loading，
  /// 完成后才关闭弹层；失败时弹层保持打开并提示原因。
  Future<void> Function()? onConfirm,
}) async {
  if (_confirming) return false;
  _confirming = true;
  var busy = false;
  try {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final r = await showGeneralDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: '确认弹窗',
      barrierColor: const Color(0x73000000),
      transitionDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      transitionBuilder: (ctx, animation, _, child) {
        if (reduceMotion) return child;
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, _) => StatefulBuilder(
        builder: (ctx, setS) => PopScope(
          canPop: !busy,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 36),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              decoration: BoxDecoration(
                color: dk(ctx, Colors.white, const Color(0xFF1F1F23)),
                borderRadius: BorderRadius.circular(28),
                border: dk<Border?>(
                  ctx,
                  null,
                  Border.all(color: const Color(0xFF2E2E33)),
                ),
                boxShadow: dk(ctx, const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 40,
                    offset: Offset(0, 16),
                  ),
                ], const <BoxShadow>[]),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: hts(
                      18,
                      dk(ctx, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 26,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: hts(
                        14,
                        dk(
                          ctx,
                          const Color(0xFF71717A),
                          const Color(0xFF9A9AA3),
                        ),
                        lh: 20,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: cancel,
                          kind: AppButtonKind.secondary,
                          size: AppButtonSize.medium,
                          expanded: false,
                          onPressed: busy
                              ? null
                              : () => Navigator.of(ctx).pop(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          loading: busy,
                          label: ok,
                          kind: danger
                              ? AppButtonKind.danger
                              : AppButtonKind.primary,
                          size: AppButtonSize.medium,
                          expanded: false,
                          onPressed: () async {
                            if (busy) return;
                            if (onConfirm == null) {
                              Navigator.of(ctx).pop(true);
                              return;
                            }
                            setS(() => busy = true);
                            try {
                              await Future.wait([
                                onConfirm(),
                                Future<void>.delayed(kIndicatorMinShow),
                              ]);
                              if (ctx.mounted) Navigator.of(ctx).pop(true);
                            } catch (e) {
                              if (ctx.mounted) {
                                setS(() => busy = false);
                                AppToast.error(ctx, e);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return r ?? false;
  } finally {
    _confirming = false;
  }
}

// ───────── 盒子 ─────────
Widget hbox({
  double? w,
  double? h,
  double? minW,
  double? minH,
  double? maxW,
  Color? bg,
  Gradient? grad,
  BorderRadiusGeometry? radius,
  List<BoxShadow>? shadow,
  BoxBorder? border,
  EdgeInsetsGeometry? pad,
  EdgeInsetsGeometry? margin,
  bool clip = false,
  double? opacity,
  AlignmentGeometry? align,
  bool dashed = false,
  Color? dashColor,
  double dashWidth = 2,
  Widget? child,
}) {
  Widget r;
  if (dashed) {
    r = CustomPaint(
      foregroundPainter: _DashedPainter(
        dashColor ?? Colors.grey,
        dashWidth,
        radius is BorderRadius ? radius.topLeft.x : 0,
      ),
      child: child == null
          ? null
          : Container(padding: pad, alignment: align, child: child),
    );
    r = Container(
      width: w,
      height: h,
      constraints: BoxConstraints(
        minWidth: minW ?? 0,
        minHeight: minH ?? 0,
        maxWidth: maxW ?? double.infinity,
      ),
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        gradient: grad,
        borderRadius: radius,
        boxShadow: shadow,
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: r,
    );
  } else {
    final outer =
        bg == null && grad == null && shadow != null && shadow.isNotEmpty;
    final hasDeco =
        bg != null ||
        grad != null ||
        radius != null ||
        (shadow != null && !outer) ||
        border != null;
    r = Container(
      width: w,
      height: h,
      constraints: (minW != null || minH != null || maxW != null)
          ? BoxConstraints(
              minWidth: minW ?? 0,
              minHeight: minH ?? 0,
              maxWidth: maxW ?? double.infinity,
            )
          : null,
      padding: pad,
      margin: outer ? null : margin,
      alignment: align,
      decoration: hasDeco
          ? BoxDecoration(
              color: bg,
              gradient: grad,
              borderRadius: radius,
              boxShadow: outer ? null : shadow,
              border: border,
            )
          : null,
      clipBehavior: (clip && hasDeco) ? Clip.antiAlias : Clip.none,
      child: (clip && !hasDeco && child != null)
          ? ClipRect(child: child)
          : child,
    );
  }
  if (bg == null &&
      grad == null &&
      shadow != null &&
      shadow.isNotEmpty &&
      !dashed) {
    r = CustomPaint(painter: _OuterShadowPainter(shadow, radius), child: r);
    if (margin != null) r = Padding(padding: margin, child: r);
  }
  if (opacity != null) r = Opacity(opacity: opacity, child: r);
  return r;
}

/// CSS 的 box-shadow 只画在盒子外面；Flutter 的 BoxShadow 会铺满盒子底下。
/// 盒子本身没有底色时（透明），用这个只画外侧阴影。
class _OuterShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;
  final BorderRadiusGeometry? radius;
  _OuterShadowPainter(this.shadows, this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = (radius ?? BorderRadius.zero)
        .resolve(TextDirection.ltr)
        .toRRect(rect);
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect.inflate(400)),
      Path()..addRRect(rr),
    );
    canvas.save();
    canvas.clipPath(outside);
    for (final s in shadows) {
      canvas.drawRRect(rr.shift(s.offset).inflate(s.spreadRadius), s.toPaint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OuterShadowPainter old) => true;
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double width, radius;
  _DashedPainter(this.color, this.width, this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rr);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter o) =>
      o.color != color || o.width != width;
}

/// 负外边距（CSS margin-top: -22px 等）。
class NegMargin extends SingleChildRenderObjectWidget {
  final double top, left;
  const NegMargin({super.key, this.top = 0, this.left = 0, super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderNegMargin(top, left);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderNegMargin renderObject,
  ) {
    renderObject
      ..top = top
      ..left = left;
  }
}

class RenderNegMargin extends RenderShiftedBox {
  double top, left;
  RenderNegMargin(this.top, this.left) : super(null);
  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(c.size.width + left, c.size.height + top),
    );
    (c.parentData as BoxParentData).offset = Offset(left, top);
  }
}

// ───────── 弹性布局 ─────────
Widget hrow(
  List<Widget> children, {
  MainAxisAlignment main = MainAxisAlignment.start,
  CrossAxisAlignment cross = CrossAxisAlignment.start,
  double gap = 0,
  bool intrinsic = false,
  bool min = true,
}) {
  final r = Row(
    mainAxisSize: min ? MainAxisSize.min : MainAxisSize.max,
    mainAxisAlignment: main,
    crossAxisAlignment: cross,
    textBaseline: TextBaseline.alphabetic,
    spacing: gap,
    children: children,
  );
  return intrinsic ? IntrinsicHeight(child: r) : r;
}

Widget hcol(
  List<Widget> children, {
  MainAxisAlignment main = MainAxisAlignment.start,
  CrossAxisAlignment cross = CrossAxisAlignment.stretch,
  double gap = 0,
  bool min = true,
}) => Column(
  mainAxisSize: min ? MainAxisSize.min : MainAxisSize.max,
  mainAxisAlignment: main,
  crossAxisAlignment: cross,
  spacing: gap,
  children: children,
);

Widget hwrap(
  List<Widget> children, {
  double gap = 0,
  double rowGap = 0,
  WrapCrossAlignment cross = WrapCrossAlignment.start,
  WrapAlignment main = WrapAlignment.start,
}) => Wrap(
  spacing: gap,
  runSpacing: rowGap,
  crossAxisAlignment: cross,
  alignment: main,
  children: children,
);

/// 层叠容器：第一个子项决定尺寸，其余为绝对定位。
Widget hstack(
  Widget flow,
  List<Widget> abs, {
  List<Widget> behind = const [],
  bool clip = false,
}) => Stack(
  clipBehavior: clip ? Clip.hardEdge : Clip.none,
  fit: StackFit.passthrough,
  children: [...behind, flow, ...abs],
);

// ───────── 文本 ─────────
TextStyle hts(
  double size,
  Color color, {
  FontWeight w = FontWeight.w400,
  double? lh,
  double? ls,
  bool tab = false,
  TextDecoration? deco,
}) => TextStyle(
  fontSize: size,
  color: color,
  fontWeight: w,
  height: lh != null ? lh / size : null,
  letterSpacing: ls,
  leadingDistribution: TextLeadingDistribution.even,
  decoration: deco ?? TextDecoration.none,
  fontFeatures: tab ? const [FontFeature.tabularFigures()] : null,
);

// ───────── SVG ─────────
Widget hsvg(String markup, {double? w, double? h}) =>
    SvgPicture.string(markup, width: w, height: h);

// ───────── 表单控件 ─────────
/// 受控开关（外部持有状态），样式与设计稿一致。
class HSwitchValue extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const HSwitchValue({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(2),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF0485F7)
            : (C.dark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    ),
  );
}

class HSwitch extends StatefulWidget {
  final bool initial;
  final Color onColor, offColor;

  /// 受控模式（[onChanged] 不为空时）：开关状态由 [value] 决定。
  final bool? value;
  final ValueChanged<bool>? onChanged;
  const HSwitch({
    super.key,
    required this.initial,
    this.onColor = const Color(0xFF0485F7),
    this.offColor = const Color(0xFFD4D4D8),
    this.value,
    this.onChanged,
  });
  @override
  State<HSwitch> createState() => _HSwitchState();
}

class _HSwitchState extends State<HSwitch> {
  late bool on = widget.initial;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      if (widget.onChanged != null) {
        // 受控模式：值由外部保存，成功与否由外部决定
        widget.onChanged!(!widget.value!);
        return;
      }
      setState(() => on = !on);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(2),
      alignment: (widget.onChanged != null ? widget.value! : on)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: (widget.onChanged != null ? widget.value! : on)
            ? widget.onColor
            : dk(
                context,
                widget.offColor,
                widget.offColor == const Color(0xFFD4D4D8)
                    ? const Color(0xFF3F3F46)
                    : widget.offColor,
              ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    ),
  );
}

class HCheck extends StatefulWidget {
  final bool initial;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color color;
  const HCheck({
    super.key,
    required this.initial,
    this.value,
    this.onChanged,
    this.size = 16,
    this.color = const Color(0xFF0485F7),
  });
  @override
  State<HCheck> createState() => _HCheckState();
}

class _HCheckState extends State<HCheck> {
  late bool on = widget.initial;
  bool get selected => widget.value ?? on;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      if (widget.onChanged != null) {
        widget.onChanged!(!selected);
        return;
      }
      setState(() => on = !on);
    },
    child: Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: selected
            ? widget.color
            : dk(context, Colors.white, const Color(0xFF1F1F23)),
        borderRadius: BorderRadius.circular(widget.size * 0.25),
        border: Border.all(
          color: selected ? widget.color : const Color(0xFFA1A1AA),
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: widget.size - 3,
              color: Colors.white,
            )
          : null,
    ),
  );
}

/// 当前会话的门店资料驱动文字；未加载值由门店模型处理。
Widget hLiveText(
  String Function(StoreProfile p) text,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: storeProfile,
  builder: (_, _) => Text(
    text(storeProfile),
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

// ───────── 单选 / 多选组 ─────────
class SelCtrl extends ChangeNotifier {
  final Set<int> selected;
  final bool multi;

  /// 取消全部选中（如输入了自定义金额后取消档位）。
  void clear() {
    selected.clear();
    notifyListeners();
  }

  /// 外部直接改了 [selected] 后刷新选中显示。
  void refresh() => notifyListeners();

  void Function(int)? onSelect;
  SelCtrl(this.selected, this.multi);
  void tap(int i) {
    onSelect?.call(i);
    if (multi) {
      selected.contains(i) ? selected.remove(i) : selected.add(i);
    } else {
      selected
        ..clear()
        ..add(i);
    }
    notifyListeners();
  }
}

class HSel extends StatelessWidget {
  final SelCtrl ctrl;
  final int index;
  final Widget on, off;

  /// 分段条（设计稿 role=tab）：按设计稿原样显示选中 / 未选中，不套 ChoiceChip 样式。
  final bool segment;
  final VoidCallback? onTap;
  const HSel({
    super.key,
    required this.ctrl,
    required this.index,
    required this.on,
    required this.off,
    this.segment = false,
    this.onTap,
  });
  static String? _label(Widget widget) => switch (widget) {
    Text(:final data, :final textSpan) => data ?? textSpan?.toPlainText(),
    RichText(:final text) => text.toPlainText(),
    Container(:final child) => child == null ? null : _label(child),
    Align(:final child) => child == null ? null : _label(child),
    Padding(:final child) => child == null ? null : _label(child),
    SizedBox(:final child) => child == null ? null : _label(child),
    Flexible(:final child) => _label(child),
    Row(:final children) => _firstLabel(children),
    Column(:final children) => _firstLabel(children),
    Wrap(:final children) => _firstLabel(children),
    _ => null,
  };
  static String? _firstLabel(List<Widget> children) {
    for (final child in children) {
      final label = _label(child);
      if (label != null && label.trim().isNotEmpty) return label;
    }
    return null;
  }

  static double? _visualHeight(Widget widget) => switch (widget) {
    Container(:final constraints, :final child) =>
      constraints?.maxHeight.isFinite == true
          ? constraints!.maxHeight
          : child == null
          ? null
          : _visualHeight(child),
    Align(:final child) => child == null ? null : _visualHeight(child),
    Padding(:final child) => child == null ? null : _visualHeight(child),
    _ => null,
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ctrl,
    builder: (_, _) {
      // 32px 分段条 / 特色选项不是 ChoiceChip，保留原设计；34px 胶囊统一样式。
      final label = segment || ctrl.multi || _visualHeight(on) != 34
          ? null
          : (_label(off) ?? _label(on));
      if (label != null && label.trim().isNotEmpty) {
        final selected = ctrl.selected.contains(index);
        return ChoiceChipGroup<int>(
          semanticLabel: label,
          kind: ChipKind.pill,
          items: [
            ChoiceChipItem(
              value: index,
              label: label,
              isOriginal: label.endsWith(' 原'),
            ),
          ],
          selected: selected ? index : null,
          onChanged: (_) {
            if (!selected) {
              if (onTap != null) {
                onTap!();
              } else {
                ctrl.tap(index);
              }
            }
          },
        );
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () => ctrl.tap(index),
        child: ctrl.selected.contains(index) ? on : off,
      );
    },
  );
}

/// 将原始 [Positioned] 的百分比宽度包装。
Widget hfrac(
  double f,
  Widget child, {
  AlignmentGeometry align = Alignment.centerLeft,
}) => Align(
  alignment: align,
  child: FractionallySizedBox(widthFactor: f, child: child),
);

// ───────── 计数 / 开关状态 ─────────
class ValCtrl extends ChangeNotifier {
  int v;
  ValCtrl(this.v);
  bool get on => v != 0;
  void set(int x) {
    if (x != v) {
      v = x;
      notifyListeners();
    }
  }

  void add(int d, {int min = 0}) => set(math.max(min, v + d));
  void flip() => set(on ? 0 : 1);
}

/// 数字增减控件。按钮外观和数字占位由设计稿提供，交互与排布统一在这里。
/// [step] 与 [ValCtrl] 的存储单位一致；小数值由中间的 [hCount] 格式化。
class HNumberStepper extends StatelessWidget {
  final ValCtrl? ctrl;
  final VoidCallback? onDecrease, onIncrease;
  final int step;
  final Widget value;
  final MainAxisAlignment main;
  final CrossAxisAlignment cross;
  final double gap;

  const HNumberStepper({
    super.key,
    required this.ctrl,
    required this.step,
    required this.value,
    this.main = MainAxisAlignment.start,
    this.cross = CrossAxisAlignment.center,
    this.gap = 4,
  }) : assert(step > 0),
       onDecrease = null,
       onIncrease = null;

  /// 受控模式：数值与边界由页面管理，复用既有按钮外观和排布。
  const HNumberStepper.controlled({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    required this.value,
    this.main = MainAxisAlignment.start,
    this.cross = CrossAxisAlignment.center,
    this.gap = 4,
  }) : ctrl = null,
       step = 1;

  @override
  Widget build(BuildContext context) => hrow(
    [
      AppIconButton(
        icon: Icons.remove,
        size: AppIconButtonSize.small,
        semanticLabel: '减少',
        onPressed: onDecrease ?? (ctrl == null ? null : () => ctrl!.add(-step)),
      ),
      value,
      AppIconButton(
        icon: Icons.add,
        size: AppIconButtonSize.small,
        semanticLabel: '增加',
        onPressed: onIncrease ?? (ctrl == null ? null : () => ctrl!.add(step)),
      ),
    ],
    main: main,
    cross: cross,
    gap: gap,
  );
}

/// 步进器中间的数字：[dec] 小数位（值按 10^dec 放大保存）、[suffix] 单位后缀、[comma] 千分位。
Widget hCount(
  ValCtrl c,
  TextStyle style, [
  int dec = 0,
  String suffix = '',
  bool comma = false,
]) => ListenableBuilder(
  listenable: c,
  builder: (_, _) {
    final base = dec == 0 ? c.v.toDouble() : c.v / math.pow(10, dec);
    var t = base.toStringAsFixed(dec);
    if (comma) {
      final parts = t.split('.');
      final ip = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
      t = parts.length > 1 ? '$ip.${parts[1]}' : ip;
    }
    return Text('$t$suffix', style: style);
  },
);
