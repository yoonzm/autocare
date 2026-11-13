import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../resources/staff_svgs.dart';
import 'st_live.dart';

class StTasksTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  const StTasksTemplate({super.key, required this.d});

  @override
  State<StTasksTemplate> createState() => _StTasksTemplateState();
}

class _StTasksTemplateState extends State<StTasksTemplate> {
  int? picked;

  @override
  Widget build(BuildContext context) {
    final all = [
      for (final t in (widget.d['items'] as List? ?? const []))
        Map<String, dynamic>.from(t as Map),
    ];
    final waiting = [
      for (final t in all)
        if (stPhase(t) == 0) t,
    ];
    final working = [
      for (final t in all)
        if (stPhase(t) == 1) t,
    ];
    final done = [
      for (final t in all)
        if (stPhase(t) == 2) t,
    ];
    final tab =
        picked ?? (working.isNotEmpty ? 1 : (waiting.isNotEmpty ? 0 : 2));
    final list = tab == 0 ? waiting : (tab == 1 ? working : done);
    Widget workingCard(Map<String, dynamic> t) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => stOpenTask(context, '${t['id']}'),
      child: hbox(
        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
        radius: BorderRadius.circular(22),
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
        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: hrow(
          [
            hsvg(dk(context, Svgs.s39, Svgs.s40), w: 78, h: 29),
            Expanded(
              flex: 1,
              child: hcol(
                [
                  hrow(
                    [
                      hbox(
                        grad: LinearGradient(
                          begin: Alignment(-0, -1),
                          end: Alignment(0, 1),
                          colors: stPlateGreen(t['plate'])
                              ? [Color(0xFFE9FBEF), Color(0xFFB8F0CB)]
                              : [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                          stops: [0, 1],
                        ),
                        radius: BorderRadius.circular(5),
                        shadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: Color.fromRGBO(255, 255, 255, 0.75),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
                        child: Text(
                          stPlateOf(t),
                          style: hts(
                            12,
                            stPlateGreen(t['plate'])
                                ? Color(0xFF14532D)
                                : Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 18,
                            ls: 0.5,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox.shrink()),
                      hbox(
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
                  ),
                  Text(
                    stItemsOf(t),
                    style: hts(
                      15,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 22,
                    ),
                  ),
                  hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          h: 6,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(3),
                          clip: true,
                          child: hcol(
                            [
                              Align(
                                alignment: Alignment.topLeft,
                                child: hfrac(
                                  ((t['progress'] as num?) ?? 0) / 100,
                                  hbox(
                                    h: 6,
                                    bg: Color(0xFF0485F7),
                                    radius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                            min: false,
                          ),
                        ),
                      ),
                      Text(
                        '${t['progress'] ?? 0}%',
                        style: hts(
                          12,
                          Color(0xFF0485F7),
                          w: FontWeight.w600,
                          lh: 17,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 10,
                  ),
                  Text(
                    '${t['bay_name'] ?? '未指定工位'} · 预计 ${stClock(stEnd(t))}',
                    style: hts(
                      11,
                      dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 6,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      ),
    );
    Widget waitCard(
      Map<String, dynamic> t, {
      bool finished = false,
    }) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => stOpenTask(context, '${t['id']}'),
      child: hbox(
        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
        radius: BorderRadius.circular(22),
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
        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: hrow(
          [
            hsvg(dk(context, Svgs.s39, Svgs.s40), w: 78, h: 29),
            Expanded(
              flex: 1,
              child: hcol(
                [
                  hrow(
                    [
                      hbox(
                        grad: LinearGradient(
                          begin: Alignment(-0, -1),
                          end: Alignment(0, 1),
                          colors: stPlateGreen(t['plate'])
                              ? [Color(0xFFE9FBEF), Color(0xFFB8F0CB)]
                              : [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                          stops: [0, 1],
                        ),
                        radius: BorderRadius.circular(5),
                        shadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: Color.fromRGBO(255, 255, 255, 0.75),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
                        child: Text(
                          stPlateOf(t),
                          style: hts(
                            12,
                            stPlateGreen(t['plate'])
                                ? Color(0xFF14532D)
                                : Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 18,
                            ls: 0.5,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox.shrink()),
                      hbox(
                        bg: finished
                            ? dk(
                                context,
                                Color(0xFFDDF7E8),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              )
                            : dk(
                                context,
                                Color(0xFFFDEFD6),
                                Color.fromRGBO(245, 165, 36, 0.16),
                              ),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          finished ? '已完成' : '待开工',
                          style: hts(
                            11,
                            finished
                                ? dk(
                                    context,
                                    Color(0xFF1B7A43),
                                    Color(0xFF5FDB93),
                                  )
                                : dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
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
                    gap: 8,
                  ),
                  Text(
                    stItemsOf(t),
                    style: hts(
                      15,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 22,
                    ),
                  ),
                  hrow(
                    [
                      hsvg(dk(context, Svgs.s41, Svgs.s42), w: 14, h: 14),
                      Flexible(
                        flex: 89,
                        child: Text(
                          finished
                              ? '完工 ${stClock(t['finished_at'] ?? t['completed_at'])}'
                              : '预计 ${stClock(t['starts_at'])} 到店',
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 6,
                  ),
                  Text(
                    '${stDayLabel(t['starts_at'])} · 客户 ${t['customer']}',
                    style: hts(
                      11,
                      dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 6,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      ),
    );
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 110),
            child: hcol(
              [
                hrow(
                  [
                    hbox(w: 87),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '我的任务',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 87),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                AppSegmented<int>(
                  items: [
                    SegmentItem(value: 0, label: '待施工', count: waiting.length),
                    SegmentItem(value: 1, label: '施工中', count: working.length),
                    SegmentItem(value: 2, label: '已完成', count: done.length),
                  ],
                  selected: tab,
                  onChanged: (i) => setState(() => picked = i),
                ),
                ...(tab == 1
                    ? [for (final t in working) workingCard(t)]
                    : [for (final t in list) waitCard(t, finished: tab == 2)]),
                hbox(
                  pad: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: hrow(
                    [
                      hsvg(dk(context, Svgs.s111, Svgs.s112), w: 14, h: 14),
                      Flexible(
                        flex: 84,
                        child: Text(
                          list.isEmpty ? '暂无任务' : '已显示全部任务',
                          style: hts(
                            12,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
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

/// 我的任务：今日分配给自己的预约，按待施工 / 施工中 / 已完成分组。
class StTasksLivePage extends StatelessWidget {
  const StTasksLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '我的任务',
    load: () => merchantApi.staffWork('staff_task_list'),
    builder: (_, d) => StTasksTemplate(d: d),
  );
}
