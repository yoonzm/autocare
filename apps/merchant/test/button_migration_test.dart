import 'dart:io';
import 'dart:ui' as ui;

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/buttons.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  @override
  bool get hasSession => false;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async => [];
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = _Api();
  });
  tearDown(() {
    merchantApi = original;
    C.dark = false;
  });
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('C:/Windows/Fonts/msyh.ttc');
    if (font.existsSync()) {
      await (FontLoader('ButtonAudit')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
  });

  for (final dark in [false, true]) {
    testWidgets('标准按钮代表页面及反馈状态可渲染 ${dark ? 'dark' : 'light'}', (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      C.dark = dark;
      final brightness = dark ? Brightness.dark : Brightness.light;
      final pages = <String, Widget>{
        'login': const LoginPage(),
        'service': const ServiceEditPage(
          initial: {'name': '精致洗车', 'price': 88},
        ),
        'states': Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: '确认收款',
                    size: AppButtonSize.large,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: '确认收款',
                    size: AppButtonSize.large,
                    loading: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  const AppButton(label: '请先选择会员', size: AppButtonSize.large),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      AppIconButton(
                        icon: Icons.add,
                        semanticLabel: '新增',
                        kind: AppIconButtonKind.primary,
                        onPressed: () {},
                      ),
                      AppIconButton(
                        icon: Icons.add,
                        semanticLabel: '新增',
                        kind: AppIconButtonKind.primary,
                        loading: true,
                        onPressed: () {},
                      ),
                      AppIconButton.pill(
                        label: '挂单',
                        badge: 12,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AppSmsCodeButton(onPressed: () {}),
                      AppSmsCodeButton(sending: true, onPressed: () {}),
                      AppSmsCodeButton(
                        seconds: 60,
                        sent: true,
                        onPressed: () {},
                      ),
                      AppSmsCodeButton(sent: true, onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ErrorView(error: const AppError.network(), onRetry: () {}),
                ],
              ),
            ),
          ),
        ),
      };
      for (final width in [360.0, 390.0]) {
        t.view.physicalSize = Size(width, 844);
        for (final entry in pages.entries) {
          final boundary = GlobalKey();
          await t.pumpWidget(
            MaterialApp(
              theme: buildTheme(brightness).copyWith(
                textTheme: buildTheme(brightness).textTheme
                    .apply(fontFamily: 'ButtonAudit'),
              ),
              home: RepaintBoundary(key: boundary, child: entry.value),
            ),
          );
          await t.pump(const Duration(milliseconds: 500));
          expect(t.takeException(), isNull, reason: '${entry.key} at $width');
          if (entry.key == 'states') {
            expect(find.widgetWithText(AppButton, '重试'), findsOneWidget);
          }
          final directory = Platform.environment['BUTTON_RENDER_DIR'];
          if (directory != null) {
            await t.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              await Directory(directory).create(recursive: true);
              await File(
                '$directory/${entry.key}-${dark ? 'dark' : 'light'}-${width.toInt()}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
            });
          }
          await t.pumpWidget(const SizedBox());
        }
      }
    });
  }
}
