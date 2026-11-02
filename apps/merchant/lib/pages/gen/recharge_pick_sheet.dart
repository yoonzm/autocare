import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class RechargePickSheet extends StatelessWidget {
  const RechargePickSheet({super.key});

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
            '选择次卡套餐',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hPackagePicker(),
          Text(
            '已下架的套餐不可售卖，不在此列出',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 17,
            ),
          ),
          hTap(
            context,
            hbox(
              h: 48,
              bg: Color(0xFF0485F7),
              radius: BorderRadius.circular(24),
              child: Align(
                alignment: Alignment(0, 0),
                widthFactor: 1,
                child: Text(
                  '确定',
                  style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600),
                ),
              ),
            ),
            to: 'RechargeCard',
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
