// 设计稿中的线性图标（24x24 视口），由设计稿 SVG 提取。
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Map<String, String> _icons = {
  'edit': '<path d="M4 20h4L19 9a2.1 2.1 0 0 0-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
  'mail': '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M4 8l8 6 8-6"/>',
  'close': '<path d="M6 6l12 12M18 6L6 18"/>',
  'chevronRight': '<path d="M9 6l6 6-6 6"/>',
  'chevronLeft': '<path d="M15 6l-6 6 6 6"/>',
  'filter': '<path d="M4 6h16M7 12h10M10 18h4"/>',
  'phone': '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2"/>',
  'add': '<path d="M12 5v14M5 12h14"/>',
  'scan': '<path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3M4 12h16"/>',
  'arrowIn': '<path d="M17 7L7 17M15 17H7V9"/>',
  'arrowOut': '<path d="M7 17L17 7M9 7h8v8"/>',
  'clipboard': '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V3h6v1M9 11h6M9 15h4"/>',
  'warn': '<path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17h.01"/>',
  'shield': '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/>',
  'sparkle':
      '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/>',
  'drop': '<path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z"/>',
  'box':
      '<path d="M21 8 12 3 3 8v8l9 5 9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/>',
  'boxActive': '<path d="M21 8 12 3 3 8v8l9 5 9-5z" fill="#E1F0FE"/><path d="M3 8l9 5 9-5M12 13v8"/>',
  'home': '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>',
  'users': '<circle cx="9" cy="8" r="4"/><path d="M2 21v-1a6 6 0 0 1 12 0v1M16 4a4 4 0 0 1 0 8M22 21v-1a6 6 0 0 0-4-5.6"/>',
  'usersActive': '<circle cx="9" cy="8" r="4" fill="#0485F7"/><path d="M2 21v-1a6 6 0 0 1 12 0v1M16 4a4 4 0 0 1 0 8M22 21v-1a6 6 0 0 0-4-5.6"/>',
  'chart': '<path d="M4 20V11M10 20V5M16 20v-6M21 20H3"/>',
  'car': '<path d="M3 13l2-5a2 2 0 0 1 1.9-1.4h10.2A2 2 0 0 1 19 8l2 5v5a1 1 0 0 1-1 1h-1a1 1 0 0 1-1-1v-1H6v1a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z"/><path d="M3 13h18M7 16h.01M17 16h.01"/>',
  'wechat': '<path d="M9 4C5.1 4 2 6.6 2 9.8c0 1.8 1 3.4 2.6 4.5L4 16.5l2.6-1.3c.8.2 1.6.4 2.4.4"/><path d="M15 9c3.9 0 7 2.5 7 5.6 0 1.6-.8 3-2.2 4l.5 2-2.3-1.1c-.9.3-1.9.4-3 .4-3.9 0-7-2.5-7-5.6S11.1 9 15 9z"/>',
  'phoneDevice':
      '<rect x="6" y="2" width="12" height="20" rx="3"/><path d="M11 18h2"/>',
  'chevronDown': '<path d="M6 9l6 6 6-6"/>',
  'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10 21a2 2 0 0 0 4 0"/>',
  'trendUp': '<path d="M3 17l6-6 4 4 8-8"/><path d="M15 7h6v6"/>',
  'receipt':
      '<path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
  'card': '<rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10h18M16 14.5h2"/>',
  'card2': '<rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10h18M7 15h4"/>',
  'calendar': '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M3 10h18M8 3v4M16 3v4"/>',
  'arrowRight': '<path d="M5 12h14M13 6l6 6-6 6"/>',
  'chat': '<path d="M21 12a8 8 0 0 1-11.5 7.2L4 20l1-4.5A8 8 0 1 1 21 12z"/>',
  'search': '<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>',
  'check': '<path d="M5 12l5 5 9-10"/>',
  'store': '<path d="M4 10v10h16V10M3 10l2-6h14l2 6zM10 20v-5h4v5"/>',
  'crown': '<path d="M3 8l4 4 5-7 5 7 4-4-2 11H5z"/>',
  'printer': '<path d="M7 9V3h10v6M7 17H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2h-2"/><path d="M7 14h10v7H7z"/>',
  'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  'moon': '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>',
  'trash': '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5h.01"/>',
  'download': '<path d="M12 4v11M7 10l5 5 5-5M5 20h14"/>',
  'car2': '<path d="M3 13l2-5a2 2 0 0 1 1.9-1.4h10.2A2 2 0 0 1 19 8l2 5v5a1 1 0 0 1-1 1h-1a1 1 0 0 1-1-1v-1H6v1a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z"/><path d="M3 13h18"/>',
  'dots': '<path d="M5 12h.01M12 12h.01M19 12h.01"/>',
  'dotsFill': '<circle cx="5" cy="12" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="19" cy="12" r="1.8"/>',
};

const Map<String, double> _defaultStroke = {
  'add': 2.2,
  'close': 2,
  'chevronLeft': 2,
  'chevronRight': 2,
  'chevronDown': 2,
  'search': 2,
  'check': 2.6,
  'arrowRight': 2,
  'trendUp': 2.2,
  'dots': 2.4,
  'warn': 2,
  'chart': 1.8,
};

/// 设计稿图标。[name] 对应 `_icons` 中的键；[fill] 用于首页等选中态的实心图标。
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double? stroke;
  final Color? fill;
  const AppIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFF18181B),
    this.stroke,
    this.fill,
  });

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final inner = _icons[name] ?? '';
    final w = stroke ?? _defaultStroke[name] ?? 1.8;
    final isFill = name == 'dotsFill';
    final f = isFill ? _hex(color) : (fill != null ? _hex(fill!) : 'none');
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$f" '
        'stroke="${isFill ? 'none' : _hex(color)}" stroke-opacity="${color.a}" stroke-width="$w" '
        'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
    // 与 Icon 一致：父级给出紧约束时，图标仍保持自身尺寸并居中
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: SvgPicture.string(svg, width: size, height: size),
      ),
    );
  }
}
