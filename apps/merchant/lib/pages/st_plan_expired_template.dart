// 从员工端设计稿生成页派生（tools/bind_st.py），仅绑定数据和事件；不手工修改 gen_st/。
import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import 'gen_st/svgs.dart';

class StPlanExpiredTemplate extends StatelessWidget {
  const StPlanExpiredTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    final ends = '${Access.context['plan_ends_at'] ?? ''}';
    final day = ends.length >= 10 ? ends.substring(0, 10).replaceAll('-', '.') : '—';
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(24, 150, 24, 0),
            child: hcol(
              [
                hbox(
                  w: 88,
                  h: 88,
                  bg: dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16)),
                  radius: BorderRadius.circular(28),
                  child: hrow(
                    [hsvg(dk(context, Svgs.s100, Svgs.s101), w: 40, h: 40)],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    '门店套餐已到期',
                    style: hts(
                      20,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  '${Access.storeName}的套餐已于 $day 到期，开单、预约和任务更新暂时不可用。续费需要由老板在 App 内完成，请联系老板。',
                  style: hts(14, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 21),
                  textAlign: TextAlign.center,
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: hcol(
                    [
                      Text(
                        '你的数据都在',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      Text(
                        '施工记录、业绩和提成已保留，门店续费后立即恢复使用。',
                        style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 19),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 6,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 14,
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
            bg: dk(context, Color.fromRGBO(255, 255, 255, 0.94), Color.fromRGBO(9, 9, 11, 0.92)),
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
            child: hcol(
              [
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
                              '联系老板',
                              style: hts(
                                15,
                                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => AppToast.show(context, '请联系老板在 App 内续费'),
                      ),
                    ),
                    Expanded(
                      flex: 14,
                      child: hTap(
                        context,
                        hbox(
                          h: 50,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(25),
                          child: Align(
                            alignment: Alignment(0, 0),
                            widthFactor: 1,
                            child: hBusy(
                              'StPlanExpired>refresh',
                              Text(
                                '刷新状态',
                                style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22),
                              ),
                              style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22),
                              label: '提交中…',
                            ),
                          ),
                        ),
                        onTap: () => runBusy('StPlanExpired>refresh', () async {
                          try {
                            await AccessFlow.refresh(context);
                          } catch (e) {
                            if (context.mounted) AccessFlow.toastError(context, e);
                          }
                        }),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 10,
                ),
                hTap(
                  context,
                  hbox(
                    pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: Text(
                      '退出登录',
                      style: hts(
                        13,
                        dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                        w: FontWeight.w500,
                        lh: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () => AccessFlow.signOut(context),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// 门店套餐到期（员工只读）：续费只能由老板完成。
class StPlanExpiredLivePage extends StatelessWidget {
  const StPlanExpiredLivePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const PopScope(canPop: false, child: StPlanExpiredTemplate());
}
