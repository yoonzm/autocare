import 'scan_result.dart';
import '../../kit/async_kit.dart';
import '../members/member_route_data.dart';
import '../orders/order_route_data.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class FindNotFoundSheet extends StatelessWidget {
  final ScanResult? result;
  final VoidCallback? onCreate;
  const FindNotFoundSheet({super.key, this.onCreate, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return ErrorView(error: const AppError('请先扫描车牌'));
    final v = ScanView(result!);
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
                w: 44,
                h: 44,
                bg: dk(
                  context,
                  Color(0xFFFDEFD6),
                  Color.fromRGBO(245, 165, 36, 0.16),
                ),
                radius: BorderRadius.circular(22),
                child: hrow(
                  [hsvg(dk(context, Svgs.s410, Svgs.s411), w: 22, h: 22)],
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
              ),
              Expanded(
                flex: 1,
                child: hcol(
                  [
                    Text(
                      '没有找到该车牌的会员',
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
                            v.plate,
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
          Text(
            '这辆车还没有登记过，请选择接下来怎么处理：',
            style: hts(
              13,
              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
              lh: 19,
            ),
          ),
          hcol(
            [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap:
                    onCreate ??
                    () => openRoute(
                      context,
                      'MemberAdd',
                      arguments: MemberRouteData(
                        vehicle: {
                          'plate': result!.rawPlate,
                          'brand_model': result!.data['vehicle_model'],
                          'color': result!.data['vehicle_color'],
                        },
                      ),
                    ),
                child: hbox(
                  bg: Color(0xFF0485F7),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(
                          context,
                          Color.fromRGBO(255, 255, 255, 0.2),
                          Color.fromRGBO(9, 9, 11, 0.92),
                        ),
                        radius: BorderRadius.circular(20),
                        child: hrow(
                          [hsvg(Svgs.s412, w: 22, h: 22)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '创建会员',
                              style: hts(
                                15,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                            hbox(
                              opacity: .8,
                              child: Text(
                                '车牌 ${v.plate} 将自动带入',
                                style: hts(12, Color(0xFFFFFFFF), lh: 17),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                      hsvg(Svgs.s413, w: 18, h: 18),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openRoute(
                  context,
                  'Order',
                  arguments: OrderRouteData(
                    walkIn: true,
                    plate: result!.rawPlate,
                  ),
                ),
                child: hbox(
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(20),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s414, Svgs.s415),
                              w: 22,
                              h: 22,
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '散客结账',
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
                            hbox(
                              opacity: .8,
                              child: Text(
                                '不记会员，无折扣和次卡抵扣',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 1,
                        ),
                      ),
                      hsvg(dk(context, Svgs.s416, Svgs.s417), w: 18, h: 18),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
          ),
          hrow(
            [
              Flexible(
                flex: 117,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Text(
                    '识别不对？重新扫描',
                    style: hts(
                      13,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 18,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 52,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openRoute(context, 'Members'),
                  child: Text(
                    '手动搜索',
                    style: hts(
                      13,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      w: FontWeight.w500,
                      lh: 18,
                    ),
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.start,
            gap: 24,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
