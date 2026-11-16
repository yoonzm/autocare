import 'package:autocare_merchant/pages/scan/find_not_found_sheet.dart';
import 'package:autocare_merchant/pages/scan/scan_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('未找到会员：车牌标签贴合文字宽度，不撑满整行', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FindNotFoundSheet(
            result: ScanResult({'matched': false, 'plate': '浙H2F185', 'plate_color': 'blue'}),
          ),
        ),
      ),
    );
    await t.pump();
    final badge = find.ancestor(of: find.text('浙H·2F185'), matching: find.byType(Container)).first;
    expect(t.getSize(badge).width, lessThan(160));
  });
}
