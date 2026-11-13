import '../../kit/buttons.dart';
import 'expense_widgets.dart';
import '../../kit/single_selection.dart';
import 'expense_controller.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class BudgetAdjustLiveTemplate extends StatelessWidget {
  const BudgetAdjustLiveTemplate({super.key, required this.c});
  final ExpenseController c;

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
            c.adjustTitle,
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          SingleSelection(
            index: c.summaryMetric,
            onChanged: (i) => c.setSummaryMetric(i),
            builder: (context, selection) => hrow(
              [
                Expanded(
                  flex: 1,
                  child: HSel(
                    ctrl: selection,
                    index: 0,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFFFE1E2),
                        Color.fromRGBO(255, 56, 60, 0.18),
                      ),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '当前预算',
                            style: hts(
                              11,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            c.categoryAmountText,
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '当前预算',
                            style: hts(
                              11,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            c.categoryAmountText,
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: HSel(
                    ctrl: selection,
                    index: 1,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFFFE1E2),
                        Color.fromRGBO(255, 56, 60, 0.18),
                      ),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '已用',
                            style: hts(
                              11,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            expenseMoney(c.spent(c.category)),
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '已用',
                            style: hts(
                              11,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            expenseMoney(c.spent(c.category)),
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: HSel(
                    ctrl: selection,
                    index: 2,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFFFE1E2),
                        Color.fromRGBO(255, 56, 60, 0.18),
                      ),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '超支',
                            style: hts(
                              11,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            c.categoryExcessText,
                            style: hts(
                              15,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(16),
                      pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: hcol(
                        [
                          Text(
                            '超支',
                            style: hts(
                              11,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              lh: 14,
                            ),
                          ),
                          Text(
                            c.categoryExcessText,
                            style: hts(
                              15,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
              intrinsic: true,
            ),
          ),
          hcol(
            [
              Text(
                '追加金额',
                style: hts(
                  14,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w600,
                  lh: 20,
                ),
              ),
              hrow(
                [
                  Text(
                    '¥',
                    style: hts(
                      22,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      w: FontWeight.w600,
                      lh: 30,
                    ),
                  ),
                  Expanded(
                    child: hbox(
                      minW: 0,
                      child: ExpenseInput(
                        style: hts(
                          32,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 40,
                          tab: true,
                        ),
                        hint: '请输入追加金额',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        value: c.adjustment == 0 ? '' : '${c.adjustment}',
                        onChanged: c.setAdjustment,
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.baseline,
                gap: 6,
              ),
              SingleSelection(
                index: c.adjustmentPreset,
                onChanged: (i) => c.chooseAdjustment(i),
                builder: (context, selection) => hwrap(
                  [
                    HSel(
                      ctrl: selection,
                      index: 0,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            c.fillExcessText,
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            c.fillExcessText,
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: selection,
                      index: 1,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥5,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥5,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: selection,
                      index: 2,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥8,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '¥8,000',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 8,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '资金来源',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              SingleSelection(
                index: c.adjustSource,
                onChanged: (i) => c.setAdjustSource(i),
                builder: (context, selection) => hwrap(
                  [
                    HSel(
                      ctrl: selection,
                      index: 0,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            c.reserveText,
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            c.reserveText,
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: selection,
                      index: 1,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '其他分类调剂',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '其他分类调剂',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: selection,
                      index: 2,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '追加总预算',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '追加总预算',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => c.pickBudgetSource(context),
            child: hbox(
              bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
              radius: BorderRadius.circular(16),
              pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      c.sourceLabel,
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 20,
                      ),
                    ),
                  ),
                  Text(
                    c.sourceAvailableText,
                    style: hts(
                      13,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 18,
                    ),
                  ),
                  hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 12,
              ),
            ),
          ),
          hcol(
            [
              Text(
                '追加原因',
                style: hts(
                  14,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w600,
                  lh: 20,
                ),
              ),
              hbox(
                minH: 56,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(14),
                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: ExpenseInput(
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    lh: 20,
                  ),
                  maxLines: 4,
                  hint: '请输入追加原因',
                  value: c.reason,
                  onChanged: c.setReason,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 6,
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: AppButton(
                      label: '取消',
                      kind: AppButtonKind.secondary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey: c.saveKey,
                      label: '确认追加',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => c.save(context),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 16,
      ),
    );
  }
}
