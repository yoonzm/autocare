import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
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
                        '注销账号',
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
                  bg: dk(
                    context,
                    Color(0xFFFFE1E2),
                    Color.fromRGBO(255, 56, 60, 0.18),
                  ),
                  radius: BorderRadius.circular(18),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      hsvg(dk(context, Svgs.s98, Svgs.s99), w: 18, h: 18),
                      Flexible(
                        flex: 504,
                        child: Text(
                          '注销后账号无法恢复，请谨慎操作。申请提交后有 15 天冷静期，期间重新登录可撤销。',
                          style: hts(
                            13,
                            dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                            lh: 19,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.start,
                    gap: 10,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '注销前需满足',
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
                            minH: 58,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 20,
                                  h: 20,
                                  bg: Color.fromRGBO(255, 56, 60, 0.133),
                                  radius: BorderRadius.circular(10),
                                  child: hrow(
                                    [hsvg(Svgs.s399, w: 12, h: 12)],
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
                                        '无进行中的订单与挂单',
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
                                        '当前 4 笔挂单未处理',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA43433),
                                            Color(0xFFFF7B7E),
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
                                hTap(
                                  context,
                                  Text(
                                    '去处理',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 18,
                                    ),
                                  ),
                                  to: 'HoldList',
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
                          hbox(
                            minH: 58,
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
                                        '无未结清的欠费',
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
                                        '账号状态正常',
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
                          hbox(
                            minH: 58,
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
                                        '已导出需要保留的经营数据',
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
                                        '建议先到统计页导出',
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
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
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '注销后将',
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
                          hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s101, Svgs.s102),
                                w: 14,
                                h: 14,
                              ),
                              Flexible(
                                flex: 182,
                                child: Text(
                                  '删除账号、员工权限及登录信息',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 19,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.start,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s101, Svgs.s102),
                                w: 14,
                                h: 14,
                              ),
                              Flexible(
                                flex: 195,
                                child: Text(
                                  '门店经营数据在冷静期结束后清除',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 19,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.start,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s101, Svgs.s102),
                                w: 14,
                                h: 14,
                              ),
                              Flexible(
                                flex: 221,
                                child: Text(
                                  '注销后账号权益立即终止',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 19,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.start,
                            gap: 8,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
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
                      hcol(
                        [
                          Text.rich(
                            TextSpan(
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                              children: [
                                TextSpan(
                                  text: '短信验证码 ',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA43433),
                                      Color(0xFFFF7B7E),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hbox(
                            h: 48,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 6, 0),
                            child: hrow(
                              [
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '6 位数字',
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                                HCodeHolder(
                                  builder: (context, k1) => hTap(
                                    context,
                                    hbox(
                                      h: 36,
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
                                            color: Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.06,
                                            ),
                                            offset: Offset(0, 0),
                                            blurRadius: 1,
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.06,
                                            ),
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
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
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: hCodeText(
                                          k1,
                                          hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF1E63AE),
                                              Color(0xFF6AB4FA),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () => hSendCode(context, k1),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                          hLiveText(
                            (p) => p.live
                                ? ('验证码将发送至当前账号绑定的手机号 ${p.maskedPhone}')
                                : '验证码将发送至当前账号绑定的手机号 138 **** 1234',
                            hts(
                              12,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                      hrow(
                        [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                            child: HCheck(
                              initial: false,
                              size: 16,
                              color: Color(0xFFFF383C),
                            ),
                          ),
                          Flexible(
                            flex: 208,
                            child: Text(
                              '我已了解注销后果，并同意注销账号',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
                                lh: 19,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 8,
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
                  child: hDeleteGate(
                    on: hTap(
                      context,
                      hbox(
                        h: 50,
                        bg: dk(
                          context,
                          Color(0xFFFFE1E2),
                          Color.fromRGBO(255, 56, 60, 0.18),
                        ),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: hBusy(
                            'DeleteAccount>Login',
                            Text(
                              '申请注销',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFA43433),
                                  Color(0xFFFF7B7E),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            style: hts(
                              15,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              w: FontWeight.w500,
                              lh: 22,
                            ),
                            label: '提交中…',
                          ),
                        ),
                      ),
                      to: 'Login',
                    ),
                    off: hTap(
                      context,
                      hbox(
                        h: 50,
                        bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: hBusy(
                            'DeleteAccount>Login',
                            Text(
                              '申请注销',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            style: hts(
                              15,
                              dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                              w: FontWeight.w500,
                              lh: 22,
                            ),
                            label: '提交中…',
                          ),
                        ),
                      ),
                      onTap: () => hToast(context, hDeleteReason()),
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
