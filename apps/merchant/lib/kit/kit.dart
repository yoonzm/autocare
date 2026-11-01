// 设计稿转换后的页面所用的运行时组件。
// 页面代码由 tools/design_to_flutter.py 生成，请勿手工修改 lib/pages/gen 下的文件。
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../routes.dart';
import '../theme.dart' show C;
import 'keyboard.dart';
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
Widget hTap(
  BuildContext context,
  Widget child, {
  String? to,
  bool back = false,
  VoidCallback? onTap,
  String? label,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      if (onTap != null) {
        onTap();
      } else if (back) {
        // 结果页（收款成功、开卡成功等）禁止侧滑返回，左上角 ✕ 回到入口，而不是上一步
        final name = ModalRoute.of(context)?.settings.name;
        if (name != null && resultPages.contains(name)) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        } else {
          Navigator.of(context).maybePop();
        }
      } else if (to != null) {
        openRoute(context, to);
      } else {
        HapticFeedback.selectionClick();
        if (label != null && label.isNotEmpty) hToast(context, '$label（演示）');
      }
    },
    child: child,
  );
}

void hToast(BuildContext context, String msg) =>
    hToastOn(ScaffoldMessenger.of(context), msg);

/// 提示条：深浅色都用明确的文字色与底色，悬浮在底部操作栏上方。
void hToastOn(ScaffoldMessengerState messenger, String msg) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 104),
        duration: const Duration(milliseconds: 1600),
        elevation: 0,
        backgroundColor: C.dark
            ? const Color(0xFF3A3A40)
            : const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
}

bool _confirming = false;

/// 确认弹窗：居中卡片，标题 + 说明 + 两个胶囊按钮。
Future<bool> hConfirm(
  BuildContext context,
  String title, {
  String ok = '确定',
  String cancel = '取消',
  String? message,
  bool danger = true,
}) async {
  if (_confirming) return false;
  _confirming = true;
  try {
    final r = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierColor: const Color(0x73000000),
      builder: (ctx) => Dialog(
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
                    dk(ctx, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
                    lh: 20,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: dk(
                            ctx,
                            const Color(0xFFEEEEF0),
                            const Color(0xFF34343A),
                          ),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Text(
                          cancel,
                          style: hts(
                            15,
                            dk(
                              ctx,
                              const Color(0xFF18181B),
                              const Color(0xFFFAFAFA),
                            ),
                            w: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: danger
                              ? const Color(0xFFFF383C)
                              : const Color(0xFF0485F7),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Text(
                          ok,
                          style: hts(15, Colors.white, w: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return r ?? false;
  } finally {
    _confirming = false;
  }
}

/// 删除 / 停用类操作：确认后返回上一页。
Future<void> hConfirmPop(BuildContext context, String label) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (await hConfirm(context, '确认$label？', message: '该操作会立即生效，请再确认一次。')) {
    // 等弹窗退场动画结束再返回，避免两层转场叠在一起留下遮罩
    await Future<void>.delayed(const Duration(milliseconds: 240));
    nav.maybePop();
    hToastOn(messenger, '已完成（演示）');
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
  const HSwitch({
    super.key,
    required this.initial,
    this.onColor = const Color(0xFF0485F7),
    this.offColor = const Color(0xFFD4D4D8),
  });
  @override
  State<HSwitch> createState() => _HSwitchState();
}

class _HSwitchState extends State<HSwitch> {
  late bool on = widget.initial;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => on = !on),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(2),
      alignment: on ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: on
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
  final double size;
  final Color color;
  const HCheck({
    super.key,
    required this.initial,
    this.size = 16,
    this.color = const Color(0xFF0485F7),
  });
  @override
  State<HCheck> createState() => _HCheckState();
}

class _HCheckState extends State<HCheck> {
  late bool on = widget.initial;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => on = !on),
    child: Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: on
            ? widget.color
            : dk(context, Colors.white, const Color(0xFF1F1F23)),
        borderRadius: BorderRadius.circular(widget.size * 0.25),
        border: Border.all(
          color: on ? widget.color : const Color(0xFFA1A1AA),
          width: 1.5,
        ),
      ),
      child: on
          ? Icon(
              Icons.check_rounded,
              size: widget.size - 3,
              color: Colors.white,
            )
          : null,
    ),
  );
}

class HInput extends StatelessWidget {
  final String hint;
  final String value;
  final TextStyle style;
  final TextInputType? keyboard;
  final bool obscure;
  final int? maxLines;
  final TextAlign align;
  final Color hintColor;
  const HInput({
    super.key,
    required this.style,
    this.hint = '',
    this.value = '',
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.align = TextAlign.start,
    this.hintColor = const Color(0xFF71717A),
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    onTapOutside: onTapOutsideDismiss,
    textInputAction: obscure || maxLines == 1
        ? TextInputAction.done
        : TextInputAction.newline,
    initialValue: value,
    style: style,
    textAlign: align,
    keyboardType: keyboard,
    obscureText: obscure,
    maxLines: obscure ? 1 : maxLines,
    minLines: 1,
    decoration: InputDecoration(
      isCollapsed: true,
      border: InputBorder.none,
      hintText: hint,
      hintStyle: style.copyWith(
        color: hintColor == const Color(0xFF71717A)
            ? dk(context, hintColor, const Color(0xFF9A9AA3))
            : hintColor,
      ),
    ),
  );
}

// ───────── 单选 / 多选组 ─────────
class SelCtrl extends ChangeNotifier {
  final Set<int> selected;
  final bool multi;
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

class HSelHolder extends StatefulWidget {
  /// 每组：(初始选中集合, 是否多选)
  final List<(Set<int>, bool)> groups;
  final Widget Function(BuildContext, List<SelCtrl>) builder;

  /// 分组下标 -> 选中变化时的回调（参数为被点选的序号）
  final Map<int, void Function(int)> onSelect;
  const HSelHolder({
    super.key,
    required this.groups,
    required this.builder,
    this.onSelect = const {},
  });
  @override
  State<HSelHolder> createState() => _HSelHolderState();
}

class _HSelHolderState extends State<HSelHolder> {
  late final List<SelCtrl> ctrls = [
    for (var i = 0; i < widget.groups.length; i++)
      SelCtrl({...widget.groups[i].$1}, widget.groups[i].$2)
        ..onSelect = widget.onSelect[i],
  ];
  @override
  Widget build(BuildContext context) => widget.builder(context, ctrls);
}

class HSel extends StatelessWidget {
  final SelCtrl ctrl;
  final int index;
  final Widget on, off;
  const HSel({
    super.key,
    required this.ctrl,
    required this.index,
    required this.on,
    required this.off,
  });
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ctrl,
    builder: (_, _) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ctrl.tap(index),
      child: ctrl.selected.contains(index) ? on : off,
    ),
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

class HHolder extends StatefulWidget {
  final List<int> inits;
  final Widget Function(BuildContext, List<ValCtrl>) builder;
  const HHolder({super.key, required this.inits, required this.builder});
  @override
  State<HHolder> createState() => _HHolderState();
}

class _HHolderState extends State<HHolder> {
  late final List<ValCtrl> ctrls = [for (final i in widget.inits) ValCtrl(i)];
  @override
  void dispose() {
    for (final c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, ctrls);
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

Widget hMonth(ValCtrl c, TextStyle style) => ListenableBuilder(
  listenable: c,
  builder: (_, _) => Text('${c.v ~/ 12} 年 ${c.v % 12 + 1} 月', style: style),
);

Widget hPwdLabel(ValCtrl c, TextStyle style) => ListenableBuilder(
  listenable: c,
  builder: (_, _) => Text(c.on ? '显示' : '隐藏', style: style),
);

/// 独立的开关式控件（复选、多选标签）。
class HToggle extends StatefulWidget {
  final bool initial;
  final Widget on, off;
  const HToggle({
    super.key,
    required this.initial,
    required this.on,
    required this.off,
  });
  @override
  State<HToggle> createState() => _HToggleState();
}

class _HToggleState extends State<HToggle> {
  late bool sel = widget.initial;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => sel = !sel),
    child: sel ? widget.on : widget.off,
  );
}

/// 可按标签筛选、可删除条目的列表。
class HDyn extends StatefulWidget {
  final List<String> texts;
  final SelCtrl? filter;
  final List<String> labels;
  final Widget Function(BuildContext, HDynState) builder;
  const HDyn({
    super.key,
    required this.texts,
    this.filter,
    this.labels = const [],
    required this.builder,
  });
  @override
  State<HDyn> createState() => HDynState();
}

class HDynState extends State<HDyn> {
  final Set<int> removed = {};

  List<Widget> vis(List<Widget> items) {
    String? want;
    final f = widget.filter;
    if (f != null && f.selected.isNotEmpty) {
      final i = f.selected.first;
      if (i < widget.labels.length) want = widget.labels[i];
    }
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (removed.contains(i)) continue;
      if (want != null &&
          want.isNotEmpty &&
          !want.contains('全部') &&
          !widget.texts[i].contains(want)) {
        continue;
      }
      out.add(items[i]);
    }
    return out;
  }

  Future<void> confirmRemove(BuildContext context, int i) async {
    if (await hConfirm(context, '确认删除？', ok: '删除') && mounted) {
      setState(() => removed.add(i));
      if (context.mounted) hToast(context, '已删除（演示）');
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.filter;
    if (f == null) return widget.builder(context, this);
    return ListenableBuilder(
      listenable: f,
      builder: (ctx, _) => widget.builder(ctx, this),
    );
  }
}
