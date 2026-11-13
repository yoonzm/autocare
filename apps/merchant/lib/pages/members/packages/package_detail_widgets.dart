import '../../../kit/buttons.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../backend/package_calc.dart' show formatMoney;
import '../../../kit/kit.dart';
import '../../../resources/merchant_svgs.dart';
import '../../../routes.dart' show openRoute;
import '../../../theme.dart' show C, softShadow;
import 'owned_package_view.dart';
import '../member_route_data.dart';

/// 次卡详情顶部的进度环（剩余次数占总次数），环里是“剩余次”。
Widget hPackageRing(OwnedPackageView k) => Builder(
  builder: (context) {
    final fraction = k.ringFraction;
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(84, 84),
            painter: _RingPainter(fraction),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${k.remaining}',
                style: hts(
                  24,
                  const Color(0xFFFAFAFA),
                  w: FontWeight.w600,
                  lh: 26,
                ),
              ),
              Text('剩余次', style: hts(10, const Color(0xFFA1A1AA), lh: 14)),
            ],
          ),
        ],
      ),
    );
  },
);

class _RingPainter extends CustomPainter {
  final double fraction;
  const _RingPainter(this.fraction);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: 37.5,
    );
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = const Color(0x24FFFFFF),
    );
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFF5D78E),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

Widget _heading(BuildContext context, String text) => hbox(
  pad: const EdgeInsets.only(left: 4),
  child: Text(
    text,
    style: hts(
      13,
      dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
      w: FontWeight.w500,
      lh: 18,
    ),
  ),
);

Widget _card(BuildContext context, Widget child) => Container(
  decoration: BoxDecoration(
    color: C.card,
    borderRadius: BorderRadius.circular(24),
    boxShadow: C.dark ? null : softShadow,
    border: C.dark ? Border.all(color: const Color(0xFF26262B)) : null,
  ),
  child: child,
);

/// “包含服务”：每个服务一行（剩余 / 总次数、已用）。
Widget hPackageServices(
  Map<String, dynamic> package,
  Map<String, dynamic> member,
) => Builder(
  builder: (context) {
    final items = List<Map<String, dynamic>>.from(
      package['items'] as List? ?? const [],
    );
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return hcol(
      [
        _heading(context, '包含服务'),
        _card(
          context,
          Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  hbox(
                    h: 1,
                    bg: dk(
                      context,
                      const Color(0xFFEFEFF1),
                      const Color(0xFF2A2A2E),
                    ),
                    margin: const EdgeInsets.only(left: 64),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: dk(
                            context,
                            const Color(0xFFE1F0FE),
                            const Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: hsvg(
                            dk(context, Svgs.s274, Svgs.s275),
                            w: 20,
                            h: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${items[i]['service_name']}',
                              style: hts(14, ink, w: FontWeight.w500, lh: 20),
                            ),
                            Text(
                              '剩余 ${(items[i]['total'] as num) - (items[i]['used'] as num)} 次 / 共 ${items[i]['total']} 次',
                              style: hts(12, muted, lh: 16),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '已用 ${items[i]['used']}',
                        style: hts(12, muted, lh: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 8,
    );
  },
);

/// “使用记录”：时间线，最近的在前。
Widget hPackageRecords(
  Map<String, dynamic> package,
  Map<String, dynamic> member,
) => Builder(
  builder: (context) {
    final events = List<Map<String, dynamic>>.from(
      package['events'] as List? ?? const [],
    );
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    final shown = events.take(4).toList();
    return hcol(
      [
        _heading(context, '使用记录'),
        _card(
          context,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              children: [
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('还没有使用记录', style: hts(13, muted, lh: 18)),
                  ),
                for (var i = 0; i < shown.length; i++)
                  _timelineRow(
                    context,
                    shown[i],
                    last: i == shown.length - 1,
                    ink: ink,
                    muted: muted,
                  ),
                if (events.length > shown.length)
                  AppButton(
                    label: '查看全部 ${events.length} 条记录',
                    kind: AppButtonKind.text,
                    size: AppButtonSize.medium,
                    expanded: false,
                    onPressed: () => openRoute(
                      context,
                      'MemberRecords',
                      arguments: MemberRouteData(member: member),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 8,
    );
  },
);

String _eventTitle(Map<String, dynamic> e) {
  final count = e['count'];
  return switch ('${e['kind']}') {
    'use' => '核销 $count 次',
    'buy' => '购买 $count 次',
    'extend' => '延期 ${e['days']} 天',
    'refund' => '退款 ¥${formatMoney(num.tryParse('${e['amount']}') ?? 0)}',
    _ => '${e['kind']}',
  };
}

String _eventSub(Map<String, dynamic> e) {
  final parts = [
    if ('${e['vehicle_plate'] ?? ''}'.isNotEmpty) '${e['vehicle_plate']}',
    if ('${e['service_name'] ?? ''}'.isNotEmpty) '${e['service_name']}',
    if ('${e['reason'] ?? ''}'.isNotEmpty) '${e['reason']}',
    // 技师依赖员工模块，目前只记录经办人
    if ('${e['kind']}' != 'use' && '${e['operator'] ?? ''}'.isNotEmpty)
      '${e['operator']}',
  ];
  return parts.join(' · ');
}

String _eventTime(Map<String, dynamic> e) {
  final t = DateTime.tryParse('${e['created_at']}')?.toLocal();
  if (t == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  final now = DateTime.now();
  final hm = '${two(t.hour)}:${two(t.minute)}';
  return t.year == now.year && t.month == now.month && t.day == now.day
      ? '今天 $hm'
      : '${two(t.month)}.${two(t.day)} $hm';
}

Widget _timelineRow(
  BuildContext context,
  Map<String, dynamic> e, {
  required bool last,
  required Color ink,
  required Color muted,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: Stack(
    children: [
      if (!last)
        Positioned(
          left: 5,
          top: 16,
          bottom: -14,
          child: Container(
            width: 2,
            color: dk(
              context,
              const Color(0xFFE4E4E7),
              const Color(0xFF3F3F46),
            ),
          ),
        ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF0485F7),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: dk(
                    context,
                    const Color(0xFFE1F0FE),
                    const Color.fromRGBO(4, 133, 247, 0.18),
                  ),
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventTitle(e),
                  style: hts(14, ink, w: FontWeight.w500, lh: 20),
                ),
                if (_eventSub(e).isNotEmpty)
                  Text(_eventSub(e), style: hts(12, muted, lh: 17)),
              ],
            ),
          ),
          Text(
            _eventTime(e),
            style: hts(
              12,
              dk(context, const Color(0xFFA1A1AA), const Color(0xFF80808A)),
              lh: 17,
            ),
          ),
        ],
      ),
    ],
  ),
);
