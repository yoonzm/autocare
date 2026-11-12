#!/usr/bin/env python3
"""从员工端设计稿生成页派生 会员查询 / 会员简况 模板（只换数据来源和事件，视觉保持设计稿）。

用法：python3 tools/bind_st_members.py
输入：apps/merchant/lib/pages/gen_st/st_member_page.dart、st_member_info_page.dart
输出：apps/merchant/lib/pages/st_member_template.dart、st_member_info_template.dart
"""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'apps/merchant/lib/pages'
HEADER = "// 从员工端设计稿生成页派生（tools/bind_st_members.py），仅绑定数据和事件；不手工修改 gen_st/。\n"


def match(s, i):
    """i 指向一个开括号，返回匹配的闭括号下标（跳过字符串）。"""
    d, j, q = 0, i, None
    while j < len(s):
        c = s[j]
        if q:
            if c == '\\':
                j += 2
                continue
            if c == q:
                q = None
        elif c in "'\"":
            q = c
        elif c in '([{':
            d += 1
        elif c in ')]}':
            d -= 1
            if d == 0:
                return j
        j += 1
    raise ValueError('unbalanced')


def split_top(body):
    els, d, q, start, j = [], 0, None, 0, 0
    while j < len(body):
        c = body[j]
        if q:
            if c == '\\':
                j += 2
                continue
            if c == q:
                q = None
        elif c in "'\"":
            q = c
        elif c in '([{':
            d += 1
        elif c in ')]}':
            d -= 1
        elif c == ',' and d == 0:
            els.append(body[start:j])
            start = j + 1
        j += 1
    tail = body[start:]
    if tail.strip():
        els.append(tail)
    return [e.strip() for e in els]


def must(s, old, new, count=1):
    assert s.count(old) == count, (old, s.count(old))
    return s.replace(old, new)


def list_region(s, marker):
    """marker 之后第一个 `[`..`]` 列表，返回 (start, end, 元素)。"""
    i = s.index(marker)
    lb = s.index('[', i)
    rb = match(s, lb)
    return lb, rb, split_top(s[lb + 1:rb])


def build_member():
    s = (ROOT / 'gen_st/st_member_page.dart').read_text(encoding='utf-8')
    flow_i = s.index('flow: hcol(')
    ov_i = s.index('overlays: [')
    ov_end = match(s, s.index('[', ov_i))
    head = s[:flow_i]
    flow = s[flow_i:ov_i]
    # 1) 底部导航由员工外壳提供，模板不带
    # 2) 搜索框接入输入回调；右侧扫码图标跳到真实的车牌扫码
    flow = must(flow, "HInput(style:", "HInput(onChanged: onQuery, style:")
    # 3) 最近到店列表 → 数据
    lb, rb, els = list_region(flow, "hcol([hTap(context, hbox(minH: 72")
    rows = [e for e in els if e.startswith('hTap(')]
    divider = [e for e in els if not e.startswith('hTap(')][0]
    assert len(rows) == 3
    def row_fn(e):
        e = must(e, ", to: 'StMemberInfo')", ", onTap: () => onOpen(m))")
        return e
    r = [row_fn(x) for x in rows]
    # 文本占位：用第 i 行的字面量替换为数据
    def bind(e, initial, name, level, sub):
        e = must(e, "Text('%s'," % initial, "Text(_initial(m),")
        e = must(e, "Text('%s'," % name, "Text('${m['name'] ?? ''}',")
        e = must(e, "Text('%s'," % level, "Text(_level(m),")
        e = must(e, "Text('%s'," % sub, "Text(_sub(m),")
        return e
    r[0] = bind(r[0], '王', '王建国', '黑金', '138****6021 · 沪A·8K29M')
    r[1] = bind(r[1], '李', '李梅', '金卡', '139****2208 · 沪AF·09316')
    r[2] = bind(r[2], '赵', '赵磊', '银卡', '137****5560 · 沪B·5X770')
    row_method = ("  Widget _row(BuildContext context, int i, Map<String, dynamic> m) {\n"
                  "    switch (i % 3) {\n"
                  "      case 0:\n        return " + r[0] + ";\n"
                  "      case 1:\n        return " + r[1] + ";\n"
                  "      default:\n        return " + r[2] + ";\n    }\n  }\n")
    new_list = ("hcol([if (items.isEmpty) hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), "
                "child: hrow([Expanded(flex: 1, child: Text(empty, style: hts(14, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 20)))], "
                "main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0)), "
                "for (var i = 0; i < items.length; i++) ...[if (i > 0) " + divider + ", _row(context, i, items[i])]")
    flow = flow[:flow.index("hcol([hTap(context, hbox(minH: 72")] + new_list + flow[rb:]
    body = f'''{HEADER}import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';

/// 员工端「会员查询」→「会员简况」之间传递会员 ID。
class StMemberFlow {{
  static String? currentId;
}}

/// 员工端会员查询：只返回脱敏后的服务相关信息（服务端校验「会员查询」权限）。
class StMemberTemplate extends StatefulWidget {{
  final List<Map<String, dynamic>> initial;
  const StMemberTemplate({{super.key, required this.initial}});

  @override
  State<StMemberTemplate> createState() => _StMemberTemplateState();
}}

class _StMemberTemplateState extends State<StMemberTemplate> {{
  late List<Map<String, dynamic>> items = widget.initial;
  String query = '';
  Timer? _debounce;
  int _seq = 0;

  @override
  void dispose() {{
    _debounce?.cancel();
    super.dispose();
  }}

  void onQuery(String text) {{
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text.trim()));
  }}

  Future<void> _search(String q) async {{
    final seq = ++_seq;
    try {{
      final d = await merchantApi.staffWork('staff_member_search', {{'q': q}});
      if (!mounted || seq != _seq) return;
      setState(() {{
        query = q;
        items = [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
      }});
    }} catch (e) {{
      if (mounted && seq == _seq) hToast(context, '查询失败：$e');
    }}
  }}

  String get empty => query.isEmpty ? '暂无到店记录' : '没有找到匹配的会员';

  void onOpen(Map<String, dynamic> m) {{
    StMemberFlow.currentId = '${{m['id']}}';
    openRoute(context, 'StMemberInfo');
  }}

  String _initial(Map<String, dynamic> m) => stInitial('${{m['name'] ?? ''}}');
  String _level(Map<String, dynamic> m) => '${{m['level'] ?? ''}}'.isEmpty ? '会员' : '${{m['level']}}';
  String _sub(Map<String, dynamic> m) {{
    final plate = '${{m['plate'] ?? ''}}';
    return plate.isEmpty ? '${{m['phone_masked'] ?? ''}}' : '${{m['phone_masked'] ?? ''}} · $plate';
  }}

{row_method}
  @override
  Widget build(BuildContext context) {{
{head[head.index('    return HPage('):]}{flow}overlays: [],
    );
  }}
}}

/// 员工底部「会员」Tab / 会员查询页：默认列出最近到店的会员。
class StMemberLivePage extends StatelessWidget {{
  const StMemberLivePage({{super.key}});

  @override
  Widget build(BuildContext context) => StLive(
    title: '会员查询',
    load: () => merchantApi.staffWork('staff_member_search', {{'q': ''}}),
    builder: (_, d) => StMemberTemplate(
      initial: [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)],
    ),
  );
}}
'''
    (ROOT / 'st_member_template.dart').write_text(body, encoding='utf-8')


def build_info():
    s = (ROOT / 'gen_st/st_member_info_page.dart').read_text(encoding='utf-8')
    flow_i = s.index('flow: hcol(')
    ov_i = s.index('overlays: [')
    head = s[:flow_i]
    flow = s[flow_i:ov_i]
    ov_end = match(s, s.index('[', ov_i))
    overlays = s[ov_i:ov_end + 1]
    # 顶部卡片
    flow = must(flow, "Text('黑金会员',", "Text(_level,")
    flow = must(flow, "Text('王建国',", "Text(_name,")
    flow = must(flow, "Text('138****6021',", "Text(_phone,")
    flow = must(flow, "Text('¥3,680',", "Text(_balance,")
    flow = must(flow, "Text('12,450',", "Text(_points,")
    flow = must(flow, "Text('2',", "Text(_pkgCount,")
    # 次卡列表（两行 → 数据）
    i = flow.index("child: hcol([hrow([hbox(w: 40, h: 40, bg: dk(context, Color(0xFFE1F0FE)")
    lb = flow.index('[', i)
    rb = match(flow, lb)
    rows = split_top(flow[lb + 1:rb])
    assert len(rows) == 2 and rows[0].startswith('hrow(')
    def pk(e, name, sub, pct, ring):
        e = must(e, "Text('%s'," % name, "Text('${p['name'] ?? ''}',")
        e = must(e, "Text('%s'," % sub, "Text(_pkgSub(p),")
        e = must(e, "Text('%s'," % pct, "Text(_pct(p),")
        e = must(e, "hsvg(Svgs.%s," % ring, "hsvg(_ring(p, %s)," % ('true' if ring == 's57' else 'false'))
        return e
    r0 = pk(rows[0], '精致洗车年卡', '剩余 12 次 · 2027.03.31 到期', '40%', 's57')
    r1 = pk(rows[1], '内饰深度清洁', '剩余 4 次 · 2026.12.31 到期', '33%', 's60')
    pkg_method = ("  Widget _pkgRow(BuildContext context, int i, Map<String, dynamic> p) =>\n"
                  "      i.isEven ? " + r0 + " : " + r1 + ";\n")
    flow = flow[:lb + 1] + ("if (_packages.isEmpty) Text('暂无可用次卡', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)), "
                            "for (var i = 0; i < _packages.length; i++) _pkgRow(context, i, _packages[i])") + flow[rb:]
    # 爱车列表
    i = flow.index("child: hcol([hbox(minH: 60")
    lb = flow.index('[', i)
    rb = match(flow, lb)
    vrows = split_top(flow[lb + 1:rb])
    assert len(vrows) == 3, len(vrows)
    divider = vrows[1]
    def veh(e, plate, model):
        e = must(e, "Text('%s'," % plate, "Text(_plate(v),")
        e = must(e, "Text('%s'," % model, "Text(_model(v),")
        return e
    v0 = veh(vrows[0], '沪A·8K29M', '宝马 5 系 · 黑色')
    # 第二辆与第一辆同款式，只换文字
    v1 = veh(vrows[2], '沪AF·09316', '理想 L7 · 灰色')
    veh_method = ("  Widget _vehRow(BuildContext context, int i, Map<String, dynamic> v) =>\n"
                  "      i.isEven ? " + v0 + " : " + v1 + ";\n")
    flow = flow[:lb + 1] + ("if (_vehicles.isEmpty) Text('暂无登记车辆', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)), "
                            "for (var i = 0; i < _vehicles.length; i++) ...[if (i > 0) " + divider + ", _vehRow(context, i, _vehicles[i])]") + flow[rb:]
    # 底部按钮：次卡核销 / 为他开单 暂无后端，明确提示 TODO
    overlays = must(overlays, "to: 'StVerify'", "onTap: () => hToast(context, '次卡核销暂未接通：需要会员本人确认的后端接口')")
    overlays = must(overlays, "to: 'StOrder'", "onTap: () => hToast(context, '快速开单暂未接通：需要技师提交开单的后端接口')")
    body = f'''{HEADER}import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/kit.dart';
import 'gen_st/svgs.dart';
import 'st_live.dart';
import 'st_member_template.dart' show StMemberFlow;

/// 员工端会员简况：仅服务相关、已脱敏的信息，不可修改储值与积分。
class StMemberInfoTemplate extends StatelessWidget {{
  final Map<String, dynamic> d;
  const StMemberInfoTemplate({{super.key, required this.d}});

  String get _name => '${{d['name'] ?? ''}}';
  String get _level => '${{d['level'] ?? ''}}'.isEmpty ? '会员' : '${{d['level']}}';
  String get _phone => '${{d['phone_masked'] ?? ''}}';
  String get _balance => stMoney(d['balance']);
  String get _points => stMoney(((d['points'] as num?) ?? 0).toInt()).substring(1);
  List<Map<String, dynamic>> get _packages => [for (final x in (d['packages'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
  List<Map<String, dynamic>> get _vehicles => [for (final x in (d['vehicles'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
  String get _pkgCount => '${{_packages.length}}';

  double _frac(Map<String, dynamic> p) {{
    final total = ((p['total'] as num?) ?? 0).toDouble();
    return total <= 0 ? 0 : (((p['remaining'] as num?) ?? 0).toDouble() / total).clamp(0, 1).toDouble();
  }}

  String _pct(Map<String, dynamic> p) => '${{(_frac(p) * 100).round()}}%';

  String _pkgSub(Map<String, dynamic> p) {{
    final left = '剩余 ${{((p['remaining'] as num?) ?? 0).toInt()}} 次';
    final t = DateTime.tryParse('${{p['expires_at'] ?? ''}}')?.toUtc().add(const Duration(hours: 8));
    if (t == null) return '$left · 长期有效';
    String two(int n) => n.toString().padLeft(2, '0');
    return '$left · ${{t.year}}.${{two(t.month)}}.${{two(t.day)}} 到期';
  }}

  /// 圆环：与设计稿相同的 SVG（周长 110），按剩余比例画进度。
  String _ring(Map<String, dynamic> p, bool blue) =>
      '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40" fill="none" aria-hidden="true">'
      '<circle cx="20.0" cy="20.0" r="17.5" stroke="#E4E4E7" stroke-width="5"></circle>'
      '<circle cx="20.0" cy="20.0" r="17.5" stroke="${{blue ? '#0485F7' : '#F5A524'}}" stroke-width="5" stroke-linecap="round" '
      'stroke-dasharray="${{(110 * _frac(p)).toStringAsFixed(1)}} 110.0"></circle></svg>';

  String _plate(Map<String, dynamic> v) => '${{v['plate'] ?? ''}}';
  String _model(Map<String, dynamic> v) {{
    final parts = ['${{v['model'] ?? ''}}', '${{v['color'] ?? ''}}'].where((e) => e.isNotEmpty);
    return parts.isEmpty ? '未登记车型' : parts.join(' · ');
  }}

{pkg_method}
{veh_method}
  @override
  Widget build(BuildContext context) {{
{head[head.index('    return HPage('):]}{flow}{overlays},
    );
  }}
}}

/// 会员简况：读取「会员查询」里选中的会员。
class StMemberInfoLivePage extends StatelessWidget {{
  const StMemberInfoLivePage({{super.key}});

  @override
  Widget build(BuildContext context) => StLive(
    title: '会员简况',
    load: () {{
      final id = StMemberFlow.currentId;
      if (id == null) return Future.error(const AppError('请先选择会员', type: AppErrorType.notFound));
      return merchantApi.staffWork('staff_member_info', {{'id': id}});
    }},
    builder: (_, d) => StMemberInfoTemplate(d: d),
  );
}}
'''
    (ROOT / 'st_member_info_template.dart').write_text(body, encoding='utf-8')


if __name__ == '__main__':
    build_member()
    build_info()
