import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';

Future<Map<String, dynamic>?> scanInventory(BuildContext context) =>
    Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const InventoryScanPage()),
    );

class InventoryScanPage extends StatefulWidget {
  const InventoryScanPage({super.key});
  @override
  State<InventoryScanPage> createState() => _InventoryScanState();
}

class _InventoryScanState extends State<InventoryScanPage>
    with WidgetsBindingObserver {
  final camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool busy = false, manual = false;
  String? code, error;
  bool get supported =>
      kIsWeb ||
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!supported || !camera.value.isInitialized) return;
    if (state == AppLifecycleState.resumed &&
        !busy &&
        !manual &&
        error == null) {
      camera.start();
    } else if (state != AppLifecycleState.resumed) {
      camera.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    camera.dispose();
    super.dispose();
  }

  Future<void> lookup(String value) async {
    if (busy || !mounted) return;
    setState(() {
      busy = true;
      error = null;
      code = value;
    });
    try {
      if (supported && camera.value.isRunning) await camera.stop();
      final result = await Future.wait([
        merchantApi.invoke({'action': 'inventory_scan', 'code': value}),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
      if (mounted) {
        Navigator.pop(
          context,
          Map<String, dynamic>.from((result.first as Map)['item']),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e is AppError ? e.message : '查询失败，请重试');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> enterCode() async {
    if (busy || manual) return;
    manual = true;
    if (supported && camera.value.isRunning) await camera.stop();
    if (!mounted) return;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('手动输入编码'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(hintText: '请输入商品条码 / SKU'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('查询'),
          ),
        ],
      ),
    );
    // Dialog route may retain its text field while animating out.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    manual = false;
    if (!mounted) return;
    if (value != null) {
      await lookup(value);
    } else if (supported && error == null) {
      await camera.start();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff18181b),
    body: SafeArea(
      child: Stack(
        children: [
          if (supported)
            Positioned.fill(
              child: MobileScanner(
                controller: camera,
                onDetect: (capture) {
                  if (busy || manual || error != null) return;
                  final values = capture.barcodes
                      .map((b) => b.rawValue)
                      .whereType<String>()
                      .where((v) => v.trim().isNotEmpty);
                  if (values.isNotEmpty) lookup(values.first);
                },
                errorBuilder: (context, e) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      '无法使用相机，请在系统设置中允许相机权限，或手动输入编码',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        '扫码查询',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supported)
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xff0089ff),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        supported ? '把商品条码放进框内，自动识别' : '当前设备请使用手动输入编码',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (busy)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: AppSpinner(size: 20, color: Colors.white),
                        ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              LoadingButton(
                                label: '重试查询',
                                onPressed: () => lookup(code!),
                              ),
                              if (supported)
                                TextButton(
                                  onPressed: () async {
                                    setState(() => error = null);
                                    await camera.start();
                                  },
                                  child: const Text('重新扫码'),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff27272a),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: busy ? null : enterCode,
                    child: const Text('手动输入编码'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
