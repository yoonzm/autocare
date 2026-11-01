// Data-bound copy of the designed CardTiersPage. Keep its card templates and
// layout in sync with the design; only record text and callbacks vary.
import 'package:flutter/material.dart';

import '../kit/kit.dart';
import '../backend/merchant_api.dart';
import '../backend/catalog_draft.dart';
import '../routes.dart';
import 'gen/svgs.dart';

class CardTiersLivePage extends StatefulWidget {
  const CardTiersLivePage({super.key});
  @override
  State<CardTiersLivePage> createState() => _CardTiersLivePageState();
}

class _CardTiersLivePageState extends State<CardTiersLivePage> {
  List<Map<String, dynamic>>? cards;
  bool loadFailed = false;
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
    if (!merchantApi.hasSession) return;
    try {
      final rows = await merchantApi.list('cards');
      if (mounted) {
        setState(() {
          cards = rows;
          loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loadFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1000,
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
                                  '等级储值卡 ${cards?.length ?? 0}',
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
                                  '等级储值卡 ${cards?.length ?? 0}',
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
                                  '次卡套餐 6',
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
                if (loadFailed)
                  hTap(context, const Text('卡种加载失败，点击重试'), onTap: _load),
                for (var i = 0; i < (cards ?? []).length; i++)
                  _cardTile(context, cards![i], i),
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
                          HSwitch(initial: true),
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
                          HSwitch(initial: false),
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

  String _discount(Map<String, dynamic> row) {
    final value = (num.tryParse(row['discount'].toString()) ?? 1) * 10;
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  Widget _cardTile(BuildContext context, Map<String, dynamic> row, int index) {
    if (index % 4 == 0) {
      return hTap(
        context,
        hbox(
          bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
          radius: BorderRadius.circular(24),
          pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
          clip: true,
          child: hstack(
            hcol(
              [
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        row['name']?.toString() ?? '',
                        style: hts(
                          18,
                          Color(0xFFF5D78E),
                          w: FontWeight.w600,
                          lh: 26,
                          ls: 0.72,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        style: hts(
                          26,
                          Color(0xFFF5D78E),
                          w: FontWeight.w600,
                          lh: 30,
                        ),
                        children: [
                          TextSpan(
                            text: _discount(row),
                            style: hts(
                              26,
                              Color(0xFFF5D78E),
                              w: FontWeight.w600,
                              lh: 30,
                            ),
                          ),
                          TextSpan(
                            text: ' 折',
                            style: hts(
                              14,
                              Color(0xFFF5D78E),
                              w: FontWeight.w600,
                              lh: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.baseline,
                  gap: 8,
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        row['description']?.toString().isNotEmpty == true
                            ? row['description'].toString()
                            : '会员卡权益',
                        style: hts(12, Color(0xFFD4D4D8), lh: 16),
                      ),
                    ),
                    Text(
                      '0 人',
                      style: hts(
                        12,
                        Color(0xFFFAFAFA),
                        w: FontWeight.w600,
                        lh: 16,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 22,
            ),
            [],
            behind: [
              Positioned(
                top: -80,
                right: -60,
                child: hsvg(dk(context, Svgs.s83, Svgs.s84), w: 200, h: 200),
              ),
            ],
          ),
        ),
        onTap: () {
          CatalogDraft.begin('cards', row);
          openRoute(context, 'CardTierEdit');
        },
      );
    }
    if (index % 4 == 1) {
      return hTap(
        context,
        hbox(
          bg: Color(0xFFF3E2B3),
          radius: BorderRadius.circular(24),
          pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: hcol(
            [
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['name']?.toString() ?? '',
                      style: hts(
                        18,
                        Color(0xFF3D2B0E),
                        w: FontWeight.w600,
                        lh: 26,
                        ls: 0.72,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      style: hts(
                        26,
                        Color(0xFF3D2B0E),
                        w: FontWeight.w600,
                        lh: 30,
                      ),
                      children: [
                        TextSpan(
                          text: _discount(row),
                          style: hts(
                            26,
                            Color(0xFF3D2B0E),
                            w: FontWeight.w600,
                            lh: 30,
                          ),
                        ),
                        TextSpan(
                          text: ' 折',
                          style: hts(
                            14,
                            Color(0xFF3D2B0E),
                            w: FontWeight.w600,
                            lh: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.baseline,
                gap: 8,
              ),
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['description']?.toString().isNotEmpty == true
                          ? row['description'].toString()
                          : '会员卡权益',
                      style: hts(12, Color(0xFF5C4520), lh: 16),
                    ),
                  ),
                  Text(
                    '0 人',
                    style: hts(
                      12,
                      Color(0xFF3D2B0E),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 8,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 22,
          ),
        ),
        onTap: () {
          CatalogDraft.begin('cards', row);
          openRoute(context, 'CardTierEdit');
        },
      );
    }
    if (index % 4 == 2) {
      return hTap(
        context,
        hbox(
          bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
          radius: BorderRadius.circular(24),
          pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: hcol(
            [
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['name']?.toString() ?? '',
                      style: hts(
                        18,
                        dk(context, Color(0xFF27272A), Color(0xFFD4D4D8)),
                        w: FontWeight.w600,
                        lh: 26,
                        ls: 0.72,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      style: hts(
                        26,
                        dk(context, Color(0xFF27272A), Color(0xFFD4D4D8)),
                        w: FontWeight.w600,
                        lh: 30,
                      ),
                      children: [
                        TextSpan(
                          text: _discount(row),
                          style: hts(
                            26,
                            dk(context, Color(0xFF27272A), Color(0xFFD4D4D8)),
                            w: FontWeight.w600,
                            lh: 30,
                          ),
                        ),
                        TextSpan(
                          text: ' 折',
                          style: hts(
                            14,
                            dk(context, Color(0xFF27272A), Color(0xFFD4D4D8)),
                            w: FontWeight.w600,
                            lh: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.baseline,
                gap: 8,
              ),
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['description']?.toString().isNotEmpty == true
                          ? row['description'].toString()
                          : '会员卡权益',
                      style: hts(
                        12,
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                        lh: 16,
                      ),
                    ),
                  ),
                  Text(
                    '0 人',
                    style: hts(
                      12,
                      dk(context, Color(0xFF27272A), Color(0xFFD4D4D8)),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 8,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 22,
          ),
        ),
        onTap: () {
          CatalogDraft.begin('cards', row);
          openRoute(context, 'CardTierEdit');
        },
      );
    }
    if (index % 4 == 3) {
      return hTap(
        context,
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
          pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: hcol(
            [
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['name']?.toString() ?? '',
                      style: hts(
                        18,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
                        lh: 26,
                        ls: 0.72,
                      ),
                    ),
                  ),
                  Text(
                    _discount(row) == '10' ? '原价' : '${_discount(row)} 折',
                    style: hts(
                      15,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      w: FontWeight.w500,
                      lh: 30,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.baseline,
                gap: 8,
              ),
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      row['description']?.toString().isNotEmpty == true
                          ? row['description'].toString()
                          : '会员卡权益',
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                  ),
                  Text(
                    '0 人',
                    style: hts(
                      12,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 8,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 22,
          ),
        ),
        onTap: () {
          CatalogDraft.begin('cards', row);
          openRoute(context, 'CardTierEdit');
        },
      );
    }
    throw StateError("Invalid card style");
  }
}
