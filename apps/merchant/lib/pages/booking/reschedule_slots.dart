import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem, ChipKind;

import 'reschedule_controller.dart';

class BookingRescheduleSlots extends StatelessWidget {
  final RescheduleController c;
  const BookingRescheduleSlots({super.key, required this.c});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96,
    child: AsyncView<Map<String, dynamic>>(
      key: ValueKey(c.rescheduleDay),
      load: () => merchantApi.appointment('slots', {
        'day': bookingDay(c.date(c.rescheduleDay!)),
        'service_ids': c.booking.row['service_ids'],
        'exclude': c.booking.id,
        'bay_id': c.booking.row['bay_id'],
        'technician_id': c.booking.row['technician_id'],
      }),
      isEmpty: (_) => false,
      inlineError: true,
      pullToRefresh: false,
      skeletonPadding: EdgeInsets.zero,
      skeleton: const AppSkeleton(height: 96, radius: 12),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, data) => SingleChildScrollView(
        child: (data['slots'] as List).isEmpty
            ? const EmptyView(title: '该日期没有可预约时段', inline: true)
            : AppChoiceGroup<String>(
                semanticLabel: '新时间',
                kind: ChipKind.tile,
                columns: 3,
                items: [
                  for (final slot in data['slots'] as List)
                    ChoiceItem(
                      value: slot['time'] as String,
                      label: slot['time'] as String,
                      enabled: slot['available'] == true,
                    ),
                ],
                selected: c.selectedTime.isEmpty ? null : c.selectedTime,
                onChanged: (value) {
                  c.selectedTime = value;
                  c.edited();
                },
              ),
      ),
    ),
  );
}
