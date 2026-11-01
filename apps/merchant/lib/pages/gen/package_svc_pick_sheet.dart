import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PackageSvcPickSheet extends StatelessWidget {
  const PackageSvcPickSheet({super.key});

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
            '选择包含服务',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hbox(
            h: 44,
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(22),
            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s280, Svgs.s281), w: 18, h: 18),
                Flexible(
                  flex: 84,
                  child: Text(
                    '搜索服务项目',
                    style: hts(
                      14,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
          ),
          HSelHolder(
            groups: [
              ({0}, false),
            ],
            builder: (context, g1) => hrow(
              [
                Flexible(
                  flex: 54,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: HSel(
                      ctrl: g1[0],
                      index: 0,
                      on: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '全部',
                            style: hts(
                              13,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '全部',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 54,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: HSel(
                      ctrl: g1[0],
                      index: 1,
                      on: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '洗车',
                            style: hts(
                              13,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '洗车',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 54,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: HSel(
                      ctrl: g1[0],
                      index: 2,
                      on: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '美容',
                            style: hts(
                              13,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '美容',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 54,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: HSel(
                      ctrl: g1[0],
                      index: 3,
                      on: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '养护',
                            style: hts(
                              13,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 30,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(15),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '养护',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
              intrinsic: true,
            ),
          ),
          hcol(
            [
              hbox(
                bg: Color(0xFFF2F8FE),
                radius: BorderRadius.circular(16),
                pad: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: hrow(
                  [
                    hbox(
                      w: 24,
                      h: 24,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(Svgs.s282, w: 14, h: 14)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    hbox(
                      w: 40,
                      h: 40,
                      bg: dk(
                        context,
                        Color(0xFFE1F0FE),
                        Color.fromRGBO(4, 133, 247, 0.18),
                      ),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(dk(context, Svgs.s283, Svgs.s284), w: 20, h: 20)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        minW: 0,
                        child: hcol(
                          [
                            Text(
                              '精致洗车',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '单次 ¥68 · 约 40 分钟',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                    ),
                    HHolder(
                      inits: [20],
                      builder: (context, ctrls) {
                        final c2 = ctrls[0];
                        return hrow(
                          [
                            hTap(
                              context,
                              hbox(
                                w: 26,
                                h: 26,
                                bg: Color(0xFFFFFFFF),
                                radius: BorderRadius.circular(13),
                                border: dk(
                                  context,
                                  Border.all(
                                    color: Color(0xFFD4D4D8),
                                    width: 1,
                                  ),
                                  Border.all(
                                    color: Color(0xFF3F3F46),
                                    width: 1,
                                  ),
                                ),
                                align: Alignment(0, 0),
                                child: Text(
                                  '−',
                                  style: hts(
                                    16,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ),
                              onTap: () => c2.add(-1),
                            ),
                            Flexible(
                              flex: 34,
                              child: hbox(
                                minW: 34,
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: hCount(
                                    c2,
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    0,
                                    ' 次',
                                    false,
                                  ),
                                ),
                              ),
                            ),
                            hTap(
                              context,
                              hbox(
                                w: 26,
                                h: 26,
                                bg: Color(0xFFFFFFFF),
                                radius: BorderRadius.circular(13),
                                border: dk(
                                  context,
                                  Border.all(
                                    color: Color(0xFFD4D4D8),
                                    width: 1,
                                  ),
                                  Border.all(
                                    color: Color(0xFF3F3F46),
                                    width: 1,
                                  ),
                                ),
                                align: Alignment(0, 0),
                                child: Text(
                                  '+',
                                  style: hts(
                                    16,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ),
                              onTap: () => c2.add(1),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 6,
                        );
                      },
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
                radius: BorderRadius.circular(16),
                pad: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: hrow(
                  [
                    hbox(
                      w: 24,
                      h: 24,
                      radius: BorderRadius.circular(12),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 1.5),
                        Border.all(color: Color(0xFF3F3F46), width: 1.5),
                      ),
                    ),
                    hbox(
                      w: 40,
                      h: 40,
                      bg: dk(
                        context,
                        Color(0xFFFDEFD6),
                        Color.fromRGBO(245, 165, 36, 0.16),
                      ),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(dk(context, Svgs.s285, Svgs.s286), w: 20, h: 20)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        minW: 0,
                        child: hcol(
                          [
                            Text(
                              '内饰深度清洁',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '单次 ¥380 · 约 120 分钟',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
                radius: BorderRadius.circular(16),
                pad: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: hrow(
                  [
                    hbox(
                      w: 24,
                      h: 24,
                      radius: BorderRadius.circular(12),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 1.5),
                        Border.all(color: Color(0xFF3F3F46), width: 1.5),
                      ),
                    ),
                    hbox(
                      w: 40,
                      h: 40,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(dk(context, Svgs.s287, Svgs.s288), w: 20, h: 20)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        minW: 0,
                        child: hcol(
                          [
                            Text(
                              '空调杀菌',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '单次 ¥98 · 约 30 分钟',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
                radius: BorderRadius.circular(16),
                pad: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: hrow(
                  [
                    hbox(
                      w: 24,
                      h: 24,
                      radius: BorderRadius.circular(12),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 1.5),
                        Border.all(color: Color(0xFF3F3F46), width: 1.5),
                      ),
                    ),
                    hbox(
                      w: 40,
                      h: 40,
                      bg: dk(
                        context,
                        Color(0xFFDDF6E7),
                        Color.fromRGBO(23, 201, 100, 0.16),
                      ),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(dk(context, Svgs.s289, Svgs.s290), w: 20, h: 20)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        minW: 0,
                        child: hcol(
                          [
                            Text(
                              '镀晶养护',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '单次 ¥1,280 · 约 240 分钟',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
                radius: BorderRadius.circular(16),
                pad: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: hrow(
                  [
                    hbox(
                      w: 24,
                      h: 24,
                      radius: BorderRadius.circular(12),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 1.5),
                        Border.all(color: Color(0xFF3F3F46), width: 1.5),
                      ),
                    ),
                    hbox(
                      w: 40,
                      h: 40,
                      bg: Color(0xFFFFF4DB),
                      radius: BorderRadius.circular(12),
                      child: hrow(
                        [hsvg(dk(context, Svgs.s285, Svgs.s286), w: 20, h: 20)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        minW: 0,
                        child: hcol(
                          [
                            Text(
                              '打蜡抛光',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '单次 ¥188 · 约 90 分钟',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
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
            gap: 2,
          ),
          Text(
            '选中服务后设置包含次数；原价按「单次价 × 次数」自动汇总。',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 17,
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '已选 1 项',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 17,
                        ),
                      ),
                      Text(
                        '合计原价 ¥1,360',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 1,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 48,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(24),
                    pad: EdgeInsets.fromLTRB(28, 0, 28, 0),
                    child: Align(
                      alignment: Alignment(-1, 0),
                      widthFactor: 1,
                      child: Text(
                        '确认添加',
                        style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600),
                      ),
                    ),
                  ),
                  to: 'PackageEdit',
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
        gap: 14,
      ),
    );
  }
}
