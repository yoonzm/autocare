import 'dart:async';
// 设计稿转换后的页面所用的运行时组件。
// 页面代码由 tools/design_to_flutter.py 生成，请勿手工修改 lib/pages/gen 下的文件。
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../backend/registration_draft.dart';
import '../backend/catalog_draft.dart';
import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import 'async_kit.dart';
export '../widgets/card_face.dart' show hCardPreview;
export 'async_kit.dart' show hBusy;
export '../backend/package_calc.dart' show PackageCalc;
export '../widgets/member_widgets.dart'
    show
        hMemberText,
        hMemberRich,
        hFilterCountText,
        hOrderText,
        hPackageText,
        hRechargeText,
        hTierName,
        RechargeView;
export '../widgets/sale_widgets.dart' show hPackagePicker;
export '../widgets/follow_widgets.dart'
    show
        hFollowProgress,
        hFollowRich,
        hFollowText,
        hReminderList,
        hVisitHistory,
        hVisitNext;
export '../widgets/package_detail_widgets.dart'
    show hPackageRing, hPackageServices, hPackageRecords;
export '../widgets/package_widgets.dart'
    show hPackagePreview, hPackageItems, hPkgText;
import '../backend/forgot_flow.dart';
import '../backend/store_profile.dart';
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
  if (label == '显示密码' && onTap == null && to == null && !back) {
    return PasswordEye(child: child);
  }
  // 底部弹层的路由名是 `sheet:页面名`，忙碌键按页面名
  final route0 = ModalRoute.of(context)?.settings.name
      ?.replaceFirst('sheet:', '');
  final busyKey = to == null || route0 == null ? null : '$route0>$to';
  final tap = GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      final route = ModalRoute.of(context)?.settings.name;
      if (merchantApi.hasSession &&
          to == 'Services' &&
          route == 'ServiceEdit' &&
          _hasSaveLabel(child)) {
        unawaited(
          runBusy(
            '$route>Services',
            () => CatalogDraft.save(context, 'services'),
          ),
        );
        return;
      }
      if (merchantApi.hasSession &&
          to == 'CardTiers' &&
          route == 'CardTierEdit' &&
          _hasSaveLabel(child)) {
        unawaited(
          runBusy(
            '$route>CardTiers',
            () => CatalogDraft.save(context, 'cards'),
          ),
        );
        return;
      }
      // TODO: 开卡成功页的“去充值”和微信绑定依赖支付 / 微信模块，目前只提示，不假装成功。
      if (merchantApi.hasSession &&
          route == 'MemberAddDone' &&
          (to == 'Recharge' || to == 'BindInvite' || to == 'BindH5')) {
        hToast(
          context,
          to == 'Recharge' ? '余额充值暂未接通（依赖支付模块）' : '微信绑定暂未接通（依赖微信模块）',
        );
        return;
      }
      // 记录回访：保存后写入回访记录
      if (merchantApi.hasSession &&
          route == 'MemberVisit' &&
          to == 'MemberDetail' &&
          _hasConfirmLabel(child, '保存回访')) {
        unawaited(
          runBusy(
            'MemberVisit>MemberDetail',
            () => MemberFlow.saveVisit(context),
          ),
        );
        return;
      }
      // 次卡延期 / 退款：“取消”“再想想”只关闭弹层，确认后由云函数执行
      if (merchantApi.hasSession &&
          to == 'PackageDetail' &&
          route == 'sheet:PackageExtend') {
        if (_hasConfirmLabel(child, '取消')) {
          Navigator.of(context).maybePop();
        } else {
          unawaited(
            runBusy(
              'PackageExtend>PackageDetail',
              () => MemberFlow.extendPackage(context),
            ),
          );
        }
        return;
      }
      if (merchantApi.hasSession &&
          route == 'sheet:PackageRefund' &&
          (to == 'PackageDetail' || to == 'MemberDetail')) {
        if (to == 'PackageDetail' || _hasConfirmLabel(child, '再想想')) {
          Navigator.of(context).maybePop();
        } else {
          unawaited(
            runBusy(
              'PackageRefund>MemberDetail',
              () => MemberFlow.refundPackage(context),
            ),
          );
        }
        return;
      }
      // 筛选会员：“查看”应用条件并关闭面板，“取消”丢弃修改
      if (merchantApi.hasSession &&
          route == 'sheet:MemberFilter' &&
          to == 'Members') {
        if (_hasConfirmLabel(child, '取消')) {
          MemberFlow.filter.discard();
        } else {
          MemberFlow.filter.apply();
        }
        Navigator.of(context).maybePop();
        return;
      }
      // 调整卡种与积分：必须选原因，由云函数写流水
      if (merchantApi.hasSession &&
          route == 'MemberAdjust' &&
          _hasConfirmLabel(child, '确认调整')) {
        unawaited(
          runBusy(
            'MemberAdjust>MemberDetail',
            () => MemberFlow.adjust(context),
          ),
        );
        return;
      }
      // 购买次卡：由云函数算价格、次数、有效期，检查限购和余额
      if (merchantApi.hasSession &&
          route == 'Recharge' &&
          to == 'PackageSold') {
        unawaited(
          runBusy('Recharge>PackageSold', () => MemberFlow.sell(context)),
        );
        return;
      }
      // 储值充值：确认收款后由云函数入账、算赠送和自动升级
      if (merchantApi.hasSession &&
          route == 'Recharge' &&
          to == 'RechargeSuccess') {
        unawaited(
          runBusy(
            'Recharge>RechargeSuccess',
            () => MemberFlow.recharge(context),
          ),
        );
        return;
      }
      // 删除会员：确认后由云函数软删除，并回到会员列表
      if (merchantApi.hasSession &&
          route == 'sheet:MemberDelete' &&
          to == 'Members') {
        unawaited(
          runBusy('MemberDelete>Members', () async {
            final nav = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            try {
              await MemberFlow.deleteCurrent();
              nav.popUntil((r) => r.isFirst);
              AppToast.showOn(messenger, '已删除', kind: ToastKind.success);
            } catch (e) {
              AppToast.showOn(
                messenger,
                AppError.from(e).message,
                kind: ToastKind.error,
              );
            }
          }),
        );
        return;
      }
      if (merchantApi.hasSession &&
          to == 'MemberAddDone' &&
          route == 'MemberAdd' &&
          _hasSaveLabel(child)) {
        unawaited(
          runBusy('$route>MemberAddDone', () => MemberFlow.create(context)),
        );
        return;
      }
      if (merchantApi.hasSession &&
          route == 'MemberEdit' &&
          _hasSaveLabel(child)) {
        unawaited(runBusy('$route>$to', () => MemberFlow.update(context)));
        return;
      }
      if (merchantApi.hasSession &&
          route == 'VehicleAdd' &&
          _hasSaveLabel(child)) {
        unawaited(runBusy('$route>$to', () => MemberFlow.saveVehicle(context)));
        return;
      }
      if (merchantApi.hasSession &&
          to == 'CardPackages' &&
          route == 'PackageEdit' &&
          _hasSaveLabel(child)) {
        unawaited(
          runBusy(
            '$route>CardPackages',
            () => CatalogDraft.save(context, 'packages'),
          ),
        );
        return;
      }
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
  // 异步提交类按钮（保存 / 下一步 / 确认修改 …）：处理中显示 loading 并忽略点击
  if (busyKey != null && asyncActionKeys.contains(busyKey)) {
    return BusyOverlay(actionKey: busyKey, child: tap);
  }
  return tap;
}

bool _hasSaveLabel(Widget widget) => _hasConfirmLabel(widget, '保存');

/// 按钮里有没有这个文字（含加载中被 hBusy 包着的）。
bool _hasConfirmLabel(Widget widget, String label) {
  if (widget is Text) return widget.data == label;
  if (widget is Container && widget.child != null) {
    return _hasConfirmLabel(widget.child!, label);
  }
  if (widget is Align && widget.child != null) {
    return _hasConfirmLabel(widget.child!, label);
  }
  if (widget is Padding && widget.child != null) {
    return _hasConfirmLabel(widget.child!, label);
  }
  // 提交按钮里的文字被 hBusy（忙碌态）包了一层
  if (widget is ValueListenableBuilder<Set<String>> && widget.child != null) {
    return _hasConfirmLabel(widget.child!, label);
  }
  return false;
}

void hToast(BuildContext context, String msg) =>
    hToastOn(ScaffoldMessenger.of(context), msg);

/// 提示条（信息类，2s）。成功 / 失败请直接用 [AppToast]，失败提示停留更久。
void hToastOn(ScaffoldMessengerState messenger, String msg) =>
    AppToast.showOn(messenger, msg);

bool _confirming = false;

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
    final r = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: const Color(0x73000000),
      builder: (ctx) => StatefulBuilder(
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
                        child: GestureDetector(
                          onTap: busy
                              ? null
                              : () => Navigator.of(ctx).pop(false),
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
                          onTap: () async {
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
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: danger
                                  ? const Color(0xFFFF383C)
                                  : const Color(0xFF0485F7),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: busy
                                ? const AppSpinner(
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : Text(
                                    ok,
                                    style: hts(
                                      15,
                                      Colors.white,
                                      w: FontWeight.w600,
                                    ),
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
  final route = ModalRoute.of(context)?.settings.name;
  final kind = !merchantApi.hasSession
      ? null
      : switch (route) {
          'ServiceEdit' => 'services',
          'CardTierEdit' => 'cards',
          'PackageEdit' => 'packages',
          _ => null,
        };
  if (kind != null && !CatalogDraft.canRemove(kind)) {
    AppToast.show(context, '尚未保存，无需删除');
    return;
  }
  if (await hConfirm(
    context,
    '确认$label？',
    message: '该操作会立即生效，请再确认一次。',
    onConfirm: kind == null ? null : () => CatalogDraft.removeCurrent(kind),
  )) {
    if (!context.mounted) return;
    if (kind != null) {
      AppToast.showOn(
        messenger,
        kind == 'cards' ? '已停用' : '已删除',
        kind: ToastKind.success,
      );
      nav.maybePop();
      return;
    }
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
  bool _bound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bound) return;
    _bound = true;
    // 卡种编辑页唯一的开关是“预约优先排期”，值来自正在编辑的卡种
    final route = ModalRoute.of(context)?.settings.name;
    if (merchantApi.hasSession && route == 'CardTierEdit') {
      on = CatalogDraft.priorityBooking;
    }
    // 套餐编辑页两个开关：第一个“在会员小程序展示”，第二个“上架销售”
    if (merchantApi.hasSession && route == 'PackageEdit') {
      _slotKey = 'sw:PackageEdit';
      _slot = RegistrationDraft.claim(_slotKey, this);
      on = _slot == 0
          ? CatalogDraft.packageShowInMini
          : CatalogDraft.packageActive;
    }
  }

  String _slotKey = '';
  int _slot = 0;

  @override
  void dispose() {
    if (_slotKey.isNotEmpty) RegistrationDraft.release(_slotKey, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      final route = ModalRoute.of(context)?.settings.name;
      if (widget.onChanged != null) {
        // 受控模式：值由外部保存，成功与否由外部决定
        widget.onChanged!(!widget.value!);
        return;
      }
      if (merchantApi.hasSession && route == 'ServiceEdit') {
        hToast(context, '此设置暂未接通');
        return;
      }
      setState(() => on = !on);
      if (merchantApi.hasSession && route == 'CardTierEdit') {
        CatalogDraft.set('cards', 'priority_booking', on);
      }
      if (merchantApi.hasSession && route == 'PackageEdit') {
        CatalogDraft.set(
          'packages',
          _slot == 0 ? 'show_in_mini' : 'active',
          on,
        );
      }
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

  /// 注册页的“同意协议”勾选状态需要在点“下一步”时校验。
  void _report() {
    final route = ModalRoute.of(context)?.settings.name;
    if (route != null && RegistrationDraft.formRoutes.contains(route)) {
      RegistrationDraft.setChecked(route, on);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _report();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      setState(() => on = !on);
      _report();
    },
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

class HInput extends StatefulWidget {
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
  State<HInput> createState() => HInputState();
}

class HInputState extends State<HInput> {
  /// 密码框是否明文显示（由同一行里的“显示密码”小眼睛切换）。
  bool visible = false;

  /// 同一页里 hint 相同的输入框（如“6 位数字”出现两次）按出现顺序区分。
  int _slot = 0;
  String _route = '';
  bool _claimed = false;

  void toggleVisible() => setState(() => visible = !visible);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_claimed) return;
    _claimed = true;
    _route = ModalRoute.of(context)?.settings.name ?? '';
    if (RegistrationDraft.formRoutes.contains(_route)) {
      _slot = RegistrationDraft.claim('$_route:${widget.hint}', this);
      // 真实表单每次打开都从空白开始，不沿用设计稿里的示例文字。
      RegistrationDraft.reset(_route, widget.hint, _slot);
    }
  }

  @override
  void dispose() {
    if (_claimed) RegistrationDraft.release('$_route:${widget.hint}', this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.hint;
    final value = widget.value;
    final style = widget.style;
    final obscure = widget.obscure && !visible;
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final isForm = RegistrationDraft.formRoutes.contains(route);
    RegistrationDraft.remember(route, hint, value, _slot);
    // TODO: Member/booking rules are out of V1. Keep the designed controls
    // visible, but do not let them imply that their values were saved.
    final deferred =
        merchantApi.hasSession && route == 'ServiceEdit' && value == '8';
    final catalogField = switch ((route, value)) {
      ('ServiceEdit', '全车镀晶 · 9H 陶瓷') => ('services', 'name'),
      ('ServiceEdit', '1,580') => ('services', 'price'),
      ('CardTierEdit', '黑金卡') => ('cards', 'name'),
      ('CardTierEdit', '10,000') => ('cards', 'upgrade_recharge'),
      ('CardTierEdit', '30,000') => ('cards', 'upgrade_cumulative'),
      ('MemberAdd', '139 1688 5530') ||
      ('MemberAdd', '') when hint == '请输入手机号' => ('members', 'phone'),
      ('MemberEdit', '13812346021') => ('members', 'phone'),
      ('MemberAdd', '') when hint == '请输入客户姓名' => ('members', 'name'),
      ('MemberEdit', '王建国') => ('members', 'name'),
      ('MemberAdd', '') when hint == '如：车主偏好、车辆旧伤位置' => ('members', 'note'),
      ('MemberEdit', '喜欢下午到店，爱车偏好镀晶养护。') => ('members', 'note'),
      ('MemberEdit', '1985.06.12') => ('members', 'birthday'),
      ('VehicleAdd', '[17 位 VIN]') => ('vehicles', 'vin'),
      ('VehicleAdd', '18,600') => ('vehicles', 'mileage'),
      ('Recharge', '') when hint == '输入金额，不享赠送' => ('recharge', 'custom'),
      ('MemberAdjust', '') when hint == '补充说明，将记入操作记录' => ('adjust', 'note'),
      ('MemberVisit', '客户表示下周有空，想预约镀晶复养。') => ('visit', 'content'),
      ('PackageEdit', '精致洗车年卡') => ('packages', 'name'),
      ('PackageEdit', '1,080') => ('packages', 'price'),
      ('PackageEdit', '') when hint == '如：仅限精致洗车项目，节假日通用' => (
        'packages',
        'description',
      ),
      _ => null,
    };
    final initial = isForm
        ? ''
        : catalogField == null
        ? value
        : CatalogDraft.text(catalogField.$1, catalogField.$2, value);
    return TextFormField(
      onTapOutside: onTapOutsideDismiss,
      readOnly: deferred,
      onTap: deferred ? () => hToast(context, '此字段暂未接通') : null,
      onChanged: (text) {
        RegistrationDraft.set(route, hint, text, _slot);
        if (catalogField != null) {
          CatalogDraft.set(catalogField.$1, catalogField.$2, text);
          if (catalogField.$1 == 'recharge') MemberFlow.customAmountTyped(text);
        }
      },
      textInputAction: widget.obscure || widget.maxLines == 1
          ? TextInputAction.done
          : TextInputAction.newline,
      initialValue: initial,
      style: style,
      textAlign: widget.align,
      keyboardType: widget.keyboard,
      obscureText: obscure,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      minLines: 1,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: style.copyWith(
          color: widget.hintColor == const Color(0xFF71717A)
              ? dk(context, widget.hintColor, const Color(0xFF9A9AA3))
              : widget.hintColor,
        ),
      ),
    );
  }
}

/// 注销账号的“申请注销”：验证码填好并勾选后才是可点样式，否则是设计稿的置灰样式，
/// 置灰时点一下说明原因（不能只置灰）。
Widget hDeleteGate({required Widget on, required Widget off}) =>
    ValueListenableBuilder<int>(
      valueListenable: RegistrationDraft.changes,
      builder: (_, _, _) => RegistrationDraft.deleteError() == null ? on : off,
    );

/// 注销账号按钮置灰时点击给出的原因。
String hDeleteReason() => RegistrationDraft.deleteError() ?? '暂时无法申请注销';

/// 门店资料（登录后从后端读取）驱动的文字；未加载时由调用方给出设计稿的示例文字。
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

/// “忘记密码”流程状态驱动的文字（如“手机号 138 **** 1234 已验证通过”）。
Widget hFlowText(
  String Function(ForgotFlow f) text,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: forgotFlow,
  builder: (_, _) => Text(
    text(forgotFlow),
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

/// 密码框右侧的小眼睛：切换同一行里密码框的明文 / 密文。
/// 设计稿生成的页面里小眼睛和输入框是同一行的两个兄弟控件，
/// 这里沿着祖先找到包含密码框的那一行，直接切换它的状态。
class PasswordEye extends StatefulWidget {
  final Widget child;
  const PasswordEye({super.key, required this.child});
  @override
  State<PasswordEye> createState() => _PasswordEyeState();
}

class _PasswordEyeState extends State<PasswordEye> {
  bool shown = false;

  HInputState? _field() {
    HInputState? found;
    void visit(Element e) {
      if (found != null) return;
      if (e is StatefulElement) {
        final st = e.state;
        if (st is HInputState && st.widget.obscure) {
          found = st;
          return;
        }
      }
      e.visitChildren(visit);
    }

    context.visitAncestorElements((a) {
      a.visitChildren(visit);
      return found == null;
    });
    return found;
  }

  void _toggle() {
    final f = _field();
    if (f == null) return;
    f.toggleVisible();
    setState(() => shown = f.visible);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: shown ? '隐藏密码' : '显示密码',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      // 设计稿里默认是带斜线的眼睛（点击可显示）；明文显示时换成睁开的眼睛（点击可隐藏）
      child: shown
          ? SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: C.muted,
                ),
              ),
            )
          : widget.child,
    ),
  );
}

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
  bool _registered = false;
  String _slotKey = '';

  @override
  void dispose() {
    if (_slotKey.isNotEmpty) RegistrationDraft.release(_slotKey, this);
    super.dispose();
  }

  /// 卡种编辑页：第一组是卡面颜色，第二组是有效期；选中项来自正在编辑的卡种，
  /// 点选后写回草稿（卡面预览、保存都读草稿）。
  void _bindCardGroup() {
    _slotKey = 'sel:CardTierEdit';
    final slot = RegistrationDraft.claim(_slotKey, this);
    final ctrl = ctrls.first;
    if (slot == 0) {
      // 白色卡面（普通会员）不在 4 个色块里：一个都不选，保存时保持白色
      ctrl.selected.clear();
      if (CatalogDraft.colorIndex >= 0) {
        ctrl.selected.add(CatalogDraft.colorIndex);
      }
      ctrl.addListener(() {
        if (ctrl.selected.isNotEmpty) {
          CatalogDraft.set(
            'cards',
            'color',
            CatalogDraft.cardColors[ctrl.selected.first],
          );
        }
      });
    } else if (slot == 1) {
      ctrl.selected
        ..clear()
        ..add(CatalogDraft.validityIndex);
      ctrl.addListener(
        () => CatalogDraft.set(
          'cards',
          'validity',
          CatalogDraft.cardValidities[ctrl.selected.first],
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_registered) return;
    _registered = true;
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'CardTierEdit' &&
        widget.groups.length == 1) {
      _bindCardGroup();
      return;
    }
    // 记录回访：回访方式 / 回访结果
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'MemberVisit' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:MemberVisit';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      if (slot == 0) {
        ctrl.selected
          ..clear()
          ..add(0);
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set('visit', 'method_index', ctrl.selected.first);
        });
      } else {
        ctrl.selected.clear();
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set('visit', 'result_index', ctrl.selected.first);
        });
      }
      return;
    }
    // 回访提醒：页签（全部 / 次卡到期 / 养护到期 / 生日 / 沉睡）
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'MemberFollowUp' &&
        widget.groups.length == 1) {
      final ctrl = ctrls.first;
      ctrl.selected
        ..clear()
        ..add(MemberFlow.reminderTab.value);
      ctrl.addListener(() {
        if (ctrl.selected.isEmpty) return;
        MemberFlow.reminderTab.value = ctrl.selected.first;
      });
      return;
    }
    // 次卡延期：延长时间 / 延期原因
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'sheet:PackageExtend' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:PackageExtend';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      if (slot == 0) {
        ctrl.selected
          ..clear()
          ..add(0);
        ctrl.onSelect = (i) {
          if (i >= MemberFlow.extendDays.length) {
            // TODO: 自定义延期天数，预期接口：extend 的 days 参数已支持 1–3650，界面还没有输入入口。
            hToast(context, '自定义天数暂未接通，请选择 30 / 60 / 90 天');
          }
        };
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          final i = ctrl.selected.first;
          if (i >= MemberFlow.extendDays.length) {
            ctrl.selected
              ..clear()
              ..add(0);
            CatalogDraft.set('pkg_extend', 'days_index', 0);
            return;
          }
          CatalogDraft.set('pkg_extend', 'days_index', i);
        });
      } else {
        ctrl.selected.clear();
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'pkg_extend',
            'reason',
            MemberFlow.extendReasons[ctrl.selected.first],
          );
        });
      }
      return;
    }
    // 次卡退款：退回方式 / 退款原因
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'sheet:PackageRefund' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:PackageRefund';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      if (slot == 0) {
        ctrl.selected
          ..clear()
          ..add(0);
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set('pkg_refund', 'to_index', ctrl.selected.first);
        });
      } else {
        ctrl.selected.clear();
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'pkg_refund',
            'reason',
            MemberFlow.refundReasons[ctrl.selected.first],
          );
        });
      }
      return;
    }
    // 筛选会员：卡种（多选）/ 储值余额 / 最近到店 / 次卡状态 / 车辆与项目
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'sheet:MemberFilter' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:MemberFilter';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      final f = MemberFlow.filter;
      ctrl.selected.clear();
      if (slot == 0) {
        ctrl.selected.addAll(f.tierSel);
        ctrl.onSelect = (i) {
          if (i >= f.tiers.length) hToast(context, '本店没有这个卡种');
        };
        ctrl.addListener(() {
          f.tierSel = {...ctrl.selected}
            ..removeWhere((i) => i >= f.tiers.length);
          f.changed();
        });
      } else if (slot == 1) {
        ctrl.selected.add(f.balanceSel);
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          f.balanceSel = ctrl.selected.first;
          f.changed();
        });
      } else if (slot == 2) {
        if (f.visitSel >= 0) ctrl.selected.add(f.visitSel);
        ctrl.addListener(() {
          f.visitSel = ctrl.selected.isEmpty ? -1 : ctrl.selected.first;
          f.changed();
        });
      } else {
        // TODO: 次卡状态 / 车辆与项目依赖次卡和订单数据，预期接口：members list 的 filters 参数。
        var busy = false;
        ctrl.addListener(() {
          if (busy || ctrl.selected.isEmpty) return;
          busy = true;
          hToast(context, '次卡状态、车辆与项目筛选暂未接通');
          ctrl.clear();
          busy = false;
        });
      }
      return;
    }
    // 调整卡种与积分：三组选项依次是卡种 / 增加或扣减 / 调整原因
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'MemberAdjust' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:MemberAdjust';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      if (slot == 0) {
        void showCurrent() {
          final i =
              int.tryParse('${CatalogDraft.current?.fields['tier_index']}') ??
              -1;
          ctrl.selected
            ..clear()
            ..addAll(i >= 0 ? {i} : <int>{});
          ctrl.refresh();
        }

        showCurrent();
        // 卡种列表异步读取，读到后再回填当前卡种
        CatalogDraft.preview.addListener(showCurrent);
        ctrl.onSelect = (i) {
          if (i >= MemberFlow.tiers.length) {
            hToast(context, '这个卡种按钮在本店没有对应的卡种');
            return;
          }
          CatalogDraft.set('adjust', 'tier_index', i);
        };
      } else if (slot == 1) {
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'adjust',
            'dir',
            ctrl.selected.first == 0 ? 'add' : 'sub',
          );
        });
      } else {
        ctrl.selected.clear();
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'adjust',
            'reason',
            MemberFlow.adjustReasons[ctrl.selected.first],
          );
        });
      }
      return;
    }
    // 充值页：第一组是金额档位，第二组是收款方式
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'Recharge' &&
        widget.groups.length == 1) {
      _slotKey = 'sel:Recharge';
      final slot = RegistrationDraft.claim(_slotKey, this);
      final ctrl = ctrls.first;
      if (slot == 0) {
        final i =
            int.tryParse('${CatalogDraft.current?.fields['preset']}') ?? 1;
        ctrl.selected
          ..clear()
          ..add(i);
        MemberFlow.clearPresetSelection = ctrl.clear;
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set('recharge', 'preset', ctrl.selected.first);
          CatalogDraft.set('recharge', 'mode', 'preset');
        });
      } else if (slot == 2) {
        // 购买次卡页签的收款方式（含“储值余额”）
        final i = MemberFlow.saleMethods.indexOf(MemberFlow.saleMethod);
        ctrl.selected
          ..clear()
          ..add(i < 0 ? 0 : i);
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'recharge',
            'sale_method',
            MemberFlow.saleMethods[ctrl.selected.first],
          );
        });
      } else {
        final i = MemberFlow.payMethods.indexOf(
          CatalogDraft.text('recharge', 'method', MemberFlow.payMethods.first),
        );
        ctrl.selected
          ..clear()
          ..add(i < 0 ? 0 : i);
        ctrl.addListener(() {
          if (ctrl.selected.isEmpty) return;
          CatalogDraft.set(
            'recharge',
            'method',
            MemberFlow.payMethods[ctrl.selected.first],
          );
        });
      }
      return;
    }
    // 编辑会员资料：唯一一组选项是称呼（先生 / 女士）
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'MemberEdit' &&
        widget.groups.length == 1) {
      final ctrl = ctrls.first;
      final i = MemberFlow.honorifics.indexOf(
        CatalogDraft.text('members', 'honorific', ''),
      );
      ctrl.selected.clear();
      if (i >= 0) ctrl.selected.add(i);
      ctrl.addListener(() {
        if (ctrl.selected.isEmpty) return;
        CatalogDraft.set(
          'members',
          'honorific',
          MemberFlow.honorifics[ctrl.selected.first],
        );
      });
      return;
    }
    // 套餐编辑页：唯一一组选项是有效期
    if (merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'PackageEdit' &&
        widget.groups.length == 1) {
      final ctrl = ctrls.first;
      ctrl.selected
        ..clear()
        ..add(CatalogDraft.packageValidityIndex);
      ctrl.addListener(() {
        if (ctrl.selected.isEmpty) return;
        CatalogDraft.set(
          'packages',
          'validity_months',
          CatalogDraft.packageValidities[ctrl.selected.first],
        );
      });
      return;
    }
    // 注册第二页的三组选项（身份 / 工位数量 / 主营业务）：让提交时能读到选中项。
    // 三组都是单组 holder，靠“多选 / 初始选中项”区分：多选 = 主营业务，
    // 初始 {0} = 身份，初始 {1} = 工位数量。
    if (ModalRoute.of(context)?.settings.name == 'RegShop' &&
        widget.groups.length == 1) {
      final (initial, multi) = widget.groups.first;
      final sel = ctrls.first.selected;
      if (multi) {
        RegistrationDraft.businessSel = sel;
      } else if (initial.length == 1 && initial.first == 0) {
        RegistrationDraft.roleSel = sel;
      } else if (initial.length == 1 && initial.first == 1) {
        RegistrationDraft.baySel = sel;
      }
    }
  }

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
  late final List<ValCtrl> ctrls;
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final cardDiscount =
        ModalRoute.of(context)?.settings.name == 'CardTierEdit' &&
        widget.inits.length == 1 &&
        widget.inits.first == 90;
    final initial = cardDiscount
        ? ((num.tryParse(CatalogDraft.text('cards', 'discount', '0.9')) ??
                      0.9) *
                  100)
              .round()
        : null;
    final adjustPoints =
        merchantApi.hasSession &&
        ModalRoute.of(context)?.settings.name == 'MemberAdjust' &&
        widget.inits.length == 1;
    ctrls = [
      for (final i in widget.inits) ValCtrl(adjustPoints ? 0 : (initial ?? i)),
    ];
    if (adjustPoints) {
      ctrls[0].addListener(
        () => CatalogDraft.set('adjust', 'points', ctrls[0].v),
      );
    }
    if (cardDiscount) {
      CatalogDraft.set('cards', 'discount', ctrls[0].v / 100);
      ctrls[0].addListener(
        () => CatalogDraft.set('cards', 'discount', ctrls[0].v / 100),
      );
    }
    initialized = true;
  }

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
