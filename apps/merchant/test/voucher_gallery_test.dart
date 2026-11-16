import 'package:autocare_merchant/pages/expenses/voucher_gallery.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('凭证直接使用后端返回的链接：不再逐张请求签名，没有链接的路径不显示', (t) async {
    final requests = <Map<String, dynamic>>[];
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoucherGallery(
            paths: const ['a.jpg', 'b.jpg', 'gone.jpg'],
            urls: const {
              'a.jpg': 'https://example.test/a.jpg?token=1',
              'b.jpg': 'https://example.test/b.jpg?token=1',
            },
            request: (body) async {
              requests.add(body);
              return {};
            },
          ),
        ),
      ),
    );
    await t.pump();
    await t.pump();
    final grid = t.widget<AppImageUploader>(find.byType(AppImageUploader));
    expect(grid.items.map((i) => i.id), ['a.jpg', 'b.jpg']);
    expect(requests, isEmpty);
  });
}
