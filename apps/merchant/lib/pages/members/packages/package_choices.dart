import 'package:flutter/material.dart';

import '../../../backend/package_calc.dart';
import '../../../kit/kit.dart';
import '../../../resources/merchant_svgs.dart';

/// 购买次卡页的套餐列表：在售套餐，点选后写入购买表单。
/// [limit] 限制显示几个（购买页只显示前 3 个，其余在“选择次卡套餐”弹层里）；选中的套餐一定显示。
/// 调用者提供真实在售套餐和选择回调。
///
/// [readOnly]（还没选会员时的置灰预览）：只显示真实套餐，不能点选，也不显示选中状态。
class PackageChoices extends StatelessWidget {
  final List<Map<String, dynamic>> packages;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final int? limit;
  final bool readOnly;
  const PackageChoices({
    super.key,
    required this.packages,
    required this.selectedId,
    required this.onSelected,
    this.limit,
    this.readOnly = false,
  });
  @override
  Widget build(BuildContext context) {
    final all = packages;
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '还没有在售的次卡套餐，请先在“次卡套餐”里新增并上架',
          style: hts(
            13,
            dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
            lh: 19,
          ),
        ),
      );
    }
    final selected = readOnly ? '' : selectedId;
    var shown = limit == null ? all : all.take(limit!).toList();
    if (limit != null && !shown.any((p) => '${p['id']}' == selected)) {
      final sel = all.where((p) => '${p['id']}' == selected);
      if (sel.isNotEmpty) shown = [...shown.take(limit! - 1), sel.first];
    }
    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PackageRow(
            row: shown[i],
            selected: '${shown[i]['id']}' == selected,
            onTap: () {
              if (!readOnly) onSelected('${shown[i]['id']}');
            },
          ),
        ],
      ],
    );
  }
}

class _PackageRow extends StatelessWidget {
  final Map<String, dynamic> row;
  final bool selected;
  final VoidCallback onTap;
  const _PackageRow({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = PackageRowInfo(row);
    return _PackageTile(
      name: '${row['name'] ?? ''}',
      sub: info.subtitle,
      price: info.priceText,
      original: info.showOriginal ? info.originalText : '',
      selected: selected,
      onTap: onTap,
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String name, sub, price, original;
  final bool selected;
  final VoidCallback onTap;
  const _PackageTile({
    required this.name,
    required this.sub,
    required this.price,
    required this.original,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: hbox(
          bg: selected
              ? dk(
                  context,
                  const Color(0xFFE1F0FE),
                  const Color.fromRGBO(4, 133, 247, 0.18),
                )
              : dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(18),
          border: selected
              ? Border.all(color: const Color(0xFF0485F7), width: 1.5)
              : Border.all(
                  color: dk(
                    context,
                    const Color(0xFFE4E4E7),
                    const Color(0xFF3F3F46),
                  ),
                  width: 1.5,
                ),
          pad: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: hrow(
            [
              Expanded(
                child: hcol(
                  [
                    hrow(
                      [
                        Flexible(
                          child: Text(
                            name,
                            style: hts(15, ink, w: FontWeight.w600, lh: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 6,
                    ),
                    Text(
                      sub,
                      style: hts(
                        12,
                        dk(
                          context,
                          const Color(0xFF52525B),
                          const Color(0xFFA8A8B3),
                        ),
                        lh: 17,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 2,
                ),
              ),
              hcol(
                [
                  Text(price, style: hts(16, ink, w: FontWeight.w600, lh: 22)),
                  if (original.isNotEmpty)
                    Text(
                      original,
                      style: hts(
                        11,
                        dk(
                          context,
                          const Color(0xFFA1A1AA),
                          const Color(0xFF80808A),
                        ),
                        lh: 14,
                        deco: TextDecoration.lineThrough,
                      ),
                    ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.end,
                gap: 0,
              ),
              selected
                  ? hbox(
                      w: 22,
                      h: 22,
                      bg: const Color(0xFF0485F7),
                      radius: BorderRadius.circular(11),
                      child: hrow(
                        [hsvg(Svgs.s309, w: 14, h: 14)],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                    )
                  : hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: Border.all(
                        color: dk(
                          context,
                          const Color(0xFFD4D4D8),
                          const Color(0xFF3F3F46),
                        ),
                        width: 1.5,
                      ),
                    ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 12,
          ),
        ),
      ),
    );
  }
}
