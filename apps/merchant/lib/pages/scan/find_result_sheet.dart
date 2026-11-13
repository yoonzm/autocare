import '../../kit/buttons.dart';
import 'scan_result.dart';
import '../../kit/async_kit.dart';
import '../members/member_view.dart';
import '../members/member_route_data.dart';
import '../orders/order_route_data.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class FindResultSheet extends StatelessWidget {
  final ScanResult? result;
  final VoidCallback? onViewMember, onOrderMember;
  const FindResultSheet({
    super.key,
    this.result,
    this.onViewMember,
    this.onOrderMember,
  });

  @override
  Widget build(BuildContext context) {
    if (result?.member == null) {
      return ErrorView(error: const AppError('请先扫描车牌'));
    }
    final v = ScanView(result!);
    final m = MemberView(result!.member ?? {});
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
                child: hrow(
                  [
                    Flexible(
                      flex: 53,
                      child: hbox(
                        bg: Color(0xFF1A4FC4),
                        radius: BorderRadius.circular(3),
                        border: Border.all(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          width: 1,
                        ),
                        pad: EdgeInsets.fromLTRB(4, 2, 4, 2),
                        child: Text(
                          v.plate,
                          style: hts(9, Color(0xFFFFFFFF), w: FontWeight.w600),
                        ),
                      ),
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
                      '已匹配到会员',
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
          hbox(
            bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
            radius: BorderRadius.circular(20),
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hrow(
              [
                hbox(
                  w: 44,
                  h: 44,
                  bg: Color(0xFFF5D78E),
                  radius: BorderRadius.circular(22),
                  align: Alignment(0, 0),
                  child: Text(
                    m.avatar,
                    style: hts(
                      17,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
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
                            flex: 48,
                            child: Text(
                              m.name,
                              style: hts(
                                16,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 58,
                            child: hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                              child: Text(
                                m.levelMember,
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
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 6,
                      ),
                      Text(
                        m.maskedPhone,
                        style: hts(
                          12,
                          dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          lh: 16,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                  ),
                ),
                hcol(
                  [
                    Text(
                      '储值余额',
                      style: hts(
                        11,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      ),
                    ),
                    Text(
                      m.balanceText,
                      style: hts(
                        17,
                        Color(0xFFFAFAFA),
                        w: FontWeight.w600,
                        lh: 24,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.end,
                  gap: 0,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
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
                    ),
                    Text(
                      v.plateKind,
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
                        '车型',
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
                        v.vehicleModel,
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
                        '次卡',
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
                        v.packageSummary,
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
                        '上次到店',
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
                        v.lastVisit,
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
              Color(0xFFE1F0FE),
              Color.fromRGBO(4, 133, 247, 0.18),
            ),
            radius: BorderRadius.circular(14),
            pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s158, Svgs.s159), w: 16, h: 16),
                Flexible(
                  flex: 312,
                  child: Text(
                    '未找到车牌时，可点「手动搜索」，或为新车主新增会员。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
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
          hrow(
            [
              Expanded(
                flex: 10,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: AppButton(
                    label: '查看会员',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => openRoute(
                      context,
                      'MemberDetail',
                      arguments: MemberRouteData(member: result!.member),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: AppButton(
                    label: '为他开单',
                    kind: AppButtonKind.primary,
                    size: AppButtonSize.large,
                    expanded: true,
                    svg: Svgs.s160,
                    onPressed: () => openRoute(
                      context,
                      'Order',
                      arguments: OrderRouteData(member: result!.member),
                    ),
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
            intrinsic: true,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AppButton(
              label: '识别不对？重新扫描',
              kind: AppButtonKind.text,
              size: AppButtonSize.medium,
              expanded: false,
              onPressed: () => Navigator.of(context).maybePop(),
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
