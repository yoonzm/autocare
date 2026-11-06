/// Server clock with elapsed time since the last successful snapshot.
DateTime? serverNow;
DateTime? serverClockReadAt;
DateTime get kNow => serverNow == null
    ? DateTime.now().toUtc()
    : serverNow!.add(DateTime.now().toUtc().difference(serverClockReadAt!));
DateTime beijingDate(String value) {
  final d = DateTime.parse(value).toUtc().add(const Duration(hours: 8));
  return DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second);
}

String md(DateTime d) => '${d.month}月${d.day}日';
String percentLabel(dynamic value, {bool change = false}) {
  if (value is! num) return '—';
  return change ? '${value >= 0 ? '↑ +' : '↓ '}${value.abs()}%' : '$value%';
}

String dotted(DateTime value) {
  final d = value.isUtc ? value.add(const Duration(hours: 8)) : value;
  return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

String money(num v, {bool decimals = false}) {
  final parts = v.abs().toStringAsFixed(2).split('.');
  final s = parts[0];
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  final fraction = decimals || parts[1] != '00' ? '.${parts[1]}' : '';
  return '${v < 0 ? '-' : ''}¥$b$fraction';
}

enum Role {
  superAdmin('超级管理员'),
  ops('运营');

  final String label;
  const Role(this.label);
}

class Account {
  final String id;
  String name;
  final String username;
  Role role;
  bool enabled;
  bool mustChange; // 首次登录 / 被重置后必须修改密码
  Account({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.enabled = true,
    this.mustChange = false,
  });
  factory Account.fromJson(Map j) => Account(
    id: j['id'] as String,
    name: j['name'] as String,
    username: j['username'] as String,
    role: Role.values.byName(j['role'] as String),
    enabled: j['enabled'] as bool,
    mustChange: j['must_change'] as bool,
  );
}

enum PlanKind {
  trial('试用版'),
  basic('基础版'),
  pro('专业版');

  final String label;
  const PlanKind(this.label);
}

class PlanInfo {
  final PlanKind kind;
  String name;
  int fee; // 年费（元）；试用版为 0
  int trialDays;
  int? staffLimit; // null = 不限
  bool sms;
  bool export;
  bool multiStore;
  int merchants; // 在用商家数基数
  PlanInfo({
    required this.kind,
    required this.name,
    required this.fee,
    this.trialDays = 14,
    this.staffLimit,
    this.sms = false,
    this.export = false,
    this.multiStore = false,
    required this.merchants,
  });
  factory PlanInfo.fromJson(Map j) => PlanInfo(
    kind: PlanKind.values.byName(j['kind'] as String),
    name: j['name'] as String,
    fee: (j['fee'] as num).round() ~/ 100,
    trialDays: j['trial_days'] as int,
    staffLimit: j['staff_limit'] as int?,
    sms: j['sms'] as bool,
    export: j['export'] as bool,
    multiStore: j['multi_store'] as bool,
    merchants: j['merchants'] as int,
  );
}

class FollowLog {
  final DateTime date;
  final String who;
  final String text;
  FollowLog(this.date, this.who, this.text);
}

enum MStatus {
  paid('已付费'),
  trial('试用中'),
  expired('已到期');

  final String label;
  const MStatus(this.label);
}

class Merchant {
  final String id;
  final String name;
  final String city;
  final String owner; // 店主姓
  final String phone;
  PlanKind plan;
  DateTime expiry;
  final DateTime opened;
  int? staff;
  int members;
  num paidTotal;
  int monthOrders;
  final int tone;
  bool frozen;
  bool paused;
  final List<FollowLog> logs;
  Merchant({
    required this.id,
    required this.name,
    required this.city,
    required this.owner,
    required this.phone,
    required this.plan,
    required this.expiry,
    required this.opened,
    this.staff,
    this.members = 0,
    this.paidTotal = 0,
    this.monthOrders = 0,
    this.tone = 0,
    this.frozen = false,
    this.paused = false,
    List<FollowLog>? logs,
  }) : logs = logs ?? [];
  factory Merchant.fromJson(Map j) => Merchant(
    id: j['id'] as String,
    name: j['name'] as String,
    city: j['city'] as String,
    owner: j['owner'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    plan: PlanKind.values.byName(j['plan'] as String),
    expiry: DateTime.parse(j['expiry'] as String).toUtc(),
    opened: beijingDate(j['opened'] as String),
    staff: j['staff'] as int?,
    members: j['members'] as int,
    paidTotal: j['paid_total'] as num,
    monthOrders: j['month_orders'] as int,
    frozen: j['frozen'] as bool,
    paused: j['paused'] as bool,
    logs: (j['logs'] as List)
        .cast<Map>()
        .map(
          (l) => FollowLog(
            beijingDate(l['date'] as String),
            l['who'] as String,
            l['text'] as String,
          ),
        )
        .toList(),
  );

  int get daysLeft {
    final d = expiry.difference(kNow).inSeconds / 86400;
    return d < 0 ? d.floor() : d.ceil();
  }

  MStatus get status => !expiry.isAfter(kNow)
      ? MStatus.expired
      : plan == PlanKind.trial
      ? MStatus.trial
      : MStatus.paid;
  String get maskedPhone {
    final p = phone.replaceFirst('+86', '');
    return p.length == 11 ? '${p.substring(0, 3)}****${p.substring(7)}' : '—';
  }

  String get maskedOwner => owner.isEmpty ? '—' : '${owner.substring(0, 1)}*';
  String get short => name.split(' · ').first;
}

class Order {
  final String id;
  final String merchant;
  final PlanKind plan;
  final String cycle; // 年付 / 补差价
  final DateTime time;
  final num original;
  final num coupon;
  final String pay;
  final String period;
  num refunded;
  Order({
    required this.id,
    required this.merchant,
    required this.plan,
    this.cycle = '年付',
    required this.time,
    required this.original,
    this.coupon = 0,
    this.pay = '微信支付',
    required this.period,
    this.refunded = 0,
  });
  factory Order.fromJson(Map j) => Order(
    id: j['id'] as String,
    merchant: j['merchant'] as String,
    plan: PlanKind.values.byName(j['plan'] as String),
    cycle: j['cycle'] as String,
    time: beijingDate(j['time'] as String),
    original: j['original'] as num,
    coupon: j['coupon'] as num,
    refunded: j['refunded'] as num,
    pay: j['pay'] as String,
    period:
        '${dotted(beijingDate(j['starts_at'] as String))} – ${dotted(beijingDate(j['ends_at'] as String))}',
  );
  num get paid => original - coupon;
  bool get isRefunded => refunded > 0;
  String get title => '${plan.label}$cycle';
}

enum TStatus {
  todo('待处理'),
  doing('处理中'),
  done('已解决');

  final String label;
  const TStatus(this.label);
}

class Msg {
  final bool fromMerchant;
  final String text;
  Msg(this.fromMerchant, this.text);
}

class Ticket {
  final String id;
  final String title;
  final String merchant;
  final String when;
  final String owner;
  TStatus status;
  final List<Msg> msgs;
  Ticket({
    required this.id,
    required this.title,
    required this.merchant,
    required this.when,
    required this.owner,
    required this.status,
    required this.msgs,
  });
  factory Ticket.fromJson(Map j) => Ticket(
    id: j['id'] as String,
    title: j['title'] as String,
    merchant: j['merchant'] as String,
    when: md(beijingDate(j['time'] as String)),
    owner: j['owner'] as String,
    status: TStatus.values.byName(j['status'] as String),
    msgs: (j['msgs'] as List)
        .cast<Map>()
        .map((m) => Msg(m['from_merchant'] as bool, m['text'] as String))
        .toList(),
  );
}
