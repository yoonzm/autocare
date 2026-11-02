import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/hold_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../widgets/hold_widgets.dart' show holdTimeText;
import '../backend/member_flow.dart' show plateText;
import '../backend/store_profile.dart';
import '../mock/app_state.dart';
import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'appointments_page.dart';
import 'order_page.dart';
import 'settings_page.dart';
import 'shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          _header(context),
          _banner(context),
          const SizedBox(height: 20),
          _revenue(),
          const SizedBox(height: 20),
          _quick(context),
          const SizedBox(height: 20),
          const _WorkSection(),
        ],
      ),
    );
  }

  /// 订阅状态提醒条：试用将到期 / 套餐将到期（同一首页在不同状态下的呈现）。
  Widget _banner(BuildContext context) => ValueListenableBuilder<SubState>(
    valueListenable: subState,
    builder: (context, st, _) {
      final trial = st == SubState.trialEnding;
      if (st != SubState.trialEnding && st != SubState.expiring) {
        return const SizedBox.shrink();
      }
      final bg = trial ? C.redSoft : C.amberSoft;
      final fg = trial ? C.redInk : C.amberInk;
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xB3FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon('clock', size: 18, color: fg, stroke: 1.9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trial ? '试用剩余 3 天' : '专业版 7 天后到期',
                      style: ts(14, w: FontWeight.w600, color: fg, h: 20),
                    ),
                    Text(
                      trial ? '11.14 结束，之后进入只读模式' : '2027.10.30 到期，建议提前续费',
                      style: ts(12, color: fg.withValues(alpha: 0.8), h: 16),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => openRoute(context, trial ? 'Plans' : 'Renew'),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: trial ? C.red : C.btn,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    trial ? '去订阅' : '去续费',
                    style: ts(
                      13,
                      w: FontWeight.w600,
                      color: trial ? Colors.white : C.btnFg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _header(BuildContext context) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openRoute(context, 'StoreSwitch'),
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
                      storeProfile.live ? storeProfile.name : '驰光汽车美容',
                      style: ts(22, w: FontWeight.w600, h: 30, spacing: -0.4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcon('chevronDown', size: 20, color: C.muted),
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
          child: Text(
            '陈',
            style: ts(16, w: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    ],
  );

  Widget _revenue() {
    const bars = [30.0, 22.0, 38.0, 28.0, 44.0, 52.0, 64.0];
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
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.heroCard,
        border: C.heroBorder,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
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
                          '12,860.00',
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
                            AppIcon(
                              'trendUp',
                              size: 14,
                              color: Color(0xFF4ADE80),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '较上周六 +18.4%',
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
                    stat('订单数', '36'),
                    stat('新增会员', '5'),
                    stat('客单价', '¥357'),
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
                      clipBehavior: Clip.hardEdge,
                      children: [
                        const Positioned(
                          right: -100,
                          bottom: -100,
                          child: Rings(size: 190, color: Color(0xFF3B9DF9)),
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
                      '今日 ¥12,600',
                      'card',
                      C.greenSoft,
                      C.greenInk,
                      () => openRoute(context, 'Recharge'),
                    ),
                    const SizedBox(height: 10),
                    small(
                      '商品入库',
                      '3 件待补货',
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
        GestureDetector(
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
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned(
                  right: -120,
                  top: -110,
                  child: Rings(size: 190),
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
                            '待到店 2 · 下一位 17:30 刘先生',
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
      ],
    );
  }
}

/// 首页“施工中”：登录后取挂单里状态为“施工中”的单子；没登录（设计预览）时是设计稿示例。
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

  bool get _live => merchantApi.hasSession;

  @override
  void initState() {
    super.initState();
    if (_live) {
      HoldFlow.tick.addListener(_onTick);
      HoldFlow.loadSoon();
    }
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
    final live = _live;
    final working = live ? _working : const <Map<String, dynamic>>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          '施工中',
          sub: live
              ? (HoldFlow.holds == null ? null : '${working.length} 单')
              : '2 个工位',
          action: '全部',
          onAction: () => openRoute(context, 'HoldList'),
        ),
        const SizedBox(height: 12),
        if (!live)
          for (final j in workJobs) ...[_MockJob(j), const SizedBox(height: 12)]
        else if (HoldFlow.holds == null && HoldFlow.error != null)
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

class _MockJob extends StatelessWidget {
  final WorkJob job;
  const _MockJob(this.job);
  @override
  Widget build(BuildContext context) {
    final j = job;
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => openRoute(context, 'HoldList'),
      child: Column(
        children: [
          Row(
            children: [
              PlateTag(j.plate, green: !j.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(j.car, style: ts(13, color: C.muted, h: 18)),
              ),
              Pill(
                j.station,
                bg: j.blue ? C.primarySoft : C.amberSoft,
                fg: j.blue ? C.primaryInk : C.amberInk,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  j.service,
                  style: ts(15, w: FontWeight.w500, h: 22),
                ),
              ),
              Text(j.eta, style: ts(12, color: C.muted, h: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: j.progress / 100,
                    minHeight: 6,
                    backgroundColor: C.chip,
                    valueColor: AlwaysStoppedAnimation(
                      j.blue ? C.primary : C.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${j.progress}%',
                style: ts(12, w: FontWeight.w500, h: 16, tabular: true),
              ),
              const SizedBox(width: 10),
              Avatar(j.tech, size: 24, bg: C.stroke, fg: C.ink),
            ],
          ),
        ],
      ),
    );
  }
}
