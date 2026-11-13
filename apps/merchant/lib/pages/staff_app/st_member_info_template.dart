import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../resources/staff_svgs.dart';
import 'st_live.dart';
import 'st_member_route_data.dart';
import '../members/member_events.dart';
import '../../routes.dart' show openRoute;
import 'st_redeem_sheet.dart';

/// 员工端会员简况：仅服务相关、已脱敏的信息，不可修改储值与积分。
class StMemberInfoTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StMemberInfoTemplate({super.key, required this.d});

  String get _name => '${d['name'] ?? ''}';
  String get _level => '${d['level'] ?? ''}'.isEmpty ? '会员' : '${d['level']}';
  String get _phone => '${d['phone_masked'] ?? ''}';
  String get _balance => stMoney(d['balance']);
  String get _points =>
      stMoney(((d['points'] as num?) ?? 0).toInt()).substring(1);
  List<Map<String, dynamic>> get _packages => [
    for (final x in (d['packages'] as List? ?? const []))
      Map<String, dynamic>.from(x as Map),
  ];
  List<Map<String, dynamic>> get _vehicles => [
    for (final x in (d['vehicles'] as List? ?? const []))
      Map<String, dynamic>.from(x as Map),
  ];
  String get _pkgCount => '${_packages.length}';

  double _frac(Map<String, dynamic> p) {
    final total = ((p['total'] as num?) ?? 0).toDouble();
    return total <= 0
        ? 0
        : (((p['remaining'] as num?) ?? 0).toDouble() / total)
              .clamp(0, 1)
              .toDouble();
  }

  String _pct(Map<String, dynamic> p) => '${(_frac(p) * 100).round()}%';

  String _pkgSub(Map<String, dynamic> p) {
    final left = '剩余 ${((p['remaining'] as num?) ?? 0).toInt()} 次';
    final t = DateTime.tryParse('${p['expires_at'] ?? ''}')
        ?.toUtc()
        .add(const Duration(hours: 8));
    if (t == null) return '$left · 长期有效';
    String two(int n) => n.toString().padLeft(2, '0');
    return '$left · ${t.year}.${two(t.month)}.${two(t.day)} 到期';
  }

  /// 圆环：与设计稿相同的 SVG（周长 110），按剩余比例画进度。
  String _ring(Map<String, dynamic> p, bool blue) =>
      '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40" fill="none" aria-hidden="true">'
      '<circle cx="20.0" cy="20.0" r="17.5" stroke="#E4E4E7" stroke-width="5"></circle>'
      '<circle cx="20.0" cy="20.0" r="17.5" stroke="${blue ? '#0485F7' : '#F5A524'}" stroke-width="5" stroke-linecap="round" '
      'stroke-dasharray="${(110 * _frac(p)).toStringAsFixed(1)} 110.0"></circle></svg>';

  String _plate(Map<String, dynamic> v) => '${v['plate'] ?? ''}';
  String _model(Map<String, dynamic> v) {
    final parts = [
      '${v['model'] ?? ''}',
      '${v['color'] ?? ''}',
    ].where((e) => e.isNotEmpty);
    return parts.isEmpty ? '未登记车型' : parts.join(' · ');
  }

  Widget _pkgRow(BuildContext context, int i, Map<String, dynamic> p) =>
      i.isEven
      ? hrow(
          [
            hbox(
              w: 40,
              h: 40,
              bg: dk(
                context,
                Color(0xFFE1F0FE),
                Color.fromRGBO(4, 133, 247, 0.18),
              ),
              radius: BorderRadius.circular(13),
              child: hrow(
                [hsvg(dk(context, Svgs.s55, Svgs.s56), w: 20, h: 20)],
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
                    '${p['name'] ?? ''}',
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                  ),
                  Text(
                    _pkgSub(p),
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 17,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 2,
              ),
            ),
            hbox(
              w: 40,
              h: 40,
              child: hstack(
                hrow(
                  [
                    Flexible(
                      flex: 18,
                      child: Text(
                        _pct(p),
                        style: hts(
                          11,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                [],
                behind: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IntrinsicWidth(
                      child: hsvg(_ring(p, true), w: 40, h: 40),
                    ),
                  ),
                ],
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 10,
        )
      : hrow(
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
                [hsvg(dk(context, Svgs.s58, Svgs.s59), w: 20, h: 20)],
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
                    '${p['name'] ?? ''}',
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                  ),
                  Text(
                    _pkgSub(p),
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 17,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 2,
              ),
            ),
            hbox(
              w: 40,
              h: 40,
              child: hstack(
                hrow(
                  [
                    Flexible(
                      flex: 18,
                      child: Text(
                        _pct(p),
                        style: hts(
                          11,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                [],
                behind: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IntrinsicWidth(
                      child: hsvg(_ring(p, false), w: 40, h: 40),
                    ),
                  ),
                ],
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 10,
        );

  Widget _vehRow(BuildContext context, int i, Map<String, dynamic> v) =>
      i.isEven
      ? hbox(
          minH: 60,
          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: hrow(
            [
              hbox(
                w: 32,
                h: 32,
                bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s61, Svgs.s62), w: 18, h: 18)],
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
                      _plate(v),
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 22,
                      ),
                    ),
                    Text(
                      _model(v),
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 1,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 12,
          ),
        )
      : hbox(
          minH: 60,
          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: hrow(
            [
              hbox(
                w: 32,
                h: 32,
                bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s61, Svgs.s62), w: 18, h: 18)],
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
                      _plate(v),
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 22,
                      ),
                    ),
                    Text(
                      _model(v),
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 1,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 12,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
            child: hcol(
              [
                hrow(
                  [
                    hbox(
                      w: 87,
                      child: hrow(
                        [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: AppIconButton(
                              svg: dk(context, Svgs.s0, Svgs.s1),
                              semanticLabel: "返回",
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                        intrinsic: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '会员简况',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 87),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [
                      Color(0xFF26262C),
                      Color(0xFF18181B),
                      Color(0xFF2B2418),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  bg: Color(0xFFF5D78E),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    _level,
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  _name,
                                  style: hts(
                                    16,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w600,
                                    lh: 23,
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                Text(
                                  _phone,
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                        hcol(
                          [
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        _balance,
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '余额',
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
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        _points,
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '积分',
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
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        _pkgCount,
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '次卡',
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
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.start,
                              gap: 0,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [
                      Positioned(
                        top: 24,
                        right: -6,
                        child: IntrinsicWidth(
                          child: hbox(
                            opacity: .3,
                            child: hcol(
                              [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: hsvg(Svgs.s54, w: 80, h: 30),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                    behind: [
                      Positioned(
                        top: -120,
                        right: -120,
                        child: IntrinsicWidth(
                          child: hsvg(Svgs.s2, w: 260, h: 260),
                        ),
                      ),
                      Positioned(
                        top: -100,
                        right: -80,
                        width: 260,
                        height: 260,
                        child: hbox(
                          w: 260,
                          h: 260,
                          radius: BorderRadius.circular(130),
                        ),
                      ),
                    ],
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '次卡',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          if (_packages.isEmpty)
                            Text(
                              '暂无可用次卡',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 18,
                              ),
                            ),
                          for (var i = 0; i < _packages.length; i++)
                            _pkgRow(context, i, _packages[i]),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '爱车',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
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
                        [
                          if (_vehicles.isEmpty)
                            Text(
                              '暂无登记车辆',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 18,
                              ),
                            ),
                          for (var i = 0; i < _vehicles.length; i++) ...[
                            if (i > 0)
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                              ),
                            _vehRow(context, i, _vehicles[i]),
                          ],
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hbox(
                  bg: dk(
                    context,
                    Color(0xFFFDEFD6),
                    Color.fromRGBO(245, 165, 36, 0.16),
                  ),
                  radius: BorderRadius.circular(18),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Text(
                    '员工端仅展示服务相关信息，不可修改储值与积分。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)),
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
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFE4E4E7),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF3A3A40),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hcol(
              [
                hrow(
                  [
                    Expanded(
                      flex: 10,
                      child: AppButton(
                        label: '次卡核销',
                        kind: AppButtonKind.secondary,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: () => showStRedeemSheet(context, d),
                      ),
                    ),
                    Expanded(
                      flex: 14,
                      child: AppButton(
                        label: '为他开单',
                        kind: AppButtonKind.primary,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: () => openRoute(
                          context,
                          'StOrder',
                          arguments: StMemberRouteData('${d['id']}'),
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 10,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// 会员简况：读取「会员查询」里选中的会员。
class StMemberInfoLivePage extends StatelessWidget {
  final String? memberId;
  const StMemberInfoLivePage({super.key, this.memberId});

  @override
  Widget build(BuildContext context) => StLive(
    key: ValueKey(memberId),
    title: '会员简况',
    refresh: memberChanged,
    load: () {
      final id = memberId;
      if (id == null) {
        return Future.error(
          const AppError('请先选择会员', type: AppErrorType.notFound),
        );
      }
      return merchantApi.staffWork('staff_member_info', {'id': id});
    },
    builder: (_, d) => StMemberInfoTemplate(d: d),
  );
}
