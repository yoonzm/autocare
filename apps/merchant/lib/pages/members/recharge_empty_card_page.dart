import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import '../../kit/buttons.dart';
import 'packages/package_choices.dart' show PackageChoices;
import 'wallet_controller.dart';
import 'wallet_page.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class RechargeEmptyCardPage extends StatelessWidget {
  final WalletController? controller;
  const RechargeEmptyCardPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return const WalletPage(initial: 1);
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
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
                        '会员充值',
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
                AppSegmented<int>(
                  items: const [
                    SegmentItem(value: 0, label: '储值充值'),
                    SegmentItem(value: 1, label: '购买次卡'),
                  ],
                  selected: 1,
                  onChanged: c.selectTab,
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => c.chooseMember(context),
                        child: hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Color(0xFFBFDDFB),
                            width: 2,
                          ),
                          pad: EdgeInsets.fromLTRB(16, 18, 16, 18),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(22),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s404, Svgs.s405),
                                      w: 22,
                                      h: 22,
                                    ),
                                  ],
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
                                      '选择会员',
                                      style: hts(
                                        16,
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
                                      '输入车牌、手机号或姓名查找',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 17,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              hsvg(
                                dk(context, Svgs.s406, Svgs.s407),
                                w: 18,
                                h: 18,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 10,
                  intrinsic: true,
                ),
                hbox(
                  opacity: .45,
                  child: hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '选择套餐',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
                          ),
                        ),
                      ),
                      PackageChoices(
                        packages: c.packages,
                        selectedId: c.packageId,
                        onSelected: c.selectPackage,
                        limit: 3,
                        readOnly: true,
                      ),
                      Text(
                        c.saleAll,
                        style: hts(
                          13,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                          lh: 18,
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
            child: hcol(
              [
                Align(
                  alignment: Alignment.topLeft,
                  child: AppButton(
                    label: '请先选择会员',
                    kind: AppButtonKind.primary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => c.chooseMember(context),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
        ),
      ],
    );
  }
}
