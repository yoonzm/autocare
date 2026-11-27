// 预约详情：展示调用者传入的预约与明确动作。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import '../../backend/appointment_flow.dart';
import '../../resources/merchant_svgs.dart';
import '../../kit/page_header.dart';

class AppointmentDetailTemplate extends StatelessWidget {
  final Appointment a;
  final String actionKey;
  final VoidCallback onReschedule, onOrder;
  const AppointmentDetailTemplate({
    super.key,
    required this.a,
    required this.actionKey,
    required this.onReschedule,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      header: AppPageHeader(title: '预约详情'),
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: hcol(
              [
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
                        hrow(
                          [
                            hbox(
                              w: 48,
                              h: 48,
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(24),
                              align: Alignment(0, 0),
                              child: Text(
                                a.customer.substring(0, 1),
                                style: hts(
                                  18,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 54,
                                        child: Text(
                                          a.customer,
                                          style: hts(
                                            18,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 26,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 38,
                                        child: hbox(
                                          bg: Color(0xFFF5D78E),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            a.level,
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 18,
                                            ),
                                            softWrap: false,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                  Text(
                                    a.maskedPhone,
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 3,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => AppToast.show(
                                context,
                                a.row['phone'] == ''
                                    ? '尚未登记联系方式'
                                    : '联系电话：${a.row['phone']}',
                              ),
                              child: hbox(
                                w: 40,
                                h: 40,
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(20),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s9, Svgs.s10),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hbox(
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: hcol(
                                  [
                                    Text(
                                      '预约时间',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 14,
                                      ),
                                    ),
                                    Text(
                                      '${a.start.month}.${a.start.day} ${a.time}',
                                      style: hts(
                                        15,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 20,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hbox(
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: hcol(
                                  [
                                    Text(
                                      '距到店',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 14,
                                      ),
                                    ),
                                    Text(
                                      a.row['status'] == 'waiting'
                                          ? '${a.start.difference(bookingToday).inMinutes} 分钟'
                                          : a.row['status'] == 'late'
                                          ? '已超时'
                                          : '—',
                                      style: hts(
                                        15,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 20,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 8,
                          intrinsic: true,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 16,
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
                hbox(
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
                  pad: EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                hbox(
                                  w: 22,
                                  h: 22,
                                  bg: Color(0xFF17C964),
                                  radius: BorderRadius.circular(11),
                                  child: hrow(
                                    [hsvg(Svgs.s11, w: 13, h: 13)],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                                Text(
                                  '已预约',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                a.row['status'] == 'done'
                                    ? hbox(
                                        w: 22,
                                        h: 22,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(11),
                                        child: hrow(
                                          [hsvg(Svgs.s11, w: 13, h: 13)],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      )
                                    : hbox(
                                        w: 22,
                                        h: 22,
                                        bg: Color(0xFF0485F7),
                                        radius: BorderRadius.circular(11),
                                        shadow: [
                                          BoxShadow(
                                            color: Color(0xFFCFE6FD),
                                            offset: Offset(0, 0),
                                            blurRadius: 0,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                        child: hrow(
                                          [
                                            hbox(
                                              w: 8,
                                              h: 8,
                                              bg: dk(
                                                context,
                                                Color(0xFFFFFFFF),
                                                Color(0xFF18181B),
                                              ),
                                              radius: BorderRadius.circular(4),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                Text(
                                  switch (a.row['status']) {
                                    'arrived' => '已到店',
                                    'done' => '待到店',
                                    'cancelled' => '已取消',
                                    'late' => '超时未到',
                                    _ => '待到店',
                                  },
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF1E63AE),
                                      Color(0xFF6AB4FA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                a.row['status'] == 'done'
                                    ? hbox(
                                        w: 22,
                                        h: 22,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(11),
                                        child: hrow(
                                          [hsvg(Svgs.s11, w: 13, h: 13)],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      )
                                    : hbox(
                                        w: 22,
                                        h: 22,
                                        radius: BorderRadius.circular(11),
                                        border: dk(
                                          context,
                                          Border.all(
                                            color: Color(0xFFD4D4D8),
                                            width: 2,
                                          ),
                                          Border.all(
                                            color: Color(0xFF3F3F46),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                Text(
                                  '施工中',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                a.row['status'] == 'done'
                                    ? hbox(
                                        w: 22,
                                        h: 22,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(11),
                                        child: hrow(
                                          [hsvg(Svgs.s11, w: 13, h: 13)],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      )
                                    : hbox(
                                        w: 22,
                                        h: 22,
                                        radius: BorderRadius.circular(11),
                                        border: dk(
                                          context,
                                          Border.all(
                                            color: Color(0xFFD4D4D8),
                                            width: 2,
                                          ),
                                          Border.all(
                                            color: Color(0xFF3F3F46),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                Text(
                                  '已完成',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 0,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 14,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '预约信息',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
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
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        [
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '车辆',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  a.plate.isEmpty ? '到店登记' : a.plate,
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '服务项目',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  a.service,
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '预计用时',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${a.duration}（${a.time} – ${bookingTime(a.start.add(Duration(minutes: a.minutes)))}）',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '工位 / 技师',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  a.station,
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '预约来源',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '门店手工预约',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 62,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '备注',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  a.row['note'] == ''
                                      ? '—'
                                      : '${a.row['note']}',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
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
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '通知记录',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
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
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        _noticeRows(context),
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
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
                  flex: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onReschedule,
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '改期 / 取消',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 16,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onOrder,
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        child: hBusy(
                          actionKey,
                          Text(
                            switch (a.row['status']) {
                              'done' => '预约已完成',
                              'cancelled' => '预约已取消',
                              'arrived' => '去开单',
                              _ => '客户到店 · 开单',
                            },
                            style: hts(
                              15,
                              dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          style: hts(
                            15,
                            dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
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

  List<Widget> _noticeRows(BuildContext context) {
    final raw = (a.row['notices'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final rows = <Map<String, dynamic>>[];

    if (raw.isEmpty) {
      rows.add({
        'kind': 'confirm',
        'channel': 'sms',
        'status': a.row['notify_confirm'] == true ? 'unrecorded' : 'disabled',
        'subtitle': '—',
      });
    } else {
      for (final n in raw) {
        final sent = _noticeTime('${n['sent_at'] ?? n['created_at'] ?? ''}');
        final err = '${n['error'] ?? ''}'.trim();
        rows.add({
          'kind': '${n['kind'] ?? 'confirm'}',
          'channel': '${n['channel'] ?? 'sms'}',
          'status': '${n['status'] ?? 'sent'}',
          'subtitle': n['status'] == 'sent'
              ? (sent.isEmpty ? '—' : sent)
              : (err.isNotEmpty ? err : '—'),
        });
      }
    }

    final hasRemind = raw.any((n) => n['kind'] == 'remind');
    if (!hasRemind) {
      final enabled = a.row['remind_enabled'] == true;
      final state = '${a.row['remind_state'] ?? 'disabled'}';
      final remindAt = _noticeTime('${a.row['remind_at'] ?? ''}');
      final status = !enabled
          ? 'disabled'
          : switch (state) {
              'pending' || 'sending' => 'pending',
              'sent' => 'sent',
              'failed' || 'unknown' => 'failed',
              'skipped' || 'cancelled' => 'skipped',
              _ => 'disabled',
            };
      rows.add({
        'kind': 'remind',
        'channel': 'sms',
        'status': status,
        'subtitle': status == 'pending' && remindAt.isNotEmpty
            ? '预计 $remindAt 发送'
            : '—',
      });
    }

    final widgets = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        widgets.add(
          hbox(
            h: 1,
            bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
          ),
        );
      }
      widgets.add(_noticeRow(context, rows[i]));
    }
    return widgets;
  }

  Widget _noticeRow(BuildContext context, Map<String, dynamic> row) {
    final isWechat = row['channel'] == 'wechat';
    final title = switch (row['kind']) {
      'confirm' => '预约确认',
      'reschedule' => '改期通知',
      'remind' => '到店前提醒',
      'cancel' => '取消通知',
      _ => '预约通知',
    };
    final (badgeLabel, badgeBg, badgeInk) = switch (row['status']) {
      'sent' => (
        '已发送',
        dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16)),
        dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
      ),
      'pending' => (
        '待发送',
        dk(context, Color(0xFFE8F2FC), Color.fromRGBO(4, 133, 247, 0.16)),
        dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
      ),
      'failed' => (
        '发送失败',
        dk(context, Color(0xFFFDECEC), Color.fromRGBO(243, 18, 96, 0.16)),
        dk(context, Color(0xFFC81E45), Color(0xFFFB7185)),
      ),
      'skipped' => (
        '已跳过',
        dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
      ),
      'unrecorded' => (
        '未记录',
        dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
      ),
      _ => (
        '未开启',
        dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
      ),
    };
    final channelBg = isWechat
        ? dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16))
        : dk(context, Color(0xFFE8F2FC), Color.fromRGBO(4, 133, 247, 0.16));
    final channelInk = isWechat
        ? dk(context, Color(0xFF2B7745), Color(0xFF5FD48C))
        : dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA));

    return hbox(
      minH: 60,
      pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: hrow(
        [
          hbox(
            w: 36,
            h: 36,
            bg: channelBg,
            radius: BorderRadius.circular(18),
            align: Alignment(0, 0),
            child: Text(
              isWechat ? '微信' : '短信',
              style: hts(11, channelInk, w: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 1,
            child: hcol(
              [
                Text(
                  title,
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w500,
                    lh: 20,
                  ),
                ),
                Text(
                  '${row['subtitle'] ?? '—'}',
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 1,
            ),
          ),
          hbox(
            bg: badgeBg,
            radius: BorderRadius.circular(9),
            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              badgeLabel,
              style: hts(11, badgeInk, w: FontWeight.w600, lh: 18),
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    );
  }

  String _noticeTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';
    final bj = parsed.toUtc().add(const Duration(hours: 8));
    final now = bookingToday;
    final hhmm =
        '${bj.hour.toString().padLeft(2, '0')}:${bj.minute.toString().padLeft(2, '0')}';
    if (bj.year == now.year && bj.month == now.month && bj.day == now.day) {
      return '今天 $hhmm';
    }
    final mm = bj.month.toString().padLeft(2, '0');
    final dd = bj.day.toString().padLeft(2, '0');
    return bj.year == now.year ? '$mm-$dd $hhmm' : '${bj.year}-$mm-$dd $hhmm';
  }
}
