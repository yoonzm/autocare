// Data-bound copy of the designed CardPackagesPage. Keep its layout in sync
// with the design; only record text and callbacks vary.
// TODO: 经营概览（本月营收 / 售出 / 在用 / 将到期）与“已售 N”依赖次卡售卖，属于订单 / 会员模块，
// V1 不接入：概览显示“—”，列表不显示销量。预期后端接口：merchant-v1 `package_stats`。
import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/merchant_api.dart';
import '../backend/package_calc.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart';
import 'gen/svgs.dart';

class CardPackagesLivePage extends StatefulWidget {
  const CardPackagesLivePage({super.key});
  @override
  State<CardPackagesLivePage> createState() => _CardPackagesLivePageState();
}

class _CardPackagesLivePageState extends State<CardPackagesLivePage> {
  List<Map<String, dynamic>>? _rows;
  AppError? error;
  bool loading = false;

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
    AppError? failed;
    try {
      rows = await merchantApi.list('packages');
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
        _rows = rows;
        CatalogCounts.packages = rows!.length;
        error = null;
      } else if (_rows == null) {
        error = failed;
      }
    });
    // 已有旧数据时刷新失败：只弹 Toast（可重试），不替换页面内容
    if (failed != null && _rows != null) {
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? _load : null,
      );
    }
  }

  void _add() {
    CatalogDraft.begin('packages');
    openRoute(context, 'PackageEdit');
  }

  bool get _hasRows => _rows != null && _rows!.isNotEmpty;

  /// 套餐列表区：加载（骨架）/ 错误（重试）/ 空（引导新建）/ 内容。
  Widget _listArea(BuildContext context) {
    final rows = _rows;
    if (rows == null) {
      if (error != null) {
        return SizedBox(
          height: 300,
          child: ErrorView(error: error!, retrying: loading, onRetry: _load),
        );
      }
      return showSkeleton
          ? const SkeletonList(count: 5)
          : const SizedBox(height: 120);
    }
    if (rows.isEmpty) {
      return SizedBox(
        height: 280,
        child: EmptyView.firstTime(
          title: '还没有次卡套餐',
          message: '新建第一个套餐，把常用服务打包出售',
          actionLabel: '新建套餐',
          onAction: _add,
        ),
      );
    }
    return Opacity(
      opacity: loading && showSkeleton ? 0.6 : 1,
      child: hbox(
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
          [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                hbox(
                  h: 1,
                  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                  margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                ),
              _rowTile(context, rows[i]),
            ],
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 0,
        ),
      ),
    );
  }

  Widget _rowTile(BuildContext context, Map<String, dynamic> row) {
    final info = PackageRowInfo(row);
    return hTap(
      context,
      hbox(
        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
        opacity: info.active ? 1 : .62,
        child: hrow(
          [
            hbox(
              w: 44,
              h: 44,
              bg: dk(
                context,
                info.active ? Color(0xFFE1F0FE) : Color(0xFFFFE1E2),
                info.active
                    ? Color.fromRGBO(4, 133, 247, 0.18)
                    : Color.fromRGBO(255, 56, 60, 0.18),
              ),
              radius: BorderRadius.circular(14),
              child: hrow(
                [
                  hsvg(
                    info.active
                        ? dk(context, Svgs.s61, Svgs.s62)
                        : dk(context, Svgs.s69, Svgs.s70),
                    w: 22,
                    h: 22,
                  ),
                ],
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                gap: 0,
              ),
            ),
            Expanded(
              flex: 1,
              child: hbox(
                minW: 0,
                child: hcol(
                  [
                    hrow(
                      [
                        Flexible(
                          flex: 90,
                          child: Text(
                            '${row['name'] ?? ''}',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    Text(
                      info.subtitle,
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 17,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 3,
                ),
              ),
            ),
            hcol(
              [
                Text(
                  info.priceText,
                  style: hts(
                    16,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 22,
                  ),
                ),
                hrow(
                  [
                    if (info.showOriginal)
                      Flexible(
                        flex: 37,
                        child: Text(
                          info.originalText,
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 16,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    Flexible(
                      flex: 49,
                      child: hbox(
                        bg: dk(
                          context,
                          info.active ? Color(0xFFDDF6E7) : Color(0xFFEEEEF0),
                          info.active
                              ? Color.fromRGBO(23, 201, 100, 0.16)
                              : Color(0xFF27272A),
                        ),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          info.active ? '上架中' : '已下架',
                          style: hts(
                            11,
                            dk(
                              context,
                              info.active
                                  ? Color(0xFF2B7745)
                                  : Color(0xFF52525B),
                              info.active
                                  ? Color(0xFF5FD48C)
                                  : Color(0xFFA8A8B3),
                            ),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 6,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.end,
              gap: 3,
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      ),
      onTap: () {
        CatalogDraft.begin('packages', row);
        openRoute(context, 'PackageEdit');
      },
    );
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
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 40),
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
                          [hsvg(dk(context, Svgs.s58, Svgs.s59), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      onTap: _add,
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
                          child: hTap(
                            context,
                            hbox(
                              h: 34,
                              radius: BorderRadius.circular(17),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  tabLabel('等级储值卡', CatalogCounts.cards),
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
                            to: 'CardTiers',
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
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  tabLabel('次卡套餐', _rows?.length),
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
                if (_hasRows) ...[
                  hbox(
                    grad: LinearGradient(
                      begin: Alignment(-0.5, -0.866),
                      end: Alignment(0.5, 0.866),
                      colors: [
                        Color(0xFF2A2A30),
                        Color(0xFF18181B),
                        Color(0xFF121214),
                      ],
                      stops: [0, 0.6, 1],
                    ),
                    radius: BorderRadius.circular(28),
                    shadow: [
                      BoxShadow(
                        color: Color.fromRGBO(24, 24, 27, 0.16),
                        offset: Offset(0, 10),
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                    ],
                    pad: EdgeInsets.fromLTRB(18, 18, 18, 18),
                    clip: true,
                    child: hstack(
                      hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '本月次卡营收',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 17,
                                      ),
                                    ),
                                    Text(
                                      '—',
                                      style: hts(
                                        32,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 38,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              hbox(
                                bg: Color.fromRGBO(23, 201, 100, 0.18),
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  '—',
                                  style: hts(
                                    11,
                                    Color(0xFF5FD48C),
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.end,
                            gap: 0,
                          ),
                          hbox(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFF2E2E33),
                                width: 1,
                              ),
                            ),
                            pad: EdgeInsets.fromLTRB(0, 12, 0, 0),
                            child: hcol([
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text(
                                          '本月售出',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                          ),
                                        ),
                                        Text(
                                          '—',
                                          style: hts(
                                            16,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 24,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 1,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text(
                                          '在用次卡',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                          ),
                                        ),
                                        Text(
                                          '—',
                                          style: hts(
                                            16,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 24,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 1,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text(
                                          '将到期',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                          ),
                                        ),
                                        Text(
                                          '—',
                                          style: hts(
                                            16,
                                            Color(0xFFF5A524),
                                            w: FontWeight.w600,
                                            lh: 24,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 1,
                                    ),
                                  ),
                                ],
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                                intrinsic: true,
                                min: false,
                              ),
                            ], gap: 8),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
                      ),
                      [],
                      behind: [
                        // 设计稿 top -100 / right -80，容器内边距 18
                        Positioned(
                          top: -118,
                          right: -98,
                          child: hsvg(Svgs.s60, w: 220, h: 220),
                        ),
                      ],
                    ),
                  ),
                ],
                _listArea(context),
                if (_hasRows)
                  hbox(
                    pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      '次卡在开单时按项目自动抵扣；到期未用完的次数作废，如需延期可在会员的次卡详情里操作。',
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
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
}
