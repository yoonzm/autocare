// 图片选择：拍照 / 从相册选择，选完在原处回显（不真正上传）。
import 'kit.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

/// 按 key 保存已选图片路径（仅内存，mock）。
final Map<String, ValueNotifier<List<String>>> _imgStore = {};

ValueNotifier<List<String>> imageStore(String key) =>
    _imgStore.putIfAbsent(key, () => ValueNotifier<List<String>>([]));

bool _picking = false;

/// 不弹来源选择，直接调用系统相机 / 相册，选中后写入 [key]，返回是否拿到了图片。
Future<bool> hCaptureImage(
  BuildContext context,
  String key, {
  required bool camera,
}) async {
  if (_picking) return false;
  _picking = true;
  try {
    final f = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (f == null) return false;
    imageStore(key).value = [f.path];
    return true;
  } catch (_) {
    if (context.mounted) {
      hToastOn(
        ScaffoldMessenger.of(context),
        camera ? '无法打开相机，请在系统设置中允许访问' : '无法访问相册，请在系统设置中允许访问',
      );
    }
    return false;
  } finally {
    _picking = false;
  }
}

/// 弹出“拍照 / 从相册选择”，选中后写入 [key]。
/// [replaceAt] 不为空时替换该位置，否则追加（受 [max] 限制）。
Future<void> hPickImage(
  BuildContext context,
  String key, {
  int? replaceAt,
  int max = 1,
}) async {
  if (_picking) return;
  _picking = true;
  try {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SourceSheet(),
    );
    if (src == null) return;
    final XFile? f;
    try {
      f = await ImagePicker().pickImage(
        source: src,
        maxWidth: 1600,
        imageQuality: 85,
      );
    } catch (_) {
      if (context.mounted) {
        hToastOn(
          ScaffoldMessenger.of(context),
          src == ImageSource.camera
              ? '无法打开相机，请在系统设置中允许访问'
              : '无法访问相册，请在系统设置中允许访问',
        );
      }
      return;
    }
    if (f == null) return;
    final n = imageStore(key);
    final list = [...n.value];
    if (replaceAt != null && replaceAt < list.length) {
      list[replaceAt] = f.path;
    } else if (max <= 1) {
      list
        ..clear()
        ..add(f.path);
    } else if (list.length < max) {
      list.add(f.path);
    }
    n.value = list;
  } finally {
    _picking = false;
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  Widget _row(BuildContext ctx, IconData icon, String text, ImageSource s) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(ctx, s),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: C.inset,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: C.ink),
              const SizedBox(width: 12),
              Text(
                text,
                style: ts(15, w: FontWeight.w500, color: C.ink),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom + 16),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: C.stroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '添加图片',
            style: ts(18, w: FontWeight.w600, color: C.ink, h: 26),
          ),
          const SizedBox(height: 12),
          _row(context, Icons.photo_camera_outlined, '拍照', ImageSource.camera),
          const SizedBox(height: 10),
          _row(
            context,
            Icons.photo_library_outlined,
            '从相册选择',
            ImageSource.gallery,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: C.chip,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '取消',
                style: ts(15, w: FontWeight.w500, color: C.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _thumb(
  String path,
  double size,
  double radius,
  VoidCallback onClear,
  VoidCallback onTap,
) => GestureDetector(
  onTap: onTap,
  child: SizedBox(
    width: size,
    height: size,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            cacheWidth: 400,
            errorBuilder: (_, _, _) => Container(color: C.chip),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0x99000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  ),
);

/// 单张图片槽位：没选时显示原有占位，选了之后盖上图片；点击重新选择。
class HImageSlot extends StatelessWidget {
  final String imgKey;
  final double radius;
  final Widget child;
  const HImageSlot({
    super.key,
    required this.imgKey,
    required this.child,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<String>>(
    valueListenable: imageStore(imgKey),
    builder: (context, list, _) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => hPickImage(context, imgKey),
      child: Stack(
        children: [
          child,
          if (list.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(list.first),
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      errorBuilder: (_, _, _) => Container(color: C.chip),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => imageStore(imgKey).value = [],
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0x99000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// “+”添加按钮：已选图片以缩略图排在按钮前面，达到上限后按钮消失。
class HImageAdd extends StatelessWidget {
  final String imgKey;
  final double size;
  final double radius;
  final int max;
  final Widget child;
  const HImageAdd({
    super.key,
    required this.imgKey,
    required this.child,
    this.size = 72,
    this.radius = 16,
    this.max = 9,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<String>>(
    valueListenable: imageStore(imgKey),
    builder: (context, list, _) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < list.length; i++)
          _thumb(
            list[i],
            size,
            radius,
            () => imageStore(imgKey).value = [...list]..removeAt(i),
            () => hPickImage(context, imgKey, replaceAt: i, max: max),
          ),
        if (list.length < max)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => hPickImage(context, imgKey, max: max),
            child: child,
          ),
      ],
    ),
  );
}
