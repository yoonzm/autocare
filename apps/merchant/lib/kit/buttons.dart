import 'package:flutter/material.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';

import 'async_kit.dart';

export 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show
        AppButton,
        AppButtonKind,
        AppButtonSize,
        AppIconButton,
        AppIconButtonKind,
        AppIconButtonSize,
        AppSmsCodeButton;

Widget merchantFeedbackButton(
  BuildContext context,
  String label,
  VoidCallback? onPressed,
  bool loading,
  AsyncButtonKind kind,
) => AppButton(
  label: label,
  loading: loading,
  size: kind == AsyncButtonKind.text
      ? AppButtonSize.small
      : AppButtonSize.medium,
  kind: switch (kind) {
    AsyncButtonKind.primary => AppButtonKind.primary,
    AsyncButtonKind.secondary => AppButtonKind.secondary,
    AsyncButtonKind.text => AppButtonKind.text,
  },
  onPressed: onPressed,
);

/// 把既有异步动作的状态交给标准按钮，业务请求仍由页面执行。
class ActionButton extends StatelessWidget {
  final String actionKey;
  final String label;
  final AppButtonKind kind;
  final AppButtonSize size;
  final String? svg;
  final IconData? icon;
  final bool expanded;
  final VoidCallback? onPressed;
  const ActionButton({
    super.key,
    required this.actionKey,
    required this.label,
    this.kind = AppButtonKind.primary,
    this.size = AppButtonSize.medium,
    this.svg,
    this.icon,
    this.expanded = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: busyActions,
    builder: (context, keys, _) => AppButton(
      label: label,
      kind: kind,
      size: size,
      svg: svg,
      icon: icon,
      expanded: expanded,
      loading: keys.contains(actionKey),
      onPressed: onPressed,
    ),
  );
}

/// 自持加载状态的标准按钮，复用统一异步动作的错误与防重复处理。
class RequestButton extends StatelessWidget {
  final String label;
  final AppButtonKind kind;
  final AppButtonSize size;
  final Future<void> Function()? onPressed;
  const RequestButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.size = AppButtonSize.large,
  });

  @override
  Widget build(BuildContext context) => AsyncAction(
    onTap: onPressed,
    builder: (key, onTap) => ActionButton(
      actionKey: key,
      label: label,
      kind: kind,
      size: size,
      expanded: true,
      onPressed: onTap,
    ),
  );
}
