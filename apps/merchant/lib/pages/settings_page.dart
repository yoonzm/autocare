import 'package:flutter/material.dart';

import '../theme.dart';
import '../mock/app_state.dart';
import '../mock/theme_state.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                  _profile(context),
                  const SizedBox(height: 20),
                  _group(context, '门店管理', [
                    _Item(
                      'store',
                      '门店信息',
                      '地址 · 电话 · 营业执照',
                      bg: const Color(0xFFE1F0FE),
                      fg: const Color(0xFF1E63AE),
                      route: 'StoreInfo',
                    ),
                    _Item(
                      'users',
                      '员工与权限',
                      '8 人',
                      bg: const Color(0xFFDDF6E7),
                      fg: const Color(0xFF2B7745),
                      route: 'Staff',
                    ),
                    _Item(
                      'sparkle',
                      '服务项目与价格',
                      '36 项',
                      bg: const Color(0xFFFDEFD6),
                      fg: const Color(0xFF855F2E),
                      route: 'Services',
                    ),
                    _Item(
                      'card',
                      '会员卡种与权益',
                      '4 种',
                      bg: const Color(0xFF18181B),
                      fg: const Color(0xFFF5D78E),
                      route: 'CardTiers',
                    ),
                  ]),
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
                    onTap: () => openRoute(context, 'Login'),
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

  /// 演示用：切换订阅状态，查看首页在不同状态下的呈现。
  void _demoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: ValueListenableBuilder<SubState>(
            valueListenable: subState,
            builder: (_, cur, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('汽美管家 v1.0.0', style: ts(17, w: FontWeight.w600, h: 24)),
                const SizedBox(height: 4),
                Text(
                  '演示：切换套餐状态，首页会显示对应的提醒或到期页',
                  style: ts(12, color: C.muted, h: 16),
                ),
                const SizedBox(height: 12),
                for (final st in SubState.values)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      subState.value = st;
                      Navigator.of(ctx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              subStateLabels[st]!,
                              style: ts(15, h: 22),
                            ),
                          ),
                          if (cur == st)
                            const AppIcon(
                              'check',
                              size: 18,
                              color: C.primary,
                              stroke: 2.6,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, _Item item) {
    if (item.route != null) {
      openRoute(context, item.route!);
    } else {
      toast(context, '${item.title}（演示）');
    }
  }

  Widget _profile(BuildContext context) => GestureDetector(
    // 演示入口：长按个人卡片，切换套餐状态（首页提醒条 / 到期页）
    onLongPress: () => _demoSheet(context),
    child: Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.heroCard,
        border: C.heroBorder,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(right: -90, top: -100, child: Rings(size: 240)),
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
                      '陈',
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
                              '陈明',
                              style: ts(
                                18,
                                w: FontWeight.w600,
                                color: const Color(0xFFFAFAFA),
                                h: 26,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Pill('店长', bg: C.gold, fg: C.onGold, size: 11),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '139 **** 8812',
                          style: ts(12, color: C.faint, h: 16),
                        ),
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
                          Text(
                            '驰光汽车美容 · 徐汇店',
                            style: ts(
                              14,
                              w: FontWeight.w500,
                              color: const Color(0xFFFAFAFA),
                              h: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '专业版 · 2027.10.30 到期',
                            style: ts(12, color: C.faint, h: 16),
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
    ),
  );

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
                                  child: Text(
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
  _Item(
    this.icon,
    this.title,
    this.sub, {
    this.route,
    this.bg = const Color(0xFFEEEEF0),
    this.fg = const Color(0xFF3F3F46),
    this.dot = false,
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
