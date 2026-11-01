import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StaffTransferSheet extends StatelessWidget {
  const StaffTransferSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
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
          Text(
            '转交进行中的订单',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(18),
            pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: hrow(
              [
                hbox(
                  bg: Color(0xFF0B5FD6),
                  radius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFF5B9BF0), width: 1.5),
                  pad: EdgeInsets.fromLTRB(5, 1, 5, 1),
                  child: Text(
                    '沪A·8K29M',
                    style: hts(
                      11,
                      Color(0xFFFFFFFF),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '全车镀晶 · 9H',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      Text(
                        '施工中 65% · 2 号工位',
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
              gap: 10,
            ),
          ),
          Text(
            '转交给',
            style: hts(
              13,
              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
              w: FontWeight.w500,
              lh: 18,
            ),
          ),
          hcol(
            [
              hbox(
                bg: dk(
                  context,
                  Color(0xFFE1F0FE),
                  Color.fromRGBO(4, 133, 247, 0.18),
                ),
                radius: BorderRadius.circular(18),
                border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: hrow(
                  [
                    hbox(
                      w: 36,
                      h: 36,
                      bg: Color(0xFFFFFFFF),
                      radius: BorderRadius.circular(18),
                      align: Alignment(0, 0),
                      child: Text(
                        '王',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          Text(
                            '王磊',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          Text(
                            '洗车 / 内饰 · 本月 203 台次',
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
                    hbox(
                      bg: dk(
                        context,
                        Color(0xFFDDF6E7),
                        Color.fromRGBO(23, 201, 100, 0.16),
                      ),
                      radius: BorderRadius.circular(9),
                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        '空闲',
                        style: hts(
                          11,
                          dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(11),
                      child: hrow(
                        [hsvg(Svgs.s309, w: 14, h: 14)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
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
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(18),
                pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: hrow(
                  [
                    hbox(
                      w: 36,
                      h: 36,
                      bg: Color(0xFFFFFFFF),
                      radius: BorderRadius.circular(18),
                      align: Alignment(0, 0),
                      child: Text(
                        '张',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          Text(
                            '张伟',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          Text(
                            '贴膜 · 本月 46 台次',
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
                    hbox(
                      bg: dk(
                        context,
                        Color(0xFFE1F0FE),
                        Color.fromRGBO(4, 133, 247, 0.18),
                      ),
                      radius: BorderRadius.circular(9),
                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        '施工中',
                        style: hts(
                          11,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 2),
                        Border.all(color: Color(0xFF3F3F46), width: 2),
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
            gap: 8,
          ),
          Text(
            '转交后进度与已拍照片保留，提成按各自完成的工序分配，并通知接手技师。',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 17,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 10,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
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
                          ),
                        ),
                      ),
                    ),
                    to: 'DisableStaff',
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: Color(0xFFA43433),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '转交并停用',
                          style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600),
                        ),
                      ),
                    ),
                    to: 'Staff',
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
            intrinsic: true,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
