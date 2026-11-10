#!/usr/bin/env python3
"""把员工端设计稿生成页（lib/pages/gen_st/）派生为接真实后端的模板（lib/pages/st_*_template.dart）。

只替换数据来源和事件处理，视觉与结构保持生成页原样；不手工修改 gen_st/。
生成页由 tools/design_to_flutter.py 从最新设计稿的 St* 画板生成：
  python3 tools/design_to_flutter.py <只含 St* 画板的目录> lib/pages/gen_st
用法（在 apps/merchant 目录）：python3 tools/bind_st.py [页面 ...]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from derive import Doc, match_close  # noqa: E402

GEN = 'lib/pages/gen_st/'
OUT = 'lib/pages/'
HEADER = '// 从员工端设计稿生成页派生（tools/bind_st.py），仅绑定数据和事件；不手工修改 gen_st/。\n'
IMPORTS = """import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/staff_flow.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../mock/theme_state.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';
"""
OLD_IMPORTS = "import 'package:flutter/material.dart';\nimport '../../kit/kit.dart';\nimport 'svgs.dart';\n"


def load(name):
    d = Doc(open(GEN + name).read())
    d.rep(OLD_IMPORTS, IMPORTS)
    return d


def save(name, d):
    body = d.s
    for imp, tokens in (
        ("import '../backend/merchant_api.dart';\n", ('merchantApi',)),
        ("import '../backend/staff_flow.dart';\n", ('StaffFlow',)),
        ("import '../backend/access_flow.dart';\n", ('Access', 'AccessFlow')),
        ("import '../kit/async_kit.dart';\n", ('runBusy', 'AppToast', 'ErrorView', 'AsyncView', 'AppError', 'hBusy')),
        ("import '../routes.dart' show openRoute;\n", ('openRoute',)),
        ("import '../mock/theme_state.dart';\n", ('appThemeMode', 'themeModeLabel')),
        ("import 'st_live.dart';\n", ('stInitial', 'stGreeting', 'StLive', 'stMoney', 'stDayLabel', 'stPlateGreen', 'stClock')),
    ):
        if not any(t in body.replace(imp, '') for t in tokens):
            body = body.replace(imp, '')
    open(OUT + name, 'w').write(HEADER + body)


def busy(d, anchor, key, label=True):
    """把按钮文字包进 hBusy（loading 只显示转圈 + 提交中…，尺寸不变）。"""
    a, b = d.span(anchor, 'Text')
    txt = d.s[a:b]
    i = txt.index('style:')
    j = txt.index('(', i)
    k = match_close(txt, j)
    style = txt[i + 6:k + 1].strip()
    tail = ", label: '提交中…'" if label else ''
    d.cut(a, b, f"hBusy('{key}', {txt}, style: {style}{tail})")


def run_action(key, body):
    return (f"() => runBusy('{key}', () async {{ try {{ {body} }} catch (e) "
            "{ if (context.mounted) AccessFlow.toastError(context, e); } })")


def drop_dock(d):
    """底部导航由员工外壳（lib/pages/staff_tabs.dart 的 StaffNavBar）统一提供，页面里不再各画一份。"""
    a = d.s.index('overlays: [')
    b = match_close(d.s, d.s.index('[', a)) + 1
    d.cut(a, b, 'overlays: []')


def stateless(d, old, new, fields, ctor, locals_=''):
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatelessWidget {{\n{fields}\n  const {new}({{super.key, {ctor}}});\n\n"
        f"  @override\n  Widget build(BuildContext context) {{\n{locals_}    return ",
    )


# ───────────── 登录失败（手机号未登记）─────────────
def auth_fail():
    d = load('st_auth_fail_page.dart')
    stateless(d, 'StAuthFailPage', 'StAuthFailTemplate', '  final String phone;', 'required this.phone')
    d.rep("'登录手机号：139 **** 1111',", "'登录手机号：${StaffFlow.maskedPhone(phone)}',")
    # 「换个手机号」：先退出当前会话再回登录页
    d.rep("to: 'Login'", "onTap: () => AccessFlow.signOut(context)")
    save('st_auth_fail_template.dart', d)


# ───────────── 暂无权限 ─────────────
def no_perm():
    d = load('st_no_perm_page.dart')
    stateless(d, 'StNoPermPage', 'StNoPermTemplate', '  final String need;', 'this.need = \'该功能\'',
              "    final who = Access.role == 'owner' ? '平台' : (Access.role == 'manager' ? '老板' : '店长');\n")
    d.rep("'该页面需要「查看门店营业统计」权限。请联系店长开通后再试。',", "'该页面需要「$need」权限。请联系$who开通后再试。',")
    save('st_no_perm_template.dart', d)


# ───────────── 套餐到期（员工只读版）─────────────
def plan_expired():
    d = load('st_plan_expired_page.dart')
    stateless(d, 'StPlanExpiredPage', 'StPlanExpiredTemplate', '', '',
              "    final ends = '${Access.context['plan_ends_at'] ?? ''}';\n"
              "    final day = ends.length >= 10 ? ends.substring(0, 10).replaceAll('-', '.') : '—';\n")
    d.rep("'驰光汽车美容 · 徐汇店的套餐已于 2026.11.09 到期，开单、预约和任务更新暂时不可用。续费需要由老板在 App 内完成，请联系老板。',",
          "'${Access.storeName}的套餐已于 $day 到期，开单、预约和任务更新暂时不可用。续费需要由老板在 App 内完成，请联系老板。',")
    d.rep("to: 'StPlanExpired'", "onTap: () => AppToast.show(context, '请联系老板在 App 内续费')")
    busy(d, "'刷新状态'", 'StPlanExpired>refresh')
    d.rep("to: 'StHome'", "onTap: " + run_action('StPlanExpired>refresh', "await AccessFlow.refresh(context);"))
    d.rep("to: 'Login'", "onTap: () => AccessFlow.signOut(context)")
    d.s += """
/// 门店套餐到期（员工只读）：续费只能由老板完成。
class StPlanExpiredLivePage extends StatelessWidget {
  const StPlanExpiredLivePage({super.key});

  @override
  Widget build(BuildContext context) => const PopScope(canPop: false, child: StPlanExpiredTemplate());
}
"""
    save('st_plan_expired_template.dart', d)


# ───────────── 加入门店（首次登录确认）─────────────
PERM_ITEMS = {
    'technician': [('order_view_own', '查看派给我的任务'), ('progress_update', '更新施工进度'), ('stock_use', '领用耗材'),
                   ('perf_view_own', '查看个人业绩'), ('stats_view_store', '查看门店营业额'), ('member_recharge_refund', '会员充值与退款')],
    'cashier': [('cashier', '开单收银'), ('cash_queue', '处理待收银'), ('member_recharge_refund', '会员充值'),
                ('appt_edit', '新建与改期预约'), ('order_refund', '订单退款'), ('stats_view_store', '查看门店营业统计')],
    'manager': [('order_view_all', '查看全店任务'), ('cashier', '开单收银'), ('member_recharge_refund', '会员充值'),
                ('stock_manage', '入库与盘点'), ('order_refund', '订单退款'), ('stats_view_store', '查看门店营业统计')],
}


def auth():
    d = load('st_auth_page.dart')
    stateless(d, 'StAuthPage', 'StAuthTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final role = '${d['role']}';\n    final store = '${d['store_name']}';\n"
              "    final items = stPermItems[role] ?? stPermItems['technician']!;\n"
              "    final caps = ((d['caps'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', v == true));\n")
    d.rep("'欢迎加入驰光汽车美容',", "'欢迎加入$store',")
    d.rep("'徐汇店已为你开通员工账号',", "'已为你开通${Access.roleName(role)}账号',")
    d.rep("'驰光汽车美容 · 徐汇店',", "store,")
    d.rep("'138 **** 7712',", "StaffFlow.maskedPhone(d['phone']),")
    # 身份标签：按身份换配色（技师绿 / 前台黄 / 店长蓝）
    a, b = d.span("'施工技师',", 'hbox', 1)
    chip = d.s[a:b].replace("'施工技师',", "Access.roleName(role),")
    d.cut(a, b, chip)
    # 权限格：按身份和生效权限生成
    i1a, i1b = d.span("'查看派给我的任务',", 'hrow', 1)
    row_on = d.s[i1a:i1b]
    j1a, j1b = d.span("'查看门店营业额',", 'hrow', 1)
    row_off = d.s[j1a:j1b]
    grid_a, grid_b = d.span("'查看派给我的任务',", 'hcol', 1)
    on_cell = row_on.replace("'查看派给我的任务',", 'label,').replace("Flexible(\n      flex: 104,", "Flexible(\n      flex: 1,")
    import re
    on_cell = re.sub(r"flex: \d+,\s*child: Text\(\s*label", "flex: 1, child: Text(label", on_cell)
    off_cell = re.sub(r"flex: \d+,\s*child: Text\(\s*'查看门店营业额'", "flex: 1, child: Text(label", row_off)
    off_cell = off_cell.replace("'查看门店营业额',", 'label,')
    helper = ("\n  Widget permCell(String key, String label) {\n    final on = caps[key] == true;\n    return Expanded(flex: 1, child: on ? "
              + on_cell + " : " + off_cell + ");\n  }\n")
    # gen 里每一格本身就是 Expanded 的子 hrow；这里直接替换整个 hcol 为动态行
    d.cut(grid_a, grid_b, "hcol([for (var i = 0; i < items.length; i += 2) hrow([permCell(items[i].$1, items[i].$2), permCell(items[i + 1].$1, items[i + 1].$2)], cross: CrossAxisAlignment.stretch, gap: 0, intrinsic: true, min: false)], gap: 10)")
    d.rep("    return HPage(", helper + "    return HPage(")
    busy(d, "'确认加入并进入工作台'", 'StAuth>join')
    d.rep("to: 'StHome'", "onTap: " + run_action('StAuth>join', "await AccessFlow.join(context);"))
    d.rep("to: 'Login'", "onTap: () => AccessFlow.signOut(context)")
    d.s += """
/// 加入门店：员工首次用该身份登录时确认一次（每个「门店 + 身份」只出现一次）。
class StAuthLivePage extends StatelessWidget {
  const StAuthLivePage({super.key});

  @override
  Widget build(BuildContext context) => StAuthTemplate(d: Access.context);
}

/// 加入页展示的权限（与「员工与权限」里该身份的开关一致，数据来自服务端生效权限）。
const stPermItems = <String, List<(String, String)>>{
"""
    for role, items in PERM_ITEMS.items():
        d.s += f"  '{role}': [\n"
        for k, v in items:
            d.s += f"    ('{k}', '{v}'),\n"
        d.s += "  ],\n"
    d.s += "};\n"
    save('st_auth_template.dart', d)


# ───────────── 选择身份 ─────────────
def identity():
    d = load('st_identity_page.dart')
    stateless(d, 'StIdentityPage', 'StIdentityTemplate', '  final List<Map<String, dynamic>> items;', 'required this.items',
              "    final phone = StaffFlow.maskedPhone(AccessFlow.phone.isEmpty ? '${Access.context['phone'] ?? ''}' : AccessFlow.phone);\n")
    d.rep("'138 **** 7712 在以下门店有身份，请选择本次进入的身份。',", "'$phone 在以下门店有身份，请选择本次进入的身份。',")
    # 三行：老板（当前样式带描边）、前台（蓝）、技师（绿）。取三张卡作为角色模板。
    r1a, r1b = d.span("'驰光汽车美容 · 徐汇店',", 'hTap', 1)
    r2a, r2b = d.span("'星航汽车养护 · 闵行店',", 'hTap', 1)
    r3a, r3b = d.span("'悦驰汽车装饰 · 松江店',", 'hTap', 1)
    owner, cash, tech = d.s[r1a:r1b], d.s[r2a:r2b], d.s[r3a:r3b]

    def fill(card, ini, store, role, hint, to):
        card = card.replace(ini, "stInitial(store),").replace(store, "store,").replace(role, "Access.roleName('${it['role']}'),")
        card = card.replace(hint, "hint,")
        return card.replace(f"to: '{to}'", "onTap: () => pick(it)")
    owner = fill(owner, "'驰',", "'驰光汽车美容 · 徐汇店',", "'老板',", "'名下 2 家门店 · 上次使用',", 'Main')
    cash = fill(cash, "'星',", "'星航汽车养护 · 闵行店',", "'前台收银',", "'今日待收银 2',", 'StFrontHome')
    tech = fill(tech, "'悦',", "'悦驰汽车装饰 · 松江店',", "'施工技师',", "'待施工 2',", 'StHome')
    fn = ("    String hintOf(Map<String, dynamic> it) {\n"
          "      if (it['kind'] == 'owner') {\n        return '名下 ${it['stores'] ?? 1} 家门店${it['current'] == true ? ' · 上次使用' : ''}';\n      }\n"
          "      if (it['status'] == 'pending') {\n        return '待确认加入';\n      }\n"
          "      return '${it['hint'] ?? ''}';\n    }\n\n"
          "    Widget card(Map<String, dynamic> it) {\n"
          "      final store = '${it['store_name']}';\n      final hint = hintOf(it);\n"
          "      return switch ('${it['role']}') {\n        'owner' => " + owner + ",\n        'technician' => " + tech + ",\n        _ => " + cash + ",\n      };\n    }\n\n")
    d.cut(r1a, r3b, "for (final it in items) card(it)")
    d.rep("    return HPage(", fn + "    return HPage(")
    d.rep("to: 'Login'", "onTap: () => AccessFlow.signOut(context)")
    d.s += """
/// 选择身份：同一手机号在多家门店有不同身份时，每次进入前选择一个。
class StIdentityLivePage extends StatefulWidget {
  const StIdentityLivePage({super.key});

  @override
  State<StIdentityLivePage> createState() => _StIdentityLivePageState();
}

class _StIdentityLivePageState extends State<StIdentityLivePage> {
  bool busy = false;

  Future<void> pick(Map<String, dynamic> it) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await AccessFlow.enter(context, it);
    } catch (e) {
      if (mounted) AccessFlow.toastError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: busy,
    child: StIdentityTemplate(items: AccessFlow.items, pick: pick),
  );
}
"""
    d.rep("  final List<Map<String, dynamic>> items;\n", "  final List<Map<String, dynamic>> items;\n  final Future<void> Function(Map<String, dynamic>) pick;\n")
    d.rep("required this.items", "required this.items, required this.pick")
    save('st_identity_template.dart', d)


def remove_element(d, a, b):
    """从列表字面量里去掉一个元素（连同后面的逗号）。"""
    j = b
    while d.s[j] in ' \n\t':
        j += 1
    if d.s[j] == ',':
        j += 1
    d.cut(a, j)


def plate_variants(d, blue_anchor, green_anchor, var):
    """车牌牌照有蓝 / 绿两种样式：取设计稿里各一张，合成按车牌位数选择。"""
    ba, bb = d.span(blue_anchor, 'hbox', 1)
    ga, gb = d.span(green_anchor, 'hbox', 1)
    return d.s[ba:bb], d.s[ga:gb]


# ───────────── 技师工作台 ─────────────
def home():
    d = load('st_home_page.dart')
    drop_dock(d)
    stateless(d, 'StHomePage', 'StHomeTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final name = '${d['name']}';\n"
              "    final tasks = [for (final t in (d['tasks'] as List? ?? const [])) Map<String, dynamic>.from(t as Map)];\n"
              "    final working = [for (final t in tasks) if (t['status'] == 'arrived') t];\n"
              "    final waiting = [for (final t in tasks) if (t['status'] != 'arrived') t];\n"
              "    String itemsOf(Map<String, dynamic> t) => ((t['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').join(' + ');\n"
              "    String plateOf(Map<String, dynamic> t) => '${t['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${t['plate']}';\n")
    d.rep("'周',", "stInitial(name),")
    d.rep("'早上好，老周',", "'${stGreeting()}，$name',")
    d.rep("'技师 · 驰光汽车美容 · 徐汇店',", "'${Access.roleBrief()} · ${Access.storeName}',")
    d.rep("'¥3,860',", "stMoney(d['revenue_today']),")
    # 业绩卡里的完成单 / 预计提成 / 待施工
    a2, b2 = d.span("'今日业绩',", 'hbox', 1)
    card = d.s[a2:b2]
    card = card.replace("'4',", "'${d['done_today'] ?? 0}',", 1).replace("'¥386',", "stMoney(d['commission_today']),", 1).replace("'2',", "'${d['waiting'] ?? 0}',", 1)
    d.cut(a2, b2, card)
    # 进行中：设计稿的卡带进度条；进度没有数据来源（预期接口：任务进度，P2），不造百分比
    wa, wb = d.span("'进行中',", 'hcol', 1)
    sec = d.s[wa:wb]
    ca, cb = d.span("'沪A·8K29M',", 'hTap', 1)
    # 在 sec 内定位卡：用偏移
    off = ca - wa
    card = d.s[ca:cb]
    card = card.replace("'沪A·8K29M',", 'plateOf(t),').replace("'全车镀晶 · 9H 陶瓷',", 'itemsOf(t),').replace("'65%',", "'进行中',").replace('hfrac(0.65,', 'hfrac(0.0,')
    card = card.replace("'3 号工位 · 预计 17:00',", "'${t['bay_name'] ?? '未指定工位'} · 预计 ${stClock(stEnd(t))}',")
    card = card.replace("to: 'StTaskDetail'", "onTap: () => stOpenTask(context, '${t['id']}')")
    sec = sec[:off] + "for (final t in working) " + card + sec[off + (cb - ca):]
    d.cut(wa, wb, "if (working.isNotEmpty) " + sec)
    # 待施工：绿牌 / 蓝牌两种样式
    qa, qb = d.span("'待施工',", 'hcol', 1, 2)
    sec = d.s[qa:qb]
    c1a, c1b = d.span("'沪AF·09316',", 'hTap', 1)
    c2a, c2b = d.span("'沪B·5X770',", 'hTap', 1)
    green, blue = d.s[c1a:c1b], d.s[c2a:c2b]
    pa, pb = d.span("'沪AF·09316',", 'hbox', 1)
    chip_green = d.s[pa:pb]
    ga2, gb2 = d.span("'沪B·5X770',", 'hbox', 1)
    chip_blue = d.s[ga2:gb2]
    base = blue.replace(chip_blue, "(stPlateGreen(t['plate']) ? " + chip_green.replace("'沪AF·09316',", 'plateOf(t),') + " : " + chip_blue.replace("'沪B·5X770',", 'plateOf(t),') + ")")
    base = base.replace("'内饰深度清洁',", 'itemsOf(t),').replace("'预计 14:00 到店',", "'预计 ${stClock(t['starts_at'])} 到店',")
    base = base.replace("'今天 14:00 · 客户 赵磊',", "'${stDayLabel(t['starts_at'])} · 客户 ${t['customer']}',")
    base = base.replace("to: 'StTaskDetail'", "onTap: () => stOpenTask(context, '${t['id']}')")
    off1, off2 = c1a - qa, c2b - qa
    sec = sec[:off1] + "for (final t in waiting) " + base + sec[off2:]
    d.cut(qa, qb, "if (waiting.isNotEmpty) " + sec)
    d.rep("to: 'StMsgs'", "onTap: () => openRoute(context, 'StMsgs')")
    d.s += """
/// 技师工作台：今日任务、业绩与预计提成都来自服务端（只统计自己的预约订单）。
class StHomeLivePage extends StatelessWidget {
  const StHomeLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '工作台',
    load: merchantApi.staffHome,
    builder: (_, d) => StHomeTemplate(d: d),
  );
}
"""
    save('st_home_template.dart', d)


# ───────────── 前台工作台 ─────────────
def front_home():
    d = load('st_front_home_page.dart')
    drop_dock(d)
    stateless(d, 'StFrontHomePage', 'StFrontHomeTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final name = '${d['name']}';\n"
              "    final upcoming = [for (final t in (d['upcoming'] as List? ?? const [])) Map<String, dynamic>.from(t as Map)];\n"
              "    String itemsOf(Map<String, dynamic> t) => ((t['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').join(' + ');\n"
              "    String plateOf(Map<String, dynamic> t) => '${t['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${t['plate']}';\n")
    d.rep("'刘',", "stInitial(name),")
    d.rep("'下午好，小刘',", "'${stGreeting()}，$name',")
    d.rep("'前台收银 · 驰光汽车美容 · 徐汇店',", "'${Access.roleBrief()} · ${Access.storeName}',")
    a, b = d.span("'今日收款笔数',", 'hbox', 1)
    card = d.s[a:b]
    card = card.replace("'36 笔',", "'${d['orders_today'] ?? 0} 笔',")
    card = card.replace("'2',", "'${d['cash_queue'] ?? 0}',", 1).replace("'3',", "'${d['waiting'] ?? 0}',", 1).replace("'2',", "'${d['working'] ?? 0}',", 1)
    d.cut(a, b, card)
    # 待收银 · 技师提交：待收银队列由 P2 的开单提交接入前先不显示
    qa, qb = d.span("'待收银 · 技师提交',", 'hcol', 1)
    remove_element(d, qa, qb)
    # 即将到店
    ua, ub = d.span("'即将到店',", 'hcol', 1)
    sec = d.s[ua:ub]
    r1a, r1b = d.span("'13:00',", 'hbox', 2)
    r2a, r2b = d.span("'14:00',", 'hbox', 2)
    sep = d.s[r1b:r2a].strip().strip(',').strip()
    row = d.s[r1a:r1b].replace("'13:00',", "stClock(t['starts_at']),").replace("'沪AF·09316 · 精致洗车',", "'${plateOf(t)} · ${itemsOf(t)}',").replace("'李梅 · 金卡',", "'${t['customer']}',")
    lead = "if (i > 0) " + sep + ", " if sep else ""
    sec = sec[:r1a - ua] + "for (var i = 0; i < upcoming.length; i++) ...[" + lead + "(() { final t = upcoming[i]; return " + row + "; })()]" + sec[r2b - ua:]
    d.cut(ua, ub, "if (upcoming.isNotEmpty) " + sec)
    d.rep("to: 'StMsgs'", "onTap: () => openRoute(context, 'StMsgs')")
    d.s += """
/// 前台工作台：今日收款笔数（只给笔数，不给金额）、待到店、施工中与即将到店。
class StFrontHomeLivePage extends StatelessWidget {
  const StFrontHomeLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '工作台',
    load: merchantApi.staffHome,
    builder: (_, d) => StFrontHomeTemplate(d: d),
  );
}
"""
    save('st_front_home_template.dart', d)


# ───────────── 我的 ─────────────
def mine():
    d = load('st_mine_page.dart')
    drop_dock(d)
    stateless(d, 'StMinePage', 'StMineTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final name = '${d['name']}';\n"
              "    final phone = '${d['phone'] ?? ''}';\n"
              "    final masked = phone.length == 11 ? '${phone.substring(0, 3)}****${phone.substring(7)}' : phone;\n"
              "    final joined = StaffFlow.dotDate(d['joined_on'], monthOnly: true);\n")
    d.rep("'周',", "stInitial(name),")
    d.rep("'老周',", "name,")
    d.rep("'技师',", "Access.roleBrief(),")
    d.rep("'138****7712 · 入职 2022.03',", "'$masked · 入职 $joined',")
    d.rep("'62',", "'${d['month_done'] ?? 0}',")
    # TODO: 好评率没有评价数据来源（预期接口：staff_rating），显示「—」，不造假。
    d.rep("'99%',", "'—',")
    d.rep("'¥4,620',", "stMoney(d['month_commission']),")
    d.rep("'本月 ¥4,620',", "'本月 ${stMoney(d['month_commission'])}',")
    d.rep("'4 位',", "'${(d['waiting'] ?? 0) + (d['working'] ?? 0)} 位',")
    d.rep("'2 条未读',", "'查看全部',")
    d.rep("'跟随系统',", "themeModeLabel(appThemeMode.value),")
    d.rep("'当前：徐汇店 · 施工技师（仅多身份账号显示）',", "'当前：${Access.storeName} · ${Access.roleName()}',")
    d.rep("to: 'StPerf'", "onTap: () => openRoute(context, 'StPerf')")
    d.rep("to: 'StIdentity'", "onTap: () => AccessFlow.switchIdentity(context)")
    # 「切换身份」只对多身份账号显示（设计稿注明）
    ia, ib = d.span("'切换身份',", 'hTap', 1)
    d.cut(ia, ib, "if (((Access.context['identity_count'] as num?) ?? 1) > 1) " + d.s[ia:ib])
    # TODO: 联系店长需要门店联系人电话（预期接口：staff_context 返回店长手机号）
    d.rep("to: 'StMine'", "onTap: () => AppToast.show(context, '请直接联系店长')")
    d.rep("to: 'ChangePassword'", "onTap: () => AppToast.show(context, 'TODO：员工账号使用验证码登录，暂不支持修改密码')")
    d.rep("to: 'Login'", "onTap: () => AccessFlow.signOut(context)")
    d.s += """
/// 我的：本人资料与本月数据；「切换身份」只在多身份账号显示。
class StMineLivePage extends StatelessWidget {
  const StMineLivePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    // 切换身份 / 权限调整后，身份相关的行（切换身份、当前身份）随之更新
    listenable: Access.changed,
    builder: (_, _) => StLive(
      title: '我的',
      load: merchantApi.staffHome,
      builder: (_, d) => StMineTemplate(d: d),
    ),
  );
}
"""
    save('st_mine_template.dart', d)


PAGES = ['auth_fail', 'no_perm', 'plan_expired', 'auth', 'identity', 'home', 'front_home', 'mine']

if __name__ == '__main__':
    for name in sys.argv[1:] or PAGES:
        globals()[name]()
        print('ok', name)
