// 次卡套餐编辑页里随草稿变化的几块：套餐预览、包含服务列表、定价文字。
// 生成脚本把设计稿里对应的静态区域换成这里的组件（生成页面不能手改）。
import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/merchant_api.dart';
import '../backend/package_calc.dart';
import '../backend/store_profile.dart';
import '../kit/kit.dart';
import '../pages/gen/svgs.dart';
import '../routes.dart';
import '../theme.dart' show C, softShadow;

/// 套餐编辑页顶部的“套餐预览”：名称、次数 / 有效期、售价都跟着编辑实时变化。
Widget hPackagePreview() => ListenableBuilder(
  listenable: Listenable.merge([CatalogDraft.preview, storeProfile]),
  builder: (context, _) {
    final name = (CatalogDraft.current?.fields['name'] ?? '').toString().trim();
    final store = storeProfile.live ? storeProfile.name : '驰光汽车美容';
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -0.866),
          end: Alignment(0.5, 0.866),
          colors: [Color(0xFF1E63AE), Color(0xFF0485F7), Color(0xFF4DB0FF)],
          stops: [0, 0.7, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: hsvg(Svgs.s276, w: 220, h: 220),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hts(
                        12,
                        const Color(0xCCFFFFFF),
                        w: FontWeight.w500,
                        lh: 17,
                      ),
                    ),
                  ),
                  Text('套餐预览', style: hts(11, const Color(0xB3FFFFFF), lh: 16)),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? '套餐名称' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: hts(
                            20,
                            name.isEmpty
                                ? const Color(0x80FFFFFF)
                                : Colors.white,
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PackageCalc.summary,
                          style: hts(12, const Color(0xD9FFFFFF), lh: 17),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    PackageCalc.priceText,
                    style: hts(26, Colors.white, w: FontWeight.w600, lh: 32),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  },
);

/// 随套餐草稿变化的文字（原价合计 / 相当于单次 / 省 ¥… 约 … 折）。
Widget hPkgText(
  String Function() text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (_, _) => Text(
    merchantApi.hasSession ? text() : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

/// “包含服务”卡片：每个服务一行（名称、单次价、次数加减），最后是“添加服务项目”。
/// 次数减到 1 以后再点“−”会把这个服务从套餐里去掉。
Widget hPackageItems() => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (context, _) {
    final items = CatalogDraft.packageItems;
    void change(int index, int delta) {
      final next = CatalogDraft.packageItems;
      final count = (int.tryParse('${next[index]['count']}') ?? 1) + delta;
      if (count < 1) {
        next.removeAt(index);
      } else if (count <= 999) {
        next[index]['count'] = count;
      }
      CatalogDraft.setPackageItems(next);
    }

    Widget stepButton(String label, IconData icon, VoidCallback onTap) =>
        Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.all(6), // 点击区域扩大到 44
              decoration: BoxDecoration(
                color: dk(
                  context,
                  const Color(0xFFF4F4F5),
                  const Color(0xFF27272A),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: C.ink),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: C.dark ? null : softShadow,
        border: C.dark ? Border.all(color: const Color(0xFF26262B)) : null,
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: dk(
                          context,
                          const Color(0xFFE1F0FE),
                          const Color(0x2E0485F7),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: hsvg(
                          dk(context, Svgs.s274, Svgs.s275),
                          w: 20,
                          h: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${items[i]['name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: hts(15, C.ink, w: FontWeight.w500, lh: 22),
                          ),
                          Text(
                            '单次 ¥${formatMoney(num.tryParse('${items[i]['price']}') ?? 0)}',
                            style: hts(12, C.muted, lh: 17),
                          ),
                        ],
                      ),
                    ),
                    stepButton('减少', Icons.remove_rounded, () => change(i, -1)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 36),
                      child: Text(
                        '${items[i]['count']}',
                        textAlign: TextAlign.center,
                        style: hts(15, C.ink, w: FontWeight.w600, lh: 22),
                      ),
                    ),
                    stepButton('增加', Icons.add_rounded, () => change(i, 1)),
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.only(left: 64),
              color: C.line,
            ),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openRoute(context, 'PackageSvcPick'),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    hsvg(Svgs.s277, w: 18, h: 18),
                    const SizedBox(width: 8),
                    Text(
                      '添加服务项目',
                      style: hts(
                        14,
                        const Color(0xFF0485F7),
                        w: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
);
