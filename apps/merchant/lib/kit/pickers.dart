import 'buttons.dart';
// 表单选择组件；地区来自后端公共字典。
import 'async_kit.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/region_dictionary.dart';
import '../backend/member_flow.dart' show memberFromRow;
import '../pages/members/member_models.dart';
import 'keyboard.dart';

import '../theme.dart' show C;

Color get _ink => C.ink;
Color get _muted => C.muted;
const _primary = Color(0xFF0485F7);
Color get _line => C.line;

// ───────── 取值控制器 ─────────
class StrCtrl extends ChangeNotifier {
  String v;

  /// 还没选择时显示的占位文字（显示为灰色）。
  String? placeholder;
  StrCtrl(this.v, {this.placeholder});
  void set(String s) {
    if (s != v) {
      v = s;
      notifyListeners();
    }
  }
}

/// 显示选择结果；初始是“选填/请选择”这类占位文案时，选择后改用正文颜色。
Widget hStr(StrCtrl c, TextStyle style, {String? placeholder}) =>
    ListenableBuilder(
      listenable: c,
      builder: (_, _) {
        final ph = placeholder ?? c.placeholder;
        return Text(
          c.v,
          style: ph != null && c.v != ph
              ? style.copyWith(color: _ink)
              : c.placeholder != null
              ? style.copyWith(color: _muted)
              : style,
        );
      },
    );

// ───────── 通用底部面板 ─────────
Future<T?> _sheet<T>(
  BuildContext context,
  Widget Function(BuildContext) builder,
) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: C.card,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (ctx) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: builder(ctx),
    ),
  ),
);

TextStyle _ts(double s, {FontWeight w = FontWeight.w400, Color? c}) =>
    TextStyle(
      fontSize: s,
      fontWeight: w,
      color: c ?? _ink,
      decoration: TextDecoration.none,
    );

Widget _handle() => Center(
  child: Container(
    width: 40,
    height: 5,
    margin: const EdgeInsets.only(top: 10, bottom: 6),
    decoration: BoxDecoration(
      color: C.stroke,
      borderRadius: BorderRadius.circular(3),
    ),
  ),
);

Widget _header(BuildContext ctx, String title, {VoidCallback? onOk}) => Padding(
  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
  child: Row(
    children: [
      AppButton(
        label: '取消',
        kind: AppButtonKind.secondary,
        onPressed: () => Navigator.pop(ctx),
      ),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: _ts(17, w: FontWeight.w600),
        ),
      ),
      onOk == null
          ? const SizedBox(width: 64)
          : AppButton(
              label: '确定',
              kind: AppButtonKind.primary,
              onPressed: onOk,
            ),
    ],
  ),
);

/// 单选列表：点选即确定。
Future<String?> pickFromList(
  BuildContext context,
  String title,
  List<String> options,
  String current,
) => pickValue<String>(context, title, options, current, (value) => value);

/// The returned value is independent of its label; labels may be duplicated.
Future<T?> pickValue<T>(
  BuildContext context,
  String title,
  List<T> options,
  T? current,
  String Function(T) label,
) => _sheet<T>(
  context,
  (ctx) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(ctx).size.height * 0.7,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        _header(ctx, title),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            children: [
              for (final o in options)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx, o),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label(o),
                            style: _ts(
                              15,
                              w: o == current
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              c: o == current ? _primary : _ink,
                            ),
                          ),
                        ),
                        if (o == current)
                          const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: _primary,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  ),
);

Widget _wheelTheme(Widget child) => CupertinoTheme(
  // 显式指定亮色和文字颜色：系统为深色模式时，Cupertino 滚轮默认文字是白色，
  // 放在白色面板上就看不见了。
  data: CupertinoThemeData(
    brightness: C.dark ? Brightness.dark : Brightness.light,
    textTheme: CupertinoTextThemeData(
      pickerTextStyle: TextStyle(fontSize: 20, color: _ink),
      dateTimePickerTextStyle: TextStyle(fontSize: 20, color: _ink),
    ),
  ),
  child: child,
);

// ───────── 客户选择（支持按姓名 / 车牌 / 手机号检索）─────────
/// 登录后的会员选择：搜索 / 列表来自后端（姓名、手机号、车牌）。
Future<Member?> pickLiveMember(BuildContext context, {String title = '选择客户'}) =>
    showModalBottomSheet<Member>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _LiveMemberPicker(title: title),
    );

class _LiveMemberPicker extends StatefulWidget {
  final String title;
  const _LiveMemberPicker({required this.title});
  @override
  State<_LiveMemberPicker> createState() => _LiveMemberPickerState();
}

class _LiveMemberPickerState extends State<_LiveMemberPicker> {
  Timer? _debounce;
  Timer? _indicatorTimer;
  bool _showIndicator = false;
  DateTime? _indicatorAt;
  List<Member>? _lastMembers;
  Object? _reportedError;
  int _generation = 0;
  String _q = '';
  late Future<List<Member>> _future;

  @override
  void initState() {
    super.initState();
    _startFetch();
  }

  void _startFetch() {
    final generation = ++_generation;
    _future = _fetch(_q, generation);
    _showIndicator = false;
    _indicatorAt = null;
    _reportedError = null;
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(kIndicatorDelay, () {
      if (mounted && generation == _generation) {
        setState(() {
          _showIndicator = true;
          _indicatorAt = DateTime.now();
        });
      }
    });
  }

  Future<List<Member>> _fetch(String query, int generation) async {
    try {
      final page = await merchantApi.members(query: query, limit: 50);
      return [for (final r in page.items) memberFromRow(r)];
    } finally {
      if (generation == _generation) {
        _indicatorTimer?.cancel();
        final at = _indicatorAt;
        if (at != null) {
          final left = kIndicatorMinShow - DateTime.now().difference(at);
          if (left > Duration.zero) await Future<void>.delayed(left);
        }
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _indicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: h * 0.72,
          child: Column(
            children: [
              _handle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: _ts(17, w: FontWeight.w600),
                      ),
                    ),
                    AppButton(
                      label: '取消',
                      kind: AppButtonKind.text,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: C.inset,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        setState(() {
                          _q = v.trim();
                          _startFetch();
                        });
                      });
                    },
                    style: _ts(14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: '姓名 / 手机号 / 车牌号',
                      hintStyle: _ts(14, c: _muted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Member>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.done &&
                        snap.hasData) {
                      _lastMembers = snap.data;
                    }
                    if (snap.hasError) {
                      if (_lastMembers == null) {
                        return ErrorView(
                          error: AppError.from(snap.error!),
                          onRetry: () => setState(_startFetch),
                        );
                      }
                      if (!identical(_reportedError, snap.error)) {
                        _reportedError = snap.error;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) AppToast.error(context, snap.error!);
                        });
                      }
                    }
                    final list = snap.data ?? _lastMembers;
                    if (list == null) {
                      return _showIndicator
                          ? const SkeletonList(count: 5)
                          : const SizedBox.shrink();
                    }
                    if (list.isEmpty) {
                      return Stack(
                        children: [
                          const EmptyView(
                            title: '没有找到会员',
                            message: '换个姓名、手机号或车牌试试',
                            inline: true,
                          ),
                          if (snap.connectionState == ConnectionState.waiting &&
                              _showIndicator)
                            const Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: LinearProgressIndicator(minHeight: 2),
                            ),
                        ],
                      );
                    }
                    return Stack(
                      children: [
                        ListView(
                          children: [
                            for (final m in list)
                              ListTile(
                                onTap: () => Navigator.pop(context, m),
                                title: Text(m.name, style: _ts(15)),
                                subtitle: Text(
                                  '${m.level} · ${m.plate}',
                                  style: _ts(12, c: _muted),
                                ),
                              ),
                          ],
                        ),
                        if (snap.connectionState == ConnectionState.waiting &&
                            _showIndicator)
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── 日期 ─────────
/// 日期选择。年 / 月 / 日三列联动：月份决定天数（含闰年），并受 [min]、[max] 限制。
/// 生日：1930 年至今天；入库 / 开支等已发生的日期：最近一年内、不晚于今天；其余：前后各一年。
Future<String?> pickDate(
  BuildContext context,
  String title, {
  required bool birthday,
  required String current,
  bool pastOnly = false,
  bool fullFormat = false,
}) {
  final clock = DateTime.now();
  final now = DateTime(clock.year, clock.month, clock.day);
  final min = birthday
      ? DateTime(1930)
      : DateTime(now.year - 1, now.month, now.day);
  final max = (birthday || pastOnly)
      ? now
      : DateTime(now.year + 1, now.month, now.day);
  var picked = birthday ? DateTime(1990, 6, 18) : now;
  final m = RegExp(r'(\d{4})\.(\d{1,2})\.(\d{1,2})').firstMatch(current);
  if (m != null) {
    picked = DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }
  const weeks = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  String caption(DateTime d) {
    final base =
        '${d.year} 年 ${d.month} 月 ${d.day} 日 · ${weeks[d.weekday - 1]}';
    if (birthday) {
      var age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age--;
      }
      return '$base · $age 岁';
    }
    final diff = DateTime(d.year, d.month, d.day).difference(now).inDays;
    return diff == 0
        ? '$base · 今天'
        : (diff > 0 ? '$base · $diff 天后' : '$base · ${-diff} 天前');
  }

  return _sheet<String>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handle(),
          _header(
            ctx,
            title,
            onOk: () {
              final d = picked;
              Navigator.pop(
                ctx,
                (birthday || fullFormat)
                    ? '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}'
                    : (d == now
                          ? '今天 ${d.month}.${d.day.toString().padLeft(2, '0')}'
                          : '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}'),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(caption(picked), style: _ts(13, c: _muted)),
          ),
          SizedBox(
            height: 216,
            child: _wheelTheme(
              CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                dateOrder: DatePickerDateOrder.ymd,
                initialDateTime: picked,
                minimumDate: min,
                maximumDate: max,
                onDateTimeChanged: (d) => setS(() => picked = d),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────── 时间（营业时间等）─────────
Future<String?> pickTime(BuildContext context, String title, String current) {
  final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(current);
  var picked = DateTime(
    2026,
    10,
    31,
    m == null ? 9 : int.parse(m.group(1)!),
    m == null ? 0 : int.parse(m.group(2)!),
  );
  return _sheet<String>(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        _header(
          ctx,
          title,
          onOk: () {
            Navigator.pop(
              ctx,
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
            );
          },
        ),
        SizedBox(
          height: 216,
          child: _wheelTheme(
            CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              minuteInterval: 5,
              initialDateTime: picked,
              onDateTimeChanged: (d) => picked = d,
            ),
          ),
        ),
      ],
    ),
  );
}

// ───────── 品牌车型 ─────────
const carBrands = <String, List<String>>{
  '宝马': ['3系 325Li', '5系 525Li', 'X3', 'X5'],
  '奔驰': ['C 级 C260L', 'E 级 E300L', 'GLC 260'],
  '奥迪': ['A4L', 'A6L', 'Q5L'],
  '大众': ['帕萨特', '迈腾', '途观L'],
  '特斯拉': ['Model 3', 'Model Y'],
  '理想': ['L6', 'L7', 'L9'],
  '蔚来': ['ET5', 'ES6', 'ES8'],
  '比亚迪': ['汉', '唐', '海豹'],
  '丰田': ['凯美瑞', '汉兰达', '埃尔法'],
  '本田': ['雅阁', 'CR-V', '奥德赛'],
};
const carColors = <String>['黑', '白', '灰', '银', '蓝', '红'];

Future<String?> pickCarModel(BuildContext context, String current) {
  final withColor = current.contains(' · ');
  final base = current.split(' · ').first.trim();
  final brands = carBrands.keys.toList();
  var bi = brands.indexWhere((b) => base.startsWith(b));
  if (bi < 0) bi = 0;
  var mi = carBrands[brands[bi]]!.indexWhere((m) => base == '${brands[bi]} $m');
  if (mi < 0) mi = 0;
  var ci = withColor ? carColors.indexOf(current.split(' · ').last.trim()) : 0;
  if (ci < 0) ci = 0;
  return _sheet<String>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setS) {
        final models = carBrands[brands[bi]]!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(
              ctx,
              '选择品牌车型',
              onOk: () {
                final s =
                    '${brands[bi]} ${models[mi.clamp(0, models.length - 1)]}';
                Navigator.pop(ctx, withColor ? '$s · ${carColors[ci]}' : s);
              },
            ),
            SizedBox(
              height: 216,
              child: _wheelTheme(
                Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: bi,
                        ),
                        onSelectedItemChanged: (i) => setS(() {
                          bi = i;
                          mi = 0;
                        }),
                        children: [
                          for (final b in brands) Center(child: Text(b)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CupertinoPicker(
                        key: ValueKey(bi),
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: mi,
                        ),
                        onSelectedItemChanged: (i) => mi = i,
                        children: [
                          for (final m in models) Center(child: Text(m)),
                        ],
                      ),
                    ),
                    if (withColor)
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: ci,
                          ),
                          onSelectedItemChanged: (i) => ci = i,
                          children: [
                            for (final c in carColors) Center(child: Text(c)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

// ───────── 城市 ─────────
Future<CitySelection?> pickCity(BuildContext context, String current) =>
    _sheet<CitySelection>(context, (ctx) => _CitySheet(current: current));

class _CitySheet extends StatefulWidget {
  final String current;
  const _CitySheet({required this.current});
  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  RegionDictionary? data;
  int pi = 0, ci = 0;
  final cityScroll = FixedExtentScrollController();
  final provinceScroll = FixedExtentScrollController();
  final viewKey = GlobalKey<AsyncViewState<RegionDictionary>>();

  @override
  void dispose() {
    cityScroll.dispose();
    provinceScroll.dispose();
    super.dispose();
  }

  void loaded(RegionDictionary value) {
    final provinces = value.provinces;
    pi = provinces.indexWhere((p) => widget.current.startsWith('${p.name} · '));
    if (pi < 0) pi = 0;
    final cities = provinces.isEmpty
        ? <Region>[]
        : value.children(provinces[pi].code);
    ci = cities.indexWhere((c) => widget.current.endsWith(' · ${c.name}'));
    if (ci < 0) ci = 0;
    setState(() => data = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (provinceScroll.hasClients) provinceScroll.jumpToItem(pi);
      if (cityScroll.hasClients) cityScroll.jumpToItem(ci);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provinces = data?.provinces ?? <Region>[];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        _header(
          context,
          '选择所在城市',
          onOk: provinces.isEmpty
              ? null
              : () {
                  final province = provinces[pi];
                  final cities = data!.children(province.code);
                  Navigator.pop(context, CitySelection(province, cities[ci]));
                },
        ),
        SizedBox(
          height: 216,
          child: AsyncView<RegionDictionary>(
            key: viewKey,
            load: RegionDictionary.load,
            isEmpty: (d) => d.provinces.isEmpty,
            onLoaded: loaded,
            pullToRefresh: false,
            inlineError: true,
            skeletonScrollable: false,
            skeleton: Center(child: AppSpinner(color: C.ink)),
            empty: (_) => EmptyView(
              inline: true,
              title: '地区数据尚未就绪',
              actionLabel: '重试',
              onAction: () => viewKey.currentState?.reload(),
            ),
            builder: (_, dictionary) {
              final ps = dictionary.provinces;
              final cities = dictionary.children(ps[pi].code);
              return _wheelTheme(
                Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: provinceScroll,
                        itemExtent: 40,
                        onSelectedItemChanged: (i) {
                          setState(() {
                            pi = i;
                            ci = 0;
                          });
                          if (cityScroll.hasClients) cityScroll.jumpToItem(0);
                        },
                        children: [
                          for (final p in ps) Center(child: Text(p.name)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        key: ValueKey(ps[pi].code),
                        scrollController: cityScroll,
                        itemExtent: 40,
                        onSelectedItemChanged: (i) => setState(() => ci = i),
                        children: [
                          for (final c in cities) Center(child: Text(c.name)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ───────── 金额 ─────────
Future<String?> pickAmount(BuildContext context, String title, String current) {
  final text = TextEditingController(
    text: current.replaceAll(RegExp(r'[^0-9.]'), ''),
  );
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: _ts(17, w: FontWeight.w600)),
      content: TextField(
        controller: text,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onTapOutside: onTapOutsideDismiss,
        style: _ts(24, w: FontWeight.w600),
        decoration: const InputDecoration(
          prefixText: '¥ ',
          border: InputBorder.none,
        ),
      ),
      actions: [
        AppButton(
          label: '取消',
          kind: AppButtonKind.secondary,
          onPressed: () => Navigator.pop(ctx),
        ),
        AppButton(
          label: '确定',
          kind: AppButtonKind.primary,
          onPressed: () {
            final v = double.tryParse(text.text) ?? 0;
            Navigator.pop(ctx, '¥${v.toStringAsFixed(2)}');
          },
        ),
      ],
    ),
  );
}

// ───────── 车牌输入 ─────────
const _provinces = '京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼';
const _alnum = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';

/// 新能源 / 燃油车切换（与页面上的“燃油车 · 蓝牌 / 新能源 · 绿牌”分段控件联动）。

class PlateCtrl extends ChangeNotifier {
  final List<String> chars = List.filled(8, '');
  bool green;
  int focus;
  PlateCtrl(String initial, this.green) : focus = 0 {
    final cs = initial.characters.toList();
    for (var i = 0; i < cs.length && i < 8; i++) {
      chars[i] = cs[i];
    }
    focus = (cs.length - 1).clamp(0, 7);
  }

  int get length => green ? 8 : 7;

  /// 已输入的车牌（不含空位）。
  String get text => chars.take(length).join();

  void setText(String value) {
    final next = value.characters.take(8).toList();
    for (var i = 0; i < chars.length; i++) {
      chars[i] = i < next.length ? next[i] : '';
    }
    focus = next.length.clamp(0, length - 1);
    notifyListeners();
  }

  void setGreen(bool g) {
    if (g == green) return;
    green = g;
    if (!g) chars[7] = '';
    focus = focus.clamp(0, length - 1);
    notifyListeners();
  }

  void focusAt(int i) {
    focus = i.clamp(0, length - 1);
    notifyListeners();
  }

  void input(String ch) {
    chars[focus] = ch;
    if (focus < length - 1) focus++;
    notifyListeners();
  }

  void backspace() {
    if (chars[focus].isEmpty && focus > 0) focus--;
    chars[focus] = '';
    notifyListeners();
  }
}

class HPlate extends StatefulWidget {
  final PlateCtrl controller;
  const HPlate({super.key, required this.controller});
  @override
  State<HPlate> createState() => _HPlateState();
}

class _HPlateState extends State<HPlate> {
  PlateCtrl get ctrl => widget.controller;
  bool _sheetOpen = false;

  Future<void> _openKeyboard() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.dark
          ? const Color(0xFF111114)
          : const Color(0xFFF2F2F7),
      barrierColor: Colors.black12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PlateKeyboard(ctrl: ctrl),
    );
    _sheetOpen = false;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: ctrl,
    builder: (context, _) {
      final g = ctrl.green;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (var i = 0; i < 8; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(child: _cell(i, g)),
            ],
          ],
        ),
      );
    },
  );

  Widget _cell(int i, bool g) {
    final inRange = i < ctrl.length;
    final ch = ctrl.chars[i];
    final focused = inRange && i == ctrl.focus;
    if (!inRange) {
      // 第 8 位：燃油车上显示“新能源”入口
      return GestureDetector(
        onTap: () => setState(() {
          ctrl.setGreen(true);
          ctrl.focusAt(7);
          _openKeyboard();
        }),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.stroke),
          ),
          child: Text('新能源', style: _ts(9, c: _muted)),
        ),
      );
    }
    final first = i == 0;
    final bg = first
        ? (g ? const Color(0xFF1F9D55) : const Color(0xFF0B5FD6))
        : (g ? C.greenSoft : C.inset);
    final fg = first ? Colors.white : (g ? C.greenInk : _ink);
    return GestureDetector(
      onTap: () {
        ctrl.focusAt(i);
        _openKeyboard();
      },
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: focused ? Border.all(color: _primary, width: 2) : null,
        ),
        child: Text(
          ch.isEmpty ? (first ? '省' : '') : ch,
          style: _ts(
            18,
            w: FontWeight.w600,
            c: ch.isEmpty ? fg.withValues(alpha: 0.5) : fg,
          ),
        ),
      ),
    );
  }
}

class _PlateKeyboard extends StatelessWidget {
  final PlateCtrl ctrl;
  const _PlateKeyboard({required this.ctrl});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final province = ctrl.focus == 0;
        final keys = (province ? _provinces : _alnum).characters.toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        province ? '选择省份简称' : '输入字母或数字',
                        style: _ts(13, c: _muted),
                      ),
                    ),
                  ),
                  AppButton(
                    label: '完成',
                    kind: AppButtonKind.primary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final k in keys)
                    GestureDetector(
                      onTap: () => ctrl.input(k),
                      child: Container(
                        width: province ? 34 : 33,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(k, style: _ts(18, w: FontWeight.w500)),
                      ),
                    ),
                  GestureDetector(
                    onTap: ctrl.backspace,
                    child: Container(
                      width: 56,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: C.stroke,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 20,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
