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
  pro('专业版'),
  flagship('旗舰版');

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
  final List<String> attachments;
  Msg(this.fromMerchant, this.text, [this.attachments = const []]);
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
        .map(
          (m) => Msg(
            m['from_merchant'] as bool,
            m['text'] as String,
            (m['attachments'] as List? ?? const []).cast<String>(),
          ),
        )
        .toList(),
  );
}

/// 短信记录里的一条短信（验证码或通知）。验证码明文与手机号不脱敏，仅超级管理员可见。
class SmsLog {
  final String id;
  final String phone; // 数据库里是 +86 开头
  final String purpose;
  final String kind; // code | notice
  final String? code;
  final String content;
  final String provider;
  final String signName;
  final String status; // pending | sent | failed
  final String error;
  final int attempts;
  final String storeName;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? expiresAt;
  final DateTime? consumedAt;
  const SmsLog({
    required this.id,
    required this.phone,
    required this.purpose,
    required this.kind,
    required this.code,
    required this.content,
    required this.provider,
    required this.signName,
    required this.status,
    required this.error,
    required this.attempts,
    required this.storeName,
    required this.createdAt,
    required this.sentAt,
    required this.expiresAt,
    required this.consumedAt,
  });
  factory SmsLog.fromJson(Map j) {
    DateTime? time(dynamic v) =>
        v == null ? null : DateTime.parse(v as String).toUtc();
    return SmsLog(
      id: j['id'] as String,
      phone: j['phone'] as String,
      purpose: j['purpose'] as String,
      kind: j['kind'] as String,
      code: j['code'] as String?,
      content: j['content'] as String? ?? '',
      provider: j['provider'] as String? ?? '',
      signName: j['sign_name'] as String? ?? '',
      status: j['status'] as String,
      error: j['error'] as String? ?? '',
      attempts: j['attempts'] as int? ?? 0,
      storeName: j['store_name'] as String? ?? '',
      createdAt: DateTime.parse(j['created_at'] as String).toUtc(),
      sentAt: time(j['sent_at']),
      expiresAt: time(j['expires_at']),
      consumedAt: time(j['consumed_at']),
    );
  }

  bool get isCode => kind == 'code';
  bool get failed => status == 'failed';

  /// `+8613800137712` → `138 0013 7712`，手机号不脱敏。
  String get phoneText {
    final d = phone.replaceAll(RegExp(r'\D'), '');
    final n = d.length >= 11 ? d.substring(d.length - 11) : d;
    return n.length == 11
        ? '${n.substring(0, 3)} ${n.substring(3, 7)} ${n.substring(7)}'
        : n;
  }

  String get purposeLabel => switch (purpose) {
    'login' => '登录验证码',
    'register' => '注册验证码',
    'reset_password' => '找回密码验证码',
    'change_phone_old' || 'change_phone_new' => '换绑手机号验证码',
    'delete_account' => '注销账号验证码',
    _ => isCode ? '验证码' : '通知',
  };

  String get scene => switch (purpose) {
    'login' => '登录 · 验证码登录',
    'register' => '注册 · 开通账号',
    'reset_password' => '找回密码 · 重置密码',
    'change_phone_old' => '账号与安全 · 更换手机号（当前号码）',
    'change_phone_new' => '账号与安全 · 更换手机号（新号码）',
    'delete_account' => '账号与安全 · 注销账号',
    _ => purpose,
  };

  String get channelText => provider.isEmpty
      ? '—'
      : '${switch (provider) {
          'zhutong' => '助通短信',
          _ => provider,
        }}${signName.isEmpty ? '' : ' · 签名「$signName」'}';

  /// 当前还可使用：发送成功、没用过、没过期、错误次数没超限。
  bool usable(DateTime now) =>
      isCode &&
      status == 'sent' &&
      consumedAt == null &&
      attempts < 5 &&
      expiresAt != null &&
      expiresAt!.isAfter(now);

  /// 验证状态（详情页）。
  String verifyText(DateTime now) {
    if (!isCode || status != 'sent') return '—';
    if (consumedAt != null) return '已使用';
    if (attempts >= 5) return '错误次数过多';
    if (expiresAt != null && !expiresAt!.isAfter(now)) return '已过期';
    return '未使用';
  }

  /// 列表第三行 / 详情卡片副标题。
  String lifeText(DateTime now) {
    if (status == 'failed') return '';
    if (status == 'pending') return '发送中';
    if (!isCode) return storeName;
    if (consumedAt != null) return '已使用';
    if (attempts >= 5) return '错误次数过多';
    final left = expiresAt?.difference(now) ?? Duration.zero;
    if (left <= Duration.zero) return '已过期';
    return '5 分钟内有效，剩余 ${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  /// 北京时间 HH:mm。
  String get timeText {
    final d = beijingDate(createdAt.toIso8601String());
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String full(DateTime? t) {
    if (t == null) return '—';
    final d = beijingDate(t.toIso8601String());
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

/// 一页短信记录与翻页游标。
class SmsPage {
  final List<SmsLog> items;
  final bool more;
  final int failedCount;
  const SmsPage(this.items, this.more, this.failedCount);
}

/// 用户账号（老板与员工）：一个登录用户，可以有多个门店身份。
class UserIdentity {
  final String role; // owner | manager | cashier | technician
  final String storeName;
  final DateTime? joinedOn;
  const UserIdentity(this.role, this.storeName, this.joinedOn);
  factory UserIdentity.fromJson(Map j) => UserIdentity(
    j['role'] as String,
    j['store_name'] as String? ?? '',
    j['joined_on'] == null ? null : DateTime.parse(j['joined_on'] as String),
  );
}

String userRoleLabel(String role) => switch (role) {
  'owner' => '老板',
  'manager' => '店长',
  'cashier' => '前台',
  _ => '技师',
};

class UserEvent {
  final String text;
  final DateTime at;
  final String by;
  const UserEvent(this.text, this.at, this.by);
}

class UserAccount {
  final String id;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final String phone; // 11 位，不脱敏
  final String name;
  final String role;
  final List<UserIdentity> identities;
  final bool frozen;
  final DateTime? deleteRequestedAt;
  final DateTime? cancelledAt;
  final String cancelSource;
  final String cancelReason;
  final String cancelNote;
  final String status; // active | cooling | cancelled | frozen
  const UserAccount({
    required this.id,
    required this.createdAt,
    required this.lastSignInAt,
    required this.phone,
    required this.name,
    required this.role,
    required this.identities,
    required this.frozen,
    required this.deleteRequestedAt,
    required this.cancelledAt,
    required this.cancelSource,
    required this.cancelReason,
    required this.cancelNote,
    required this.status,
  });
  factory UserAccount.fromJson(Map j) {
    DateTime? time(dynamic v) =>
        v == null ? null : DateTime.parse(v as String).toUtc();
    return UserAccount(
      id: j['user_id'] as String,
      createdAt: DateTime.parse(j['created_at'] as String).toUtc(),
      lastSignInAt: time(j['last_sign_in_at']),
      phone: j['phone'] as String? ?? '',
      name: j['name'] as String? ?? '',
      role: j['role'] as String? ?? 'technician',
      identities: ((j['identities'] as List?) ?? const [])
          .cast<Map>()
          .map(UserIdentity.fromJson)
          .toList(),
      frozen: j['frozen'] == true,
      deleteRequestedAt: time(j['delete_requested_at']),
      cancelledAt: time(j['cancelled_at']),
      cancelSource: j['cancel_source'] as String? ?? '',
      cancelReason: j['cancel_reason'] as String? ?? '',
      cancelNote: j['cancel_note'] as String? ?? '',
      status: j['status'] as String,
    );
  }

  /// `13800137712` → `138 0013 7712`，手机号不脱敏。
  String get phoneText => phone.length == 11
      ? '${phone.substring(0, 3)} ${phone.substring(3, 7)} ${phone.substring(7)}'
      : phone;

  /// 头像和详情里的姓名脱敏：`刘**`。
  String get maskedName =>
      name.isEmpty ? '—' : '${String.fromCharCode(name.runes.first)}**';
  String get initial =>
      name.isEmpty ? '—' : String.fromCharCode(name.runes.first);
  String get roleLabel => userRoleLabel(role);

  /// 列表第二行：店名（老板多店显示数量），多身份员工显示「另有 N 个身份」。
  String get summary {
    if (identities.isEmpty) return '';
    final first = identities.first.storeName;
    if (role == 'owner') {
      final owned = identities.where((i) => i.role == 'owner').length;
      return owned > 1 ? '$first · $owned 家店' : first;
    }
    return identities.length > 1 ? '另有 ${identities.length - 1} 个身份' : first;
  }

  /// 冷静期到期时间：申请后 15 天。
  DateTime? get coolingEndsAt => deleteRequestedAt?.add(const Duration(days: 15));
  int coolingDaysLeft(DateTime now) {
    final end = coolingEndsAt;
    if (end == null) return 0;
    final left = end.difference(now);
    return left.isNegative ? 0 : (left.inHours / 24).ceil();
  }
}

class UserDetail {
  final UserAccount account;
  final int devices;
  final List<UserEvent> events;
  final int openHolds;
  final int openAppointments;
  const UserDetail(
    this.account,
    this.devices,
    this.events,
    this.openHolds,
    this.openAppointments,
  );
  int get openTotal => openHolds + openAppointments;
}

class UserPage {
  final List<UserAccount> items;
  final bool more;
  final int total, cooling, cancelled, frozen;
  const UserPage(
    this.items,
    this.more,
    this.total,
    this.cooling,
    this.cancelled,
    this.frozen,
  );
}
