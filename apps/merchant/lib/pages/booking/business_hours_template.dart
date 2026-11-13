import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import 'booking_settings_controller.dart';
import '../../resources/merchant_svgs.dart';

class BusinessHoursTemplate extends StatelessWidget {
  final BookingSettingsController c;
  const BusinessHoursTemplate({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1171,
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
                      svg: dk(context, Svgs.s0, Svgs.s1),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '营业时间与工位',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AppButton(
                      label: '保存',
                      loading: c.saving,
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => c.save(context),
                    ),
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      Text(
                        '营业时间',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => c.pickSettingTime(
                                context,
                                'opens_at',
                                '选择开始时间',
                              ),
                              child: hbox(
                                h: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                child: Align(
                                  alignment: Alignment(0, 0),
                                  widthFactor: 1,
                                  child: Text(
                                    '${c.settings['opens_at']}',
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '至',
                            style: hts(
                              16,
                              dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => c.pickSettingTime(
                                context,
                                'closes_at',
                                '选择结束时间',
                              ),
                              child: hbox(
                                h: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                child: Align(
                                  alignment: Alignment(0, 0),
                                  widthFactor: 1,
                                  child: Text(
                                    '${c.settings['closes_at']}',
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 10,
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                      Text(
                        '营业日',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      AppChoiceGroup<int>.multiple(
                        items: [
                          ChoiceItem(value: 0, label: '周一'),
                          ChoiceItem(value: 1, label: '周二'),
                          ChoiceItem(value: 2, label: '周三'),
                          ChoiceItem(value: 3, label: '周四'),
                          ChoiceItem(value: 4, label: '周五'),
                          ChoiceItem(value: 5, label: '周六'),
                          ChoiceItem(value: 6, label: '周日'),
                        ],
                        selectedValues: {
                          for (var i = 0; i < 7; i++)
                            if (!(c.settings['closed_days'] as List).contains(
                              i + 1,
                            ))
                              i,
                        },
                        onChanged: (values) => c.setSetting('closed_days', [
                          for (var i = 0; i < 7; i++)
                            if (!values.contains(i)) i + 1,
                        ]),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '节假日',
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
                      child: hcol(
                        [
                          // TODO: 节假日 / 休息日设置不在本次范围，预期后端接口：holiday_rules（列表 / 保存）。
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '节假日设置尚未接通',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          AppButton(
                            label: '添加休息日',
                            kind: AppButtonKind.text,
                            size: AppButtonSize.medium,
                            onPressed: () => c.deferred(context),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
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
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '工位 · 共 ${c.rows.length} 个',
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
                      child: hcol(
                        [
                          if (c.rows.isEmpty)
                            const EmptyView(
                              title: '还没有工位',
                              message: '点击下方添加工位',
                              inline: true,
                            ),
                          for (
                            var rowIndex = 0;
                            rowIndex < c.rows.length;
                            rowIndex++
                          ) ...[
                            if (rowIndex > 0)
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  c.editResource(context, c.rows[rowIndex]),
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '${c.rows[rowIndex]['name']}',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                          Text(
                                            '${c.rows[rowIndex]['category']}',
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
                                        gap: 0,
                                      ),
                                    ),
                                    hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFDDF6E7),
                                        Color.fromRGBO(23, 201, 100, 0.16),
                                      ),
                                      radius: BorderRadius.circular(9),
                                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Text(
                                        c.rows[rowIndex]['active'] == true
                                            ? '可预约'
                                            : '已停用',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 18,
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                      ),
                                    ),
                                    hsvg(
                                      dk(context, Svgs.s3, Svgs.s4),
                                      w: 16,
                                      h: 16,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                AppButton(
                  label: '添加工位',
                  kind: AppButtonKind.primary,
                  size: AppButtonSize.large,
                  expanded: true,
                  svg: dk(context, Svgs.s56, Svgs.s57),
                  onPressed: () => c.editResource(context, null),
                ),
                Text(
                  '工位数量受套餐限制，当前专业版最多 20 个',
                  style: hts(
                    12,
                    dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                  ),
                  textAlign: TextAlign.center,
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
      overlays: [],
    );
  }
}
