import '../../kit/buttons.dart';
import 'member_picker_widgets.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

Future<Map<String, dynamic>?> showMemberPicker(BuildContext context) =>
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'sheet:MemberPicker'),
      builder: (_) => const SingleChildScrollView(child: MemberPickerSheet()),
    );

class MemberPickerSheet extends StatefulWidget {
  const MemberPickerSheet({super.key});
  @override
  State<MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<MemberPickerSheet> {
  final query = ValueNotifier('');
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hbox(
      minH: 700,
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      child: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: hcol(
              [
                Align(
                  alignment: Alignment.topCenter,
                  child: hbox(
                    w: 36,
                    h: 4,
                    bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
                    radius: BorderRadius.circular(2),
                  ),
                ),
                hbox(
                  h: 48,
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '选择会员',
                          style: hts(
                            17,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                        ),
                      ),
                      AppIconButton(
                        svg: dk(context, Svgs.s400, Svgs.s401),
                        semanticLabel: "返回",
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hMemberPickerSearch(query),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
          hMemberPickerList(
            query,
            (member) => Navigator.of(context).pop(member),
          ),
          hbox(
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
            pad: EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: hcol(
              [
                AppButton(
                  label: '新增会员',
                  kind: AppButtonKind.secondary,
                  size: AppButtonSize.medium,
                  expanded: false,
                  svg: dk(context, Svgs.s402, Svgs.s403),
                  onPressed: () => openRoute(context, 'MemberAdd'),
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
        gap: 0,
      ),
    );
  }
}
