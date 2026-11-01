import 'dart:async';

import 'package:autocare_merchant/kit/kit.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/widgets/app_icon.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 假相机：记录闪光灯 / 拍照 / 暂停预览调用，不依赖真机。
class _FakeCamera extends CameraPlatform with MockPlatformInterfaceMixin {
  _FakeCamera({this.cameras = 1});
  final int cameras;
  final flashModes = <FlashMode>[];
  int shots = 0, paused = 0, resumed = 0, disposed = 0;

  @override
  Future<List<CameraDescription>> availableCameras() async => [
    for (var i = 0; i < cameras; i++)
      const CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
  ];

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async => 1;

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream.value(
        CameraInitializedEvent(
          cameraId,
          1280,
          720,
          ExposureMode.auto,
          false,
          FocusMode.auto,
          false,
        ),
      );

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      StreamController<CameraErrorEvent>.broadcast().stream;

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      StreamController<DeviceOrientationChangedEvent>.broadcast().stream;

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {}

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async =>
      flashModes.add(mode);

  @override
  Future<XFile> takePicture(int cameraId) async {
    shots++;
    return XFile('/tmp/fake_scan.jpg');
  }

  @override
  Future<void> pausePreview(int cameraId) async => paused++;

  @override
  Future<void> resumePreview(int cameraId) async => resumed++;

  @override
  Widget buildPreview(int cameraId) =>
      const ColoredBox(key: Key('live-preview'), color: Colors.teal);

  @override
  Future<void> dispose(int cameraId) async => disposed++;
}

void main() {
  late CameraPlatform old;
  setUp(() {
    old = CameraPlatform.instance;
    navTracker.stack.clear(); // 全局导航记录会在用例间残留
  });
  tearDown(() => CameraPlatform.instance = old);

  Future<BuildContext> open(WidgetTester t, String route) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('入口'));
          },
        ),
      ),
    );
    openRoute(ctx, route);
    await t.pumpAndSettle();
    return ctx;
  }

  final bolt = find.byWidgetPredicate((w) => w is AppIcon && w.name == 'bolt');

  testWidgets('扫描页直接显示实时相机画面，不再是示意背景', (t) async {
    CameraPlatform.instance = _FakeCamera();
    await open(t, 'FindScanPlate');
    expect(find.byKey(const Key('live-preview')), findsOneWidget);
    // 取景框里不再放示意车牌 / 二维码
    expect(find.text('沪A·8K29M'), findsNothing);
    expect(find.text('将车牌对准框内'), findsOneWidget);
    await t.tap(find.text('会员码'));
    await t.pumpAndSettle();
    // 切换 Tab 不重启相机
    expect(find.byKey(const Key('live-preview')), findsOneWidget);
    expect((CameraPlatform.instance as _FakeCamera).disposed, 0);
  });

  testWidgets('闪光灯：点击开启常亮（torch），再点关闭', (t) async {
    final cam = _FakeCamera();
    CameraPlatform.instance = cam;
    await open(t, 'ScanLicense');
    expect(cam.flashModes, [FlashMode.off]);
    await t.tap(bolt);
    await t.pumpAndSettle();
    expect(cam.flashModes.last, FlashMode.torch);
    await t.tap(bolt);
    await t.pumpAndSettle();
    expect(cam.flashModes.last, FlashMode.off);
  });

  testWidgets('点快门：真实拍照 → 定格画面 → 识别 → 打开结果，关闭后恢复取景', (t) async {
    final cam = _FakeCamera();
    CameraPlatform.instance = cam;
    final sem = t.ensureSemantics();
    final ctx = await open(t, 'FindScanPlate');
    await t.tap(find.bySemanticsLabel('拍摄识别'));
    await t.pump(const Duration(milliseconds: 100));
    expect(cam.shots, 1);
    expect(cam.paused, 1);
    expect(imageStore('scan_photo').value, ['/tmp/fake_scan.jpg']);
    expect(find.text('识别中…'), findsOneWidget);
    expect(navTracker.has('sheet:FindResult'), isFalse);
    // 识别结束后弹出匹配结果
    await t.pump(const Duration(milliseconds: 1500));
    await t.pump(const Duration(milliseconds: 400));
    expect(navTracker.has('sheet:FindResult'), isTrue);
    expect(find.text('识别中…'), findsNothing);
    // 关闭结果后继续取景
    Navigator.of(ctx, rootNavigator: true).pop();
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(cam.resumed, 1);
    sem.dispose();
  });

  testWidgets('没有可用相机时给出提示，点快门不会崩溃', (t) async {
    CameraPlatform.instance = _FakeCamera(cameras: 0);
    final sem = t.ensureSemantics();
    await open(t, 'ScanPlate');
    expect(find.text('相机不可用 · 点此重试'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('拍摄识别'));
    await t.pump();
    expect(find.text('相机未就绪'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    sem.dispose();
  });
}
