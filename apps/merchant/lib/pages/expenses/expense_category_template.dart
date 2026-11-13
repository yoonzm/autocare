import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'expense_controller.dart';
import '../../resources/merchant_svgs.dart';

class ExpenseCategoryTemplate extends StatelessWidget {
  final ExpenseController c;
  final Map<String, dynamic> record;
  const ExpenseCategoryTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => c.editCategory(context, record['category']),
    child: hbox(
      pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: hcol(
        [
          hrow(
            [
              hbox(
                w: 32,
                h: 32,
                bg: dk(
                  context,
                  Color(0xFFE1F0FE),
                  Color.fromRGBO(4, 133, 247, 0.18),
                ),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s42, Svgs.s43), w: 17, h: 17)],
                  main: MainAxisAlignment.center,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${record['category']}',
                  style: hts(
                    15,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w500,
                    lh: 22,
                  ),
                ),
              ),
              Text(
                '${record['amount'] == 0 ? 0 : (c.spent(record['category']) * 100 / (record['amount'] as num)).round()}%',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 16,
                ),
              ),
              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
          hbox(
            h: 6,
            bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
            radius: BorderRadius.circular(3),
            child: hcol(
              [
                hbox(
                  h: 6,
                  bg: Color(0xFFF5A524),
                  radius: BorderRadius.circular(3),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
              min: false,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: Text(
                  '已用 ${expenseMoney(c.spent(record['category']))} · 预算 ${expenseMoney(record['amount'])}',
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                ),
              ),
              Text(
                '${record['threshold']}% 提醒',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 16,
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
        gap: 8,
      ),
    ),
  );
}
