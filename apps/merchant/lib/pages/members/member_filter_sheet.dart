import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_filter_controller.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';

Future<MemberFilters?> showMemberFilters(
  BuildContext context,
  MemberFilters initial,
) => showModalBottomSheet<MemberFilters>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  routeSettings: const RouteSettings(name: 'sheet:MemberFilter'),
  builder: (_) =>
      SingleChildScrollView(child: MemberFilterSheet(initial: initial)),
);

class MemberFilterSheet extends StatefulWidget {
  final MemberFilters? initial;
  const MemberFilterSheet({super.key, this.initial});
  @override
  State<MemberFilterSheet> createState() => _MemberFilterState();
}

class _MemberFilterState extends State<MemberFilterSheet> {
  late final c = MemberFilterController(widget.initial ?? MemberFilters())
    ..addListener(_onCount);
  AppError? lastError;
  void _onCount() {
    if (c.countError != null && c.countError != lastError && mounted) {
      AppToast.show(
        context,
        c.countError!.message,
        kind: ToastKind.error,
        actionLabel: c.countError!.retryable ? '重试' : null,
        onAction: c.countError!.retryable ? c.refreshCount : null,
      );
    }
    lastError = c.countError;
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return ErrorView(
        error: const AppError('请先登录', type: AppErrorType.auth),
        onNext: () => openRoute(context, 'Login'),
      );
    }
    return AsyncView<List<Map<String, dynamic>>>(
      shrinkWrap: true,
      inlineError: true,
      skeletonScrollable: false,
      pullToRefresh: false,
      skeletonPadding: EdgeInsets.zero,
      load: c.loadTiers,
      onLoaded: c.applyTiers,
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 4),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, _) => ListenableBuilder(
        listenable: c,
        builder: (_, _) => _MemberFilterTemplate(c: c),
      ),
    );
  }
}

class _MemberFilterTemplate extends StatelessWidget {
  final MemberFilterController c;
  const _MemberFilterTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    return hbox(
      minH: 712,
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, 0),
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
          hrow(
            [
              Expanded(
                flex: 1,
                child: Text(
                  '筛选会员',
                  style: hts(
                    20,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 28,
                  ),
                ),
              ),
              AppButton(
                label: '重置',
                kind: AppButtonKind.text,
                size: AppButtonSize.medium,
                expanded: false,
                onPressed: () => c.reset(),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text.rich(
                  TextSpan(
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                    children: [
                      TextSpan(
                        text: '卡种 ',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: '· 可多选',
                        style: hts(
                          14,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppChoiceGroup<int>.multiple(
                items: [
                  ChoiceItem(value: 0, label: c.tierName(0)),
                  ChoiceItem(value: 1, label: c.tierName(1)),
                  ChoiceItem(value: 2, label: c.tierName(2)),
                  ChoiceItem(value: 3, label: c.tierName(3)),
                ],
                selectedValues: c.tierIndices,
                onChanged: (values) => c.chooseTiers(context, values),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '储值余额',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '不限'),
                  ChoiceItem(value: 1, label: '¥500 以下'),
                  ChoiceItem(value: 2, label: '¥500–2,000'),
                  ChoiceItem(value: 3, label: '¥2,000 以上'),
                ],
                selected: c.filters.balance,
                onChanged: c.chooseBalance,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '最近到店',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '7 天内'),
                  ChoiceItem(value: 1, label: '30 天内'),
                  ChoiceItem(value: 2, label: '超过 60 天'),
                  ChoiceItem(value: 3, label: '超过 90 天'),
                ],
                selected: c.filters.visit,
                onChanged: c.chooseVisit,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '次卡状态',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '7 天内到期'),
                  ChoiceItem(value: 1, label: '剩余 ≤ 2 次'),
                  ChoiceItem(value: 2, label: '已用完'),
                ],
                selected: -1,
                onChanged: (value) => c.unsupported(context, value),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '车辆与项目',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              AppChoiceGroup<int>(
                items: [
                  ChoiceItem(value: 0, label: '新能源车主'),
                  ChoiceItem(value: 1, label: '做过镀晶'),
                  ChoiceItem(value: 2, label: '车衣质保中'),
                  ChoiceItem(value: 3, label: '多辆车'),
                ],
                selected: -1,
                onChanged: (value) => c.unsupported(context, value),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hbox(
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFEFEFF1),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF2A2A2E),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(0, 12, 0, 30),
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: AppButton(
                      label: c.matched == null ? '查看会员' : '查看 ${c.matched} 位会员',
                      kind: AppButtonKind.secondary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => Navigator.of(context).pop(c.filters),
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
        gap: 18,
      ),
    );
  }
}
