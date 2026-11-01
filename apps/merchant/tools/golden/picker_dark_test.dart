// ignore_for_file: avoid_print
// 本地验证：系统深色模式下，滚轮选择器的文字仍然可见。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimei_guanjia/kit/pickers.dart';

void main() {
  testWidgets('dark picker', (tester) async {
    final loader = FontLoader('Wqy')
      ..addFont(
        Future.value(
          File('/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc')
              .readAsBytesSync()
              .buffer
              .asByteData(),
        ),
      );
    await loader.load();
    tester.view.physicalSize = const Size(390 * 2, 600 * 2);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAllTestValues();
    });
    final key = GlobalKey();
    late BuildContext ctx;
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(fontFamily: 'Wqy'),
          home: Builder(
            builder: (c) {
              ctx = c;
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      ),
    );
    // ignore: use_build_context_synchronously
    pickDate(ctx, '选择生日', birthday: true, current: '选填，用于生日礼');
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 1);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      File('/tmp/claude-0/out/picker_dark.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
