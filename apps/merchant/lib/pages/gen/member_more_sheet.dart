import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class MemberMoreSheet extends StatelessWidget {
  const MemberMoreSheet({super.key});

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
            '更多操作',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: hrow(
              [
                hbox(
                  w: 44,
                  h: 44,
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [Color(0xFFFFF1CF), Color(0xFFF5D78E)],
                    stops: [0, 1],
                  ),
                  radius: BorderRadius.circular(22),
                  align: Alignment(0, 0),
                  child: hMemberText(
                    (m) => m.avatar,
                    '王',
                    hts(17, Color(0xFF5C3D0A), w: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      hMemberText(
                        (m) => m.name,
                        '王建国',
                        hts(
                          16,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      hMemberText(
                        (m) => '${m.levelMember} · ${m.maskedPhone}',
                        '黑金会员 · 138 **** 6021',
                        hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
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
              hTap(
                context,
                hbox(
                  minH: 62,
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(13),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s220, Svgs.s221),
                              w: 20,
                              h: 20,
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
                              '编辑会员资料',
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
                              '姓名、手机号、生日、备注',
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
                      hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                to: 'MemberEdit',
              ),
              hbox(
                h: 1,
                bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                margin: EdgeInsets.fromLTRB(56, 0, 0, 0),
              ),
              hTap(
                context,
                hbox(
                  minH: 62,
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(
                          context,
                          Color(0xFFFDEFD6),
                          Color.fromRGBO(245, 165, 36, 0.16),
                        ),
                        radius: BorderRadius.circular(13),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s222, Svgs.s223),
                              w: 20,
                              h: 20,
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
                              '调整卡种与积分',
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
                              '升降级、积分增减需填写原因',
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
                      hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                to: 'MemberAdjust',
              ),
              hbox(
                h: 1,
                bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                margin: EdgeInsets.fromLTRB(56, 0, 0, 0),
              ),
              hTap(
                context,
                hbox(
                  minH: 62,
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(
                          context,
                          Color(0xFFDDF6E7),
                          Color.fromRGBO(23, 201, 100, 0.16),
                        ),
                        radius: BorderRadius.circular(13),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s224, Svgs.s225),
                              w: 20,
                              h: 20,
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
                              '发起回访',
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
                              '电话或微信回访并记录',
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
                      hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                to: 'MemberVisit',
              ),
              hbox(
                h: 1,
                bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                margin: EdgeInsets.fromLTRB(56, 0, 0, 0),
              ),
              hTap(
                context,
                hbox(
                  minH: 62,
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(13),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s226, Svgs.s227),
                              w: 20,
                              h: 20,
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
                              '发送微信通知',
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
                              '活动、到期提醒等',
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
                      hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                to: 'MemberSendMsg',
              ),
              hbox(
                h: 1,
                bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                margin: EdgeInsets.fromLTRB(56, 0, 0, 0),
              ),
              hTap(
                context,
                hbox(
                  minH: 62,
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hrow(
                    [
                      hbox(
                        w: 40,
                        h: 40,
                        bg: dk(
                          context,
                          Color(0xFFFFE1E2),
                          Color.fromRGBO(255, 56, 60, 0.18),
                        ),
                        radius: BorderRadius.circular(13),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s228, Svgs.s229),
                              w: 20,
                              h: 20,
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
                              '删除会员',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFA43433),
                                  Color(0xFFFF7B7E),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '删除后不可恢复，历史订单保留',
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
                      hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                to: 'MemberDelete',
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
