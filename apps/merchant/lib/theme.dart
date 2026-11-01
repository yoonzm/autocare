import 'package:flutter/material.dart';

/// 设计稿色板（HeroUI 风格），按深色模式令牌（DarkTokens）自动切换。
/// [dark] 由应用根部根据当前主题亮度同步，主题切换后整棵树会重建。
class C {
  static bool dark = false;
  static Color _p(int light, int darkV) => Color(dark ? darkV : light);

  // 背景与卡片
  static Color get bg => _p(0xFFF4F4F5, 0xFF09090B);
  static Color get card => _p(0xFFFFFFFF, 0xFF18181B);

  /// 卡片内部的凹陷填充（输入框、未选中项）
  static Color get inset => _p(0xFFF4F4F5, 0xFF27272A);
  static Color get chip => _p(0xFFEEEEF0, 0xFF27272A);
  static Color get segment => _p(0xFFE9E9EB, 0xFF1F1F23);
  static Color get line => _p(0xFFEFEFF1, 0xFF2A2A2E);
  static Color get stroke => _p(0xFFE4E4E7, 0xFF3A3A40);

  // 文字
  static Color get ink => _p(0xFF18181B, 0xFFFAFAFA);
  static Color get sub => _p(0xFF52525B, 0xFFA8A8B3);
  static Color get muted => _p(0xFF71717A, 0xFF9A9AA3);
  static Color get faint => _p(0xFFA1A1AA, 0xFF80808A);

  // 深色元素：浅色模式是黑底，深色模式分别变为 反白按钮 / 深灰卡片 / 头像底
  static Color get btn => _p(0xFF18181B, 0xFFFAFAFA);
  static Color get btnFg => _p(0xFFFFFFFF, 0xFF18181B);
  static Color get heroCard => _p(0xFF18181B, 0xFF1F1F23);
  static Color get pill => _p(0xFF18181B, 0xFF34343A);
  static Border? get heroBorder =>
      dark ? Border.all(color: const Color(0xFF2E2E33)) : null;
  static BoxDecoration hero(double radius) => BoxDecoration(
    color: heroCard,
    borderRadius: BorderRadius.circular(radius),
    border: heroBorder,
  );

  // 强调色
  static const primary = Color(0xFF0485F7);
  static Color get primaryInk => _p(0xFF1E63AE, 0xFF6AB4FA);
  static Color get primarySoft => _p(0xFFE1F0FE, 0x2E0485F7);
  static const plate = Color(0xFF0B5FD6);

  static const green = Color(0xFF17C964);
  static Color get greenInk => _p(0xFF2B7745, 0xFF5FD48C);
  static Color get greenSoft => _p(0xFFDDF6E7, 0x2917C964);

  static const amber = Color(0xFFF5A524);
  static Color get amberInk => _p(0xFF855F2E, 0xFFF0C46A);
  static Color get amberSoft => _p(0xFFFDEFD6, 0x29F5A524);

  static const red = Color(0xFFFF383C);
  static Color get redInk => _p(0xFFA43433, 0xFFFF7B7E);
  static Color get redSoft => _p(0xFFFFE4E4, 0x2EFF383C);

  static const gold = Color(0xFFF5D78E);

  /// 金色 / 反白底上的深色文字（不随主题反转）
  static const onGold = Color(0xFF18181B);
  static const dark2 = Color(0xFF27272A);
}

List<BoxShadow> get softShadow => C.dark
    ? const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)]
    : const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
        BoxShadow(color: Color(0x0F000000), blurRadius: 1),
      ];

TextStyle ts(
  double size, {
  FontWeight w = FontWeight.w400,
  Color? color,
  double? h,
  double? spacing,
  bool tabular = false,
  TextDecoration? deco,
}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: color ?? C.ink,
  height: h != null ? h / size : null,
  leadingDistribution: TextLeadingDistribution.even,
  letterSpacing: spacing,
  decoration: deco,
  fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
);

ThemeData buildTheme([Brightness brightness = Brightness.light]) {
  final dark = brightness == Brightness.dark;
  final bg = dark ? const Color(0xFF09090B) : const Color(0xFFF4F4F5);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.primary,
      brightness: brightness,
      surface: bg,
    ),
    cardColor: dark ? const Color(0xFF18181B) : Colors.white,
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xFF18181B) : Colors.white,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(backgroundColor: bg, elevation: 0),
  );
}
