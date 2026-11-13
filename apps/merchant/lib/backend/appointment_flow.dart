import 'package:flutter/foundation.dart';

DateTime get bookingToday =>
    DateTime.now().toUtc().add(const Duration(hours: 8));
String bookingDay(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String bookingTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

enum ApptStatus { waiting, arrived, late, done }

class Appointment {
  final Map<String, dynamic> row;
  Appointment(this.row);
  String get id => row['id'] as String;
  DateTime get start =>
      DateTime.parse(row['starts_at'] as String)
          .toUtc()
          .add(const Duration(hours: 8));
  String get time => bookingTime(start);
  int get minutes => (row['duration_minutes'] as num).toInt();
  String get duration => '${minutes / 60} 小时';
  String get plate => '${row['vehicle_plate'] ?? ''}';
  String get customer => '${row['customer_name']}';
  String get maskedPhone {
    final phone = '${row['phone'] ?? ''}';
    return phone.length == 11
        ? '${phone.substring(0, 3)} **** ${phone.substring(7)}'
        : '未登记联系方式';
  }

  String get level => '${row['level'] ?? '散客'}';
  String get service =>
      (row['items'] as List).map((e) => e['name']).join(' · ');
  String get station =>
      '${row['bay_name'] ?? '未指定工位'} · ${row['technician_name'] ?? '未指定技师'}';
  ApptStatus get status => switch (row['status']) {
    'arrived' => ApptStatus.arrived,
    'late' => ApptStatus.late,
    'done' => ApptStatus.done,
    _ => ApptStatus.waiting,
  };
}

class AppointmentFlow {
  static final changed = ValueNotifier<int>(0);
  static void notify() => changed.value++;
}
