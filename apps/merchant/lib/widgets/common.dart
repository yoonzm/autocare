import '../kit/kit.dart';

import 'package:flutter/material.dart';

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
  const RoundBtn(
    this.icon, {
    super.key,
    required this.label,
    this.onTap,
    this.dot = false,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: C.card,
          shape: BoxShape.circle,
          boxShadow: softShadow,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppIcon(icon, size: 20, color: C.ink),
            if (dot)
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: C.red,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: C.card, spreadRadius: 2)],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
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
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
          ),
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

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color bg, fg;
  final EdgeInsetsGeometry padding;
  const PrimaryButton(
    this.text, {
    super.key,
    this.onTap,
    this.bg = C.primary,
    this.fg = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onTap == null ? C.faint : bg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: ts(16, w: FontWeight.w600, color: fg, h: 24),
      ),
    ),
  );
}

/// 圆环装饰（深色卡片背景）
class Rings extends StatelessWidget {
  final double size;
  final Color color;
  const Rings({super.key, this.size = 220, this.color = C.dark2});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(size: Size(size, size), painter: _RingsPainter(color)),
  );
}

class _RingsPainter extends CustomPainter {
  final Color color;
  _RingsPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final c = size.center(Offset.zero);
    for (final f in [0.27, 0.39, 0.49]) {
      canvas.drawCircle(c, size.width * f, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.color != color;
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
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: name == null ? null : RouteSettings(name: name),
      builder: (_) => page,
    ),
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
