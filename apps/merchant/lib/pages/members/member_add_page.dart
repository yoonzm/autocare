import '../../kit/buttons.dart';
import 'member_tier_preview.dart';
import '../../kit/text_input.dart';
import '../../theme.dart' show C;
import 'member_form_controller.dart';
import 'member_form_host.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../widgets/choice_controls.dart';
import '../../widgets/color_fields.dart';
import '../../resources/merchant_svgs.dart';

class MemberAddPage extends StatelessWidget {
  final Map<String, dynamic>? member, vehicle;
  const MemberAddPage({super.key, this.member, this.vehicle});
  @override
  Widget build(BuildContext context) => MemberFormHost(
    key: ValueKey('create-${member?['id']}'),
    kind: MemberFormKind.create,
    member: member,
    vehicle: vehicle,
    builder: (c) => _MemberAddPageTemplate(c: c),
  );
}

class _MemberAddPageTemplate extends StatelessWidget {
  final MemberFormController c;
  const _MemberAddPageTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1200,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: hcol(
              [
                hrow(
                  [
                    AppIconButton(
                      svg: dk(context, Svgs.s71, Svgs.s72),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '新增会员',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ActionButton(
                      actionKey: c.actionKey,
                      label: '保存',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => c.submit(context),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => c.scanVehicle(context),
                  child: hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                    radius: BorderRadius.circular(22),
                    pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: hrow(
                      [
                        hbox(
                          w: 40,
                          h: 40,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(12),
                          child: hrow(
                            [hsvg(Svgs.s206, w: 22, h: 22)],
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
                                '扫描车牌快速建档',
                                style: hts(
                                  15,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w500,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '自动识别车牌、车型、车架号',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 2,
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
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '客户信息',
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
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 64,
                                  child: Text.rich(
                                    TextSpan(
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '手机号 ',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFF52525B),
                                              Color(0xFFA8A8B3),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '*',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AppTextInput(
                                    controller: c.input('phone'),
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '请输入手机号',
                                    keyboard: TextInputType.phone,
                                    align: TextAlign.right,
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
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 64,
                                  child: Text.rich(
                                    TextSpan(
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '姓名 ',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFF52525B),
                                              Color(0xFFA8A8B3),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '*',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AppTextInput(
                                    controller: c.input('name'),
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '请输入客户姓名',
                                    align: TextAlign.right,
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
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '称呼',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                HSegmented(
                                  labels: MemberFormController.honorifics,
                                  initial: 0,
                                  onChanged: (i) => c.set(
                                    'honorific',
                                    MemberFormController.honorifics[i],
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
                          Builder(
                            builder: (context) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => c.selectBirthday(context),
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '生日',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                          lh: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      c.text('birthday').isEmpty
                                          ? '选填，用于生日礼'
                                          : c.text('birthday'),
                                      style:
                                          (hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF71717A),
                                              Color(0xFF9A9AA3),
                                            ),
                                            lh: 22,
                                          )).copyWith(
                                            color: c.text('birthday').isEmpty
                                                ? C.muted
                                                : C.ink,
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
                        '车辆信息',
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
                      pad: EdgeInsets.fromLTRB(0, 16, 0, 4),
                      child: hcol(
                        [
                          HPlate(controller: c.plate),
                          hcol(
                            [
                              Builder(
                                builder: (context) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => c.selectCar(context),
                                  child: hbox(
                                    minH: 54,
                                    pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '品牌车型',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF52525B),
                                                Color(0xFFA8A8B3),
                                              ),
                                              lh: 20,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          c.text('brand_model').isEmpty
                                              ? '请选择品牌车型'
                                              : c.text('brand_model'),
                                          style:
                                              (hts(
                                                15,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                lh: 22,
                                              )).copyWith(
                                                color:
                                                    c
                                                        .text('brand_model')
                                                        .isEmpty
                                                    ? C.muted
                                                    : C.ink,
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
                              HVehicleColor(
                                value: c.text('color'),
                                onChanged: (value) => c.set('color', value),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
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
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '会员等级',
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
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFDDF6E7),
                              Color.fromRGBO(23, 201, 100, 0.16),
                            ),
                            radius: BorderRadius.circular(10),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              '自动升级',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF2B7745),
                                  Color(0xFF5FD48C),
                                ),
                                w: FontWeight.w600,
                                lh: 20,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      const MemberTierPreview(),
                      hbox(
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(14),
                        pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Text(
                          '新会员默认为普通会员。单次充值或累计消费达到门槛，立即自动升级；两者同时满足时取最高等级。保存后可在成功页直接充值。',
                          style: hts(
                            12,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 18,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 14,
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
                        '客户来源',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      HChipGroup(
                        labels: MemberFormController.sources,
                        // 登录后办卡：来源要自己选，不沿用设计稿示例里选中的“老客推荐”
                        initial: -1,
                        onChanged: (i) =>
                            c.set('source', MemberFormController.sources[i]),
                      ),
                      Builder(
                        builder: (context) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => c.selectReferrer(context),
                          child: hbox(
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '推荐人',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  c.text('referrer_label').isEmpty
                                      ? '选填'
                                      : c.text('referrer_label'),
                                  style:
                                      (hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 20,
                                      )).copyWith(
                                        color: c.text('referrer_label').isEmpty
                                            ? C.muted
                                            : C.ink,
                                      ),
                                ),
                                hsvg(
                                  dk(context, Svgs.s207, Svgs.s208),
                                  w: 14,
                                  h: 14,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '备注',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                      hbox(
                        minH: 64,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(14),
                        pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: AppTextInput(
                          controller: c.input('note'),
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            lh: 20,
                          ),
                          maxLines: 4,
                          hint: '如：车主偏好、车辆旧伤位置',
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
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
      overlays: [],
    );
  }
}
