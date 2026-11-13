import 'package:flutter/widgets.dart';

import '../backend/feedback_draft.dart';

/// 提供当前 App 的临时登录恢复箱；活动表单和提交状态仍归各页面实例所有。
class FeedbackRecoveryScope extends InheritedWidget {
  final FeedbackRecovery recovery;
  const FeedbackRecoveryScope({
    super.key,
    required this.recovery,
    required super.child,
  });
  static FeedbackRecovery? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FeedbackRecoveryScope>()?.recovery;
  @override
  bool updateShouldNotify(FeedbackRecoveryScope oldWidget) =>
      !identical(recovery, oldWidget.recovery);
}
