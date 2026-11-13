import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../widgets/choice_chip_group.dart';
import 'reschedule_controller.dart';

class BookingRescheduleSlots extends StatelessWidget {
  final RescheduleController c;
  const BookingRescheduleSlots({super.key, required this.c});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 88,
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
      skeleton: const AppSkeleton(height: 88, radius: 12),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, data) => SingleChildScrollView(
        child: (data['slots'] as List).isEmpty
            ? const EmptyView(title: '该日期没有可预约时段', inline: true)
            : ChoiceChipGroup<String>(
                semanticLabel: '新时间',
                kind: ChipKind.tile,
                items: [
                  for (final slot in data['slots'] as List)
                    ChoiceChipItem(
                      value: slot['time'] as String,
                      label: slot['time'] as String,
                      disabled: slot['available'] != true,
                      isOriginal:
                          bookingDay(c.booking.start) ==
                              bookingDay(c.date(c.rescheduleDay!)) &&
                          slot['time'] == c.booking.time,
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
