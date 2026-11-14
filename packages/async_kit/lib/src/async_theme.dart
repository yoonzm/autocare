import 'package:flutter/material.dart';

/// Async feedback tokens supplied by the enclosing Theme, with project defaults.
/// No app-global brightness, page configuration, or full application theme lives here.
@immutable
class AsyncKitTheme extends ThemeExtension<AsyncKitTheme> {
  final Color card;
  final Color chip;
  final Color ink;
  final Color sub;
  final Color muted;
  final Color faint;
  final Color primary;
  final Color primaryInk;
  final Color primarySoft;
  final Color greenInk;
  final Color greenSoft;
  final Color amberInk;
  final Color amberSoft;
  final Color red;
  final Color redInk;
  final Color redSoft;
  final Color skeletonBase;
  final Color skeletonGlow;
  final Color toastBackground;
  final String permissionHint;
  const AsyncKitTheme({
    required this.card,
    required this.chip,
    required this.ink,
    required this.sub,
    required this.muted,
    required this.faint,
    required this.primary,
    required this.primaryInk,
    required this.primarySoft,
    required this.greenInk,
    required this.greenSoft,
    required this.amberInk,
    required this.amberSoft,
    required this.red,
    required this.redInk,
    required this.redSoft,
    required this.skeletonBase,
    required this.skeletonGlow,
    required this.toastBackground,
    this.permissionHint = '请联系管理员开通访问权限',
  });
  factory AsyncKitTheme.standard(
    Brightness brightness, {
    String permissionHint = '请联系管理员开通访问权限',
  }) {
    final dark = brightness == Brightness.dark;
    return AsyncKitTheme(
      card: Color(dark ? 0xFF18181B : 0xFFFFFFFF),
      chip: Color(dark ? 0xFF27272A : 0xFFEEEEF0),
      ink: Color(dark ? 0xFFFAFAFA : 0xFF18181B),
      sub: Color(dark ? 0xFFA8A8B3 : 0xFF52525B),
      muted: Color(dark ? 0xFF9A9AA3 : 0xFF71717A),
      faint: Color(dark ? 0xFF80808A : 0xFFA1A1AA),
      primary: Color(dark ? 0xFF0485F7 : 0xFF0485F7),
      primaryInk: Color(dark ? 0xFF6AB4FA : 0xFF1E63AE),
      primarySoft: Color(dark ? 0x2E0485F7 : 0xFFE1F0FE),
      greenInk: Color(dark ? 0xFF5FD48C : 0xFF2B7745),
      greenSoft: Color(dark ? 0x2917C964 : 0xFFDDF6E7),
      amberInk: Color(dark ? 0xFFF0C46A : 0xFF855F2E),
      amberSoft: Color(dark ? 0x29F5A524 : 0xFFFDEFD6),
      red: Color(dark ? 0xFFFF383C : 0xFFFF383C),
      redInk: Color(dark ? 0xFFFF7B7E : 0xFFA43433),
      redSoft: Color(dark ? 0x2EFF383C : 0xFFFFE4E4),
      skeletonBase: Color(dark ? 0xFF2A2A2E : 0xFFE4E4E7),
      skeletonGlow: Color(dark ? 0xFF3A3A40 : 0xFFF4F4F5),
      toastBackground: Color(dark ? 0xFF3A3A40 : 0xFF18181B),
      permissionHint: permissionHint,
    );
  }
  static AsyncKitTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AsyncKitTheme>() ??
        AsyncKitTheme.standard(theme.brightness);
  }

  TextStyle textStyle(
    double size, {
    FontWeight w = FontWeight.w400,
    Color? color,
    double? h,
  }) => TextStyle(
    fontSize: size,
    fontWeight: w,
    color: color ?? ink,
    height: h == null ? null : h / size,
    leadingDistribution: TextLeadingDistribution.even,
  );
  @override
  AsyncKitTheme copyWith({
    Color? card,
    Color? chip,
    Color? ink,
    Color? sub,
    Color? muted,
    Color? faint,
    Color? primary,
    Color? primaryInk,
    Color? primarySoft,
    Color? greenInk,
    Color? greenSoft,
    Color? amberInk,
    Color? amberSoft,
    Color? red,
    Color? redInk,
    Color? redSoft,
    Color? skeletonBase,
    Color? skeletonGlow,
    Color? toastBackground,
    String? permissionHint,
  }) => AsyncKitTheme(
    card: card ?? this.card,
    chip: chip ?? this.chip,
    ink: ink ?? this.ink,
    sub: sub ?? this.sub,
    muted: muted ?? this.muted,
    faint: faint ?? this.faint,
    primary: primary ?? this.primary,
    primaryInk: primaryInk ?? this.primaryInk,
    primarySoft: primarySoft ?? this.primarySoft,
    greenInk: greenInk ?? this.greenInk,
    greenSoft: greenSoft ?? this.greenSoft,
    amberInk: amberInk ?? this.amberInk,
    amberSoft: amberSoft ?? this.amberSoft,
    red: red ?? this.red,
    redInk: redInk ?? this.redInk,
    redSoft: redSoft ?? this.redSoft,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonGlow: skeletonGlow ?? this.skeletonGlow,
    toastBackground: toastBackground ?? this.toastBackground,
    permissionHint: permissionHint ?? this.permissionHint,
  );
  @override
  AsyncKitTheme lerp(covariant AsyncKitTheme? other, double t) {
    if (other == null) return this;
    return AsyncKitTheme(
      card: Color.lerp(card, other.card, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      sub: Color.lerp(sub, other.sub, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      greenInk: Color.lerp(greenInk, other.greenInk, t)!,
      greenSoft: Color.lerp(greenSoft, other.greenSoft, t)!,
      amberInk: Color.lerp(amberInk, other.amberInk, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      red: Color.lerp(red, other.red, t)!,
      redInk: Color.lerp(redInk, other.redInk, t)!,
      redSoft: Color.lerp(redSoft, other.redSoft, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonGlow: Color.lerp(skeletonGlow, other.skeletonGlow, t)!,
      toastBackground: Color.lerp(toastBackground, other.toastBackground, t)!,
      permissionHint: t < 0.5 ? permissionHint : other.permissionHint,
    );
  }
}
