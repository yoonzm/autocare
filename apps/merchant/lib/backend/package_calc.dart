/// 正在编辑的次卡套餐的汇总：原价合计、单次价、优惠。
/// 原价 = Σ（服务单次价 × 次数），与设计稿“选中服务后设置包含次数；原价按「单次价 × 次数」自动汇总”一致。
class PackageCalc {
  final List<Map<String, dynamic>> items;
  final num price;
  final int validityMonths;
  const PackageCalc({
    this.items = const [],
    this.price = 0,
    this.validityMonths = 12,
  });

  factory PackageCalc.fromRow(Map<String, dynamic> row) => PackageCalc(
    items: packageItemsFromRow(row),
    price: num.tryParse('${row['price'] ?? 0}'.replaceAll(',', '')) ?? 0,
    validityMonths: int.tryParse('${row['validity_months'] ?? 12}') ?? 12,
  );

  static num _n(Object? v) => num.tryParse('$v') ?? 0;

  int get totalCount => items.fold(0, (s, e) => s + _n(e['count']).toInt());

  num get originalTotal =>
      items.fold<num>(0, (s, e) => s + _n(e['price']) * _n(e['count']));

  num get saving => originalTotal - price;

  static String money(num v) => formatMoney(v);

  /// `3 个月有效` / `永久有效`
  String get validityText {
    final m = validityMonths;
    return m == 0 ? '永久有效' : '$m 个月有效';
  }

  /// `20 次 · 12 个月有效`
  String get summary => '$totalCount 次 · $validityText';

  /// `¥1,360`
  String get originalText => '¥${money(originalTotal)}';

  /// `¥1,080`
  String get priceText => '¥${money(price)}';

  /// `相当于单次 ¥54`
  String get perUseText => totalCount == 0
      ? '相当于单次 —'
      : '相当于单次 ¥${money((price / totalCount).round())}';

  /// `省 ¥280 · 约 7.9 折`；没有优惠时 `无优惠`。
  String get savingText {
    if (originalTotal <= 0 || saving <= 0) return '无优惠';
    final ratio = (price / originalTotal * 10).toStringAsFixed(1);
    return '省 ¥${money(saving)} · 约 $ratio 折';
  }
}

/// 接口嵌套服务记录转为编辑数据；复制后排序，避免修改调用者的记录。
List<Map<String, dynamic>> packageItemsFromRow(Map<String, dynamic>? row) {
  final raw = [
    for (final item in (row?['items'] as List? ?? const []))
      Map<String, dynamic>.from(item as Map),
  ];
  raw.sort(
    (a, b) =>
        ((a['position'] ?? 0) as num).compareTo((b['position'] ?? 0) as num),
  );
  return [
    for (final item in raw)
      {
        'service_id': item['service_id'],
        'name': (item['service'] as Map?)?['name'] ?? item['name'] ?? '',
        'price': (item['service'] as Map?)?['price'] ?? item['price'] ?? 0,
        'count': item['count'] ?? 1,
      },
  ];
}

/// `1080` -> `1,080`，`58.5` -> `58.50`。
String formatMoney(num v) {
  final s = v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// 列表里一行套餐（后端返回的记录）的展示文字。
class PackageRowInfo {
  final Map<String, dynamic> row;
  const PackageRowInfo(this.row);

  static num _n(Object? v) => num.tryParse('$v') ?? 0;

  List<Map> get _items => [
    ...((row['items'] as List?) ?? const []).cast<Map>(),
  ];

  int get totalCount => _items.fold(0, (s, e) => s + _n(e['count']).toInt());

  num get original => _items.fold<num>(
    0,
    (s, e) => s + _n((e['service'] as Map?)?['price']) * _n(e['count']),
  );

  num get price => _n(row['price']);

  bool get active => row['active'] != false;

  /// 有原价且高于售价时才显示划线原价。
  bool get showOriginal => original > price;

  String get validityText {
    final m = _n(row['validity_months']).toInt();
    return m == 0 ? '永久有效' : '$m 个月有效';
  }

  /// TODO: “已售 N” 依赖次卡售卖（订单 / 会员模块），V1 未接入，这里不显示销量。
  String get subtitle => '$totalCount 次 · $validityText';
  String get priceText => '¥${formatMoney(price)}';
  String get originalText => '¥${formatMoney(original)}';
}
