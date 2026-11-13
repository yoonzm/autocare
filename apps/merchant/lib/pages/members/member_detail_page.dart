import 'packages/member_package_route_data.dart';
import 'member_route_data.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'member_events.dart';
import '../../backend/member_flow.dart';
import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import 'member_models.dart' show Member, Vehicle, CardPack;
import '../../theme.dart';
import '../../routes.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';
import '../orders/order_page.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});
  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  // 登录后（会员来自后端）：进入页面和资料 / 车辆变化后重新读取，保证是最新的
  late Member member = widget.member;
  GlobalKey<AsyncViewState<List<Map<String, dynamic>>>> packagesKey =
      GlobalKey();
  int _refreshVersion = 0;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    if (member.id != null) {
      memberChanged.addListener(_refresh);
      _refresh();
    }
  }

  @override
  void didUpdateWidget(MemberDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member.id != oldWidget.member.id) {
      if (member.id != null) memberChanged.removeListener(_refresh);
      member = widget.member;
      _refreshVersion++;
      packagesKey = GlobalKey();
      _missing = false;
      if (member.id != null) {
        memberChanged.addListener(_refresh);
        _refresh();
      }
    }
  }

  @override
  void dispose() {
    if (member.id != null) memberChanged.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _refresh() async {
    final id = member.id;
    if (id == null || !merchantApi.hasSession) return;
    final version = ++_refreshVersion;
    try {
      final row = await merchantApi.member(id);
      if (!mounted || version != _refreshVersion || id != member.id) return;
      packagesKey.currentState?.reload();
      setState(() {
        member = memberFromRow(row);
      });
    } catch (e) {
      if (!mounted || version != _refreshVersion || id != member.id) return;
      final err = AppError.from(e);
      // 会员已被删除：回到列表；其他失败保留已有内容并提示
      if (err.type == AppErrorType.notFound) {
        setState(() => _missing = true);
        return;
      }
      if (ModalRoute.of(context)?.isCurrent == true) {
        AppToast.show(context, err.message, kind: ToastKind.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession || member.id == null) {
      return Scaffold(
        body: ErrorView(
          error: AppError(
            merchantApi.hasSession ? '请先选择会员' : '请先登录',
            type: merchantApi.hasSession
                ? AppErrorType.notFound
                : AppErrorType.auth,
          ),
          onNext: () =>
              openRoute(context, merchantApi.hasSession ? 'Members' : 'Login'),
        ),
      );
    }
    if (_missing) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('会员已删除', type: AppErrorType.notFound),
          onNext: () => openRoute(context, 'Members'),
        ),
      );
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubHeader(
              '会员详情',
              trailing: Align(
                alignment: Alignment.centerRight,
                child: RoundBtn(
                  'dots',
                  label: '更多',
                  onTap: () => openRoute(
                    context,
                    'MemberMore',
                    arguments: MemberRouteData(member: member.data),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 16),
                  _vehicles(context),
                  const SizedBox(height: 16),
                  _packs(context),
                  const SizedBox(height: 16),
                  _recordsRow(context),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottom > 0 ? bottom - 4 : 16,
              ),
              decoration: BoxDecoration(
                color: C.card,
                boxShadow: [
                  BoxShadow(color: C.line, offset: const Offset(0, -1)),
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: _bottomBtn('余额充值', C.chip, C.ink, () {
                      openRoute(
                        context,
                        'Recharge',
                        arguments: MemberRouteData(member: member.data),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 14,
                    child: _bottomBtn(
                      '为他开单',
                      C.primary,
                      Colors.white,
                      () => push(context, OrderPage(member: member)),
                      icon: 'receipt',
                      bold: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBtn(
    String t,
    Color bg,
    Color fg,
    VoidCallback onTap, {
    String? icon,
    bool bold = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            AppIcon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            t,
            style: ts(
              15,
              w: bold ? FontWeight.w600 : FontWeight.w500,
              color: fg,
              h: 22,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _hero() {
    Widget stat(String l, String v) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: ts(12, color: const Color(0xFFA1A1AA), h: 16)),
          const SizedBox(height: 2),
          Text(
            v,
            style: ts(
              15,
              w: FontWeight.w600,
              color: const Color(0xFFFAFAFA),
              h: 22,
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
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -110,
            bottom: -140,
            child: Rings(
              size: 260,
              viewBox: 260,
              radii: [70, 100, 128],
              colors: [Color(0xFF3A3226), Color(0xFF2E2A24), Color(0xFF27272A)],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: C.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      member.name.substring(0, 1),
                      style: ts(18, w: FontWeight.w600, color: C.onGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: ts(
                            18,
                            w: FontWeight.w600,
                            color: const Color(0xFFFAFAFA),
                            h: 26,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _heroSub(),
                          style: ts(12, color: const Color(0xFFA1A1AA), h: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: C.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      member.level,
                      style: ts(12, w: FontWeight.w600, color: C.onGold, h: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '储值余额（元）',
                style: ts(12, color: const Color(0xFFA1A1AA), h: 16),
              ),
              const SizedBox(height: 2),
              Text(
                _numText('balance', money: true),
                style: ts(
                  32,
                  w: FontWeight.w600,
                  color: const Color(0xFFFAFAFA),
                  h: 38,
                  spacing: -1,
                  tabular: true,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2E2E33))),
                ),
                child: Row(
                  children: [
                    // 累计消费 / 到店次数来自开单（订单模块接入后才会增长）；积分来自充值和手动调整
                    stat('累计消费', '¥${_numText('total_spent')}'),
                    stat('到店次数', '${_numText('visit_count')} 次'),
                    stat('积分', _numText('points')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHead(String title, String action, VoidCallback onTap) => Row(
    children: [
      Expanded(
        child: Text(title, style: ts(15, w: FontWeight.w600, h: 22)),
      ),
      GestureDetector(
        onTap: onTap,
        child: Text(
          action,
          style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
        ),
      ),
    ],
  );

  /// 会员名下的真实车辆。
  List<Map<String, dynamic>> get _liveVehicles =>
      List<Map<String, dynamic>>.from(
        (member.data?['vehicles'] as List?) ?? const [],
      );

  List<(Vehicle, bool)> get _vehicleList => [
    for (final v in _liveVehicles)
      (
        Vehicle(
          '${v['brand_model']}'.isEmpty ? '未填写车型' : '${v['brand_model']}',
          plateText('${v['plate']}'),
          [
            if ('${v['color']}'.isNotEmpty) '${v['color']}',
            if (v['mileage'] != null) '${v['mileage']} km',
          ].join(' · '),
        ),
        v['energy'] == 'ev',
      ),
  ];

  /// 会员记录里的数字：`3680` -> `3,680`；[money] 时保留两位小数。
  String _numText(String key, {bool money = false}) {
    final v = num.tryParse('${member.data?[key] ?? 0}') ?? 0;
    return money ? money2(v) : formatMoney(v);
  }

  String _heroSub() {
    final p = member.phone;
    final masked = p.length == 11
        ? '${p.substring(0, 3)} **** ${p.substring(7)}'
        : p;
    final at = DateTime.tryParse('${member.data?['created_at'] ?? ''}')
        ?.toLocal();
    final joined = at == null
        ? ''
        : ' · 入会 ${at.year}.${at.month.toString().padLeft(2, '0')}';
    return '$masked$joined';
  }

  Widget _vehicles(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead('名下车辆', '添加车辆', () {
          openRoute(
            context,
            'VehicleAdd',
            arguments: MemberRouteData(member: member.data),
          );
        }),
        if (_liveVehicles.isEmpty) ...[
          const SizedBox(height: 12),
          Text('还没有登记车辆', style: ts(13, color: C.muted, h: 18)),
        ] else
          for (var i = 0; i < _vehicleList.length; i++) ...[
            const SizedBox(height: 12),
            if (i > 0) ...[const Divider1(), const SizedBox(height: 12)],
            _vehicle(_vehicleList[i].$1, green: _vehicleList[i].$2),
          ],
      ],
    ),
  );

  Widget _vehicle(Vehicle v, {bool green = false}) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: C.inset,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: AppIcon('car', size: 22, color: C.sub)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v.model, style: ts(14, w: FontWeight.w500, h: 20)),
            const SizedBox(height: 2),
            Text(v.note, style: ts(12, color: C.muted, h: 16)),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: green ? const Color(0xFFD7F5E1) : const Color(0xFF0B5FD6),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: green ? const Color(0xFF86D9A4) : const Color(0xFF5B9BF0),
            width: 1.5,
          ),
        ),
        child: Text(
          v.plate,
          maxLines: 1,
          style: ts(
            12,
            w: FontWeight.w600,
            color: green ? const Color(0xFF14532D) : Colors.white,
            h: 16,
          ),
        ),
      ),
    ],
  );

  Widget _packs(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead('次卡套餐', '购买次卡', () {
          openRoute(
            context,
            'RechargeCard',
            arguments: MemberRouteData(member: member.data),
          );
        }),
        AsyncView<List<Map<String, dynamic>>>(
          shrinkWrap: true,
          inlineError: true,
          skeletonScrollable: false,
          pullToRefresh: false,
          skeletonPadding: EdgeInsets.zero,
          key: packagesKey,
          load: () async => [
            for (final row in await merchantApi.memberPackages(member.id!))
              if (row['refunded_at'] == null) row,
          ],
          isEmpty: (rows) => rows.isEmpty,
          skeleton: const SkeletonList(count: 2),
          empty: (_) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('暂无次卡', style: ts(13, color: C.muted, h: 18)),
          ),
          builder: (_, rows) => Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openPack('${rows[i]['id']}'),
                  child: _pack(_livePack(rows[i]), i),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  Future<void> _openPack(String id) async {
    openRoute(
      context,
      'PackageDetail',
      arguments: MemberPackageRouteData(id: id, member: member.data ?? {}),
    );
  }

  CardPack _livePack(Map<String, dynamic> r) {
    final total = (num.tryParse('${r['total_count']}') ?? 0).toInt();
    final used = (num.tryParse('${r['used_count']}') ?? 0).toInt();
    final exp = DateTime.tryParse('${r['expires_at'] ?? ''}')?.toLocal();
    final text = exp == null
        ? '永久有效'
        : '${exp.year}.${exp.month.toString().padLeft(2, '0')}.${exp.day.toString().padLeft(2, '0')} 到期';
    return CardPack('${r['name']}', total - used, total, text);
  }

  Widget _pack(CardPack p, int i) {
    final amber = i == 1;
    final bg = amber ? C.amberSoft : C.primarySoft;
    final fg = amber ? C.amberInk : C.primaryInk;
    final bar = amber ? C.amber : C.primary;
    final rest = p.expire.contains('到期') && i == 1
        ? ' / ${p.total} 次 · ${p.expire}'
        : ' / ${p.total} 次';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: AppIcon(amber ? 'sparkle' : 'drop', size: 16, color: fg),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(p.name, style: ts(14, w: FontWeight.w500, h: 20)),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${p.used}',
                    style: ts(13, w: FontWeight.w600, h: 18),
                  ),
                  TextSpan(
                    text: rest,
                    style: ts(13, color: C.muted, h: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 6, color: C.chip),
              FractionallySizedBox(
                widthFactor: p.total == 0 ? 0 : (p.used / p.total).clamp(0, 1),
                child: Container(height: 6, color: bar),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recordsRow(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => openRoute(
      context,
      'MemberRecords',
      arguments: MemberRouteData(member: member.data),
    ),
    child: AppCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AppIcon('receipt', size: 18, color: C.primaryInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('消费与充值记录', style: ts(15, w: FontWeight.w500, h: 22)),
            ),
            Text('全部记录', style: ts(13, color: C.muted, h: 18)),
            const SizedBox(width: 4),
            AppIcon('chevronRight', size: 16, color: C.faint),
          ],
        ),
      ),
    ),
  );
}
