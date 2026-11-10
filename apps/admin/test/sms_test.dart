import 'package:autocare_admin/data/admin_api.dart';
import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/pages/mine_page.dart';
import 'package:autocare_admin/pages/sms_pages.dart';
import 'package:autocare_admin/theme.dart';
import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sms(
  String id,
  String phone, {
  String purpose = 'login',
  String status = 'sent',
  String code = '482916',
  String error = '',
  int attempts = 0,
  String? consumedAt,
  required DateTime created,
  Duration validFor = const Duration(minutes: 5),
}) => {
  'id': id,
  'phone': phone,
  'purpose': purpose,
  'kind': 'code',
  'code': code,
  'content': '【汽美管家】验证码 $code，5 分钟内有效，请勿泄露给他人。',
  'provider': 'zhutong',
  'sign_name': '汽美管家',
  'status': status,
  'error': error,
  'attempts': attempts,
  'store_name': '',
  'created_at': created.toIso8601String(),
  'sent_at': status == 'sent' ? created.toIso8601String() : null,
  'expires_at': created.add(validFor).toIso8601String(),
  'consumed_at': consumedAt,
};

class SmsApi extends AdminApi {
  final calls = <Map<String, dynamic>>[];
  Object? failure;
  Object? resendFailure;
  late List<Map<String, dynamic>> rows;
  bool more = false;
  @override
  bool get hasSession => false;
  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add({'action': action, ...values});
    final now = DateTime.now().toUtc();
    if (failure != null) throw failure!;
    switch (action) {
      case 'sms_list':
        final kind = values['kind'];
        final phone = (values['phone'] as String?) ?? '';
        final list = rows.where((r) {
          if (kind == 'failed' && r['status'] != 'failed') return false;
          if (kind == 'notice') return false;
          return phone.isEmpty || (r['phone'] as String).contains(phone);
        }).toList();
        return {
          'items': list,
          'more': more,
          'failed_count': rows.where((r) => r['status'] == 'failed').length,
          'now': now.toIso8601String(),
        };
      case 'sms_get':
        return {
          'item': rows.firstWhere((r) => r['id'] == values['id']),
          'now': now.toIso8601String(),
        };
      case 'sms_resend':
        if (resendFailure != null) throw resendFailure!;
        return {'ok': true, 'retry_after': 60};
    }
    return {};
  }
}

void main() {
  late SmsApi api;
  late DateTime now;
  setUp(() {
    api = SmsApi();
    store = Store(api: api);
    now = DateTime.now().toUtc();
    api.rows = [
      sms('a', '+8613800137712', created: now.subtract(const Duration(minutes: 1))),
      sms(
        'b',
        '+8613677889900',
        status: 'failed',
        error: '短信发送失败，请稍后重试（provider_rejected）',
        created: now.subtract(const Duration(minutes: 5)),
      ),
      sms(
        'c',
        '+8613911223344',
        purpose: 'register',
        code: '307184',
        created: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  });
  tearDown(() {
    store = Store();
    C.dark = false;
  });

  Future<void> open(WidgetTester t, {Widget? page}) async {
    t.view.physicalSize = const Size(390, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(MaterialApp(home: page ?? const SmsLogsPage()));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
  }

  testWidgets('列表显示完整手机号和验证码明文，失败原因与失败数', (t) async {
    await open(t);
    expect(find.text('138 0013 7712'), findsOneWidget);
    expect(find.text('482916'), findsOneWidget);
    expect(find.text('登录验证码'), findsWidgets);
    expect(find.text('注册验证码'), findsOneWidget);
    expect(find.textContaining('provider_rejected'), findsOneWidget);
    expect(find.text('重发'), findsOneWidget);
    expect(find.textContaining('剩余'), findsWidgets);
    expect(find.text('失败 1', findRichText: true), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(find.textContaining('已送达'), findsNothing);
    expect(api.calls.first, {'action': 'sms_list', 'kind': 'all'});
  });

  testWidgets('切换到「失败」只查失败记录，「通知」暂无时显示空状态', (t) async {
    await open(t);
    await t.tap(find.text('失败 1', findRichText: true));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.last['kind'], 'failed');
    expect(find.text('138 0013 7712'), findsNothing);
    expect(find.text('136 7788 9900'), findsOneWidget);
    await t.tap(find.text('通知'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('暂无通知短信'), findsOneWidget);
  });

  testWidgets('按手机号搜索会防抖后请求服务端', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField), '7712');
    await t.pump(const Duration(milliseconds: 100));
    expect(api.calls.where((c) => c['action'] == 'sms_list').length, 1);
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.last['phone'], '7712');
    expect(find.text('136 7788 9900'), findsNothing);
    await t.enterText(find.byType(TextField), '000000');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('没有找到相关短信'), findsOneWidget);
  });

  testWidgets('复制验证码写入剪贴板并提示', (t) async {
    String? copied;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await open(t);
    await t.tap(find.text('复制').first);
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(copied, '482916');
    expect(find.text('验证码已复制'), findsOneWidget);
  });

  testWidgets('失败的验证码可重发：调用服务端并刷新；被限流时展示服务端文案', (t) async {
    await open(t);
    await t.tap(find.text('重发'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    final resend = api.calls.where((c) => c['action'] == 'sms_resend').toList();
    expect(resend.single['id'], 'b');
    expect(find.text('验证码已重新发送'), findsOneWidget);
    expect(api.calls.where((c) => c['action'] == 'sms_list').length, 2);

    api.resendFailure = const AppError('请 45 秒后再获取验证码');
    await t.pump(const Duration(seconds: 4));
    await t.tap(find.text('重发'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('请 45 秒后再获取验证码'), findsOneWidget);
  });

  testWidgets('首次加载失败显示错误并可重试，不退回假数据', (t) async {
    api.failure = const AppError('服务不可用', type: AppErrorType.server);
    await open(t);
    expect(find.text('138 0013 7712'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    api.failure = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('138 0013 7712'), findsOneWidget);
  });

  testWidgets('点进详情：验证码、内容、场景、通道和验证状态', (t) async {
    await open(t);
    await t.tap(find.text('138 0013 7712'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.any((c) => c['action'] == 'sms_get' && c['id'] == 'a'), isTrue);
    expect(find.text('短信详情'), findsOneWidget);
    expect(find.text('482916'), findsOneWidget);
    expect(find.textContaining('验证码 482916'), findsOneWidget);
    expect(find.text('登录 · 验证码登录'), findsOneWidget);
    expect(find.text('助通短信 · 签名「汽美管家」'), findsOneWidget);
    expect(find.text('未使用'), findsOneWidget);
    expect(find.text('送达时间'), findsOneWidget);
    expect(find.text('复制验证码'), findsOneWidget);
    await t.tap(find.text('重发'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.any((c) => c['action'] == 'sms_resend' && c['id'] == 'a'), isTrue);
    expect(find.text('短信详情'), findsNothing);
  });

  testWidgets('已使用 / 已过期 / 错误次数过多的验证状态', (t) async {
    final created = now.subtract(const Duration(minutes: 20));
    api.rows = [
      sms('u', '+8613800000001', created: created, consumedAt: created.toIso8601String()),
      sms('e', '+8613800000002', created: created),
      sms('x', '+8613800000003', created: now, attempts: 5),
    ];
    await open(t);
    expect(find.text('已使用'), findsOneWidget);
    expect(find.text('已过期'), findsOneWidget);
    expect(find.text('错误次数过多'), findsOneWidget);
  });

  testWidgets('「我的」里只有超级管理员看得到短信记录入口', (t) async {
    Account account(Role role) => Account(
      id: 'me',
      name: '测试',
      username: 'tester',
      role: role,
    );
    store.me = account(Role.superAdmin);
    await open(t, page: const MinePage());
    expect(find.text('短信记录'), findsOneWidget);
    expect(find.text('验证码与通知 · 仅超级管理员可见'), findsOneWidget);
    store.me = account(Role.ops);
    store.notifyListeners();
    await t.pumpAndSettle();
    expect(find.text('短信记录'), findsNothing);
  });
}
