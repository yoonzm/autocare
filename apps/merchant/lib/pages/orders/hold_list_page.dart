import 'hold_board.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../resources/merchant_svgs.dart';

class HoldListPage extends StatelessWidget {
  final int initialTab;
  const HoldListPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      header: AppPageHeader(title: '挂单'),
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: hcol(
              [HoldBoard(initialTab: initialTab)],
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
                    onTap: () => openRoute(context, 'Order'),
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: hrow(
                        [
                          hsvg(dk(context, Svgs.s14, Svgs.s15), w: 18, h: 18),
                          Flexible(
                            flex: 60,
                            child: Text(
                              '新开一单',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 6,
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
