import '../kit/buttons.dart';
import '../kit/kit.dart';

import 'package:flutter/material.dart';

import '../kit/sheet_route.dart';

import '../theme.dart';
import 'app_icon.dart';

/// 白色圆角卡片
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final bool shadow;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.color,
    this.onTap,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? C.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? softShadow : null,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final double size;
  const Pill(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    this.size = 12,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: ts(size, w: FontWeight.w500, color: fg, h: 16),
    ),
  );
}

/// 会员等级徽标
class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge(this.level, {super.key});
  @override
  Widget build(BuildContext context) {
    switch (level) {
      case '黑金':
        return Pill(level, bg: C.ink, fg: C.gold, size: 11);
      case '金卡':
        return Pill(level, bg: C.amberSoft, fg: C.amberInk, size: 11);
      case '银卡':
        return Pill(level, bg: C.chip, fg: C.sub, size: 11);
      default:
        return Pill(level, bg: C.chip, fg: C.muted, size: 11);
    }
  }
}

/// 蓝底白字车牌
class PlateTag extends StatelessWidget {
  final String text;
  final bool green;
  const PlateTag(this.text, {super.key, this.green = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: green ? const Color(0xFFD7F5E1) : C.plate,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: green ? const Color(0xFF86D9A4) : const Color(0xFF5B9BF0),
        width: 1.5,
      ),
    ),
    child: Text(
      text,
      style: ts(
        13,
        w: FontWeight.w600,
        color: green ? const Color(0xFF14532D) : Colors.white,
        spacing: 0.5,
        h: 18,
      ),
    ),
  );
}

class Avatar extends StatelessWidget {
  final String text;
  final double size;
  final Color? bg;
  final Color fg;
  const Avatar(
    this.text, {
    super.key,
    this.size = 44,
    this.bg,
    this.fg = C.gold,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg ?? C.pill, shape: BoxShape.circle),
    child: Text(
      text,
      style: ts(size * 0.36, w: FontWeight.w600, color: fg),
    ),
  );
}

/// 白色圆形图标按钮（44）
class RoundBtn extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool dot;
  final AppIconButtonKind kind;
  const RoundBtn(
    this.icon, {
    super.key,
    required this.label,
    this.onTap,
    this.dot = false,
    this.kind = AppIconButtonKind.surface,
  });
  @override
  Widget build(BuildContext context) => AppIconButton(
    svg: AppIcon.svg(icon),
    semanticLabel: label,
    kind: kind,
    onPressed: onTap,
  );
}

/// 二级页面顶部栏
class SubHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  /// 表单卡片：左上角是 ✕ 而不是返回箭头
  final bool close;
  const SubHeader(this.title, {super.key, this.trailing, this.close = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Row(
      children: [
        RoundBtn(
          close ? 'close' : 'chevronLeft',
          label: close ? '取消' : '返回',
          onTap: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: ts(17, w: FontWeight.w600, h: 24),
          ),
        ),
        SizedBox(width: 44, child: trailing),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? sub, action;
  final VoidCallback? onAction;
  const SectionTitle(
    this.title, {
    super.key,
    this.sub,
    this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: ts(17, w: FontWeight.w600, h: 24),
              ),
              if (sub != null)
                TextSpan(
                  text: ' · $sub',
                  style: ts(17, w: FontWeight.w500, color: C.muted, h: 24),
                ),
            ],
          ),
        ),
      ),
      if (action != null)
        AppButton(
          label: action!,
          kind: AppButtonKind.text,
          size: AppButtonSize.medium,
          onPressed: onAction,
        ),
    ],
  );
}

/// 深色选中的胶囊筛选
class ChipTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const ChipTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 32,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: labels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final on = i == selected;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: on ? C.btn : (C.dark ? C.chip : C.card),
              borderRadius: BorderRadius.circular(16),
              boxShadow: on || C.dark ? null : softShadow,
            ),
            child: Text(
              labels[i],
              style: ts(
                13,
                w: FontWeight.w500,
                color: on ? C.btnFg : C.sub,
                h: 18,
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// 灰底分段控件
class Segmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const Segmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: C.segment,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected
                      ? (C.dark ? C.stroke : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: i == selected ? softShadow : null,
                ),
                child: Text(
                  labels[i],
                  style: ts(
                    13,
                    w: FontWeight.w500,
                    color: i == selected ? C.ink : C.sub,
                    h: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// 圆环装饰（深色卡片背景）
/// 卡片背景的同心圆装饰。和设计稿的 SVG 一致：[viewBox] 是 SVG 的画布边长，[radii] 是各圈半径（画布单位），
/// 描边宽度 1.5（画布单位，随 [size] / [viewBox] 缩放）。[colors] 给每一圈单独指定颜色；[dot] 是画布里的一个实心小圆点。
///
/// 放进卡片时要注意：卡片有内边距时，Stack 里的 Positioned 是相对内边距之内的区域，
/// 设计稿的 right / top 要减去内边距；Stack 本身要 `clipBehavior: Clip.none`（由卡片外层的 Container 裁圆角），
/// 否则圈会被内边距处截断。
class Rings extends StatelessWidget {
  final double size;
  final Color color;
  final List<Color>? colors;
  final double viewBox;
  final List<double> radii;
  final (Offset, double, Color)? dot;
  const Rings({
    super.key,
    this.size = 220,
    this.color = C.dark2,
    this.colors,
    this.viewBox = 220,
    this.radii = const [60, 85, 108],
    this.dot,
  });
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      size: Size(size, size),
      painter: _RingsPainter(color, colors, viewBox, radii, dot),
    ),
  );
}

class _RingsPainter extends CustomPainter {
  final Color color;
  final List<Color>? colors;
  final double viewBox;
  final List<double> radii;
  final (Offset, double, Color)? dot;
  _RingsPainter(this.color, this.colors, this.viewBox, this.radii, this.dot);
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / viewBox;
    final c = size.center(Offset.zero);
    for (var i = 0; i < radii.length; i++) {
      final p = Paint()
        ..color = colors != null && i < colors!.length ? colors![i] : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * k;
      canvas.drawCircle(c, radii[i] * k, p);
    }
    if (dot != null) {
      canvas.drawCircle(dot!.$1 * k, dot!.$2 * k, Paint()..color = dot!.$3);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.color != color ||
      old.viewBox != viewBox ||
      old.radii != radii ||
      old.colors != colors;
}

class Divider1 extends StatelessWidget {
  final double indent;
  const Divider1({super.key, this.indent = 0});
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: EdgeInsets.only(left: indent),
    color: C.line,
  );
}

/// 压入页面，并按页面类型给路由命名，这样 openRoute('MemberDetail') 之类的跳转
/// 能回到已打开的页面，而不是再新开一个。
void push(BuildContext context, Widget page) {
  final name = switch (page.runtimeType.toString()) {
    'MemberDetailPage' => 'MemberDetail',
    'OrderPage' => 'Order',
    'AppointmentAddPage' => 'AppointmentAdd',
    'AppointmentsPage' => 'Appointments',
    _ => null,
  };
  final settings = name == null ? null : RouteSettings(name: name);
  Navigator.of(context).push(
    name == 'AppointmentAdd'
        ? appSheetRoute<void>(settings: settings, page: page)
        : MaterialPageRoute(settings: settings, builder: (_) => page),
  );
}

void toast(BuildContext context, String msg) => hToast(context, msg);

/// 暂未实现的页面占位
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          SubHeader(title),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded, size: 40, color: C.faint),
                  const SizedBox(height: 12),
                  Text('该页面稍后实现', style: ts(15, color: C.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
