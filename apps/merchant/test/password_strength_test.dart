import 'package:autocare_merchant/backend/password_reset_challenge.dart';
import 'package:autocare_merchant/backend/password_validation.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/pages/account/change_password_page.dart';
import 'package:autocare_merchant/pages/account/forgot_reset_page.dart';
import 'package:autocare_merchant/pages/account/password_strength_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluatePassword', () {
    test('空密码为 none 且所有规则未通过', () {
      final r = evaluatePassword('', current: 'OldPass123', phone: '13812345678');
      expect(r.strength, PasswordStrength.none);
      expect(r.hasLength, isFalse);
      expect(r.hasLetterAndDigit, isFalse);
      expect(r.differsFromCurrent, isFalse);
      expect(r.noPhoneDigits, isFalse);
    });

    test('长度不足、纯数字或纯字母均为弱', () {
      final short = evaluatePassword('1234', current: '', phone: '13812345678');
      expect(short.strength, PasswordStrength.weak);
      expect(short.hasLength, isFalse);
      expect(short.hasLetterAndDigit, isFalse);
      expect(short.noPhoneDigits, isTrue);

      final digitsOnly = evaluatePassword('12345678', phone: '13900001111');
      expect(digitsOnly.strength, PasswordStrength.weak);
      expect(digitsOnly.hasLength, isTrue);
      expect(digitsOnly.hasLetterAndDigit, isFalse);

      final lettersOnly = evaluatePassword('abcdefgh', phone: '13900001111');
      expect(lettersOnly.strength, PasswordStrength.weak);
      expect(lettersOnly.hasLength, isTrue);
      expect(lettersOnly.hasLetterAndDigit, isFalse);

      final tooLong = evaluatePassword(
        'Abcdefgh1234567890123',
        phone: '13900001111',
      );
      expect(tooLong.strength, PasswordStrength.weak);
      expect(tooLong.hasLength, isFalse);
    });

    test('与当前密码相同或包含手机号连续 6 位数字时降为弱', () {
      final same = evaluatePassword(
        'Abc12345678',
        current: 'Abc12345678',
        phone: '13900001111',
      );
      expect(same.differsFromCurrent, isFalse);
      expect(same.strength, PasswordStrength.weak);

      final hasPhone = evaluatePassword(
        'Abc123456xyz',
        current: 'OldPass999',
        phone: '+8613812345678',
      );
      expect(hasPhone.noPhoneDigits, isFalse);
      expect(hasPhone.strength, PasswordStrength.weak);
    });

    test('合规密码按长度与字符种类分为中、强、极强', () {
      final medium = evaluatePassword('abc12345', phone: '13900001111');
      expect(medium.strength, PasswordStrength.medium);

      final strongByCase = evaluatePassword('Abc12345', phone: '13900001111');
      expect(strongByCase.strength, PasswordStrength.strong);

      final strongByLength = evaluatePassword(
        'abc12345678',
        phone: '13900001111',
      );
      expect(strongByLength.strength, PasswordStrength.strong);

      final veryStrongByLenAndTypes = evaluatePassword(
        'Abc123456789',
        phone: '13900001111',
      );
      expect(veryStrongByLenAndTypes.strength, PasswordStrength.veryStrong);

      final veryStrongByFourTypes = evaluatePassword(
        'Abc!123456',
        phone: '13900001111',
      );
      expect(veryStrongByFourTypes.strength, PasswordStrength.veryStrong);
    });
  });

  group('页面实时联动', () {
    setUp(() {
      storeProfile.clear();
      storeProfile.apply({'phone': '+8613812345678', 'name': '蓝鲸养护'});
    });
    tearDown(storeProfile.clear);

    List<bool> ruleStates(WidgetTester t) => t
        .widget<PasswordRulesCard>(find.byType(PasswordRulesCard))
        .rules
        .map((r) => r.satisfied)
        .toList();

    testWidgets('修改登录密码页随输入实时更新强度与 4 条规则', (t) async {
      t.view.physicalSize = const Size(1170, 2700);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);

      await t.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
      await t.pumpAndSettle();

      // 初始空状态
      expect(find.text('强度：—'), findsOneWidget);
      expect(ruleStates(t), [false, false, false, false]);

      // 输入 4 位纯数字：弱
      await t.enterText(find.byType(TextFormField).at(1), '1234');
      await t.pump();
      expect(find.text('强度：弱'), findsOneWidget);
      expect(ruleStates(t), [false, false, true, true]);

      // 输入 8 位小写+数字：中
      await t.enterText(find.byType(TextFormField).at(1), 'abcd5678');
      await t.pump();
      expect(find.text('强度：中'), findsOneWidget);
      expect(ruleStates(t), [true, true, true, true]);

      // 当前密码输入与新密码一致：第 3 条规则变为未满足且强度降为弱
      await t.enterText(find.byType(TextFormField).at(0), 'abcd5678');
      await t.pump();
      expect(find.text('强度：弱'), findsOneWidget);
      expect(ruleStates(t), [true, true, false, true]);

      // 改为包含手机号连续 6 位数字：第 4 条规则变为未满足且强度为弱
      await t.enterText(find.byType(TextFormField).at(1), 'Abc123456');
      await t.pump();
      expect(find.text('强度：弱'), findsOneWidget);
      expect(ruleStates(t), [true, true, true, false]);

      // 输入强密码
      await t.enterText(find.byType(TextFormField).at(1), 'Abcd5678');
      await t.pump();
      expect(find.text('强度：强'), findsOneWidget);
      expect(ruleStates(t), [true, true, true, true]);

      // 输入极强密码
      await t.enterText(find.byType(TextFormField).at(1), 'Abcd!5678901');
      await t.pump();
      expect(find.text('强度：极强'), findsOneWidget);
      expect(ruleStates(t), [true, true, true, true]);
    });

    testWidgets('忘记密码重置页随输入实时更新强度与 3 条规则', (t) async {
      t.view.physicalSize = const Size(1170, 2700);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);

      await t.pumpWidget(
        const MaterialApp(
          home: ForgotResetPage(
            challenge: PasswordResetChallenge(
              phone: '13812345678',
              code: '123456',
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      expect(find.text('强度：—'), findsOneWidget);
      expect(ruleStates(t), [false, false, false]);

      await t.enterText(find.byType(TextFormField).at(0), '1234');
      await t.pump();
      expect(find.text('强度：弱'), findsOneWidget);
      expect(ruleStates(t), [false, false, true]);

      await t.enterText(find.byType(TextFormField).at(0), 'Abc123456');
      await t.pump();
      expect(find.text('强度：弱'), findsOneWidget);
      expect(ruleStates(t), [true, true, false]);

      await t.enterText(find.byType(TextFormField).at(0), 'Abcd5678');
      await t.pump();
      expect(find.text('强度：强'), findsOneWidget);
      expect(ruleStates(t), [true, true, true]);
    });
  });
}
