import 'package:flutter/foundation.dart';

String money(num v, {int digits = 0}) {
  final neg = v < 0;
  final fixed = v.abs().toStringAsFixed(digits);
  final parts = fixed.split('.');
  final buf = StringBuffer();
  final s = parts[0];
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}$buf${parts.length > 1 ? '.${parts[1]}' : ''}';
}

// ───────── 会员 ─────────
class Member {
  final String name, level, plate, lastVisit, amount, amountNote;
  final Set<String> tags;
  final bool bound;
  final String phone;
  const Member(
    this.name,
    this.level,
    this.plate,
    this.lastVisit,
    this.amount,
    this.amountNote,
    this.tags, {
    this.bound = true,
    this.phone = '',
  });
}

const members = <Member>[
  Member('王建国', '黑金', '沪A·8K29M', '今天到店', '¥3,680', '余额', {
    '黑金',
  }, phone: '13816826021'),
  Member('林晓雯', '金卡', '沪AD·61207', '3 天前', '¥1,240', '余额', {
    '金卡',
  }, phone: '13917630412'),
  Member(
    '陈浩',
    '银卡',
    '苏E·3QX18',
    '1 周前',
    '¥520',
    '次卡 3 天到期',
    {'次卡将到期'},
    bound: false,
    phone: '13761885507',
  ),
  Member('赵一鸣', '金卡', '沪B·72M51', '2 周前', '¥2,060', '余额', {
    '金卡',
  }, phone: '13588205126'),
  Member(
    '周志远',
    '银卡',
    '浙A·5L0P2',
    '47 天未到店',
    '¥180',
    '待回访',
    {'待回访'},
    bound: false,
    phone: '13472215908',
  ),
  Member(
    '刘先生',
    '金卡',
    '沪C·9H318',
    '5 天前',
    '¥1,860',
    '余额',
    {'金卡'},
    bound: false,
    phone: '13916885026',
  ),
  Member('周女士', '黑金', '沪A·6Q552', '昨天到店', '¥5,200', '余额', {
    '黑金',
  }, phone: '13701865530'),
];

class Vehicle {
  final String model, plate, note;
  const Vehicle(this.model, this.plate, this.note);
}

class CardPack {
  final String name, expire;
  final int used, total;
  const CardPack(this.name, this.used, this.total, this.expire);
}

class RecordItem {
  final String date, title, desc, amount;
  final bool income;
  const RecordItem(this.date, this.title, this.desc, this.amount, this.income);
}

const memberVehicles = <Vehicle>[
  Vehicle('宝马 5系 525Li · 黑', '沪A·8K29M', '上次保养 10.31 · 里程 32,800 km'),
  Vehicle('理想 L7 · 灰', '沪AF·09316', '车衣质保至 2029.06'),
];

const memberPacks = <CardPack>[
  CardPack('精致洗车年卡', 8, 20, '2027.03.31 到期'),
  CardPack('内饰深度清洁', 2, 6, '12.31 到期'),
];

const memberRecords = <RecordItem>[
  RecordItem('今天', '镀晶养护 · 内饰精洗', '余额支付 · 3 号工位', '-¥1,422', false),
  RecordItem('10.26', '余额充值', '充值 ¥5,000 · 赠 ¥300', '+¥5,300', true),
  RecordItem('10.12', '精致洗车', '次卡抵扣 1 次', '次卡', false),
  RecordItem('09.28', '车身打蜡', '微信支付', '-¥258', false),
];

// ───────── 预约 ─────────
enum ApptStatus { waiting, arrived, late, done }

class Appointment {
  final String time, duration, plate, customer, level, service, station;
  ApptStatus status;
  Appointment(
    this.time,
    this.duration,
    this.plate,
    this.customer,
    this.level,
    this.service,
    this.station,
    this.status,
  );
}

class AppointmentStore extends ChangeNotifier {
  final List<Appointment> items = [
    Appointment(
      '15:30',
      '1.5 小时',
      '苏K·5F218',
      '散客',
      '散客',
      '基础洗车 · 轮毂清洁',
      '2 号工位 · 小陈',
      ApptStatus.arrived,
    ),
    Appointment(
      '16:30',
      '1 小时',
      '沪A·2M118',
      '孙先生',
      '金卡',
      '全车精洗',
      '4 号工位 · 已超时 17 分钟',
      ApptStatus.late,
    ),
    Appointment(
      '17:30',
      '1.5 小时',
      '沪C·9H318',
      '刘先生',
      '金卡',
      '车身打蜡',
      '4 号工位 · 老周',
      ApptStatus.waiting,
    ),
    Appointment(
      '18:00',
      '1.5 小时',
      '沪A·6Q552',
      '周女士',
      '黑金',
      '内饰深度清洁',
      '1 号工位 · 小陈',
      ApptStatus.waiting,
    ),
    Appointment(
      '09:30',
      '1 小时',
      '沪B·3D820',
      '赵女士',
      '金卡',
      '基础洗车',
      '1 号工位 · 小陈',
      ApptStatus.done,
    ),
    Appointment(
      '11:00',
      '1.5 小时',
      '沪A·7L305',
      '陈女士',
      '金卡',
      '内饰精洗',
      '2 号工位 · 老周',
      ApptStatus.done,
    ),
  ];

  void add(Appointment a) {
    items.add(a);
    notifyListeners();
  }

  void setStatus(Appointment a, ApptStatus s) {
    a.status = s;
    notifyListeners();
  }
}

final appointmentStore = AppointmentStore();

class ServiceOption {
  final String name;
  final int price;
  const ServiceOption(this.name, this.price);
}

const apptServices = <ServiceOption>[
  ServiceOption('基础洗车', 68),
  ServiceOption('全车精洗', 168),
  ServiceOption('车身打蜡', 258),
  ServiceOption('内饰深度清洁', 388),
  ServiceOption('镀晶养护', 1280),
  ServiceOption('隐形车衣', 18800),
];

// ───────── 服务项目 ─────────
class ServiceItem {
  final String category, name, desc, tag;
  final int price;
  final String memberNote;
  final bool offline;
  const ServiceItem(
    this.category,
    this.name,
    this.desc,
    this.price, {
    this.tag = '',
    this.memberNote = '',
    this.offline = false,
  });
}

const services = <ServiceItem>[
  ServiceItem(
    '镀晶镀膜',
    '全车镀晶 · 9H 陶瓷',
    '工时 4h · 提成 8% · 绑定耗材 2 项',
    1580,
    memberNote: '会员低至 ¥1,422',
  ),
  ServiceItem(
    '镀晶镀膜',
    '石墨烯镀膜',
    '工时 6h · 提成 8%',
    2680,
    memberNote: '会员低至 ¥2,412',
  ),
  ServiceItem('镀晶镀膜', '漆面抛光', '工时 3h · 提成 ¥60/单', 680, memberNote: '会员低至 ¥612'),
  ServiceItem(
    '洗车',
    '精致洗车',
    '工时 40min · 提成 ¥8/单',
    68,
    tag: '可次卡抵扣',
    memberNote: '本月 412 单',
  ),
  ServiceItem('洗车', '快速洗车', '工时 20min · 提成 ¥4/单', 38, memberNote: '本月 268 单'),
  ServiceItem('洗车', '发动机舱清洗', '工时 30min', 120, tag: '已下架', offline: true),
  ServiceItem(
    '贴膜',
    '全车隐形车衣',
    '工时 2 天 · 提成 6%',
    18800,
    memberNote: '会员低至 ¥16,920',
  ),
  ServiceItem('内饰', '内饰深度清洁', '工时 2h · 提成 ¥40/单', 380, memberNote: '会员低至 ¥342'),
];

// ───────── 库存 ─────────
class Product {
  final String name, unit, category;
  final int stock, safe;
  const Product(this.name, this.category, this.stock, this.unit, this.safe);
  double get ratio => (stock / (safe * 2)).clamp(0.08, 1.0);
}

const products = <Product>[
  Product('TPU 隐形车衣 7.5mil', '贴膜', 2, '卷', 5),
  Product('9H 陶瓷镀晶液 50ml', '镀晶', 6, '瓶', 10),
  Product('中性洗车液 20L', '洗护', 14, '桶', 6),
  Product('超细纤维擦车巾', '洗护', 86, '条', 40),
  Product('改色膜 · 哑光灰', '贴膜', 4, '卷', 3),
  Product('玻璃镀膜剂', '镀晶', 9, '瓶', 8),
  Product('脚垫（通用）', '配件', 3, '套', 6),
];

// ───────── 统计 ─────────
const monthDaily = <double>[
  7.2,
  8.1,
  6.4,
  9.8,
  10.5,
  12.9,
  8.6,
  9.2,
  10.1,
  11.4,
  9.7,
  13.2,
  14.8,
  10.3,
  9.1,
  8.8,
  10.9,
  12.2,
  11.7,
  13.9,
  15.2,
  12.4,
  9.6,
  10.8,
  11.3,
  12.7,
  14.1,
  13.4,
  11.9,
  12.1,
  12.86,
];

class Share {
  final String name;
  final int percent, amount;
  const Share(this.name, this.percent, this.amount);
}

const revenueShares = <Share>[
  Share('镀晶 / 镀膜', 38, 124815),
  Share('车衣 / 改色膜', 27, 88684),
  Share('洗车美容', 18, 59123),
  Share('内饰清洁及其他', 17, 55838),
];

// ───────── 首页 / 开单 ─────────
class WorkJob {
  final String plate, car, station, service, eta, tech;
  final int progress;
  final bool blue;
  const WorkJob(
    this.plate,
    this.car,
    this.station,
    this.service,
    this.eta,
    this.tech,
    this.progress,
    this.blue,
  );
}

const workJobs = <WorkJob>[
  WorkJob(
    '沪A·8K29M',
    '宝马 5系 · 黑',
    '3 号工位',
    '镀晶养护 · 内饰精洗',
    '预计 17:00',
    '周',
    65,
    true,
  ),
  WorkJob(
    '沪AD·61207',
    '特斯拉 Model Y · 白',
    '贴膜间',
    '全车隐形车衣',
    '预计 明天 18:00',
    '张',
    30,
    false,
  ),
];

class OrderService {
  final String name;
  final int price;
  final bool cardCovered; // 次卡可抵扣
  final Set<String> cats;
  const OrderService(
    this.name,
    this.price,
    this.cats, {
    this.cardCovered = false,
  });
}

const orderServices = <OrderService>[
  OrderService('精致洗车', 68, {'常用', '洗车'}, cardCovered: true),
  OrderService('全车镀晶 · 9H 陶瓷', 1580, {'常用', '镀晶镀膜'}),
  OrderService('内饰深度清洁', 380, {'常用', '内饰'}),
  OrderService('轮毂翻新（4 只）', 600, {'常用'}),
  OrderService('快速洗车', 38, {'洗车'}),
  OrderService('发动机舱清洗', 120, {'洗车'}),
  OrderService('漆面抛光', 680, {'镀晶镀膜'}),
  OrderService('石墨烯镀膜', 2680, {'镀晶镀膜'}),
  OrderService('全车隐形车衣', 18800, {'贴膜'}),
  OrderService('局部改色膜', 3200, {'贴膜'}),
  OrderService('座椅深度清洁', 280, {'内饰'}),
];
