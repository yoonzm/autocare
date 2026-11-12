import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 头像配色：会员按卡种配色，黑金 = 黑底金字。
enum AppAvatarTier { standard, blackGold, gold, silver, normal }

/// 头像：默认 44 圆，字取姓；没有名字时用灰色人像图标；小头像 28 用于选择标签内部。
class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final AppAvatarTier tier;
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.tier = AppAvatarTier.standard,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final (bg, fg) = switch (tier) {
      AppAvatarTier.standard => (t.primarySoft, t.primaryText),
      AppAvatarTier.blackGold => (t.darkAvatarBg, t.gold),
      AppAvatarTier.gold => (t.warn.bg, t.warn.fg),
      AppAvatarTier.silver => (t.fill, t.inkSub),
      AppAvatarTier.normal => (t.ok.bg, t.ok.fg),
    };
    final trimmed = name.trim();
    final empty = trimmed.isEmpty;
    return Semantics(
      label: empty ? '未命名' : trimmed,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: empty ? t.fillStrong : bg,
        ),
        child: empty
            ? Icon(Icons.person_rounded, size: size * .55, color: t.inkFaint)
            : Text(
                String.fromCharCode(trimmed.runes.first),
                style: t.body.copyWith(
                  color: fg,
                  fontSize: size * .4,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
      ),
    );
  }
}
