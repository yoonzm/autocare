import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Internal renderer for monochrome button icons; button state owns the tint.
Widget buttonIcon(
  BuildContext context, {
  IconData? icon,
  String? svg,
  String? darkSvg,
  required double size,
  required Color color,
}) {
  if (svg == null) return Icon(icon, size: size, color: color);
  final source = Theme.of(context).brightness == Brightness.dark
      ? darkSvg ?? svg
      : svg;
  return SvgPicture.string(
    source,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
