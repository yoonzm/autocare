// 从既有设计模板派生；选择标签统一使用受控组件，不修改 gen/。
import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../widgets/booking_template_bindings.dart';
import '../widgets/choice_chip_group.dart';

class AppointmentRescheduleTemplate extends StatelessWidget {
  final BookingTemplateController c;
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
          '改期 · ${c.booking!.customer}',
          style: hts(
            20,
            dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
            w: FontWeight.w600,
            lh: 28,
          ),
        ),
        Text(
          '原预约：${c.booking!.start.month}.${c.booking!.start.day} ${c.booking!.time} · ${c.booking!.service} · ${c.booking!.station}',
          style: hts(
            13,
            dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
            lh: 18,
          ),
        ),
        _sectionTitle(context, '新日期'),
        ChoiceChipGroup<int>(
          semanticLabel: '新日期',
          kind: ChipKind.pill,
          items: [
            for (var i = 0; i < 4; i++)
              ChoiceChipItem(value: i, label: c.dateLabel(i)),
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
            const BookingDeferredSwitch(),
          ],
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
        hrow(
          [
            Expanded(
              child: hTap(
                context,
                hbox(
                  h: 50,
                  bg: dk(
                    context,
                    const Color(0xFFEEEEF0),
                    const Color(0xFF27272A),
                  ),
                  radius: BorderRadius.circular(25),
                  align: Alignment.center,
                  child: Text(
                    '取消',
                    style: hts(
                      15,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w500,
                      lh: 22,
                    ),
                  ),
                ),
                back: true,
              ),
            ),
            Expanded(
              flex: 2,
              child: KeyedSubtree(
                key: const ValueKey('reschedule-confirm-button'),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canReschedule && !c.busy
                      ? () => c.save(context, button: '确认改期')
                      : null,
                  child: hbox(
                    h: 50,
                    bg: canReschedule
                        ? dk(
                            context,
                            const Color(0xFF18181B),
                            const Color(0xFFFAFAFA),
                          )
                        : dk(
                            context,
                            const Color(0xFFD4D4D8),
                            const Color(0xFF3F3F46),
                          ),
                    radius: BorderRadius.circular(25),
                    align: Alignment.center,
                    child: c.busy
                        ? hrow(
                            [
                              AppSpinner(
                                size: 18,
                                color: dk(
                                  context,
                                  Colors.white,
                                  const Color(0xFF18181B),
                                ),
                              ),
                              Text(
                                '提交中…',
                                style: hts(
                                  15,
                                  dk(
                                    context,
                                    Colors.white,
                                    const Color(0xFF18181B),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          )
                        : Text(
                            '确认改期',
                            style: hts(
                              15,
                              canReschedule
                                  ? dk(
                                      context,
                                      Colors.white,
                                      const Color(0xFF18181B),
                                    )
                                  : const Color(0xFF71717A),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                  ),
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
        ChoiceChipGroup<int>(
          semanticLabel: '取消原因',
          kind: ChipKind.pill,
          items: const [
            ChoiceChipItem(value: 0, label: '客户有事'),
            ChoiceChipItem(value: 1, label: '时间冲突'),
            ChoiceChipItem(value: 2, label: '联系不上'),
            ChoiceChipItem(value: 3, label: '其他'),
          ],
          selected: c.cancelReason,
          onChanged: (value) {
            c.cancelReason = value;
            c.changed();
          },
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canCancel && !c.busy ? () => c.cancelBooking(context) : null,
          child: hbox(
            h: 46,
            bg: dk(
              context,
              const Color(0xFFFFE1E2),
              const Color.fromRGBO(255, 56, 60, 0.18),
            ),
            radius: BorderRadius.circular(23),
            align: Alignment.center,
            child: Text(
              '取消这个预约',
              style: hts(
                15,
                canCancel
                    ? dk(
                        context,
                        const Color(0xFFA43433),
                        const Color(0xFFFF7B7E),
                      )
                    : const Color(0xFFC4C4C9),
                w: FontWeight.w600,
                lh: 22,
              ),
            ),
          ),
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
