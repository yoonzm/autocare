import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 状态语义：ok 成功 / wait 进行中 / bad 失败 / off 草稿·作废 / warn 提醒。
enum Tone { ok, wait, bad, off, warn }

StatusColors toneColors(AppTokens t, Tone tone) => switch (tone) {
  Tone.ok => t.ok,
  Tone.wait => t.wait,
  Tone.bad => t.danger,
  Tone.off => t.off,
  Tone.warn => t.warn,
};

/// 状态标签：高 18、圆角 9、11/600，「浅底 + 深字」。车牌、黑金卡种这类内容标签不用它。
class AppStatusTag extends StatelessWidget {
  final String text;
  final Tone tone;
  const AppStatusTag(this.text, {super.key, this.tone = Tone.wait});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final c = toneColors(t, tone);
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(text, style: t.micro.copyWith(color: c.fg), maxLines: 1),
    );
  }
}
