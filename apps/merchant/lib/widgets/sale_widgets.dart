import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/package_calc.dart';
import '../kit/kit.dart';
import '../pages/gen/svgs.dart';

/// 购买次卡页的套餐列表：在售套餐，点选后写入购买表单。
/// [limit] 限制显示几个（购买页只显示前 3 个，其余在“选择次卡套餐”弹层里）；选中的套餐一定显示。
/// 没登录（设计预览）时显示设计稿的示例套餐。
///
/// [readOnly]（还没选会员时的置灰预览）：只显示真实套餐，不能点选，也不显示选中状态。
Widget hPackagePicker({int? limit, bool readOnly = false}) => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (context, _) {
    if (!merchantApi.hasSession) return _samplePackages(context, limit);
    final all = MemberFlow.salePackages;
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
    final selected = readOnly
        ? ''
        : '${CatalogDraft.current?.fields['sale_package_id'] ?? ''}';
    var shown = limit == null ? all : all.take(limit).toList();
    if (limit != null && !shown.any((p) => '${p['id']}' == selected)) {
      final sel = all.where((p) => '${p['id']}' == selected);
      if (sel.isNotEmpty) shown = [...shown.take(limit - 1), sel.first];
    }
    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PackageRow(
            row: shown[i],
            selected: '${shown[i]['id']}' == selected,
            hot: i == 0 && all.length > 1,
            onTap: () => readOnly
                ? null
                : CatalogDraft.set(
                    'recharge',
                    'sale_package_id',
                    '${shown[i]['id']}',
                  ),
          ),
        ],
      ],
    );
  },
);

Widget _samplePackages(BuildContext context, int? limit) {
  final rows = [
    ('精致洗车年卡', '20 次 · 12 个月有效', '¥1,080', '¥1,360', true),
    ('精致洗车 10 次卡', '10 次 · 6 个月有效', '¥580', '¥680', false),
    ('内饰深度清洁 6 次卡', '6 次 · 12 个月有效', '¥1,380', '¥1,788', false),
  ];
  return Column(
    children: [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _PackageTile(
          name: rows[i].$1,
          sub: rows[i].$2,
          price: rows[i].$3,
          original: rows[i].$4,
          selected: i == 0,
          hot: i == 0,
          onTap: () {},
        ),
      ],
    ],
  );
}

class _PackageRow extends StatelessWidget {
  final Map<String, dynamic> row;
  final bool selected;
  final bool hot;
  final VoidCallback onTap;
  const _PackageRow({
    required this.row,
    required this.selected,
    required this.hot,
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
      hot: hot,
      onTap: onTap,
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String name, sub, price, original;
  final bool selected, hot;
  final VoidCallback onTap;
  const _PackageTile({
    required this.name,
    required this.sub,
    required this.price,
    required this.original,
    required this.selected,
    required this.hot,
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
                        if (hot)
                          hbox(
                            bg: dk(
                              context,
                              const Color(0xFFFFE1E2),
                              const Color.fromRGBO(255, 56, 60, 0.18),
                            ),
                            radius: BorderRadius.circular(9),
                            pad: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '热卖',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  const Color(0xFFA43433),
                                  const Color(0xFFFF7B7E),
                                ),
                                w: FontWeight.w600,
                                lh: 18,
                              ),
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
