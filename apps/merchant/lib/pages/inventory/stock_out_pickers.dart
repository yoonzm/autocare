import 'package:flutter/material.dart';

import '../../kit/kit.dart' show dk;
import '../../theme.dart';
import '../../widgets/app_icon.dart';

/// 选择器的结果：[item] 为 null 表示点了右上角「清除」。点遮罩关闭返回 null（不改动）。
class PickResult {
  final Map<String, dynamic>? item;
  const PickResult(this.item);
}

/// 选择技师（设计稿 StaffPicker）：单选，点一行立即选中并关闭，已选项蓝色对勾，右上角「清除」改回未指定；
/// 搜索按姓名过滤；每行姓名、擅长项目和当前状态（空闲 / 施工中，只作提示，仍可选）。
/// 这是通用的「选择技师」弹层，出库和新建预约共用。
Future<PickResult?> showStaffPicker(
  BuildContext context, {
  required List<Map<String, dynamic>> technicians,
  String? selectedId,
}) => _sheet(
  context,
  (ctx) => _PickerSheet(
    title: '选择技师',
    searchHint: '搜索技师姓名',
    emptyText: '没有找到技师',
    items: technicians,
    selectedId: selectedId,
    matches: (t, q) => '${t['name']}'.contains(q),
    rowBuilder: _staffRow,
    dividerIndent: 52,
  ),
);

/// 选择工单（设计稿 WorkOrderPicker）：只列进行中的工单（客户已到店、尚未完成），按到店时间倒序；
/// 搜索按车牌过滤；选中后由调用方带入工单的技师。
Future<PickResult?> showWorkOrderPicker(
  BuildContext context, {
  required List<Map<String, dynamic>> workorders,
  String? selectedId,
}) => _sheet(
  context,
  (ctx) => _PickerSheet(
    title: '选择工单',
    searchHint: '搜索车牌',
    emptyText: '暂无进行中的工单',
    caption: '进行中的工单',
    footnote: '选中工单后，领用技师会自动带入该工单的技师，可再修改。',
    items: workorders,
    selectedId: selectedId,
    matches: (w, q) => '${w['plate']}'
        .replaceAll(RegExp(r'[·\s]'), '')
        .toUpperCase()
        .contains(q.replaceAll(RegExp(r'[·\s]'), '').toUpperCase()),
    rowBuilder: _workOrderRow,
    dividerIndent: 0,
  ),
);

Future<PickResult?> _sheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<PickResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: C.card,
      barrierColor: Colors.black.withValues(alpha: .5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: builder,
    );

typedef _RowBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> item,
  int index,
  bool selected,
);

class _PickerSheet extends StatefulWidget {
  final String title, searchHint, emptyText;
  final String? caption, footnote;
  final List<Map<String, dynamic>> items;
  final String? selectedId;
  final bool Function(Map<String, dynamic> item, String query) matches;
  final _RowBuilder rowBuilder;
  final double dividerIndent;
  const _PickerSheet({
    required this.title,
    required this.searchHint,
    required this.emptyText,
    this.caption,
    this.footnote,
    required this.items,
    required this.selectedId,
    required this.matches,
    required this.rowBuilder,
    required this.dividerIndent,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim();
    final visible = [
      for (final (i, it) in widget.items.indexed)
        if (q.isEmpty || widget.matches(it, q)) (i, it),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: C.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: ts(20, w: FontWeight.w600, h: 28),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        Navigator.of(context).pop(const PickResult(null)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '清除',
                        style: ts(
                          14,
                          w: FontWeight.w500,
                          color: C.muted,
                          h: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: C.chip,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Row(
                  children: [
                    AppIcon('search', size: 18, color: C.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        style: ts(15, h: 22),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: widget.searchHint,
                          hintStyle: ts(15, color: C.faint, h: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.caption != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.caption!,
                  style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
                ),
              ],
              const SizedBox(height: 6),
              Flexible(
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            widget.emptyText,
                            style: ts(13, color: C.muted, h: 18),
                          ),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final (n, entry) in visible.indexed) ...[
                            if (n > 0)
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(
                                  left: widget.dividerIndent,
                                ),
                                color: C.line,
                              ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  Navigator.of(context)
                                      .pop(PickResult(entry.$2)),
                              child: widget.rowBuilder(
                                context,
                                entry.$2,
                                entry.$1,
                                '${entry.$2['id']}' == widget.selectedId,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (widget.footnote != null) ...[
                const SizedBox(height: 12),
                Text(widget.footnote!, style: ts(12, color: C.muted, h: 17)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _check() => Container(
  width: 22,
  height: 22,
  decoration: const BoxDecoration(
    color: Color(0xFF0485F7),
    shape: BoxShape.circle,
  ),
  child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
);

/// 状态小标签：施工中（黄）/ 空闲（绿）。
Widget _statusTag(BuildContext context, bool busy) => Container(
  height: 18,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: busy
        ? dk(
            context,
            const Color(0xFFFDEFD6),
            const Color.fromRGBO(245, 165, 36, 0.18),
          )
        : dk(
            context,
            const Color(0xFFDDF6E7),
            const Color.fromRGBO(52, 199, 89, 0.18),
          ),
    borderRadius: BorderRadius.circular(9),
  ),
  child: Text(
    busy ? '施工中' : '空闲',
    style: ts(
      11,
      w: FontWeight.w600,
      color: busy
          ? dk(context, const Color(0xFF855F2E), const Color(0xFFF5C26B))
          : dk(context, const Color(0xFF2B7745), const Color(0xFF6EE08F)),
      h: 18,
    ),
  ),
);

const _avatarColors = [
  (Color(0xFFE1F0FE), Color(0xFF1E63AE)),
  (Color(0xFFDDF6E7), Color(0xFF2B7745)),
  (Color(0xFFFDEFD6), Color(0xFF855F2E)),
  (Color(0xFFEEEEF0), Color(0xFF3F3F46)),
];

Widget _staffRow(
  BuildContext context,
  Map<String, dynamic> t,
  int index,
  bool selected,
) {
  final name = '${t['name']}';
  final colors = _avatarColors[index % _avatarColors.length];
  final skills = '${t['skills'] ?? ''}'.trim();
  return ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 64),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: colors.$1, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              name.isEmpty ? '' : name.characters.first,
              style: ts(16, w: FontWeight.w600, color: colors.$2, h: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(
                          15,
                          w: selected ? FontWeight.w600 : FontWeight.w500,
                          h: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _statusTag(context, t['status'] == 'busy'),
                  ],
                ),
                if (skills.isNotEmpty)
                  Text(
                    skills,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, color: C.muted, h: 16),
                  ),
              ],
            ),
          ),
          if (selected) _check(),
        ],
      ),
    ),
  );
}

/// 开始时间：今天显示「今天 14:20」，其他日子「11.16 14:20」（北京时间）。
String startedText(String? iso, [DateTime? now]) {
  final t = DateTime.tryParse(iso ?? '');
  if (t == null) return '';
  DateTime bj(DateTime d) => d.toUtc().add(const Duration(hours: 8));
  final d = bj(t);
  final today = bj(now ?? DateTime.now());
  String two(int n) => n.toString().padLeft(2, '0');
  final hm = '${two(d.hour)}:${two(d.minute)}';
  final sameDay =
      d.year == today.year && d.month == today.month && d.day == today.day;
  return sameDay ? '今天 $hm' : '${two(d.month)}.${two(d.day)} $hm';
}

Widget _workOrderRow(
  BuildContext context,
  Map<String, dynamic> w,
  int index,
  bool selected,
) {
  final tech = '${w['technician'] ?? ''}'.trim();
  final start = startedText('${w['started_at'] ?? ''}');
  final sub = [
    if (tech.isNotEmpty) tech,
    if (start.isNotEmpty) '$start 开始',
  ].join(' · ');
  return ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 68),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if ('${w['plate']}'.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B5FD6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF5B9BF0),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${w['plate']}',
                          style: ts(
                            11,
                            w: FontWeight.w600,
                            color: Colors.white,
                            h: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        '${w['service']}'.isEmpty ? '服务项目' : '${w['service']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(
                          15,
                          w: selected ? FontWeight.w600 : FontWeight.w500,
                          h: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(sub, style: ts(12, color: C.muted, h: 16)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _statusTag(context, true),
          if (selected) ...[const SizedBox(width: 12), _check()],
        ],
      ),
    ),
  );
}
