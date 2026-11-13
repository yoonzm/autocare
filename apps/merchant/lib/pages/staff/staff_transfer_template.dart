import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

class StaffTransferTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  const StaffTransferTemplate({super.key, required this.d});

  @override
  State<StaffTransferTemplate> createState() => _StaffTransferTemplateState();
}

class _StaffTransferTemplateState extends State<StaffTransferTemplate> {
  String? picked;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final id = '${d['id']}';
    final open = (d['open_work'] as List?) ?? const [];
    final cands = [
      for (final c in (d['candidates'] as List? ?? const []))
        Map<String, dynamic>.from(c as Map),
    ];
    final sel = picked ?? (cands.isEmpty ? null : '${cands.first['id']}');
    Widget cand(Map<String, dynamic> c, bool on) {
      final chip = c['busy'] == true
          ? hbox(
              bg: dk(
                context,
                Color(0xFFE1F0FE),
                Color.fromRGBO(4, 133, 247, 0.18),
              ),
              radius: BorderRadius.circular(9),
              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                '施工中',
                style: hts(
                  11,
                  dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                  w: FontWeight.w600,
                  lh: 18,
                ),
                softWrap: false,
                maxLines: 1,
              ),
            )
          : hbox(
              bg: dk(
                context,
                Color(0xFFDDF6E7),
                Color.fromRGBO(23, 201, 100, 0.16),
              ),
              radius: BorderRadius.circular(9),
              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                '空闲',
                style: hts(
                  11,
                  dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                  w: FontWeight.w600,
                  lh: 18,
                ),
                softWrap: false,
                maxLines: 1,
              ),
            );
      return on
          ? hbox(
              bg: dk(
                context,
                Color(0xFFE1F0FE),
                Color.fromRGBO(4, 133, 247, 0.18),
              ),
              radius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFF0485F7), width: 1.5),
              pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: hrow(
                [
                  hbox(
                    w: 36,
                    h: 36,
                    bg: Color(0xFFFFFFFF),
                    radius: BorderRadius.circular(18),
                    align: Alignment(0, 0),
                    child: Text(
                      staffInitial(c),
                      style: hts(
                        14,
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
                          '${c['name']}',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          [
                            if ('${c['skills'] ?? ''}'.isNotEmpty)
                              '${c['skills']}',
                            '本月 ${c['month_orders'] ?? 0} 台次',
                          ].join(' · '),
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 16,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 1,
                    ),
                  ),
                  chip,
                  hbox(
                    w: 22,
                    h: 22,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(11),
                    child: hrow(
                      [hsvg(Svgs.s309, w: 14, h: 14)],
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                      gap: 0,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 12,
              ),
            )
          : hbox(
              bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
              radius: BorderRadius.circular(18),
              pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: hrow(
                [
                  hbox(
                    w: 36,
                    h: 36,
                    bg: Color(0xFFFFFFFF),
                    radius: BorderRadius.circular(18),
                    align: Alignment(0, 0),
                    child: Text(
                      staffInitial(c),
                      style: hts(
                        14,
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
                          '${c['name']}',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          [
                            if ('${c['skills'] ?? ''}'.isNotEmpty)
                              '${c['skills']}',
                            '本月 ${c['month_orders'] ?? 0} 台次',
                          ].join(' · '),
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 16,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 1,
                    ),
                  ),
                  chip,
                  hbox(
                    w: 22,
                    h: 22,
                    radius: BorderRadius.circular(11),
                    border: dk(
                      context,
                      Border.all(color: Color(0xFFD4D4D8), width: 2),
                      Border.all(color: Color(0xFF3F3F46), width: 2),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 12,
              ),
            );
    }

    return AsyncActionScope(
      actionKey: 'StaffTransfer>Staff-${identityHashCode(context)}',
      child: hbox(
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
              '转交进行中的订单',
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            for (final o in open)
              hbox(
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(18),
                pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: hrow(
                  [
                    hbox(
                      bg: Color(0xFF0B5FD6),
                      radius: BorderRadius.circular(4),
                      border: Border.all(color: Color(0xFF5B9BF0), width: 1.5),
                      pad: EdgeInsets.fromLTRB(5, 1, 5, 1),
                      child: Text(
                        '${o['plate'] ?? ''}'.isEmpty
                            ? '未登记车牌'
                            : '${o['plate']}',
                        style: hts(
                          11,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 16,
                        ),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          Text(
                            ((o['items'] as List?) ?? const [])
                                .map((e) => '${(e as Map)['name']}')
                                .join(' · '),
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                          Text(
                            [
                              o['status'] == 'arrived' ? '施工中' : '待到店',
                              if (o['bay_name'] != null) '${o['bay_name']}',
                            ].join(' · '),
                            style: hts(
                              12,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 16,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 1,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 10,
                ),
              ),
            Text(
              '转交给',
              style: hts(
                13,
                dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                w: FontWeight.w500,
                lh: 18,
              ),
            ),
            hcol(
              [
                for (final c in cands)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => picked = '${c['id']}'),
                    child: cand(c, '${c['id']}' == sel),
                  ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
            Text(
              '转交后进度与已拍照片保留，提成按各自完成的工序分配，并通知接手技师。',
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 17,
              ),
            ),
            hrow(
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
                      onPressed: () {
                        final nav = Navigator.of(context);
                        nav.pop();
                        openRoute(nav.context, 'DisableStaff');
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey:
                          'StaffTransfer>Staff-${identityHashCode(context)}',
                      label: '转交并停用',
                      kind: AppButtonKind.danger,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: sel == null
                          ? () => AppToast.show(context, '没有可接手的技师，请先添加或启用其他技师')
                          : () => runBusy(
                              'StaffTransfer>Staff-${identityHashCode(context)}',
                              () async {
                                try {
                                  await StaffFlow.setStatus(
                                    id,
                                    'disabled',
                                    transferTo: sel,
                                  );
                                  if (context.mounted) {
                                    openRoute(context, 'Staff');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppToast.error(context, e);
                                  }
                                }
                              },
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
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 14,
        ),
      ),
    );
  }
}

class StaffTransferSheet extends StatelessWidget {
  final String? staffId;
  const StaffTransferSheet({super.key, this.staffId});
  @override
  Widget build(BuildContext context) => StaffLiveHost(
    sheet: true,
    staffId: staffId,
    load: loadTransferData,
    builder: (_, data) => StaffTransferTemplate(d: data),
  );
}
