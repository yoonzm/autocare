// Data-bound copy of the designed PackageSvcPickSheet: services come from the
// backend; initial selection is explicit and the result is returned to the caller.
import 'package:flutter/material.dart';

import '../../backend/service_store.dart';
import '../../backend/package_calc.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../theme.dart' show C;
import '../../resources/merchant_svgs.dart';

Future<List<Map<String, dynamic>>?> openPackageServicePicker(
  BuildContext context, {
  required List<Map<String, dynamic>> initialItems,
}) => showModalBottomSheet<List<Map<String, dynamic>>>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  routeSettings: const RouteSettings(name: 'sheet:PackageSvcPick'),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: PackageServicePicker(initialItems: initialItems),
      ),
    ),
  ),
);

class PackageServicePicker extends StatefulWidget {
  final List<Map<String, dynamic>> initialItems;
  const PackageServicePicker({super.key, required this.initialItems});
  @override
  State<PackageServicePicker> createState() => _PackageServicePickerState();
}

class _PackageServicePickerState extends State<PackageServicePicker> {
  /// 已选：service_id -> 次数。进入时带入套餐里已有的服务。
  late final Map<String, int> _picked = {
    for (final e in widget.initialItems)
      '${e['service_id']}': int.tryParse('${e['count']}') ?? 1,
  };
  List<Map<String, dynamic>> _services = const [];
  String _query = '';
  String _category = '全部';

  num _price(Map<String, dynamic> s) => num.tryParse('${s['price']}') ?? 0;

  num get _total => _services.fold<num>(
    0,
    (sum, s) => sum + _price(s) * (_picked['${s['id']}'] ?? 0),
  );

  // 套餐里已有、但服务已被删除 / 停用的项，也要保留并计入已选
  int get _pickedCount => _picked.length;

  void _step(String id, int delta) {
    setState(() {
      final next = (_picked[id] ?? 0) + delta;
      if (next < 1) {
        _picked.remove(id);
      } else if (next <= 999) {
        _picked[id] = next;
      }
    });
  }

  void _confirm() {
    final old = {for (final e in widget.initialItems) '${e['service_id']}': e};
    final byId = {for (final s in _services) '${s['id']}': s};
    final items = <Map<String, dynamic>>[
      for (final entry in _picked.entries)
        if (byId[entry.key] != null)
          {
            'service_id': entry.key,
            'name': byId[entry.key]!['name'],
            'price': byId[entry.key]!['price'],
            'count': entry.value,
          }
        else if (old[entry.key] != null)
          {...old[entry.key]!, 'count': entry.value},
    ];
    Navigator.of(context).pop(items);
  }

  @override
  Widget build(BuildContext context) {
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, const Color(0xFFD4D4D8), const Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text('选择包含服务', style: hts(20, C.ink, w: FontWeight.w600, lh: 28)),
          hbox(
            h: 44,
            bg: dk(context, const Color(0xFFF4F4F5), const Color(0xFF27272A)),
            radius: BorderRadius.circular(22),
            pad: const EdgeInsets.symmetric(horizontal: 14),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s280, Svgs.s281), w: 18, h: 18),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim()),
                    style: hts(14, C.ink),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '搜索服务项目',
                      hintStyle: hts(14, muted),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
          ),
          SizedBox(
            height: 340,
            child: AsyncView<List<Map<String, dynamic>>>(
              // 服务项目走全局缓存（在售的）
              load: () async => [
                for (final s in await ServiceStore.load())
                  if (s['active'] != false) s,
              ],
              isEmpty: (rows) => rows.isEmpty,
              pullToRefresh: false,
              skeleton: const SkeletonList(count: 5),
              empty: (_) => const EmptyView(
                title: '还没有服务项目',
                message: '请先在“服务项目”里新增',
                inline: true,
              ),
              onLoaded: (rows) =>
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _services = rows);
                  }),
              builder: (context, rows) => _list(context, rows),
            ),
          ),
          Text('选中服务后设置包含次数；原价按「单次价 × 次数」自动汇总。', style: hts(12, muted, lh: 17)),
          hbox(
            pad: const EdgeInsets.only(top: 4),
            child: hrow(
              [
                Expanded(
                  child: hcol(
                    [
                      Text('已选 $_pickedCount 项', style: hts(12, muted, lh: 17)),
                      Text(
                        '合计原价 ¥${formatMoney(_total)}',
                        style: hts(15, C.ink, w: FontWeight.w600, lh: 22),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 1,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _confirm,
                  child: hbox(
                    h: 48,
                    bg: const Color(0xFF0485F7),
                    radius: BorderRadius.circular(24),
                    pad: const EdgeInsets.symmetric(horizontal: 28),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Text(
                        '确认添加',
                        style: hts(
                          15,
                          const Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
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
        gap: 14,
      ),
    );
  }

  Widget _chip(String label, bool on) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => _category = label),
    child: hbox(
      h: 30,
      bg: on
          ? dk(context, const Color(0xFF18181B), const Color(0xFF34343A))
          : dk(context, const Color(0xFFF4F4F5), const Color(0xFF27272A)),
      radius: BorderRadius.circular(15),
      pad: const EdgeInsets.symmetric(horizontal: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: Text(
          label,
          style: hts(
            13,
            on
                ? const Color(0xFFFFFFFF)
                : dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
            w: FontWeight.w500,
          ),
        ),
      ),
    ),
  );

  Widget _list(BuildContext context, List<Map<String, dynamic>> rows) {
    final categories = [
      '全部',
      ...{for (final s in rows) '${s['category'] ?? '其他'}'},
    ];
    final shown = [
      for (final s in rows)
        if ((_category == '全部' || '${s['category'] ?? '其他'}' == _category) &&
            (_query.isEmpty || '${s['name']}'.contains(_query)))
          s,
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in categories) ...[
                _chip(c, c == _category),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          const EmptyView(title: '没有匹配的服务', inline: true)
        else
          for (final s in shown) _tile(context, s),
      ],
    );
  }

  Widget _tile(BuildContext context, Map<String, dynamic> s) {
    final id = '${s['id']}';
    final count = _picked[id];
    final on = count != null;
    Widget step(String label) => hbox(
      w: 26,
      h: 26,
      bg: const Color(0xFFFFFFFF),
      radius: BorderRadius.circular(13),
      border: dk(
        context,
        Border.all(color: const Color(0xFFD4D4D8)),
        Border.all(color: const Color(0xFF3F3F46)),
      ),
      align: Alignment.center,
      child: Text(label, style: hts(16, const Color(0xFF18181B), lh: 16)),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: on ? null : () => _step(id, 1),
      child: hbox(
        bg: on
            ? dk(context, const Color(0xFFF2F8FE), const Color(0x140485F7))
            : null,
        radius: BorderRadius.circular(16),
        pad: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        margin: const EdgeInsets.only(bottom: 2),
        child: hrow(
          [
            on
                ? hbox(
                    w: 24,
                    h: 24,
                    bg: const Color(0xFF0485F7),
                    radius: BorderRadius.circular(12),
                    child: hrow(
                      [hsvg(Svgs.s282, w: 14, h: 14)],
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                      gap: 0,
                    ),
                  )
                : hbox(
                    w: 24,
                    h: 24,
                    radius: BorderRadius.circular(12),
                    border: dk(
                      context,
                      Border.all(color: const Color(0xFFD4D4D8), width: 1.5),
                      Border.all(color: const Color(0xFF3F3F46), width: 1.5),
                    ),
                  ),
            hbox(
              w: 40,
              h: 40,
              bg: dk(
                context,
                const Color(0xFFE1F0FE),
                const Color.fromRGBO(4, 133, 247, 0.18),
              ),
              radius: BorderRadius.circular(12),
              child: hrow(
                [hsvg(dk(context, Svgs.s283, Svgs.s284), w: 20, h: 20)],
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                gap: 0,
              ),
            ),
            Expanded(
              child: hcol(
                [
                  Text(
                    '${s['name']}',
                    style: hts(15, C.ink, w: FontWeight.w500, lh: 22),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '单次 ¥${formatMoney(_price(s))}',
                    style: hts(
                      12,
                      dk(
                        context,
                        const Color(0xFF71717A),
                        const Color(0xFF9A9AA3),
                      ),
                      lh: 17,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 1,
              ),
            ),
            if (on)
              HNumberStepper.controlled(
                onDecrease: () => _step(id, -1),
                onIncrease: () => _step(id, 1),
                minus: step('−'),
                value: hbox(
                  minW: 34,
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1,
                    child: Text(
                      '$count 次',
                      style: hts(14, C.ink, w: FontWeight.w600),
                    ),
                  ),
                ),
                plus: step('+'),
                gap: 6,
              ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      ),
    );
  }
}
