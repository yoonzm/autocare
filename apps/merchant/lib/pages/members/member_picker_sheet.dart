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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: hbox(
                          w: 36,
                          h: 36,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(18),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s400, Svgs.s401),
                                w: 18,
                                h: 18,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openRoute(context, 'MemberAdd'),
                  child: hbox(
                    h: 44,
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(22),
                    child: hrow(
                      [
                        hsvg(dk(context, Svgs.s402, Svgs.s403), w: 16, h: 16),
                        Flexible(
                          flex: 56,
                          child: Text(
                            '新增会员',
                            style: hts(
                              14,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                      gap: 6,
                    ),
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
        gap: 0,
      ),
    );
  }
}
