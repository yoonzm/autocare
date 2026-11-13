import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import 'member_visit_controller.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;
import 'visit_history.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class MemberVisitPage extends StatelessWidget {
  final Map<String, dynamic>? member;
  const MemberVisitPage({super.key, this.member});
  @override
  Widget build(BuildContext context) =>
      _MemberVisitPageHost(key: ValueKey(member?['id']), member: member);
}

class _MemberVisitPageHost extends StatefulWidget {
  final Map<String, dynamic>? member;
  const _MemberVisitPageHost({super.key, this.member});
  @override
  State<_MemberVisitPageHost> createState() => _MemberVisitPageHostState();
}

class _MemberVisitPageHostState extends State<_MemberVisitPageHost> {
  late final c = widget.member?['id'] == null
      ? null
      : MemberVisitController(widget.member!);
  @override
  void dispose() {
    c?.dispose();
    super.dispose();
  }

  Widget content() => ListenableBuilder(
    listenable: c!,
    builder: (_, _) => AsyncActionScope(
      actionKey: c!.actionKey,
      child: _MemberVisitPageTemplate(c: c!),
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
    return content();
  }
}

class _MemberVisitPageTemplate extends StatelessWidget {
  final MemberVisitController c;
  const _MemberVisitPageTemplate({required this.c});

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
                        '记录回访',
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
                      hcol(
                        [
                          Text(
                            '回访方式',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                          AppChoiceGroup<int>(
                            items: [
                              ChoiceItem(value: 0, label: '电话'),
                              ChoiceItem(value: 1, label: '微信'),
                              ChoiceItem(value: 2, label: '到店'),
                            ],
                            selected: c.method,
                            onChanged: (value) => c.chooseMethod(value),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                      ),
                      hcol(
                        [
                          Text(
                            '回访结果',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                          AppChoiceGroup<int>(
                            items: [
                              ChoiceItem(value: 0, label: '已接通 · 有意向'),
                              ChoiceItem(value: 1, label: '已接通 · 暂无需求'),
                              ChoiceItem(value: 2, label: '未接通'),
                              ChoiceItem(value: 3, label: '已预约到店'),
                            ],
                            selected: c.result,
                            onChanged: (value) => c.chooseResult(value),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                      ),
                      hcol(
                        [
                          Text(
                            '回访内容',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                          hbox(
                            minH: 86,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: AppTextInput(
                              controller: c.content,
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
                              hint: '记录沟通内容',
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
                            Expanded(
                              flex: 1,
                              child: Text(
                                '下次回访',
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
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => c.chooseNext(context),
                              child: Text(
                                c.next.isEmpty
                                    ? '选填'
                                    : c.next.replaceAll('-', '.'),
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
                            ),
                            hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // TODO: 回访推送渠道及发送计划接口未接通，follow_ups.save 只记录下次回访日期。
                          AppToast.show(context, '推送提醒暂未接通：缺少通知渠道与发送计划接口');
                        },
                        child: hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '提醒方式',
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
                                '当天 9:00 推送',
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
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                AsyncView<List<Map<String, dynamic>>>(
                  shrinkWrap: true,
                  inlineError: true,
                  skeletonScrollable: false,
                  pullToRefresh: false,
                  skeletonPadding: EdgeInsets.zero,
                  load: () => merchantApi.followUps('${c.member['id']}'),
                  isEmpty: (_) => false,
                  skeleton: const SkeletonList(count: 2),
                  empty: (_) => const SizedBox.shrink(),
                  builder: (_, rows) => VisitHistory(rows: rows),
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
                    label: '保存回访',
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
