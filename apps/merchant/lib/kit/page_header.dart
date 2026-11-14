import 'package:flutter/material.dart';

import '../resources/merchant_svgs.dart';
import 'kit.dart';

/// 顶部栏左侧按钮的图标：返回箭头 / 关闭 ✕。
enum AppHeaderLeading { back, close }

/// 页面顶部栏（44px 白色圆形按钮 + 居中 17px 标题 + 右侧 44px 占位或操作），样式取自设计稿。
///
/// 骨架屏和真实页面的固定外壳都用它，保证加载中看到的标题栏和加载后完全一致。
class AppPageHeader extends StatelessWidget {
  final String title;
  final AppHeaderLeading leading;

  /// 右侧操作（如“保存”文字、黑色 + 圆钮）；为空时留 44px 占位，标题保持居中。
  final Widget? trailing;
  const AppPageHeader({
    super.key,
    required this.title,
    this.leading = AppHeaderLeading.back,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: hbox(
          w: 44,
          h: 44,
          bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(22),
          shadow: dk(
            context,
            const [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 1),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
            const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)],
          ),
          child: Center(
            child: hsvg(
              leading == AppHeaderLeading.back
                  ? dk(context, Svgs.s0, Svgs.s1)
                  : dk(context, Svgs.s26, Svgs.s27),
              w: 20,
              h: 20,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: hts(
            17,
            dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
            w: FontWeight.w600,
            lh: 24,
          ),
        ),
      ),
      const SizedBox(width: 8),
      trailing ?? const SizedBox(width: 44, height: 44),
    ],
  );
}

/// 页面右上角的黑色圆形图标按钮（如“新增”）。
class AppHeaderAction extends StatelessWidget {
  final String lightSvg, darkSvg;
  final VoidCallback? onTap;
  final String label;
  const AppHeaderAction({
    super.key,
    required this.lightSvg,
    required this.darkSvg,
    required this.label,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: hbox(
        w: 44,
        h: 44,
        bg: dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
        radius: BorderRadius.circular(22),
        child: Center(
          child: hsvg(dk(context, lightSvg, darkSvg), w: 20, h: 20),
        ),
      ),
    ),
  );
}
