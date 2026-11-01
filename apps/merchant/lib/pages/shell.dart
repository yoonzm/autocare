import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'members_page.dart';
import '../mock/app_state.dart';
import '../routes.dart';
import 'gen/plan_expired_page.dart';
import 'order_page.dart';
import 'stats_page.dart';

/// 全局切换底部 Tab 的入口（首页快捷入口使用）
final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  @override
  void initState() {
    super.initState();
    shellMounted = true;
  }

  @override
  void dispose() {
    shellMounted = false;
    super.dispose();
  }

  static const _pages = <Widget>[
    HomePage(),
    MembersPage(),
    InventoryPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SubState>(
      valueListenable: subState,
      builder: (context, st, _) => st == SubState.expired
          ? const PopScope(canPop: false, child: PlanExpiredPage())
          : _tabs(context),
    );
  }

  Widget _tabs(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, idx, _) => Scaffold(
        // 底栏上方探出的 24px 是透明区域，内容要能从它后面透出来
        extendBody: true,
        body: IndexedStack(index: idx, children: _pages),
        bottomNavigationBar: _BottomBar(
          index: idx,
          onTab: (i) => tabIndex.value = i,
          onOrder: () => push(context, const OrderPage()),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onOrder;
  const _BottomBar({
    required this.index,
    required this.onTab,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    // 设计稿：84px 的凹槽底栏（含 34px 安全区），开单按钮探出 24px
    final double barH = 60 + (bottom > 18 ? bottom - 10 : 8);
    return SizedBox(
      height: barH + 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barH,
            child: CustomPaint(painter: _NotchBarPainter(C.card, C.dark)),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 0,
            height: barH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _item(0, 'home', '首页'),
                _item(1, 'users', '会员'),
                const Spacer(),
                _item(2, 'box', '库存'),
                _item(3, 'chart', '统计'),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onOrder,
                child: Semantics(
                  label: '开单收银',
                  button: true,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4DB0FF),
                          Color(0xFF0485F7),
                          Color(0xFF0568D8),
                        ],
                        stops: [0, 0.55, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x8C0485F7),
                          blurRadius: 26,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Color(0x590485F7),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const AppIcon('add', color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int i, String icon, String label) {
    final sel = index == i;
    final color = sel ? C.primary : C.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTab(i),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon,
                size: 24,
                color: color,
                fill: sel && i == 0 ? color : null,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: ts(
                  11,
                  w: sel ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  h: 14,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: sel ? C.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 中间带圆形凹槽的底栏背景（与设计稿 clip-path 一致）。
class _NotchBarPainter extends CustomPainter {
  final Color color;
  final bool dark;
  _NotchBarPainter(this.color, this.dark);

  Path _path(Size size) {
    final cx = size.width / 2;
    final h = size.height;
    // 设计稿以 390 宽为基准，凹槽以屏幕中线对称
    final l = cx - 195;
    return Path()
      ..moveTo(0, h)
      ..lineTo(0, 28)
      ..arcToPoint(const Offset(28, 0), radius: const Radius.circular(28))
      ..lineTo(l + 128, 0)
      ..cubicTo(l + 150, 0, l + 155.86, 13.35, l + 167.43, 27.14)
      ..arcToPoint(
        Offset(l + 222.57, 27.14),
        radius: const Radius.circular(36),
        clockwise: false,
      )
      ..cubicTo(l + 234.14, 13.35, l + 240, 0, l + 262, 0)
      ..lineTo(size.width - 28, 0)
      ..arcToPoint(Offset(size.width, 28), radius: const Radius.circular(28))
      ..lineTo(size.width, h)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.drawPath(
      path.shift(const Offset(0, -4)),
      Paint()
        ..color = const Color(0x0F000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    if (dark) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF26262B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NotchBarPainter old) =>
      old.color != color || old.dark != dark;
}
