import 'appointment_schedule_legend.dart';

import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../kit/async_kit.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 沿用设计稿：40px 时间轴、62px 工位列、每小时 44px 的排班网格。
class AppointmentScheduleLive extends StatelessWidget {
  final List<Appointment> items;
  final List<Map<String, dynamic>> resources;
  final ValueChanged<Appointment> onOpen;
  final String opensAt, closesAt;
  const AppointmentScheduleLive({
    super.key,
    required this.items,
    required this.resources,
    required this.onOpen,
    this.opensAt = '09:00',
    this.closesAt = '20:00',
  });
  @override
  Widget build(BuildContext context) {
    int clock(String t) =>
        int.parse(t.split(':')[0]) * 60 + int.parse(t.split(':')[1]);
    final startMinute = clock(opensAt), endMinute = clock(closesAt);
    final gridHeight = (endMinute - startMinute) / 60 * 44;
    double top(Appointment a) =>
        ((a.start.hour * 60 + a.start.minute - startMinute) / 60 * 44).clamp(
          0,
          gridHeight,
        );
    final bays = resources.where((r) => r['kind'] == 'bay').toList();
    final columns = [
      ...bays,
      if (items.any((a) => a.row['bay_id'] == null))
        {'id': null, 'name': '未指定'},
    ];
    if (columns.isEmpty) {
      return const EmptyView(
        title: '还没有工位',
        message: '在“营业时间与工位”中添加后可查看排班',
        inline: true,
      );
    }
    final visible = ((MediaQuery.sizeOf(context).width - 88) / 62).ceil().clamp(
      0,
      bays.length,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(8, 14, 0, 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 40 + 62.0 * columns.length,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      for (final bay in columns)
                        SizedBox(
                          width: 62,
                          child: Text(
                            '${bay['name']}',
                            textAlign: TextAlign.center,
                            style: ts(
                              12,
                              w: FontWeight.w600,
                              color: C.sub,
                              h: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: gridHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (
                          var h = 0;
                          h <= (endMinute - startMinute) ~/ 60;
                          h++
                        ) ...[
                          Positioned(
                            top: h * 44.0,
                            left: 40,
                            right: 0,
                            child: Container(height: 1, color: C.line),
                          ),
                          Positioned(
                            top: h * 44.0 - 7,
                            left: 0,
                            width: 34,
                            child: Text(
                              '${((startMinute + h * 60) ~/ 60).toString().padLeft(2, '0')}:${(startMinute % 60).toString().padLeft(2, '0')}',
                              style: ts(10, color: C.muted, h: 14),
                            ),
                          ),
                        ],
                        for (var c = 0; c < columns.length; c++)
                          for (final a in items.where(
                            (a) => a.row['bay_id'] == columns[c]['id'],
                          ))
                            if (a.start.hour * 60 + a.start.minute >=
                                    startMinute &&
                                a.start.hour * 60 + a.start.minute < endMinute)
                              Positioned(
                                left: 40 + c * 62.0 + 2,
                                top: top(a),
                                width: 58,
                                height: (a.minutes / 60 * 44).clamp(
                                  0,
                                  gridHeight - top(a),
                                ),
                                child: GestureDetector(
                                  onTap: () => onOpen(a),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: switch (a.status) {
                                        ApptStatus.done => C.chip,
                                        ApptStatus.arrived => C.greenSoft,
                                        ApptStatus.late => C.redSoft,
                                        _ => C.primarySoft,
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      a.plate.isEmpty
                                          ? a.customer
                                          : '${a.plate}\n${a.customer}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: ts(
                                        10,
                                        color: switch (a.status) {
                                          ApptStatus.done => C.muted,
                                          ApptStatus.arrived => C.greenInk,
                                          ApptStatus.late => C.redInk,
                                          _ => C.primaryInk,
                                        },
                                        h: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const AppointmentScheduleLegend(),
        const SizedBox(height: 16),
        Text(
          '共 ${bays.length} 个工位，此处显示 $visible 个 · 点击色块查看预约',
          textAlign: TextAlign.center,
          style: ts(12, color: C.faint, h: 18),
        ),
      ],
    );
  }
}
