import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class MemberDeleteSheet extends StatelessWidget {
  const MemberDeleteSheet({super.key});

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
          hMemberText(
            (m) => '删除会员 ${m.name}？',
            '删除会员 王建国？',
            hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hMemberText(
            (m) => '将永久删除会员 ${m.name} 的档案、车辆与次卡。以下数据无法随会员一并删除：',
            '将永久删除会员 王建国 的档案、车辆与次卡。以下数据无法随会员一并删除：',
            hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 20),
          ),
          hcol(
            [
              Text(
                '· 历史订单与财务流水会保留，会员显示为“已删除会员”',
                style: hts(
                  13,
                  dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                  lh: 19,
                ),
              ),
              hMemberText(
                (m) => '· 储值余额将作废，请先线下退还或转为消费',
                '· 储值余额 ¥3,680.00 将作废，请先线下退还或转为消费',
                hts(
                  13,
                  dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                  lh: 19,
                ),
              ),
              Text(
                '· 删除后无法恢复，也无法再收到微信通知',
                style: hts(
                  13,
                  dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                  lh: 19,
                ),
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
                          '再想想',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'MemberMore',
                  ),
                ),
              ),
              Expanded(
                flex: 14,
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
                        child: hBusy(
                          'MemberDelete>Members',
                          Text(
                            '确认删除',
                            style: hts(
                              15,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              w: FontWeight.w500,
                              lh: 22,
                            ),
                          ),
                          style: hts(
                            15,
                            dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                          label: '提交中…',
                        ),
                      ),
                    ),
                    to: 'Members',
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
