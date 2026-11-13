import '../kit/buttons.dart';

// 次卡套餐预览与服务列表；数据及操作均由页面显式传入。
import 'package:flutter/material.dart';

import '../backend/package_calc.dart';
import '../kit/kit.dart';
import '../resources/merchant_svgs.dart';
import '../theme.dart' show C, softShadow;

/// 套餐编辑页顶部的“套餐预览”：名称、次数 / 有效期、售价都跟着编辑实时变化。
class PackagePreview extends StatelessWidget {
  final String name, store;
  final PackageCalc calc;
  const PackagePreview({
    super.key,
    required this.name,
    required this.store,
    required this.calc,
  });
  @override
  Widget build(BuildContext context) {
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
        clipBehavior: Clip.none,
        children: [
          // 设计稿：right -70 / top -90，Stack 在内边距（20 / 18）之内
          Positioned(
            top: -108,
            right: -90,
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
                          calc.summary,
                          style: hts(12, const Color(0xD9FFFFFF), lh: 17),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    calc.priceText,
                    style: hts(26, Colors.white, w: FontWeight.w600, lh: 32),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// “包含服务”卡片：每个服务一行（名称、单次价、次数加减），最后是“添加服务项目”。
/// 次数减到 1 以后再点“−”会把这个服务从套餐里去掉。
class PackageItems extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index, int delta) onStep;
  final VoidCallback onAdd;
  const PackageItems({
    super.key,
    required this.items,
    required this.onStep,
    required this.onAdd,
  });
  @override
  Widget build(BuildContext context) {
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
                    HNumberStepper.controlled(
                      onDecrease: () => onStep(i, -1),
                      onIncrease: () => onStep(i, 1),

                      value: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 36),
                        child: Text(
                          '${items[i]['count']}',
                          textAlign: TextAlign.center,
                          style: hts(15, C.ink, w: FontWeight.w600, lh: 22),
                        ),
                      ),

                      gap: 0,
                    ),
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
          AppButton(
            label: '添加服务项目',
            kind: AppButtonKind.secondary,
            size: AppButtonSize.medium,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
