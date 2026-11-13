import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('验证码四态固定尺寸，发送和倒计时禁点，重发回调且无内部计时', (t) async {
    for (final brightness in Brightness.values) {
      var calls = 0;
      Future<void> show({
        bool sending = false,
        int seconds = 0,
        bool sent = false,
      }) => pump(
        t,
        AppSmsCodeButton(
          sending: sending,
          seconds: seconds,
          sent: sent,
          onPressed: () => calls++,
        ),
        brightness: brightness,
      );
      await show();
      final size = t.getSize(find.byType(AppSmsCodeButton));
      expect(size, const Size(132, 44));
      await t.tap(find.text('获取验证码'));
      expect(calls, 1);
      await show(sending: true);
      expect(t.getSize(find.byType(AppSmsCodeButton)), size);
      expect(find.byType(AppSpinner), findsOneWidget);
      await t.tap(find.text('发送中…'));
      expect(calls, 1);
      await show(seconds: 60, sent: true);
      expect(t.getSize(find.byType(AppSmsCodeButton)), size);
      await t.pump(const Duration(seconds: 2));
      expect(find.text('60 秒后重发'), findsOneWidget);
      await t.tap(find.text('60 秒后重发'));
      expect(calls, 1);
      await show(sent: true);
      expect(t.getSize(find.byType(AppSmsCodeButton)), size);
      await t.tap(find.text('重新发送'));
      expect(calls, 2);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('普通按钮 loading 不改变尺寸；图标按钮 loading 保留背景', (t) async {
    for (final size in AppButtonSize.values) {
      await pump(t, AppButton(label: '保存', size: size, onPressed: () {}));
      final before = t.getSize(find.byType(AppButton));
      await pump(
        t,
        AppButton(label: '保存', size: size, loading: true, onPressed: () {}),
      );
      expect(t.getSize(find.byType(AppButton)), before);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }
    for (final brightness in Brightness.values) {
      await pump(
        t,
        AppIconButton(
          icon: Icons.add,
          semanticLabel: '新增',
          kind: AppIconButtonKind.primary,
          loading: true,
          onPressed: () {},
        ),
        brightness: brightness,
      );
      final spinner = find.byType(AppSpinner);
      final box = t.widget<Container>(
        find.ancestor(of: spinner, matching: find.byType(Container)).first,
      );
      expect(
        (box.decoration! as BoxDecoration).color,
        AppTokens.forBrightness(brightness).primary,
      );
      expect(t.takeException(), isNull);
    }
  });
}
