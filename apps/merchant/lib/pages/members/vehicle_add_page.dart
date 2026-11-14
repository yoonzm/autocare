import '../../kit/text_input.dart';
import '../../theme.dart' show C;
import 'member_form_controller.dart';
import 'member_form_host.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class VehicleAddPage extends StatelessWidget {
  final Map<String, dynamic>? member, vehicle;
  const VehicleAddPage({super.key, this.member, this.vehicle});
  @override
  Widget build(BuildContext context) => MemberFormHost(
    key: ValueKey('vehicle-${member?['id']}'),
    kind: MemberFormKind.vehicle,
    member: member,
    vehicle: vehicle,
    builder: (c) => _VehicleAddPageTemplate(c: c),
  );
}

class _VehicleAddPageTemplate extends StatelessWidget {
  final MemberFormController c;
  const _VehicleAddPageTemplate({required this.c});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 940,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: hcol(
              [
                hrow(
                  [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: hbox(
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(22),
                        shadow: dk(
                          context,
                          [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              offset: Offset(0, 0),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                          [
                            BoxShadow(
                              color: Color(0xFF26262B),
                              offset: Offset(0, 0),
                              blurRadius: 0,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: hrow(
                          [hsvg(dk(context, Svgs.s71, Svgs.s72), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '添加车辆',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => c.submit(context),
                      child: hbox(
                        h: 44,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(22),
                        pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: hBusy(
                            c.actionKey,
                            Text(
                              '保存',
                              style: hts(
                                14,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 20,
                              ),
                            ),
                            style: hts(
                              14,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                            round: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => c.scanVehicle(context),
                  child: hbox(
                    h: 150,
                    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                    radius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0xFFA1A1AA), width: 1.5),
                    child: hstack(
                      hcol(
                        [
                          hbox(
                            w: 48,
                            h: 48,
                            bg: dk(
                              context,
                              Color(0xFF18181B),
                              Color(0xFFFAFAFA),
                            ),
                            radius: BorderRadius.circular(24),
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s391, Svgs.s392),
                                  w: 22,
                                  h: 22,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          Text(
                            '扫描车牌，自动填写',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 10,
                        min: false,
                      ),
                      [],
                      behind: [
                        Positioned(
                          left: 14,
                          top: 14,
                          right: 14,
                          bottom: 14,
                          child: hbox(
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(24),
                  shadow: dk(
                    context,
                    [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 0),
                        blurRadius: 1,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                    [
                      BoxShadow(
                        color: Color(0xFF26262B),
                        offset: Offset(0, 0),
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  pad: EdgeInsets.fromLTRB(0, 16, 0, 4),
                  child: hcol(
                    [
                      hbox(
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => c.plate.setGreen(false),
                                child: !c.plate.green
                                    ? hbox(
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        shadow: dk(
                                          context,
                                          [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.08,
                                              ),
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          [
                                            BoxShadow(
                                              color: Color(0xFF26262B),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: hrow(
                                          [
                                            Text(
                                              '燃油车 · 蓝牌',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () =>
                                                    c.plate.setGreen(true),
                                                child: c.plate.green
                                                    ? hbox(
                                                        h: 32,
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFFFFFFF),
                                                          Color(0xFF18181B),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        shadow: dk(
                                                          context,
                                                          [
                                                            BoxShadow(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.08,
                                                                  ),
                                                              offset: Offset(
                                                                0,
                                                                1,
                                                              ),
                                                              blurRadius: 2,
                                                              spreadRadius: 0,
                                                            ),
                                                          ],
                                                          [
                                                            BoxShadow(
                                                              color: Color(
                                                                0xFF26262B,
                                                              ),
                                                              offset: Offset(
                                                                0,
                                                                0,
                                                              ),
                                                              blurRadius: 0,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '新能源 · 绿牌',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF18181B,
                                                                ),
                                                                Color(
                                                                  0xFFFAFAFA,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : hbox(
                                                        h: 32,
                                                        radius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '新能源 · 绿牌',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF52525B,
                                                                ),
                                                                Color(
                                                                  0xFFA8A8B3,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                      )
                                    : hbox(
                                        h: 32,
                                        radius: BorderRadius.circular(16),
                                        child: hrow(
                                          [
                                            Text(
                                              '燃油车 · 蓝牌',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () =>
                                                    c.plate.setGreen(true),
                                                child: c.plate.green
                                                    ? hbox(
                                                        h: 32,
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFFFFFFF),
                                                          Color(0xFF18181B),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        shadow: dk(
                                                          context,
                                                          [
                                                            BoxShadow(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.08,
                                                                  ),
                                                              offset: Offset(
                                                                0,
                                                                1,
                                                              ),
                                                              blurRadius: 2,
                                                              spreadRadius: 0,
                                                            ),
                                                          ],
                                                          [
                                                            BoxShadow(
                                                              color: Color(
                                                                0xFF26262B,
                                                              ),
                                                              offset: Offset(
                                                                0,
                                                                0,
                                                              ),
                                                              blurRadius: 0,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '新能源 · 绿牌',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF18181B,
                                                                ),
                                                                Color(
                                                                  0xFFFAFAFA,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : hbox(
                                                        h: 32,
                                                        radius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '新能源 · 绿牌',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF52525B,
                                                                ),
                                                                Color(
                                                                  0xFFA8A8B3,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 2,
                        ),
                      ),
                      HPlate(controller: c.plate),
                      hcol(
                        [
                          Builder(
                            builder: (context) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => c.selectCar(context),
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '品牌车型',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                          lh: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      c.text('brand_model').isEmpty
                                          ? '请选择品牌车型'
                                          : c.text('brand_model'),
                                      style:
                                          (hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            lh: 22,
                                          )).copyWith(
                                            color: c.text('brand_model').isEmpty
                                                ? C.muted
                                                : C.ink,
                                          ),
                                    ),
                                    hsvg(
                                      dk(context, Svgs.s3, Svgs.s4),
                                      w: 16,
                                      h: 16,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 64,
                                  child: Text(
                                    '车架号',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AppTextInput(
                                    controller: c.input('vin'),
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                      ls: 0.3,
                                    ),
                                    hint: '请输入车架号',
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '当前里程',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                hbox(
                                  w: 80,
                                  child: AppTextInput(
                                    controller: c.input('mileage'),
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 22,
                                    ),
                                    hint: '请输入当前里程',
                                    keyboard: TextInputType.number,
                                    align: TextAlign.right,
                                  ),
                                ),
                                Text(
                                  'km',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '到期提醒 · 自动加入回访',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(24),
                      shadow: dk(
                        context,
                        [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        [
                          BoxShadow(
                            color: Color(0xFF26262B),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        [
                          hbox(
                            minH: 58,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '车险到期',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      Text(
                                        '未设置',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF71717A),
                                            Color(0xFF9A9AA3),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 0,
                                  ),
                                ),
                                HSwitchValue(
                                  value: false,
                                  onChanged: (_) => c.reminderTodo(context),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 58,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '镀晶养护',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      Text(
                                        '施工后每 3 个月提醒复养',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF71717A),
                                            Color(0xFF9A9AA3),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 0,
                                  ),
                                ),
                                HSwitchValue(
                                  value: false,
                                  onChanged: (_) => c.reminderTodo(context),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 58,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '年检到期',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      Text(
                                        '未设置',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF71717A),
                                            Color(0xFF9A9AA3),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 0,
                                  ),
                                ),
                                HSwitchValue(
                                  value: false,
                                  onChanged: (_) => c.reminderTodo(context),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 16,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [],
    );
  }
}
