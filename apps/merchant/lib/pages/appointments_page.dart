import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import 'appointment_detail_live_page.dart';
import 'appointment_schedule_live.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'appointment_add_page.dart';

class AppointmentsPage extends StatefulWidget {
  /// 0 = 列表，1 = 工位时间表（同一界面的两个视图）
  final int initialView;
  const AppointmentsPage({super.key, this.initialView = 0});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with WidgetsBindingObserver {
  late int day = bookingToday.weekday - 1;
  late int view = widget.initialView;
  ApptStatus? filter;
  final _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  int _weekOffset = 0;
  static const _initialWeekPage = 10000;
  final _weekController = PageController(initialPage: _initialWeekPage);
  bool _restoringWeek = false;
  int _revision = 0;
  DateTime? _pausedAt;
  DateTime? _displayMonday;
  Map<String, dynamic> _settings = {};
  List<Appointment> _rows = [];
  List<Map<String, dynamic>> _resources = [];
  DateTime get _monday => _mondayFor(_weekOffset);
  DateTime _mondayFor(int offset) {
    final d = bookingToday;
    return DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1)).add(Duration(days: offset * 7));
  }

  List<(String, String, int?)> _daysFor(int offset) {
    final monday = _mondayFor(offset);
    return [
      for (var i = 0; i < 7; i++)
        (
          '一二三四五六日'[i],
          '${monday.add(Duration(days: i)).day}',
          _displayMonday == monday
              ? _rows
                    .where(
                      (a) =>
                          bookingDay(a.start) ==
                          bookingDay(monday.add(Duration(days: i))),
                    )
                    .length
              : null,
        ),
    ];
  }

  Future<Map<String, dynamic>> _load() async {
    while (true) {
      if (!mounted) throw StateError('页面已关闭');
      final version = _revision, monday = bookingDay(_monday);
      try {
        final values = await Future.wait([
          merchantApi.appointment('board', {'day': monday}),
          merchantApi.appointment('options'),
        ]);
        if (version == _revision) {
          return {
            ...values[0],
            'resources': values[1]['resources'],
            'settings': values[1]['settings'],
            'week': monday,
          };
        }
      } catch (e) {
        if (version == _revision) {
          if (mounted &&
              _displayMonday != null &&
              bookingDay(_displayMonday!) != bookingDay(_monday)) {
            final previous =
                _displayMonday!.difference(_mondayFor(0)).inDays ~/ 7;
            _restoringWeek = true;
            if (_weekController.hasClients) {
              _weekController.jumpToPage(_initialWeekPage + previous);
            }
            _restoringWeek = false;
            setState(() => _weekOffset = previous);
          }
          rethrow;
        }
      }
    }
  }

  void _showWeek(int page) {
    if (_restoringWeek) return;
    setState(() => _weekOffset = page - _initialWeekPage);
    _refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _pausedAt = DateTime.now();
    if (state == AppLifecycleState.resumed &&
        _pausedAt != null &&
        DateTime.now().difference(_pausedAt!) >= const Duration(minutes: 5)) {
      _refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppointmentFlow.changed.addListener(_refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppointmentFlow.changed.removeListener(_refresh);
    _weekController.dispose();
    super.dispose();
  }

  void _refresh() {
    _revision++;
    _key.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final items = _rows
        .where(
          (a) =>
              bookingDay(a.start) ==
              bookingDay((_displayMonday ?? _monday).add(Duration(days: day))),
        )
        .toList();
    int count(ApptStatus s) => items.where((a) => a.status == s).length;
    bool show(Appointment a) => filter == null || a.status == filter;
    final pending =
        items.where((a) => a.status != ApptStatus.done && show(a)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    final done =
        items.where((a) => a.status == ApptStatus.done && show(a)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
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
              child: AsyncView<Map<String, dynamic>>(
                key: _key,
                load: _load,
                isEmpty: (_) => false,
                skeleton: const SkeletonList(count: 5),
                empty: (_) => const SizedBox.shrink(),
                onLoaded: (value) => setState(() {
                  _rows = [
                    for (final r in value['items'] as List)
                      Appointment(Map<String, dynamic>.from(r as Map)),
                  ];
                  _displayMonday = DateTime.parse('${value['week']}T00:00:00Z');
                  _settings = Map<String, dynamic>.from(
                    value['settings'] as Map,
                  );
                  _resources = List<Map<String, dynamic>>.from(
                    value['resources'] as List,
                  );
                }),
                builder: (context, _) => RefreshIndicator(
                  onRefresh: _key.currentState!.reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      SizedBox(
                        key: const ValueKey('appointment-week'),
                        height: 86,
                        child: PageView.builder(
                          controller: _weekController,
                          onPageChanged: _showWeek,
                          itemBuilder: (_, page) =>
                              _week(page - _initialWeekPage),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Segmented(
                        labels: const ['列表', '工位时间表'],
                        selected: view,
                        onChanged: (i) => setState(() => view = i),
                      ),
                      const SizedBox(height: 16),
                      if (view == 1)
                        AppointmentScheduleLive(
                          items: items,
                          resources: _resources,
                          opensAt: '${_settings['opens_at'] ?? '09:00'}',
                          closesAt: '${_settings['closes_at'] ?? '20:00'}',
                          onOpen: (a) => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AppointmentDetailLivePage(id: a.id),
                            ),
                          ),
                        )
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
                          EmptyView(
                            title: filter == null ? '当天还没有预约' : '当天没有符合条件的预约',
                            message: filter == null
                                ? '点击下方“新建预约”安排到店服务'
                                : '切换状态筛选查看其他预约',
                            inline: true,
                          ),
                        if (pending.isNotEmpty) ...[
                          _sectionTitle(
                            '待处理 · 现在 ${bookingTime(bookingToday)}',
                          ),
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

  Widget _week(int offset) {
    final days = _daysFor(offset);
    return AppCard(
      padding: const EdgeInsets.all(8),
      radius: 24,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
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
                        days[i].$1,
                        style: ts(
                          11,
                          color: day == i ? C.faint : C.muted,
                          h: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        days[i].$2,
                        style: ts(
                          17,
                          w: FontWeight.w600,
                          color: day == i ? C.btnFg : C.ink,
                          h: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        days[i].$3 == null
                            ? ' '
                            : days[i].$3 == 0
                            ? '—'
                            : '${days[i].$3} 单',
                        style: ts(
                          10,
                          color: day == i ? C.faint : C.muted,
                          h: 12,
                        ),
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
  }

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

  String? _busyId;
  Future<void> _arrive(Appointment a) async {
    if (_busyId != null) return;
    setState(() => _busyId = a.id);
    try {
      await AppointmentFlow.change(a.id, 'arrive');
      if (mounted) AppToast.show(context, '已标记到店', kind: ToastKind.success);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _contact(Appointment a) {
    // TODO: 尚未接系统拨号能力；显示真实联系电话，不假装已经拨打。
    AppToast.show(
      context,
      a.row['phone'] == '' ? '散客尚未登记联系方式' : '联系电话：${a.row['phone']}',
    );
  }

  Widget _card(BuildContext context, Appointment a) {
    final st = _statusStyle(a.status);
    final done = a.status == ApptStatus.done;
    Widget btn(String t, Color bg, Color fg, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: _busyId == a.id ? null : onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _busyId == a.id && t == '客户到店'
              ? AppSpinner(size: 18, color: fg)
              : Text(
                  t,
                  style: ts(14, w: FontWeight.w600, color: fg, h: 20),
                ),
        ),
      ),
    );
    final call = GestureDetector(
      onTap: () => _contact(a),
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
      () => showAppointmentReschedule(context, a),
    );
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppointmentDetailLivePage(id: a.id),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.time,
                        maxLines: 1,
                        softWrap: false,
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
                                if (a.plate.trim().isNotEmpty) ...[
                                  _plate(a.plate),
                                  const SizedBox(width: 6),
                                ],
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
                      () => openAppointmentOrder(context, a),
                    ),
                    const SizedBox(width: 8),
                    reschedule,
                  ] else if (a.status == ApptStatus.late) ...[
                    btn('联系客户', C.primary, Colors.white, () => _contact(a)),
                    const SizedBox(width: 8),
                    reschedule,
                    const SizedBox(width: 8),
                    call,
                  ] else ...[
                    btn('客户到店', C.btn, C.btnFg, () => _arrive(a)),
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
