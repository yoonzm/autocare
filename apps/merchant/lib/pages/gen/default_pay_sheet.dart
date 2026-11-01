import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class DefaultPaySheet extends StatelessWidget {
  const DefaultPaySheet({super.key});

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
            '默认收款方式',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          HSelHolder(
            groups: [
              ({0}, false),
            ],
            builder: (context, g1) => hcol(
              [
                HSel(
                  ctrl: g1[0],
                  index: 0,
                  on: hbox(
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '微信支付',
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
                                '结账时默认选中',
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
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                  off: hbox(
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '微信支付',
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
                                '结账时默认选中',
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
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                ),
                HSel(
                  ctrl: g1[0],
                  index: 1,
                  on: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '支付宝',
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
                              SizedBox.shrink(),
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
                  off: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '支付宝',
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
                              SizedBox.shrink(),
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
                ),
                HSel(
                  ctrl: g1[0],
                  index: 2,
                  on: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '会员储值',
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
                                '有余额的会员优先使用',
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
                      gap: 10,
                    ),
                  ),
                  off: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '会员储值',
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
                                '有余额的会员优先使用',
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
                      gap: 10,
                    ),
                  ),
                ),
                HSel(
                  ctrl: g1[0],
                  index: 3,
                  on: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '现金',
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
                              SizedBox.shrink(),
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
                  off: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                '现金',
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
                              SizedBox.shrink(),
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
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 10,
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
                  to: 'PayConfig',
                ),
              ),
              Expanded(
                flex: 16,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '确定',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'PayConfig',
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
