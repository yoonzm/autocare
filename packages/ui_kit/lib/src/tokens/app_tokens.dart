import 'package:flutter/material.dart';

/// 浅底 + 深字成对出现的状态色。
@immutable
class StatusColors {
  final Color bg;
  final Color fg;
  const StatusColors(this.bg, this.fg);

  static StatusColors lerp(StatusColors a, StatusColors b, double t) =>
      StatusColors(Color.lerp(a.bg, b.bg, t)!, Color.lerp(a.fg, b.fg, t)!);
}

/// 圆角刻度（设计稿「令牌」）。
abstract final class AppRadius {
  static const double tag = 9;
  static const double tile = 12;
  static const double field = 14;
  static const double inset = 16;
  static const double block = 20;
  static const double card = 24;
  static const double hero = 28;
  static const double sheet = 32;
}

/// 间距刻度：只用这些值。页面左右边距 20，卡片内边距 16，卡片之间 16。
abstract final class AppSpacing {
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double pageGutter = 20;
  static const double cardPadding = 16;
  static const double minTap = 44;
}

/// 组件库的全部取值：颜色、字号、阴影。组件只引用令牌，不写色值，深色模式才能自动生效。
///
/// 取值：`AppTokens.of(context)`。应用主题里注册了 [AppTokens] 扩展就用扩展，
/// 否则按当前主题亮度取 [light] / [dark]。
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  // 主色（只有一个蓝；黑色是文字色，不作为选中色或按钮色）
  final Color primary;
  final Color primaryPressed;
  final Color primarySoft;
  final Color primaryText;
  final Color plate;
  final Color success;
  final Color requiredStar;
  // 文字
  final Color ink;
  final Color inkSub;
  final Color inkMute;
  final Color inkFaint;
  final Color onPrimary;
  // 表面
  final Color bg;
  final Color surface;
  final Color inset;
  final Color fill;
  final Color fillStrong;
  final Color line;
  final Color switchOff;
  final Color segment;
  final Color segmentActive;
  final Color overlay;
  final Color pressedOverlay;
  // 状态色
  final StatusColors ok;
  final StatusColors wait;
  final StatusColors warn;
  final StatusColors danger;
  final StatusColors off;
  final StatusColors violet;
  final StatusColors goldTag;
  final StatusColors okOnDark;
  final StatusColors darkTag;
  final Color gold;
  final Color badge;
  // 深色元素
  final Color heroBg;
  final Color heroBorder;
  final Color heroInk;
  final Color heroInkSub;
  final Color heroRing;
  final List<Color> heroGradient;
  final Color heroGlow;
  final Color darkAvatarBg;
  final Color thumbShadow;
  final Color scanGlow;
  // 阴影：浅色是三层卡片阴影，深色改为 1px 细描边
  final bool darkMode;

  const AppTokens({
    required this.primary,
    required this.primaryPressed,
    required this.primarySoft,
    required this.primaryText,
    required this.plate,
    required this.success,
    required this.requiredStar,
    required this.ink,
    required this.inkSub,
    required this.inkMute,
    required this.inkFaint,
    required this.onPrimary,
    required this.bg,
    required this.surface,
    required this.inset,
    required this.fill,
    required this.fillStrong,
    required this.line,
    required this.switchOff,
    required this.segment,
    required this.segmentActive,
    required this.overlay,
    required this.pressedOverlay,
    required this.ok,
    required this.wait,
    required this.warn,
    required this.danger,
    required this.off,
    required this.violet,
    required this.goldTag,
    required this.okOnDark,
    required this.darkTag,
    required this.gold,
    required this.badge,
    required this.heroBg,
    required this.heroBorder,
    required this.heroInk,
    required this.heroInkSub,
    required this.heroRing,
    required this.heroGradient,
    required this.heroGlow,
    required this.darkAvatarBg,
    required this.thumbShadow,
    required this.scanGlow,
    required this.darkMode,
  });

  static const light = AppTokens(
    primary: Color(0xFF0485F7),
    primaryPressed: Color(0xFF0472D6),
    primarySoft: Color(0xFFE1F0FE),
    primaryText: Color(0xFF1E63AE),
    plate: Color(0xFF0B5FD6),
    success: Color(0xFF17C964),
    requiredStar: Color(0xFFA43433),
    ink: Color(0xFF18181B),
    inkSub: Color(0xFF52525B),
    inkMute: Color(0xFF71717A),
    inkFaint: Color(0xFFA1A1AA),
    onPrimary: Color(0xFFFFFFFF),
    bg: Color(0xFFF4F4F5),
    surface: Color(0xFFFFFFFF),
    inset: Color(0xFFF4F4F5),
    fill: Color(0xFFEEEEF0),
    fillStrong: Color(0xFFE4E4E7),
    line: Color(0xFFEFEFF1),
    switchOff: Color(0xFFD4D4D8),
    segment: Color(0xFFE9E9EB),
    segmentActive: Color(0xFFFFFFFF),
    overlay: Color(0x80000000),
    pressedOverlay: Color(0x0A000000),
    ok: StatusColors(Color(0xFFDDF6E7), Color(0xFF2B7745)),
    wait: StatusColors(Color(0xFFE1F0FE), Color(0xFF1E63AE)),
    warn: StatusColors(Color(0xFFFDEFD6), Color(0xFF855F2E)),
    danger: StatusColors(Color(0xFFFFE1E2), Color(0xFFA43433)),
    off: StatusColors(Color(0xFFEEEEF0), Color(0xFF3F3F46)),
    violet: StatusColors(Color(0xFFECE6FD), Color(0xFF5B3FC0)),
    goldTag: StatusColors(Color(0x29F5D78E), Color(0xFFF5D78E)),
    okOnDark: StatusColors(Color(0x3317C964), Color(0xFF6EE7A8)),
    darkTag: StatusColors(Color(0xFF18181B), Color(0xFFF5D78E)),
    gold: Color(0xFFF5D78E),
    badge: Color(0xFFFF383C),
    heroBg: Color(0xFF18181B),
    heroBorder: Color(0x00000000),
    heroInk: Color(0xFFFAFAFA),
    heroInkSub: Color(0xFFA1A1AA),
    heroRing: Color(0xFF34343A),
    heroGradient: [Color(0xFF26262C), Color(0xFF18181B), Color(0xFF2B2418)],
    heroGlow: Color(0x4DF5D78E),
    darkAvatarBg: Color(0xFF18181B),
    thumbShadow: Color(0x33000000),
    scanGlow: Color(0x4D0485F7),
    darkMode: false,
  );

  static const dark = AppTokens(
    primary: Color(0xFF0485F7),
    primaryPressed: Color(0xFF0472D6),
    primarySoft: Color(0x2E0485F7),
    primaryText: Color(0xFF6AB4FA),
    plate: Color(0xFF0B5FD6),
    success: Color(0xFF17C964),
    requiredStar: Color(0xFFFF7B7E),
    ink: Color(0xFFFAFAFA),
    inkSub: Color(0xFFA8A8B3),
    inkMute: Color(0xFF9A9AA3),
    inkFaint: Color(0xFF80808A),
    onPrimary: Color(0xFFFFFFFF),
    bg: Color(0xFF09090B),
    surface: Color(0xFF18181B),
    inset: Color(0xFF27272A),
    fill: Color(0xFF27272A),
    fillStrong: Color(0xFF3A3A40),
    line: Color(0xFF2A2A2E),
    switchOff: Color(0xFF3A3A40),
    segment: Color(0xFF1F1F23),
    segmentActive: Color(0xFF3A3A40),
    overlay: Color(0x99000000),
    pressedOverlay: Color(0x0FFFFFFF),
    ok: StatusColors(Color(0x2917C964), Color(0xFF5FD48C)),
    wait: StatusColors(Color(0x2E0485F7), Color(0xFF6AB4FA)),
    warn: StatusColors(Color(0x29F5A524), Color(0xFFF0C46A)),
    danger: StatusColors(Color(0x2EFF383C), Color(0xFFFF7B7E)),
    off: StatusColors(Color(0xFF27272A), Color(0xFFA8A8B3)),
    violet: StatusColors(Color(0x2E7C5CE6), Color(0xFFB6A2F5)),
    goldTag: StatusColors(Color(0x29F5D78E), Color(0xFFF5D78E)),
    okOnDark: StatusColors(Color(0x3317C964), Color(0xFF6EE7A8)),
    darkTag: StatusColors(Color(0xFF34343A), Color(0xFFF5D78E)),
    gold: Color(0xFFF5D78E),
    badge: Color(0xFFFF383C),
    heroBg: Color(0xFF1F1F23),
    heroBorder: Color(0xFF26262B),
    heroInk: Color(0xFFFAFAFA),
    heroInkSub: Color(0xFFA1A1AA),
    heroRing: Color(0xFF34343A),
    heroGradient: [Color(0xFF26262C), Color(0xFF18181B), Color(0xFF2B2418)],
    heroGlow: Color(0x4DF5D78E),
    darkAvatarBg: Color(0xFF34343A),
    thumbShadow: Color(0x33000000),
    scanGlow: Color(0x4D0485F7),
    darkMode: true,
  );

  static AppTokens forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// 取当前主题的令牌：优先主题扩展，否则按亮度。
  static AppTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppTokens>() ?? forBrightness(theme.brightness);
  }

  /// 卡片阴影：浅色三层，深色改为 1px 细描边。
  List<BoxShadow> get cardShadow => darkMode
      ? const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)]
      : const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0F000000), blurRadius: 1),
        ];

  // ───────── 字号：size/lineHeight · weight ─────────
  static const _fallback = ['PingFang SC', 'Noto Sans SC', 'Microsoft YaHei'];
  TextStyle _t(double size, double h, FontWeight w, Color color) => TextStyle(
    fontSize: size,
    height: h / size,
    fontWeight: w,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
    fontFamilyFallback: _fallback,
  );

  /// 32/38 · 600，如 ¥3,840。
  TextStyle get display => _t(32, 38, FontWeight.w600, ink);

  /// 20/28 · 600，如「开单收银」、弹层标题。
  TextStyle get title => _t(20, 28, FontWeight.w600, ink);

  /// 17/24 · 600，页面标题。
  TextStyle get page => _t(17, 24, FontWeight.w600, ink);

  /// 15/22 · 500，列表标题、输入文字。
  TextStyle get body => _t(15, 22, FontWeight.w500, ink);

  /// 14/20 · 500，行标题、标签文字。
  TextStyle get base => _t(14, 20, FontWeight.w500, ink);

  /// 13/18 · 500，选择标签、辅助说明。
  TextStyle get small => _t(13, 18, FontWeight.w500, ink);

  /// 12/16 · 400，副标题、提示。
  TextStyle get caption => _t(12, 16, FontWeight.w400, inkMute);

  /// 11/14 · 600，状态标签、底部导航。
  TextStyle get micro => _t(11, 14, FontWeight.w600, ink);

  /// 金额、数量使用等宽数字。
  static const tabular = [FontFeature.tabularFigures()];

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) =>
      other is AppTokens ? (t < .5 ? this : other) : this;
}
