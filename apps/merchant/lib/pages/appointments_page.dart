import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'appointment_add_page.dart';
import 'gen/appointment_schedule_body.dart';

class AppointmentsPage extends StatefulWidget {
  /// 0 = 列表，1 = 工位时间表（同一界面的两个视图）
  final int initialView;
  const AppointmentsPage({super.key, this.initialView = 0});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  int day = 5; // 周六 31 日（今天）
  late int view = widget.initialView;
  ApptStatus? filter;

  // 其他日期的示例预约（仅展示用）
  List<Appointment> _otherDay() {
    final n = _days[day].$3;
    const tpl = [
      ('09:30', '1 小时', '沪B·3D820', '赵女士', '金卡', '基础洗车', '1 号工位 · 小陈'),
      ('11:00', '1.5 小时', '沪A·7L305', '陈女士', '金卡', '内饰精洗', '2 号工位 · 老周'),
      ('14:00', '1 小时', '沪C·9H318', '刘先生', '金卡', '全车精洗', '3 号工位 · 小陈'),
    ];
    return [
      for (var i = 0; i < n && i < tpl.length; i++)
        Appointment(
          tpl[i].$1,
          tpl[i].$2,
          tpl[i].$3,
          tpl[i].$4,
          tpl[i].$5,
          tpl[i].$6,
          tpl[i].$7,
          day < 5 ? ApptStatus.done : ApptStatus.waiting,
        ),
    ];
  }

  static const _days = [
    ('一', '26', 0),
    ('二', '27', 1),
    ('三', '28', 0),
    ('四', '29', 2),
    ('五', '30', 3),
    ('六', '31', 6),
    ('日', '1', 2),
  ];

  @override
  void initState() {
    super.initState();
    appointmentStore.addListener(_refresh);
  }

  @override
  void dispose() {
    appointmentStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = day == 5 ? appointmentStore.items : _otherDay();
    int count(ApptStatus s) => items.where((a) => a.status == s).length;
    bool show(Appointment a) => filter == null || a.status == filter;
    final pending =
        items.where((a) => a.status != ApptStatus.done && show(a)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    final done =
        items.where((a) => a.status == ApptStatus.done && show(a)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      bottomNavigationBar: _bottomBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubHeader(
              '预约管理',
              trailing: Align(
                alignment: Alignment.centerRight,
                child: RoundBtn(
                  'filter',
                  label: '预约设置',
                  onTap: () => openRoute(context, 'AppointmentSettings'),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _week(),
                  const SizedBox(height: 16),
                  Segmented(
                    labels: const ['列表', '工位时间表'],
                    selected: view,
                    onChanged: (i) => setState(() => view = i),
                  ),
                  const SizedBox(height: 16),
                  if (view == 1)
                    const AppointmentScheduleBody()
                  else ...[
                    Row(
                      children: [
                        _stat(
                          '待到店',
                          count(ApptStatus.waiting),
                          C.primarySoft,
                          C.primaryInk,
                          ApptStatus.waiting,
                        ),
                        const SizedBox(width: 8),
                        _stat(
                          '已到店',
                          count(ApptStatus.arrived),
                          C.greenSoft,
                          C.greenInk,
                          ApptStatus.arrived,
                        ),
                        const SizedBox(width: 8),
                        _stat(
                          '超时未到',
                          count(ApptStatus.late),
                          C.redSoft,
                          C.redInk,
                          ApptStatus.late,
                        ),
                        const SizedBox(width: 8),
                        _stat(
                          '已完成',
                          count(ApptStatus.done),
                          C.chip,
                          C.sub,
                          ApptStatus.done,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (pending.isEmpty && done.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            '当天没有符合条件的预约',
                            style: ts(14, color: C.muted),
                          ),
                        ),
                      ),
                    if (pending.isNotEmpty) ...[
                      _sectionTitle('待处理 · 现在 16:47'),
                      for (final a in pending) ...[
                        _card(context, a),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 8),
                    ],
                    if (done.isNotEmpty) ...[
                      _sectionTitle('已完成'),
                      for (final a in done) ...[
                        _card(context, a),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      t,
      style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
    ),
  );

  Widget _bottomBar(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom > 0 ? bottom - 4 : 16),
      decoration: BoxDecoration(
        color: C.card.withValues(alpha: 0.94),
        border: Border(top: BorderSide(color: C.stroke)),
      ),
      child: GestureDetector(
        onTap: () => push(context, const AppointmentAddPage()),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: C.btn,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon('add', color: C.btnFg, size: 20),
              const SizedBox(width: 6),
              Text(
                '新建预约',
                style: ts(15, w: FontWeight.w600, color: C.btnFg, h: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _week() => AppCard(
    padding: const EdgeInsets.all(8),
    radius: 24,
    child: Row(
      children: [
        for (var i = 0; i < _days.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => day = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: day == i ? C.btn : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _days[i].$1,
                      style: ts(11, color: day == i ? C.faint : C.muted, h: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _days[i].$2,
                      style: ts(
                        17,
                        w: FontWeight.w600,
                        color: day == i ? C.btnFg : C.ink,
                        h: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _days[i].$3 == 0 ? '—' : '${_days[i].$3} 单',
                      style: ts(10, color: day == i ? C.faint : C.muted, h: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _stat(String label, int n, Color bg, Color fg, ApptStatus st) =>
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => filter = filter == st ? null : st),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: filter == st ? Border.all(color: fg, width: 1.5) : null,
            ),
            child: Column(
              children: [
                Text(
                  '$n',
                  style: ts(20, w: FontWeight.w600, color: fg, h: 26),
                ),
                const SizedBox(height: 2),
                Text(label, style: ts(11, color: fg, h: 14)),
              ],
            ),
          ),
        ),
      );

  (String, Color, Color) _statusStyle(ApptStatus s) {
    switch (s) {
      case ApptStatus.waiting:
        return ('待到店', C.primarySoft, C.primaryInk);
      case ApptStatus.arrived:
        return ('已到店', C.greenSoft, C.greenInk);
      case ApptStatus.late:
        return ('超时未到', C.redSoft, C.redInk);
      case ApptStatus.done:
        return ('已完成', C.chip, C.sub);
    }
  }

  Widget _plate(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFF0B5FD6),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF5B9BF0), width: 1.5),
    ),
    child: Text(
      t,
      style: ts(11, w: FontWeight.w600, color: Colors.white, h: 16),
    ),
  );

  Widget _tag(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      t,
      style: ts(11, w: FontWeight.w600, color: fg, h: 18),
    ),
  );

  Widget _levelTag(String level) {
    switch (level) {
      case '黑金':
        return _tag(level, C.pill, C.gold);
      case '金卡':
        return _tag(level, C.gold, C.onGold);
      case '银卡':
        return _tag(level, C.chip, C.sub);
      default:
        return _tag(level, C.chip, C.sub);
    }
  }

  Widget _card(BuildContext context, Appointment a) {
    final st = _statusStyle(a.status);
    final done = a.status == ApptStatus.done;
    Widget btn(String t, Color bg, Color fg, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            t,
            style: ts(14, w: FontWeight.w600, color: fg, h: 20),
          ),
        ),
      ),
    );
    final call = GestureDetector(
      onTap: () => toast(context, '拨打 ${a.customer} 电话（演示）'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: C.greenSoft, shape: BoxShape.circle),
        child: Center(child: AppIcon('phone', size: 18, color: C.greenInk)),
      ),
    );
    final reschedule = btn(
      '改期',
      C.chip,
      C.ink,
      () => openRoute(context, 'AppointmentReschedule'),
    );
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openRoute(context, 'AppointmentDetail'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.time,
                        style: ts(
                          18,
                          w: FontWeight.w600,
                          h: 24,
                          tabular: true,
                          color: C.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(a.duration, style: ts(11, color: C.muted, h: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _plate(a.plate),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    a.customer,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ts(15, w: FontWeight.w600, h: 22),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _levelTag(a.level),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          _tag(st.$1, st.$2, st.$3),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(a.service, style: ts(14, color: C.sub, h: 20)),
                      const SizedBox(height: 6),
                      Text(
                        a.station,
                        style: ts(
                          12,
                          color: a.status == ApptStatus.late
                              ? C.redInk
                              : C.muted,
                          h: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!done) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 64),
              child: Row(
                children: [
                  if (a.status == ApptStatus.arrived) ...[
                    btn(
                      '去开单',
                      C.btn,
                      C.btnFg,
                      () => openRoute(context, 'Order'),
                    ),
                    const SizedBox(width: 8),
                    reschedule,
                  ] else if (a.status == ApptStatus.late) ...[
                    btn(
                      '联系客户',
                      C.primary,
                      Colors.white,
                      () => toast(context, '拨打 ${a.customer} 电话（演示）'),
                    ),
                    const SizedBox(width: 8),
                    reschedule,
                    const SizedBox(width: 8),
                    call,
                  ] else ...[
                    btn('客户到店', C.btn, C.btnFg, () {
                      appointmentStore.setStatus(a, ApptStatus.arrived);
                      toast(context, '${a.plate} 已标记到店');
                    }),
                    const SizedBox(width: 8),
                    reschedule,
                    const SizedBox(width: 8),
                    call,
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
