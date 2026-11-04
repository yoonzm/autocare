import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PayApplyDonePage extends StatelessWidget {
  const PayApplyDonePage({super.key});

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
                hbox(
                  h: 560,
                  child: hcol(
                    [
                      hbox(
                        w: 96,
                        h: 96,
                        bg: dk(
                          context,
                          Color(0xFFDDF6E7),
                          Color.fromRGBO(23, 201, 100, 0.16),
                        ),
                        radius: BorderRadius.circular(48),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s434, Svgs.s435),
                              w: 48,
                              h: 48,
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      hbox(
                        margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Text(
                          '微信支付已开通',
                          style: hts(
                            20,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      hbox(
                        maxW: 270,
                        child: Text(
                          '商户号 1612 **** 88，现在可以微信收款了',
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
                    min: false,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                        hcol(
                          [
                            Text(
                              '已自动打开「微信支付」收款方式，并设为默认收款方式，可以在「支付与收款」里调整。',
                              style: hts(13, Color(0xFFD4D4D8), lh: 19),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 12,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -110,
                        right: -110,
                        child: hsvg(Svgs.s7, w: 240, h: 240),
                      ),
                    ],
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
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: hTap(
                      context,
                      hbox(
                        h: 50,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: Text(
                            '去看收款设置',
                            style: hts(
                              15,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                        ),
                      ),
                      to: 'PayConfig',
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ),
        ),
      ],
    );
  }
}
