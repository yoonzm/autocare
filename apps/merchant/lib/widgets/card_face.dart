// 会员卡卡面：编辑页的“卡面预览”和列表里的卡片共用同一套颜色，
// 所以预览看到什么颜色，保存后列表里就是什么颜色。
import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/store_profile.dart';
import '../kit/kit.dart';
import 'common.dart' show Rings;
import '../theme.dart' show softShadow;

class CardPalette {
  final Color bg;

  /// 卡种名称 / 折扣数字的颜色
  final Color title;

  /// 次要文字
  final Color sub;

  /// 强调文字（人数等）
  final Color strong;

  /// 门店名 / “卡面预览”小标签
  final Color label;

  /// 是否绘制右上角的圆环装饰（黑金卡）
  final bool rings;

  /// 白色卡面需要一圈柔和的阴影才能和页面底色区分
  final bool shadow;
  const CardPalette({
    required this.bg,
    required this.title,
    required this.sub,
    required this.strong,
    required this.label,
    this.rings = false,
    this.shadow = false,
  });
}

/// 自定义卡面颜色：文字颜色按底色深浅自动调整（深底用浅字，浅底用深字）。
CardPalette _customPalette(Color bg) {
  final dark = bg.computeLuminance() < 0.45;
  if (dark) {
    return CardPalette(
      bg: bg,
      title: const Color(0xFFFFFFFF),
      sub: const Color(0xCCFFFFFF),
      strong: const Color(0xFFFFFFFF),
      label: const Color(0xB3FFFFFF),
    );
  }
  return CardPalette(
    bg: bg,
    title: const Color(0xFF18181B),
    sub: const Color(0xCC18181B),
    strong: const Color(0xFF18181B),
    label: const Color(0xA618181B),
    // 接近白色的底色需要一圈柔和阴影才能和页面底色区分
    shadow: bg.computeLuminance() > 0.85,
  );
}

CardPalette cardPalette(BuildContext context, String color) {
  final custom = CatalogDraft.customCardColor(color);
  if (custom != null) return _customPalette(custom);
  switch (color) {
    case 'champagne':
      return const CardPalette(
        bg: Color(0xFFF3E2B3),
        title: Color(0xFF3D2B0E),
        sub: Color(0xFF5C4520),
        strong: Color(0xFF3D2B0E),
        label: Color(0xFF5C4520),
      );
    case 'silver':
      return CardPalette(
        bg: dk(context, const Color(0xFFE4E4E7), const Color(0xFF3A3A40)),
        title: dk(context, const Color(0xFF27272A), const Color(0xFFD4D4D8)),
        sub: dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
        strong: dk(context, const Color(0xFF27272A), const Color(0xFFD4D4D8)),
        label: dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
      );
    case 'white':
      return CardPalette(
        bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
        title: dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
        sub: dk(context, const Color(0xFF71717A), const Color(0xFFA8A8B3)),
        strong: dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
        label: dk(context, const Color(0xFF71717A), const Color(0xFFA8A8B3)),
        shadow: true,
      );
    case 'blue':
      return const CardPalette(
        bg: Color(0xFF0B5FD6),
        title: Color(0xFFFFFFFF),
        sub: Color(0xCCFFFFFF),
        strong: Color(0xFFFFFFFF),
        label: Color(0xCCFFFFFF),
      );
    default:
      return CardPalette(
        bg: dk(context, const Color(0xFF18181B), const Color(0xFF34343A)),
        title: const Color(0xFFF5D78E),
        sub: const Color(0xFFD4D4D8),
        strong: const Color(0xFFFAFAFA),
        label: const Color(0xFFA1A1AA),
        rings: true,
      );
  }
}

/// 折扣系数 -> 折数文字：0.9 -> `9`，0.95 -> `9.5`，1 -> `10`。
String discountText(num discount) {
  final v = discount * 10;
  return v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);
}

String _money(num v) {
  final s = v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// 列表卡片上的权益摘要：`充值 ¥10,000 / 累计消费 ¥30,000 · 积分 2 倍`。
String cardBenefitLine(Map<String, dynamic> row) {
  final recharge = num.tryParse('${row['upgrade_recharge'] ?? ''}');
  final cumulative = num.tryParse('${row['upgrade_cumulative'] ?? ''}');
  final cond = [
    if (recharge != null) '充值 ¥${_money(recharge)}',
    if (cumulative != null) '累计消费 ¥${_money(cumulative)}',
  ].join(' / ');
  final points =
      '积分 ${CatalogDraft.formatNumber(num.tryParse('${row['points_multiplier'] ?? ''}') ?? 1)} 倍';
  if (cond.isNotEmpty) return '$cond · $points';
  // 没有升级条件的卡（如新门店默认的“普通会员”）显示卡种自己的说明
  final note = '${row['description'] ?? ''}'.trim();
  return note.isNotEmpty ? note : '无升级条件 · $points';
}

/// 卡种列表里的一张卡。
class CardTileFace extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback onTap;
  const CardTileFace({super.key, required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = cardPalette(context, row['color']?.toString() ?? 'black');
    final discount = num.tryParse('${row['discount'] ?? ''}') ?? 1;
    final original = discount >= 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: p.shadow ? softShadow : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (p.rings)
              Positioned(
                top: -98,
                right: -80,
                child: Rings(
                  size: 200,
                  viewBox: 200,
                  radii: const [55, 80, 98],
                  colors: const [
                    Color(0xFF3A3226),
                    Color(0xFF2E2A24),
                    Color(0xFF27272A),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        row['name']?.toString() ?? '',
                        style: hts(
                          18,
                          p.title,
                          w: FontWeight.w600,
                          lh: 26,
                          ls: 0.72,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    original
                        ? Text(
                            '原价',
                            style: hts(15, p.sub, w: FontWeight.w500, lh: 30),
                          )
                        : Text.rich(
                            TextSpan(
                              style: hts(
                                26,
                                p.title,
                                w: FontWeight.w600,
                                lh: 30,
                              ),
                              children: [
                                TextSpan(text: discountText(discount)),
                                TextSpan(
                                  text: ' 折',
                                  style: hts(
                                    14,
                                    p.title,
                                    w: FontWeight.w600,
                                    lh: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cardBenefitLine(row),
                        style: hts(12, p.sub, lh: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 人数来自会员模块，会员尚未接后端，这里恒为 0
                    Text(
                      '0 人',
                      style: hts(12, p.strong, w: FontWeight.w600, lh: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 编辑页顶部的“卡面预览”：随正在编辑的名称 / 折扣 / 颜色实时变化，
/// 门店名来自当前登录门店。生成脚本把设计稿里的静态预览换成它。
Widget hCardPreview() => ListenableBuilder(
  listenable: Listenable.merge([CatalogDraft.preview, storeProfile]),
  builder: (context, _) {
    final p = cardPalette(context, CatalogDraft.cardColor);
    final name = CatalogDraft.cardName.trim();
    final discount = CatalogDraft.cardDiscount;
    final store = storeProfile.live ? storeProfile.name : '驰光汽车美容';
    return Container(
      height: 168,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 设计稿：right -80 / bottom -110，半径 64 / 94 / 118；Stack 在内边距（20）之内
          if (p.rings)
            const Positioned(
              bottom: -130,
              right: -100,
              child: Rings(
                size: 240,
                viewBox: 240,
                radii: [64, 94, 118],
                colors: [
                  Color(0xFF3A3226),
                  Color(0xFF2E2A24),
                  Color(0xFF27272A),
                ],
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hts(12, p.label, lh: 16, ls: 0.96),
                    ),
                  ),
                  Text('卡面预览', style: hts(11, p.label, lh: 18)),
                ],
              ),
              Text(
                name.isEmpty ? '卡种名称' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hts(
                  26,
                  name.isEmpty ? p.title.withValues(alpha: 0.5) : p.title,
                  w: FontWeight.w600,
                  lh: 32,
                  ls: 1.56,
                ),
              ),
              Text(
                discount >= 1
                    ? 'NO. 0000 0028 · 原价'
                    : 'NO. 0000 0028 · 全场 ${discountText(discount)} 折',
                style: hts(13, p.sub, lh: 18),
              ),
            ],
          ),
        ],
      ),
    );
  },
);
