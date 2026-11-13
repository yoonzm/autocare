import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import '../../backend/registration_data.dart';
import '../../routes.dart' show openRoute;
import '../../resources/merchant_svgs.dart';

class RegDonePage extends StatelessWidget {
  final RegistrationReceipt? receipt;
  const RegDonePage({super.key, this.receipt});

  @override
  Widget build(BuildContext context) {
    if (receipt == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先完成注册开通'),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return PopScope(
      canPop: false,
      child: HPage(
        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
        height: 883,
        fixedHeight: false,
        flow: hcol(
          [
            hbox(
              pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
              child: hcol(
                [
                  hrow(
                    [
                      hbox(w: 44),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '欢迎使用',
                          style: hts(
                            17,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      hbox(w: 44),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
                  ),
                  hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                    radius: BorderRadius.circular(28),
                    pad: EdgeInsets.fromLTRB(20, 24, 20, 24),
                    clip: true,
                    border: dk(
                      context,
                      null,
                      Border(
                        top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                        right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                        bottom: BorderSide(color: Color(0xFF2E2E33), width: 1),
                        left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      ),
                    ),
                    child: hstack(
                      hcol(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: hbox(
                              w: 52,
                              h: 52,
                              bg: Color(0xFF17C964),
                              radius: BorderRadius.circular(26),
                              child: hrow(
                                [hsvg(Svgs.s335, w: 26, h: 26)],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                          ),
                          hcol(
                            [
                              Text(
                                '开通成功',
                                style: hts(
                                  22,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w600,
                                  lh: 30,
                                ),
                              ),
                              Text(
                                '${receipt!.storeName} · 已为您创建店长账号',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 4,
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hbox(
                                  bg: Color(0xFF27272A),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: hcol(
                                    [
                                      Text(
                                        '当前版本',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 14,
                                        ),
                                      ),
                                      Text(
                                        '限时免费',
                                        style: hts(
                                          15,
                                          Color(0xFFF5D78E),
                                          w: FontWeight.w600,
                                          lh: 20,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hbox(
                                  bg: Color(0xFF27272A),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  child: hcol(
                                    [
                                      Text(
                                        '免费期间',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 14,
                                        ),
                                      ),
                                      Text(
                                        '完整功能',
                                        style: hts(
                                          15,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                            intrinsic: true,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
                      ),
                      [],
                      behind: [
                        Positioned(
                          top: -114,
                          right: -110,
                          child: hsvg(Svgs.s7, w: 240, h: 240),
                        ),
                      ],
                    ),
                  ),
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '开始使用 · 1/4',
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
                            hbox(
                              minH: 62,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: Color.fromRGBO(23, 201, 100, 0.133),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [hsvg(Svgs.s20, w: 12, h: 12)],
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
                                          '创建门店账号',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 22,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        Text(
                                          '手机号 ${receipt!.maskedPhone}',
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
                                      gap: 1,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: hbox(
                                minH: 62,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 20,
                                      h: 20,
                                      radius: BorderRadius.circular(10),
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '确认服务项目与价格',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                          Text(
                                            '已按主营业务生成 ${receipt!.seededServices} 项',
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
                                        gap: 1,
                                      ),
                                    ),
                                    hsvg(
                                      dk(context, Svgs.s3, Svgs.s4),
                                      w: 16,
                                      h: 16,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              onTap: () => openRoute(context, 'Services'),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: hbox(
                                minH: 62,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 20,
                                      h: 20,
                                      radius: BorderRadius.circular(10),
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '添加员工和技师',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                          Text(
                                            '邀请店员加入，分配权限',
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
                                        gap: 1,
                                      ),
                                    ),
                                    hsvg(
                                      dk(context, Svgs.s3, Svgs.s4),
                                      w: 16,
                                      h: 16,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              onTap: () => openRoute(context, 'Staff'),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: hbox(
                                minH: 62,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 20,
                                      h: 20,
                                      radius: BorderRadius.circular(10),
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '录入第一位会员',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                          Text(
                                            '手动添加或批量导入',
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
                                        gap: 1,
                                      ),
                                    ),
                                    hsvg(
                                      dk(context, Svgs.s3, Svgs.s4),
                                      w: 16,
                                      h: 16,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              onTap: () => openRoute(context, 'MemberAdd'),
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
                    gap: 8,
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
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '限时免费中',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 22,
                                    ),
                                  ),
                                  Text(
                                    '现阶段所有功能免费使用，无需订阅，也不会限制使用时间',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 18,
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
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
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
                    flex: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: hbox(
                        h: 50,
                        bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: Text(
                            '进入工作台',
                            style: hts(
                              15,
                              dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => openRoute(context, 'Main'),
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
      ),
    );
  }
}
