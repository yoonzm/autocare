import 'package:flutter/foundation.dart';

import 'models.dart';

/// 演示用的全局状态：所有数据都在内存里，操作后即时联动各页面。
class Store extends ChangeNotifier {
  Store() {
    reset();
  }

  static const demoPassword = 'admin123';
  static const demoCode = '123456';

  late List<Account> accounts;
  late List<Merchant> merchants;
  late List<Order> orders;
  late List<Review> reviews;
  late List<Ticket> tickets;
  late List<PlanInfo> plans;
  final List<String> audit = [];
  Account? me;

  // 订阅收入基数（元）：本月订阅 / 增值 / 退款
  static const _addonBase = 13940;
  static const _refundBase = 800;
  static const _subsBase = 68420;
  List<int> history = [52000, 64000, 60000, 78000, 88000];

  bool get isSuper => me?.role == Role.superAdmin;

  void reset() {
    me = null;
    audit.clear();
    accounts = [
      Account(
        id: 'a1',
        name: '王主管',
        email: 'wang@chiguang.example',
        role: Role.superAdmin,
      ),
      Account(
        id: 'a2',
        name: '运营小李',
        email: 'ops@chiguang.example',
        role: Role.ops,
      ),
      Account(
        id: 'a3',
        name: '赵运营',
        email: 'zhao@chiguang.example',
        role: Role.ops,
      ),
      Account(
        id: 'a4',
        name: '张运营',
        email: 'zhang@chiguang.example',
        role: Role.ops,
        enabled: false,
      ),
    ];
    plans = [
      PlanInfo(
        kind: PlanKind.pro,
        name: '专业版',
        fee: 1199,
        sms: true,
        export: true,
        multiStore: true,
        merchants: 128,
      ),
      PlanInfo(
        kind: PlanKind.basic,
        name: '基础版',
        fee: 599,
        staffLimit: 5,
        merchants: 184,
      ),
      PlanInfo(
        kind: PlanKind.trial,
        name: '试用版',
        fee: 0,
        trialDays: 14,
        staffLimit: 5,
        merchants: 48,
      ),
    ];
    merchants = _seedMerchants();
    orders = _seedOrders();
    reviews = _seedReviews();
    tickets = _seedTickets();
    notifyListeners();
  }

  // ───────── 登录与账号 ─────────
  String? checkCredentials(String email, String pw) {
    final e = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) return '请输入正确的工作邮箱';
    if (pw.isEmpty) return '请输入密码';
    final a = accounts.where((a) => a.email == e).firstOrNull;
    if (a == null || pw != demoPassword) return '邮箱或密码错误';
    if (!a.enabled) return '该账号已被禁用，请联系超级管理员';
    return null;
  }

  void signIn(String email) {
    me = accounts.firstWhere((a) => a.email == email.trim().toLowerCase());
    _log('登录');
    notifyListeners();
  }

  void signOut() {
    _log('退出登录');
    me = null;
    notifyListeners();
  }

  String? addAccount(String name, String email, Role role) {
    final n = name.trim();
    final e = email.trim().toLowerCase();
    if (n.isEmpty) return '请输入姓名';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) return '请输入正确的工作邮箱';
    if (accounts.any((a) => a.email == e)) return '该邮箱已存在账号';
    accounts.add(
      Account(id: 'a${accounts.length + 1}', name: n, email: e, role: role),
    );
    _log('新增运营账号 $n（${role.label}）');
    notifyListeners();
    return null;
  }

  void setRole(Account a, Role r) {
    a.role = r;
    _log('将 ${a.name} 设为${r.label}');
    notifyListeners();
  }

  void setEnabled(Account a, bool v) {
    a.enabled = v;
    _log('${v ? '启用' : '禁用'}账号 ${a.name}');
    notifyListeners();
  }

  void resetPassword(Account a) => _log('重置 ${a.name} 的密码');

  void _log(String s) => audit.add('${me?.name ?? '系统'} · $s');

  // ───────── 商家 ─────────
  List<Merchant> byStatus(MStatus? s) =>
      s == null ? merchants : merchants.where((m) => m.status == s).toList();

  /// 需要跟进的商家：已到期 / 7 日内 / 30 日内（累计）。
  List<Merchant> followUps(int tab) {
    final l = merchants.where((m) {
      final d = m.daysLeft;
      return switch (tab) {
        0 => d < 0,
        1 => d >= 0 && d <= 7,
        _ => d >= 0 && d <= 30,
      };
    }).toList()..sort((a, b) => a.expiry.compareTo(b.expiry));
    return l;
  }

  int get expiring7 => followUps(1).length;

  /// 付费 / 试用数以平台基数为准，叠加本次演示中的变化。
  int get paidCount => 312 + _delta(MStatus.paid);
  int get trialCount => 48 + _delta(MStatus.trial);
  late final Map<MStatus, int> _seedCount = {
    for (final s in MStatus.values) s: _seedMerchants().where((m) => m.status == s).length,
  };
  int _delta(MStatus s) => byStatus(s).length - _seedCount[s]!;

  int get weekNew => 12 + reviews.where((r) => r.status == RStatus.approved).length - 2;

  void addLog(Merchant m, String text) {
    m.logs.insert(0, FollowLog(kNow, me?.name ?? '运营', text.trim()));
    _log('跟进 ${m.short}');
    notifyListeners();
  }

  /// 调整套餐。返回给用户的提示语。
  String adjust(Merchant m, int option) {
    switch (option) {
      case 0:
        m.expiry = (m.daysLeft < 0 ? kNow : m.expiry).add(const Duration(days: 7));
        _log('${m.short} 赠送 7 天');
        notifyListeners();
        return '已延长 7 天，新到期日 ${dotted(m.expiry)}';
      case 1:
        final pro = plans.firstWhere((p) => p.kind == PlanKind.pro);
        final basic = plans.firstWhere((p) => p.kind == PlanKind.basic);
        final diff = m.plan == PlanKind.basic ? pro.fee - basic.fee : pro.fee;
        orders.insert(
          0,
          Order(
            id: 'SUB-20261031-${(43 + orders.length - 5).toString().padLeft(4, '0')}',
            merchant: m.name,
            plan: PlanKind.pro,
            cycle: m.plan == PlanKind.basic ? '补差价' : '年付',
            time: DateTime(2026, 10, 31, 16, 8),
            original: diff,
            pay: '线下转账',
            fresh: true,
            period: m.plan == PlanKind.basic
                ? '${dotted(kNow)} – ${dotted(m.expiry)}'
                : '${dotted(kNow)} – ${dotted(kNow.add(const Duration(days: 364)))}',
          ),
        );
        if (m.plan != PlanKind.basic) {
          m.expiry = kNow.add(const Duration(days: 364));
        }
        m.plan = PlanKind.pro;
        m.paidTotal += diff;
        _log('${m.short} 升级到专业版，补缴 ¥$diff');
        notifyListeners();
        return '已升级到专业版，补缴 ${money(diff)}';
      default:
        m.paused = !m.paused;
        _log('${m.short} ${m.paused ? '暂停' : '恢复'}服务');
        notifyListeners();
        return m.paused ? '已暂停服务' : '已恢复服务';
    }
  }

  String account(Merchant m, int option) {
    switch (option) {
      case 0:
        _log('${m.short} 重发验证码');
        return '验证码已发送至 ${m.maskedPhone}';
      case 1:
        _log('${m.short} 重置登录状态');
        return '已退出所有设备';
      default:
        m.frozen = !m.frozen;
        _log('${m.short} ${m.frozen ? '冻结' : '解冻'}');
        notifyListeners();
        return m.frozen ? '商家账号已冻结' : '商家账号已解冻';
    }
  }

  // ───────── 开通审核 ─────────
  int get pendingReviews =>
      reviews.where((r) => r.status == RStatus.pending).length;

  void approve(Review r) {
    r.status = RStatus.approved;
    final trial = r.plan == PlanKind.trial;
    merchants.insert(
      0,
      Merchant(
        id: 'm${merchants.length + 1}',
        name: r.name,
        city: r.city,
        owner: r.owner,
        phone: r.phone,
        plan: r.plan,
        expiry: trial
            ? kNow.add(Duration(days: plans.last.trialDays))
            : kNow.add(const Duration(days: 364)),
        opened: kNow,
        staff: 1,
        tone: merchants.length % 4,
      ),
    );
    _log('通过 ${r.name} 开通申请');
    notifyListeners();
  }

  void reject(Review r, String reason) {
    r.status = RStatus.rejected;
    r.reason = reason;
    _log('驳回 ${r.name} 开通申请：$reason');
    notifyListeners();
  }

  // ───────── 订阅与收入 ─────────
  int get subsRevenue =>
      _subsBase + orders.where((o) => o.fresh).fold<int>(0, (s, o) => s + o.paid);
  int get addonRevenue => _addonBase;
  int get _refunded => orders.fold<int>(0, (s, o) => s + o.refunded);
  int get refundTotal => _refundBase + _refunded;
  int get monthRevenue => subsRevenue + addonRevenue - _refunded;

  String? refund(Order o, String input) {
    final v = int.tryParse(input.trim());
    if (v == null || v <= 0) return '请输入退款金额';
    if (v > o.paid) return '退款金额不能超过实付 ${money(o.paid)}';
    o.refunded = v;
    _log('退款 ${o.id} ${money(v)}');
    notifyListeners();
    return null;
  }

  // ───────── 工单 ─────────
  int get todoTickets => tickets.where((t) => t.status == TStatus.todo).length;

  void reply(Ticket t, String text) {
    t.msgs.add(Msg(false, text.trim()));
    if (t.status == TStatus.todo) t.status = TStatus.doing;
    _log('回复工单 ${t.title}');
    notifyListeners();
  }

  void resolve(Ticket t) {
    t.status = TStatus.done;
    _log('解决工单 ${t.title}');
    notifyListeners();
  }

  // ───────── 套餐 ─────────
  String? savePlan(
    PlanInfo p, {
    required String name,
    required String fee,
    required String staff,
    required bool sms,
    required bool export,
    required bool multi,
  }) {
    if (name.trim().isEmpty) return '请输入套餐名称';
    final f = int.tryParse(fee.trim());
    if (f == null || f < 0) return p.kind == PlanKind.trial ? '请输入试用天数' : '请输入年费';
    int? s;
    if (staff.trim().isNotEmpty) {
      s = int.tryParse(staff.trim());
      if (s == null || s <= 0) return '员工数上限需为正整数，留空表示不限';
    }
    p.name = name.trim();
    if (p.kind == PlanKind.trial) {
      p.trialDays = f;
    } else {
      p.fee = f;
    }
    p.staffLimit = s;
    p.sms = sms;
    p.export = export;
    p.multiStore = multi;
    _log('修改套餐 ${p.name}');
    notifyListeners();
    return null;
  }
}

final store = Store();

// ───────── 种子数据 ─────────
DateTime _d(int m, int d, [int y = 2026]) => DateTime(y, m, d);

List<Merchant> _seedMerchants() {
  Merchant m(
    String id,
    String name,
    String city,
    String owner,
    String phone,
    PlanKind plan,
    DateTime expiry, {
    int tone = 0,
    int staff = 3,
    int members = 200,
    int paid = 599,
    int orders = 80,
    List<FollowLog>? logs,
    DateTime? opened,
  }) => Merchant(
    id: id,
    name: name,
    city: city,
    owner: owner,
    phone: phone,
    plan: plan,
    expiry: expiry,
    opened: opened ?? _d(3, 12, 2026),
    tone: tone,
    staff: staff,
    members: members,
    paidTotal: paid,
    monthOrders: orders,
    logs: logs,
  );
  FollowLog log(int mo, int d, String t, [String who = '运营小李']) =>
      FollowLog(_d(mo, d), who, t);
  return [
    m('m1', '驰光汽车美容 · 徐汇店', '上海', '陈', '13955205520', PlanKind.pro,
        _d(3, 31, 2027), tone: 1, staff: 6, members: 1284, paid: 3588, orders: 326,
        opened: _d(4, 2, 2025)),
    m('m2', '极速洗护 · 浦东店', '上海', '周', '13833913391', PlanKind.trial,
        _d(11, 6), tone: 0, staff: 2, members: 36, paid: 0, orders: 12),
    m('m3', '车安心养护', '苏州', '吴', '13712348899', PlanKind.basic, _d(10, 12),
        tone: 2, staff: 4, members: 420, paid: 1198, orders: 0, logs: [
          log(10, 28, '电话沟通，店主考虑中，下周再联系'),
          log(10, 20, '微信提醒套餐即将到期'),
        ]),
    m('m4', '蓝鲸汽车美容', '杭州', '林', '13655027788', PlanKind.basic, _d(11, 3),
        tone: 3, members: 530, paid: 1198, orders: 96,
        logs: [log(10, 29, '电话沟通，已发续费优惠')]),
    m('m5', '悦驰养护中心', '南京', '许', '13988245521', PlanKind.basic, _d(10, 30, 2027),
        tone: 1, staff: 5, members: 310, paid: 599, orders: 58,
        opened: _d(10, 30)),
    m('m6', '星河车管家', '广州', '黄', '13522087766', PlanKind.basic, _d(11, 5),
        tone: 2, members: 245, paid: 599, orders: 41),
    m('m7', '速亮洗车', '武汉', '孙', '13477031290', PlanKind.trial, _d(11, 2),
        tone: 0, staff: 2, members: 18, paid: 0, orders: 6),
    m('m8', '金盾养护', '西安', '马', '13299176655', PlanKind.basic, _d(11, 4),
        tone: 3, members: 380, paid: 1198, orders: 73),
    m('m9', '铂爵汽车会所', '深圳', '郑', '13811229034', PlanKind.pro, _d(11, 7),
        tone: 1, staff: 9, members: 1560, paid: 2398, orders: 210),
    m('m10', '老周汽修美容', '成都', '周', '13708831422', PlanKind.pro, _d(11, 6),
        tone: 2, staff: 7, members: 890, paid: 1199, orders: 150),
    m('m11', '车管家小王', '长沙', '王', '13566107788', PlanKind.trial, _d(10, 20),
        tone: 0, staff: 1, members: 9, paid: 0, orders: 0),
    m('m12', '驰骋美容', '郑州', '韩', '13400125566', PlanKind.basic, _d(10, 25),
        tone: 3, members: 160, paid: 599, orders: 0),
    for (var i = 0; i < 8; i++)
      m(
        'm${13 + i}',
        const ['净界洗护', '蓝海汽车护理', '尚车坊', '锐驰美容', '宝骏养护', '车贝贝', '洁驰汽车服务', '优驾美容'][i],
        const ['天津', '青岛', '宁波', '厦门', '福州', '合肥', '济南', '南昌'][i],
        const ['刘', '杨', '赵', '钱', '孙', '李', '朱', '何'][i],
        '137${(10000000 + i * 1371113).toString().padLeft(8, '0')}',
        i.isEven ? PlanKind.basic : (i % 3 == 1 ? PlanKind.pro : PlanKind.trial),
        _d(11, 9 + i * 3),
        tone: i % 4,
        members: 50 + i * 40,
        paid: i % 3 == 2 ? 0 : 599,
        orders: 20 + i * 5,
      ),
    m('m21', '风驰汽车美容', '北京', '谢', '13611002233', PlanKind.pro, _d(8, 15, 2027),
        tone: 1, staff: 8, members: 920, paid: 2398, orders: 188),
    m('m22', '晨光养护', '重庆', '唐', '13922110099', PlanKind.basic, _d(6, 1, 2027),
        tone: 2, members: 270, paid: 599, orders: 64),
  ];
}

List<Order> _seedOrders() => [
  Order(
    id: 'SUB-20261031-0042',
    merchant: '驰光汽车美容 · 徐汇店',
    plan: PlanKind.pro,
    time: DateTime(2026, 10, 31, 14, 20),
    original: 1399,
    coupon: 200,
    period: '2026.10.31 – 2027.10.30',
  ),
  Order(
    id: 'SUB-20261030-0038',
    merchant: '悦驰养护中心',
    plan: PlanKind.basic,
    time: DateTime(2026, 10, 30, 11, 5),
    original: 599,
    period: '2026.10.30 – 2027.10.29',
  ),
  Order(
    id: 'SUB-20261029-0031',
    merchant: '蓝鲸汽车美容',
    plan: PlanKind.basic,
    time: DateTime(2026, 10, 29, 16, 42),
    original: 599,
    pay: '支付宝',
    period: '2026.10.29 – 2027.10.28',
  ),
  Order(
    id: 'SUB-20261028-0027',
    merchant: '星河车管家',
    plan: PlanKind.basic,
    time: DateTime(2026, 10, 28, 9, 30),
    original: 599,
    period: '2026.10.28 – 2027.10.27',
  ),
  Order(
    id: 'SUB-20261027-0022',
    merchant: '老周汽修美容',
    plan: PlanKind.pro,
    time: DateTime(2026, 10, 27, 20, 14),
    original: 1199,
    pay: '支付宝',
    period: '2026.10.27 – 2027.10.26',
  ),
];

List<Review> _seedReviews() => [
  Review(
    id: 'r1',
    name: '极速洗护 · 闵行店',
    city: '上海',
    district: '闵行区',
    owner: '周',
    phone: '13833913391',
    bays: 4,
    plan: PlanKind.trial,
    submitted: DateTime(2026, 10, 31, 9, 12),
  ),
  Review(
    id: 'r2',
    name: '蓝鲸汽车美容 · 西湖店',
    city: '杭州',
    district: '西湖区',
    owner: '林',
    phone: '13655027788',
    bays: 6,
    plan: PlanKind.basic,
    submitted: DateTime(2026, 10, 30, 15, 40),
  ),
  Review(
    id: 'r3',
    name: '悦驰养护中心 · 江宁店',
    city: '南京',
    district: '江宁区',
    owner: '许',
    phone: '13988245521',
    bays: 3,
    plan: PlanKind.trial,
    submitted: DateTime(2026, 10, 30, 10, 3),
  ),
  Review(
    id: 'r4',
    name: '锐驰美容',
    city: '宁波',
    district: '鄞州区',
    owner: '钱',
    phone: '13512340098',
    bays: 5,
    plan: PlanKind.basic,
    submitted: DateTime(2026, 10, 27, 13, 20),
    status: RStatus.approved,
  ),
  Review(
    id: 'r5',
    name: '快修快美',
    city: '无锡',
    district: '新吴区',
    owner: '蒋',
    phone: '13766540021',
    bays: 2,
    plan: PlanKind.trial,
    submitted: DateTime(2026, 10, 26, 8, 55),
    status: RStatus.rejected,
    reason: '营业执照照片不清晰',
  ),
];

List<Ticket> _seedTickets() => [
  Ticket(
    id: 't1',
    title: '无法登录商家端',
    merchant: '驰光汽车美容',
    when: '今天 10:12',
    owner: '陈*',
    status: TStatus.todo,
    msgs: [
      Msg(true, '收不到短信验证码，已重试三次。'),
      Msg(false, '您好，已为您重新发送，请注意查收。'),
      Msg(true, '还是没收到，手机号没变。'),
    ],
  ),
  Ticket(
    id: 't2',
    title: '想开具发票',
    merchant: '悦驰养护中心',
    when: '昨天',
    owner: '许*',
    status: TStatus.doing,
    msgs: [
      Msg(true, '你好，想为 10 月的订阅开具增值税发票。'),
      Msg(false, '好的，请提供开票抬头和税号。'),
    ],
  ),
  Ticket(
    id: 't3',
    title: '员工账号无法绑定',
    merchant: '蓝鲸汽车美容',
    when: '10月29日',
    owner: '林*',
    status: TStatus.todo,
    msgs: [Msg(true, '员工扫码绑定一直提示失败，换了两部手机都一样。')],
  ),
  Ticket(
    id: 't4',
    title: '如何导出会员数据',
    merchant: '极速洗护 · 浦东店',
    when: '10月25日',
    owner: '周*',
    status: TStatus.done,
    msgs: [
      Msg(true, '想把会员导出成表格，在哪里操作？'),
      Msg(false, '在「设置 → 数据备份」里选择导出会员，专业版和基础版都支持。'),
      Msg(true, '找到了，谢谢。'),
    ],
  ),
];
