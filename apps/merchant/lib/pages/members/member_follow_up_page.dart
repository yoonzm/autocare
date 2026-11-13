import '../../kit/buttons.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/single_selection.dart';
import '../../routes.dart' show openRoute;
import 'member_reminder_controller.dart';
import 'reminder_widgets.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class MemberFollowUpPage extends StatefulWidget {
  const MemberFollowUpPage({super.key});
  @override
  State<MemberFollowUpPage> createState() => _MemberFollowUpState();
}

class _MemberFollowUpState extends State<MemberFollowUpPage> {
  final c = MemberReminderController();
  final content = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return Scaffold(
      body: AsyncView<Map<String, dynamic>>(
        key: content,
        load: merchantApi.reminders,
        onLoaded: c.apply,
        isEmpty: (_) => false,
        skeleton: const SkeletonDataPage(title: '回访提醒'),
        empty: (_) => const SizedBox.shrink(),
        builder: (_, _) => ListenableBuilder(
          listenable: c,
          builder: (_, _) => _MemberFollowUpTemplate(
            c: c,
            reload: () => content.currentState?.reload(),
          ),
        ),
      ),
    );
  }
}

class _MemberFollowUpTemplate extends StatelessWidget {
  final MemberReminderController c;
  final VoidCallback reload;
  const _MemberFollowUpTemplate({required this.c, required this.reload});

  @override
  Widget build(BuildContext context) {
    final f = c.view;
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 980,
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
                      svg: dk(context, Svgs.s0, Svgs.s1),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '回访提醒',
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
                  radius: BorderRadius.circular(24),
                  pad: EdgeInsets.fromLTRB(18, 16, 18, 16),
                  clip: true,
                  border: dk(
                    context,
                    null,
                    Border(
                      top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      bottom: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                    ),
                  ),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '今日待回访',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                lh: 18,
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '已完成 ',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: '${f.done}',
                                  style: hts(
                                    13,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${f.done + f.pending}',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 8,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${f.pending} ',
                              style: hts(
                                30,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 36,
                                ls: -0.6,
                              ),
                            ),
                            TextSpan(
                              text: '位客户',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                w: FontWeight.w500,
                                lh: 36,
                                ls: -0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FollowProgress(fraction: f.fraction),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                NegMargin(
                  top: 0,
                  left: 0,
                  child: hbox(
                    clip: true,
                    child: SingleSelection(
                      index: c.tab,
                      onChanged: c.selectTab,
                      builder: (context, g1) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: hrow(
                          [
                            UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: HSel(
                                ctrl: g1,
                                index: 0,
                                segment: true,
                                on: hbox(
                                  h: 34,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipAll,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipAll,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: HSel(
                                ctrl: g1,
                                index: 1,
                                segment: true,
                                on: hbox(
                                  h: 34,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipExpire,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipExpire,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: HSel(
                                ctrl: g1,
                                index: 2,
                                segment: true,
                                on: hbox(
                                  h: 34,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipCare,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipCare,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: HSel(
                                ctrl: g1,
                                index: 3,
                                segment: true,
                                on: hbox(
                                  h: 34,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipBirthday,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipBirthday,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: HSel(
                                ctrl: g1,
                                index: 4,
                                segment: true,
                                on: hbox(
                                  h: 34,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipSleep,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      f.chipSleep,
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
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
                    ),
                  ),
                ),
                ReminderList(controller: c, reload: reload),
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
