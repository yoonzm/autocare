import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_tokens.dart';
import 'app_dialog.dart';

/// 底部弹层：遮罩 50% 黑，顶部圆角 32，上方小横条 40 × 5；标题 20/28 · 600，内容可滚动，按钮在底部固定。
/// 点遮罩或下滑关闭；[hasUnsavedChanges] 返回 true 时先二次确认。
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
  List<AppButton> actions = const [],
  bool Function()? hasUnsavedChanges,
}) {
  final t = AppTokens.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: t.surface,
    barrierColor: t.overlay,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (sheetContext) => _SheetBody(
      title: title,
      subtitle: subtitle,
      builder: builder,
      actions: actions,
      hasUnsavedChanges: hasUnsavedChanges,
    ),
  );
}

class _SheetBody extends StatelessWidget {
  final String title;
  final String? subtitle;
  final WidgetBuilder builder;
  final List<AppButton> actions;
  final bool Function()? hasUnsavedChanges;
  const _SheetBody({
    required this.title,
    required this.subtitle,
    required this.builder,
    required this.actions,
    required this.hasUnsavedChanges,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final guard = hasUnsavedChanges;
    return PopScope(
      canPop: guard == null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || guard == null) return;
        if (!guard()) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showAppDialog(
          context,
          title: '放弃未保存的内容？',
          message: '离开后已填写的内容不会保存。',
          confirmLabel: '放弃',
          cancelLabel: '继续编辑',
          danger: true,
        );
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s10),
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: t.fillStrong,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.s14,
                  AppSpacing.pageGutter,
                  AppSpacing.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.title),
                    if (subtitle != null) Text(subtitle!, style: t.caption),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: builder(context),
                ),
              ),
              if (actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.s16,
                    AppSpacing.pageGutter,
                    AppSpacing.s16,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          flex: i == actions.length - 1 && actions.length > 1 ? 2 : 1,
                          child: AppButton(
                            label: actions[i].label,
                            kind: actions[i].kind,
                            size: AppButtonSize.large,
                            expanded: true,
                            loading: actions[i].loading,
                            onPressed: actions[i].onPressed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
