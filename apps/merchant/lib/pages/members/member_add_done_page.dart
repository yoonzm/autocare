import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_view.dart';
import 'member_route_data.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class MemberAddDonePage extends StatelessWidget {
  final Map<String, dynamic>? member;
  const MemberAddDonePage({super.key, this.member});

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先完成办卡', type: AppErrorType.notFound),
        ),
      );
    }
    final m = MemberView(member!);
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1144,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
            child: hcol(
              [
                hrow(
                  [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                      child: hbox(
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
                          [hsvg(dk(context, Svgs.s26, Svgs.s27), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(0, 26, 0, 6),
                  child: hstack(
                    hcol(
                      [
                        hbox(
                          w: 128,
                          h: 128,
                          child: hstack(
                            hrow(
                              [
                                hbox(
                                  w: 76,
                                  h: 76,
                                  grad: LinearGradient(
                                    begin: Alignment(-0.342, -0.94),
                                    end: Alignment(0.342, 0.94),
                                    colors: [
                                      Color(0xFF3BDC86),
                                      Color(0xFF17C964),
                                    ],
                                    stops: [0, 1],
                                  ),
                                  radius: BorderRadius.circular(38),
                                  shadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(23, 201, 100, 0.35),
                                      offset: Offset(0, 10),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  child: hrow(
                                    [hsvg(Svgs.s29, w: 40, h: 40)],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                            [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: hsvg(Svgs.s28, w: 128, h: 128),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '开卡成功',
                          style: hts(
                            21,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                        ),
                        Text(
                          '已为${m.honorificName}建立会员档案，当前为${m.levelMember}',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 19,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    [],
                    behind: [
                      Positioned(
                        left: 38,
                        top: 4,
                        width: 8,
                        height: 8,
                        child: hbox(
                          w: 8,
                          h: 8,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4),
                        ),
                      ),
                      Positioned(
                        left: 300,
                        top: 26,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 124,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Positioned(
                        left: 318,
                        top: 114,
                        width: 9,
                        height: 9,
                        child: hbox(
                          w: 9,
                          h: 9,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4.5),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 74,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 344,
                        top: 72,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
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
                  clip: true,
                  child: hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(18, 18, 18, 8),
                        child: hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  w: 48,
                                  h: 48,
                                  grad: LinearGradient(
                                    begin: Alignment(-0.5, -0.866),
                                    end: Alignment(0.5, 0.866),
                                    colors: [
                                      Color(0xFFFFF1CF),
                                      Color(0xFFF5D78E),
                                    ],
                                    stops: [0, 1],
                                  ),
                                  radius: BorderRadius.circular(24),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    m.avatar,
                                    style: hts(
                                      19,
                                      Color(0xFF5C3D0A),
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      hrow(
                                        [
                                          Flexible(
                                            flex: 48,
                                            child: Text(
                                              m.honorificName,
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 23,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 60,
                                            child: hbox(
                                              bg: dk(
                                                context,
                                                Color(0xFFEEEEF0),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(9),
                                              pad: EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                8,
                                                0,
                                              ),
                                              child: Text(
                                                m.levelMember,
                                                style: hts(
                                                  11,
                                                  dk(
                                                    context,
                                                    Color(0xFF3F3F46),
                                                    Color(0xFFD4D4D8),
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
                                        gap: 8,
                                      ),
                                      Text(
                                        m.maskedPhone,
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
                                    gap: 3,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                            NegMargin(
                              top: 0,
                              left: -16,
                              child: hbox(
                                margin: EdgeInsets.fromLTRB(0, 14, 0, 0),
                                child: hcol(
                                  [
                                    hbox(
                                      minH: 26,
                                      pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                      child: hrow(
                                        [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '当前权益',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                lh: 20,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            m.benefits,
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 12,
                                      ),
                                    ),
                                    hbox(
                                      minH: 26,
                                      pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                      child: hrow(
                                        [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '开卡时间',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                lh: 20,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            m.openedAt,
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 12,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 12,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                      ),
                      hbox(
                        h: 20,
                        child: hstack(
                          hcol(
                            [],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                            min: false,
                          ),
                          [
                            Positioned(
                              left: -10,
                              top: 0,
                              width: 20,
                              height: 20,
                              child: hbox(
                                w: 20,
                                h: 20,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: -10,
                              width: 20,
                              height: 20,
                              child: hbox(
                                w: 20,
                                h: 20,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 10,
                              right: 16,
                              child: hbox(
                                dashed: true,
                                dashColor: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                                dashWidth: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(18, 6, 18, 18),
                        child: hcol(
                          [
                            hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s209, Svgs.s210),
                                  w: 72,
                                  h: 27,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: hbox(
                                          grad: LinearGradient(
                                            begin: Alignment(-0, -1),
                                            end: Alignment(0, 1),
                                            colors: [
                                              Color(0xFF2F73F2),
                                              Color(0xFF1A4FC4),
                                            ],
                                            stops: [0, 1],
                                          ),
                                          radius: BorderRadius.circular(5),
                                          shadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.08,
                                              ),
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
                                            m.plate,
                                            style: hts(
                                              12,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 18,
                                              ls: 0.5,
                                            ),
                                            softWrap: false,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        m.vehicleModel,
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 19,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    m.vehicleLabel,
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
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
                              gap: 12,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openRoute(
                      context,
                      'MemberDetail',
                      arguments: MemberRouteData(member: member),
                    ),
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '查看会员',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      openRoute(
                        context,
                        'Recharge',
                        arguments: MemberRouteData(member: member),
                      );
                    },
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '去充值',
                          style: hts(
                            15,
                            dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}
