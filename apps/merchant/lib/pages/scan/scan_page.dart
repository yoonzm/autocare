import 'find_not_found_sheet.dart';

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../backend/merchant_api.dart';
import 'scan_result.dart';
import 'find_result_sheet.dart';
import 'plate_scan_result_live_sheet.dart';

import 'package:image_picker/image_picker.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart' show AppSpinner;
import '../../routes.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';

/// 车牌扫描：找会员或车辆建档。
enum ScanKind { findPlate, plateCard }

/// 相机状态：启动中 / 可用 / 无权限 / 不可用（模拟器、无摄像头等）。
enum _Cam { starting, ready, denied, unavailable }

// 仅保留车牌扫描：头部 44；底部快门行 78。
const double _kTop = 44;
const double _kBottom = 78;

class ScanPage extends StatefulWidget {
  final ScanKind initial;
  final bool returnVehicle;
  final void Function(BuildContext, Map<String, dynamic>)? onViewMember,
      onOrderMember;
  const ScanPage(
    this.initial, {
    super.key,
    this.returnVehicle = false,
    this.onViewMember,
    this.onOrderMember,
  });
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ScanKind get kind => widget.initial;

  CameraController? _ctrl;
  _Cam _cam = _Cam.starting;
  bool _initializing = false;
  bool _suspended = false; // 退到后台时释放了相机
  bool _torch = false;
  bool _busy = false; // 拍照 / 识别中
  bool _pickingAlbum = false;
  String? _albumPhoto;
  bool get _locked => _busy || _pickingAlbum;
  Offset? _focusAt;
  Timer? _focusTimer;
  Timer? _slowTimer;
  bool _slow = false;
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  bool get _find => kind == ScanKind.findPlate;
  String get _title => _find ? '扫码找会员' : '扫描建档';
  (String, String) get _hint => switch (kind) {
    ScanKind.findPlate => ('将车牌对准框内', '自动匹配该车牌对应的会员'),
    ScanKind.plateCard => ('将车牌对准框内', '支持蓝牌、绿牌（新能源）、黄牌'),
  };
  Size get _frame => const Size(300, 118);

  // ───────── 相机生命周期 ─────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusTimer?.cancel();
    _slowTimer?.cancel();
    _sweep.dispose();
    final c = _ctrl;
    _ctrl = null;
    c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final c = _ctrl;
      if (c == null) return;
      _suspended = true;
      _ctrl = null;
      if (mounted) setState(() => _cam = _Cam.starting);
      c.dispose();
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_initializing) return;
    _initializing = true;
    if (mounted) setState(() => _cam = _Cam.starting);
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _cam = _Cam.unavailable);
        return;
      }
      final desc = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        desc,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      try {
        await c.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {}
      try {
        await c.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
      } catch (_) {
        _torch = false;
      }
      setState(() {
        _ctrl = c;
        _cam = _Cam.ready;
      });
    } on CameraException catch (e) {
      if (mounted) {
        setState(
          () => _cam = e.code.startsWith('CameraAccess')
              ? _Cam.denied
              : _Cam.unavailable,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _cam = _Cam.unavailable);
    } finally {
      _initializing = false;
    }
  }

  bool get _ready => _ctrl != null && _ctrl!.value.isInitialized;

  // ───────── 交互：闪光灯 / 对焦 / 拍照 / 相册 ─────────
  Future<void> _toggleTorch() async {
    if (_locked) return;
    final c = _ctrl;
    if (!_ready || c == null) {
      hToast(context, '相机未就绪');
      return;
    }
    final next = !_torch;
    try {
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torch = next);
    } catch (_) {
      if (mounted) hToast(context, '当前设备不支持闪光灯');
    }
  }

  void _focus(TapUpDetails d, Size size) {
    final c = _ctrl;
    if (!_ready || c == null || _locked || _albumPhoto != null) return;
    final p = Offset(
      (d.localPosition.dx / size.width).clamp(0.0, 1.0),
      (d.localPosition.dy / size.height).clamp(0.0, 1.0),
    );
    () async {
      try {
        await c.setFocusMode(FocusMode.auto);
        await c.setFocusPoint(p);
        await c.setExposurePoint(p);
      } catch (_) {}
    }();
    HapticFeedback.selectionClick();
    _focusTimer?.cancel();
    setState(() => _focusAt = d.localPosition);
    _focusTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _focusAt = null);
    });
  }

  Future<void> _shoot() async {
    if (_locked) return;
    if (!_canRecognize()) return;
    final photo = _albumPhoto;
    if (photo != null) {
      await _recognize(photo);
      return;
    }
    final c = _ctrl;
    if (!_ready || c == null || c.value.isTakingPicture) {
      hToast(context, _cam == _Cam.denied ? '请在系统设置中允许访问相机' : '相机未就绪');
      return;
    }
    setState(() {
      _busy = true;
      _focusAt = null;
    });
    late final String photoPath;
    try {
      HapticFeedback.mediumImpact();
      final f = await c.takePicture();
      if (!mounted) return;
      photoPath = f.path;
      // 定格拍到的画面，随后开始识别
      try {
        await c.pausePreview();
      } catch (_) {}
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        hToast(context, '拍照失败，请重试');
      }
      return;
    }
    await _recognize(photoPath);
  }

  Future<void> _pickAlbum() async {
    if (_locked) return;
    if (!_canRecognize()) return;
    setState(() => _pickingAlbum = true);
    try {
      final photo = await pickSingleImage(context, source: ImageSource.gallery);
      if (photo != null && mounted) {
        setState(() {
          _albumPhoto = photo.path;
          _focusAt = null;
        });
      }
    } finally {
      if (mounted) setState(() => _pickingAlbum = false);
    }
  }

  bool _canRecognize() {
    if (!merchantApi.hasSession) {
      hToast(context, '请先登录');
      openRoute(context, 'Login');
      return false;
    }
    return true;
  }

  /// 两个车牌入口共用真实识别；只有当前页面仍有效时才发布识别结果。
  Future<void> _recognize(String imagePath) async {
    if (!mounted) return;
    setState(() => _busy = true);
    _sweep.repeat(reverse: true);
    _slow = false;
    _slowTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _busy) setState(() => _slow = true);
    });
    final started = DateTime.now();
    var resultName = kind == ScanKind.plateCard
        ? 'ScanPlateResult'
        : 'FindResult';
    String? failure;
    Map<String, dynamic>? response;
    if (merchantApi.hasSession) {
      try {
        final res = await merchantApi.recognizePlate(imagePath);
        if (!mounted) return;
        response = res;
        if (res['matched'] == true && res['member'] is Map) {
          resultName = kind == ScanKind.plateCard
              ? 'ScanPlateResult'
              : 'FindResult';
        } else {
          resultName = 'FindNotFound';
        }
      } catch (e) {
        failure = AppError.from(e).message;
      }
    } else {
      failure = '请先登录';
    }
    final left =
        const Duration(milliseconds: 1300) - DateTime.now().difference(started);
    if (left > Duration.zero) await Future<void>.delayed(left);
    if (!mounted) return;
    _slowTimer?.cancel();
    _sweep.stop();
    if (failure != null) {
      setState(() => _busy = false);
      hToast(context, failure);
      try {
        await _ctrl?.resumePreview();
      } catch (_) {}
      return;
    }
    if (!merchantApi.hasSession) {
      setState(() => _busy = false);
      return;
    }
    setState(() => _albumPhoto = null);
    final result = ScanResult(response!);
    if (widget.returnVehicle && response['matched'] != true) {
      final vehicle = <String, dynamic>{
        'plate': response['plate'],
        'brand_model': response['vehicle_model'],
        'color': response['vehicle_color'],
      };
      setState(() => _busy = false);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => SingleChildScrollView(
          child: FindNotFoundSheet(
            result: result,
            onCreate: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).pop(vehicle);
            },
          ),
        ),
      );
      if (mounted) {
        try {
          await _ctrl?.resumePreview();
        } catch (_) {}
      }
      return;
    }
    setState(() => _busy = false);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: RouteSettings(name: 'sheet:$resultName'),
      builder: (sheetContext) => SingleChildScrollView(
        child: result.member == null
            ? FindNotFoundSheet(result: result)
            : kind == ScanKind.plateCard
            ? PlateScanResultLiveSheet(result: result)
            : FindResultSheet(
                result: result,
                onViewMember: widget.onViewMember == null
                    ? null
                    : () => widget.onViewMember!(sheetContext, result.member!),
                onOrderMember: widget.onOrderMember == null
                    ? null
                    : () => widget.onOrderMember!(sheetContext, result.member!),
              ),
      ),
    );
    if (!mounted) return;
    try {
      await _ctrl?.resumePreview();
    } catch (_) {}
  }

  // ───────── 构建 ─────────
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final pad = EdgeInsets.fromLTRB(20, top + 12, 20, bottom + 18);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _viewfinder(context),
          // 取景框 + 提示（压暗遮罩在这一层，位于头部与底部操作之下）
          Padding(
            padding: pad,
            child: Column(
              children: [
                const SizedBox(height: _kTop),
                Expanded(child: _frameAndHint()),
                const SizedBox(height: _kBottom),
              ],
            ),
          ),
          // 头部 / 底部操作
          Padding(
            padding: pad,
            child: Column(
              children: [_header(context), const Spacer(), _controls(context)],
            ),
          ),
        ],
      ),
    );
  }

  /// 最底层：实时相机画面（点击对焦）；相机不可用时退回深色背景。
  Widget _viewfinder(BuildContext context) {
    final photo = _albumPhoto;
    if (photo != null) {
      return Image.file(
        File(photo),
        key: const Key('album-preview'),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Center(
          child: Text('照片无法显示，请重新选择', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    final c = _ctrl;
    if (!_ready || c == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.2,
            colors: [Color(0xFF3A3F4A), Color(0xFF1B1D22), Color(0xFF0B0B0D)],
            stops: [0, 0.55, 1],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        // 铺满屏幕（cover），超出部分裁掉
        var scale = size.aspectRatio * c.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _focus(d, size),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                child: Transform.scale(
                  scale: scale,
                  child: Center(child: CameraPreview(c)),
                ),
              ),
              if (_focusAt != null)
                Positioned(
                  left: _focusAt!.dx - 32,
                  top: _focusAt!.dy - 32,
                  child: IgnorePointer(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.gold, width: 1.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _frameAndHint() {
    final frame = _frame;
    final (title, sub) = _busy
        ? ('识别中…', _slow ? '网络较慢，请稍候' : '请保持画面稳定')
        : _pickingAlbum
        ? ('选择照片中…', '选择后可预览并确认识别')
        : _albumPhoto != null
        ? ('确认照片后点击识别', '可从相册重新选择，或返回拍摄')
        : _hint;
    return IgnorePointer(
      ignoring: _cam == _Cam.ready,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: frame.width,
              height: frame.height,
              child: CustomPaint(
                foregroundPainter: const _Corners(),
                painter: const _Dim(),
                child: LayoutBuilder(
                  builder: (context, box) => AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) {
                      final t = _busy ? 0.1 + 0.8 * _sweep.value : 0.46;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 10,
                            right: 10,
                            top: box.maxHeight * t - 1,
                            height: 2,
                            child: const _ScanLine(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ts(16, w: FontWeight.w600, color: Colors.white, h: 24),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: ts(13, color: const Color(0xB3FFFFFF), h: 18),
            ),
            if (_albumPhoto == null &&
                (_cam == _Cam.denied || _cam == _Cam.unavailable)) ...[
              const SizedBox(height: 14),
              _cameraNotice(),
            ],
          ],
        ),
      ),
    );
  }

  /// 相机不可用时的提示（IgnorePointer 只在相机可用时生效，这里始终可点）。
  Widget _cameraNotice() => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _initCamera,
    child: Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        _cam == _Cam.denied ? '未获得相机权限，请在系统设置中允许 · 点此重试' : '相机不可用 · 点此重试',
        style: ts(12, color: Colors.white, h: 16),
      ),
    ),
  );

  Widget _header(BuildContext context) => Row(
    children: [
      _round(
        const AppIcon('close', size: 20, color: Colors.white),
        '关闭',
        () => Navigator.of(context).maybePop(),
      ),
      Expanded(
        child: Text(
          _title,
          textAlign: TextAlign.center,
          style: ts(17, w: FontWeight.w600, color: Colors.white, h: 24),
        ),
      ),
      if (_albumPhoto != null)
        _round(
          const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
          '返回拍摄',
          () {
            if (!_locked) setState(() => _albumPhoto = null);
          },
        )
      else
        _round(
          AppIcon('bolt', size: 20, color: _torch ? C.onGold : Colors.white),
          _torch ? '关闭闪光灯' : '打开闪光灯',
          _toggleTorch,
          bg: _torch ? C.gold : const Color(0x24FFFFFF),
        ),
    ],
  );

  Widget _controls(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _side('gallery', '相册', _pickAlbum),
      Semantics(
        button: true,
        label: _albumPhoto == null ? '拍摄识别' : '确认识别',
        enabled: !_locked,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _locked ? null : _shoot,
          child: Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: _busy
                ? Center(child: AppSpinner(size: 20, color: C.primary))
                : DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _albumPhoto == null
                        ? null
                        : const Icon(Icons.check, color: Colors.black),
                  ),
          ),
        ),
      ),
      _side(
        _find ? 'search' : 'pencil',
        _find ? '手动搜索' : '手动输入',
        () => _locked
            ? null
            : _find
            ? Navigator.of(context).maybePop()
            : openRoute(context, 'VehicleAdd'),
      ),
    ],
  );

  Widget _round(
    Widget icon,
    String label,
    VoidCallback onTap, {
    Color bg = const Color(0x24FFFFFF),
  }) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Center(child: icon),
      ),
    ),
  );

  Widget _side(String icon, String label, VoidCallback onTap) => SizedBox(
    width: 72,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _locked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: AppIcon(icon, size: 22, color: Colors.white)),
          ),
          const SizedBox(height: 6),
          Text(label, style: ts(12, color: const Color(0xD9FFFFFF), h: 16)),
        ],
      ),
    ),
  );
}

/// 取景框内的金色扫描线。
class _ScanLine extends StatelessWidget {
  const _ScanLine();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(1)),
      gradient: LinearGradient(
        colors: [Color(0x00F5D78E), Color(0xFFF5D78E), Color(0x00F5D78E)],
      ),
      boxShadow: [
        BoxShadow(color: Color(0x8CF5D78E), blurRadius: 14, spreadRadius: 3),
      ],
    ),
  );
}

/// 取景框外侧压暗（挖出圆角矩形）。
class _Dim extends CustomPainter {
  const _Dim();
  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(
        Rect.fromLTWH(-2000, -2000, 4400 + size.width, 4400 + size.height),
      ),
      Path()..addRRect(hole),
    );
    canvas.drawPath(path, Paint()..color = const Color(0x8C000000));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 四角金色定位角。
class _Corners extends CustomPainter {
  const _Corners();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFF5D78E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const r = 18.0, l = 26.0;
    final w = size.width, h = size.height;
    // 四个角：圆角弧 + 两条短边
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(l, 0),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - l, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
        ..lineTo(w, l),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - l)
        ..lineTo(0, h - r)
        ..arcToPoint(
          Offset(r, h),
          radius: const Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(l, h),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - l, h)
        ..lineTo(w - r, h)
        ..arcToPoint(
          Offset(w, h - r),
          radius: const Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(w, h - l),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
