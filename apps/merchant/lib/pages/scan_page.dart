import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kit/image_pick.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';

/// 扫描页的四种形态：扫码找会员（车牌 / 会员码）、扫描建档（行驶证 / 车牌）。
enum ScanKind { findPlate, findCode, licenseCard, plateCard }

class ScanPage extends StatelessWidget {
  final ScanKind kind;
  const ScanPage(this.kind, {super.key});

  bool get _find => kind == ScanKind.findPlate || kind == ScanKind.findCode;
  bool get _first => kind == ScanKind.findPlate || kind == ScanKind.licenseCard;

  String get _title => _find ? '扫码找会员' : '扫描建档';
  List<(String, String, String)> get _tabs => _find
      ? const [('车牌', 'car', 'FindScanPlate'), ('会员码', 'scan', 'FindScanCode')]
      : const [('行驶证', 'clipboard', 'ScanLicense'), ('车牌', 'car', 'ScanPlate')];
  (String, String) get _hint => switch (kind) {
    ScanKind.findPlate => ('将车牌对准框内', '自动匹配该车牌对应的会员'),
    ScanKind.findCode => ('将会员码放入框内', '扫描会员小程序「会员码」，或会员卡二维码'),
    ScanKind.licenseCard => ('将行驶证主页放入框内', '自动识别 车牌 · 车型 · 车架号'),
    ScanKind.plateCard => ('将车牌对准框内', '支持蓝牌、绿牌（新能源）、黄牌'),
  };
  String get _result => switch (kind) {
    ScanKind.findPlate => 'FindResult',
    ScanKind.findCode => 'FindResultCode',
    ScanKind.licenseCard => 'ScanResult',
    ScanKind.plateCard => 'ScanPlateResult',
  };
  Size get _frame => switch (kind) {
    ScanKind.findPlate || ScanKind.plateCard => const Size(300, 118),
    ScanKind.findCode => const Size(236, 236),
    ScanKind.licenseCard => const Size(322, 206),
  };

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final frame = _frame;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  Color(0xFF3A3F4A),
                  Color(0xFF1B1D22),
                  Color(0xFF0B0B0D),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            height: 440,
            child: CustomPaint(painter: _ScanLines()),
          ),
          // 取景框外的遮罩
          Center(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: SizedBox(
                width: frame.width,
                height: frame.height,
                child: _FrameContent(kind: kind),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, bottom + 18),
            child: Column(
              children: [
                Row(
                  children: [
                    _round(
                      'close',
                      '关闭',
                      () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: ts(
                          17,
                          w: FontWeight.w600,
                          color: Colors.white,
                          h: 24,
                        ),
                      ),
                    ),
                    _round('trendUp', '打开闪光灯', () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('闪光灯（演示）'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                    }, bolt: true),
                  ],
                ),
                const SizedBox(height: 16),
                _tabBar(context),
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, 0.62),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _hint.$1,
                          textAlign: TextAlign.center,
                          style: ts(
                            15,
                            w: FontWeight.w600,
                            color: Colors.white,
                            h: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hint.$2,
                          textAlign: TextAlign.center,
                          style: ts(13, color: const Color(0xB3FFFFFF), h: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _side(context, 'info', '相册', () async {
                      await hPickImage(context, 'scan_album');
                      if (context.mounted &&
                          imageStore('scan_album').value.isNotEmpty) {
                        openRoute(context, _result);
                      }
                    }),
                    GestureDetector(
                      onTap: () => openRoute(context, _result),
                      child: Semantics(
                        button: true,
                        label: '拍照识别',
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _side(
                      context,
                      'search',
                      _find ? '手动搜索' : '手动输入',
                      () => _find
                          ? Navigator.of(context).maybePop()
                          : openRoute(context, 'VehicleAdd'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _round(
    String icon,
    String label,
    VoidCallback onTap, {
    bool bolt = false,
  }) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0x24FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: bolt
              ? const Icon(Icons.bolt_outlined, size: 20, color: Colors.white)
              : AppIcon(icon, size: 20, color: Colors.white),
        ),
      ),
    ),
  );

  Widget _side(
    BuildContext context,
    String icon,
    String label,
    VoidCallback onTap,
  ) => SizedBox(
    width: 64,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
          Text(label, style: ts(12, color: const Color(0xCCFFFFFF), h: 16)),
        ],
      ),
    ),
  );

  Widget _tabBar(BuildContext context) => Container(
    width: 224,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0x24FFFFFF),
      borderRadius: BorderRadius.circular(21),
    ),
    child: Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: () {
                final on = (i == 0) == _first;
                if (on) return;
                final name = _tabs[i].$3;
                final page = pageFor(name);
                if (page == null) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    settings: RouteSettings(name: name),
                    fullscreenDialog: true,
                    builder: (_) => page,
                  ),
                );
              },
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: (i == 0) == _first ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      _tabs[i].$2,
                      size: 16,
                      color: (i == 0) == _first
                          ? const Color(0xFF18181B)
                          : const Color(0xBFFFFFFF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tabs[i].$1,
                      style: ts(
                        14,
                        w: (i == 0) == _first
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: (i == 0) == _first
                            ? const Color(0xFF18181B)
                            : const Color(0xBFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// 取景框：外侧压暗，内部是识别对象示意，四角金色定位角。
class _FrameContent extends StatelessWidget {
  final ScanKind kind;
  const _FrameContent({required this.kind});

  @override
  Widget build(BuildContext context) {
    Widget inner;
    switch (kind) {
      case ScanKind.findPlate:
      case ScanKind.plateCard:
        inner = Container(
          width: 232,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
            ),
            border: Border.all(color: const Color(0xCCFFFFFF), width: 3),
          ),
          child: Text(
            '沪A·8K29M',
            style: ts(
              28,
              w: FontWeight.w600,
              color: Colors.white,
              h: 34,
              spacing: 2,
            ),
          ),
        );
      case ScanKind.findCode:
        inner = Opacity(
          opacity: 0.9,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(painter: _QrPainter()),
            ),
          ),
        );
      case ScanKind.licenseCard:
        inner = Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _bar(26, 26, round: 13, a: 0.18),
                    const SizedBox(width: 10),
                    _bar(90, 7),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0x8C2F73F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final w in [0.7, 0.84, 0.58, 0.76]) ...[
                  FractionallySizedBox(
                    widthFactor: w,
                    child: _bar(double.infinity, 7, a: 0.22),
                  ),
                  const SizedBox(height: 10),
                ],
                const Spacer(),
                Row(
                  children: [
                    _bar(80, 7, a: 0.22),
                    const SizedBox(width: 10),
                    _bar(60, 7, a: 0.22),
                  ],
                ),
              ],
            ),
          ),
        );
    }
    return CustomPaint(
      foregroundPainter: const _Corners(),
      painter: const _Dim(),
      child: Center(child: inner),
    );
  }

  Widget _bar(double w, double h, {double? round, double a = 0.3}) => Container(
    width: w == double.infinity ? null : w,
    height: h,
    decoration: BoxDecoration(
      color: Color.fromRGBO(255, 255, 255, a),
      borderRadius: BorderRadius.circular(round ?? 4),
    ),
  );
}

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

class _ScanLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x06FFFFFF);
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 会员码示意（伪二维码）。
class _QrPainter extends CustomPainter {
  const _QrPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const n = 21;
    final c = size.width / n;
    final p = Paint()..color = const Color(0xFF18181B);
    final rnd = math.Random(7);
    bool finder(int x, int y) =>
        (x < 8 && y < 8) || (x > n - 9 && y < 8) || (x < 8 && y > n - 9);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (!finder(x, y) && rnd.nextDouble() > 0.52) {
          canvas.drawRect(Rect.fromLTWH(x * c, y * c, c, c), p);
        }
      }
    }
    void eye(int ox, int oy) {
      canvas.drawRect(Rect.fromLTWH(ox * c, oy * c, 7 * c, 7 * c), p);
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * c, (oy + 1) * c, 5 * c, 5 * c),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 2) * c, (oy + 2) * c, 3 * c, 3 * c),
        p,
      );
    }

    eye(0, 0);
    eye(n - 7, 0);
    eye(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
