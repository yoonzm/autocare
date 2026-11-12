#!/usr/bin/env python3
"""从员工端设计稿生成页派生 快速开单 / 待收银 模板，并给前台工作台补上“待收银 · 技师提交”。

用法：python3 tools/bind_st_orders.py（可重复执行；前台工作台的补丁幂等）
输入：apps/merchant/lib/pages/gen_st/st_order_page.dart、st_cash_queue_page.dart、st_front_home_page.dart
输出：pages/st_order_template.dart、pages/st_cash_queue_template.dart；就地更新 pages/st_front_home_template.dart
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from bind_st_members import ROOT, HEADER, match, split_top, must  # noqa: E402

SH = None


def children(row):
    """`child: hrow([ … ], …)` 里的各个子元素，以及 hrow 列表之前 / 之后的文本。"""
    i = row.index('child: hrow([')
    lb = row.index('[', i)
    rb = match(row, lb)
    return row[:i], split_top(row[lb + 1:rb]), row[rb + 1:]


def build_order():
    s = (ROOT / 'gen_st/st_order_page.dart').read_text(encoding='utf-8')
    flow_i = s.index('flow: hcol(')
    ov_i = s.index('overlays: [')
    ov_end = match(s, s.index('[', ov_i))
    head = s[:flow_i]
    flow = s[flow_i:ov_i]
    overlays = s[ov_i:ov_end + 1]

    flow = must(flow, "Text('沪A·8K29M',", "Text(_plate,")
    flow = must(flow, "Text('王建国 · 黑金会员',", "Text(_who,")
    flow = must(flow, "HInput(style:", "HInput(onChanged: (t) => note = t, style:")

    marker = "pad: EdgeInsets.fromLTRB(0, 4, 0, 4), child: hcol([hbox(minH: 72"
    i = flow.index(marker)
    lb = flow.index('[', flow.index('child: hcol([', i))
    rb = match(flow, lb)
    els = split_top(flow[lb + 1:rb])
    rows = [els[0], els[2], els[4]]
    divider = els[1]
    pre0, ch0, _ = children(rows[0])
    pre1, ch1, _ = children(rows[1])
    pre2, ch2, post2 = children(rows[2])
    sel_circle, unsel_circle = ch0[3], ch2[3]
    name_child = must(ch2[1], "Text('精致洗车',", "Text(name,")
    name_child = must(name_child, "Text('会员价 9 折',", "Text(sub,")
    price_child = must(ch2[2], "Text('¥68',", "Text(price,")
    pre_sel = pre2.replace("hbox(minH: 72, pad:", "hbox(minH: 72, bg: selected ? dk(context, Color(0xFFF3F9FF), Color.fromRGBO(4, 133, 247, 0.1)) : null, pad:")
    assert pre_sel != pre2
    row_expr = (pre_sel + "child: hrow([_icon(context, i), " + name_child + ", " + price_child +
                ", selected ? " + sel_circle + " : " + unsel_circle + "]" + post2)
    icon_method = ("  Widget _icon(BuildContext context, int i) {\n    switch (i % 3) {\n"
                   "      case 0:\n        return " + ch0[0] + ";\n"
                   "      case 1:\n        return " + ch1[0] + ";\n"
                   "      default:\n        return " + ch2[0] + ";\n    }\n  }\n")
    list_expr = ("if (services.isEmpty) hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([Expanded(flex: 1, "
                 "child: Text('暂无在售的服务项目', style: hts(14, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 20)))], "
                 "main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0)), "
                 "for (var i = 0; i < services.length; i++) ...[if (i > 0) " + divider + ", _row(context, i, services[i])]")
    flow = flow[:lb + 1] + list_expr + flow[rb:]

    overlays = must(overlays, "Text('已选 2 项 · 会员价',", "Text(_selText,")
    overlays = must(overlays, "Text('¥1,764',", "Text(_totalText,")
    overlays = must(overlays, "Text('提交到收银', style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22))",
                    "hBusy('StOrder>submit', Text('提交到收银', style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22)))")
    overlays = must(overlays, "to: 'StHome'", "onTap: _submit")

    body = f'''{HEADER}import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/service_store.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';
import 'st_member_template.dart' show StMemberFlow;

/// 技师快速开单：选服务提交到前台收银。价格、折扣、次卡抵扣全部由服务端估算，提交的只是项目和数量。
class StOrderTemplate extends StatefulWidget {{
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> services;
  const StOrderTemplate({{super.key, required this.info, required this.services}});

  @override
  State<StOrderTemplate> createState() => _StOrderTemplateState();
}}

class _StOrderTemplateState extends State<StOrderTemplate> {{
  final Set<String> selected = {{}};
  String note = '';
  Map<String, dynamic>? quote;
  int _seq = 0;

  List<Map<String, dynamic>> get services => widget.services;
  String get memberId => '${{widget.info['id']}}';
  String get _plate => '${{widget.info['plate'] ?? ''}}'.isEmpty ? '未登记车牌' : '${{widget.info['plate']}}';
  String get _level => '${{widget.info['level'] ?? ''}}'.isEmpty ? '会员' : '${{widget.info['level']}}';
  String get _who => '${{widget.info['name'] ?? ''}} · $_level';
  String get _selText => '已选 ${{selected.length}} 项 · 会员价';
  String get _totalText => stMoney(quote?['payable'] ?? 0);

  List<Map<String, dynamic>> get _lines => [for (final id in selected) {{'service_id': id, 'qty': 1}}];

  String _discountText() {{
    final d = ((widget.info['discount'] as num?) ?? 1).toDouble();
    if (d >= 1) return '原价';
    final z = (d * 10).toStringAsFixed(1).replaceAll(RegExp(r'\\.0$'), '');
    return '$_level价 $z 折';
  }}

  Future<void> _toggle(String id) async {{
    setState(() => selected.contains(id) ? selected.remove(id) : selected.add(id));
    final seq = ++_seq;
    if (selected.isEmpty) {{
      setState(() => quote = null);
      return;
    }}
    try {{
      final q = await merchantApi.staffWork('staff_order_quote', {{'member_id': memberId, 'lines': _lines}});
      if (mounted && seq == _seq) setState(() => quote = q);
    }} catch (e) {{
      if (mounted && seq == _seq) {{
        setState(() => quote = null);
        AppToast.error(context, e);
      }}
    }}
  }}

  Future<void> _submit() => runBusy('StOrder>submit', () async {{
    if (selected.isEmpty) {{
      hToast(context, '请先选择服务项目');
      return;
    }}
    try {{
      await merchantApi.staffWork('staff_order_submit', {{
        'member_id': memberId,
        'lines': _lines,
        'plate': '${{widget.info['plate'] ?? ''}}',
        'note': note,
      }});
      if (!mounted) return;
      AppToast.show(context, '已提交到收银，前台收银后会通知你', kind: ToastKind.success);
      openRoute(context, 'StHome');
    }} catch (e) {{
      if (mounted) AppToast.error(context, e);
    }}
  }});

{icon_method}
  Widget _row(BuildContext context, int i, Map<String, dynamic> svc) {{
    final id = '${{svc['id']}}';
    final selected = this.selected.contains(id);
    final name = '${{svc['name'] ?? ''}}';
    final sub = _discountText();
    final price = stMoney(num.tryParse('${{svc['price']}}') ?? 0);
    return hTap(context, {row_expr}, onTap: () => _toggle(id));
  }}

  @override
  Widget build(BuildContext context) {{
{head[head.index('    return HPage('):]}{flow}{overlays},
    );
  }}
}}

/// 快速开单：会员取自「会员查询 / 会员简况」选中的那位。
class StOrderLivePage extends StatelessWidget {{
  const StOrderLivePage({{super.key}});

  @override
  Widget build(BuildContext context) => StLive(
    title: '快速开单',
    load: () async {{
      final id = StMemberFlow.currentId;
      if (id == null) throw const AppError('请先选择会员', type: AppErrorType.notFound);
      final info = await merchantApi.staffWork('staff_member_info', {{'id': id}});
      await ServiceStore.load();
      return {{'info': info, 'services': ServiceStore.sellable}};
    }},
    builder: (_, d) => StOrderTemplate(
      info: Map<String, dynamic>.from(d['info'] as Map),
      services: [for (final x in (d['services'] as List)) Map<String, dynamic>.from(x as Map)],
    ),
  );
}}
'''
    (ROOT / 'st_order_template.dart').write_text(body, encoding='utf-8')


def build_queue():
    s = (ROOT / 'gen_st/st_cash_queue_page.dart').read_text(encoding='utf-8')
    flow_i = s.index('flow: hcol(')
    ov_i = s.index('overlays: [')
    head = s[:flow_i]
    flow = s[flow_i:ov_i]
    ov_end = match(s, s.index('[', ov_i))
    overlays = s[ov_i:ov_end + 1]
    # 两张示意卡片
    key = "hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24)"
    c1 = flow.index(key, flow.index("沪A·8K29M") - 4000 if flow.index("沪A·8K29M") > 4000 else 0)
    # 卡片起点：沪A·8K29M 之前最近的卡片 hbox
    c1 = flow.rfind(key, 0, flow.index("沪A·8K29M"))
    c1e = match(flow, flow.index('(', c1))
    c2 = flow.rfind(key, 0, flow.index("沪AF·09316"))
    c2e = match(flow, flow.index('(', c2))
    card = flow[c1:c1e + 1]
    # 卡片内的明细行
    li = card.index("hcol([hrow([Expanded(flex: 1, child: Text('全车镀晶")
    lb = card.index('[', li)
    rb = match(card, lb)
    lrows = split_top(card[lb + 1:rb])
    assert len(lrows) == 3
    line_row = must(lrows[0], "Text('全车镀晶 · 9H 陶瓷',", "Text(l['label'],")
    line_row = must(line_row, "Text('¥1,580',", "Text(l['amount'],")
    disc_row = must(lrows[2], "Text('黑金会员价 9 折',", "Text(_discLabel(h),")
    disc_row = must(disc_row, "Text('-¥196',", "Text(_discAmount(h),")
    new_lines = ("[for (final l in _lines(h)) " + line_row + ", if (_discount(h) > 0) " + disc_row + "]")
    card = card[:lb] + new_lines + card[rb + 1:]
    card = must(card, "Text('沪A·8K29M',", "Text(_plate(h),")
    card = must(card, "Text('宝马 5 系 · 黑色',", "Text(_sub(h),")
    card = must(card, "Text('10:42 提交',", "Text(_time(h),")
    card = must(card, "Text('王建国 · 黑金会员',", "Text(_who(h),")
    card = must(card, "Text('提交人 老周（技师）',", "Text(_submitter(h),")
    card = must(card, "Text('¥1,764',", "Text(_payable(h),")
    card = must(card, "Text('退回修改', style: hts(14, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500))",
                "hBusy('StCashQueue>return', Text('退回修改', style: hts(14, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500)))")
    card = must(card, "to: 'StCashQueue'", "onTap: () => _return(h)")
    card = must(card, "to: 'Order'", "onTap: () => _collect(h)")
    empty = ("hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), pad: EdgeInsets.fromLTRB(16, 20, 16, 20), "
             "child: Text('暂无待收银的订单', style: hts(14, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 20), textAlign: TextAlign.center))")
    flow = flow[:c1] + "if (items.isEmpty) " + empty + ", for (final h in items) _card(context, h)" + flow[c2e + 1:]

    body = f'''{HEADER}import 'package:flutter/material.dart';

import '../backend/hold_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'staff_live.dart';
import 'st_live.dart';

/// 待收银队列变化（退回 / 收银后）时刷新列表与前台工作台。
class StQueueFlow {{
  static final changed = ValueNotifier<int>(0);
}}

/// 前台待收银：技师提交的单。「去收银」把这张单放回开单页走既有的取单结算（价格、折扣、次卡抵扣由数据库结算时重新计算）。
class StCashQueueTemplate extends StatefulWidget {{
  final List<Map<String, dynamic>> items;
  const StCashQueueTemplate({{super.key, required this.items}});

  @override
  State<StCashQueueTemplate> createState() => _StCashQueueTemplateState();
}}

class _StCashQueueTemplateState extends State<StCashQueueTemplate> {{
  List<Map<String, dynamic>> get items => widget.items;

  Map<String, dynamic> _quote(Map<String, dynamic> h) => Map<String, dynamic>.from((h['quote'] as Map?) ?? const {{}});
  num _discount(Map<String, dynamic> h) => (_quote(h)['discount_off'] as num?) ?? 0;
  String _plate(Map<String, dynamic> h) => '${{h['vehicle_plate'] ?? ''}}'.isEmpty ? '未登记车牌' : '${{h['vehicle_plate']}}';
  String _level(Map<String, dynamic> h) {{
    final l = '${{((h['member'] as Map?)?['card'] as Map?)?['name'] ?? ''}}';
    return l.isEmpty ? '会员' : l;
  }}
  String _sub(Map<String, dynamic> h) => '${{(h['member'] as Map?)?['phone'] ?? ''}}';
  String _time(Map<String, dynamic> h) => '${{stClock(h['created_at'])}} 提交';
  String _who(Map<String, dynamic> h) => '${{(h['member'] as Map?)?['name'] ?? ''}} · ${{_level(h)}}';
  String _submitter(Map<String, dynamic> h) {{
    final s = h['submitter'] as Map?;
    if (s == null) return '提交人 —';
    final role = switch ('${{s['role']}}') {{ 'technician' => '技师', 'cashier' => '前台', 'manager' => '店长', _ => '' }};
    return '提交人 ${{s['name']}}${{role.isEmpty ? '' : '（$role）'}}';
  }}
  String _payable(Map<String, dynamic> h) => stMoney(_quote(h)['payable'] ?? 0);
  String _discLabel(Map<String, dynamic> h) => '${{_level(h)}}价';
  String _discAmount(Map<String, dynamic> h) => '-${{stMoney(_discount(h))}}';

  List<Map<String, dynamic>> _lines(Map<String, dynamic> h) => [
    for (final l in (h['lines'] as List? ?? const []))
      {{
        'label': '${{(l as Map)['name']}}${{((l['qty'] as num?) ?? 1) > 1 ? ' × ${{l['qty']}}' : ''}}',
        'amount': stMoney(((l['unit_price'] as num?) ?? 0) * ((l['qty'] as num?) ?? 1)),
      }},
  ];

  Future<void> _return(Map<String, dynamic> h) => runBusy('StCashQueue>return', () async {{
    try {{
      await merchantApi.staffWork('staff_order_return', {{'id': h['id'], 'reason': '请核对后重新提交'}});
      StQueueFlow.changed.value++;
      if (mounted) AppToast.show(context, '已退回，已通知提交人', kind: ToastKind.success);
    }} catch (e) {{
      if (mounted) AppToast.error(context, e);
    }}
  }});

  void _collect(Map<String, dynamic> h) {{
    HoldFlow.takeOut(h);
    openRoute(context, 'Order');
  }}

  Widget _card(BuildContext context, Map<String, dynamic> h) => {card};

  @override
  Widget build(BuildContext context) {{
{head[head.index('    return HPage('):]}{flow}{overlays},
    );
  }}
}}

/// 待收银：门店里技师提交、还没收银的单。
class StCashQueueLivePage extends StatelessWidget {{
  const StCashQueueLivePage({{super.key}});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    needsId: false,
    title: '待收银',
    refresh: Listenable.merge([StQueueFlow.changed, HoldFlow.tick]),
    load: (_) => merchantApi.staffWork('staff_cash_queue'),
    builder: (_, d) => StCashQueueTemplate(
      items: [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)],
    ),
  );
}}
'''
    (ROOT / 'st_cash_queue_template.dart').write_text(body, encoding='utf-8')


def patch_front_home():
    gen = (ROOT / 'gen_st/st_front_home_page.dart').read_text(encoding='utf-8')
    path = ROOT / 'st_front_home_template.dart'
    t = path.read_text(encoding='utf-8')
    if '_queueBlock' in t:
        return
    # 设计稿里的“待收银 · 技师提交”整块（在 即将到店 之前）
    k = gen.index("Text('待收银 · 技师提交'")
    start = gen.rfind("hcol([hbox(pad: EdgeInsets.fromLTRB(4, 0, 4, 0)", 0, k)
    end = match(gen, gen.index('(', start))
    block = gen[start:end + 1]
    lb = block.index('[')
    rb = match(block, lb)
    els = split_top(block[lb + 1:rb])
    header, rows = els[0], els[1:]
    assert len(rows) == 2
    header = must(header, "Text('全部 2',", "Text('全部 ${queue.length}',")
    row = rows[0]
    row = must(row, "Text('沪A·8K29M',", "Text(plateOf(q),")
    row = must(row, "Text('老周 · 10:42 提交',", "Text(qWho(q),")
    row = must(row, "Text('全车镀晶 + 内饰深度清洁',", "Text(itemsOfQ(q),")
    row = must(row, "Text('¥1,764',", "Text(qPayable(q),")
    row = must(row, "Text('王建国 · 黑金会员 · 会员价',", "Text(qMember(q),")
    new_block = ("hcol([" + header + ", for (final q in queue.take(2)) " + row +
                 block[rb:])
    # 模板里的“即将到店”之前插入
    anchor = "if (upcoming.isNotEmpty) hcol([hbox(pad: EdgeInsets.fromLTRB(4, 0, 0, 0), child: Text('即将到店'"
    assert t.count(anchor) == 1
    t = t.replace(anchor, "if (queue.isNotEmpty) " + new_block + ", " + anchor)
    helpers = '''    final queue = [for (final q in (d['queue'] as List? ?? const [])) Map<String, dynamic>.from(q as Map)];
    String itemsOfQ(Map<String, dynamic> q) => ((q['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').join(' + ');
    String qWho(Map<String, dynamic> q) => '${(q['submitter'] as Map?)?['name'] ?? '—'} · ${stClock(q['created_at'])} 提交';
    String qPayable(Map<String, dynamic> q) => stMoney(((q['quote'] as Map?)?['payable']) ?? 0);
    String qMember(Map<String, dynamic> q) => '${(q['member'] as Map?)?['name'] ?? ''} · ${((q['member'] as Map?)?['card'] as Map?)?['name'] ?? '会员'} · 会员价';
    // _queueBlock：待收银 · 技师提交（有队列时显示）
'''
    t = t.replace("    return HPage(", helpers + "    return HPage(", 1)
    # 待收银数量用队列真实长度
    t = t.replace("Text('${d['cash_queue'] ?? 0}'", "Text('${queue.length}'")
    # 实时页：合并队列
    old = """  Widget build(BuildContext context) => StLive(
    title: '工作台',
    load: merchantApi.staffHome,
    builder: (_, d) => StFrontHomeTemplate(d: d),
  );"""
    new = """  Widget build(BuildContext context) => StLive(
    title: '工作台',
    refresh: Listenable.merge([StQueueFlow.changed, HoldFlow.tick]),
    load: () async {
      final home = await merchantApi.staffHome();
      // 待收银队列需要「待收银」权限；没有权限时服务端拒绝，工作台照常显示。
      try {
        final q = await merchantApi.staffWork('staff_cash_queue');
        return {...home, 'queue': q['items'] ?? const []};
      } catch (_) {
        return home;
      }
    },
    builder: (_, d) => StFrontHomeTemplate(d: d),
  );"""
    assert old in t
    t = t.replace(old, new)
    t = t.replace("import 'st_live.dart';", "import '../backend/hold_flow.dart';\nimport 'st_cash_queue_template.dart' show StQueueFlow;\nimport 'st_live.dart';", 1)
    path.write_text(t, encoding='utf-8')


if __name__ == '__main__':
    build_order()
    build_queue()
    patch_front_home()
