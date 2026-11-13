import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/money_format.dart';
import '../../backend/data_snapshot.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

class _RangeData {
  String get memberShare => '—';
  final String title, total, delta, from, to, cur, prev, orders;
  const _RangeData({
    required this.title,
    this.total = '—',
    this.delta = '—',
    this.from = '—',
    this.to = '—',
    required this.cur,
    this.prev = '—',
    this.orders = '—',
  });
}

const _periodNames = ['今日', '本周', '本月', '本期'];
// TODO: 现有home_stats只有今日汇总。周/月/自定义、分时趋势、收入构成、会员占比没有接口。
// 保留设计好的卡片与筛选，缺失值显示—，不根据示例比例或七日趋势推算不同统计口径。
const _compositionNames = ['镀晶 / 镀膜', '车衣 / 改色膜', '洗车美容', '内饰清洁及其他'];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int range = 2;
  Map<String, dynamic>? _today;
  _RangeData get r {
    final period = _periodNames[range];
    final data = _today;
    if (range != 0 || data == null) {
      return _RangeData(title: '$period营业额（元）', cur: period);
    }
    final change = data['change_percent'];
    final date = DateTime.tryParse('${data['date']}');
    final label = date == null ? '—' : '${date.month}.${date.day}';
    return _RangeData(
      title: '今日营业额（元）',
      cur: '今日',
      prev: '上周同日',
      total: data['revenue'] is num ? money(data['revenue'], digits: 2) : '—',
      orders: data['orders'] is num ? '${data['orders']}' : '—',
      delta: change is num
          ? '较上周同日 ${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%'
          : '—',
      from: label,
      to: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return Scaffold(
      body: AsyncView<Map<String, dynamic>>(
        load: () async => dataSnapshot(await merchantApi.homeStats()),
        isEmpty: (_) => false,
        skeleton: const Column(
          children: [
            SkeletonDashboardCard(height: 230, radius: 24),
            SizedBox(height: 16),
            SkeletonList(count: 4),
          ],
        ),
        empty: (_) => const SizedBox.shrink(),
        onNext: () => openRoute(context, 'Login'),
        onLoaded: (data) => _today = data,
        builder: (_, data) => _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) => ListView(
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
          _pill('开支', 'card', onTap: () => openRoute(context, 'Expenses')),
        ],
      ),
      const SizedBox(height: 16),
      Segmented(
        labels: const ['今日', '本周', '本月', '自定义'],
        selected: range,
        onChanged: (i) {
          setState(() => range = i);
          if (i != 0) {
            AppToast.show(
              context,
              'TODO：${['今日', '周度', '月度', '自定义'][i]}统计接口尚未接通',
            );
          }
        },
      ),
      const SizedBox(height: 16),
      _chartCard(context),
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
  );

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

  Widget _chartCard(BuildContext context) => AppCard(
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
                  const SizedBox(width: 14, height: 14),
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
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              Center(
                child: Text(
                  range == 0 ? 'TODO：分时趋势接口尚未接通' : 'TODO：该时段统计接口尚未接通',
                  style: ts(12, color: C.muted, h: 18),
                ),
              ),
            ],
          ),
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
        const SizedBox(height: 14),
        // 订单中心入口（设计稿 Stats：营业额卡片底部“全部订单与收款”）
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openRoute(context, 'OrderList'),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: C.inset,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '全部订单与收款',
                    style: ts(14, w: FontWeight.w500, h: 20),
                  ),
                ),
                AppIcon('chevronRight', size: 16, color: C.faint),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _composition() {
    final colors = [C.ink, C.primary, const Color(0xFF7CC4FB), C.stroke];
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('项目收入构成', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          for (var i = 0; i < _compositionNames.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    _compositionNames[i],
                    style: ts(13, w: FontWeight.w500, h: 18),
                  ),
                ),
                Text('—', style: ts(13, color: C.muted, h: 18)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 76,
                  child: Text(
                    '—',
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
                widthFactor: 0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            if (i < _compositionNames.length - 1) const SizedBox(height: 12),
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

/// 保留图表网格，不绘制没有真实数据来源的曲线。
class _GridPainter extends CustomPainter {
  final Color gridColor = C.line;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset(0, size.height * f),
        Offset(size.width, size.height * f),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.gridColor != gridColor;
}
