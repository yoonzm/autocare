import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

class StaffRecordsTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  final Map<String, dynamic> r;
  final int range;
  final ValueChanged<int> onRange;
  const StaffRecordsTemplate({
    super.key,
    required this.d,
    required this.r,
    required this.range,
    required this.onRange,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${d['name']}';
    final summary = Map<String, dynamic>.from(r['summary'] as Map);
    final rows = [
      for (final x in (r['rows'] as List)) Map<String, dynamic>.from(x as Map),
    ];
    final label = const ['本月', '上月', '累计'][range];
    final scope = const ['本月', '上月', '全部'][range];
    Widget recordRow(Map<String, dynamic> x) {
      final plate = '${x['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${x['plate']}';
      return hbox(
        minH: 64,
        pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: hrow(
          [
            (staffGreenPlate(x['plate'])
                ? hbox(
                    bg: Color(0xFF0B5FD6),
                    radius: BorderRadius.circular(4),
                    pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    child: Text(
                      plate,
                      style: hts(
                        11,
                        Color(0xFFFFFFFF),
                        w: FontWeight.w600,
                        lh: 16,
                      ),
                    ),
                  )
                : hbox(
                    bg: Color(0xFF0B5FD6),
                    radius: BorderRadius.circular(4),
                    pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    child: Text(
                      plate,
                      style: hts(
                        11,
                        Color(0xFFFFFFFF),
                        w: FontWeight.w600,
                        lh: 16,
                      ),
                    ),
                  )),
            Expanded(
              flex: 1,
              child: hcol(
                [
                  Text(
                    '${x['service'] ?? ''}',
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      lh: 20,
                    ),
                  ),
                  Text(
                    staffDayTime(x['at']),
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
            (x['status'] == 'arrived'
                ? hcol(
                    [
                      Text(
                        '提成 待结算',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      hbox(
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          '进行中',
                          style: hts(
                            11,
                            dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.end,
                    gap: 2,
                  )
                : hcol(
                    [
                      Text(
                        x['commission'] == null
                            ? '—'
                            : '+${StaffFlow.money(x['commission'])}',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                        ),
                      ),
                      hbox(
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          '已完成',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.end,
                    gap: 2,
                  )),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      );
    }

    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 893,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: Builder(
              builder: (context) => Builder(
                builder: (context) => hcol(
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
                            '$name · 施工记录',
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
                        SegmentItem(value: 0, label: '本月'),
                        SegmentItem(value: 1, label: '上月'),
                        SegmentItem(value: 2, label: '全部'),
                      ],
                      selected: range,
                      onChanged: onRange,
                    ),
                    ...([
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '$label台次',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${summary['orders'] ?? 0}',
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '$label提成',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF2B7745),
                                        Color(0xFF5FD48C),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    StaffFlow.money(summary['commission']),
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF2B7745),
                                        Color(0xFF5FD48C),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFFDEFD6),
                                Color.fromRGBO(245, 165, 36, 0.16),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '平均用时',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    summary['avg_hours'] == null
                                        ? '—'
                                        : '${summary['avg_hours']} h',
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                        intrinsic: true,
                      ),
                      hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Text(
                              '$scope记录',
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
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                                if (rows.isEmpty)
                                  hbox(
                                    minH: 64,
                                    align: Alignment.center,
                                    child: Text(
                                      '暂无施工记录',
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
                                  ),
                                for (var i = 0; i < rows.length; i++) ...[
                                  if (i > 0)
                                    hbox(
                                      h: 1,
                                      bg: dk(
                                        context,
                                        Color(0xFFEFEFF1),
                                        Color(0xFF2A2A2E),
                                      ),
                                      margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    ),
                                  recordRow(rows[i]),
                                ],
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
                    ]),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
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

/// 施工记录（设计稿 StaffRecords）：本月 / 上月 / 全部三个范围分别向后端读取。
class StaffRecordsLivePage extends StatefulWidget {
  final String? staffId;
  const StaffRecordsLivePage({super.key, this.staffId});

  @override
  State<StaffRecordsLivePage> createState() => _StaffRecordsLivePageState();
}

class _StaffRecordsLivePageState extends State<StaffRecordsLivePage> {
  static const _ranges = ['month', 'last', 'all'];
  int range = 0;
  Map<String, dynamic>? records;
  int token = 0;

  @override
  void didUpdateWidget(StaffRecordsLivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staffId != widget.staffId) {
      token++;
      range = 0;
      records = null;
    }
  }

  Future<Map<String, dynamic>> _load(String id) async {
    final seq = ++token;
    final out = await Future.wait([
      merchantApi.staff('get', {'id': id}),
      merchantApi.staff('records', {'id': id, 'range': _ranges[range]}),
    ]);
    if (mounted && id == widget.staffId && seq == token) {
      records = out[1];
    }
    return out[0];
  }

  Future<void> _pick(int i) async {
    final id = widget.staffId;
    if (id == null || i == range) return;
    final seq = ++token;
    final previous = range;
    setState(() => range = i);
    try {
      final r = await merchantApi.staff('records', {
        'id': id,
        'range': _ranges[i],
      });
      if (!mounted || id != widget.staffId || seq != token) return;
      setState(() => records = r);
    } catch (e) {
      if (!mounted || id != widget.staffId || seq != token) return;
      setState(() => range = previous);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    staffId: widget.staffId,
    title: '施工记录',
    load: _load,
    builder: (_, d) =>
        StaffRecordsTemplate(d: d, r: records!, range: range, onRange: _pick),
  );
}
