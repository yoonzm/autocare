import 'package:autocare_merchant/pages/inventory/inventory_voucher_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('没有凭证：整块卡片不显示', (t) async {
    await t.pumpWidget(_app(const InventoryVoucherCard(paths: [])));
    expect(find.textContaining('送货单'), findsNothing);
    expect(find.text('查看附件'), findsNothing);
  });

  testWidgets('凭证卡片：标题带张数，缩略图一排；点击进入大图预览，显示 1 / 2、提示和关闭', (t) async {
    await t.pumpWidget(
      _app(
        const InventoryVoucherCard(
          paths: ['s/a.png', 's/b.png'],
          urls: {
            's/a.png': 'https://example.invalid/a.png',
            's/b.png': 'https://example.invalid/b.png',
          },
        ),
      ),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('送货单 / 发票 · 2 张'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('查看凭证 1'), findsOneWidget);
    expect(find.bySemanticsLabel('查看凭证 2'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('查看凭证 2'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('双指缩放，左右滑动切换'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('关闭预览'));
    await t.pumpAndSettle();
    expect(find.text('双指缩放，左右滑动切换'), findsNothing);
  });

  testWidgets('没有签名链接的凭证显示文档占位，不能预览', (t) async {
    await t.pumpWidget(
      _app(const InventoryVoucherCard(paths: ['s/a.png'], urls: {})),
    );
    expect(find.bySemanticsLabel('查看凭证 1'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('查看凭证 1'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('双指缩放，左右滑动切换'), findsNothing);
  });
}
