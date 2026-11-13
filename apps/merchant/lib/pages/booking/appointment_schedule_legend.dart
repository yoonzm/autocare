// 从工位时间表设计稿提取的状态图例。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class AppointmentScheduleLegend extends StatelessWidget {
  const AppointmentScheduleLegend({super.key});
  @override
  Widget build(BuildContext context) => hbox(
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
    pad: EdgeInsets.fromLTRB(8, 14, 0, 14),
    clip: true,
    child: hcol(
      [
        hwrap(
          [
            hrow(
              [
                hbox(
                  w: 10,
                  h: 10,
                  bg: dk(
                    context,
                    Color(0xFFE1F0FE),
                    Color.fromRGBO(4, 133, 247, 0.18),
                  ),
                  radius: BorderRadius.circular(3),
                ),
                Flexible(
                  flex: 33,
                  child: Text(
                    '待到店',
                    style: hts(
                      11,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 14,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
            hrow(
              [
                hbox(
                  w: 10,
                  h: 10,
                  bg: dk(
                    context,
                    Color(0xFFDDF6E7),
                    Color.fromRGBO(23, 201, 100, 0.16),
                  ),
                  radius: BorderRadius.circular(3),
                ),
                Flexible(
                  flex: 33,
                  child: Text(
                    '已到店',
                    style: hts(
                      11,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 14,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
            hrow(
              [
                hbox(
                  w: 10,
                  h: 10,
                  bg: dk(
                    context,
                    Color(0xFFFDEFD6),
                    Color.fromRGBO(245, 165, 36, 0.16),
                  ),
                  radius: BorderRadius.circular(3),
                ),
                Flexible(
                  flex: 33,
                  child: Text(
                    '施工中',
                    style: hts(
                      11,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 14,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
            hrow(
              [
                hbox(
                  w: 10,
                  h: 10,
                  bg: dk(
                    context,
                    Color(0xFFFFE1E2),
                    Color.fromRGBO(255, 56, 60, 0.18),
                  ),
                  radius: BorderRadius.circular(3),
                ),
                Flexible(
                  flex: 44,
                  child: Text(
                    '超时未到',
                    style: hts(
                      11,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 14,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
            hrow(
              [
                hbox(
                  w: 10,
                  h: 10,
                  bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                  radius: BorderRadius.circular(3),
                ),
                Flexible(
                  flex: 33,
                  child: Text(
                    '已完成',
                    style: hts(
                      11,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 14,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
          ],
          gap: 0,
          rowGap: 0,
          cross: WrapCrossAlignment.start,
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 8,
    ),
  );
}
