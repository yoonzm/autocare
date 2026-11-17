import 'package:flutter/material.dart';

import '../resources/merchant_svgs.dart';
import 'kit.dart';

/// 顶部栏左侧按钮的图标：返回箭头 / 关闭 ✕。
enum AppHeaderLeading { back, close, none }

/// 页面顶部栏（44px 白色圆形按钮 + 居中 17px 标题 + 右侧 44px 占位或操作），样式取自设计稿。
///
/// 骨架屏和真实页面的固定外壳都用它，保证加载中看到的标题栏和加载后完全一致。
class AppPageHeader extends StatelessWidget {
  final String title;

  /// 标题位置放自定义内容（搜索框、分段控件等）；传了就不再显示 [title]。
  final Widget? center;
  final AppHeaderLeading leading;

  /// 左上角按钮的点击；不传时返回上一页（`maybePop`）。
  final VoidCallback? onLeading;

  /// 为 false 时左上角按钮不响应（如提交中）。
  final bool leadingEnabled;

  /// 右侧操作（如“保存”文字、黑色 + 圆钮）；为空时留 44px 占位，标题保持居中。
  final Widget? trailing;
  const AppPageHeader({
    super.key,
    this.title = '',
    this.center,
    this.leading = AppHeaderLeading.back,
    this.onLeading,
    this.leadingEnabled = true,
    this.trailing,
  });

  Widget _leading(BuildContext context) => leading == AppHeaderLeading.none
      ? const SizedBox(width: 44, height: 44)
      : AppHeaderCircle(
          lightSvg: leading == AppHeaderLeading.back ? Svgs.s0 : Svgs.s26,
          darkSvg: leading == AppHeaderLeading.back ? Svgs.s1 : Svgs.s27,
          label: leading == AppHeaderLeading.back ? '返回' : '关闭',
          onTap: !leadingEnabled
              ? null
              : onLeading ?? () => Navigator.of(context).maybePop(),
        );

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing ?? const SizedBox(width: 44, height: 44);
    // 自定义标题区（搜索框、分段控件）要占满两侧按钮之间的宽度。
    if (center != null) {
      return Row(
        children: [
          _leading(context),
          const SizedBox(width: 8),
          Expanded(child: center!),
          const SizedBox(width: 8),
          trailingWidget,
        ],
      );
    }
    // 纯文字标题：按整行居中，不受两侧按钮宽度不同的影响（右侧是「保存」「挂单」这类变宽按钮时也一样）；
    // 标题最宽只到较宽那一侧按钮的内侧，太长时省略。
    return SizedBox(
      height: 44,
      child: CustomMultiChildLayout(
        delegate: _HeaderLayout(),
        children: [
          LayoutId(id: _HeaderSlot.leading, child: _leading(context)),
          LayoutId(
            id: _HeaderSlot.title,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: hts(
                17,
                dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 24,
              ),
            ),
          ),
          LayoutId(id: _HeaderSlot.trailing, child: trailingWidget),
        ],
      ),
    );
  }
}

enum _HeaderSlot { leading, title, trailing }

class _HeaderLayout extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // 两侧按钮和原来的 Row 一样：宽度不受限（按自身内容定宽），高度不超过标题栏。
    final loose = BoxConstraints(maxHeight: size.height);
    final l = layoutChild(_HeaderSlot.leading, loose);
    final t = layoutChild(_HeaderSlot.trailing, loose);
    positionChild(_HeaderSlot.leading, Offset(0, (size.height - l.height) / 2));
    positionChild(
      _HeaderSlot.trailing,
      Offset(size.width - t.width, (size.height - t.height) / 2),
    );
    final side = (l.width > t.width ? l.width : t.width) + 8;
    final maxTitle = size.width - 2 * side;
    final title = layoutChild(
      _HeaderSlot.title,
      BoxConstraints(maxWidth: maxTitle > 0 ? maxTitle : 0),
    );
    positionChild(
      _HeaderSlot.title,
      Offset((size.width - title.width) / 2, (size.height - title.height) / 2),
    );
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate old) => false;
}

/// 页面右上角的黑色圆形图标按钮（如“新增”）。
class AppHeaderAction extends StatelessWidget {
  final String lightSvg, darkSvg;
  final VoidCallback? onTap;
  final String label;

  /// 背景色；不传时浅色用黑、深色用白。
  final Color? color;
  const AppHeaderAction({
    super.key,
    required this.lightSvg,
    required this.darkSvg,
    required this.label,
    this.onTap,
    this.color,
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
        bg:
            color ??
            dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
        radius: BorderRadius.circular(22),
        child: Center(
          child: hsvg(dk(context, lightSvg, darkSvg), w: 20, h: 20),
        ),
      ),
    ),
  );
}

/// 白色圆形图标按钮（返回、关闭、日期筛选等次要入口），样式取自设计稿。
class AppHeaderCircle extends StatelessWidget {
  final String lightSvg, darkSvg, label;
  final VoidCallback? onTap;
  const AppHeaderCircle({
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
          child: hsvg(dk(context, lightSvg, darkSvg), w: 20, h: 20),
        ),
      ),
    ),
  );
}
