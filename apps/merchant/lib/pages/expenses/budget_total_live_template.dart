import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import 'expense_widgets.dart';
import 'expense_controller.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class BudgetTotalLiveTemplate extends StatelessWidget {
  const BudgetTotalLiveTemplate({super.key, required this.c});
  final ExpenseController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1760,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: hcol(
              [
                hrow(
                  [
                    AppIconButton(
                      svg: dk(context, Svgs.s26, Svgs.s27),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '调整预算',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 44),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
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
                  pad: EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: hcol(
                    [
                      Text(
                        c.totalInputLabel,
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                      hrow(
                        [
                          Text(
                            '¥',
                            style: hts(
                              26,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              w: FontWeight.w600,
                              lh: 34,
                            ),
                          ),
                          Expanded(
                            child: hbox(
                              minW: 0,
                              child: ExpenseInput(
                                style: hts(
                                  38,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 46,
                                  ls: -1.14,
                                  tab: true,
                                ),
                                hint: '请输入总预算',
                                keyboard: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                value: '${c.total}',
                                onChanged: c.setTotal,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 6,
                      ),
                      hwrap(
                        [
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFE1F0FE),
                              Color.fromRGBO(4, 133, 247, 0.18),
                            ),
                            radius: BorderRadius.circular(9),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              c.previousBudgetText,
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF1E63AE),
                                  Color(0xFF6AB4FA),
                                ),
                                w: FontWeight.w600,
                                lh: 18,
                              ),
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFEEEEF0),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(9),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              c.revenueShareText,
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
                                w: FontWeight.w600,
                                lh: 18,
                              ),
                            ),
                          ),
                        ],
                        gap: 8,
                        rowGap: 8,
                        cross: WrapCrossAlignment.start,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 10,
                  ),
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
                  child: hcol(
                    [
                      Text(
                        '分配方式',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      AppChoiceGroup<int>(
                        items: [
                          ChoiceItem(value: 0, label: '手动分配'),
                          ChoiceItem(value: 1, label: '沿用上月预算'),
                          ChoiceItem(value: 2, label: '按上月实际'),
                          ChoiceItem(value: 3, label: '按营收比例'),
                        ],
                        selected: c.allocationMode,
                        onChanged: (i) => c.chooseAllocation(context, i),
                      ),
                      Text(
                        '选择后会自动填入各分类金额，仍可逐项修改',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 10,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '分类分配',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
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
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: c.allocationRows(context),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hbox(
                  bg: dk(
                    context,
                    Color(0xFFDDF6E7),
                    Color.fromRGBO(23, 201, 100, 0.16),
                  ),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: hrow(
                    [
                      hsvg(dk(context, Svgs.s54, Svgs.s55), w: 18, h: 18),
                      Expanded(
                        flex: 1,
                        child: Text(
                          c.allocationTextSummary,
                          style: hts(
                            14,
                            Color(0xFF1E5C34),
                            w: FontWeight.w600,
                            lh: 20,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 10,
                  ),
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
                  child: hcol(
                    [
                      Text(
                        '生效范围',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      AppChoiceGroup<int>(
                        items: [
                          ChoiceItem(value: 0, label: '仅本月'),
                          ChoiceItem(value: 1, label: '本月起每月沿用'),
                        ],
                        selected: c.budget['carry'] == true ? 1 : 0,
                        onChanged: (i) => c.setBudgetCarry(i == 1),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 10,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 16,
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
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
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
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: AppButton(
                    label: '取消',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ActionButton(
                    actionKey: c.saveKey,
                    label: '保存预算',
                    kind: AppButtonKind.primary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => c.save(context),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}
