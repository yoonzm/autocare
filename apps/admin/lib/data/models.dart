/// 演示用的“当前日期”，与设计稿保持一致（10 月 31 日）。
final kNow = DateTime(2026, 10, 31);

String md(DateTime d) => '${d.month}月${d.day}日';
String dotted(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
String money(num v) {
  final s = v.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}¥$b';
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
  String password;
  Role role;
  bool enabled;
  bool mustChange; // 首次登录 / 被重置后必须修改密码
  Account({
    required this.id,
    required this.name,
    required this.username,
    this.password = 'admin123',
    required this.role,
    this.enabled = true,
    this.mustChange = false,
  });
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
  int staff;
  int members;
  int paidTotal;
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
    this.staff = 3,
    this.members = 0,
    this.paidTotal = 0,
    this.monthOrders = 0,
    this.tone = 0,
    this.frozen = false,
    this.paused = false,
    List<FollowLog>? logs,
  }) : logs = logs ?? [];

  int get daysLeft => expiry.difference(kNow).inDays;
  MStatus get status => daysLeft < 0
      ? MStatus.expired
      : plan == PlanKind.trial
      ? MStatus.trial
      : MStatus.paid;
  String get maskedPhone => '${phone.substring(0, 3)}****${phone.substring(7)}';
  String get maskedOwner => '$owner*';
  String get short => name.split(' · ').first;
}

class Order {
  final String id;
  final String merchant;
  final PlanKind plan;
  final String cycle; // 年付 / 补差价
  final DateTime time;
  final int original;
  final int coupon;
  final String pay;
  final String period;
  int refunded;
  final bool fresh; // 本次演示中新产生的订单
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
    this.fresh = false,
  });
  int get paid => original - coupon;
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
}
