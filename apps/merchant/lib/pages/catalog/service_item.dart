class ServiceItem {
  final String category, name, desc, tag;
  final num price;
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
