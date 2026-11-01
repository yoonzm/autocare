import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class MemberFilterSheet extends StatelessWidget {
  const MemberFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      minH: 712,
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: Text(
                  '筛选会员',
                  style: hts(
                    20,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 28,
                  ),
                ),
              ),
              hTap(
                context,
                Text(
                  '重置',
                  style: hts(
                    14,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    w: FontWeight.w500,
                    lh: 20,
                  ),
                ),
                label: '重置',
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text.rich(
                  TextSpan(
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                    children: [
                      TextSpan(
                        text: '卡种 ',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: '· 可多选',
                        style: hts(
                          14,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({2, 3}, true),
                ],
                builder: (context, g1) => hwrap(
                  [
                    HSel(
                      ctrl: g1[0],
                      index: 0,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '普通会员',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '普通会员',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 1,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '银卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '银卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 2,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '金卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '金卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 3,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '黑金卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '黑金卡',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '储值余额',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({3}, false),
                ],
                builder: (context, g2) => hwrap(
                  [
                    HSel(
                      ctrl: g2[0],
                      index: 0,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '不限',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '不限',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 1,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥500 以下',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥500 以下',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 2,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥500–2,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥500–2,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 3,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥2,000 以上',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥2,000 以上',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '最近到店',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({1}, false),
                ],
                builder: (context, g3) => hwrap(
                  [
                    HSel(
                      ctrl: g3[0],
                      index: 0,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '7 天内',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '7 天内',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g3[0],
                      index: 1,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '30 天内',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '30 天内',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g3[0],
                      index: 2,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '超过 60 天',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '超过 60 天',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g3[0],
                      index: 3,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '超过 90 天',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '超过 90 天',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '次卡状态',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [({}, true)],
                builder: (context, g4) => hwrap(
                  [
                    HSel(
                      ctrl: g4[0],
                      index: 0,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '7 天内到期',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '7 天内到期',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g4[0],
                      index: 1,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '剩余 ≤ 2 次',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '剩余 ≤ 2 次',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g4[0],
                      index: 2,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '已用完',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '已用完',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '车辆与项目',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({1}, true),
                ],
                onSelect: {0: (i) => plateEnergy.value = i == 0},
                builder: (context, g5) => hwrap(
                  [
                    HSel(
                      ctrl: g5[0],
                      index: 0,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '新能源车主',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '新能源车主',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g5[0],
                      index: 1,
                      on: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '做过镀晶',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '做过镀晶',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g5[0],
                      index: 2,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '车衣质保中',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '车衣质保中',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g5[0],
                      index: 3,
                      on: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '多辆车',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 36,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '多辆车',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hbox(
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFEFEFF1),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF2A2A2E),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(0, 12, 0, 30),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '取消',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Members',
                  ),
                ),
                Expanded(
                  flex: 2,
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
                          '查看 64 位会员',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Members',
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 18,
      ),
    );
  }
}
