import '../../kit/buttons.dart';
import 'reschedule_slots.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'reschedule_controller.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem, ChipKind;

class AppointmentRescheduleTemplate extends StatelessWidget {
  final RescheduleController c;
  const AppointmentRescheduleTemplate({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final canReschedule = c.rescheduleDay != null && c.selectedTime.isNotEmpty;
    final canCancel = c.cancelReason != null;
    return hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: const BorderRadius.vertical(top: Radius.circular(32)),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol([
        Align(
          alignment: Alignment.topCenter,
          child: hbox(
            w: 40,
            h: 5,
            bg: dk(context, const Color(0xFFD4D4D8), const Color(0xFF3F3F46)),
            radius: BorderRadius.circular(3),
          ),
        ),
        Text(
          '改期 · ${c.booking.customer}',
          style: hts(
            20,
            dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
            w: FontWeight.w600,
            lh: 28,
          ),
        ),
        Text(
          '原预约：${c.booking.start.month}.${c.booking.start.day} ${c.booking.time} · ${c.booking.service} · ${c.booking.station}',
          style: hts(
            13,
            dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
            lh: 18,
          ),
        ),
        _sectionTitle(context, '新日期'),
        AppChoiceGroup<int>(
          semanticLabel: '新日期',
          kind: ChipKind.pill,
          items: [
            for (var i = 0; i < 4; i++)
              ChoiceItem(value: i, label: c.dateLabel(i)),
          ],
          selected: c.rescheduleDay,
          onChanged: (value) {
            if (c.rescheduleDay == value) return;
            c.rescheduleDay = value;
            c.selectedTime = '';
            c.edited();
          },
        ),
        Text.rich(
          TextSpan(
            style: hts(
              14,
              dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 20,
            ),
            children: [
              const TextSpan(text: '新时间 '),
              TextSpan(
                text: c.selectedTime.isEmpty
                    ? '· 请选择时间'
                    : '· ${c.selectedTime}',
                style: hts(
                  14,
                  dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
                  lh: 20,
                ),
              ),
            ],
          ),
        ),
        if (c.rescheduleDay == null)
          SizedBox(
            height: 88,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '请先选择新日期',
                style: hts(
                  13,
                  dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
                  lh: 18,
                ),
              ),
            ),
          )
        else
          BookingRescheduleSlots(c: c),
        hrow(
          [
            Expanded(
              child: hcol([
                Text(
                  '改期后通知客户',
                  style: hts(
                    14,
                    dk(
                      context,
                      const Color(0xFF18181B),
                      const Color(0xFFFAFAFA),
                    ),
                    lh: 20,
                  ),
                ),
                Text(
                  '微信优先，失败转短信',
                  style: hts(
                    12,
                    dk(
                      context,
                      const Color(0xFF71717A),
                      const Color(0xFF9A9AA3),
                    ),
                    lh: 16,
                  ),
                ),
              ], gap: 0),
            ),
            HSwitchValue(value: false, onChanged: (_) => c.deferred(context)),
          ],
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
        hrow(
          [
            Expanded(
              child: AppButton(
                label: '取消',
                kind: AppButtonKind.secondary,
                size: AppButtonSize.large,
                expanded: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              flex: 2,
              child: KeyedSubtree(
                key: const ValueKey('reschedule-confirm-button'),
                child: AppButton(
                  expanded: true,
                  label: '确认改期',
                  kind: AppButtonKind.primary,
                  size: AppButtonSize.large,
                  loading: c.locked,
                  onPressed: canReschedule && !c.locked
                      ? () => c.save(context)
                      : null,
                ),
              ),
            ),
          ],
          cross: CrossAxisAlignment.stretch,
          gap: 10,
          intrinsic: true,
        ),
        hbox(
          h: 1,
          bg: dk(context, const Color(0xFFEFEFF1), const Color(0xFF2A2A2E)),
        ),
        _sectionTitle(context, '或者取消预约'),
        AppChoiceGroup<int>(
          semanticLabel: '取消原因',
          kind: ChipKind.pill,
          items: const [
            ChoiceItem(value: 0, label: '客户有事'),
            ChoiceItem(value: 1, label: '时间冲突'),
            ChoiceItem(value: 2, label: '联系不上'),
            ChoiceItem(value: 3, label: '其他'),
          ],
          selected: c.cancelReason,
          onChanged: (value) {
            c.cancelReason = value;
            c.changed();
          },
        ),
        AppButton(
          label: '取消这个预约',
          kind: AppButtonKind.danger,
          size: AppButtonSize.medium,
          expanded: false,
          onPressed: canCancel && !c.locked
              ? () => c.cancelBooking(context)
              : null,
        ),
      ], gap: 14),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: hts(
      14,
      dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
      w: FontWeight.w600,
      lh: 20,
    ),
  );
}
