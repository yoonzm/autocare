import 'catalog_draft.dart';

/// 正在编辑的次卡套餐的汇总：原价合计、单次价、优惠。
/// 原价 = Σ（服务单次价 × 次数），与设计稿“选中服务后设置包含次数；原价按「单次价 × 次数」自动汇总”一致。
class PackageCalc {
  PackageCalc._();

  static num _n(Object? v) => num.tryParse('$v') ?? 0;

  static int get totalCount =>
      CatalogDraft.packageItems.fold(0, (s, e) => s + _n(e['count']).toInt());

  static num get originalTotal => CatalogDraft.packageItems.fold<num>(
    0,
    (s, e) => s + _n(e['price']) * _n(e['count']),
  );

  /// 套餐售价（草稿里输入框的文字）；没填或填错为 0。
  static num get price =>
      num.tryParse(
        '${CatalogDraft.current?.fields['price'] ?? ''}'
            .replaceAll(',', '')
            .trim(),
      ) ??
      0;

  static num get saving => originalTotal - price;

  static String money(num v) => formatMoney(v);

  /// `3 个月有效` / `永久有效`
  static String get validityText {
    final m = CatalogDraft.packageValidities[CatalogDraft.packageValidityIndex];
    return m == 0 ? '永久有效' : '$m 个月有效';
  }

  /// `20 次 · 12 个月有效`
  static String get summary => '$totalCount 次 · $validityText';

  /// `¥1,360`
  static String get originalText => '¥${money(originalTotal)}';

  /// `¥1,080`
  static String get priceText => '¥${money(price)}';

  /// `相当于单次 ¥54`
  static String get perUseText => totalCount == 0
      ? '相当于单次 —'
      : '相当于单次 ¥${money((price / totalCount).round())}';

  /// `省 ¥280 · 约 7.9 折`；没有优惠时 `无优惠`。
  static String get savingText {
    if (originalTotal <= 0 || saving <= 0) return '无优惠';
    final ratio = (price / originalTotal * 10).toStringAsFixed(1);
    return '省 ¥${money(saving)} · 约 $ratio 折';
  }
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
