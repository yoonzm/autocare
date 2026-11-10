import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/image_pick.dart' show imageStore;
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/profile_flow.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class ProfileApi extends MemberFakeApi {
  final profileSaves = <Map<String, String>>[];
  Object? failure;
  final uploads = <String>[];
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
    if (failure != null) throw failure!;
    profile = {...profile, 'name': name, 'email': email};
    return profile;
  }
}

void main() {
  late MerchantApi original;
  late ProfileApi api;
  setUp(() async {
    original = merchantApi;
    merchantApi = api = ProfileApi();
    StoreContext.bind('first');
    RegistrationDraft.clear();
    navTracker.stack.clear();
    storeProfile.apply(await api.getStore());
  });
  tearDown(() {
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
              onPressed: () => openRoute(context, 'ProfileEdit'),
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
    expect(api.profileSaves.single, {'name': '陈明明', 'email': 'new@example.com'});
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
    ProfileFlow.readBytes = (_) async => [137, 80, 78, 71];
    await open(t);
    imageStore('ProfileEdit_avatar').value = ['/tmp/avatar.png'];
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.uploads, hasLength(1));
    expect(api.profileSaves, hasLength(1));
    expect(imageStore('ProfileEdit_avatar').value, isEmpty);
    expect(storeProfile.avatarUrl, 'https://example.test/a.png');
    expect(find.text('编辑资料'), findsNothing);
  });
}
