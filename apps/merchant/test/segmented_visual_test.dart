import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';

import 'appointments_test.dart' show BookingApi;
import 'orders_test.dart' show OrderApi;

import 'package:autocare_merchant/pages/orders/order_live_pages.dart';

import 'package:autocare_merchant/pages/staff/staff_editor_page.dart';
import 'package:autocare_merchant/pages/members/member_add_page.dart';

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = BookingApi();
    ServiceStore.clear();
  });
  tearDown(() {
    merchantApi = original;
    ServiceStore.clear();
    C.dark = false;
  });
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('C:/Windows/Fonts/msyh.ttc');
    if (font.existsSync()) {
      await (FontLoader('Microsoft YaHei')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets('分段选择代表页面 ${dark ? 'dark' : 'light'}', (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      C.dark = dark;
      for (final width in [360.0, 390.0]) {
        t.view.physicalSize = Size(width, 860);
        final pages = <String, Widget>{
          'staff': const StaffResourcesPage(),
          'member-add': const MemberAddPage(),
          'orders': const OrderListLivePage(),
        };
        for (final entry in pages.entries) {
          merchantApi = entry.key == 'orders' ? OrderApi() : BookingApi();
          final key = GlobalKey();
          await t.pumpWidget(
            MaterialApp(
              theme: buildTheme(dark ? Brightness.dark : Brightness.light)
                  .copyWith(
                    textTheme: buildTheme(
                      dark ? Brightness.dark : Brightness.light,
                    ).textTheme.apply(fontFamily: 'Microsoft YaHei'),
                  ),
              home: RepaintBoundary(key: key, child: entry.value),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: '${entry.key} $width');
          final dir = Platform.environment['SEGMENT_RENDER_DIR'];
          if (dir != null) {
            await t.runAsync(() async {
              final image =
                  await (key.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              await Directory(dir).create(recursive: true);
              await File(
                '$dir/${entry.key}-${dark ? 'dark' : 'light'}-${width.toInt()}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
            });
          }
          await t.pumpWidget(const SizedBox());
        }
      }
    });
  }
}
