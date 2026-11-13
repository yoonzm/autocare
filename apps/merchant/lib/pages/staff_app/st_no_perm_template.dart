import '../../kit/buttons.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../kit/kit.dart';
import '../../resources/staff_svgs.dart';

class StNoPermTemplate extends StatelessWidget {
  final String need;
  const StNoPermTemplate({super.key, this.need = '该功能'});

  @override
  Widget build(BuildContext context) {
    final who = Access.role == 'owner'
        ? '平台'
        : (Access.role == 'manager' ? '老板' : '店长');
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(28, 0, 28, 120),
            child: hcol(
              [
                hbox(
                  w: 88,
                  h: 88,
                  bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                  radius: BorderRadius.circular(28),
                  child: hrow(
                    [hsvg(dk(context, Svgs.s87, Svgs.s88), w: 40, h: 40)],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    '暂无权限访问',
                    style: hts(
                      20,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  '该页面需要「$need」权限。请联系$who开通后再试。',
                  style: hts(
                    14,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    lh: 21,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '从消息推送或分享链接直接打开无权限的页面时，显示这一页。',
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              gap: 14,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFE4E4E7),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF3A3A40),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: AppButton(
                    label: '联系店长',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => openRoute(context, 'StMine'),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: AppButton(
                    label: '返回工作台',
                    kind: AppButtonKind.primary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}
