// 从员工端设计稿生成页派生（tools/bind_st.py），仅绑定数据和事件；不手工修改 gen_st/。
import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../backend/staff_flow.dart';
import '../kit/kit.dart';
import 'gen_st/svgs.dart';
import 'st_live.dart';

class StIdentityTemplate extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic>) pick;
  const StIdentityTemplate({super.key, required this.items, required this.pick});

  @override
  Widget build(BuildContext context) {
    final phone = StaffFlow.maskedPhone(
      AccessFlow.phone.isEmpty ? '${Access.context['phone'] ?? ''}' : AccessFlow.phone,
    );
    String hintOf(Map<String, dynamic> it) {
      if (it['kind'] == 'owner') {
        return '名下 ${it['stores'] ?? 1} 家门店${it['current'] == true ? ' · 上次使用' : ''}';
      }
      if (it['status'] == 'pending') {
        return '待确认加入';
      }
      return '${it['hint'] ?? ''}';
    }

    Widget card(Map<String, dynamic> it) {
      final store = '${it['store_name']}';
      final hint = hintOf(it);
      return switch ('${it['role']}') {
        'owner' => hTap(
          context,
          hbox(
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
            radius: BorderRadius.circular(24),
            shadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(color: Color(0xFF0485F7), width: 1.5),
            pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: hrow(
              [
                hbox(
                  w: 48,
                  h: 48,
                  bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                  radius: BorderRadius.circular(16),
                  align: Alignment(0, 0),
                  child: Text(
                    stInitial(store),
                    style: hts(18, Color(0xFFF5D78E), w: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      hrow(
                        [
                          Flexible(
                            flex: 152,
                            child: Text(
                              store,
                              style: hts(
                                15,
                                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      hrow(
                        [
                          Flexible(
                            flex: 40,
                            child: hbox(
                              bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                              radius: BorderRadius.circular(10),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                Access.roleName('${it['role']}'),
                                style: hts(12, Color(0xFFF5D78E), w: FontWeight.w600, lh: 20),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 135,
                            child: Text(
                              hint,
                              style: hts(
                                12,
                                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                                lh: 17,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 4,
                  ),
                ),
                hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          onTap: () => pick(it),
        ),
        'technician' => hTap(
          context,
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
            pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: hrow(
              [
                hbox(
                  w: 48,
                  h: 48,
                  bg: dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16)),
                  radius: BorderRadius.circular(16),
                  align: Alignment(0, 0),
                  child: Text(
                    stInitial(store),
                    style: hts(
                      18,
                      dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        store,
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          Flexible(
                            flex: 64,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(10),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                Access.roleName('${it['role']}'),
                                style: hts(
                                  12,
                                  dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 47,
                            child: Text(
                              hint,
                              style: hts(
                                12,
                                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                                lh: 17,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 4,
                  ),
                ),
                hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          onTap: () => pick(it),
        ),
        _ => hTap(
          context,
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
            pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: hrow(
              [
                hbox(
                  w: 48,
                  h: 48,
                  bg: dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)),
                  radius: BorderRadius.circular(16),
                  align: Alignment(0, 0),
                  child: Text(
                    stInitial(store),
                    style: hts(
                      18,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        store,
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          Flexible(
                            flex: 64,
                            child: hbox(
                              bg: dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)),
                              radius: BorderRadius.circular(10),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                Access.roleName('${it['role']}'),
                                style: hts(
                                  12,
                                  dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 71,
                            child: Text(
                              hint,
                              style: hts(
                                12,
                                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                                lh: 17,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 4,
                  ),
                ),
                hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          onTap: () => pick(it),
        ),
      };
    }

    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 72, 20, 0),
            child: hcol(
              [
                hbox(
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: hcol(
                    [
                      Text(
                        '选择身份',
                        style: hts(
                          26,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 34,
                          ls: -0.52,
                        ),
                      ),
                      Text(
                        '$phone 在以下门店有身份，请选择本次进入的身份。',
                        style: hts(14, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 20),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 6,
                  ),
                ),
                for (final it in items) card(it),
                hbox(
                  margin: EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Text(
                    '下次登录会自动进入上次使用的身份，可在「我的 → 切换身份」随时切换。只有一个身份的账号不会看到这一页。',
                    style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18),
                  ),
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
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(context, Color.fromRGBO(255, 255, 255, 0.94), Color.fromRGBO(9, 9, 11, 0.92)),
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
                Flexible(
                  flex: 126,
                  child: hTap(
                    context,
                    hbox(
                      pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Text(
                        '使用其他手机号登录',
                        style: hts(
                          14,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                    onTap: () => AccessFlow.signOut(context),
                  ),
                ),
              ],
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.start,
              gap: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// 选择身份：同一手机号在多家门店有不同身份时，每次进入前选择一个。
class StIdentityLivePage extends StatefulWidget {
  const StIdentityLivePage({super.key});

  @override
  State<StIdentityLivePage> createState() => _StIdentityLivePageState();
}

class _StIdentityLivePageState extends State<StIdentityLivePage> {
  bool busy = false;

  Future<void> pick(Map<String, dynamic> it) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await AccessFlow.enter(context, it);
    } catch (e) {
      if (mounted) AccessFlow.toastError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: busy,
    child: StIdentityTemplate(items: AccessFlow.items, pick: pick),
  );
}
