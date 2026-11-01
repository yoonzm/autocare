import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class _RangeData {
  final String title, total, delta, from, to, cur, prev, orders, memberShare;
  final int totalNum;
  final List<double> now, before;
  const _RangeData({
    required this.title,
    required this.total,
    required this.totalNum,
    required this.delta,
    required this.now,
    required this.before,
    required this.from,
    required this.to,
    required this.cur,
    required this.prev,
    required this.orders,
    required this.memberShare,
  });
}

final _ranges = <_RangeData>[
  const _RangeData(
    title: '今日营业额（元）',
    total: '12,860',
    totalNum: 12860,
    delta: '较上周六 +18.4%',
    now: [0.4, 0.9, 1.6, 2.1, 1.4, 1.1, 1.9, 2.4, 1.7, 1.2, 0.8],
    before: [0.5, 0.7, 1.2, 1.8, 1.5, 0.9, 1.4, 1.9, 1.5, 1.0, 0.6],
    from: '08:00',
    to: '20:00',
    cur: '今日',
    prev: '上周六',
    orders: '36',
    memberShare: '68%',
  ),
  const _RangeData(
    title: '本周营业额（元）',
    total: '71,280',
    totalNum: 71280,
    delta: '较上周 +9.2%',
    now: [9.2, 10.4, 8.8, 11.6, 12.3, 14.1, 12.9],
    before: [8.6, 9.8, 9.1, 10.2, 11.4, 12.9, 11.5],
    from: '周一',
    to: '周日',
    cur: '本周',
    prev: '上周',
    orders: '198',
    memberShare: '70%',
  ),
  _RangeData(
    title: '10 月营业额（元）',
    total: '328,460',
    totalNum: 328460,
    delta: '环比 +12.6%',
    now: [32, 46, 40, 62, 54, 70, 58, 80, 74, 90, 84],
    before: [26, 34, 30, 44, 40, 52, 44, 60, 54, 66, 62],
    from: '10.01',
    to: '10.31',
    cur: '本月',
    prev: '上月',
    orders: '912',
    memberShare: '71%',
  ),
  const _RangeData(
    title: '10.01 – 10.15 营业额（元）',
    total: '158,920',
    totalNum: 158920,
    delta: '较上期 +6.3%',
    now: [7.2, 8.1, 6.4, 9.8, 10.5, 12.9, 8.6, 9.2, 10.1, 11.4, 9.7],
    before: [6.8, 7.5, 6.9, 9.0, 9.9, 11.8, 8.9, 8.7, 9.6, 10.4, 9.5],
    from: '10.01',
    to: '10.15',
    cur: '本期',
    prev: '上期',
    orders: '441',
    memberShare: '69%',
  ),
];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int range = 2;
  _RangeData get r => _ranges[range];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 12,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '营业统计',
                  style: ts(28, w: FontWeight.w600, h: 36, spacing: -0.7),
                ),
              ),
              _pill(
                '开支',
                'card',
                dark: true,
                onTap: () => openRoute(context, 'Expenses'),
              ),
              const SizedBox(width: 8),
              _pill(
                '导出',
                'download',
                onTap: () => openRoute(context, 'ExportSheet'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Segmented(
            labels: const ['今日', '本周', '本月', '自定义'],
            selected: range,
            onChanged: (i) => setState(() => range = i),
          ),
          const SizedBox(height: 16),
          _chartCard(),
          const SizedBox(height: 16),
          _composition(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _mini('施工台次', r.orders, 'car2', C.amberSoft, C.amberInk),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _mini(
                  '会员消费占比',
                  r.memberShare,
                  'card',
                  C.greenSoft,
                  C.greenInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(
    String t,
    String icon, {
    bool dark = false,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: dark ? C.heroCard : C.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          AppIcon(
            icon,
            size: 18,
            color: dark ? (C.dark ? C.gold : Colors.white) : C.ink,
          ),
          const SizedBox(width: 6),
          Text(
            t,
            style: ts(
              14,
              w: FontWeight.w500,
              color: dark ? Colors.white : C.ink,
              h: 20,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chartCard() => AppCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: ts(12, color: C.muted, h: 16)),
                  const SizedBox(height: 2),
                  Text(
                    r.total,
                    style: ts(
                      30,
                      w: FontWeight.w600,
                      h: 36,
                      spacing: -0.9,
                      tabular: true,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 22,
              decoration: BoxDecoration(
                color: C.greenSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon('trendUp', size: 14, color: C.greenInk, stroke: 2.2),
                  const SizedBox(width: 4),
                  Text(
                    r.delta,
                    style: ts(12, w: FontWeight.w500, color: C.greenInk, h: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: CustomPaint(painter: _LinePainter(r.now, r.before)),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(r.from, style: ts(11, color: C.muted, h: 14)),
            ),
            Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                color: C.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 5),
            Text(r.cur, style: ts(11, color: C.muted, h: 14)),
            const SizedBox(width: 16),
            SizedBox(
              width: 12,
              height: 3,
              child: CustomPaint(painter: _DashPainter()),
            ),
            const SizedBox(width: 5),
            Text(r.prev, style: ts(11, color: C.muted, h: 14)),
            const SizedBox(width: 16),
            Text(r.to, style: ts(11, color: C.muted, h: 14)),
          ],
        ),
      ],
    ),
  );

  Widget _composition() {
    final colors = [C.ink, C.primary, const Color(0xFF7CC4FB), C.stroke];
    final maxP = revenueShares
        .map((e) => e.percent)
        .reduce((a, b) => a > b ? a : b);
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('项目收入构成', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          for (var i = 0; i < revenueShares.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    revenueShares[i].name,
                    style: ts(13, w: FontWeight.w500, h: 18),
                  ),
                ),
                Text(
                  '${revenueShares[i].percent}%',
                  style: ts(13, color: C.muted, h: 18),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 76,
                  child: Text(
                    '¥${money(range == 2 ? revenueShares[i].amount : r.totalNum * revenueShares[i].percent ~/ 100)}',
                    textAlign: TextAlign.right,
                    style: ts(13, w: FontWeight.w600, h: 18, tabular: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: C.chip,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: revenueShares[i].percent / maxP,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            if (i < revenueShares.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _mini(String label, String value, String icon, Color bg, Color fg) =>
      AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: AppIcon(icon, size: 18, color: fg)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ts(12, color: C.muted, h: 16)),
                  Text(
                    value,
                    style: ts(18, w: FontWeight.w600, h: 24, tabular: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.faint
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.height / 2), Offset(4, size.height / 2), p);
    canvas.drawLine(Offset(8, size.height / 2), Offset(12, size.height / 2), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 营业额折线：本期实线 + 面积，上期虚线，终点空心圆。
class _LinePainter extends CustomPainter {
  final List<double> now, before;
  _LinePainter(this.now, this.before);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final grid = Paint()
      ..color = C.line
      ..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, h * f), Offset(w, h * f), grid);
    }
    final maxV = [...now, ...before].reduce((a, b) => a > b ? a : b);
    // 与设计稿一致：最高点约为画布高度的 82%，终点内缩 8px
    Offset pt(List<double> v, int i) =>
        Offset((w - 8) * i / (v.length - 1), h - (v[i] / maxV) * 90);
    Path line(List<double> v) {
      final p = Path()..moveTo(pt(v, 0).dx, pt(v, 0).dy);
      for (var i = 1; i < v.length; i++) {
        p.lineTo(pt(v, i).dx, pt(v, i).dy);
      }
      return p;
    }

    // 上期（虚线）
    final dashPaint = Paint()
      ..color = C.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final m in line(before).computeMetrics()) {
      for (double d = 0; d < m.length; d += 8) {
        canvas.drawPath(
          m.extractPath(d, (d + 4).clamp(0, m.length)),
          dashPaint,
        );
      }
    }
    // 本期面积 + 折线
    final area = line(now)
      ..lineTo(pt(now, now.length - 1).dx, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(area, Paint()..color = C.primary.withValues(alpha: 0.08));
    canvas.drawPath(
      line(now),
      Paint()
        ..color = C.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final end = pt(now, now.length - 1);
    canvas.drawCircle(end, 5, Paint()..color = C.card);
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = C.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.now != now || old.before != before;
}
