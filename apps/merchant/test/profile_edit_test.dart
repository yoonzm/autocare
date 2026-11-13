import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'dart:async';

import 'package:autocare_merchant/pages/account/profile_edit_page.dart';
import 'package:autocare_merchant/kit/async_kit.dart' show AppSpinner;
import 'package:flutter/material.dart';
import 'package:autocare_merchant/kit/image_pick.dart' show ImageSlot;
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/profile_flow.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class ProfileApi extends MemberFakeApi {
  final profileSaves = <Map<String, String>>[];
  Object? failure;
  final uploads = <String>[];
  Completer<void>? saveGate;
  Map<String, dynamic> profile = {
    'name': '陈明',
    'email': 'old@example.com',
    'role': 'owner',
    'phone': '+8613900008812',
    'joined_on': '2022-01-05',
  };
  @override
  Future<Map<String, dynamic>> getStore() async => {
    'id': 'first',
    'name': '原店',
    'account_phone': '13900008812',
    'profile': profile,
  };
  @override
  Future<String> uploadAvatar(String base64Data) async {
    uploads.add(base64Data);
    profile = {...profile, 'avatar_url': 'https://example.test/a.png'};
    return 'https://example.test/a.png';
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    profileSaves.add({'name': name, 'email': email});
    await saveGate?.future;
    if (failure != null) throw failure!;
    profile = {...profile, 'name': name, 'email': email};
    return profile;
  }
}

void main() {
  late MerchantApi original;
  late ProfileApi api;
  XFile? pickedAvatar;
  setUp(() async {
    original = merchantApi;
    merchantApi = api = ProfileApi();
    StoreContext.bind('first');
    pickedAvatar = null;
    navTracker.stack.clear();
    storeProfile.apply(await api.getStore());
  });
  tearDown(() async {
    merchantApi = original;
    StoreContext.bind(null);
    navTracker.stack.clear();
  });

  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileEditPage(pickAvatar: (_) async => pickedAvatar),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('回填当前登录人的资料，手机号脱敏显示', (t) async {
    await open(t);
    expect(
      t.widget<TextFormField>(find.byType(TextFormField).at(0)).initialValue,
      '陈明',
    );
    expect(
      t.widget<TextFormField>(find.byType(TextFormField).at(1)).initialValue,
      'old@example.com',
    );
    expect(find.text('139 **** 8812'), findsOneWidget);
    expect(find.text('2022.01'), findsOneWidget);
  });

  testWidgets('保存调用接口并返回上一页，不打开新页面', (t) async {
    await open(t);
    await t.enterText(find.byType(TextFormField).at(0), '陈明明');
    await t.enterText(find.byType(TextFormField).at(1), 'new@example.com');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.profileSaves.single, {
      'name': '陈明明',
      'email': 'new@example.com',
    });
    expect(storeProfile.profileName, '陈明明');
    expect(ProfileFlow.changed.value, greaterThan(0));
    expect(find.text('open'), findsOneWidget);
    expect(find.text('编辑资料'), findsNothing);
  });

  testWidgets('姓名为空不提交；服务端失败时留在本页', (t) async {
    await open(t);
    await t.enterText(find.byType(TextFormField).at(0), '');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.profileSaves, isEmpty);
    expect(find.text('编辑资料'), findsOneWidget);

    await t.enterText(find.byType(TextFormField).at(0), '新名字');
    api.failure = const AppError('请输入正确的邮箱');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.profileSaves, hasLength(1));
    expect(find.text('编辑资料'), findsOneWidget);
  });

  testWidgets('选了新头像：保存时先上传再保存资料，然后返回', (t) async {
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
    );
    pickedAvatar = XFile.fromData(
      bytes,
      name: 'avatar.png',
      path: '/test/avatar.png',
    );
    await open(t);
    await t.tap(find.text('更换头像'));
    await t.pumpAndSettle();
    expect(
      t.widget<ImageSlot>(find.byType(ImageSlot)).localPath,
      pickedAvatar!.path,
    );
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.uploads, hasLength(1));
    expect(api.profileSaves, hasLength(1));
    expect(base64Decode(api.uploads.single), bytes);
    expect(storeProfile.avatarUrl, 'https://example.test/a.png');
    expect(find.text('编辑资料'), findsNothing);
  });
  testWidgets('保存防重复且失败后保留输入，重试成功才返回', (t) async {
    await open(t);
    await t.enterText(find.byType(TextFormField).at(0), '独立姓名');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    api.saveGate = Completer<void>();
    api.failure = const AppError('保存失败');
    final point = t.getCenter(find.text('保存'));
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(20, 20));
    await t.tapAt(point);
    await t.pump();
    expect(api.profileSaves, hasLength(1));
    api.saveGate!.complete();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '独立姓名'), findsOneWidget);
    expect(find.text('保存失败'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.saveGate = null;
    api.failure = null;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(api.profileSaves, hasLength(2));
  });
  testWidgets('取消另一份资料表单不会覆盖原来的编辑值', (t) async {
    await open(t);
    await t.enterText(find.byType(TextFormField).at(0), '第一份姓名');
    final context = t.element(find.byType(ProfileEditPage));
    Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const ProfileEditPage()));
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField).first).controller!.text,
      '陈明',
    );
    await t.enterText(find.byType(TextFormField).first, '第二份姓名');
    Navigator.of(t.element(find.byType(ProfileEditPage))).pop();
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField).first).controller!.text,
      '第一份姓名',
    );
  });
}
