import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/merchant_backend.dart';
import 'package:autocare_merchant/main.dart';
import 'package:autocare_merchant/mock/theme_state.dart';
import 'package:autocare_merchant/pages/settings_page.dart';
import 'package:autocare_merchant/theme.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  });
  tearDown(() {
    appThemeMode.value = ThemeMode.system;
    C.dark = false;
  });

  testWidgets('外观弹层：选择深色并应用后全局切换为深色，再切回浅色', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const QimeiApp());
    expect(C.dark, isFalse);

    Future<void> apply(String label) async {
      await t.scrollUntilVisible(
        find.text('外观'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await t.pumpAndSettle();
      await t.tap(find.text('外观'));
      await t.pumpAndSettle();
      await t.tap(find.text(label));
      await t.pump();
      await t.tap(find.text('应用'));
      await t.pumpAndSettle();
    }

    final ctx = t.element(find.byType(Scaffold).first);
    Navigator.of(ctx)
        .push(MaterialPageRoute(builder: (_) => const SettingsPage()));
    await t.pumpAndSettle();

    await apply('深色');
    expect(appThemeMode.value, ThemeMode.dark);
    expect(C.dark, isTrue);
    expect(t.takeException(), isNull);

    await apply('浅色');
    expect(C.dark, isFalse);
    expect(t.takeException(), isNull);
  });
}
