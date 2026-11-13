import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import 'member_adjust_controller.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class MemberAdjustPage extends StatelessWidget {
  final Map<String, dynamic>? member;
  const MemberAdjustPage({super.key, this.member});
  @override
  Widget build(BuildContext context) =>
      _MemberAdjustPageHost(key: ValueKey(member?['id']), member: member);
}

class _MemberAdjustPageHost extends StatefulWidget {
  final Map<String, dynamic>? member;
  const _MemberAdjustPageHost({super.key, this.member});
  @override
  State<_MemberAdjustPageHost> createState() => _MemberAdjustPageHostState();
}

class _MemberAdjustPageHostState extends State<_MemberAdjustPageHost> {
  late final c = widget.member?['id'] == null
      ? null
      : MemberAdjustController(widget.member!);
  @override
  void dispose() {
    c?.dispose();
    super.dispose();
  }

  Widget content() => ListenableBuilder(
    listenable: c!,
    builder: (_, _) => AsyncActionScope(
      actionKey: c!.actionKey,
      child: _MemberAdjustPageTemplate(c: c!),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession || c == null) {
      return Scaffold(
        body: ErrorView(
          error: AppError(
            merchantApi.hasSession ? '请先选择会员' : '请先登录',
            type: merchantApi.hasSession
                ? AppErrorType.notFound
                : AppErrorType.auth,
          ),
          onNext: () =>
              openRoute(context, merchantApi.hasSession ? 'Members' : 'Login'),
        ),
      );
    }
    return Scaffold(
      body: AsyncView<List<Map<String, dynamic>>>(
        load: c!.loadTiers,
        onLoaded: c!.applyTiers,
        isEmpty: (_) => false,
        skeleton: const SkeletonDataPage(title: '调整卡种与积分', detail: true),
        empty: (_) => const SizedBox.shrink(),
        builder: (_, _) => content(),
      ),
    );
  }
}

class _MemberAdjustPageTemplate extends StatelessWidget {
  final MemberAdjustController c;
  const _MemberAdjustPageTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    final m = c.view;
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1000,
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
                        '调整卡种与积分',
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
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(22),
                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: hrow(
                    [
                      hbox(
                        w: 44,
                        h: 44,
                        bg: Color(0xFFF5D78E),
                        radius: BorderRadius.circular(22),
                        align: Alignment(0, 0),
                        child: Text(
                          m.avatar,
                          style: hts(
                            17,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              m.name,
                              style: hts(
                                16,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '${m.maskedPhone} · ${m.plate}',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
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
                      hbox(
                        bg: Color(0xFFF5D78E),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          m.levelMember,
                          style: hts(
                            11,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
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
                        '调整卡种',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          Flexible(
                            flex: 26,
                            child: Text(
                              '当前',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 19,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 60,
                            child: hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                m.levelMember,
                                style: hts(
                                  11,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      AppChoiceGroup<int>(
                        items: [
                          ChoiceItem(value: 0, label: c.tierName(0)),
                          ChoiceItem(value: 1, label: c.tierName(1)),
                          ChoiceItem(value: 2, label: c.tierName(2)),
                          ChoiceItem(value: 3, label: c.tierName(3)),
                        ],
                        selected: c.tier,
                        onChanged: (value) => c.chooseTier(context, value),
                      ),
                      Text(
                        '手动降级后，会员仍会在再次达到更高门槛时实时自动升级。',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 17,
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
                        '调整积分',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          Flexible(
                            flex: 52,
                            child: Text(
                              '当前积分',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 19,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 51,
                            child: Text(
                              m.pointsText,
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 8,
                      ),
                      AppChoiceGroup<int>(
                        items: [
                          ChoiceItem(value: 0, label: '增加'),
                          ChoiceItem(value: 1, label: '扣减'),
                        ],
                        selected: c.direction,
                        onChanged: (value) => c.chooseDirection(value),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(0, 6, 0, 6),
                        child: HNumberStepper.controlled(
                          onDecrease: () => c.changePoints(c.points - 10),
                          onIncrease: () => c.changePoints(c.points + 10),

                          value: Flexible(
                            flex: 56,
                            child: hbox(
                              minW: 120,
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  '${c.points}',
                                  style: hts(
                                    32,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 38,
                                    ls: -0.64,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 14,
                        ),
                      ),
                      hbox(
                        border: dk(
                          context,
                          Border(
                            top: BorderSide(color: Color(0xFFEFEFF1), width: 1),
                          ),
                          Border(
                            top: BorderSide(color: Color(0xFF2A2A2E), width: 1),
                          ),
                        ),
                        pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: hrow(
                          [
                            Text(
                              '调整后',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 19,
                              ),
                            ),
                            Expanded(flex: 1, child: SizedBox.shrink()),
                            Text(
                              c.afterPoints,
                              style: hts(
                                16,
                                dk(
                                  context,
                                  Color(0xFF2B7745),
                                  Color(0xFF5FD48C),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 8,
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
                      hcol(
                        [
                          Text.rich(
                            TextSpan(
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                              children: [
                                TextSpan(
                                  text: '调整原因 ',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA43433),
                                      Color(0xFFFF7B7E),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppChoiceGroup<int>(
                            items: [
                              ChoiceItem(value: 0, label: '活动补发'),
                              ChoiceItem(value: 1, label: '客诉补偿'),
                              ChoiceItem(value: 2, label: '录入错误'),
                              ChoiceItem(value: 3, label: '其他'),
                            ],
                            selected: c.reason,
                            onChanged: (value) => c.chooseReason(value),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                      ),
                      hcol(
                        [
                          Text.rich(
                            TextSpan(
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                              children: [
                                TextSpan(
                                  text: '备注 ',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '· 选填',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hbox(
                            minH: 64,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: AppTextInput(
                              controller: c.note,
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                lh: 22,
                              ),
                              maxLines: 4,
                              hint: '补充说明，将记入操作记录',
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 14,
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
                  flex: 10,
                  child: AppButton(
                    label: '取消',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Expanded(
                  flex: 16,
                  child: ActionButton(
                    actionKey: c.actionKey,
                    label: '确认调整',
                    kind: AppButtonKind.primary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => c.submit(context),
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
