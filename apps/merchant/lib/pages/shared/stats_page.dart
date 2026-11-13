import '../../kit/buttons.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/money_format.dart';
import '../../backend/data_snapshot.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

/// 一个统计时段在页面上的展示文字；数值全部来自服务端 `business_stats`。
class _RangeData {
  final String title, total, delta, from, to, cur, prev, orders, memberShare;
  final List<double?> current, previous;
  final List<({String name, String percent, String amount, double ratio})>
  parts;
  const _RangeData({
    required this.title,
    this.total = '—',
    this.delta = '—',
    this.from = '—',
    this.to = '—',
    required this.cur,
    this.prev = '—',
    this.orders = '—',
    this.memberShare = '—',
    this.current = const [],
    this.previous = const [],
    this.parts = const [],
  });
}

const _ranges = ['today', 'week', 'month', 'custom'];
const _periodNames = ['今日', '本周', '本月', '本期'];
const _prevNames = ['上周同日', '上周', '上月', '上一期'];
const _deltaNames = ['较上周同日', '较上周同期', '较上月同期', '较上一期'];
const _compositionKeys = ['coating', 'wrap', 'wash', 'other'];
const _compositionNames = ['镀晶 / 镀膜', '车衣 / 改色膜', '洗车美容', '内饰清洁及其他'];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _view = GlobalKey<AsyncViewState<Map<String, dynamic>>>();

  /// 选中的页签。
  int range = 2;

  /// 最近一次请求的时段。读取失败后仍保留，页面顶部 Toast 的“重试”才会重试它。
  int _target = 2;
  DateTimeRange? _targetCustom;

  /// 当前显示的数据及其对应的时段；新时段的数据到来前，页面仍显示这一份。
  Map<String, dynamic>? _data;
  int? _loadedRange;
  DateTimeRange? _loadedCustom;
  int _inflightRange = 2;
  DateTimeRange? _inflightCustom;
  String? _failed;

  String _key(int range, DateTimeRange? custom) =>
      range == 3 ? '3|${custom?.start}|${custom?.end}' : '$range';

  Future<Map<String, dynamic>> _load() async {
    _inflightRange = _target;
    _inflightCustom = _target == 3 ? _targetCustom : null;
    final key = _key(_inflightRange, _inflightCustom);
    try {
      return dataSnapshot(
        await merchantApi.businessStats(
          _ranges[_inflightRange],
          from: _inflightCustom?.start,
          to: _inflightCustom?.end,
        ),
      );
    } catch (_) {
      _failed = key;
      rethrow;
    }
  }

  void _loaded(Map<String, dynamic> data) {
    _data = data;
    _loadedRange = _inflightRange;
    _loadedCustom = _inflightCustom;
    _failed = null;
  }

  /// 请求结束后：加载期间又换了时段则补发；目标时段读取失败则页签退回仍在显示的时段。
  void _settled() {
    if (!mounted || _data == null) return;
    final wanted = _key(_target, _targetCustom);
    if (wanted == _key(_loadedRange!, _loadedCustom)) {
      if (range != _loadedRange) setState(() => range = _loadedRange!);
    } else if (_failed == wanted) {
      setState(() => range = _loadedRange!);
    } else {
      _view.currentState?.reload();
    }
  }

  Future<void> _select(int i) async {
    DateTimeRange? custom;
    if (i == 3) {
      final now = DateTime.now();
      custom = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
        initialDateRange: _targetCustom ?? _loadedCustom,
        helpText: '选择统计日期',
        saveText: '确定',
      );
      if (custom == null || !mounted) return;
    }
    setState(() {
      range = i;
      _target = i;
      _targetCustom = custom;
    });
    // 目标时段就是正在显示的数据（如失败后点回原页签），不必再请求。
    final data = _data;
    if (data != null && _key(i, custom) == _key(_loadedRange!, _loadedCustom)) {
      return;
    }
    _view.currentState?.reload();
  }

  static num? _num(Object? v) => v is num ? v : null;

  static String _md(Object? iso) {
    final date = DateTime.tryParse('$iso');
    return date == null ? '—' : '${date.month}.${date.day}';
  }

  _RangeData get r {
    final data = _data;
    if (data == null) {
      return _RangeData(
        title: '${_periodNames[range]}营业额（元）',
        cur: _periodNames[range],
      );
    }
    final i = math.max(0, _ranges.indexOf('${data['range']}'));
    final revenue = _num(data['revenue']);
    final change = _num(data['change_percent']);
    final share = _num(data['member_share']);
    List<double?> series(Object? v) => [
      for (final e in (v is List ? v : const []))
        e is num ? e.toDouble() : null,
    ];
    final comp = {
      for (final c
          in (data['composition'] is List
              ? data['composition'] as List
              : const []))
        if (c is Map) '${c['key']}': c,
    };
    return _RangeData(
      title: '${_periodNames[i]}营业额（元）',
      cur: _periodNames[i],
      prev: _prevNames[i],
      total: revenue == null ? '—' : money(revenue, digits: 2),
      orders: _num(data['orders']) == null ? '—' : '${data['orders']}',
      delta: change == null
          ? '—'
          : '${_deltaNames[i]} ${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
      from: _md(data['from']),
      to: _md(data['to']),
      memberShare: share == null ? '—' : '${share.round()}%',
      current: series(data['current']),
      previous: series(data['previous']),
      parts: [
        for (var k = 0; k < _compositionKeys.length; k++)
          (
            name: _compositionNames[k],
            percent:
                '${(_num(comp[_compositionKeys[k]]?['percent']) ?? 0).round()}%',
            amount: money(_num(comp[_compositionKeys[k]]?['amount']) ?? 0),
            ratio: ((_num(comp[_compositionKeys[k]]?['percent']) ?? 0) / 100)
                .clamp(0.0, 1.0)
                .toDouble(),
          ),
      ],
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
        key: _view,
        load: _load,
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
        onLoaded: _loaded,
        onSettled: _settled,
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
        onChanged: _select,
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

  Widget _pill(String t, String icon, {required VoidCallback onTap}) =>
      AppButton(
        label: t,
        kind: AppButtonKind.secondary,
        size: AppButtonSize.medium,
        expanded: false,
        svg: AppIcon.svg(icon),
        onPressed: onTap,
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
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrendPainter(
                    current: r.current,
                    previous: r.previous,
                    line: C.primary,
                    dash: C.faint,
                  ),
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
        AppButton(
          label: '全部订单与收款',
          kind: AppButtonKind.secondary,
          size: AppButtonSize.medium,
          expanded: false,
          svg: AppIcon.svg('chevronRight'),
          onPressed: () => openRoute(context, 'OrderList'),
        ),
      ],
    ),
  );

  Widget _composition() {
    final colors = [C.ink, C.primary, const Color(0xFF7CC4FB), C.stroke];
    final parts = r.parts;
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
                Text(
                  parts.isEmpty ? '—' : parts[i].percent,
                  style: ts(13, color: C.muted, h: 18),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 76,
                  child: Text(
                    parts.isEmpty ? '—' : parts[i].amount,
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
                widthFactor: parts.isEmpty ? 0 : parts[i].ratio,
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

/// 真实趋势：本期实线、对比期虚线；null（尚未到来的时刻 / 超出对比期长度）处断开。
class _TrendPainter extends CustomPainter {
  final List<double?> current, previous;
  final Color line, dash;
  const _TrendPainter({
    required this.current,
    required this.previous,
    required this.line,
    required this.dash,
  });

  static const _pad = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final n = current.length > previous.length
        ? current.length
        : previous.length;
    if (n == 0) return;
    var top = 0.0;
    for (final v in [...current, ...previous]) {
      if (v != null && v > top) top = v;
    }
    if (top <= 0) top = 1;
    Offset at(int i, double v) => Offset(
      n == 1 ? size.width / 2 : size.width * i / (n - 1),
      _pad + (size.height - 2 * _pad) * (1 - v / top),
    );
    Path path(List<double?> values) {
      final out = Path();
      var open = false;
      for (var i = 0; i < values.length; i++) {
        final v = values[i];
        if (v == null) {
          open = false;
          continue;
        }
        final p = at(i, v);
        if (open) {
          out.lineTo(p.dx, p.dy);
        } else {
          out.moveTo(p.dx, p.dy);
          open = true;
        }
      }
      return out;
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // 对比期：虚线
    final dashed = Path();
    for (final m in path(previous).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        dashed.addPath(
          m.extractPath(d, math.min(d + 4, m.length)),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(dashed, stroke..color = dash);
    canvas.drawPath(path(current), stroke..color = line);
    // 单点（如周一的本周）或最后一个点：画圆点
    for (var i = current.length - 1; i >= 0; i--) {
      final v = current[i];
      if (v == null) continue;
      canvas.drawCircle(at(i, v), 3.5, Paint()..color = line);
      break;
    }
    for (var i = 0; i < previous.length; i++) {
      final v = previous[i];
      final single =
          (i == 0 || previous[i - 1] == null) &&
          (i == previous.length - 1 || previous[i + 1] == null);
      if (v != null && single) {
        canvas.drawCircle(at(i, v), 2.5, Paint()..color = dash);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.current != current ||
      old.previous != previous ||
      old.line != line ||
      old.dash != dash;
}

/// 图表网格。
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
