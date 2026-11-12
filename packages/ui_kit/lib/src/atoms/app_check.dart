import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import 'app_tap_target.dart';

/// 多选框：22 圆，选中 = 主色实心 + 白色对勾；点击热区外扩到 44。
class AppCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  const AppCheck({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => _Mark(
    selected: value,
    semanticLabel: semanticLabel,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    inner: const Icon(Icons.check_rounded, size: 15),
  );
}

/// 单选框：22 圆，选中 = 主色实心 + 白色圆点。同一组里的互斥由页面控制 [group]。
class AppRadio<T> extends StatelessWidget {
  final T value;
  final T? group;
  final ValueChanged<T>? onChanged;
  final String? semanticLabel;
  const AppRadio({
    super.key,
    required this.value,
    required this.group,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => _Mark(
    selected: value == group,
    semanticLabel: semanticLabel,
    onTap: onChanged == null ? null : () => onChanged!(value),
    inner: const Icon(Icons.circle, size: 8),
  );
}

/// 列表里的「加入 / 已选」：28 圆，未选显示加号，选中显示对勾。
class AppAddToggle extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  const AppAddToggle({
    super.key,
    required this.selected,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => _Mark(
    size: 28,
    selected: selected,
    semanticLabel: semanticLabel,
    onTap: onChanged == null ? null : () => onChanged!(!selected),
    inner: Icon(selected ? Icons.check_rounded : Icons.add_rounded, size: 16),
    unselectedInnerAccent: true,
  );
}

class _Mark extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final Widget inner;
  final double size;
  final String? semanticLabel;
  final bool unselectedInnerAccent;
  const _Mark({
    required this.selected,
    required this.onTap,
    required this.inner,
    this.size = 22,
    this.semanticLabel,
    this.unselectedInnerAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return AppTapTarget(
      onTap: onTap,
      selected: selected,
      button: false,
      semanticLabel: semanticLabel,
      builder: (context, pressed) => Opacity(
        opacity: onTap == null ? .5 : 1,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? t.primary : Colors.transparent,
            border: Border.all(
              color: selected
                  ? t.primary
                  : unselectedInnerAccent
                  ? t.primary
                  : t.switchOff,
              width: 1.5,
            ),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: selected
                  ? t.onPrimary
                  : unselectedInnerAccent
                  ? t.primary
                  : Colors.transparent,
            ),
            child: inner,
          ),
        ),
      ),
    );
  }
}
