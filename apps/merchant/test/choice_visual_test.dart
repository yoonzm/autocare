import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/pages/members/members_page.dart';
import 'package:autocare_merchant/pages/catalog/services_page.dart';

import 'members_test.dart' show MemberFakeApi;

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = MemberFakeApi();
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
    testWidgets('选择标签代表页面 ${dark ? 'dark' : 'light'}', (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      C.dark = dark;
      for (final width in [360.0, 390.0]) {
        t.view.physicalSize = Size(width, 860);
        final pages = <String, Widget>{
          'members': const MembersPage(),
          'services': const ServicesPage(),
          'states': Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('客户来源 / 多行筛选'),
                  AppChoiceGroup<int>(
                    semanticLabel: '客户来源',
                    kind: ChipKind.pill,
                    items: [
                      for (var i = 0; i < 8; i++)
                        ChoiceItem(value: i, label: '客户来源 $i'),
                    ],
                    selected: 1,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 20),
                  const Text('多选技能'),
                  AppChoiceGroup<int>.multiple(
                    items: const [
                      ChoiceItem(value: 0, label: '洗车'),
                      ChoiceItem(value: 1, label: '抛光'),
                      ChoiceItem(value: 2, label: '贴膜'),
                      ChoiceItem(value: 3, label: '已停用', enabled: false),
                    ],
                    selectedValues: const {0, 2},
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 20),
                  const Text('预约时段'),
                  AppChoiceGroup<String>(
                    semanticLabel: '预约时段',
                    kind: ChipKind.tile,
                    columns: 3,
                    items: const [
                      ChoiceItem(value: '09:00', label: '09:00'),
                      ChoiceItem(
                        value: '09:30',
                        label: '09:30',
                        enabled: false,
                      ),
                      ChoiceItem(value: '10:00', label: '10:00'),
                      ChoiceItem(value: '10:30', label: '10:30'),
                    ],
                    selected: '10:00',
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
        };
        for (final entry in pages.entries) {
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
          final dir = Platform.environment['CHOICE_RENDER_DIR'];
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
