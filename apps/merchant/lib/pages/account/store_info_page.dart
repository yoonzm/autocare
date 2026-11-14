import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/page_header.dart';
import 'store_edit_page.dart';
import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class StoreInfoPage extends StatefulWidget {
  const StoreInfoPage({super.key});
  @override
  State<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<StoreInfoPage> {
  final _view = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  bool _pending = false;
  @override
  void initState() {
    super.initState();
    AppointmentFlow.changed.addListener(_reload);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_reload);
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() async {
    final values = await Future.wait([
      merchantApi.getStore(),
      merchantApi.appointment('options'),
    ]);
    return dataSnapshot({'store': values[0], 'options': values[1]});
  }

  void _reload() {
    if (!mounted) return;
    if (_view.currentState?.busy == true) {
      _pending = true;
      return;
    }
    _view.currentState?.reload();
  }

  void _settled() {
    if (!mounted || !_pending) return;
    _pending = false;
    _view.currentState?.reload();
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'StoreEdit'),
        builder: (_) => const StoreEditPage(),
      ),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return Scaffold(
      body: AsyncView<Map<String, dynamic>>(
        key: _view,
        load: _load,
        isEmpty: (_) => false,
        onSettled: _settled,
        onNext: () => openRoute(context, 'Login'),
        skeletonPadding: EdgeInsets.all(20),
        skeleton: Column(
          children: const [
            AppPageHeader(title: '门店信息'),
            SizedBox(height: 20),
            SkeletonDashboardCard(height: 240, radius: 24),
            SizedBox(height: 16),
            SkeletonList(count: 4),
          ],
        ),
        empty: (_) => const SizedBox.shrink(),
        builder: (_, data) => _StoreInfoView(data: data, onEdit: _edit),
      ),
    );
  }
}

class _StoreInfoView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  const _StoreInfoView({required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final store = data['store'] as Map;
    final resources =
        ((data['options'] as Map)['resources'] as List? ?? const []);
    final bays = resources
        .where((r) => r['kind'] == 'bay' && r['active'] != false)
        .toList();
    int count(String category) =>
        bays.where((r) => r['category'] == category).length;
    final address = [
      store['city'],
      store['address'],
    ].where((v) => v != null && '$v'.trim().isNotEmpty).join(' ');
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 800,
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
                          [hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '门店信息',
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
                      onTap: onEdit,
                      child: hbox(
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
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '编辑',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(28),
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
                  clip: true,
                  child: hcol(
                    [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // TODO: 门店门头照片尚无读取/上传/保存接口，预期 store_profile storefront_photo_url；不能选择本地图片冒充已保存。
                          hToast(context, '门店照片暂未接通：缺少读取与保存接口');
                        },
                        child: hbox(
                          h: 150,
                          bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                          child: hstack(
                            hcol(
                              [
                                hsvg(
                                  dk(context, Svgs.s372, Svgs.s373),
                                  w: 28,
                                  h: 28,
                                ),
                                Text(
                                  '[门店门头照片]',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                              min: false,
                            ),
                            [
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: hbox(
                                  bg: Color.fromRGBO(24, 24, 27, 0.7),
                                  radius: BorderRadius.circular(12),
                                  pad: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Text(
                                    '—',
                                    style: hts(
                                      12,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w500,
                                      lh: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: hcol(
                          [
                            Text(
                              '${store['name'] ?? '—'}',
                              style: hts(
                                19,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 26,
                                ls: -0.38,
                              ),
                            ),
                            hwrap(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFDDF6E7),
                                    Color.fromRGBO(23, 201, 100, 0.16),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 6,
                                        h: 6,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(3),
                                      ),
                                      Flexible(
                                        flex: 36,
                                        child: Text(
                                          '—',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 5,
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '限时免费',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '门店编号 ${store['id'] ?? '—'}',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                              ],
                              gap: 6,
                              rowGap: 6,
                              cross: WrapCrossAlignment.start,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 8,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s374, Svgs.s375),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '门店地址',
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
                                  Text(
                                    address.isEmpty ? '—' : address,
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                /* TODO: 接入地图导航渠道与门店坐标后开启。 */
                                hToast(context, 'TODO：地图导航尚未接通');
                              },
                              child: Text(
                                '导航',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 20,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s376, Svgs.s377),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '联系电话',
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
                                  Text(
                                    '${store['phone'] ?? '—'}',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'BusinessHours'),
                        child: hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                                child: hsvg(
                                  dk(context, Svgs.s378, Svgs.s379),
                                  w: 20,
                                  h: 20,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '营业时间',
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
                                    Text(
                                      '${store['hours_line'] ?? '—'}',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.start,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'BusinessHours'),
                        child: hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                                child: hsvg(
                                  dk(context, Svgs.s380, Svgs.s381),
                                  w: 20,
                                  h: 20,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '工位配置 · 共 ${bays.length} 个',
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
                                    hrow(
                                      [
                                        Flexible(
                                          flex: 51,
                                          child: hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFE1F0FE),
                                              Color.fromRGBO(4, 133, 247, 0.18),
                                            ),
                                            radius: BorderRadius.circular(11),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '洗车 ${count('洗车')}',
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  Color(0xFF1E63AE),
                                                  Color(0xFF6AB4FA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 51,
                                          child: hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFDDF6E7),
                                              Color.fromRGBO(
                                                23,
                                                201,
                                                100,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(11),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '美容 ${count('美容')}',
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  Color(0xFF2B7745),
                                                  Color(0xFF5FD48C),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 63,
                                          child: hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFFDEFD6),
                                              Color.fromRGBO(
                                                245,
                                                165,
                                                36,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(11),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '贴膜间 ${count('贴膜')}',
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  Color(0xFF855F2E),
                                                  Color(0xFFF0C46A),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 6,
                                      intrinsic: true,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 6,
                                ),
                              ),
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.start,
                            gap: 12,
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
