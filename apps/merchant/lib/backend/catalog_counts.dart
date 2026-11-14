/// 两个页签（等级储值卡 / 次卡套餐）上显示的数量；还没加载过时为 null，不显示数字。
class CatalogCounts {
  CatalogCounts._();
  static int? cards;
  static int? packages;
}

String tabLabel(String name, int? count) =>
    count == null ? name : '$name $count';
