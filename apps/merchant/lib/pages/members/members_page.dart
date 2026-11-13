import 'member_filter_controller.dart';
import 'member_filter_sheet.dart';
import 'member_events.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/member_flow.dart';
import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import 'member_models.dart' show Member;
import '../../kit/keyboard.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';
import 'member_detail_page.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});
  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  MemberFilters _filters = MemberFilters();
  int? _pendingReminders;
  int _reminderVersion = 0, _loadVersion = 0;
  String query = '';
  final search = TextEditingController();
  bool _subscribed = false;

  // ───────── 登录后：会员来自后端 ─────────
  bool get _live => merchantApi.hasSession;
  List<Member>? _liveList;
  List<Map<String, dynamic>> _tiers = const [];
  Map<String, int> _counts = const {};
  int _total = 0;
  int _matched = 0;
  num _totalBalance = 0;
  int _newThisMonth = 0;
  bool _loadingMore = false;
  AppError? _error;
  bool _loading = false;
  bool _showSkeleton = false;
  DateTime? _skeletonAt;
  Timer? _debounce;

  /// 当前选中的卡种（null = 全部）。
  String? _tierId;

  @override
  void initState() {
    super.initState();
    if (_live) {
      memberChanged.addListener(_load);
      _subscribed = true;
      _load();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    if (_subscribed) {
      memberChanged.removeListener(_load);
    }
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (!_live || (more && (_loading || _loadingMore))) return;
    final version = ++_loadVersion;
    final offset = more ? (_liveList?.length ?? 0) : 0;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _showSkeleton = false;
        _skeletonAt = null;
      }
    });
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && version == _loadVersion && _loading && !more) {
        setState(() {
          _showSkeleton = true;
          _skeletonAt = DateTime.now();
        });
      }
    });
    List<Member>? rows;
    List<Map<String, dynamic>>? tiers;
    Map<String, int>? counts;
    MemberPage? pageData;
    int? total;
    AppError? failed;
    final asked = (query: query, tier: _tierId, filters: _filters);
    final filterArgs = _filters;
    try {
      final res = await Future.wait<Object>([
        merchantApi.members(
          query: asked.query,
          cardTypeId: asked.tier,
          cardTypeIds: filterArgs.tierIds.toList(),
          balanceMin: filterArgs.min,
          balanceMax: filterArgs.max,
          visitedWithinDays: filterArgs.within,
          visitedOverDays: filterArgs.over,
          offset: offset,
        ),
        merchantApi.list('cards'),
      ]);
      final page = res[0] as MemberPage;
      pageData = page;
      rows = [for (final r in page.items) memberFromRow(r)];
      counts = page.counts;
      total = page.total;
      tiers = res[1] as List<Map<String, dynamic>>;
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    final at = _skeletonAt;
    if (at != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(at);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted || version != _loadVersion) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      _showSkeleton = false;
      if (failed == null) {
        _liveList = more ? [...?_liveList, ...rows!] : rows;
        if (!more) unawaited(_loadReminderCount());
        _matched = pageData!.matched;
        _totalBalance = pageData.totalBalance;
        _newThisMonth = pageData.newThisMonth;
        _counts = counts!;
        _total = total!;
        _tiers = tiers!;
        _error = null;
      } else if (_liveList == null) {
        _error = failed;
      }
    });
    if (failed != null && _liveList != null) {
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? _load : null,
      );
    } else if (failed == null &&
        (asked.query != query ||
            asked.tier != _tierId ||
            asked.filters != _filters)) {
      // 请求期间又改了搜索 / 筛选：按最新条件再取一次
      unawaited(_load());
    }
  }

  Future<void> _loadReminderCount() async {
    final version = ++_reminderVersion;
    try {
      final data = await merchantApi.reminders();
      if (mounted && version == _reminderVersion) {
        setState(() => _pendingReminders = (data['pending'] as num?)?.toInt());
      }
    } catch (e) {
      if (mounted && version == _reminderVersion) {
        final error = AppError.from(e);
        AppToast.show(
          context,
          error.message,
          kind: ToastKind.error,
          actionLabel: error.retryable ? '重试' : null,
          onAction: error.retryable ? _loadReminderCount : null,
        );
      }
    }
  }

  Future<void> _openFilters() async {
    final selected = await showMemberFilters(context, _filters);
    if (!mounted || selected == null) return;
    setState(() => _filters = selected);
    await _load();
  }

  void _onQuery(String v) {
    setState(() => query = v.trim());
    if (!_live) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  void _pickTier(String? id) {
    setState(() => _tierId = id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_live) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    final list = _liveList ?? const <Member>[];

    return Scaffold(
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          0,
          MediaQuery.of(context).padding.top + 12,
          0,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '会员',
                    style: ts(28, w: FontWeight.w600, h: 36, spacing: -0.7),
                  ),
                ),
                Semantics(
                  button: true,
                  label: '筛选会员',
                  child: GestureDetector(
                    onTap: _openFilters,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: C.card,
                        shape: BoxShape.circle,
                        boxShadow: softShadow,
                      ),
                      child: Center(
                        child: AppIcon('filter', size: 20, color: C.ink),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    openRoute(context, 'MemberAdd');
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                    decoration: BoxDecoration(
                      color: C.btn,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        AppIcon('add', size: 18, color: C.btnFg),
                        const SizedBox(width: 6),
                        Text(
                          '新增会员',
                          style: ts(
                            14,
                            w: FontWeight.w500,
                            color: C.btnFg,
                            h: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: softShadow,
              ),
              child: Row(
                children: [
                  AppIcon('search', size: 20, color: C.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: search,
                      onTapOutside: onTapOutsideDismiss,
                      onChanged: _onQuery,
                      style: ts(14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: '姓名 / 手机号 / 车牌号',
                        hintStyle: ts(14, color: C.muted),
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: '扫车牌或会员码找会员',
                    child: GestureDetector(
                      onTap: () => openRoute(context, 'FindScanPlate'),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: C.inset,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppIcon('scan', size: 18, color: C.ink),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _summary(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _liveChip(
                  _liveList == null ? '全部' : '全部 $_total',
                  _tierId == null,
                  () => _pickTier(null),
                ),
                for (final t in _tiers) ...[
                  const SizedBox(width: 8),
                  _liveChip(
                    '${t['name']} ${_counts['${t['id']}'] ?? 0}',
                    _tierId == '${t['id']}',
                    () => _pickTier('${t['id']}'),
                  ),
                ],
                // 待回访数量来自 reminders 接口。
                const SizedBox(width: 8),
                _followChip(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              radius: 24,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Stack(
                children: [
                  Opacity(
                    opacity: _loading && _showSkeleton && _liveList != null
                        ? 0.6
                        : 1,
                    child: _live && _liveList == null
                        ? (_error != null
                              ? SizedBox(
                                  height: 300,
                                  child: ErrorView(
                                    error: _error!,
                                    retrying: _loading,
                                    onRetry: _load,
                                  ),
                                )
                              : (_showSkeleton
                                    ? const SkeletonList(count: 5)
                                    : const SizedBox(height: 120)))
                        : _live && list.isEmpty
                        ? SizedBox(
                            height: 280,
                            child:
                                (query.isEmpty &&
                                    _tierId == null &&
                                    !_filters.active)
                                ? EmptyView.firstTime(
                                    title: '还没有会员',
                                    message: '办理第一张会员卡，建立会员档案',
                                    actionLabel: '新增会员',
                                    onAction: () {
                                      openRoute(context, 'MemberAdd');
                                    },
                                  )
                                : EmptyView.filtered(
                                    onAction: () {
                                      search.clear();
                                      setState(() => query = '');
                                      _tierId = null;
                                      _filters = MemberFilters();
                                      _load();
                                    },
                                  ),
                          )
                        : list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                '没有符合条件的会员',
                                style: ts(14, color: C.muted),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < list.length; i++) ...[
                                _row(context, list[i]),
                                if (i < list.length - 1)
                                  const Divider1(indent: 72),
                              ],
                            ],
                          ),
                  ),
                  if (_loading && _showSkeleton && _liveList != null)
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
          ),
          if (_live && _liveList != null && _liveList!.length < _matched)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Center(
                child: LoadingButton(
                  label: '加载更多',
                  loadingLabel: '加载中…',
                  style: LoadingButtonStyle.secondary,
                  onPressed: () => _load(more: true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 储值余额合计：不到 1 万显示整数，否则 `¥48.6万`。
  static String _compactMoney(num v) {
    if (v < 10000) return '¥${formatMoney(v)}';
    final w = (v / 10000);
    return '¥${w >= 100 ? w.round() : w.toStringAsFixed(1)}万';
  }

  Widget _liveChip(String label, bool on, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: on ? C.btn : (C.dark ? C.chip : C.card),
            borderRadius: BorderRadius.circular(17),
            border: on || C.dark ? null : Border.all(color: C.stroke),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: ts(
                13,
                w: FontWeight.w500,
                color: on ? C.btnFg : C.sub,
                h: 18,
              ),
            ),
          ),
        ),
      );

  Widget _followChip() => GestureDetector(
    onTap: () => openRoute(context, 'MemberFollowUp'),
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: C.redSoft,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: C.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _pendingReminders == null ? '待回访' : '待回访 $_pendingReminders',
            style: ts(13, w: FontWeight.w500, color: C.redInk, h: 18),
          ),
        ],
      ),
    ),
  );

  Widget _summary() {
    Widget tile(
      String icon,
      Color iconBg,
      Color iconFg,
      String label,
      Widget value,
    ) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: AppIcon(icon, size: 16, color: iconFg)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: ts(11, color: const Color(0xFFA1A1AA), h: 14),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    const white = Color(0xFFFAFAFA);
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [Color(0xFF2A2A30), Color(0xFF18181B), Color(0xFF121214)],
          stops: [0, 0.55, 1],
        ),
        border: C.heroBorder,
        boxShadow: C.dark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x2E18181B),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: Offset(0, 10),
                ),
              ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -98,
            top: -128,
            child: Rings(
              size: 240,
              viewBox: 240,
              radii: [60, 90, 118],
              colors: [Color(0xFF3A3226), Color(0xFF2E2A24), Color(0xFF27272A)],
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '会员总数',
                          style: ts(12, color: const Color(0xFFA1A1AA), h: 16),
                        ),
                        Text(
                          _liveList == null ? '—' : '$_total',
                          style: ts(
                            34,
                            w: FontWeight.w600,
                            color: white,
                            h: 40,
                            tabular: true,
                            spacing: -1,
                          ),
                        ),
                        if (_newThisMonth > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            height: 20,
                            padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
                            decoration: BoxDecoration(
                              color: const Color(0x2917C964),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon(
                                  'trendUp',
                                  size: 11,
                                  color: const Color(0xFF5FD48C),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '本月新增 $_newThisMonth',
                                  style: ts(
                                    11,
                                    w: FontWeight.w600,
                                    color: const Color(0xFF5FD48C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 132,
                    height: 64,
                    child: CustomPaint(painter: _TrendPainter()),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  tile(
                    'card',
                    const Color(0x29F5D78E),
                    C.gold,
                    '储值余额',
                    Text(
                      _liveList == null ? '—' : _compactMoney(_totalBalance),
                      style: ts(
                        17,
                        w: FontWeight.w600,
                        color: white,
                        h: 24,
                        tabular: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  tile(
                    'trendUp',
                    const Color(0x330485F7),
                    const Color(0xFF6AB4FA),
                    '复购率',
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '—',
                          style: ts(
                            17,
                            w: FontWeight.w600,
                            color: white,
                            h: 24,
                            tabular: true,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _avatarBg = [0xFFFDEFD6, 0xFFE1F0FE, 0xFFDDF6E7, 0xFFEEEEF0];
  static const _avatarFg = [0xFF855F2E, 0xFF1E63AE, 0xFF2B7745, 0xFF3F3F46];

  Widget _levelTag(String level) {
    Color bg, fg;
    switch (level) {
      case '黑金':
        bg = C.pill;
        fg = C.gold;
      case '金卡':
        bg = C.amberSoft;
        fg = C.amberInk;
      default:
        bg = C.chip;
        fg = C.sub;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        level,
        style: ts(11, w: FontWeight.w600, color: fg, h: 18),
      ),
    );
  }

  Widget _row(BuildContext context, Member m) {
    final idx = _liveList?.indexOf(m) ?? 0;
    final black = m.level == '黑金';
    final k = ((idx < 0 ? 0 : idx) + 3) % 4;
    Widget note;
    if (m.amountNote.contains('次卡')) {
      note = _notePill(m.amountNote, C.redSoft, C.redInk);
    } else if (m.amountNote.contains('回访')) {
      note = _notePill(m.amountNote, C.amberSoft, C.amberInk);
    } else {
      note = Text(m.amountNote, style: ts(12, color: C.muted, h: 16));
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => push(context, MemberDetailPage(member: m)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Avatar(
              m.name.isEmpty ? '' : m.name.substring(0, 1),
              bg: black ? C.pill : (C.dark ? C.chip : Color(_avatarBg[k])),
              fg: black ? C.gold : (C.dark ? C.sub : Color(_avatarFg[k])),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(m.name, style: ts(15, w: FontWeight.w500, h: 22)),
                      const SizedBox(width: 6),
                      _levelTag(m.level),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${m.plate} · ${m.lastVisit}',
                    style: ts(12, color: C.muted, h: 16),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  m.amount,
                  style: ts(15, w: FontWeight.w600, h: 22, tabular: true),
                ),
                const SizedBox(height: 3),
                note,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notePill(String t, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      t,
      style: ts(11, w: FontWeight.w500, color: fg, h: 18),
    ),
  );
}

/// 近 6 个月会员增长趋势（金色折线 + 渐变面积）。
class _TrendPainter extends CustomPainter {
  const _TrendPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final line = Path()
      ..moveTo(2, 52)
      ..cubicTo(16, 50, 22, 44, 36, 42)
      ..cubicTo(50, 40, 58, 36, 70, 30)
      ..cubicTo(82, 24, 96, 24, 108, 14)
      ..lineTo(130, 8);
    final area = Path.from(line)
      ..lineTo(130, 64)
      ..lineTo(2, 64)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x61F5D78E), Color(0x00F5D78E)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFFF5D78E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      const Offset(130, 8),
      4,
      Paint()..color = const Color(0xFF18181B),
    );
    canvas.drawCircle(
      const Offset(130, 8),
      4,
      Paint()
        ..color = const Color(0xFFF5D78E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
