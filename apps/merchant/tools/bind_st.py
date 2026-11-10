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
import '../backend/task_flow.dart';
import '../kit/async_kit.dart';
import 'staff_live.dart';
import '../kit/kit.dart';
import '../mock/theme_state.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';
"""
OLD_IMPORTS = "import 'package:flutter/material.dart';\nimport '../../kit/kit.dart';\nimport 'svgs.dart';\n"


def load(name):
    d = Doc(open(GEN + name).read())
    if OLD_IMPORTS in d.s:
        d.rep(OLD_IMPORTS, IMPORTS)
    else:
        d.rep("import 'package:flutter/material.dart';\nimport '../../kit/kit.dart';\n", IMPORTS)
    return d


def save(name, d):
    body = d.s
    for imp, tokens in (
        ("import '../backend/merchant_api.dart';\n", ('merchantApi',)),
        ("import '../backend/staff_flow.dart';\n", ('StaffFlow',)),
        ("import '../backend/access_flow.dart';\n", ('Access', 'AccessFlow')),
        ("import '../kit/async_kit.dart';\n", ('runBusy', 'AppToast', 'ErrorView', 'AsyncView', 'AppError', 'hBusy')),
        ("import '../routes.dart' show openRoute;\n", ('openRoute',)),
        ("import 'gen_st/svgs.dart';\n", ('Svgs.',)),
        ("import '../backend/task_flow.dart';\n", ('TaskFlow',)),
        ("import 'staff_live.dart';\n", ('StaffLiveHost',)),
        ("import '../mock/theme_state.dart';\n", ('appThemeMode', 'themeModeLabel')),
        ("import 'st_live.dart';\n", ('stInitial', 'stGreeting', 'StLive', 'stMoney', 'stDayLabel', 'stPlateGreen', 'stClock', 'stOpenTask', 'stItemsOf', 'stPlateOf', 'stPhase', 'stEnd', 'stLoadTask', 'stMsgTime')),
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
    d.rep("[Positioned(top: 11, right: 11,", "[if (((d['unread'] as num?) ?? 0) > 0) Positioned(top: 11, right: 11,")
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
    d.rep("[Positioned(top: 11, right: 11,", "[if (((d['unread'] as num?) ?? 0) > 0) Positioned(top: 11, right: 11,")
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
    d.rep("'2 条未读',", "((d['unread'] as num?) ?? 0) > 0 ? '${d['unread']} 条未读' : '查看全部',")
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



def plate_dyn(chunk, green='plateGreen'):
    """车牌牌照：设计稿里蓝牌样式按车牌位数切换为绿牌样式（新能源 8 位）。"""
    chunk = chunk.replace('colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)]',
                          f'colors: {green} ? [Color(0xFFE9FBEF), Color(0xFFB8F0CB)] : [Color(0xFF2F73F2), Color(0xFF1A4FC4)]')
    chunk = chunk.replace('hts(12, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 18, ls: 0.5)',
                          f'hts(12, {green} ? Color(0xFF14532D) : Color(0xFFFFFFFF), w: FontWeight.w600, lh: 18, ls: 0.5)')
    return chunk


def stateful(d, old, new, fields, state_fields, locals_):
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatefulWidget {{\n{fields}\n  const {new}({{super.key, {', '.join('required this.' + f for f in ['d'])}}});\n\n"
        f"  @override\n  State<{new}> createState() => _{new}State();\n}}\n\n"
        f"class _{new}State extends State<{new}> {{\n{state_fields}\n  @override\n  Widget build(BuildContext context) {{\n{locals_}    return ",
    )


AMBER_BG = 'dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16))'
AMBER_FG = 'dk(context, Color(0xFF855F2E), Color(0xFFF0C46A))'
BLUE_BG = 'dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18))'
BLUE_FG = 'dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA))'
GREEN_BG = 'dk(context, Color(0xFFDDF7E8), Color.fromRGBO(23, 201, 100, 0.16))'
GREEN_FG = 'dk(context, Color(0xFF1B7A43), Color(0xFF5FDB93))'


# ───────────── 我的任务 ─────────────
def tasks():
    d = load('st_tasks_page.dart')
    drop_dock(d)
    stateful(d, 'StTasksPage', 'StTasksTemplate', '  final Map<String, dynamic> d;', '  int? picked;\n',
             "    final all = [for (final t in (widget.d['items'] as List? ?? const [])) Map<String, dynamic>.from(t as Map)];\n"
             "    final waiting = [for (final t in all) if (stPhase(t) == 0) t];\n"
             "    final working = [for (final t in all) if (stPhase(t) == 1) t];\n"
             "    final done = [for (final t in all) if (stPhase(t) == 2) t];\n"
             "    final tab = picked ?? (working.isNotEmpty ? 1 : (waiting.isNotEmpty ? 0 : 2));\n"
             "    final list = tab == 0 ? waiting : (tab == 1 ? working : done);\n")
    d.rep("'待施工 2',", "'待施工 ${waiting.length}',", 2)
    d.rep("'施工中 1',", "'施工中 ${working.length}',", 2)
    d.rep("'已完成 4',", "'已完成 ${done.length}',", 2)
    d.rep("groups: [({1}, false)],", "groups: [({tab}, false)], onSelect: {0: (i) => setState(() => picked = i)},")
    wa, wb = d.span("'沪A·8K29M',", 'hTap', 1)
    working_card = d.s[wa:wb]
    ga, gb = d.span("'沪AF·09316',", 'hTap', 1)
    ba, bb = d.span("'沪B·5X770',", 'hTap', 1)
    wait_card = d.s[ba:bb]
    open_task = "onTap: () => stOpenTask(context, '${t['id']}')"
    working_card = plate_dyn(working_card.replace("'沪A·8K29M',", 'stPlateOf(t),').replace("'全车镀晶 · 9H 陶瓷',", 'stItemsOf(t),')
        .replace("'65%',", "'${t['progress'] ?? 0}%',").replace('hfrac(0.65,', "hfrac(((t['progress'] as num?) ?? 0) / 100,")
        .replace("'3 号工位 · 预计 17:00',", "'${t['bay_name'] ?? '未指定工位'} · 预计 ${stClock(stEnd(t))}',")
        .replace("to: 'StTaskDetail'", open_task), "stPlateGreen(t['plate'])")
    wait_card = plate_dyn(wait_card.replace("'沪B·5X770',", 'stPlateOf(t),').replace("'内饰深度清洁',", 'stItemsOf(t),')
        .replace("'预计 14:00 到店',", "finished ? '完工 ${stClock(t['finished_at'] ?? t['completed_at'])}' : '预计 ${stClock(t['starts_at'])} 到店',")
        .replace("'今天 14:00 · 客户 赵磊',", "'${stDayLabel(t['starts_at'])} · 客户 ${t['customer']}',")
        .replace("to: 'StTaskDetail'", open_task)
        .replace("'待开工',", "finished ? '已完成' : '待开工',")
        .replace(AMBER_BG, f"finished ? {GREEN_BG} : {AMBER_BG}").replace(AMBER_FG, f"finished ? {GREEN_FG} : {AMBER_FG}"),
        "stPlateGreen(t['plate'])")
    fn = ("    Widget workingCard(Map<String, dynamic> t) => " + working_card + ";\n"
          "    Widget waitCard(Map<String, dynamic> t, {bool finished = false}) => " + wait_card + ";\n")
    d.cut(wa, bb, "...(tab == 1 ? [for (final t in working) workingCard(t)] : [for (final t in list) waitCard(t, finished: tab == 2)])")
    d.rep("'已显示全部任务',", "list.isEmpty ? '暂无任务' : '已显示全部任务',")
    d.s = d.s.replace("    return HPage(", fn + "    return HPage(", 1)
    d.s += """
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
"""
    save('st_tasks_template.dart', d)



# ───────────── 任务详情 ─────────────
def task_detail():
    d = load('st_task_detail_page.dart')
    stateless(d, 'StTaskDetailPage', 'StTaskDetailTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final t = d;\n"
              "    final phase = stPhase(t);\n"
              "    final stage = phase == 2 ? 4 : ((t['stage'] as num?) ?? 0).toInt();\n"
              "    final progress = phase == 2 ? 100 : ((t['progress'] as num?) ?? 0).toInt();\n"
              "    final plateGreen = stPlateGreen(t['plate']);\n"
              "    final items = ((t['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').toList();\n"
              "    final itemNode = items.isEmpty ? '项目施工' : (items.length == 1 ? '${items.first} 施工' : '${items.first} 等 ${items.length} 项施工');\n"
              "    final chip = const ['待开工', '施工中', '已完成'][phase];\n"
              "    final end = stClock(stEnd(t));\n"
              "    String nodeSub(int i) {\n"
              "      if (i == 1) return phase == 0 ? '预计 ${stClock(t['starts_at'])} 到店' : '${stClock(t['arrived_at'])} 到店';\n"
              "      if (stage >= i) return '已完成';\n"
              "      if (i == stage + 1 && phase == 1) return '进行中';\n"
              "      return i == 4 ? '预计 $end' : '待开始';\n"
              "    }\n"
              "    // 0 已完成 / 1 当前 / 2 待进行\n"
              "    int nodeState(int i) => stage >= i ? 0 : (i == stage + 1 ? 1 : 2);\n")
    # 头部：状态 / 工位 / 车牌 / 时间窗 / 进度
    d.rep("'3 号工位',", "'${t['bay_name'] ?? '未指定工位'}',")
    d.rep(BLUE_BG, f"[{AMBER_BG}, {BLUE_BG}, {GREEN_BG}][phase]")
    d.rep(BLUE_FG, f"[{AMBER_FG}, {BLUE_FG}, {GREEN_FG}][phase]")
    d.rep("Text('施工中',", "Text(chip,", 1)
    pa, pb = d.span("'沪A·8K29M',", 'hbox', 1)
    d.cut(pa, pb, plate_dyn(d.s[pa:pb].replace("'沪A·8K29M',", 'stPlateOf(t),'), 'plateGreen'))
    # TODO: 车型 / 颜色没有数据来源（预约只登记车牌），改显示预约时间窗
    d.rep("'宝马 5 系 · 黑色',", "'${stDayLabel(t['starts_at'])} – $end',")
    d.rep("hfrac(0.65,", "hfrac(progress / 100,")
    d.rep("'65%',", "'$progress%',")
    # 信息卡
    d.rep("'全车镀晶 · 9H 陶瓷',", "stItemsOf(t),")
    d.rep("'王建国 · 黑金会员',", "'${t['customer']} · ${t['level']}',")
    d.rep("'17:00',", "end,")
    d.rep("'车内有宠物毛发',", "'${t['note'] ?? ''}'.isEmpty ? '无' : '${t['note']}',")
    # 施工节点：四个节点按进度生成，状态取自 stage
    r = []
    for title in ["'到店接车',", "'清洗 · 打磨',", "'镀晶施工',", "'固化 · 质检',"]:
        a, b = d.span(title, 'hrow', 1)
        r.append((a, b))
    rows = [d.s[a:b] for a, b in r]
    done_row = rows[1]
    cur_row = rows[2]
    next_row = rows[3]
    # 已完成 / 当前 / 待进行三种样式；末节点不画连接线
    green_line = "hbox(w: 2, minH: 20, bg: Color(0xFF17C964))"
    gray_line = "hbox(w: 2, minH: 20, bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)))"
    assert green_line in done_row and gray_line in cur_row
    done_last = done_row.replace(green_line, 'SizedBox.shrink()')
    cur_last = cur_row.replace(gray_line, 'SizedBox.shrink()')
    ha = next_row.index('hcol(')
    hb = match_close(next_row, ha + 4)
    inner = next_row[ha:hb + 1]
    k = inner.rindex(']')
    next_mid = next_row[:ha] + inner[:k].rstrip() + ', ' + gray_line + inner[k:] + next_row[hb + 1:]

    def texts(row, title, sub):
        row = row.replace("'清洗 · 打磨',", 'title,').replace("'12:10 完成',", 'sub,')
        row = row.replace("'镀晶施工',", 'title,').replace("'进行中 · 第 2 层',", 'sub,')
        row = row.replace("'固化 · 质检',", 'title,').replace("'预计 16:30',", 'sub,')
        return row

    fn = ("    Widget node(int i, String title, {bool last = false}) {\n"
          "      final sub = nodeSub(i);\n"
          "      return switch (nodeState(i)) {\n"
          f"        0 => last ? {texts(done_last, 'title', 'sub')} : {texts(done_row, 'title', 'sub')},\n"
          f"        1 => last ? {texts(cur_last, 'title', 'sub')} : {texts(cur_row, 'title', 'sub')},\n"
          f"        _ => last ? {texts(next_row, 'title', 'sub')} : {texts(next_mid, 'title', 'sub')},\n"
          "      };\n    }\n")
    first = rows[0]
    first_t = first.replace("'到店接车',", 'title,').replace("'10:42 · 已拍照留档',", 'sub,')
    # 第一个节点的两种样式沿用已完成 / 待进行（到店前显示为当前）
    fn = fn.replace("0 => last", "0 => last", 1)
    # 用 node(1..4) 取代四个固定节点
    new_nodes = "node(1, '到店接车'), node(2, '清洗 · 打磨'), node(3, itemNode), node(4, '固化 · 质检', last: true)"
    a_first, _ = r[0]
    _, b_last = r[3]
    # 节点之间的分隔（逗号）一并替换
    d.cut(a_first, b_last, new_nodes)
    d.s = d.s.replace("    return HPage(", fn + "    return HPage(", 1)
    # 施工照片：存储上传未接通（TODO），不展示示例图
    ta, tb = d.span("'施工照片 · 6 张',", 'hcol', 1)
    sec = d.s[ta:tb]
    sec = sec.replace("'施工照片 · 6 张',", "'施工照片 · 0 张',")
    # 保留最后一块「添加」虚线框，其余示例照片去掉
    tiles = []
    pos = 0
    import re
    for m in re.finditer(r'UnconstrainedBox\(', sec):
        a = m.start()
        b = match_close(sec, m.end() - 1) + 1
        tiles.append((a, b))
    assert len(tiles) == 4, len(tiles)
    add_tile = sec[tiles[3][0]:tiles[3][1]]
    add_tile = ("hTap(context, " + add_tile + ", onTap: () => AppToast.show(context, 'TODO：施工照片上传待接通'))")
    sec = sec[:tiles[0][0]] + add_tile + sec[tiles[3][1]:]
    d.cut(ta, tb, sec)
    # 底部操作：只有施工中（且未提交完工）可以更新进度 / 提交完工
    a = d.s.index('overlays: [')
    b = match_close(d.s, d.s.index('[', a)) + 1
    d.cut(a, b, 'overlays: phase == 1 ? ' + d.s[a + len('overlays: '):b] + ' : []')
    d.rep("to: 'StProgress'", "onTap: () => openRoute(context, 'StProgress')")
    d.rep("to: 'StFinish'", "onTap: () => openRoute(context, 'StFinish')")
    d.s += """
/// 任务详情：当前任务（[TaskFlow.currentId]）由服务端校验是派给自己的；进度 / 完工后自动刷新。
class StTaskDetailLivePage extends StatelessWidget {
  const StTaskDetailLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    needsId: false,
    title: '任务详情',
    refresh: TaskFlow.changed,
    load: (_) => stLoadTask(),
    builder: (_, d) => StTaskDetailTemplate(d: d),
  );
}
"""
    save('st_task_detail_template.dart', d)



# ───────────── 更新进度（弹层）─────────────
def progress():
    import re
    d = load('st_progress_sheet.dart')
    old, new = 'StProgressSheet', 'StProgressTemplate'
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatefulWidget {{\n  final Map<String, dynamic> d;\n  const {new}({{super.key, required this.d}});\n\n"
        f"  @override\n  State<{new}> createState() => _{new}State();\n}}\n\n"
        f"class _{new}State extends State<{new}> {{\n"
        "  // 选中的行 = 当前所在节点：第 0 行表示已完成 1 个节点（到店接车），依次类推\n"
        "  late int row = (((widget.d['stage'] as num?) ?? 1).toInt() - 1).clamp(0, 2);\n\n"
        "  Future<void> save() async {\n"
        "    try {\n"
        "      final t = await merchantApi.staffWork('staff_task_progress', {'id': widget.d['id'], 'stage': row + 1});\n"
        "      TaskFlow.notify();\n"
        "      if (!mounted) return;\n"
        "      AppToast.show(context, '进度已更新为 ${t['progress']}%');\n"
        "      Navigator.of(context).pop();\n"
        "    } catch (e) {\n"
        "      if (mounted) AccessFlow.toastError(context, e);\n"
        "    }\n  }\n\n"
        "  @override\n  Widget build(BuildContext context) {\n"
        "    final items = ((widget.d['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').toList();\n"
        "    final itemNode = items.isEmpty ? '项目施工' : (items.length == 1 ? '${items.first} 施工' : '${items.first} 等 ${items.length} 项施工');\n"
        "    return ",
    )
    d.rep("groups: [({1}, false)],", "groups: [({row}, false)], onSelect: {0: (i) => row = i},") if "groups: [({1}, false)]," in d.s else None
    d.rep("'镀晶施工',", "itemNode,", 2)
    # 每行的说明随选中项变化：选中行之前「已完成」，选中行「当前阶段」，之后「下一阶段」
    k = 0
    for lit in ["'已完成',", "'当前阶段 · 第 2 层',", "'下一阶段',"]:
        pass
    pos = 0
    out = d.s
    seq = []
    for m in re.finditer(r"Text\('(已完成|当前阶段 · 第 2 层|下一阶段)',", out):
        seq.append(m.start())
    assert len(seq) == 6, len(seq)
    for idx in reversed(range(6)):
        a = seq[idx]
        b = match_close(out, out.index('(', a)) + 1
        text = out[a:b]
        style = text[text.index('style:'):-1]
        rw = idx // 2
        out = (out[:a] + f"ListenableBuilder(listenable: g1[0], builder: (_, _) => Text(g1[0].selected.isEmpty || {rw} > g1[0].selected.first ? '下一阶段' : ({rw} == g1[0].selected.first ? '当前阶段' : '已完成'), {style}))" + out[b:])
    d.s = out
    d.rep("to: 'StTaskDetail'),", "onTap: () => Navigator.of(context).pop()),", 1) if False else None
    ca, cb = d.span("'取消',", 'hTap', 1)
    d.cut(ca, cb, d.s[ca:cb].replace("to: 'StTaskDetail'", "onTap: () => Navigator.of(context).pop()"))
    sa, sb = d.span("'保存',", 'hTap', 1)
    seg = d.s[sa:sb].replace("to: 'StTaskDetail'", "onTap: () => runBusy('StProgress>StTaskDetail', save)")
    d.cut(sa, sb, seg)
    busy(d, "'保存',", 'StProgress>StTaskDetail')
    d.s = d.s.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';", 1)
    save('st_progress_template.dart', d)


# ───────────── 完工提交 ─────────────
def finish():
    d = load('st_finish_page.dart')
    stateless(d, 'StFinishPage', 'StFinishTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final t = d;\n    final plateGreen = stPlateGreen(t['plate']);\n")
    pa, pb = d.span("'沪A·8K29M',", 'hbox', 1)
    d.cut(pa, pb, plate_dyn(d.s[pa:pb].replace("'沪A·8K29M',", 'stPlateOf(t),'), 'plateGreen'))
    d.rep("'全车镀晶 · 9H 陶瓷',", "stItemsOf(t),")
    d.rep("'¥158',", "stMoney(t['est_commission']),")
    # TODO: 完工照片上传 / 耗材登记没有后端（预期接口：存储上传、领用耗材），不展示示例内容
    ra, rb = d.span("'已拍摄完工照片（6 张）',", 'hbox', 1)
    div = d.s.rindex('hbox(h: 1,', 0, ra)
    d.cut(div, ra)
    ra, rb = d.span("'已拍摄完工照片（6 张）',", 'hbox', 1)
    remove_element(d, ra, rb)
    ca, cb = d.span("'耗材',", 'hbox', 1)
    remove_element(d, ca, cb)
    # 紧随其后的分隔线
    da = ca
    while d.s[da] in ' \n':
        da += 1
    assert d.s[da:].startswith('hbox(h: 1,'), d.s[da:da + 30]
    db = match_close(d.s, d.s.index('(', da)) + 1
    remove_element(d, da, db)
    d.rep("to: 'StTaskDetail'", "onTap: () => openRoute(context, 'StTaskDetail')")
    d.rep("to: 'StDone'", "onTap: () => runBusy('StFinish>StDone', () async { try { final r = await merchantApi.staffWork('staff_task_finish', {'id': t['id']}); TaskFlow.finished = r; TaskFlow.notify(); if (context.mounted) openRoute(context, 'StDone'); } catch (e) { if (context.mounted) AccessFlow.toastError(context, e); } })")
    busy(d, "'确认完工',", 'StFinish>StDone')
    d.rep("'提交后将通知收银与车主取车',", "'提交后将通知前台收银',")
    d.s += """
/// 完工提交：提交后任务进入「已完成」，并通知前台 / 店长收银（服务端校验任务属于自己且正在施工）。
class StFinishLivePage extends StatelessWidget {
  const StFinishLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    needsId: false,
    title: '完工提交',
    load: (_) => stLoadTask(),
    builder: (_, d) => StFinishTemplate(d: d),
  );
}
"""
    save('st_finish_template.dart', d)


# ───────────── 已完工 ─────────────
def done():
    d = load('st_done_page.dart')
    stateless(d, 'StDonePage', 'StDoneTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final t = d;\n    final plateGreen = stPlateGreen(t['plate']);\n")
    d.rep("'+¥158',", "'+${stMoney(t['est_commission'])}',")
    d.rep("'已通知车主取车，提成已计入本月',", "'已通知前台收银，结算后计入本月提成',")
    pa, pb = d.span("'沪A·8K29M',", 'hbox', 1)
    d.cut(pa, pb, plate_dyn(d.s[pa:pb].replace("'沪A·8K29M',", 'stPlateOf(t),'), 'plateGreen'))
    d.rep("'全车镀晶 · 9H 陶瓷',", "stItemsOf(t),")
    d.rep("'待取车',", "'待收银',")
    d.rep("'16:48',", "stClock(t['finished_at']),")
    d.rep("'本单提成',", "'预计提成',")
    d.rep("'¥158',", "stMoney(t['est_commission']),")
    d.rep("'今日累计',", "'今日累计预计',")
    d.rep("'¥544',", "stMoney(t['today_commission']),")
    d.rep("to: 'StTasks'", "onTap: () => openRoute(context, 'StTasks')")
    d.s += """
/// 完工结果：数据来自刚提交的完工（[TaskFlow.finished]），直达进入时提示先提交完工。
class StDoneLivePage extends StatelessWidget {
  const StDoneLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = TaskFlow.finished;
    if (r == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先在任务详情提交完工', type: AppErrorType.notFound),
          onNext: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    return StDoneTemplate(d: r);
  }
}
"""
    save('st_done_template.dart', d)



# ───────────── 业绩提成 ─────────────
def perf():
    d = load('st_perf_page.dart')
    stateless(d, 'StPerfPage', 'StPerfTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final ym = '${d['month']}'.split('-');\n"
              "    final monthLabel = ym.length == 2 ? '${ym[0]} 年 ${int.tryParse(ym[1]) ?? ''} 月' : '';\n"
              "    final revenue = ((d['month_revenue'] as num?) ?? 0).toDouble();\n"
              "    final commission = ((d['month_commission'] as num?) ?? 0).toDouble();\n"
              "    final days = [for (final x in (d['days'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];\n"
              "    final rows = [for (final x in (d['rows'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];\n"
              "    final peak = days.fold<double>(0, (m, x) => ((x['amount'] as num?) ?? 0) > m ? ((x['amount'] as num?) ?? 0).toDouble() : m);\n"
              "    double barH(int i) => peak <= 0 ? 4 : 4 + ((days[i]['amount'] as num).toDouble() / peak) * 92;\n"
              "    String dayLabel(int i) => i == days.length - 1 ? '今天' : const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][(DateTime.tryParse('${days[i]['day']}')?.weekday ?? 1) - 1];\n"
              "    String compact(double v) => v >= 10000 ? '¥${(v / 1000).toStringAsFixed(1)}k' : stMoney(v);\n"
              "    String mmdd(Object? iso) { final t = DateTime.tryParse('${iso ?? ''}')?.toUtc().add(const Duration(hours: 8)); return t == null ? '—' : '${t.month}月${t.day}日'; }\n")
    d.rep("'2026 年 11 月',", "monthLabel,")
    d.rep("'¥4,620',", "stMoney(commission),")
    d.rep("'62',", "'${d['month_orders'] ?? 0}',")
    d.rep("'¥38.6k',", "compact(revenue),")
    # 提成比例：本月提成 / 本月业绩（实际综合比例，不是配置的方案比例）
    d.rep("'12%',", "revenue > 0 ? '${(commission / revenue * 100).round()}%' : '—',")
    b1a, b1b = d.span("'周一',", 'Expanded', 1, 2)
    b7a, b7b = d.span("'今天',", 'Expanded', 1)
    import re
    bar = d.s[b1a:b1b]
    bar = re.sub(r'hbox\(h: \d+, maxW: 26', 'hbox(h: barH(i), maxW: 26', bar, count=1).replace("'周一',", 'dayLabel(i),')
    last = d.s[b7a:b7b]
    last = re.sub(r'hbox\(h: \d+, maxW: 26', 'hbox(h: barH(i), maxW: 26', last, count=1).replace("'今天',", 'dayLabel(i),')
    fn = f"    Widget bar(int i) => i == days.length - 1 ? {last} : {bar};\n"
    d.cut(b1a, b7b, "for (var i = 0; i < days.length; i++) bar(i)")
    ra, rb = d.span("'全车镀晶 · 沪A·8K29M',", 'hbox', 1)
    rc, rd = d.span("'全车镀晶 · 沪C·7Q221',", 'hbox', 1)
    sep = d.s[rb:d.s.index('hbox(minH: 60', rb)].strip().strip(',').strip()
    row = (d.s[ra:rb].replace("'全车镀晶 · 沪A·8K29M',", "'${x['service']} · ${x['plate']}'.replaceAll(RegExp(r' · $'), ''),")
           .replace("'10月31日',", "mmdd(x['at']),").replace("'¥158',", "stMoney(x['amount']),"))
    empty = "hbox(minH: 64, align: Alignment.center, child: Text('本月暂无提成明细', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)))"
    d.cut(ra, rd, f"if (rows.isEmpty) {empty}, for (var i = 0; i < rows.length; i++) ...[if (i > 0) {sep}, (() {{ final x = rows[i]; return {row}; }})()]")
    d.s = d.s.replace("    return HPage(", fn + "    return HPage(", 1)
    d.s += """
/// 业绩提成：本月提成 / 完成单 / 业绩、近 7 天提成与明细，来自服务端的提成快照。
class StPerfLivePage extends StatelessWidget {
  const StPerfLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '业绩提成',
    load: () => merchantApi.staffWork('staff_perf'),
    builder: (_, d) => StPerfTemplate(d: d),
  );
}
"""
    save('st_perf_template.dart', d)


# ───────────── 今日到店 ─────────────
def arrivals():
    d = load('st_arrivals_page.dart')
    drop_dock(d) if 'overlays: [HBottomDock' in d.s else None
    stateless(d, 'StArrivalsPage', 'StArrivalsTemplate', '  final Map<String, dynamic> d;', 'required this.d',
              "    final items = [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];\n"
              "    final arrived = items.where((x) => x['status'] != 'waiting').length;\n"
              "    final waiting = items.length - arrived;\n")
    d.rep("'4 位车主',", "'${items.length} 位车主',")
    d.rep("'已到店 1',", "'已到店 $arrived',")
    d.rep("'待到店 3',", "'待到店 $waiting',")
    ra, rb = d.span("'10:30',", 'hTap', 1)
    rc, rd = d.span("'16:30',", 'hTap', 1)
    green_bg = "dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16))"
    green_fg = "dk(context, Color(0xFF2B7745), Color(0xFF5FD48C))"
    row = d.s[ra:rb]
    assert green_bg in row and green_fg in row
    row = (row.replace("'10:30',", "stClock(t['starts_at']),").replace("'沪A·8K29M',", 'stPlateOf(t),')
           .replace("'全车镀晶 + 内饰清洁',", 'stItemsOf(t),').replace("'客户 王建国 · 黑金会员',", "'客户 ${t['customer']} · ${t['level']}',")
           .replace("'已到店',", "t['status'] == 'waiting' ? '待到店' : (t['status'] == 'done' ? '已完成' : '已到店'),")
           .replace(green_bg, f"t['status'] == 'waiting' ? {BLUE_BG} : {green_bg}")
           .replace(green_fg, f"t['status'] == 'waiting' ? {BLUE_FG} : {green_fg}"))
    # 前台没有任务详情（那是技师的施工任务），行不跳转
    row = row.replace(", to: 'StTaskDetail')", ")")
    row = plate_dyn(row, "stPlateGreen(t['plate'])")
    empty = "hbox(minH: 64, align: Alignment.center, child: Text('今日暂无预约', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)))"
    d.cut(ra, rd + 0 if False else d.span("'16:30',", 'hTap', 1)[1], f"if (items.isEmpty) {empty}, for (final t in items) {row}")
    d.s += """
/// 今日到店：门店当天的预约（需要「今日到店」权限，服务端校验）。
class StArrivalsLivePage extends StatelessWidget {
  const StArrivalsLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '今日到店',
    load: () => merchantApi.staffWork('staff_arrivals'),
    builder: (_, d) => StArrivalsTemplate(d: d),
  );
}
"""
    save('st_arrivals_template.dart', d)


# ───────────── 消息 ─────────────
def msgs():
    d = load('st_msgs_page.dart')
    old, new = 'StMsgsPage', 'StMsgsTemplate'
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatefulWidget {{\n  final Map<String, dynamic> d;\n  const {new}({{super.key, required this.d}});\n\n"
        f"  @override\n  State<{new}> createState() => _{new}State();\n}}\n\n"
        f"class _{new}State extends State<{new}> {{\n"
        "  static const kinds = ['task', 'arrival', 'system'];\n"
        "  int tab = 0;\n\n"
        "  Future<void> open(Map<String, dynamic> m) async {\n"
        "    final link = '${m['link'] ?? ''}';\n"
        "    if (link.startsWith('StTaskDetail:')) {\n"
        "      TaskFlow.currentId = link.substring('StTaskDetail:'.length);\n"
        "      openRoute(context, 'StTaskDetail');\n"
        "    } else if (link.isNotEmpty) {\n"
        "      openRoute(context, link);\n"
        "    }\n"
        "    if (m['read_at'] == null) {\n"
        "      try {\n"
        "        await merchantApi.staffWork('staff_messages_read', {'id': m['id']});\n"
        "        TaskFlow.notify();\n"
        "      } catch (_) {\n"
        "        // 标记已读失败不影响查看，下次进入仍显示未读\n"
        "      }\n"
        "    }\n  }\n\n"
        "  Future<void> readAll() async {\n"
        "    try {\n"
        "      await merchantApi.staffWork('staff_messages_read');\n"
        "      TaskFlow.notify();\n"
        "    } catch (e) {\n"
        "      if (mounted) AccessFlow.toastError(context, e);\n"
        "    }\n  }\n\n"
        "  @override\n  Widget build(BuildContext context) {\n"
        "    final all = [for (final x in (widget.d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];\n"
        "    final shown = tab == 0 ? all : [for (final m in all) if (m['kind'] == kinds[tab - 1]) m];\n"
        "    return ",
    )
    d.rep("groups: [({0}, false)],", "groups: [({tab}, false)], onSelect: {0: (i) => setState(() => tab = i)},") if "groups: [({0}, false)]," in d.s else None
    dot = "hbox(w: 8, h: 8, bg: Color(0xFFF31260), radius: BorderRadius.circular(4))"

    def row_of(anchor):
        a, b = d.span(anchor, 'hTap', 1)
        return a, b, d.s[a:b]

    rows = {}
    spans = []
    for key, title, time, body in [
        ('task', "'新任务派给你',", "'14:02',", "'沪B·5X770 内饰深度清洁，预计 14:00 到店。派单人：小刘（前台）。',"),
        ('arrival', "'车主已到店',", "'10:42',", "'王建国的沪A·8K29M 已到店，可以接车。',"),
        ('perf', "'提成已更新',", None, "'全车镀晶 沪A·8K29M 已完工，+¥158 计入本月提成。',"),
        ('perm', "'权限已调整',", None, "'老板调整了「施工技师」的权限：新增「领用耗材」。',"),
    ]:
        a, b, r = row_of(title)
        spans.append((a, b))
        r = r.replace(title, "'${m['title']}',").replace(body, "'${m['body']}',")
        r = r.replace("'昨天',", "stMsgTime(m['created_at']),")
        if time:
            r = r.replace(time, "stMsgTime(m['created_at']),")
        r = r.replace(dot + ", ", "")
        # 标题后的未读红点
        ta, tb = Doc(r).span("'${m['title']}',", 'Text', 1)
        r = r[:tb] + ", if (m['read_at'] == null) " + dot + r[tb:]
        for tgt in ["'StTaskDetail'", "'StArrivals'", "'StPerf'", "'StMine'"]:
            r = r.replace("to: " + tgt, "onTap: () => open(m)")
        rows[key] = r
    sa = spans[0][0]
    sb = spans[3][1]
    sep = d.s[spans[0][1]:spans[1][0]].strip().strip(',').strip()
    fn = ("    Widget row(Map<String, dynamic> m) => switch (m['kind']) {\n"
          f"      'task' => {rows['task']},\n"
          f"      'arrival' => {rows['arrival']},\n"
          f"      _ => '${{m['link']}}' == 'StPerf' ? {rows['perf']} : {rows['perm']},\n"
          "    };\n")
    empty = "hbox(minH: 64, align: Alignment.center, child: Text('暂无消息', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)))"
    d.cut(sa, sb, f"if (shown.isEmpty) {empty}, for (var i = 0; i < shown.length; i++) ...[if (i > 0) {sep}, row(shown[i])]")
    d.s = d.s.replace("    return HPage(", fn + "    return HPage(", 1)
    d.rep("label: '全部已读'", "onTap: () => runBusy('StMsgs>readAll', readAll), label: '全部已读'")
    d.s += """
/// 消息：任务 / 到店 / 系统通知；点开跳转到对应页面并标记已读。
class StMsgsLivePage extends StatelessWidget {
  const StMsgsLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '消息',
    load: () => merchantApi.staffWork('staff_messages'),
    builder: (_, d) => StMsgsTemplate(d: d),
  );
}
"""
    save('st_msgs_template.dart', d)


PAGES = ['auth_fail', 'no_perm', 'plan_expired', 'auth', 'identity', 'home', 'front_home', 'mine', 'tasks', 'task_detail', 'progress', 'finish', 'done', 'perf', 'arrivals', 'msgs']

if __name__ == '__main__':
    for name in sys.argv[1:] or PAGES:
        globals()[name]()
        print('ok', name)
