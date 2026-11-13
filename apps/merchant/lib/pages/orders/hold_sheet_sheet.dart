import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import 'hold_controller.dart';
import 'hold_draft.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';

Future<Map<String, dynamic>?> showHoldEditor(
  BuildContext context,
  HoldDraft draft,
) => showModalBottomSheet<Map<String, dynamic>>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  routeSettings: const RouteSettings(name: 'sheet:HoldSheet'),
  builder: (ctx) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
    child: SingleChildScrollView(child: HoldSheetSheet(draft: draft)),
  ),
);

class HoldSheetSheet extends StatefulWidget {
  final HoldDraft? draft;
  const HoldSheetSheet({super.key, this.draft});
  @override
  State<HoldSheetSheet> createState() => _HoldSheetState();
}

class _HoldSheetState extends State<HoldSheetSheet> {
  late final c = widget.draft == null ? null : HoldController(widget.draft!);
  @override
  void dispose() {
    c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (c == null || !merchantApi.hasSession) {
      return ErrorView(
        error: AppError(merchantApi.hasSession ? '请先在开单页选择项目' : '请先登录'),
      );
    }
    return ListenableBuilder(
      listenable: c!,
      builder: (_, _) => AsyncActionScope(
        actionKey: c!.actionKey,
        child: _HoldSheetTemplate(c: c!),
      ),
    );
  }
}

class _HoldSheetTemplate extends StatelessWidget {
  final HoldController c;
  const _HoldSheetTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    final h = HoldView(c.draft);
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
            '挂单保存',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(18),
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hrow(
              [
                hbox(
                  w: 40,
                  h: 40,
                  bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                  radius: BorderRadius.circular(20),
                  align: Alignment(0, 0),
                  child: Text(
                    h.avatar,
                    style: hts(16, Color(0xFFF5D78E), w: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        h.name,
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: hbox(
                          bg: Color(0xFF0B5FD6),
                          radius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Color(0xFF5B9BF0),
                            width: 1.5,
                          ),
                          pad: EdgeInsets.fromLTRB(5, 1, 5, 1),
                          child: Text(
                            h.plate,
                            style: hts(
                              11,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 3,
                  ),
                ),
                hcol(
                  [
                    Text(
                      h.countText,
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                    Text(
                      h.payableText,
                      style: hts(
                        16,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
                        lh: 22,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.end,
                  gap: 0,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '车辆状态',
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
                  ChoiceItem(value: 0, label: '待施工'),
                  ChoiceItem(value: 1, label: '施工中'),
                  ChoiceItem(value: 2, label: '待结算'),
                ],
                selected: c.status,
                onChanged: c.chooseStatus,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              Text.rich(
                TextSpan(
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                  children: [
                    TextSpan(
                      text: '备注 ',
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
                        lh: 20,
                      ),
                    ),
                    TextSpan(
                      text: '· 选填',
                      style: hts(
                        14,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 20,
                      ),
                    ),
                  ],
                ),
              ),
              hbox(
                minH: 64,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(14),
                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: AppTextInput(
                  controller: c.note,
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    lh: 20,
                  ),
                  maxLines: 4,
                  hint: '请输入备注',
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
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '到点提醒我',
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
                  ChoiceItem(value: 0, label: '不提醒'),
                  ChoiceItem(value: 1, label: '30 分钟'),
                  ChoiceItem(value: 2, label: '1 小时'),
                  ChoiceItem(value: 3, label: '完工时'),
                ],
                selected: c.remind,
                onChanged: c.chooseRemind,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
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
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey: c.actionKey,
                      label: '确认挂单',
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
        gap: 16,
      ),
    );
  }
}
