import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';

/// 预览用的亮度：null 跟随系统（App 当前外观），否则强制浅色 / 深色，便于对照两套令牌。
final ValueNotifier<Brightness?> previewBrightness = ValueNotifier(null);

/// 预览舞台：用选定的亮度重新注入令牌，舞台背景为令牌的页面底色，里面的组件自动切换浅色 / 深色。
class PreviewStage extends StatelessWidget {
  final List<Widget> children;
  const PreviewStage({super.key, required this.children});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Brightness?>(
    valueListenable: previewBrightness,
    builder: (context, forced, _) {
      final base = Theme.of(context);
      final brightness = forced ?? base.brightness;
      final tokens = AppTokens.forBrightness(brightness);
      return Theme(
        data: base.copyWith(brightness: brightness, extensions: [tokens]),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: tokens.bg,
            borderRadius: BorderRadius.circular(AppRadius.hero),
            border: Border.all(color: tokens.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.s16),
                children[i],
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// 一个组件的预览卡：标题 + 组件名标签 + 各状态 + 规则说明 + 用法代码。
class Demo extends StatelessWidget {
  final String title;
  final String tag;
  final List<Widget> children;
  final List<String> notes;
  final String? code;
  const Demo({
    super.key,
    required this.title,
    required this.tag,
    required this.children,
    this.notes = const [],
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: t.title.copyWith(fontSize: 18, height: 26 / 18)),
              _Mono(tag),
            ],
          ),
          const SizedBox(height: AppSpacing.s14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: BorderRadius.circular(AppRadius.inset),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s14),
                  children[i],
                ],
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            for (final n in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: t.small.copyWith(color: t.inkSub)),
                    Expanded(
                      child: Text(
                        n,
                        style: t.small.copyWith(
                          color: t.inkSub,
                          fontWeight: FontWeight.w400,
                          height: 20 / 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (code != null) ...[
            const SizedBox(height: AppSpacing.s8),
            _Code(code!),
          ],
        ],
      ),
    );
  }
}

class _Mono extends StatelessWidget {
  final String text;
  const _Mono(this.text);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      decoration: BoxDecoration(
        color: t.wait.bg,
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(
        text,
        style: t.caption.copyWith(
          color: t.wait.fg,
          fontFamily: 'monospace',
          height: 18 / 12,
        ),
      ),
    );
  }
}

class _Code extends StatelessWidget {
  final String text;
  const _Code(this.text);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: t.heroBg,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: t.heroBorder),
      ),
      child: SelectableText(
        text,
        style: t.caption.copyWith(
          color: t.heroInk,
          fontFamily: 'monospace',
          height: 18 / 12,
        ),
      ),
    );
  }
}

/// 状态小标签：每个状态下面一行说明。
class StateLabel extends StatelessWidget {
  final String label;
  final Widget child;
  const StateLabel(this.label, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: AppSpacing.s6),
        Text(label, style: t.caption.copyWith(fontSize: 11, height: 14 / 11)),
      ],
    );
  }
}

/// 子标题（「主要 / 次要 / 危险 / 文字」这类）。
class GroupLabel extends StatelessWidget {
  final String text;
  const GroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Text(
      text,
      style: t.caption.copyWith(fontWeight: FontWeight.w600, height: 17 / 12),
    );
  }
}
