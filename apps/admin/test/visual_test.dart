import 'dart:io';
import 'dart:ui' as ui;

import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/data/theme_state.dart';
import 'package:autocare_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'flow_test.dart' show TestApi;

void main() {
  testWidgets(
    'phone layout: existing login and four tabs in light/dark themes',
    (t) async {
      final directory = Platform.environment['ADMIN_RENDER_DIR'];
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      if (directory != null) {
        await t.runAsync(() async {
          final font = File('C:/Windows/Fonts/msyh.ttc');
          if (await font.exists()) {
            final bytes = ByteData.sublistView(await font.readAsBytes());
            await (FontLoader('Ahem')..addFont(Future.value(bytes))).load();
          }
          final material = Platform.environment['ADMIN_FONT_DIR'];
          if (material != null) {
            for (final entry in {
              'Roboto': 'roboto-regular.ttf',
              'MaterialIcons': 'materialicons-regular.otf',
            }.entries) {
              final bytes = ByteData.sublistView(
                await File('$material/${entry.value}').readAsBytes(),
              );
              await (FontLoader(
                entry.key,
              )..addFont(Future.value(bytes))).load();
            }
          }
        });
      }
      store = Store(api: TestApi());
      addTearDown(() {
        store = Store();
        appThemeMode.value = ThemeMode.system;
      });
      final key = GlobalKey();
      Future<void> capture(String name) async {
        expect(t.takeException(), isNull);
        if (directory == null) return;
        await t.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(directory).create(recursive: true);
          await File('$directory/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await t.pumpWidget(RepaintBoundary(key: key, child: const AdminApp()));
      await t.pumpAndSettle();
      await capture('login-light');
      await t.enterText(find.byType(TextField).at(0), 'test_admin');
      await t.enterText(find.byType(TextField).at(1), 'TestPassword8');
      await t.tap(find.text('登录'));
      await t.pumpAndSettle();
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        appThemeMode.value = mode;
        await t.pumpAndSettle();
        for (var i = 0; i < 4; i++) {
          await t.tap(find.byKey(ValueKey('nav-$i')));
          await t.pumpAndSettle();
          await capture('tab-$i-${mode.name}');
        }
      }
    },
  );
}
