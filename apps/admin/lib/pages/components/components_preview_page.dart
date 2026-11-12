import 'package:autocare_ui_kit/autocare_ui_kit.dart' hide AppToast;
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui.dart';
import 'preview_common.dart';
import 'preview_sections.dart';

/// 组件库预览：对照设计稿「组件库」各画板，逐个展示 autocare_ui_kit 里每个组件的全部状态，
/// 可在浅色 / 深色之间切换对照。只是静态展示，不请求数据，也不影响任何业务功能。
class ComponentsPreviewPage extends StatelessWidget {
  const ComponentsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) => AdPage(
    title: '组件库',
    onRefresh: () async {},
    children: [
      const _ThemeSwitch(),
      Text(
        '基础组件库 autocare_ui_kit 的预览。组件分 5 层，页面只做组合；这里列出每个组件的全部状态，深色模式可随时切换对照。',
        style: ts(13, color: C.sub, h: 20),
      ),
      RowGroup([
        for (final s in previewSections)
          Row1(
            leading: SoftTile(s.icon, C.primaryInk, C.primarySoft),
            title: s.title,
            sub: s.subtitle,
            onTap: () => go(context, ComponentSectionPage(s.id)),
          ),
      ]),
    ],
  );
}

class ComponentSectionPage extends StatelessWidget {
  final String id;
  const ComponentSectionPage(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    final section = previewSectionById(id)!;
    return AdPage(
      title: section.title,
      onRefresh: () async {},
      children: [
        const _ThemeSwitch(),
        // 舞台在自己的主题作用域里构建分区内容，组件才能取到所选亮度的令牌。
        PreviewStage(children: [Builder(builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, w) in section.build(context).indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.s16),
              w,
            ],
          ],
        ))]),
      ],
    );
  }
}

/// 跟随系统 / 浅色 / 深色：只作用于预览舞台，不改变 App 的外观设置。
class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Brightness?>(
    valueListenable: previewBrightness,
    builder: (context, value, _) => Segmented(
      labels: const ['跟随外观', '浅色', '深色'],
      index: switch (value) {
        null => 0,
        Brightness.light => 1,
        Brightness.dark => 2,
      },
      onChanged: (i) => previewBrightness.value = switch (i) {
        1 => Brightness.light,
        2 => Brightness.dark,
        _ => null,
      },
    ),
  );
}
