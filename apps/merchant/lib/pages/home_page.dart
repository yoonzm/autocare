import '../widgets/inventory_bindings.dart' show inventoryChanged;
import '../backend/appointment_flow.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/hold_flow.dart';
import '../backend/catalog_draft.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../widgets/hold_widgets.dart' show holdTimeText;
import '../backend/member_flow.dart' show plateText;
import '../backend/store_profile.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'appointments_page.dart';
import 'order_page.dart';
import 'settings_page.dart';
import 'shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _money(num value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '$whole.${parts[1]}';
  }

  final _statsKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  Map<String, dynamic>? _stats;
  final _appointmentKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CatalogDraft.changed.addListener(_onDataChanged);
    inventoryChanged.addListener(_onDataChanged);
    AppointmentFlow.changed.addListener(_onAppointmentsChanged);
  }

  void _onAppointmentsChanged() => _appointmentKey.currentState?.reload();
  void _onDataChanged() => unawaited(_refresh());

  Future<void> _refresh() async {
    await Future.wait([
      if (_statsKey.currentState != null) _statsKey.currentState!.reload(),
      if (_appointmentKey.currentState != null)
        _appointmentKey.currentState!.reload(),
    ]);
  }

  Future<void> _pullRefresh() async {
    final previous = _stats;
    await _refresh();
    if (mounted && _stats != null && !identical(previous, _stats)) {
      AppToast.show(context, '已更新', kind: ToastKind.success);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _pausedAt = DateTime.now();
    if (state == AppLifecycleState.resumed &&
        _pausedAt != null &&
        DateTime.now().difference(_pausedAt!) >= const Duration(minutes: 5)) {
      unawaited(_refresh());
    }
  }

  @override
  void dispose() {
    CatalogDraft.changed.removeListener(_onDataChanged);
    inventoryChanged.removeListener(_onDataChanged);
    AppointmentFlow.changed.removeListener(_onAppointmentsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    final scaler = MediaQuery.textScalerOf(context);
    final statsHeight =
        81.0 +
        (C.dark ? 2 : 0) +
        scaler.scale(13) * 18 / 13 +
        scaler.scale(34) * 40 / 34 +
        scaler.scale(12) * 32 / 12 +
        scaler.scale(18) * 26 / 18;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 12,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          children: [
            _header(context),
            const SizedBox(height: 20),
            SizedBox(
              height: statsHeight,
              child: AsyncView<Map<String, dynamic>>(
                key: _statsKey,
                load: merchantApi.homeStats,
                isEmpty: (_) => false, // 成功的零统计仍显示原卡片。
                skeletonPadding: EdgeInsets.zero,
                skeleton: SkeletonDashboardCard(
                  height: statsHeight,
                  radius: 28,
                ),
                empty: (_) => const SizedBox.shrink(),
                onLoaded: (data) => setState(() => _stats = data),
                builder: (_, data) => _revenue(data),
              ),
            ),
            const SizedBox(height: 20),
            _quick(context),
            const SizedBox(height: 20),
            const _WorkSection(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('周六 · 10月31日', style: ts(13, color: C.sub, h: 18)),
              const SizedBox(height: 2),
              Row(
                children: [
                  ListenableBuilder(
                    listenable: storeProfile,
                    builder: (_, _) => Text(
                      storeProfile.live ? storeProfile.name : '—',
                      style: ts(22, w: FontWeight.w600, h: 30, spacing: -0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      RoundBtn(
        'bell',
        label: '消息通知',
        dot: true,
        onTap: () => openRoute(context, 'Messages'),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: () => push(context, const SettingsPage()),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.primary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: C.card, spreadRadius: 3)],
          ),
          // 当前登录人的姓名首字；有头像图片时显示头像（与「我的」页同源）。
          child: ListenableBuilder(
            listenable: storeProfile,
            builder: (_, _) {
              final initial = Text(
                storeProfile.profileInitial,
                style: ts(16, w: FontWeight.w600, color: Colors.white),
              );
              return storeProfile.avatarUrl.isEmpty
                  ? initial
                  : ClipOval(
                      child: Image.network(
                        storeProfile.avatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        cacheWidth: 132,
                        errorBuilder: (_, _, _) => initial,
                      ),
                    );
            },
          ),
        ),
      ),
    ],
  );

  Widget _revenue(Map<String, dynamic> data) {
    final daily = (data['daily_revenue'] as List).cast<num>();
    final peak = daily.fold<num>(0, (a, b) => a > b ? a : b);
    final bars = [
      for (final value in daily) peak == 0 ? 0.0 : value / peak * 64,
    ];
    final change = data['change_percent'] as num?;
    final date = DateTime.parse(data['date'] as String);
    final weekday = '一二三四五六日'[date.weekday - 1];
    final comparison = change == null
        ? '较上周$weekday —'
        : '较上周$weekday ${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
    Widget stat(String l, String v) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: ts(12, color: C.faint, h: 16)),
          const SizedBox(height: 2),
          Text(
            v,
            style: ts(
              18,
              w: FontWeight.w600,
              color: const Color(0xFFFAFAFA),
              h: 26,
            ),
          ),
        ],
      ),
    );
    return Container(
      key: const ValueKey('home-revenue-card'),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.heroCard,
        border: C.heroBorder,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(right: -90, top: -100, child: Rings(size: 220)),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('今日营业额（元）', style: ts(13, color: C.faint, h: 18)),
                        const SizedBox(height: 4),
                        Text(
                          _money(data['revenue'] as num),
                          style: ts(
                            34,
                            w: FontWeight.w600,
                            color: const Color(0xFFFAFAFA),
                            h: 40,
                            spacing: -1,
                            tabular: true,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Opacity(
                              opacity: change == null ? 0 : 1,
                              child: Transform.flip(
                                flipY: change != null && change < 0,
                                child: AppIcon(
                                  'trendUp',
                                  size: 14,
                                  color: const Color(0xFF4ADE80),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comparison,
                              style: ts(
                                12,
                                w: FontWeight.w500,
                                color: const Color(0xFF4ADE80),
                                h: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 64,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < bars.length; i++)
                          Container(
                            width: 10,
                            height: bars[i],
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                            decoration: BoxDecoration(
                              color: i == bars.length - 1
                                  ? C.primary
                                  : const Color(0xFF3F3F46),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2E2E33))),
                ),
                child: Row(
                  children: [
                    stat('订单数', '${data['orders']}'),
                    stat('新增会员', '${data['new_members']}'),
                    stat('客单价', '¥${_money(data['average'] as num)}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quick(BuildContext context) {
    Widget small(
      String title,
      String sub,
      String icon,
      Color bg,
      Color fg,
      VoidCallback tap,
    ) => Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -22,
                bottom: -24,
                child: Opacity(
                  opacity: 0.22,
                  child: AppIcon(icon, size: 64, color: fg, stroke: 1.4),
                ),
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppIcon(icon, size: 20, color: fg),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: ts(15, w: FontWeight.w600, color: fg, h: 22),
                        ),
                      ],
                    ),
                    Text(
                      sub,
                      style: ts(12, color: fg.withValues(alpha: 0.75), h: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => push(context, const OrderPage()),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned(
                          right: -96,
                          bottom: -96,
                          child: Rings(
                            size: 190,
                            viewBox: 240,
                            radii: [60, 90, 118],
                            color: Color(0xFF3B9DF9),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0x33FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                'receipt',
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '开单收银',
                                  style: ts(
                                    20,
                                    w: FontWeight.w700,
                                    color: Colors.white,
                                    h: 26,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '选车 · 选服务 · 收款',
                                  style: ts(
                                    12,
                                    color: const Color(0xD9FFFFFF),
                                    h: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    small(
                      '会员充值',
                      '今日 ${_stats == null ? '—' : '¥${_money(_stats!['recharge'] as num)}'}',
                      'card',
                      C.greenSoft,
                      C.greenInk,
                      () => openRoute(context, 'Recharge'),
                    ),
                    const SizedBox(height: 10),
                    small(
                      '商品入库',
                      _stats == null
                          ? '—'
                          : '${_stats!['stock_low'] ?? 0} 件待补货 · ${_stats!['stock_expiring'] ?? 0} 件临期',
                      'box',
                      C.amberSoft,
                      C.amberInk,
                      () => tabIndex.value = 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: AsyncView<Map<String, dynamic>>(
            key: _appointmentKey,
            load: () => merchantApi.appointment('summary'),
            isEmpty: (_) => false,
            skeletonPadding: EdgeInsets.zero,
            skeleton: const SkeletonDashboardCard(height: 64, radius: 24),
            inlineError: true,
            pullToRefresh: false,
            empty: (_) => const SizedBox.shrink(),
            builder: (_, summary) => GestureDetector(
              onTap: () => push(context, const AppointmentsPage()),
              child: Container(
                height: 64,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: C.heroCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      right: -66,
                      top: -70,
                      child: Rings(
                        size: 190,
                        viewBox: 240,
                        radii: [60, 90, 118],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: C.gold,
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon('calendar', size: 18, color: C.onGold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '预约管理',
                                style: ts(
                                  15,
                                  w: FontWeight.w600,
                                  color: const Color(0xFFFAFAFA),
                                  h: 20,
                                ),
                              ),
                              Text(
                                summary['next'] == null
                                    ? '待到店 ${summary['count']}'
                                    : '待到店 ${summary['count']} · 下一位 ${bookingTime(DateTime.parse(summary['next']['starts_at'] as String).toUtc().add(const Duration(hours: 8)))} ${summary['next']['customer_name']}',
                                style: ts(12, color: C.faint, h: 16),
                              ),
                            ],
                          ),
                        ),
                        AppIcon('arrowRight', size: 18, color: C.faint),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 首页“施工中”：取真实挂单里状态为“施工中”的单子。
///
/// TODO: 卡片上的工位、技师、施工进度、预计完工依赖员工和工位模块，目前没有数据，不显示。
class _WorkSection extends StatefulWidget {
  const _WorkSection();
  @override
  State<_WorkSection> createState() => _WorkSectionState();
}

class _WorkSectionState extends State<_WorkSection> {
  Timer? _timer;
  bool _slow = false;
  bool _wasLoading = false;

  @override
  void initState() {
    super.initState();
    HoldFlow.tick.addListener(_onTick);
    HoldFlow.loadSoon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    HoldFlow.tick.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    final loading = HoldFlow.loading;
    if (loading && !_wasLoading && HoldFlow.holds == null) {
      // 300ms 内什么都不显示，之后才出骨架
      _slow = false;
      _timer?.cancel();
      _timer = Timer(kIndicatorDelay, () {
        if (mounted && HoldFlow.loading) setState(() => _slow = true);
      });
    }
    _wasLoading = loading;
    setState(() {});
  }

  List<Map<String, dynamic>> get _working => [
    for (final h in HoldFlow.holds ?? const <Map<String, dynamic>>[])
      if (h['status'] == '施工中') h,
  ];

  @override
  Widget build(BuildContext context) {
    final working = _working;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          '施工中',
          sub: HoldFlow.holds == null ? null : '${working.length} 单',
          action: '全部',
          onAction: () => openRoute(context, 'HoldList'),
        ),
        const SizedBox(height: 12),
        if (HoldFlow.holds == null && HoldFlow.error != null)
          SizedBox(
            height: 220,
            child: ErrorView(
              error: HoldFlow.error!,
              retrying: HoldFlow.loading,
              onRetry: () => unawaited(HoldFlow.load()),
            ),
          )
        else if (HoldFlow.holds == null)
          _slow ? const SkeletonList(count: 2) : const SizedBox(height: 120)
        else if (working.isEmpty)
          const EmptyView(
            title: '暂无施工中的车辆',
            message: '开单页挂单并选择“施工中”后会显示在这里',
            inline: true,
          )
        else
          for (final h in working.take(5)) ...[
            _LiveJob(h),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _LiveJob extends StatelessWidget {
  final Map<String, dynamic> hold;
  const _LiveJob(this.hold);

  @override
  Widget build(BuildContext context) {
    final member = Map<String, dynamic>.from(
      (hold['member'] as Map?) ?? const {},
    );
    final plate = '${hold['vehicle_plate'] ?? ''}';
    final items =
        List<Map<String, dynamic>>.from((hold['items'] as List?) ?? const [])
          ..sort(
            (a, b) => ((a['position'] ?? 0) as num).compareTo(
              (b['position'] ?? 0) as num,
            ),
          );
    final created = DateTime.tryParse('${hold['created_at'] ?? ''}');
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => openRoute(context, 'HoldList'),
      child: Column(
        children: [
          Row(
            children: [
              if (plate.isNotEmpty) ...[
                PlateTag(plateText(plate), green: plate.length >= 8),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  member.isEmpty ? '散客' : '${member['name'] ?? ''}',
                  style: ts(13, color: C.muted, h: 18),
                ),
              ),
              Pill('施工中', bg: C.primarySoft, fg: C.primaryInk),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  items.map((e) => '${e['name']}').join(' · '),
                  style: ts(15, w: FontWeight.w500, h: 22),
                ),
              ),
              if (created != null)
                Text(
                  holdTimeText(created),
                  style: ts(12, color: C.muted, h: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
