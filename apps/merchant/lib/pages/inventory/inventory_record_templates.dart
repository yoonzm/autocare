import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_controller.dart';
import '../../resources/merchant_svgs.dart';

class InventoryBatchTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> record;
  const InventoryBatchTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.batchCode(record),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.batchDates(record),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 16,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 1,
        ),
      ),
      Text(
        c.batchQuantity(record),
        style: hts(
          15,
          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
          w: FontWeight.w600,
          lh: 22,
        ),
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 12,
  );
}

class InventoryOutRecordTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> record;
  const InventoryOutRecordTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      hbox(
        w: 32,
        h: 32,
        bg: dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16)),
        radius: BorderRadius.circular(10),
        child: hrow(
          [hsvg(dk(context, Svgs.s316, Svgs.s317), w: 18, h: 18)],
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          gap: 0,
        ),
      ),
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.recordKind(record),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.recordNote(record),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 16,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 1,
        ),
      ),
      hcol(
        [
          Text(
            c.recordQuantity(record),
            style: hts(
              15,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 22,
            ),
          ),
          Text(
            c.recordTime(record),
            style: hts(
              11,
              dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
              lh: 14,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.end,
        gap: 1,
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 12,
  );
}

class InventoryInRecordTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> record;
  const InventoryInRecordTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      hbox(
        w: 32,
        h: 32,
        bg: dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16)),
        radius: BorderRadius.circular(10),
        child: hrow(
          [hsvg(dk(context, Svgs.s318, Svgs.s319), w: 18, h: 18)],
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          gap: 0,
        ),
      ),
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.recordKind(record),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.recordNote(record),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 16,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 1,
        ),
      ),
      hcol(
        [
          Text(
            c.recordQuantity(record),
            style: hts(
              15,
              dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
              w: FontWeight.w600,
              lh: 22,
            ),
          ),
          Text(
            c.recordTime(record),
            style: hts(
              11,
              dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
              lh: 14,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.end,
        gap: 1,
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 12,
  );
}

class InventoryCheckRecordTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> record;
  const InventoryCheckRecordTemplate({
    super.key,
    required this.c,
    required this.record,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      hbox(
        w: 32,
        h: 32,
        bg: dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)),
        radius: BorderRadius.circular(10),
        child: hrow(
          [hsvg(dk(context, Svgs.s320, Svgs.s321), w: 18, h: 18)],
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          gap: 0,
        ),
      ),
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.recordKind(record),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.recordNote(record),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 16,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 1,
        ),
      ),
      hcol(
        [
          Text(
            c.recordQuantity(record),
            style: hts(
              15,
              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
              w: FontWeight.w600,
              lh: 22,
            ),
          ),
          Text(
            c.recordTime(record),
            style: hts(
              11,
              dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
              lh: 14,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.end,
        gap: 1,
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 12,
  );
}
