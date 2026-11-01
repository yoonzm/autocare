import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ForgotDonePage extends StatelessWidget {
  const ForgotDonePage({super.key});

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
                hbox(
                  w: 96,
                  h: 96,
                  bg: Color(0xFFDCF5E7),
                  radius: BorderRadius.circular(48),
                  child: hrow(
                    [hsvg(Svgs.s398, w: 44, h: 44)],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Text(
                    '密码已重置',
                    style: hts(
                      22,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                hbox(
                  maxW: 260,
                  child: Text(
                    '请使用新密码登录。其他设备上的登录状态已失效。',
                    style: hts(
                      14,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 21,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              gap: 12,
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
                hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '去登录',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'LoginPwd',
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
        ),
      ],
    );
  }
}
