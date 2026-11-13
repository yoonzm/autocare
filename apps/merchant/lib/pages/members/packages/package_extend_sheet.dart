import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../../kit/buttons.dart';
import 'member_package_host.dart';
import 'member_package_route_data.dart';
import 'member_package_controller.dart';

import 'package:flutter/material.dart';

import '../../../kit/kit.dart';

class PackageExtendSheet extends StatelessWidget {
  final MemberPackageRouteData? data;
  const PackageExtendSheet({super.key, this.data});
  @override
  Widget build(BuildContext context) => MemberPackageHost(
    key: ValueKey(data?.id),
    data: data,
    detail: false,
    builder: (c) => _PackageExtendSheetTemplate(c: c),
  );
}

class _PackageExtendSheetTemplate extends StatelessWidget {
  final MemberPackageController c;
  const _PackageExtendSheetTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    final k = c.view;
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
            '延长有效期',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          Text(
            k.extendSubtitle,
            style: hts(
              13,
              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
              lh: 20,
            ),
          ),
          hcol(
            [
              Text(
                '延长时间',
                style: hts(
                  13,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '30 天'),
                  ChoiceItem(value: 1, label: '60 天'),
                  ChoiceItem(value: 2, label: '90 天'),
                  ChoiceItem(value: 3, label: '自定义'),
                ],
                selected: c.daysIndex,
                onChanged: (i) => c.chooseDays(context, i),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 8,
          ),
          hcol(
            [
              hbox(
                minH: 42,
                child: hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '延期后到期日',
                        style: hts(
                          14,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                        ),
                      ),
                    ),
                    Text(
                      k.extendedExpiry,
                      style: hts(
                        15,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
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
          hcol(
            [
              Text(
                '延期原因',
                style: hts(
                  13,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '会员长期出差'),
                  ChoiceItem(value: 1, label: '门店服务延误'),
                  ChoiceItem(value: 2, label: '其他'),
                ],
                selected: c.reasonIndex,
                onChanged: c.chooseReason,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 8,
          ),
          Text(
            '延期会记录在使用记录中，会员将收到微信通知。',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 18,
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 10,
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
                  flex: 14,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey: c.actionKey,
                      label: '确认延期',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => c.submit(context),
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
        gap: 14,
      ),
    );
  }
}
