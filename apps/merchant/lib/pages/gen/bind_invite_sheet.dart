import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class BindInviteSheet extends StatelessWidget {
  const BindInviteSheet({super.key});

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
              Expanded(
                flex: 1,
                child: Text(
                  '发送绑定邀请',
                  style: hts(
                    20,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 28,
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 0,
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
                  bg: dk(
                    context,
                    Color(0xFFE1F0FE),
                    Color.fromRGBO(4, 133, 247, 0.18),
                  ),
                  radius: BorderRadius.circular(20),
                  align: Alignment(0, 0),
                  child: Text(
                    '李',
                    style: hts(
                      16,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '李女士',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      Text(
                        '139 **** 5530',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
                    '短信',
                    style: hts(
                      11,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      w: FontWeight.w600,
                      lh: 18,
                    ),
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
              Text(
                '短信预览',
                style: hts(
                  13,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w600,
                  lh: 18,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: hbox(
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Text(
                    '【驰光汽车】李女士您好，点击链接绑定微信会员，随时查看余额、次卡和消费记录：https://qm.link/Ab3x 退订回T',
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      lh: 21,
                    ),
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 6,
          ),
          hcol(
            [
              Text(
                '· 链接 7 天内有效，会员点开并验证手机号即完成绑定',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 18,
                ),
              ),
              Text(
                '· 本条按 1 条短信计费，约 ¥0.06',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 18,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 4,
          ),
          hrow(
            [
              Expanded(
                flex: 1,
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
                  to: 'PayUnbound',
                ),
              ),
              Expanded(
                flex: 2,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '发送邀请',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'PayUnbound',
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
        gap: 16,
      ),
    );
  }
}
