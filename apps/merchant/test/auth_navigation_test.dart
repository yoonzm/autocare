import 'package:autocare_merchant/main.dart';
import 'package:autocare_merchant/pages/login_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'sb_publishable_test',
    );
  });

  testWidgets('返回登录时保留监听认证状态的根页面', (tester) async {
    await tester.pumpWidget(const QimeiApp());
    expect(find.byType(StreamBuilder<AuthState>), findsOneWidget);

    final rootContext = tester.element(find.byType(LoginPage));
    Navigator.of(rootContext).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => openRoute(context, 'Login'),
              child: const Text('退出所有设备'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('退出所有设备'));
    await tester.pumpAndSettle();

    expect(find.byType(StreamBuilder<AuthState>), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('退出所有设备'), findsNothing);
  });
}
