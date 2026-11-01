import 'package:flutter/material.dart';

/// 设计稿色板（HeroUI 风格）。
class C {
  static const bg = Color(0xFFF4F4F5);
  static const card = Colors.white;
  static const inset = Color(0xFFF4F4F5);
  static const chip = Color(0xFFEEEEF0);
  static const segment = Color(0xFFE9E9EB);
  static const line = Color(0xFFEFEFF1);
  static const stroke = Color(0xFFE4E4E7);
  static const stroke2 = Color(0xFFD4D4D8);

  static const ink = Color(0xFF18181B);
  static const sub = Color(0xFF52525B);
  static const muted = Color(0xFF71717A);
  static const faint = Color(0xFFA1A1AA);

  static const primary = Color(0xFF0485F7);
  static const primaryInk = Color(0xFF1E63AE);
  static const primarySoft = Color(0xFFE1F0FE);
  static const green = Color(0xFF17C964);
  static const greenInk = Color(0xFF2B7745);
  static const greenSoft = Color(0xFFDDF6E7);
  static const amber = Color(0xFFF5A524);
  static const amberInk = Color(0xFF855F2E);
  static const amberSoft = Color(0xFFFDEFD6);
  static const red = Color(0xFFFF383C);
  static const redInk = Color(0xFFA43433);
  static const redSoft = Color(0xFFFFE1E2);
  static const gold = Color(0xFFF5D78E);
  static const violetInk = Color(0xFF5B3FC0);
  static const violetSoft = Color(0xFFECE6FD);
}

const softShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F000000), blurRadius: 1),
];

TextStyle ts(
  double size, {
  FontWeight w = FontWeight.w400,
  Color color = C.ink,
  double? h,
}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: color,
  height: h != null ? h / size : null,
  leadingDistribution: TextLeadingDistribution.even,
  fontFeatures: const [FontFeature.tabularFigures()],
);

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: C.bg,
  colorScheme: ColorScheme.fromSeed(seedColor: C.primary, surface: C.bg),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
);
