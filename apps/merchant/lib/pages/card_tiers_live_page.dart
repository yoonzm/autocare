// Data-bound copy of the designed CardTiersPage. Keep its card templates and
// layout in sync with the design; only record text and callbacks vary.
import 'dart:async';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../backend/merchant_api.dart';
import '../backend/catalog_draft.dart';
import '../routes.dart';
import '../widgets/card_face.dart';
import 'gen/svgs.dart';

class CardTiersLivePage extends StatefulWidget {
  const CardTiersLivePage({super.key});
  @override
  State<CardTiersLivePage> createState() => _CardTiersLivePageState();
}

class _CardTiersLivePageState extends State<CardTiersLivePage> {
  List<Map<String, dynamic>>? cards;
  AppError? error;
  bool loading = false;

  /// 通用规则（来自后端，保存后即时生效）。
  bool autoUpgrade = true;
  bool balanceRefundable = false;
  bool _savingRule = false;

  /// 请求超过 300ms 才显示骨架；出现后至少停留 500ms。
  bool showSkeleton = false;
  DateTime? _skeletonAt;

  @override
  void initState() {
    super.initState();
    CatalogDraft.changed.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    CatalogDraft.changed.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!merchantApi.hasSession || loading) return;
    setState(() {
      loading = true;
      showSkeleton = false;
      _skeletonAt = null;
    });
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && loading) {
        setState(() {
          showSkeleton = true;
          _skeletonAt = DateTime.now();
        });
      }
    });
    List<Map<String, dynamic>>? rows;
    ({bool autoUpgrade, bool balanceRefundable})? rules;
    AppError? failed;
    try {
      // 卡种和通用规则一起加载；任何一个失败都算加载失败
      final results = await Future.wait<Object>([
        merchantApi.list('cards'),
        merchantApi.cardRules(),
      ]);
      rows = results[0] as List<Map<String, dynamic>>;
      rules = results[1] as ({bool autoUpgrade, bool balanceRefundable});
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    final at = _skeletonAt;
    if (at != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(at);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted) return;
    setState(() {
      loading = false;
      showSkeleton = false;
      if (failed == null) {
        cards = rows;
        CatalogCounts.cards = rows!.length;
        autoUpgrade = rules!.autoUpgrade;
        balanceRefundable = rules.balanceRefundable;
        error = null;
      } else if (cards == null) {
        error = failed;
      }
    });
    // 已有旧数据时刷新失败：只弹 Toast（可重试），不替换页面内容
    if (failed != null && cards != null) {
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? _load : null,
      );
    }
  }

  /// 通用规则只在已经加载出卡种时显示：加载中、失败、还没有卡种时都不显示。
  bool get _showRules => cards != null && cards!.isNotEmpty;

  /// 乐观更新：先改界面，保存失败回滚并用 Toast 说明原因。
  Future<void> _saveRule({bool? autoUpgrade, bool? balanceRefundable}) async {
    if (_savingRule) return;
    _savingRule = true;
    final before = (auto: this.autoUpgrade, refund: this.balanceRefundable);
    final next = (
      auto: autoUpgrade ?? this.autoUpgrade,
      refund: balanceRefundable ?? this.balanceRefundable,
    );
    setState(() {
      this.autoUpgrade = next.auto;
      this.balanceRefundable = next.refund;
    });
    try {
      await merchantApi.saveCardRules(
        autoUpgrade: next.auto,
        balanceRefundable: next.refund,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          this.autoUpgrade = before.auto;
          this.balanceRefundable = before.refund;
        });
        AppToast.error(context, e);
      }
    } finally {
      _savingRule = false;
    }
  }

  void _addCard() {
    CatalogDraft.begin('cards');
    openRoute(context, 'CardTierEdit');
  }

  /// 卡种列表区：加载（骨架）/ 错误（重试）/ 空（引导新建）/ 内容。
  List<Widget> _listArea(BuildContext context) {
    final rows = cards;
    if (rows == null) {
      if (error != null) {
        return [
          SizedBox(
            height: 300,
            child: ErrorView(error: error!, retrying: loading, onRetry: _load),
          ),
        ];
      }
      return [
        showSkeleton
            ? const SkeletonList(count: 5)
            : const SizedBox(height: 120),
      ];
    }
    if (rows.isEmpty) {
      return [
        SizedBox(
          height: 280,
          child: EmptyView.firstTime(
            title: '还没有会员卡种',
            message: '新建第一个卡种，设置各项目折扣',
            actionLabel: '新建卡种',
            onAction: _addCard,
          ),
        ),
      ];
    }
    return [
      if (loading && showSkeleton) const LinearProgressIndicator(minHeight: 2),
      for (var i = 0; i < rows.length; i++)
        Opacity(
          opacity: loading && showSkeleton ? 0.6 : 1,
          child: _cardTile(context, rows[i], i),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      // 高度跟随内容：内容不够一屏时不滚动（设计稿的固定高度只是示例）
      height: 0,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: hcol(
              [
                hrow(
                  [
                    hTap(
                      context,
                      hbox(
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(22),
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
                        child: hrow(
                          [hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      back: true,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '会员卡种与权益',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hTap(
                      context,
                      hbox(
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        radius: BorderRadius.circular(22),
                        child: hrow(
                          [hsvg(dk(context, Svgs.s81, Svgs.s82), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      onTap: () {
                        CatalogDraft.begin('cards');
                        openRoute(context, 'CardTierEdit');
                      },
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: HToggle(
                            initial: true,
                            on: hbox(
                              h: 34,
                              bg: dk(
                                context,
                                Color(0xFFFFFFFF),
                                Color(0xFF18181B),
                              ),
                              radius: BorderRadius.circular(17),
                              shadow: dk(
                                context,
                                [
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
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  tabLabel('等级储值卡', cards?.length),
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ),
                            off: hbox(
                              h: 32,
                              radius: BorderRadius.circular(16),
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  tabLabel('等级储值卡', cards?.length),
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: hTap(
                            context,
                            hbox(
                              h: 34,
                              radius: BorderRadius.circular(17),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  tabLabel('次卡套餐', CatalogCounts.packages),
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ),
                            to: 'CardPackages',
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                    intrinsic: true,
                  ),
                ),
                ..._listArea(context),
                if (_showRules)
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
                    pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: hcol(
                      [
                        Text(
                          '通用规则',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '充值或消费自动升级',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                  Text(
                                    '单次充值或累计消费达标，实时升级，取最高等级',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 0,
                              ),
                            ),
                            HSwitch(
                              initial: autoUpgrade,
                              value: autoUpgrade,
                              onChanged: (v) => _saveRule(autoUpgrade: v),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                        hbox(
                          h: 1,
                          bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '储值余额可退款',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                  Text(
                                    '退款时扣除已赠送金额',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 0,
                              ),
                            ),
                            HSwitch(
                              initial: balanceRefundable,
                              value: balanceRefundable,
                              onChanged: (v) => _saveRule(balanceRefundable: v),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 12,
                    ),
                  ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 16,
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

  Widget _cardTile(BuildContext context, Map<String, dynamic> row, int index) =>
      CardTileFace(
        row: row,
        onTap: () {
          CatalogDraft.begin('cards', row);
          openRoute(context, 'CardTierEdit');
        },
      );
}
