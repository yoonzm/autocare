import 'expense_widgets.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'expense_controller.dart';
import '../../resources/merchant_svgs.dart';

class ExpenseAllocationTemplate extends StatelessWidget {
  final ExpenseController c;
  final String categoryKey;
  const ExpenseAllocationTemplate({
    super.key,
    required this.c,
    required this.categoryKey,
  });
  @override
  Widget build(BuildContext context) => switch (categoryKey) {
    '房租' => hbox(
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
                child: hcol(
                  [
                    Text(
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
    '人工' => hbox(
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
                  Color(0xFFDDF6E7),
                  Color.fromRGBO(23, 201, 100, 0.16),
                ),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s44, Svgs.s45), w: 17, h: 17)],
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
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
    '材料采购' => hbox(
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
                  [hsvg(dk(context, Svgs.s46, Svgs.s47), w: 17, h: 17)],
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
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
    '水电' => hbox(
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
                  Color(0xFFFDEFD6),
                  Color.fromRGBO(245, 165, 36, 0.16),
                ),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s48, Svgs.s49), w: 17, h: 17)],
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
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
    '营销推广' => hbox(
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
                  Color(0xFFFFE1E2),
                  Color.fromRGBO(255, 56, 60, 0.18),
                ),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s50, Svgs.s51), w: 17, h: 17)],
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
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
    _ => hbox(
      pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: hcol(
        [
          hrow(
            [
              hbox(
                w: 32,
                h: 32,
                bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(dk(context, Svgs.s52, Svgs.s53), w: 17, h: 17)],
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
                      categoryKey,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 22,
                      ),
                    ),
                    Text(
                      c.allocationText(categoryKey),
                      style: hts(
                        11,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
                ),
              ),
              hbox(
                h: 38,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(12),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Flexible(
                      flex: 6,
                      child: Text(
                        '¥',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ),
                    hbox(
                      w: 70,
                      child: ExpenseInput(
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                        hint: '请输入$categoryKey预算',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                        value: '${c.categories[categoryKey]?['amount'] ?? 0}',
                        onChanged: (v) => c.setCategoryAmount(categoryKey, v),
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
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    ),
  };
}
