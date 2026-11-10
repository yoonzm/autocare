#!/usr/bin/env python3
"""把设计稿生成页（lib/pages/gen/staff_*）派生为接真实后端的员工模板（lib/pages/*_template.dart）。

只替换数据来源和事件处理，视觉与结构保持 gen/ 原样；不手工修改 gen/。
用法（在 apps/merchant 目录）：python3 tools/bind_staff.py [页面 ...]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from derive import Doc, match_close  # noqa: E402

GEN = 'lib/pages/gen/'
OUT = 'lib/pages/'
HEADER = '// 从既有设计模板派生（tools/bind_staff.py），仅绑定数据和事件；不手工修改 gen/。\n'
IMPORTS = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../backend/merchant_api.dart';
import '../backend/staff_flow.dart';
import '../backend/store_profile.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../kit/sheet_route.dart';
import '../routes.dart' show openRoute;
import 'booking_resources_page.dart';
import 'gen/svgs.dart';
import 'staff_live.dart';
"""
OLD_IMPORTS = "import 'package:flutter/material.dart';\n\nimport '../../kit/kit.dart';\nimport 'svgs.dart';\n"


def load(name):
    d = Doc(open(GEN + name).read())
    d.rep(OLD_IMPORTS, IMPORTS)
    return d


def save(name, d):
    body = d.s
    for imp, token in (
        ("import 'package:flutter/services.dart';\n", 'Clipboard'),
        ("import '../backend/merchant_api.dart';\n", 'merchantApi'),
        ("import '../backend/store_profile.dart';\n", 'storeProfile'),
    ):
        if token not in body.replace(imp, ''):
            body = body.replace(imp, '')
    for imp, tokens in (
        ("import '../routes.dart' show openRoute;\n", ('openRoute',)),
        ("import '../kit/sheet_route.dart';\n", ('appSheetRoute',)),
        ("import 'booking_resources_page.dart';\n", ('BookingResourceEditor',)),
        ("import '../kit/async_kit.dart';\n", ('runBusy', 'AppToast', 'ErrorView', 'AsyncView', 'AppError')),
    ):
        if not any(t in body.replace(imp, '') for t in tokens):
            body = body.replace(imp, '')
    # 删除没有用到的局部变量
    import re
    for var in ('id', 'name', 'role', 'masked', 'reason'):
        m = re.search(r"^    final " + var + r" = [^\n]*\n", body, re.M)
        if m and not re.search(r"(?<![\w'.])\$?\{?" + var + r"\b", body[:m.start()] + body[m.end():]):
            body = body[:m.start()] + body[m.end():]
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


def wrap_tap(d, anchor, expr, name='hbox', nth=1):
    """给没有点击事件的设计稿控件加上 hTap。"""
    a, b = d.span(anchor, name, nth)
    d.cut(a, b, f"hTap(context, {d.s[a:b]}, onTap: {expr})")


def run_action(key, body):
    return (f"() => runBusy('{key}', () async {{ try {{ {body} }} catch (e) "
            "{ if (context.mounted) AppToast.error(context, e); } })")


def stateless_with_data(d, old, new, locals_='', use_id=True):
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatelessWidget {{\n  final Map<String, dynamic> d;\n  const {new}({{super.key, required this.d}});\n\n"
        f"  @override\n  Widget build(BuildContext context) {{\n{"    final id = '${d['id']}';\n" if use_id else ''}    final name = '${{d['name']}}';\n"
        f"    final role = StaffFlow.roleName(d['role']);\n{locals_}    return ",
    )


# ───────────── 重新启用 ─────────────
def enable():
    d = load('staff_enable_sheet.dart')
    stateless_with_data(d, 'StaffEnableSheet', 'StaffEnableTemplate')
    d.rep("'重新启用 赵磊 的账号？'", "'重新启用 $name 的账号？'")
    d.rep("'赵',", "staffInitial(d),")
    d.rep("'赵磊',", "name,")
    d.rep("'洗车技师 · 已停用 · 10.18',", "'$role · 已停用 · ${staffMonthDay(d['disabled_at'])}',")
    busy(d, "'确认启用'", 'StaffEnable>Staff')
    d.rep(
        "to: 'Staff',",
        "onTap: " + run_action(
            'StaffEnable>Staff',
            "await StaffFlow.setStatus(id, 'enabled'); if (context.mounted) openRoute(context, 'Staff');",
        ) + ",",
    )
    save('staff_enable_template.dart', d)


# ───────────── 停用 ─────────────
def disable():
    d = load('disable_staff_sheet.dart')
    stateless_with_data(d, 'DisableStaffSheet', 'DisableStaffTemplate',
                        "    final open = (d['open_work'] as List?) ?? const [];\n")
    d.rep("'停用 李国强 的账号？'", "'停用 $name 的账号？'")
    d.rep("'李',", "staffInitial(d),")
    d.rep("'李国强',", "name,")
    d.rep(
        "'施工技师 · 施工中 · 2 号工位',",
        "[role, if (d['status'] == 'pending') '待激活' else if (d['busy'] == true) '施工中' else '空闲', "
        "if (d['bay_name'] != null) '${d['bay_name']}'].join(' · '),",
    )
    # 有进行中订单时才出现「需先转交」一行
    a, b = d.span("'进行中的 1 个订单需先转交给其他技师'", 'hrow')
    row = d.s[a:b].replace("'进行中的 1 个订单需先转交给其他技师'", "'进行中的 ${open.length} 个订单需先转交给其他技师'")
    d.cut(a, b, "if (open.isNotEmpty) " + row)
    d.rep("to: 'StaffTransfer',",
          "onTap: () { StaffFlow.currentId = id; openRoute(context, 'StaffTransfer'); },")
    busy(d, "'确认停用'", 'DisableStaff>Staff')
    d.rep(
        "to: 'Staff',",
        "onTap: open.isNotEmpty ? () => AppToast.show(context, '请先转交进行中的订单') : " + run_action(
            'DisableStaff>Staff',
            "await StaffFlow.setStatus(id, 'disabled'); if (context.mounted) openRoute(context, 'Staff');",
        ) + ",",
    )
    save('disable_staff_template.dart', d)


# ───────────── 转交进行中的订单 ─────────────
def transfer():
    d = load('staff_transfer_sheet.dart')
    old = 'StaffTransferSheet'
    new = 'StaffTransferTemplate'
    init = (
        "    final d = widget.d;\n    final id = '${d['id']}';\n"
        "    final open = (d['open_work'] as List?) ?? const [];\n"
        "    final cands = [for (final c in (d['candidates'] as List? ?? const [])) Map<String, dynamic>.from(c as Map)];\n"
        "    final sel = picked ?? (cands.isEmpty ? null : '${cands.first['id']}');\n"
    )
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        f"class {new} extends StatefulWidget {{\n  final Map<String, dynamic> d;\n  const {new}({{super.key, required this.d}});\n\n"
        f"  @override\n  State<{new}> createState() => _{new}State();\n}}\n\n"
        f"class _{new}State extends State<{new}> {{\n  String? picked;\n\n  @override\n  Widget build(BuildContext context) {{\n{init}    return ",
    )
    # 订单卡：每个进行中的订单一张
    a, b = d.span("'沪A·8K29M',", 'hbox', 2)
    card = d.s[a:b]
    card = card.replace("'沪A·8K29M',", "'${o['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${o['plate']}',")
    card = card.replace("'全车镀晶 · 9H',", "((o['items'] as List?) ?? const []).map((e) => '${(e as Map)['name']}').join(' · '),")
    card = card.replace(
        "'施工中 65% · 2 号工位',",
        "[o['status'] == 'arrived' ? '施工中' : '待到店', if (o['bay_name'] != null) '${o['bay_name']}'].join(' · '),",
    )
    d.cut(a, b, "for (final o in open) " + card)
    # 候选技师：第一张是选中样式、第二张是未选中样式
    a1, b1 = d.span("'王磊',", 'hbox', 1)
    a2, b2 = d.span("'张伟',", 'hbox', 1)
    on, off = d.s[a1:b1], d.s[a2:b2]
    ca, cb = d.span("'空闲',", 'hbox', 1)
    chip_free = d.s[ca:cb]
    ca2, cb2 = d.span("'施工中',", 'hbox', 1)
    chip_busy = d.s[ca2:cb2]
    assert ca < a2 < ca2 < b2

    def fill(card, chip, ini, nm, sub):
        card = card.replace(chip, 'chip').replace(ini, 'staffInitial(c),').replace(nm, "'${c['name']}',")
        return card.replace(
            sub,
            "[if ('${c['skills'] ?? ''}'.isNotEmpty) '${c['skills']}', '本月 ${c['month_orders'] ?? 0} 台次'].join(' · '),",
        )

    on = fill(on, chip_free, "'王',", "'王磊',", "'洗车 / 内饰 · 本月 203 台次',")
    off = fill(off, chip_busy, "'张',", "'张伟',", "'贴膜 · 本月 46 台次',")
    fn = (
        "    Widget cand(Map<String, dynamic> c, bool on) {\n"
        "      final chip = c['busy'] == true ? " + chip_busy + " : " + chip_free + ";\n"
        "      return on ? " + on + " : " + off + ";\n    }\n\n"
    )
    d.cut(a1, b2, "for (final c in cands) hTap(context, cand(c, '${c['id']}' == sel), "
                  "onTap: () => setState(() => picked = '${c['id']}'))")
    d.rep("    return hbox(\n      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),",
          fn + "    return hbox(\n      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),")
    # 取消：回到「停用账号」确认弹层（设计稿 StaffTransfer → DisableStaff）
    d.rep("to: 'DisableStaff',",
          "onTap: () { final nav = Navigator.of(context); nav.pop(); openRoute(nav.context, 'DisableStaff'); },")
    busy(d, "'转交并停用'", 'StaffTransfer>Staff')
    d.rep(
        "to: 'Staff',",
        "onTap: sel == null ? () => AppToast.show(context, '没有可接手的技师，请先添加或启用其他技师') : " + run_action(
            'StaffTransfer>Staff',
            "await StaffFlow.setStatus(id, 'disabled', transferTo: sel); if (context.mounted) openRoute(context, 'Staff');",
        ) + ",",
    )
    save('staff_transfer_template.dart', d)


# ───────────── 邀请（新增后） ─────────────
def invite():
    d = load('staff_invite_page.dart')
    stateless_with_data(d, 'StaffInvitePage', 'StaffInviteTemplate',
                        "    final masked = StaffFlow.maskedPhone(d['phone']);\n")
    d.rep("'赵敏 · 施工技师',", "'$name · $role',")
    d.rep("'赵',", "staffInitial(d),")
    d.rep("'赵敏',", "name,")
    d.rep("'施工技师 · 138 **** 5521',", "'$role · $masked',")
    d.rep("'邀请赵敏登录汽美管家',", "'邀请$name登录汽美管家',")
    # TODO: 二维码目前是设计稿的示意图（不可扫码）。真实二维码需要 App 下载地址（配置后由 staff_invite 返回）与二维码生成。
    d.rep("'手机号与登记的 138 **** 5521 匹配即自动激活',", "'手机号与登记的 $masked 匹配即自动激活',")
    copy = run_action(
        'StaffInvite>copy',
        "final r = await StaffFlow.invite(id); await Clipboard.setData(ClipboardData(text: '${r['link']}')); "
        "if (context.mounted) AppToast.show(context, '邀请链接已复制', kind: ToastKind.success);",
    )
    sms = run_action(
        'StaffInvite>sms',
        "await merchantApi.staff('invite', {'id': id, 'via': 'sms'}); "
        "if (context.mounted) AppToast.show(context, '短信已发送', kind: ToastKind.success);",
    )
    busy(d, "'复制邀请链接'", 'StaffInvite>copy', label=False)
    busy(d, "'发送短信'", 'StaffInvite>sms', label=False)
    wrap_tap(d, "'StaffInvite>copy'", copy)
    wrap_tap(d, "'StaffInvite>sms'", sms)
    # 设计稿「完成」是主色蓝底白字（生成页过期，仍是黑底）
    a, b = d.span("'完成',", 'hbox', 1)
    seg = d.s[a:b].replace("bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA))", "bg: Color(0xFF0485F7)")
    seg = seg.replace("dk(context, Color(0xFFFFFFFF), Color(0xFF18181B))", "Color(0xFFFFFFFF)")
    d.cut(a, b, seg)
    d.s += """
/// 新增员工后的邀请页：展示刚保存的员工（[StaffFlow.invited]），不读取示例数据。
class StaffInviteLivePage extends StatelessWidget {
  const StaffInviteLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final d = StaffFlow.invited;
    if (d == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先添加员工', type: AppErrorType.notFound),
          onNext: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    return StaffInviteTemplate(d: d);
  }
}
"""
    save('staff_invite_template.dart', d)


# ───────────── 已停用员工详情 ─────────────
def detail_off():
    d = load('staff_detail_off_page.dart')
    stateless_with_data(d, 'StaffDetailOffPage', 'StaffDetailOffTemplate',
                        "    final reason = '${d['disable_reason'] ?? ''}';\n", use_id=False)
    d.rep("'赵',", "staffInitial(d),")
    d.rep("'赵磊',", "name,")
    d.rep("'洗车技师 · 入职 2023.06',", "'$role · 入职 ${StaffFlow.dotDate(d['joined_on'], monthOnly: true)}',")
    d.rep("'停用于 2026.10.18 · 操作人 陈明（店长）',", "'停用于 ${staffFullDay(d['disabled_at'])} · 操作人 ${d['disabled_by']}',")
    a, b = d.span("'原因：已离职',", 'Text')
    d.cut(a, b, "if (reason.isNotEmpty) " + d.s[a:b].replace("'原因：已离职',", "'原因：$reason',"))
    d.rep("'138 **** 9012',", "StaffFlow.maskedPhone(d['phone']),")
    d.rep("'施工技师（停用中）',", "'$role（停用中）',")
    d.rep("'跟随项目设置',", "staffCommissionLabel(d),")
    d.rep("'1,206 台次',", "'${staffCount(d['total_orders'])} 台次',")
    d.rep("'¥42,380',", "StaffFlow.money(d['total_commission']),")
    d.s += """
/// 已停用员工详情（设计稿 StaffDetailOff）：读取真实员工与累计记录。
class StaffDetailOffLivePage extends StatelessWidget {
  const StaffDetailOffLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '员工详情',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffDetailOffTemplate(d: d),
  );
}
"""
    save('staff_detail_off_template.dart', d)


# ───────────── 员工详情 ─────────────
def detail():
    d = load('staff_detail_page.dart')
    stateless_with_data(
        d, 'StaffDetailPage', 'StaffDetailTemplate',
        "    final skills = '${d['skills'] ?? ''}'.isEmpty ? <String>[] : '${d['skills']}'.split(' / ');\n"
        "    final recent = [for (final r in (d['recent'] as List? ?? const [])) Map<String, dynamic>.from(r as Map)];\n"
        "    final status = [if (d['status'] == 'pending') '待激活' else if (d['busy'] == true) '施工中' else '空闲', "
        "if (d['bay_name'] != null) '${d['bay_name']}'].join(' · ');\n",
        use_id=False,
    )
    d.rep("'李',", "staffInitial(d),")
    d.rep("'李国强',", "name,")
    d.rep("'施工中 · 2 号工位',", "status,")
    d.rep("'施工技师 · 入职 2022.03',", "'$role · 入职 ${StaffFlow.dotDate(d['joined_on'], monthOnly: true)}',")
    d.rep("'118',", "'${d['month_orders'] ?? 0}',")
    d.rep("'¥8,640',", "StaffFlow.money(d['month_commission']),")
    # TODO: 客户好评没有评价数据来源（预期接口：staff_rating），显示「—」，不造假。
    d.rep("'98%',", "'—',")
    d.rep("'138 **** 2207',", "StaffFlow.maskedPhone(d['phone']),")
    d.rep("'施工技师',", "role,")
    d.rep("'跟随项目设置',", "staffCommissionLabel(d),")
    # 擅长项目：每项一个标签
    a1, b1 = d.span("'镀晶',", 'hbox', 1)
    a3, b3 = d.span("'石墨烯镀膜',", 'hbox', 1)
    chip = d.s[a1:b1].replace("'镀晶',", 's,')
    d.cut(a1, b3, "for (final s in (skills.isEmpty ? ['未设置'] : skills)) " + chip)
    # 最近施工：蓝牌进行中 / 绿牌已完成 / 蓝牌已完成三种样式合成一个行模板
    r1a, r1b = d.span("'沪A·8K29M',", 'hrow', 1)
    r2a, r2b = d.span("'沪AF·09316',", 'hrow', 1)
    r3a, r3b = d.span("'苏E·3QX18',", 'hrow', 1)
    sep = d.s[r1b:r2a].strip().strip(',').strip()
    row3 = d.s[r3a:r3b]
    ca, cb = d.span("'苏E·3QX18',", 'hbox', 1)
    chip_blue = d.s[ca:cb]
    ga, gb = d.span("'沪AF·09316',", 'hbox', 1)
    chip_green = d.s[ga:gb]
    active_right = d.s[slice(*d.span("'进行中',", 'Text', 1))]
    done_a, done_b = d.span("'10.28 · +¥214',", 'Text', 1)
    done_right = d.s[done_a:done_b]
    row = row3.replace(chip_blue, "(staffGreenPlate(r['plate']) ? " + chip_green.replace("'沪AF·09316',", "plate,") + " : " + chip_blue.replace("'苏E·3QX18',", "plate,") + ")")
    row = row.replace(done_right, "(r['status'] == 'arrived' ? " + active_right + " : " + done_right.replace("'10.28 · +¥214',", "'${staffDayLabel(r['at'])}${r['commission'] == null ? '' : ' · +${StaffFlow.money(r['commission'])}'}',") + ")")
    row = row.replace("'石墨烯镀膜',", "'${r['service'] ?? ''}',")
    fn = ("    Widget recentRow(Map<String, dynamic> r) {\n"
          "      final plate = '${r['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${r['plate']}';\n"
          "      return " + row + ";\n    }\n\n")
    empty = ("if (recent.isEmpty) Text('暂无施工记录', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18)), ")
    d.cut(r1a, r3b, empty + "for (var i = 0; i < recent.length; i++) ...[if (i > 0) " + sep + ", recentRow(recent[i])]")
    d.rep("    return HPage(", fn + "    return HPage(")
    d.rep("to: 'StaffEdit',",
          "onTap: () => Navigator.of(context).push(appSheetRoute<void>(settings: const RouteSettings(name: 'StaffEdit'), "
          "page: BookingResourceEditor(kind: 'technician', row: d))),")
    d.rep("to: 'RolePermission',",
          "onTap: () { StaffFlow.permissionRole = d['role'] == 'cashier' ? 'cashier' : 'technician'; openRoute(context, 'RolePermission'); },")
    d.s += """
/// 员工详情（设计稿 StaffDetail）：读取真实员工、本月统计与最近施工。
class StaffDetailLivePage extends StatelessWidget {
  const StaffDetailLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '员工详情',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffDetailTemplate(d: d),
  );
}

/// 编辑员工：从详情进入时按当前员工读取，再交给编辑表单。
class StaffEditLivePage extends StatelessWidget {
  const StaffEditLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '编辑员工',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => BookingResourceEditor(kind: 'technician', row: d),
  );
}
"""
    save('staff_detail_template.dart', d)


# ───────────── 提成方案 ─────────────
def commission():
    d = load('staff_commission_page.dart')
    stateless_with_data(
        d, 'StaffCommissionPage', 'StaffCommissionTemplate',
        "    final services = [for (final s in (d['services'] as List? ?? const [])) Map<String, dynamic>.from(s as Map)];\n",
    )
    d.rep("'李',", "staffInitial(d),")
    d.rep("'李国强',", "name,")
    d.rep("'施工技师 · 上月提成 ¥8,640',", "'$role · 上月提成 ${StaffFlow.money(d['last_month_commission'])}',")
    a1, b1 = d.span("'全车镀晶 · 9H',", 'hrow', 1)
    a3, b3 = d.span("'精致洗车',", 'hrow', 1)
    row = d.s[a1:b1].replace("'全车镀晶 · 9H',", "'${s['name']}',").replace("'15%',", "staffServiceRate(s),")
    d.cut(a1, b3, "for (final s in services) " + row)
    # TODO: 「统一比例」「按项目自定义」需要比例输入界面，设计稿没有画；后端 staff_commission_save 已支持，
    #       界面确认前这两项只提示，不改动方案。
    for anchor in ("'统一比例',", "'按项目自定义',"):
        wrap_tap(d, anchor, "() => AppToast.show(context, 'TODO：比例输入界面待设计确认，当前仅支持跟随项目设置')")
    busy(d, "'保存',", 'StaffCommission>StaffDetail')
    d.rep("to: 'StaffDetail',", "onTap: " + run_action(
        'StaffCommission>StaffDetail',
        "await StaffFlow.saveCommission(id, 'follow'); if (context.mounted) openRoute(context, 'StaffDetail');",
    ) + ",")
    d.s += """
/// 提成方案（设计稿 StaffCommission）：读取员工与各服务项目的提成设置。
class StaffCommissionLivePage extends StatelessWidget {
  const StaffCommissionLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '提成方案',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffCommissionTemplate(d: d),
  );
}
"""
    save('staff_commission_template.dart', d)


# ───────────── 施工记录 ─────────────
def records():
    d = load('staff_records_page.dart')
    old = 'StaffRecordsPage'
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        "class StaffRecordsTemplate extends StatelessWidget {\n  final Map<String, dynamic> d;\n  final Map<String, dynamic> r;\n"
        "  final int range;\n  final ValueChanged<int> onRange;\n"
        "  const StaffRecordsTemplate({super.key, required this.d, required this.r, required this.range, required this.onRange});\n\n"
        "  @override\n  Widget build(BuildContext context) {\n    final name = '${d['name']}';\n"
        "    final summary = Map<String, dynamic>.from(r['summary'] as Map);\n"
        "    final rows = [for (final x in (r['rows'] as List)) Map<String, dynamic>.from(x as Map)];\n"
        "    final label = const ['本月', '上月', '累计'][range];\n    final scope = const ['本月', '上月', '全部'][range];\n    return ",
    )
    # 去掉设计预览用的 HDyn（按文字筛选的演示机制）；Tab 改为通知页面按范围重新读取
    a = d.s.index('HDyn(')
    b = d.s.index('builder: (context, d2) =>') + len('builder: (context, d2) =>')
    d.cut(a, b, 'Builder(\n                builder: (context) =>')
    d.rep("d2.vis(", "(")
    d.rep("groups: [\n                ({0}, false),\n              ],", "groups: [\n                ({range}, false),\n              ],\n              onSelect: {0: onRange},")
    d.rep("'李国强 · 施工记录',", "'$name · 施工记录',")
    d.rep("'本月台次',", "'$label台次',")
    d.rep("'本月提成',", "'$label提成',")
    d.rep("'本月记录',", "'$scope记录',")
    d.rep("'118',", "'${summary['orders'] ?? 0}',")
    d.rep("'¥8,640',", "StaffFlow.money(summary['commission']),")
    # TODO: 平均用时只统计有到店时间和完工时间的预约订单。
    d.rep("'1.8 h',", "summary['avg_hours'] == null ? '—' : '${summary['avg_hours']} h',")
    # 记录行：蓝牌进行中 / 绿牌已完成 / 蓝牌已完成合成一个行模板
    r1a, r1b = d.span("'沪A·8K29M',", 'hbox', 2)
    r2a, r2b = d.span("'沪AF·09316',", 'hbox', 2)
    r3a, r3b = d.span("'苏E·3QX18',", 'hbox', 2)
    r5a, r5b = d.span("'沪A·5P906',", 'hbox', 2)
    sep = d.s[r1b:r2a].strip().strip(',').strip()
    base = d.s[r3a:r3b]
    ca, cb = d.span("'苏E·3QX18',", 'hbox', 1)
    chip_blue = d.s[ca:cb]
    ga, gb = d.span("'沪AF·09316',", 'hbox', 1)
    chip_green = d.s[ga:gb]
    aa, ab = d.span("'提成 待结算',", 'hcol', 1)
    active_right = d.s[aa:ab]
    da, db = d.span("'+¥214',", 'hcol', 1)
    done_right = d.s[da:db]
    row = base.replace(chip_blue, "(staffGreenPlate(x['plate']) ? " + chip_green.replace("'沪AF·09316',", "plate,") + " : " + chip_blue.replace("'苏E·3QX18',", "plate,") + ")")
    row = row.replace(done_right, "(x['status'] == 'arrived' ? " + active_right + " : " + done_right.replace("'+¥214',", "x['commission'] == null ? '—' : '+${StaffFlow.money(x['commission'])}',") + ")")
    row = row.replace("'石墨烯镀膜',", "'${x['service'] ?? ''}',").replace("'10.28 10:10',", "staffDayTime(x['at']),")
    fn = ("    Widget recordRow(Map<String, dynamic> x) {\n"
          "      final plate = '${x['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${x['plate']}';\n"
          "      return " + row + ";\n    }\n\n")
    empty = ("if (rows.isEmpty) hbox(minH: 64, align: Alignment.center, child: Text('暂无施工记录', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18))), ")
    d.cut(r1a, r5b, empty + "for (var i = 0; i < rows.length; i++) ...[if (i > 0) " + sep + ", recordRow(rows[i])]")
    d.rep("    return hbox(", fn + "    return hbox(") if False else None
    d.s = d.s.replace("    return HPage(", fn + "    return HPage(", 1)
    d.s += """
/// 施工记录（设计稿 StaffRecords）：本月 / 上月 / 全部三个范围分别向后端读取。
class StaffRecordsLivePage extends StatefulWidget {
  const StaffRecordsLivePage({super.key});

  @override
  State<StaffRecordsLivePage> createState() => _StaffRecordsLivePageState();
}

class _StaffRecordsLivePageState extends State<StaffRecordsLivePage> {
  static const _ranges = ['month', 'last', 'all'];
  int range = 0;
  Map<String, dynamic>? records;
  int? token;

  Future<Map<String, dynamic>> _load(String id) async {
    final out = await Future.wait([
      merchantApi.staff('get', {'id': id}),
      merchantApi.staff('records', {'id': id, 'range': _ranges[range]}),
    ]);
    records = out[1];
    return out[0];
  }

  Future<void> _pick(int i) async {
    final id = StaffFlow.currentId;
    if (id == null || i == range) return;
    final seq = token = (token ?? 0) + 1;
    final previous = range;
    setState(() => range = i);
    try {
      final r = await merchantApi.staff('records', {'id': id, 'range': _ranges[i]});
      if (!mounted || seq != token) return;
      setState(() => records = r);
    } catch (e) {
      if (!mounted || seq != token) return;
      setState(() => range = previous);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '施工记录',
    load: _load,
    builder: (_, d) => StaffRecordsTemplate(d: d, r: records!, range: range, onRange: _pick),
  );
}
"""
    save('staff_records_template.dart', d)


# ───────────── 角色权限 ─────────────
def permissions():
    import re
    d = load('role_permission_page.dart')
    old = 'RolePermissionPage'
    d.rep(
        f"class {old} extends StatelessWidget {{\n  const {old}({{super.key}});\n\n  @override\n  Widget build(BuildContext context) {{\n    return ",
        "class RolePermissionTemplate extends StatefulWidget {\n  final Map<String, dynamic> d;\n  const RolePermissionTemplate({super.key, required this.d});\n\n"
        "  @override\n  State<RolePermissionTemplate> createState() => _RolePermissionTemplateState();\n}\n\n"
        "class _RolePermissionTemplateState extends State<RolePermissionTemplate> {\n"
        "  static const roles = ['manager', 'cashier', 'technician'];\n"
        "  static const keys = ['order_view_own', 'order_view_all', 'progress_update', 'cashier', 'member_view', "
        "'member_recharge_refund', 'stock_use', 'stock_manage', 'perf_view_own', 'stats_view_store'];\n"
        "  late String role = StaffFlow.permissionRole;\n"
        "  late final Map<String, Map<String, bool>> edits = {\n"
        "    for (final r in roles)\n"
        "      r: {for (final k in keys) k: ((widget.d['permissions'] as Map?)?[r] as Map?)?[k] == true},\n  };\n"
        "  final Set<String> dirty = {};\n\n"
        "  bool on(String k) => edits[role]![k] ?? false;\n\n"
        "  void set(String k, bool v) {\n"
        "    if (role == 'manager') {\n      AppToast.show(context, '店长权限固定为全部，不能修改');\n      return;\n    }\n"
        "    setState(() {\n      edits[role]![k] = v;\n      dirty.add(role);\n    });\n  }\n\n"
        "  Future<void> save() async {\n"
        "    try {\n"
        "      for (final r in dirty) {\n        await StaffFlow.savePermissions(r, edits[r]!);\n      }\n"
        "      if (mounted) openRoute(context, 'Staff');\n"
        "    } catch (e) {\n      if (mounted) AppToast.error(context, e);\n    }\n  }\n\n"
        "  @override\n  Widget build(BuildContext context) {\n"
        "    final d = widget.d;\n"
        "    final count = [for (final s in (d['staff'] as List? ?? const [])) if ((s as Map)['role'] == role && s['status'] != 'disabled') s].length;\n"
        "    return ",
    )
    d.rep("groups: [\n                      ({2}, false),\n                    ],",
          "groups: [\n                      ({roles.indexOf(role)}, false),\n                    ],\n                    onSelect: {0: (i) => setState(() => role = roles[i])},")
    d.rep("'修改后对该角色的 5 名员工立即生效',", "'修改后对该角色的 $count 名员工立即生效',")
    # 10 个开关按设计稿顺序依次对应 10 项权限
    keys = ['order_view_own', 'order_view_all', 'progress_update', 'cashier', 'member_view',
            'member_recharge_refund', 'stock_use', 'stock_manage', 'perf_view_own', 'stats_view_store']
    it = iter(keys)
    d.s, n = re.subn(r"HSwitch\(initial: (?:true|false)\)",
                     lambda m: f"HSwitchValue(value: on('{(k := next(it))}'), onChanged: (v) => set('{k}', v))", d.s)
    assert n == 10, n
    busy(d, "'保存',", 'RolePermission>Staff')
    d.rep("to: 'Staff',", "onTap: " + "() => runBusy('RolePermission>Staff', save)" + ",")
    d.s += """
/// 角色权限（设计稿 RolePermission）：逐店读取并保存角色权限开关，店长固定为全部。
class RolePermissionLivePage extends StatelessWidget {
  const RolePermissionLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '角色权限',
    needsId: false,
    load: (_) => merchantApi.staff('list'),
    builder: (_, d) => RolePermissionTemplate(d: d),
  );
}
"""
    save('role_permission_template.dart', d)


PAGES = ['enable', 'disable', 'transfer', 'invite', 'detail_off', 'detail', 'commission', 'records', 'permissions']

if __name__ == '__main__':
    for name in sys.argv[1:] or PAGES:
        globals()[name]()
        print('ok', name)
