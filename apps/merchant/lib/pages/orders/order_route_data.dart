import '../../backend/data_snapshot.dart';

class OrderRouteData {
  final Map<String, dynamic>? member, hold, appointment;
  final bool walkIn;
  final String plate;
  OrderRouteData({
    Map<String, dynamic>? member,
    Map<String, dynamic>? hold,
    Map<String, dynamic>? appointment,
    this.walkIn = false,
    this.plate = '',
  }) : member = member == null ? null : dataSnapshot(member),
       hold = hold == null ? null : dataSnapshot(hold),
       appointment = appointment == null ? null : dataSnapshot(appointment);

  // 每次打开代表独立编辑意图；同 ID 的旧页面不能覆盖本次传入的新快照。
}

class OrderReceipt {
  final Map<String, dynamic> data;
  OrderReceipt(Map<String, dynamic> data) : data = dataSnapshot(data);
}
