import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import '../../kit/single_selection.dart';

// 库存预警配置：显式状态和事件，沿用现有布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockAlertSettingsBoundTemplate extends StatelessWidget {
  const StockAlertSettingsBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
            child: SingleSelection(
              index: c.expiryIndex,
              onChanged: c.selectExpiry,
              builder: (context, selection) => hcol(
                [
                  hrow(
                    [
                      AppIconButton(
                        svg: dk(context, Svgs.s0, Svgs.s1),
                        semanticLabel: "返回",
                        onPressed: c.busy
                            ? null
                            : () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '库存预警设置',
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
                    pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      '提醒开关',
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
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '低库存提醒',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '低于每个商品的安全库存时提醒',
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
                              HSwitchValue(
                                value: c.settings['low_enabled'] == true,
                                onChanged: (value) =>
                                    c.setAlert(context, 'low_enabled', value),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        hbox(
                          h: 1,
                          bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                          margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                        ),
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '临期提醒',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '按每个商品设置的提醒天数',
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
                              HSwitchValue(
                                value: c.settings['expiry_enabled'] == true,
                                onChanged: (value) => c.setAlert(
                                  context,
                                  'expiry_enabled',
                                  value,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
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
                        hcol(
                          [
                            Text(
                              '默认临期天数',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '新增商品、未单独设置时使用',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 17,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 2,
                        ),
                        hcol(
                          [
                            Text(
                              '提前',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                            ),
                            ListenableBuilder(
                              listenable: selection,
                              builder: (context, _) => AppChoiceGroup<int>(
                                items: [
                                  ChoiceItem(value: 0, label: '7 天'),
                                  ChoiceItem(value: 1, label: '15 天'),
                                  ChoiceItem(value: 2, label: '30 天'),
                                  ChoiceItem(value: 3, label: '60 天'),
                                ],
                                selected: selection.selected.firstOrNull,
                                onChanged: selection.tap,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 8,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                  ),
                  hbox(
                    pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: Text(
                      '提醒方式',
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
                        ...[
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '首页卡片',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 20,
                                        ),
                                      ),
                                      Text(
                                        '「待补货」「即将过期」显示在首页',
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
                                HSwitchValue(
                                  value: c.settings['home_enabled'] == true,
                                  onChanged: (value) => c.setAlert(
                                    context,
                                    'home_enabled',
                                    value,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
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
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        'App 消息推送',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 20,
                                        ),
                                      ),
                                      Text(
                                        '每天早上 9:00 汇总一条',
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
                                HSwitchValue(
                                  value: c.settings['message_enabled'] == true,
                                  onChanged: (value) => c.setAlert(
                                    context,
                                    'message_enabled',
                                    value,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
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
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '微信服务通知',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 20,
                                        ),
                                      ),
                                      Text(
                                        '发给店主和店长',
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
                                HSwitchValue(
                                  value: c.settings['wechat_enabled'] == true,
                                  onChanged: (value) => c.setAlert(
                                    context,
                                    'wechat_enabled',
                                    value,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                        ],
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
                    ),
                  ),
                  hbox(
                    pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      '每个商品的安全库存在「编辑商品」里单独设置',
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 16,
              ),
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
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey: c.actionKey,
                      label: '保存',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: c.busy ? null : () => c.saveSettings(context),
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
        ),
      ],
    );
  }
}
