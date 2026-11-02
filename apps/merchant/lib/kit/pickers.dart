// 表单里的选择类交互：日期、车型、城市、列表选择、金额输入、车牌输入。数据均为 mock。
import 'async_kit.dart';
import 'kit.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/registration_draft.dart';
import '../backend/store_profile.dart';
import '../backend/catalog_draft.dart';
import '../mock/mock_data.dart';
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

class HStrHolder extends StatefulWidget {
  final String initial;
  final Widget Function(BuildContext, StrCtrl) builder;
  const HStrHolder({super.key, required this.initial, required this.builder});
  @override
  State<HStrHolder> createState() => _HStrHolderState();
}

class _HStrHolderState extends State<HStrHolder> {
  late final StrCtrl ctrl;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final route = ModalRoute.of(context)?.settings.name;
      if (route == 'RegShop' && widget.initial == '上海市 · 浦东新区') {
        // 注册时城市必须自己选，不预设成设计稿里的示例城市。
        ctrl = StrCtrl(
          RegistrationDraft.cityPlaceholder,
          placeholder: RegistrationDraft.cityPlaceholder,
        );
        RegistrationDraft.city = '';
        ctrl.addListener(() {
          RegistrationDraft.city = ctrl.v == ctrl.placeholder ? '' : ctrl.v;
        });
      } else if (merchantApi.hasSession &&
          route == 'CardTierEdit' &&
          (widget.initial == '2 倍' || widget.initial == '赠精致洗车 2 次')) {
        // 卡种编辑页的积分倍率 / 生日礼：值来自正在编辑的卡种，选择后写回草稿
        final multiplier = widget.initial == '2 倍';
        ctrl = StrCtrl(
          multiplier ? CatalogDraft.multiplierLabel : CatalogDraft.giftLabel,
        );
        ctrl.addListener(
          () => multiplier
              ? CatalogDraft.setMultiplier(ctrl.v)
              : CatalogDraft.setGift(ctrl.v),
        );
      } else if (merchantApi.hasSession &&
          route == 'PackageEdit' &&
          (widget.initial == '2 份' || widget.initial == '全部车型')) {
        // 套餐编辑页的每人限购 / 适用车型：值来自正在编辑的套餐，选择后写回草稿
        final limit = widget.initial == '2 份';
        ctrl = StrCtrl(
          limit
              ? CatalogDraft.packageLimitLabel
              : CatalogDraft.packageVehicleScope,
        );
        ctrl.addListener(
          () => limit
              ? CatalogDraft.setPackageLimit(ctrl.v)
              : CatalogDraft.set('packages', 'vehicle_scope', ctrl.v),
        );
      } else {
        ctrl = StrCtrl(
          route == 'ServiceEdit' && widget.initial == '镀晶镀膜'
              ? CatalogDraft.text('services', 'category', widget.initial)
              : widget.initial,
        );
      }
      initialized = true;
    }
  }

  bool initialized = false;
  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, ctrl);
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
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(
          '取消',
          style: _ts(15, w: FontWeight.w500, c: _muted),
        ),
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
          : TextButton(
              onPressed: onOk,
              child: Text(
                '确定',
                style: _ts(15, w: FontWeight.w600, c: _primary),
              ),
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
) => _sheet<String>(
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
                            o,
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
bool memberMatches(Member m, String q) {
  final k = q.trim().toLowerCase().replaceAll(RegExp(r'[\s·]'), '');
  if (k.isEmpty) return true;
  return m.name.toLowerCase().contains(k) ||
      m.plate.toLowerCase().replaceAll('·', '').contains(k) ||
      m.phone.contains(k) ||
      m.level.contains(k);
}

Future<Member?> pickMember(
  BuildContext context, {
  Member? current,
  String title = '选择客户',
}) {
  return showModalBottomSheet<Member>(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _MemberPicker(current: current, title: title),
  );
}

class _MemberPicker extends StatefulWidget {
  final Member? current;
  final String title;
  const _MemberPicker({this.current, required this.title});
  @override
  State<_MemberPicker> createState() => _MemberPickerState();
}

class _MemberPickerState extends State<_MemberPicker> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = [
      for (final m in members)
        if (memberMatches(m, q)) m,
    ];
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: _ts(15, w: FontWeight.w500, c: _muted),
                      ),
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
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: _muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => q = v),
                          onTapOutside: onTapOutsideDismiss,
                          style: _ts(14),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: '搜索姓名 / 车牌 / 手机号',
                            hintStyle: TextStyle(fontSize: 14, color: _muted),
                          ),
                        ),
                      ),
                      if (q.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => q = ''),
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: C.faint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text('没有找到匹配的客户', style: _ts(14, c: _muted)),
                      )
                    : ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        children: [
                          for (final m in list)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.pop(context, m),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: _line),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: m.level == '黑金' ? _ink : C.chip,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        m.name.substring(0, 1),
                                        style: _ts(
                                          15,
                                          w: FontWeight.w600,
                                          c: m.level == '黑金'
                                              ? const Color(0xFFF5D78E)
                                              : C.sub,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                m.name,
                                                style: _ts(
                                                  15,
                                                  w: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                m.level,
                                                style: _ts(
                                                  11,
                                                  w: FontWeight.w600,
                                                  c: _muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${m.plate} · ${m.phone.isEmpty ? '' : '${m.phone.substring(0, 3)} **** ${m.phone.substring(7)}'}',
                                            style: _ts(12, c: _muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.current == m)
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
      ),
    );
  }
}

// ───────── 日期 ─────────
const _today = (2026, 10, 31);

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
  final now = DateTime(_today.$1, _today.$2, _today.$3);
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
const cityData = <String, List<String>>{
  '上海市': ['浦东新区', '徐汇区', '静安区', '闵行区', '杨浦区'],
  '北京市': ['朝阳区', '海淀区', '东城区', '西城区'],
  '杭州市': ['西湖区', '余杭区', '滨江区'],
  '南京市': ['玄武区', '鼓楼区', '江宁区'],
  '苏州市': ['姑苏区', '吴中区', '工业园区'],
  '广州市': ['天河区', '越秀区', '番禺区'],
  '深圳市': ['南山区', '福田区', '宝安区'],
  '成都市': ['锦江区', '武侯区', '高新区'],
  '武汉市': ['武昌区', '江汉区', '洪山区'],
};

Future<String?> pickCity(BuildContext context, String current) {
  final cities = cityData.keys.toList();
  var ci = cities.indexWhere((c) => current.startsWith(c));
  if (ci < 0) ci = 0;
  var di = cityData[cities[ci]]!.indexWhere((d) => current.endsWith(d));
  if (di < 0) di = 0;
  return _sheet<String>(
    context,
    (ctx) => StatefulBuilder(
      builder: (ctx, setS) {
        final ds = cityData[cities[ci]]!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(
              ctx,
              '选择所在城市',
              onOk: () => Navigator.pop(
                ctx,
                '${cities[ci]} · ${ds[di.clamp(0, ds.length - 1)]}',
              ),
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
                          initialItem: ci,
                        ),
                        onSelectedItemChanged: (i) => setS(() {
                          ci = i;
                          di = 0;
                        }),
                        children: [
                          for (final c in cities) Center(child: Text(c)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        key: ValueKey(ci),
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: di,
                        ),
                        onSelectedItemChanged: (i) => di = i,
                        children: [for (final d in ds) Center(child: Text(d))],
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
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('取消', style: _ts(15, c: _muted)),
        ),
        TextButton(
          onPressed: () {
            final v = double.tryParse(text.text) ?? 0;
            Navigator.pop(ctx, '¥${v.toStringAsFixed(2)}');
          },
          child: Text(
            '确定',
            style: _ts(15, w: FontWeight.w600, c: _primary),
          ),
        ),
      ],
    ),
  );
}

// ───────── 入口：按字段类型选择 ─────────
const _techs = ['老周', '小陈', '张师傅', '李国强', '王磊'];

Future<void> hPick(
  BuildContext context,
  String kind,
  String label,
  StrCtrl c,
) async {
  final route = ModalRoute.of(context)?.settings.name;
  if (merchantApi.hasSession && route == 'ServiceEdit' && kind == 'duration') {
    hToast(context, '此字段暂未接通');
    return;
  }
  String? r;
  switch (kind) {
    case 'birthday':
      r = await pickDate(context, '选择生日', birthday: true, current: c.v);
    case 'datefull':
      r = await pickDate(
        context,
        '选择$label',
        birthday: false,
        current: c.v,
        fullFormat: true,
      );
    case 'date':
      r = await pickDate(
        context,
        '选择$label',
        birthday: false,
        current: c.v,
        pastOnly: true,
      );
    case 'time':
      r = await pickTime(context, label.isEmpty ? '选择时间' : '选择$label时间', c.v);
    case 'car':
      r = await pickCarModel(context, c.v);
    case 'city':
      r = await pickCity(context, c.v);
    case 'amount':
      r = await pickAmount(context, label, c.v);
    case 'referrer':
      final m = await pickMember(context, title: '选择推荐人');
      if (m != null) r = '${m.name} · ${m.level}';
    case 'category':
      r = await pickFromList(context, '选择分类', [
        '镀晶镀膜',
        '洗车',
        '贴膜',
        '内饰',
        '改色膜',
        '保养维修',
      ], c.v);
    case 'duration':
      r = await pickFromList(context, '标准工时', [
        '0.5 小时',
        '1 小时',
        '2 小时',
        '3 小时',
        '4 小时',
        '6 小时',
        '8 小时',
        '2 天',
      ], c.v);
    case 'supplier':
      r = await pickFromList(context, '选择供应商', [
        '蓝盾膜业',
        '驰光化工',
        '车美汇',
        '金牌耗材',
        '新材科技',
      ], c.v);
    case 'payee':
      r = await pickFromList(context, '选择收款方', [
        '市供电局',
        '自来水公司',
        '房东',
        '美团',
        '广告公司',
        '物业',
      ], c.v);
    case 'account':
      r = await pickFromList(context, '选择$label', [
        '微信',
        '支付宝',
        '现金',
        '对公转账',
        '银行卡',
      ], c.v);
    case 'station':
      r = await pickFromList(context, '选择工位', [
        '1 号工位 · 空闲',
        '2 号工位 · 施工中',
        '3 号工位 · 施工中',
        '4 号工位 · 空闲（推荐）',
        '5 号工位 · 空闲',
      ], c.v);
    case 'tech':
      r = await pickFromList(context, '选择技师', _techs, c.v);
    case 'workorder':
      r = await pickFromList(context, '关联工单', [
        '沪A·8K29M 镀晶养护',
        '沪AD·61207 全车隐形车衣',
        '沪B·2C519 全车精洗 · 打蜡',
      ], c.v);
    case 'multiplier':
      r = await pickFromList(context, '积分倍率', [
        '1 倍',
        '1.5 倍',
        '2 倍',
        '3 倍',
      ], c.v);
    case 'gift':
      r = await pickFromList(context, '生日礼', [
        '不赠送',
        '赠精致洗车 1 次',
        '赠精致洗车 2 次',
        '赠 50 元券',
      ], c.v);
    case 'packageLimit':
      r = await pickFromList(context, '每人限购', [
        '不限',
        '1 份',
        '2 份',
        '3 份',
        '5 份',
        '10 份',
      ], c.v);
    case 'vehicleScope':
      r = await pickFromList(context, '适用车型', [
        '全部车型',
        '仅轿车',
        '仅 SUV',
        '仅 MPV',
        '新能源车',
      ], c.v);
    case 'budgetFrom':
      r = await pickFromList(context, '调剂来源', [
        '营销',
        '人工',
        '房租',
        '水电',
        '其他',
      ], c.v);
    default:
      r = await pickFromList(context, label, [c.v], c.v);
  }
  if (r != null) {
    c.set(r);
    if (!context.mounted) return;
    if (kind == 'category' &&
        ModalRoute.of(context)?.settings.name == 'ServiceEdit') {
      CatalogDraft.set('services', 'category', r);
    }
  }
}

// ───────── 车牌输入 ─────────
const _provinces = '京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼';
const _alnum = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';

/// 新能源 / 燃油车切换（与页面上的“燃油车 · 蓝牌 / 新能源 · 绿牌”分段控件联动）。
final ValueNotifier<bool> plateEnergy = ValueNotifier<bool>(true);

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
  final String initial;
  final bool green;

  /// 是否跟随页面上的 plateEnergy 分段控件。
  final bool linked;
  const HPlate({
    super.key,
    required this.initial,
    required this.green,
    this.linked = false,
  });
  @override
  State<HPlate> createState() => _HPlateState();
}

class _HPlateState extends State<HPlate> {
  late final PlateCtrl ctrl = PlateCtrl(widget.initial, widget.green);
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.linked) plateEnergy.value = widget.green;
    if (widget.linked) plateEnergy.addListener(_sync);
  }

  void _sync() => ctrl.setGreen(plateEnergy.value);

  @override
  void dispose() {
    if (widget.linked) plateEnergy.removeListener(_sync);
    ctrl.dispose();
    super.dispose();
  }

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
          if (widget.linked) plateEnergy.value = true;
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '完成',
                      style: _ts(16, w: FontWeight.w600, c: _primary),
                    ),
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

// ───────── 获取验证码（60 秒倒计时）─────────
class CodeCtrl extends ChangeNotifier {
  /// 同一页有多个“获取验证码”时的序号（按出现顺序，0 起）。
  int slot = 0;
  int seconds = 0;

  /// 请求验证码中：按钮显示转圈和“发送中…”，期间不可再点；失败立即恢复。
  bool sending = false;
  void setSending(bool v) {
    if (sending == v) return;
    sending = v;
    notifyListeners();
  }

  Timer? _timer;
  void start() {
    seconds = 60;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      seconds--;
      if (seconds <= 0) t.cancel();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HCodeHolder extends StatefulWidget {
  final Widget Function(BuildContext, CodeCtrl) builder;
  const HCodeHolder({super.key, required this.builder});
  @override
  State<HCodeHolder> createState() => _HCodeHolderState();
}

class _HCodeHolderState extends State<HCodeHolder> {
  final CodeCtrl ctrl = CodeCtrl();
  bool _claimed = false;
  String _route = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_claimed) return;
    _claimed = true;
    _route = ModalRoute.of(context)?.settings.name ?? '';
    ctrl.slot = RegistrationDraft.claim('code:$_route', this);
  }

  @override
  void dispose() {
    if (_claimed) RegistrationDraft.release('code:$_route', this);
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, ctrl);
}

void hSendCode(BuildContext context, CodeCtrl c) {
  if (c.seconds > 0 || c.sending) return;
  final route = ModalRoute.of(context)?.settings.name;
  if (route == 'RegPhone') {
    _sendRegistrationCode(context, c);
    return;
  }
  if (route == 'ForgotVerify') {
    // 忘记密码：手机号手动输入（登录页和修改密码页两个入口一样）
    unawaited(
      sendCodeTo(context, c, RegistrationDraft.get('ForgotVerify', '请输入手机号')),
    );
    return;
  }
  if (merchantApi.hasSession && route == 'ChangePhone') {
    // 第一个按钮发到当前手机号，第二个发到新手机号。
    final phone = c.slot == 0
        ? storeProfile.localPhone
        : RegistrationDraft.get('ChangePhone', '请输入新手机号');
    unawaited(sendCodeTo(context, c, phone));
    return;
  }
  c.start();
  hToastOn(ScaffoldMessenger.of(context), '验证码已发送（演示）');
}

Future<void> _sendRegistrationCode(BuildContext context, CodeCtrl c) =>
    sendCodeTo(context, c, RegistrationDraft.get('RegPhone', '请输入手机号'));

/// 向 [phone] 获取验证码（开发环境由后端 mock 返回并直接提示）。
Future<void> sendCodeTo(BuildContext context, CodeCtrl c, String phone) async {
  if (c.sending) return;
  if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
    hToastOn(ScaffoldMessenger.of(context), '请输入正确的 11 位手机号');
    return;
  }
  c.setSending(true);
  try {
    // 加载指示至少停留 500ms，避免一闪而过
    final results = await Future.wait<Object?>([
      merchantApi.sendMockCode(phone),
      Future<void>.delayed(kIndicatorMinShow),
    ]);
    final code = results[0] as String;
    c.setSending(false);
    if (!context.mounted) return;
    c.start();
    hToastOn(ScaffoldMessenger.of(context), '开发环境验证码：$code');
  } catch (e) {
    c.setSending(false);
    // 失败立即恢复可点，直接展示服务端的原因（如“今日发送次数已达上限”）
    if (context.mounted) AppToast.error(context, e);
  }
}

Widget hCodeText(CodeCtrl c, TextStyle style) => ListenableBuilder(
  listenable: c,
  builder: (_, _) {
    if (c.sending) {
      // 设计稿的验证码按钮加载态：转圈（16）+ “发送中…”，灰色
      final grey = style.copyWith(color: _muted);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpinner(size: 16, color: _muted),
          const SizedBox(width: 6),
          Text('发送中…', style: grey),
        ],
      );
    }
    return Text(
      c.seconds > 0 ? '${c.seconds} 秒后重发' : '获取验证码',
      style: c.seconds > 0 ? style.copyWith(color: _muted) : style,
    );
  },
);
