import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class DisableStaffSheet extends StatelessWidget {
  const DisableStaffSheet({super.key});

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
            '停用 李国强 的账号？',
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
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hrow(
              [
                hbox(
                  w: 40,
                  h: 40,
                  bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                  radius: BorderRadius.circular(20),
                  align: Alignment(0, 0),
                  child: Text(
                    '李',
                    style: hts(
                      16,
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
                        '李国强',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '施工技师 · 施工中 · 2 号工位',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
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
          hcol(
            [
              hrow(
                [
                  hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                  Flexible(
                    flex: 260,
                    child: Text(
                      '该员工将无法登录，历史施工记录与提成保留',
                      style: hts(
                        13,
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
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
                  hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                  Flexible(
                    flex: 223,
                    child: Text(
                      '进行中的 1 个订单需先转交给其他技师',
                      style: hts(
                        13,
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                        lh: 19,
                      ),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    flex: 39,
                    child: hTap(
                      context,
                      Text(
                        '去转交',
                        style: hts(
                          13,
                          Color(0xFF0485F7),
                          w: FontWeight.w500,
                          lh: 19,
                        ),
                        softWrap: false,
                        maxLines: 1,
                      ),
                      to: 'StaffTransfer',
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 8,
              ),
              hrow(
                [
                  hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                  Flexible(
                    flex: 169,
                    child: Text(
                      '可随时在员工详情中重新启用',
                      style: hts(
                        13,
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
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
            gap: 8,
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
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'StaffDetail',
                  ),
                ),
              ),
              Expanded(
                flex: 16,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: hTap(
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
                        child: Text(
                          '确认停用',
                          style: hts(
                            15,
                            dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
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
