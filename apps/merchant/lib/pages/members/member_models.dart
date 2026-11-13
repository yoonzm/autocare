class Member {
  final String name, level, plate, lastVisit, amount, amountNote;
  final Set<String> tags;
  final String phone;

  /// 会员摘要与服务端记录。需要会员身份的页面必须检查 ID；散客不作为已注册会员处理。
  final String? id;
  final Map<String, dynamic>? data;
  const Member(
    this.name,
    this.level,
    this.plate,
    this.lastVisit,
    this.amount,
    this.amountNote,
    this.tags, {
    this.phone = '',
    this.id,
    this.data,
  });
}

class Vehicle {
  final String model, plate, note;
  const Vehicle(this.model, this.plate, this.note);
}

class CardPack {
  final String name, expire;
  final int used, total;
  const CardPack(this.name, this.used, this.total, this.expire);
}
