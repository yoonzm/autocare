import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({super.key});

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
          hrow(
            [
              hbox(
                w: 72,
                h: 48,
                bg: Color(0xFF27272A),
                radius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  width: 1,
                ),
                clip: true,
                child: hstack(
                  hcol(
                    [],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                    min: false,
                  ),
                  [
                    Positioned(
                      left: 6,
                      top: 6,
                      right: 6,
                      bottom: 6,
                      child: hbox(
                        bg: dk(
                          context,
                          Color.fromRGBO(255, 255, 255, 0.1),
                          Color.fromRGBO(9, 9, 11, 0.92),
                        ),
                        radius: BorderRadius.circular(6),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 14,
                      right: 12,
                      height: 4,
                      child: hbox(
                        h: 4,
                        bg: dk(
                          context,
                          Color.fromRGBO(255, 255, 255, 0.4),
                          Color.fromRGBO(9, 9, 11, 0.92),
                        ),
                        radius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 24,
                      right: 24,
                      height: 4,
                      child: hbox(
                        h: 4,
                        bg: dk(
                          context,
                          Color.fromRGBO(255, 255, 255, 0.25),
                          Color.fromRGBO(9, 9, 11, 0.92),
                        ),
                        radius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: hcol(
                  [
                    Text(
                      '行驶证识别结果',
                      style: hts(
                        20,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
                        lh: 28,
                      ),
                    ),
                    hcol(
                      [
                        hbox(
                          bg: dk(
                            context,
                            Color(0xFFDDF6E7),
                            Color.fromRGBO(23, 201, 100, 0.16),
                          ),
                          radius: BorderRadius.circular(10),
                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s156, Svgs.s157),
                                w: 12,
                                h: 12,
                              ),
                              Flexible(
                                flex: 48,
                                child: Text(
                                  '识别成功',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF2B7745),
                                      Color(0xFF5FD48C),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 4,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 4,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 12,
          ),
          hcol(
            [
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '车牌号',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          hbox(
                            grad: LinearGradient(
                              begin: Alignment(-0, -1),
                              end: Alignment(0, 1),
                              colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                              stops: [0, 1],
                            ),
                            radius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 0.75),
                              width: 1.5,
                            ),
                            pad: EdgeInsets.fromLTRB(9, 2, 9, 2),
                            child: Text(
                              '沪A·8K29M',
                              style: hts(
                                14,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 20,
                                ls: 0.5,
                              ),
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                    Text(
                      '蓝牌',
                      style: hts(
                        12,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '品牌车型',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '宝马 5系 525Li',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '车架号',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'LBV8K29M4PN****21',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                          ls: 0.3,
                          tab: true,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '发动机号',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'B48B20B ****',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                          ls: 0.3,
                          tab: true,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '注册日期',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '2023-03-18',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
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
          hbox(
            bg: dk(
              context,
              Color(0xFFFDEFD6),
              Color.fromRGBO(245, 165, 36, 0.16),
            ),
            radius: BorderRadius.circular(14),
            pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s337, Svgs.s338), w: 16, h: 16),
                Flexible(
                  flex: 336,
                  child: Text(
                    '请核对信息，识别有误可在下一步修改。车身颜色需手动选择。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)),
                      lh: 18,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: hTap(
                    context,
                    hbox(
                      h: 48,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(24),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '重新扫描',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    to: 'ScanLicense',
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: hTap(
                    context,
                    hbox(
                      h: 48,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(24),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '确认并填入',
                          style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600),
                        ),
                      ),
                    ),
                    to: 'MemberAdd',
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
        gap: 14,
      ),
    );
  }
}
