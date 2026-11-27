import '../../backend/access_flow.dart';
import '../../backend/hold_store.dart';
import '../../kit/async_kit.dart';
import '../../kit/upload_gallery.dart';
import '../../backend/media_api.dart';
import '../../backend/merchant_api.dart';

import 'package:flutter/material.dart';

import '../../backend/task_flow.dart';
import '../staff/staff_live.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/staff_svgs.dart';
import 'st_live.dart';
import 'task_route_data.dart';
import '../../kit/page_header.dart';

class StTaskDetailTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StTaskDetailTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final t = d;
    final phase = stPhase(t);
    final plateGreen = stPlateGreen(t['plate']);
    final chip = const ['待开工', '施工中', '已完成'][phase];
    final end = stClock(stEnd(t));
    final startKey = 'StTaskDetail>start-${identityHashCode(context)}';
    return AsyncActionScope(
      actionKey: startKey,
      child: HPage(
        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
        header: AppPageHeader(title: '任务详情'),
        flow: hcol(
          [
            hbox(
              pad: EdgeInsets.fromLTRB(20, 8, 20, 130),
              child: hcol(
                [
                  hbox(
                    grad: LinearGradient(
                      begin: Alignment(-0.5, -0.866),
                      end: Alignment(0.5, 0.866),
                      colors: [
                        Color(0xFF26262C),
                        Color(0xFF18181B),
                        Color(0xFF2B2418),
                      ],
                      stops: [0, 0.55, 1],
                    ),
                    radius: BorderRadius.circular(28),
                    pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    clip: true,
                    child: hstack(
                      hcol(
                        [
                          hrow(
                            [
                              hbox(
                                bg: [
                                  dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  dk(
                                    context,
                                    Color(0xFFDDF7E8),
                                    Color.fromRGBO(23, 201, 100, 0.16),
                                  ),
                                ][phase],
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  chip,
                                  style: hts(
                                    11,
                                    [
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      dk(
                                        context,
                                        Color(0xFF1B7A43),
                                        Color(0xFF5FDB93),
                                      ),
                                    ][phase],
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              ),
                              Expanded(flex: 1, child: SizedBox.shrink()),
                              Text(
                                '${t['bay_name'] ?? '未指定工位'}',
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
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                          hrow(
                            [
                              Flexible(
                                flex: 74,
                                child: hbox(
                                  grad: LinearGradient(
                                    begin: Alignment(-0, -1),
                                    end: Alignment(0, 1),
                                    colors: plateGreen
                                        ? [
                                            Color(0xFFE9FBEF),
                                            Color(0xFFB8F0CB),
                                          ]
                                        : [
                                            Color(0xFF2F73F2),
                                            Color(0xFF1A4FC4),
                                          ],
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
                                      plateGreen
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
                              ),
                              Flexible(
                                flex: 102,
                                child: Text(
                                  '${stDayLabel(t['starts_at'])} – $end',
                                  style: hts(
                                    14,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w500,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
                      ),
                      [],
                      behind: [
                        Positioned(
                          top: -120,
                          right: -120,
                          child: IntrinsicWidth(
                            child: hsvg(Svgs.s2, w: 260, h: 260),
                          ),
                        ),
                        Positioned(
                          top: -100,
                          right: -80,
                          width: 260,
                          height: 260,
                          child: hbox(
                            w: 260,
                            h: 260,
                            radius: BorderRadius.circular(130),
                          ),
                        ),
                      ],
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
                                  '服务项目',
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
                                stItemsOf(t),
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
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '客户',
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
                                '${t['customer']} · ${t['level']}',
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
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '预计完工',
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
                                end,
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
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '备注',
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
                                '${t['note'] ?? ''}'.isEmpty
                                    ? '无'
                                    : '${t['note']}',
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
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
                    child: UploadGallery(
                      key: ValueKey('task-photos-${d['id']}'),
                      title: '施工照片',
                      max: 6,
                      load: MediaApi.task(merchantApi, d['id'].toString()).load,
                      upload: Access.can('progress_update')
                          ? MediaApi.task(
                              merchantApi,
                              d['id'].toString(),
                            ).upload
                          : null,
                      remove: Access.can('progress_update')
                          ? MediaApi.task(
                              merchantApi,
                              d['id'].toString(),
                            ).remove
                          : null,
                      discard: MediaApi.task(
                        merchantApi,
                        d['id'].toString(),
                      ).discard,
                      refresh: MediaApi.task(
                        merchantApi,
                        d['id'].toString(),
                      ).refresh,
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
        overlays: phase < 2
            ? [
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: phase == 0
                          ? () => runBusy(startKey, () async {
                              try {
                                await merchantApi.staffWork(
                                  'staff_task_progress',
                                  {'id': t['id'], 'stage': 1},
                                );
                                TaskFlow.notify();
                                HoldStore.invalidated.value++;
                                if (context.mounted) {
                                  AppToast.show(
                                    context,
                                    '已开始施工',
                                    kind: ToastKind.success,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AccessFlow.toastError(context, e);
                                }
                              }
                            })
                          : () => openRoute(
                              context,
                              'StFinish',
                              arguments: TaskRouteData(
                                taskId: t['id'] as String,
                              ),
                            ),
                      child: hbox(
                        h: 50,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: phase == 0
                              ? hBusy(
                                  startKey,
                                  Text(
                                    '开始施工',
                                    style: hts(
                                      15,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w600,
                                      lh: 22,
                                    ),
                                  ),
                                  style: hts(
                                    15,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                    lh: 22,
                                  ),
                                )
                              : Text(
                                  '提交完工',
                                  style: hts(
                                    15,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                    lh: 22,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

/// 任务详情：传入的挂单任务 ID 由服务端校验是派给自己的；开始施工 / 完工后自动刷新。
class StTaskDetailLivePage extends StatelessWidget {
  final String? taskId;
  const StTaskDetailLivePage({super.key, this.taskId});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    key: ValueKey(taskId),
    needsId: false,
    title: '任务详情',
    refresh: TaskFlow.changed,
    load: (_) => stLoadTask(taskId),
    builder: (_, d) => StTaskDetailTemplate(d: d),
  );
}
