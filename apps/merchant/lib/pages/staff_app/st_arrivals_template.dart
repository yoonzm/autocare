import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../resources/staff_svgs.dart';
import 'st_live.dart';

class StArrivalsTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StArrivalsTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final x in (d['items'] as List? ?? const []))
        Map<String, dynamic>.from(x as Map),
    ];
    final arrived = items.where((x) => x['status'] != 'waiting').length;
    final waiting = items.length - arrived;
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 40),
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
                        '今日到店',
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
                  pad: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hcol(
                          [
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '今日预约',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 19,
                                        ),
                                      ),
                                      Text(
                                        '${items.length} 位车主',
                                        style: hts(
                                          22,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 30,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                hcol(
                                  [
                                    Text(
                                      '已到店 $arrived',
                                      style: hts(
                                        12,
                                        Color(0xFF6EE7A8),
                                        w: FontWeight.w500,
                                        lh: 17,
                                      ),
                                    ),
                                    Text(
                                      '待到店 $waiting',
                                      style: hts(
                                        12,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w500,
                                        lh: 17,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.end,
                                  gap: 4,
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
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -116,
                        right: -120,
                        child: IntrinsicWidth(
                          child: hsvg(Svgs.s2, w: 260, h: 260),
                        ),
                      ),
                      Positioned(
                        top: -96,
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
                if (items.isEmpty)
                  hbox(
                    minH: 64,
                    align: Alignment.center,
                    child: Text(
                      '今日暂无预约',
                      style: hts(
                        13,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ),
                for (final t in items)
                  hrow(
                    [
                      hbox(
                        w: 48,
                        pad: EdgeInsets.fromLTRB(0, 14, 0, 0),
                        child: Text(
                          stClock(t['starts_at']),
                          style: hts(15, Color(0xFF0485F7), w: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(20),
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
                              hrow(
                                [
                                  hbox(
                                    grad: LinearGradient(
                                      begin: Alignment(-0, -1),
                                      end: Alignment(0, 1),
                                      colors: stPlateGreen(t['plate'])
                                          ? [
                                              Color(0xFFE9FBEF),
                                              Color(0xFFB8F0CB),
                                            ]
                                          : [
                                              Color(0xFF2F73F2),
                                              Color(0xFF1A4FC4),
                                            ],
                                      stops: [0, 1],
                                    ),
                                    radius: BorderRadius.circular(5),
                                    shadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.08),
                                        offset: Offset(0, 0),
                                        blurRadius: 0,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        0.75,
                                      ),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
                                    child: Text(
                                      stPlateOf(t),
                                      style: hts(
                                        12,
                                        stPlateGreen(t['plate'])
                                            ? Color(0xFF14532D)
                                            : Color(0xFFFFFFFF),
                                        w: FontWeight.w600,
                                        lh: 18,
                                        ls: 0.5,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Expanded(flex: 1, child: SizedBox.shrink()),
                                  hbox(
                                    bg: t['status'] == 'waiting'
                                        ? dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          )
                                        : dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                    radius: BorderRadius.circular(9),
                                    pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: Text(
                                      t['status'] == 'waiting'
                                          ? '待到店'
                                          : (t['status'] == 'done'
                                                ? '已完成'
                                                : '已到店'),
                                      style: hts(
                                        11,
                                        t['status'] == 'waiting'
                                            ? dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              )
                                            : dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
                                              ),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                              Text(
                                stItemsOf(t),
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                              Text(
                                '客户 ${t['customer']} · ${t['level']}',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                    intrinsic: true,
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

/// 今日到店：门店当天的预约（需要「今日到店」权限，服务端校验）。
class StArrivalsLivePage extends StatelessWidget {
  const StArrivalsLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '今日到店',
    load: () => merchantApi.staffWork('staff_arrivals'),
    builder: (_, d) => StArrivalsTemplate(d: d),
  );
}
