import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import '../../kit/buttons.dart';
import '../../kit/single_selection.dart';
import 'member_view.dart';

// Data-bound copy of the designed MemberRecordsPage (消费记录). Keep its layout in
// sync with the design; the hero numbers and the list are real, the rows are the
// ledger of the member (充值 / 积分调整 / 卡种调整 / 自动升级).
// TODO: “消费”“次卡”流水依赖订单和次卡售卖，接入后会出现在这里；目前这两个页签是空的。
import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes.dart' show openRoute;
import '../orders/order_detail_ref.dart';

import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class MemberRecordsLivePage extends StatefulWidget {
  final Map<String, dynamic>? member;
  const MemberRecordsLivePage({super.key, this.member});
  @override
  State<MemberRecordsLivePage> createState() => _MemberRecordsLivePageState();
}

class _MemberRecordsLivePageState extends State<MemberRecordsLivePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.member?['id'] == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先选择会员', type: AppErrorType.notFound),
        ),
      );
    }
    final m = MemberView(widget.member!);
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 960,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: SingleSelection(
              index: _tab < 0 ? 0 : _tab,
              onChanged: _syncTab,
              builder: (context, selection) => ListenableBuilder(
                listenable: selection,
                builder: (context, _) => hcol(
                  [
                    hrow(
                      [
                        AppIconButton(
                          svg: dk(context, Svgs.s0, Svgs.s1),
                          semanticLabel: "返回",
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '消费记录',
                                style: hts(
                                  17,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${m.name} · ${m.levelMember}',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                          ),
                        ),
                        AppIconButton(
                          svg: dk(context, Svgs.s230, Svgs.s231),
                          semanticLabel: '日期筛选',
                          onPressed: () =>
                              AppToast.show(context, '日期筛选尚未接通：缺少流水日期范围接口'),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    hcol([
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFFFFFFF),
                                Color(0xFF18181B),
                              ),
                              radius: BorderRadius.circular(18),
                              shadow: dk(
                                context,
                                [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 0),
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                [
                                  BoxShadow(
                                    color: Color(0xFF26262B),
                                    offset: Offset(0, 0),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: hcol(
                                [
                                  Text(
                                    '累计消费',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                  Text(
                                    m.totalSpentText,
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFFFFFFF),
                                Color(0xFF18181B),
                              ),
                              radius: BorderRadius.circular(18),
                              shadow: dk(
                                context,
                                [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 0),
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                [
                                  BoxShadow(
                                    color: Color(0xFF26262B),
                                    offset: Offset(0, 0),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: hcol(
                                [
                                  Text(
                                    '累计充值',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                  Text(
                                    m.totalRechargedText,
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFFFFFFF),
                                Color(0xFF18181B),
                              ),
                              radius: BorderRadius.circular(18),
                              shadow: dk(
                                context,
                                [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 0),
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                [
                                  BoxShadow(
                                    color: Color(0xFF26262B),
                                    offset: Offset(0, 0),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: hcol(
                                [
                                  Text(
                                    '到店',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                  Text(
                                    m.visitText,
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 4,
                              ),
                            ),
                          ),
                        ],
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                        intrinsic: true,
                        min: false,
                      ),
                    ], gap: 8),
                    AppSegmented<int>(
                      items: [
                        SegmentItem(value: 0, label: '全部'),
                        SegmentItem(value: 1, label: '消费'),
                        SegmentItem(value: 2, label: '充值'),
                        SegmentItem(value: 3, label: '次卡'),
                      ],
                      selected: selection.selected.first,
                      onChanged: selection.tap,
                    ),
                    ..._ledger(context, selection),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [],
    );
  }

  int _request = 0;
  @override
  void didUpdateWidget(MemberRecordsLivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member?['id'] != oldWidget.member?['id']) {
      _request++;
      _items.clear();
      _total = 0;
      _tab = -1;
      _loading = false;
      _loadingMore = false;
      _showSkeleton = false;
      _skeletonAt = null;
      _error = null;
      _loaded = false;
    }
  }

  // ───────── 流水 ─────────
  final List<Map<String, dynamic>> _items = [];
  int _total = 0;
  int _tab = -1; // 0 全部 / 1 消费 / 2 充值 / 3 次卡
  bool _loading = false;
  bool _loadingMore = false;
  bool _showSkeleton = false;
  DateTime? _skeletonAt;
  AppError? _error;
  bool _loaded = false;

  String? get _memberId => widget.member?['id']?.toString();

  /// 页签变化时重新读取（构建期间只登记，下一帧再请求）。
  void _syncTab(int tab) {
    if (tab == _tab) return;
    _tab = tab;
    _showSkeleton = false;
    _skeletonAt = null;
    _error = null;
    _request++;
    _loading = false;
    _loadingMore = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load({bool more = false}) async {
    final id = _memberId;
    if (id == null || _loading || _loadingMore) return;
    // 消费 / 次卡流水还没有数据来源，不请求
    if (_tab == 1 || _tab == 3) {
      setState(() {
        _items.clear();
        _total = 0;
        _loaded = true;
        _error = null;
      });
      return;
    }
    final seq = ++_request;
    final tab = _tab;
    final hadLoaded = _loaded;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _showSkeleton = false;
      }
    });
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && seq == _request && _loading && !hadLoaded) {
        setState(() {
          _showSkeleton = true;
          _skeletonAt = DateTime.now();
        });
      }
    });
    AppError? failed;
    ({List<Map<String, dynamic>> items, int total})? page;
    try {
      page = await merchantApi.ledger(
        id,
        filter: tab == 2 ? 'recharge' : 'all',
        offset: more ? _items.length : 0,
      );
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    if (_skeletonAt != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(_skeletonAt!);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted || seq != _request || id != _memberId || tab != _tab) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      _showSkeleton = false;
      _skeletonAt = null;
      _loaded = true;
      if (failed != null) {
        if (!hadLoaded) _error = failed;
      } else {
        if (!more) _items.clear();
        _items.addAll(page!.items);
        _total = page.total;
        _error = null;
      }
    });
    if (failed != null && hadLoaded) {
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? _load : null,
      );
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// 一条流水在列表里的文字：标题 / 副标题 / 金额。
  ({String title, String sub, String amount, bool positive}) _describe(
    Map<String, dynamic> e,
  ) {
    final at = DateTime.tryParse('${e['created_at']}')?.toLocal();
    final when = at == null
        ? ''
        : '${_two(at.month)}.${_two(at.day)} ${_two(at.hour)}:${_two(at.minute)}';
    final operator = '${e['operator'] ?? ''}';
    final kind = '${e['kind']}';
    if (kind == 'recharge') {
      final gift = num.tryParse('${e['gift']}') ?? 0;
      final amount = num.tryParse('${e['amount']}') ?? 0;
      return (
        title: gift > 0 ? '储值充值 · 送 ¥${formatMoney(gift)}' : '储值充值',
        sub: [
          when,
          '${e['pay_method']}',
          if (operator.isNotEmpty) '经办 $operator',
        ].join(' · '),
        amount: '+¥${formatMoney(amount + gift)}',
        positive: true,
      );
    }
    if (kind == 'adjust_points') {
      final d = int.tryParse('${e['points_delta']}') ?? 0;
      return (
        title: '积分调整 · ${e['reason']}',
        sub: [when, if (operator.isNotEmpty) '经办 $operator'].join(' · '),
        amount: '${d >= 0 ? '+' : '-'}${formatMoney(d.abs())} 分',
        positive: d >= 0,
      );
    }
    final upgrade = kind == 'upgrade';
    return (
      title: upgrade ? '自动升级' : '调整卡种 · ${e['reason']}',
      sub: [when, if (operator.isNotEmpty) operator].join(' · '),
      amount: '${e['card_from']} → ${e['card_to']}',
      positive: false,
    );
  }

  List<Widget> _ledger(BuildContext context, SelCtrl tabs) {
    _syncTab(tabs.selected.isEmpty ? 0 : tabs.selected.first);
    if (_error != null && _items.isEmpty) {
      return [
        SizedBox(
          height: 260,
          child: ErrorView(error: _error!, retrying: _loading, onRetry: _load),
        ),
      ];
    }
    if (!_loaded) {
      return [
        _showSkeleton
            ? const SkeletonList(count: 5)
            : const SizedBox(height: 120),
      ];
    }
    if (_items.isEmpty) {
      return [
        SizedBox(
          height: 240,
          child: EmptyView(
            title: _tab == 1 || _tab == 3 ? '暂无记录' : '还没有记录',
            message: _tab == 1
                ? '开单消费后会显示在这里'
                : _tab == 3
                ? '次卡购买和使用后会显示在这里'
                : '充值、积分调整后会显示在这里',
          ),
        ),
      ];
    }
    // 按月份分组（新的在前）
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final e in _items) {
      final at = DateTime.tryParse('${e['created_at']}')?.toLocal();
      final key = at == null ? '' : '${at.year} 年 ${at.month} 月';
      groups.putIfAbsent(key, () => []).add(e);
    }
    return [
      for (final g in groups.entries) _month(context, g.key, g.value),
      if (_items.length < _total)
        Center(
          child: RequestButton(
            label: '加载更多',
            onPressed: () => _load(more: true),
            kind: AppButtonKind.secondary,
            size: AppButtonSize.large,
          ),
        ),
    ];
  }

  Widget _month(
    BuildContext context,
    String label,
    List<Map<String, dynamic>> entries,
  ) {
    num recharged = 0;
    for (final e in entries) {
      if (e['kind'] == 'recharge') {
        recharged += num.tryParse('${e['amount']}') ?? 0;
      }
    }
    final summary = recharged > 0 ? '充值 ¥${formatMoney(recharged)}' : '';
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final d = _describe(entries[i]);
      if (i > 0) {
        rows.add(
          hbox(
            h: 1,
            bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
            margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
          ),
        );
      }
      final entry = entries[i];
      // 储值充值行可以点进订单详情（充值订单）；积分 / 卡种调整不是订单
      final row = _row(context, d.title, d.sub, d.amount, d.positive);
      rows.add(
        entry['kind'] == 'recharge'
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  openRoute(
                    context,
                    'OrderDetail',
                    arguments: OrderDetailRef(
                      kind: 'recharge',
                      id: '${entry['id']}',
                    ),
                  );
                },
                child: row,
              )
            : row,
      );
    }
    return hcol(
      [
        hbox(
          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
          child: hrow(
            [
              Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: hts(
                    13,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    w: FontWeight.w500,
                    lh: 18,
                  ),
                ),
              ),
              Text(
                summary,
                style: hts(
                  13,
                  dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                  lh: 18,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.start,
            gap: 0,
          ),
        ),
        hbox(
          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
          radius: BorderRadius.circular(24),
          shadow: dk(
            context,
            [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                offset: Offset(0, 0),
                blurRadius: 1,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
            [
              BoxShadow(
                color: Color(0xFF26262B),
                offset: Offset(0, 0),
                blurRadius: 0,
                spreadRadius: 1,
              ),
            ],
          ),
          pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: hcol(
            rows,
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 8,
    );
  }

  Widget _row(
    BuildContext context,
    String title,
    String sub,
    String amount,
    bool positive,
  ) => hbox(
    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: hrow(
      [
        hbox(
          w: 40,
          h: 40,
          bg: dk(
            context,
            Color(0xFFFDEFD6),
            Color.fromRGBO(245, 165, 36, 0.16),
          ),
          radius: BorderRadius.circular(13),
          child: hrow(
            [hsvg(dk(context, Svgs.s234, Svgs.s235), w: 18, h: 18)],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            gap: 0,
          ),
        ),
        Expanded(
          flex: 1,
          child: hcol(
            [
              Text(
                title,
                style: hts(
                  14,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                  lh: 20,
                ),
              ),
              Text(
                sub,
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 16,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 2,
          ),
        ),
        Text(
          amount,
          style: hts(
            15,
            dk(
              context,
              positive ? Color(0xFF2B7745) : Color(0xFF52525B),
              positive ? Color(0xFF5FD48C) : Color(0xFFA8A8B3),
            ),
            w: FontWeight.w600,
            lh: 22,
            tab: true,
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.center,
      gap: 12,
    ),
  );
}
