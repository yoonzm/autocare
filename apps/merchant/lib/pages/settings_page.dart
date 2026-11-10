import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/access_flow.dart';
import '../backend/appointment_flow.dart';
import '../kit/async_kit.dart';
import '../backend/catalog_draft.dart';
import '../backend/store_profile.dart';
import '../backend/profile_flow.dart';
import '../theme.dart';
import '../mock/theme_state.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _countsKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  final _profileKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();

  @override
  void initState() {
    super.initState();
    CatalogDraft.changed.addListener(_reloadCounts);
    AppointmentFlow.changed.addListener(_reloadCounts);
    ProfileFlow.changed.addListener(_reloadProfile);
  }

  @override
  void dispose() {
    CatalogDraft.changed.removeListener(_reloadCounts);
    AppointmentFlow.changed.removeListener(_reloadCounts);
    ProfileFlow.changed.removeListener(_reloadProfile);
    super.dispose();
  }

  void _reloadCounts() => _countsKey.currentState?.reload();
  void _reloadProfile() => _profileKey.currentState?.reload();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SubHeader('我的'),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  SizedBox(
                    height: C.dark ? 176 : 174,
                    child: AsyncView<Map<String, dynamic>>(
                      key: _profileKey,
                      load: _loadProfile,
                      isEmpty: (_) => false,
                      inlineError: true,
                      pullToRefresh: false,
                      skeletonScrollable: false,
                      skeletonPadding: EdgeInsets.zero,
                      waiting: const SizedBox(height: 174),
                      skeleton: _profileSkeleton(),
                      empty: (_) => const SizedBox.shrink(),
                      onLoaded: storeProfile.apply,
                      onNext: () => openRoute(context, 'Login'),
                      builder: (context, data) => _profile(context, data),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 263,
                    child: AsyncView<Map<String, dynamic>>(
                      key: _countsKey,
                      load: merchantApi.settingsStats,
                      isEmpty: (_) => false,
                      inlineError: true,
                      pullToRefresh: false,
                      skeletonScrollable: false,
                      skeletonPadding: EdgeInsets.zero,
                      waiting: _management(context),
                      skeleton: _management(context, null, true),
                      empty: (_) => const SizedBox.shrink(),
                      onNext: () => openRoute(context, 'Login'),
                      builder: (context, counts) =>
                          _management(context, counts),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _group(context, '营业设置', [
                    _Item(
                      'crown',
                      '套餐与订阅',
                      '专业版 · 365 天后到期',
                      bg: const Color(0xFFF5D78E),
                      fg: const Color(0xFF18181B),
                      route: 'Subscription',
                    ),
                    _Item(
                      'card2',
                      '支付与收款',
                      '微信 · 支付宝 · 储值',
                      bg: const Color(0xFFDDF6E7),
                      fg: const Color(0xFF2B7745),
                      route: 'PayConfig',
                    ),
                    _Item(
                      'printer',
                      '小票打印机',
                      '已连接',
                      dot: true,
                      route: 'Printer',
                    ),
                    _Item(
                      'clock',
                      '营业时间与工位',
                      '09:00–20:00 · 6 工位',
                      bg: const Color(0xFFE1F0FE),
                      fg: const Color(0xFF1E63AE),
                      route: 'BusinessHours',
                    ),
                    _Item(
                      'bell',
                      '通知与消息',
                      '会员消费充值 · 微信 / 短信',
                      bg: const Color(0xFFFFE1E2),
                      fg: const Color(0xFFA43433),
                      route: 'NotifySettings',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _group(context, '通用', [
                    _Item('shield', '账号与安全', '密码 · 登录设备', route: 'Security'),
                    _Item(
                      'moon',
                      '外观',
                      themeModeLabel(appThemeMode.value),
                      route: 'ThemeSheet',
                    ),
                    _Item('mail', '数据备份', '已开启', route: 'DataBackup'),
                    _Item('trash', '清除缓存', '128 MB', route: 'ClearCache'),
                    _Item('info', '关于汽美管家', 'v1.0.0', route: 'AboutApp'),
                  ]),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await merchantApi.signOut();
                        CatalogDraft.current = null;
                        if (context.mounted) openRoute(context, 'Login');
                      } catch (e) {
                        if (context.mounted) toast(context, '退出失败：$e');
                      }
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: softShadow,
                      ),
                      child: Text(
                        '退出登录',
                        style: ts(
                          16,
                          w: FontWeight.w600,
                          color: C.redInk,
                          h: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _management(
    BuildContext context, [
    Map<String, dynamic>? counts,
    bool skeleton = false,
  ]) => _group(context, '门店管理', [
    _Item(
      'store',
      '门店信息',
      '地址 · 电话 · 营业时间',
      bg: const Color(0xFFE1F0FE),
      fg: const Color(0xFF1E63AE),
      route: 'StoreInfo',
    ),
    _Item(
      'users',
      '员工与权限',
      counts == null ? '' : '${counts['staff']} 人',
      bg: const Color(0xFFDDF6E7),
      fg: const Color(0xFF2B7745),
      route: 'Staff',
      skeleton: skeleton,
    ),
    _Item(
      'sparkle',
      '服务项目与价格',
      counts == null ? '' : '${counts['services']} 项',
      bg: const Color(0xFFFDEFD6),
      fg: const Color(0xFF855F2E),
      route: 'Services',
      skeleton: skeleton,
    ),
    _Item(
      'card',
      '会员卡种与权益',
      counts == null ? '' : '${counts['cards']} 种',
      bg: const Color(0xFF18181B),
      fg: const Color(0xFFF5D78E),
      route: 'CardTiers',
      skeleton: skeleton,
    ),
  ]);

  void _open(BuildContext context, _Item item) {
    if (item.route != null) {
      openRoute(context, item.route!);
    } else {
      toast(context, '${item.title}（演示）');
    }
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final store = await merchantApi.getStore();
    // 店长使用同一个商家外壳，个人信息必须来自当前员工身份。
    final identity = Access.isOwner
        ? null
        : await merchantApi.identity('context');
    return {...store, '_identity': identity};
  }

  Widget _profileSkeleton() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.heroCard,
      border: C.heroBorder,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            AppSkeleton(width: 56, height: 56, radius: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 120, height: 26),
                  SizedBox(height: 4),
                  AppSkeleton(width: 108, height: 16),
                ],
              ),
            ),
            AppSkeleton(width: 40, height: 40, radius: 20),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: C.dark2,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 160, height: 20),
              SizedBox(height: 2),
              AppSkeleton(width: 130, height: 16),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _profile(BuildContext context, Map<String, dynamic> data) {
    final identity = data['_identity'] as Map<String, dynamic>?;
    final name =
        '${identity == null ? data['contact_name'] ?? '' : identity['name'] ?? ''}'
            .trim();
    final contactRole = '${data['contact_role'] ?? ''}'.trim();
    final role = identity == null
        ? (contactRole.isEmpty ? Access.roleBrief('owner') : contactRole)
        : Access.roleBrief('${identity['role']}');
    final phone =
        '${identity == null ? data['account_phone'] ?? '' : identity['phone'] ?? ''}'
            .replaceAll(RegExp(r'\D'), '');
    final localPhone = phone.length >= 11
        ? phone.substring(phone.length - 11)
        : phone;
    final maskedPhone = localPhone.length == 11
        ? '${localPhone.substring(0, 3)} **** ${localPhone.substring(7)}'
        : (localPhone.isEmpty ? '—' : localPhone);
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.heroCard,
        border: C.heroBorder,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -110,
            top: -110,
            child: Rings(size: 240, viewBox: 240, radii: [60, 90, 118]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: C.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: C.dark2, spreadRadius: 3)],
                    ),
                    child: Text(
                      name.isEmpty ? '—' : name.characters.first,
                      style: ts(20, w: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name.isEmpty ? '—' : name,
                              style: ts(
                                18,
                                w: FontWeight.w600,
                                color: const Color(0xFFFAFAFA),
                                h: 26,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Pill(role, bg: C.gold, fg: C.onGold, size: 11),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(maskedPhone, style: ts(12, color: C.faint, h: 16)),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: '编辑资料',
                    child: GestureDetector(
                      onTap: () => openRoute(context, 'ProfileEdit'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: C.dark2,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AppIcon(
                            'edit',
                            size: 18,
                            color: Color(0xFFFAFAFA),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: C.dark2,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListenableBuilder(
                            listenable: storeProfile,
                            builder: (_, _) => Text(
                              storeProfile.live ? storeProfile.name : '—',
                              style: ts(
                                14,
                                w: FontWeight.w500,
                                color: const Color(0xFFFAFAFA),
                                h: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          ListenableBuilder(
                            listenable: storeProfile,
                            builder: (_, _) => Text(
                              storeProfile.live ? storeProfile.expiryLine : '—',
                              style: ts(12, color: C.faint, h: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openRoute(context, 'StoreSwitch'),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '切换门店',
                          style: ts(
                            13,
                            w: FontWeight.w500,
                            color: C.onGold,
                            h: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<_Item> items) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: ts(13, w: FontWeight.w500, color: C.muted, h: 18),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _open(context, items[i]),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _darkPair(items[i].bg, true),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: AppIcon(
                                items[i].icon,
                                size: 18,
                                color: _darkPair(items[i].fg, false),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(items[i].title, style: ts(15, h: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (items[i].dot) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: C.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Flexible(
                                  child: items[i].skeleton
                                      ? const AppSkeleton(width: 38, height: 16)
                                      : Text(
                                          items[i].sub,
                                          textAlign: TextAlign.right,
                                          style: ts(
                                            13,
                                            color: items[i].dot
                                                ? C.greenInk
                                                : C.muted,
                                            h: 18,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppIcon(
                            'chevronRight',
                            size: 16,
                            color: C.faint,
                            stroke: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < items.length - 1) const Divider1(indent: 60),
                ],
              ],
            ),
          ),
        ],
      );
}

class _Item {
  final String icon;
  final String title, sub;
  final String? route;
  final Color bg, fg;
  final bool dot;
  final bool skeleton;
  _Item(
    this.icon,
    this.title,
    this.sub, {
    this.route,
    this.bg = const Color(0xFFEEEEF0),
    this.fg = const Color(0xFF3F3F46),
    this.dot = false,
    this.skeleton = false,
  });
}

/// 设置项图标的底色 / 前景色在深色模式下的对应关系。
Color _darkPair(Color c, bool bg) {
  if (!C.dark) return c;
  const m = {
    0xFFE1F0FE: 0x2E0485F7,
    0xFFDDF6E7: 0x2917C964,
    0xFFFDEFD6: 0x29F5A524,
    0xFFFFE1E2: 0x2EFF383C,
    0xFFEEEEF0: 0xFF34343A,
    0xFF18181B: 0xFF34343A,
    0xFF1E63AE: 0xFF6AB4FA,
    0xFF2B7745: 0xFF5FD48C,
    0xFF855F2E: 0xFFF0C46A,
    0xFFA43433: 0xFFFF7B7E,
    0xFF3F3F46: 0xFFA8A8B3,
  };
  final v = m[c.toARGB32()];
  return v == null ? c : Color(v);
}
