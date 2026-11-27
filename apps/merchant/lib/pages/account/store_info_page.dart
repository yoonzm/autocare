import '../../kit/upload_gallery.dart';
import '../../backend/media_api.dart';
import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/page_header.dart';
import '../../kit/sheet_route.dart';
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
  bool _loaded = false;
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
      appSheetRoute<void>(
        settings: const RouteSettings(name: 'StoreEdit'),
        page: const StoreEditPage(),
      ),
    );
    if (mounted) _reload();
  }

  Widget _editButton(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _edit,
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
  );

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
      backgroundColor: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 8),
            child: AppPageHeader(
              title: '门店信息',
              trailing: _loaded ? _editButton(context) : null,
            ),
          ),
          Expanded(
            child: AsyncView<Map<String, dynamic>>(
              key: _view,
              load: _load,
              isEmpty: (_) => false,
              onLoaded: (_) {
                if (mounted && !_loaded) setState(() => _loaded = true);
              },
              onSettled: _settled,
              onNext: () => openRoute(context, 'Login'),
              skeletonPadding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              skeleton: const Column(
                children: [
                  SkeletonDashboardCard(height: 240, radius: 28),
                  SizedBox(height: 16),
                  SkeletonDashboardCard(height: 132, radius: 24),
                  SizedBox(height: 16),
                  SkeletonDashboardCard(height: 156, radius: 24),
                ],
              ),
              empty: (_) => const SizedBox.shrink(),
              builder: (_, data) => _StoreInfoView(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

/// 按营业时段判断当前是否营业；没设置营业时间返回 null（不显示状态）。
bool? _openNow(Map store, [DateTime? now]) {
  int? minutes(Object? v) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch('${v ?? ''}');
    return m == null ? null : int.parse(m[1]!) * 60 + int.parse(m[2]!);
  }

  final from = minutes(store['opens_at']);
  final to = minutes(store['closes_at']);
  if (from == null || to == null) return null;
  final t = now ?? DateTime.now();
  final cur = t.hour * 60 + t.minute;
  return from <= to ? cur >= from && cur < to : cur >= from || cur < to;
}

/// 顶部门头封面：只读展示第一张门店照片与总张数，点击查看大图；照片在「编辑」页管理。
class _StoreCover extends StatefulWidget {
  const _StoreCover({super.key});
  @override
  State<_StoreCover> createState() => _StoreCoverState();
}

class _StoreCoverState extends State<_StoreCover> {
  late final Future<List<UploadRecord>> _photos = MediaApi.store(merchantApi)
      .load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UploadRecord>>(
      future: _photos,
      builder: (context, snap) {
        final photos = snap.data ?? const <UploadRecord>[];
        final base = dk(context, Color(0xFFE4E4E7), Color(0xFF27272A));
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: photos.isEmpty
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ImageViewerPage(
                      images: [for (final p in photos) p.image],
                    ),
                  ),
                ),
          child: SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: base),
                if (photos.isNotEmpty)
                  Image(
                    image: photos.first.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  )
                else if (snap.connectionState == ConnectionState.done)
                  Center(
                    child: Text(
                      '暂无门店照片',
                      style: hts(
                        13,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ),
                if (photos.isNotEmpty)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xB3000000),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '共 ${photos.length} 张',
                        style: hts(
                          12,
                          Colors.white,
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StoreInfoView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StoreInfoView({required this.data});

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
    // 省市区之间不加分隔符，与详细地址连成一句
    final address = [
      '${store['city'] ?? ''}'.replaceAll(RegExp(r'\s*·\s*'), '').trim(),
      '${store['address'] ?? ''}'.trim(),
    ].where((v) => v.isNotEmpty).join();
    final phone = '${store['phone'] ?? ''}'.replaceFirst(RegExp(r'^\+86'), '');
    final open = _openNow(store);
    return SingleChildScrollView(
      child: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: hcol(
              [
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
                      _StoreCover(key: ObjectKey(store)),
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
                                if (open != null)
                                  hbox(
                                    bg: open
                                        ? dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          )
                                        : dk(
                                            context,
                                            Color(0xFFEEEEF0),
                                            Color(0xFF27272A),
                                          ),
                                    radius: BorderRadius.circular(11),
                                    pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 6,
                                          h: 6,
                                          bg: open
                                              ? Color(0xFF17C964)
                                              : Color(0xFFA1A1AA),
                                          radius: BorderRadius.circular(3),
                                        ),
                                        Text(
                                          open ? '营业中' : '休息中',
                                          style: hts(
                                            12,
                                            open
                                                ? dk(
                                                    context,
                                                    Color(0xFF2B7745),
                                                    Color(0xFF5FD48C),
                                                  )
                                                : dk(
                                                    context,
                                                    Color(0xFF3F3F46),
                                                    Color(0xFFD4D4D8),
                                                  ),
                                            w: FontWeight.w500,
                                            lh: 22,
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
                                    '门店编号 ${store['store_code'] ?? '—'}',
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
                                    phone.isEmpty ? '—' : phone,
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
                                      '${store['hours_text'] ?? '—'}',
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
    );
  }
}
