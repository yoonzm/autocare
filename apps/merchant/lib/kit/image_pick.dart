import 'buttons.dart';
// 图片选择返回路径，预览与保存由页面显式处理。
import 'kit.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

bool _picking = false;

/// 选择并返回图片，由调用页面管理路径；指定来源时直接打开相机或相册。
Future<XFile?> pickSingleImage(
  BuildContext context, {
  ImageSource? source,
}) async {
  if (_picking) return null;
  _picking = true;
  try {
    final src =
        source ??
        await showModalBottomSheet<ImageSource>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const _SourceSheet(),
        );
    if (src == null) return null;
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
      return null;
    }
    if (f == null) return null;
    return f;
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
          AppButton(
            label: '取消',
            kind: AppButtonKind.secondary,
            size: AppButtonSize.large,
            expanded: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// 受控单图槽位：页面提供本地图片、远端地址和事件。
class ImageSlot extends StatelessWidget {
  final String localPath, remoteUrl;
  final VoidCallback onPick, onClear;
  final Widget? badge;
  final Clip clipBehavior;
  final double radius;
  final Widget child;
  const ImageSlot({
    super.key,
    required this.localPath,
    required this.onPick,
    required this.onClear,
    this.remoteUrl = '',
    this.badge,
    this.clipBehavior = Clip.hardEdge,
    required this.child,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onPick,
    child: Stack(
      clipBehavior: clipBehavior,
      children: [
        child,
        // 已保存的头像（来自服务端）；本地新选的图片盖在它上面，保存时才上传。
        if (localPath.isEmpty && remoteUrl.isNotEmpty)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                remoteUrl,
                fit: BoxFit.cover,
                cacheWidth: 400,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        if (localPath.isNotEmpty)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    errorBuilder: (_, _, _) => Container(color: C.chip),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AppIconButton(
                      icon: Icons.close,
                      semanticLabel: '移除图片',
                      onPressed: onClear,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ?badge,
      ],
    ),
  );
}
