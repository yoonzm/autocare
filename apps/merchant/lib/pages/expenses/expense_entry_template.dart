import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'expense_controller.dart';
import '../../resources/merchant_svgs.dart';

class ExpenseEntryTemplate extends StatelessWidget {
  final ExpenseController c;
  final Map<String, dynamic> record;
  const ExpenseEntryTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => c.openDetail(context, record),
    child: hbox(
      minH: 64,
      pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
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
              [hsvg(dk(context, Svgs.s146, Svgs.s147), w: 20, h: 20)],
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
                  hrow(
                    [
                      Flexible(
                        flex: 60,
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
                      Flexible(
                        flex: 60,
                        child: hbox(
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(9),
                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Text(
                            c.entryStatus(record),
                            style: hts(
                              11,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
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
                    '${record['payee']} · ${record['account']}',
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 3,
              ),
            ),
          ),
          Text(
            '−${expenseMoney(record['amount'])}',
            style: hts(
              15,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 22,
              tab: true,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    ),
  );
}
