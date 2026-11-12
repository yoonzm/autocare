import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_tokens.dart';

/// 结算类页面左侧显示的金额，不超过两行：标题 + 大号金额。
class AppAmountSummary extends StatelessWidget {
  final String caption;
  final String amount;
  const AppAmountSummary({super.key, required this.caption, required this.amount});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.caption,
        ),
        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.title.copyWith(fontFeatures: AppTokens.tabular),
        ),
      ],
    );
  }
}

/// 底部操作栏：固定在底部，左右内边距 20，顶部 1px 分割线，底部安全区另加。
/// 一个主要按钮；有次要按钮时，次要 : 主要 = 1 : 2。内容区底部要留出栏高度。
class AppBottomBar extends StatelessWidget {
  final AppAmountSummary? summary;
  final AppButton? secondary;
  final AppButton primary;
  const AppBottomBar({
    super.key,
    required this.primary,
    this.secondary,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.s12,
        AppSpacing.pageGutter,
        AppSpacing.s12 + bottom,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          if (summary != null) ...[
            Expanded(flex: 4, child: summary!),
            const SizedBox(width: AppSpacing.s12),
          ],
          if (secondary != null) ...[
            Expanded(
              flex: 1,
              child: AppButton(
                label: secondary!.label,
                kind: secondary!.kind,
                size: AppButtonSize.large,
                expanded: true,
                loading: secondary!.loading,
                onPressed: secondary!.onPressed,
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
          ],
          Expanded(
            flex: secondary == null ? (summary == null ? 1 : 3) : 2,
            child: AppButton(
              label: primary.label,
              kind: primary.kind,
              size: AppButtonSize.large,
              expanded: true,
              loading: primary.loading,
              icon: primary.icon,
              onPressed: primary.onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
