import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/merchant_api.dart';
import '../../backend/task_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../staff/staff_live.dart';
import 'st_live.dart';

class StProgressTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  const StProgressTemplate({super.key, required this.d});

  @override
  State<StProgressTemplate> createState() => _StProgressTemplateState();
}

class _StProgressTemplateState extends State<StProgressTemplate> {
  // 选中的行 = 当前所在节点：第 0 行表示已完成 1 个节点（到店接车），依次类推
  late int row = (((widget.d['stage'] as num?) ?? 1).toInt() - 1).clamp(0, 2);

  late final SelCtrl _stage = SelCtrl({row}, false)..onSelect = (i) => row = i;

  @override
  void dispose() {
    _stage.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      final t = await merchantApi.staffWork('staff_task_progress', {
        'id': widget.d['id'],
        'stage': row + 1,
      });
      TaskFlow.notify();
      if (!mounted) return;
      AppToast.show(context, '进度已更新为 ${t['progress']}%');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AccessFlow.toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ((widget.d['items'] as List?) ?? const [])
        .map((e) => '${(e as Map)['name']}')
        .toList();
    final itemNode = items.isEmpty
        ? '项目施工'
        : (items.length == 1
              ? '${items.first} 施工'
              : '${items.first} 等 ${items.length} 项施工');
    return AsyncActionScope(
      actionKey: 'StProgress>StTaskDetail-${identityHashCode(context)}',
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
              '更新进度',
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            Builder(
              builder: (context) => hcol(
                [
                  HSel(
                    ctrl: _stage,
                    index: 0,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFE1F0FE),
                        Color.fromRGBO(4, 133, 247, 0.18),
                      ),
                      radius: BorderRadius.circular(18),
                      border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '清洗 · 打磨',
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            0 > _stage.selected.first
                                        ? '下一阶段'
                                        : (0 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(18),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '清洗 · 打磨',
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            0 > _stage.selected.first
                                        ? '下一阶段'
                                        : (0 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                  ),
                  HSel(
                    ctrl: _stage,
                    index: 1,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFE1F0FE),
                        Color.fromRGBO(4, 133, 247, 0.18),
                      ),
                      radius: BorderRadius.circular(18),
                      border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  itemNode,
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            1 > _stage.selected.first
                                        ? '下一阶段'
                                        : (1 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(18),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  itemNode,
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            1 > _stage.selected.first
                                        ? '下一阶段'
                                        : (1 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                  ),
                  HSel(
                    ctrl: _stage,
                    index: 2,
                    on: hbox(
                      bg: dk(
                        context,
                        Color(0xFFE1F0FE),
                        Color.fromRGBO(4, 133, 247, 0.18),
                      ),
                      radius: BorderRadius.circular(18),
                      border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '固化 · 质检',
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            2 > _stage.selected.first
                                        ? '下一阶段'
                                        : (2 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                    off: hbox(
                      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      radius: BorderRadius.circular(18),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '固化 · 质检',
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
                                ListenableBuilder(
                                  listenable: _stage,
                                  builder: (_, _) => Text(
                                    _stage.selected.isEmpty ||
                                            2 > _stage.selected.first
                                        ? '下一阶段'
                                        : (2 == _stage.selected.first
                                              ? '当前阶段'
                                              : '已完成'),
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
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
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 8,
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
                      onPressed: () => Navigator.of(context).pop(),
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
                          'StProgress>StTaskDetail-${identityHashCode(context)}',
                      label: '保存',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => runBusy(
                        'StProgress>StTaskDetail-${identityHashCode(context)}',
                        save,
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

/// 进度弹层只读取明确传入的任务。
class StProgressSheet extends StatelessWidget {
  final String? taskId;
  const StProgressSheet({super.key, this.taskId});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    key: ValueKey(taskId),
    sheet: true,
    needsId: false,
    load: (_) => stLoadTask(taskId),
    builder: (_, d) => StProgressTemplate(d: d),
  );
}
