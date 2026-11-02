import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/package_calc.dart' show PackageRowInfo, formatMoney;

/// 当前会员（办卡成功的 / 正在查看的）在生成页里用到的各种文字。
class MemberView {
  final Map<String, dynamic> row;
  const MemberView(this.row);

  Map<String, dynamic> get _card =>
      Map<String, dynamic>.from((row['card'] as Map?) ?? const {});
  List<Map<String, dynamic>> get _vehicles =>
      List<Map<String, dynamic>>.from((row['vehicles'] as List?) ?? const []);

  String get name => '${row['name'] ?? ''}';

  /// 头像上的字：姓氏。
  String get avatar => name.isEmpty ? '' : name.substring(0, 1);

  /// `李女士` / `王先生`；没填称呼时就是全名。
  String get honorificName {
    final h = '${row['honorific'] ?? ''}';
    return h.isEmpty ? name : '$avatar$h';
  }

  String get level => '${_card['name'] ?? ''}';

  /// `黑金卡会员` / `普通会员`（卡种名已带“会员”时不再重复）。
  String get levelMember => level.endsWith('会员') ? level : '$level会员';

  String get maskedPhone {
    final p = '${row['phone'] ?? ''}';
    return p.length == 11 ? '${p.substring(0, 3)} **** ${p.substring(7)}' : p;
  }

  /// `服务原价 · 积分 1 倍` / `服务 9 折 · 积分 2 倍`
  String get benefits {
    final d = num.tryParse('${_card['discount'] ?? 1}') ?? 1;
    final m = num.tryParse('${_card['points_multiplier'] ?? 1}') ?? 1;
    final discount = d >= 1
        ? '服务原价'
        : '服务 ${CatalogDraft.formatNumber(d * 10)} 折';
    return '$discount · 积分 ${CatalogDraft.formatNumber(m)} 倍';
  }

  /// `11月1日 12:02`
  String get openedAt {
    final t = DateTime.tryParse('${row['created_at'] ?? ''}')?.toLocal();
    if (t == null) return '';
    return '${t.month}月${t.day}日 ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  num _num(String k) => num.tryParse('${row[k] ?? 0}') ?? 0;

  /// `¥3,680.00`
  String get balanceText => '¥${money2(_num('balance'))}';
  String get pointsText => formatMoney(_num('points'));
  String get totalSpentText => '¥${formatMoney(_num('total_spent'))}';
  String get totalRechargedText => '¥${formatMoney(_num('total_recharged'))}';
  String get visitText => '${_num('visit_count').toInt()} 次';

  String get plate =>
      _vehicles.isEmpty ? '未登记车辆' : plateText('${_vehicles.first['plate']}');
  String get vehicleModel {
    if (_vehicles.isEmpty) return '可在会员详情里添加';
    final m = '${_vehicles.first['brand_model'] ?? ''}';
    return m.isEmpty ? '未填写车型' : m;
  }

  String get vehicleLabel => _vehicles.isEmpty ? '' : '已登记车辆';
}

/// 随当前会员变化的文字；没登录（设计预览）时显示设计稿的示例文字 [sample]。
Widget hMemberText(
  String Function(MemberView m) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) {
  final row = MemberFlow.current;
  return Text(
    merchantApi.hasSession && row != null ? text(MemberView(row)) : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  );
}

/// 同一行里样式不同的几段文字（姓名 + 手机号）；没登录时显示设计稿的示例文字。
Widget hMemberRich(
  List<String Function(MemberView m)> parts,
  List<String> samples,
  List<TextStyle> styles, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) {
  final row = MemberFlow.current;
  final live = merchantApi.hasSession && row != null;
  return Text.rich(
    TextSpan(
      children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
            text: live ? parts[i](MemberView(row)) : samples[i],
            style: styles[i],
          ),
      ],
    ),
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  );
}

/// 充值表单（金额 / 到账 / 充值后余额）和充值结果（成功页）里用到的文字。
class RechargeView {
  const RechargeView();

  num get _balance =>
      num.tryParse('${MemberFlow.current?['balance'] ?? 0}') ?? 0;

  // 表单
  num get amount => MemberFlow.rechargeAmount;
  num get gift => MemberFlow.rechargeGift;
  String get amountText => '¥${money2(amount)}';
  String get afterText => '¥${money2(_balance + amount + gift)}';

  /// 调整积分后的预览。
  String get adjustAfter => formatMoney(MemberFlow.adjustedPoints);

  /// `实收 · 到账 ¥2,300`
  String get payLine => '实收 · 到账 ¥${formatMoney(amount + gift)}';

  /// 档位上的赠送文案；设计稿里的“+ 洗车 2 次”等赠品暂未实现，只显示赠送金额。
  static String giftLabel(int i) =>
      '送 ¥${formatMoney(MemberFlow.rechargeGifts[i])}';

  // 购买次卡（表单）
  PackageRowInfo? get _salePkg {
    final p = MemberFlow.salePackage;
    return p == null ? null : PackageRowInfo(p);
  }

  String get saleOriginal => '¥${formatMoney(_salePkg?.original ?? 0)}';
  String get saleSaving {
    final p = _salePkg;
    final off = p == null ? 0 : (p.original - p.price);
    return '−¥${formatMoney(off > 0 ? off : 0)}';
  }

  String get saleDue => '¥${money2(_salePkg?.price ?? 0)}';
  String get saleConfirm => '确认收款 ¥${formatMoney(_salePkg?.price ?? 0)}';
  String get saleBalanceChip => '储值余额 ¥${formatMoney(_balance)}';
  String get saleAll => '查看全部 ${MemberFlow.salePackages.length} 个在售套餐';

  // 购买成功页
  Map<String, dynamic> get _s => MemberFlow.lastSale ?? const {};
  String get soldPaid => '¥${money2(num.tryParse('${_s['price'] ?? 0}') ?? 0)}';
  String get soldName => '${_s['name'] ?? ''}';
  String get soldCount => '${_s['total_count'] ?? 0} 次';
  String get soldExpiry {
    final t = DateTime.tryParse('${_s['expires_at'] ?? ''}')?.toLocal();
    return t == null ? '永久有效' : '至 ${t.year}.${_two(t.month)}.${_two(t.day)}';
  }

  String get soldSaving {
    final off =
        (num.tryParse('${_s['original_price'] ?? 0}') ?? 0) -
        (num.tryParse('${_s['price'] ?? 0}') ?? 0);
    return '−¥${money2(off > 0 ? off : 0)}';
  }

  String get soldSubtitle {
    final at = _s['at'] is DateTime ? _s['at'] as DateTime : DateTime.now();
    final m = '${_s['method'] ?? ''}';
    final pay = m == '微信' || m == '支付宝' ? '$m支付' : m;
    return '${_s['name'] ?? ''} · ${_s['member_name'] ?? ''} · $pay · ${_two(at.hour)}:${_two(at.minute)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  // 结果（成功页）
  Map<String, dynamic> get _r => MemberFlow.lastRecharge ?? const {};
  num _n(String k) => num.tryParse('${_r[k] ?? 0}') ?? 0;
  String get doneAmount => '¥${money2(_n('amount'))}';
  String get doneGift => '+¥${money2(_n('gift'))}';
  String get doneTotal => '¥${money2(_n('amount') + _n('gift'))}';
  String get doneBalance => '¥${money2(_n('balance'))}';
  String get donePoints => '+${formatMoney(_n('points_gained'))}';
  String get doneSubtitle {
    final at = _r['at'] is DateTime ? _r['at'] as DateTime : DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final m = '${_r['method'] ?? ''}';
    final pay = m == '微信' || m == '支付宝' ? '$m支付' : m;
    return '${_r['member_name'] ?? ''} · $pay · ${two(at.hour)}:${two(at.minute)}';
  }
}

/// 随充值表单 / 结果变化的文字；没登录（设计预览）时显示设计稿的示例文字 [sample]。
Widget hRechargeText(
  String Function(RechargeView r) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (_, _) => Text(
    merchantApi.hasSession ? text(const RechargeView()) : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

/// 筛选面板底部按钮上的“查看 N 位会员”；还没算出人数时只显示“查看会员”。
Widget hFilterCountText(String sample, TextStyle style) {
  if (!merchantApi.hasSession) return Text(sample, style: style);
  return ValueListenableBuilder<int?>(
    valueListenable: MemberFlow.filter.matched,
    builder: (_, n, _) => Text(n == null ? '查看会员' : '查看 $n 位会员', style: style),
  );
}

/// 调整页第 [i] 个卡种按钮的名称（本店真实卡种，去掉“卡”“会员”后缀）；读不到时显示设计稿的示例。
Widget hTierName(int i, String sample, TextStyle style) => Builder(
  builder: (context) {
    if (!merchantApi.hasSession || MemberFlow.tiers.isEmpty) {
      return Text(sample, style: style);
    }
    var t = i < MemberFlow.tiers.length
        ? '${MemberFlow.tiers[i]['name']}'
        : '—';
    // 设计稿的按钮是简称：普通 / 银卡 / 金卡 / 黑金（去掉“会员”，三个字以上的去掉结尾的“卡”）
    t = t.replaceAll('会员', '');
    if (t.length > 2 && t.endsWith('卡')) t = t.substring(0, t.length - 1);
    return Text(t, style: style);
  },
);

/// 次卡详情 / 延期 / 退款页面里用到的文字（来自 [MemberFlow.currentPackage]）。
class PackageView {
  const PackageView();
  Map<String, dynamic> get _p => MemberFlow.currentPackage ?? const {};
  num _n(String k) => num.tryParse('${_p[k] ?? 0}') ?? 0;
  int get total => _n('total_count').toInt();
  int get used => _n('used_count').toInt();
  int get remaining => total - used;
  num get paid => _n('price_paid');
  String get name => '${_p['name'] ?? ''}';
  DateTime? get _exp =>
      DateTime.tryParse('${_p['expires_at'] ?? ''}')?.toLocal();
  bool get refunded => _p['refunded_at'] != null;
  bool get expired => _exp != null && _exp!.isBefore(DateTime.now());

  String get status => refunded
      ? '已退款'
      : used >= total
      ? '已用完'
      : expired
      ? '已过期'
      : '使用中';

  static String _d(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';

  String get expiresAt => _exp == null ? '永久有效' : _d(_exp!);
  String get purchasedAt {
    final t = DateTime.tryParse('${_p['purchased_at'] ?? ''}')?.toLocal();
    return t == null ? '' : _d(t);
  }

  String get expiryNote {
    if (refunded) return '已退款';
    final e = _exp;
    if (e == null) return '永久有效';
    final days = e.difference(DateTime.now()).inDays;
    return days < 0 ? '已过期' : (days == 0 ? '今天到期' : '$days 天后到期');
  }

  String get owner =>
      '${_p['member']?['name'] ?? MemberFlow.current?['name'] ?? ''} · ${MemberView(MemberFlow.current ?? const {}).levelMember}';
  String get paidText => '¥${formatMoney(paid)}';
  double get ringFraction =>
      total == 0 ? 0 : (remaining / total).clamp(0, 1).toDouble();

  // 延期
  String get extendSubtitle => '$name · 当前到期日 $expiresAt';
  String get extendedExpiry {
    final base = _exp == null || _exp!.isBefore(DateTime.now())
        ? DateTime.now()
        : _exp!;
    return _d(base.add(Duration(days: MemberFlow.extendDaysValue)));
  }

  // 退款（与云函数的算法一致：实付 − 已用次数 × 单次均价）
  num get unit => total == 0 ? 0 : paid / total;
  num get usedDeduct => (used * unit * 100).round() / 100;
  num get refundable {
    final v = ((paid - used * unit) * 100).round() / 100;
    return v < 0 ? 0 : v;
  }

  String get refundSubtitle => '$name · 已用 $used 次，剩余 $remaining 次';
  String get usedLine => '已用 $used 次 × 单次 ¥${formatMoney(unit.round())}';
  String get usedDeductText => '−¥${money2(usedDeduct)}';
  String get paidMoney => '¥${money2(paid)}';
  String get refundableText => '¥${money2(refundable)}';
  String get refundConfirm => '确认退款 ¥${formatMoney(refundable)}';
}

Widget hPackageText(
  String Function(PackageView k) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (_, _) => Text(
    merchantApi.hasSession && MemberFlow.currentPackage != null
        ? text(const PackageView())
        : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

/// 收款成功页里用到的文字（来自 [MemberFlow.lastOrder]，即云函数的开单结果）。
class OrderView {
  const OrderView();
  Map<String, dynamic> get _o => MemberFlow.lastOrder ?? const {};
  num _n(String k) => num.tryParse('${_o[k] ?? 0}') ?? 0;

  String get payable => '¥${money2(_n('payable'))}';
  String get balancePaid => '¥${money2(_n('balance_paid'))}';
  String get balance => '¥${money2(_n('balance'))}';
  String get points => '+${formatMoney(_n('points_gained'))}';
  String get items => '${_o['items'] ?? ''}';

  String get _payText {
    final m = '${_o['pay_method'] ?? ''}';
    return switch (m) {
      '会员余额' => '储值支付',
      '微信' || '支付宝' => '$m支付',
      _ => m,
    };
  }

  String get subtitle {
    final at = _o['at'] is DateTime ? _o['at'] as DateTime : DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final plate = '${_o['plate'] ?? ''}';
    return [
      if (plate.isNotEmpty && plate != '未登记车辆') plate,
      '${_o['member_name'] ?? ''}',
      _payText,
      '${two(at.hour)}:${two(at.minute)}',
    ].join(' · ');
  }

  /// `黑金卡 9 折 −¥158.00`；有次卡抵扣时在前面加上 `次卡抵扣 −¥68.00`。
  String get discountLine {
    final parts = <String>[];
    final card = _n('card_off');
    final off = _n('discount_off');
    if (card > 0) parts.add('次卡抵扣 −¥${money2(card)}');
    if (off > 0) {
      final d = _n('discount') * 10;
      final n = d == d.roundToDouble()
          ? d.round().toString()
          : d.toStringAsFixed(1);
      parts.add('${_o['card_name'] ?? ''} $n 折 −¥${money2(off)}');
    }
    return parts.isEmpty ? '无优惠' : parts.join(' · ');
  }
}

Widget hOrderText(
  String Function(OrderView o) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => Text(
  merchantApi.hasSession && MemberFlow.lastOrder != null
      ? text(const OrderView())
      : sample,
  style: style,
  textAlign: textAlign,
  softWrap: softWrap,
  maxLines: maxLines,
);
