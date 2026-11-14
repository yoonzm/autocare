import '../../kit/async_kit.dart';

// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';

class StockCheckInputBoundTemplate extends StatelessWidget {
  const StockCheckInputBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return AsyncActionScope(
      actionKey: c.actionKey,
      child: hbox(
        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
        radius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
        pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
        child: hcol(
          [
            Align(
              alignment: Alignment.topCenter,
              child: hbox(
                w: 40,
                h: 5,
                bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
                radius: BorderRadius.circular(3),
              ),
            ),
            Text(
              c.countProductName,
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            hcol(
              [
                Text.rich(
                  TextSpan(
                    style: hts(
                      13,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      w: FontWeight.w500,
                      lh: 18,
                    ),
                    children: [
                      TextSpan(
                        text: '实盘数量',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' *',
                        style: hts(
                          13,
                          Color(0xFFD6403F),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                hbox(
                  minH: 48,
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(14),
                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: c.countField(
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            lh: 22,
                          ),
                          quantity: true,
                        ),
                      ),
                      Text(
                        c.countUnit,
                        style: hts(
                          14,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                Text(
                  c.countStockLabel,
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 17,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 6,
            ),
            hcol(
              [
                Text(
                  '备注',
                  style: hts(
                    13,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    w: FontWeight.w500,
                    lh: 18,
                  ),
                ),
                hbox(
                  minH: 48,
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(14),
                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: c.countField(
                          style: hts(
                            15,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 22,
                          ),
                          quantity: false,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 6,
            ),
            hbox(
              pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: hrow(
                [
                  Expanded(
                    flex: 1,
                    child: UnconstrainedBox(
                      alignment: Alignment.topLeft,
                      constrainedAxis: Axis.horizontal,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: c.busy
                            ? null
                            : () => c.nextCount(context, confirm: false),
                        child: hbox(
                          h: 50,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(25),
                          child: Align(
                            alignment: Alignment(0, 0),
                            widthFactor: 1,
                            child: Text(
                              '跳过',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: UnconstrainedBox(
                      alignment: Alignment.topLeft,
                      constrainedAxis: Axis.horizontal,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: c.busy
                            ? null
                            : () => c.nextCount(context, confirm: true),
                        child: hbox(
                          h: 50,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(25),
                          child: Align(
                            alignment: Alignment(0, 0),
                            widthFactor: 1,
                            child: Text(
                              '确认并下一项',
                              style: hts(
                                15,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 10,
                intrinsic: true,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 14,
        ),
      ),
    );
  }
}
