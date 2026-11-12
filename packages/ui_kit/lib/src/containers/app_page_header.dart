import 'package:flutter/material.dart';

import '../atoms/app_icon_button.dart';
import '../tokens/app_tokens.dart';

enum HeaderLeading { none, back, close }

/// 页面头部：左侧返回或关闭（圆形图标按钮 44），标题居中 17/24 · 600，右侧最多一个入口。
/// 弹层式页面（新建、编辑）用关闭 ×，进入下一级用返回 ‹；有底部操作栏时，右上角不再放保存、提交。
class AppPageHeader extends StatelessWidget {
  final String title;
  final HeaderLeading leading;
  final VoidCallback? onLeading;
  final Widget? trailing;
  const AppPageHeader({
    super.key,
    required this.title,
    this.leading = HeaderLeading.back,
    this.onLeading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: switch (leading) {
              HeaderLeading.none => null,
              HeaderLeading.back => AppIconButton(
                icon: Icons.chevron_left_rounded,
                semanticLabel: '返回',
                onPressed: onLeading ?? () => Navigator.maybePop(context),
              ),
              HeaderLeading.close => AppIconButton(
                icon: Icons.close_rounded,
                semanticLabel: '关闭',
                onPressed: onLeading ?? () => Navigator.maybePop(context),
              ),
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.page,
            ),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}
