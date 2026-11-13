import 'package:flutter/material.dart';

import '../states/states.dart' show AppSpinner;

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

/// 图片来源：拍照、相册。不支持从文件管理器选。
enum AppImageSource { camera, gallery }

/// 图片上传规则（通用，所有页面共用；压缩与转码由适配层执行，组件只负责展示）。
abstract final class AppImageRules {
  /// 长边压到 2048px 以内。
  static const int maxEdge = 2048;

  /// 压缩后单张不超过 5 MB，否则提示「图片超过 5 MB」，不加入。
  static const int maxBytes = 5 * 1024 * 1024;

  /// 单张上传超时 60 秒。
  static const Duration timeout = Duration(seconds: 60);

  /// 网格默认最多 6 张，每处可调；槽位固定 1 张。
  static const int defaultMax = 6;
  static const List<String> formats = ['jpg', 'png'];
}

/// 待提交、上传中、已传、失败；未选图用 `null` 表示。
enum AppUploadState { pending, uploading, uploaded, failed }

/// 一张图片的展示数据：状态、进度、缩略图。组件不持有业务数据，只显示传入的值。
class AppUploadItem {
  final String id;
  final AppUploadState state;

  /// 0~1，仅上传中有意义；未知进度传 null，显示旋转加载指示。
  final double? progress;
  final ImageProvider? image;
  const AppUploadItem({
    required this.id,
    required this.state,
    this.progress,
    this.image,
  });
}

/// 图片上传：多张图片用 [AppImageUploader.grid]（方块网格），单张证件用 [AppImageUploader.slot]（单格槽位）；
/// 四种状态（未传、上传中、已传、失败）两种形态保持一致。
class AppImageUploader extends StatelessWidget {
  final String? title;
  final String? helper;
  final bool enabled;
  final bool readOnly;
  final String? label;
  final int max;
  final List<AppUploadItem> items;
  final AppUploadItem? item;
  final VoidCallback? onPick;
  final ValueChanged<AppUploadItem>? onRemove;
  final ValueChanged<AppUploadItem>? onRetry;
  final ValueChanged<AppUploadItem>? onCancel;
  final ValueChanged<AppUploadItem>? onPreview;

  /// 相机权限被拒绝时，添加格下方显示灰字提示，点击跳转系统设置。
  final bool permissionDenied;
  final VoidCallback? onOpenSettings;
  final bool _slot;

  const AppImageUploader.grid({
    super.key,
    required String this.title,
    required this.items,
    this.helper,
    this.readOnly = false,
    this.enabled = true,
    this.max = AppImageRules.defaultMax,
    this.onPick,
    this.onRemove,
    this.onRetry,
    this.onCancel,
    this.onPreview,
    this.permissionDenied = false,
    this.onOpenSettings,
  }) : label = null,
       item = null,
       _slot = false;

  const AppImageUploader.slot({
    super.key,
    required String this.label,
    this.enabled = true,
    this.item,
    this.onPick,
    this.onRetry,
    this.onCancel,
  }) : readOnly = false,
       helper = null,
       title = null,
       items = const [],
       max = 1,
       onRemove = null,
       onPreview = null,
       permissionDenied = false,
       onOpenSettings = null,
       _slot = true;

  @override
  Widget build(BuildContext context) =>
      _slot ? _buildSlot(context) : _buildGrid(context);

  Widget _buildGrid(BuildContext context) {
    final t = AppTokens.of(context);
    final canAdd = !readOnly && items.length < max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title!, style: t.small)),
            // 已选 / 上限，上传中和失败的也计入。
            Text(
              '${items.length} / $max',
              style: t.caption.copyWith(fontFeatures: AppTokens.tabular),
            ),
          ],
        ),
        if (helper != null)
          Text(helper!, style: t.caption.copyWith(color: t.inkMute)),
        const SizedBox(height: AppSpacing.s10),
        Wrap(
          spacing: AppSpacing.s10,
          runSpacing: AppSpacing.s10,
          children: [
            for (var i = 0; i < items.length; i++)
              _GridTile(
                item: items[i],
                index: i,
                onRemove: enabled && !readOnly ? onRemove : null,
                onRetry: enabled && !readOnly ? onRetry : null,
                onCancel: enabled && !readOnly ? onCancel : null,
                onPreview: onPreview,
              ),
            if (canAdd)
              _AddTile(label: '添加$title', onPick: enabled ? onPick : null),
          ],
        ),
        if (permissionDenied)
          AppTapTarget(
            onTap: onOpenSettings,
            minWidth: 0,
            minHeight: 32,
            builder: (context, pressed) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s8),
              child: Text(
                '未授权相机，去设置开启',
                style: t.caption.copyWith(color: t.inkMute),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlot(BuildContext context) {
    final t = AppTokens.of(context);
    final it = item;
    final uploading = it?.state == AppUploadState.uploading;
    final failed = it?.state == AppUploadState.failed;
    final uploaded = it?.state == AppUploadState.uploaded;
    VoidCallback? tap;
    String semantic;
    if (it == null) {
      tap = onPick;
      semantic = '添加$label';
    } else if (failed) {
      tap = onRetry == null ? null : () => onRetry!(it);
      semantic = '$label 上传失败，重试';
    } else if (uploading) {
      tap = onCancel == null ? null : () => onCancel!(it);
      semantic = '$label 上传中，点击取消';
    } else {
      // 已上传的格子再点一下，就是重新选择并替换，不先弹删除确认。
      tap = onPick;
      semantic =
          '$label ${it.state == AppUploadState.pending ? '待上传' : '已上传'}，重新选择';
    }
    return AppTapTarget(
      onTap: enabled ? tap : null,
      semanticLabel: semantic,
      minWidth: 0,
      minHeight: 0,
      builder: (context, pressed) => SizedBox(
        height: 110,
        width: double.infinity,
        child: CustomPaint(
          foregroundPainter: it == null
              ? _DashedBorderPainter(t.fillStrong, 16)
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.inset),
            child: Container(
              color: failed ? t.danger.bg : t.inset,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (it?.image != null) _UploadImage(image: it!.image!),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (it == null)
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 24,
                            color: t.inkMute,
                          )
                        else if (uploading && it.progress == null)
                          AppSpinner(size: 20, color: t.heroInk)
                        else if (uploading)
                          Text(
                            '${(it.progress! * 100).round()}%',
                            style: t.body.copyWith(
                              fontFeatures: AppTokens.tabular,
                              color: t.primaryText,
                            ),
                          )
                        else if (failed)
                          Text(
                            '重试',
                            style: t.base.copyWith(color: t.danger.fg),
                          ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          label!,
                          style: t.small.copyWith(
                            color: failed ? t.danger.fg : t.inkSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (uploaded)
                    Positioned(
                      right: AppSpacing.s8,
                      top: AppSpacing.s8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: t.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: t.onPrimary,
                        ),
                      ),
                    ),
                  if (uploading && it!.progress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ProgressBar(it.progress!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar(this.value);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return SizedBox(
      height: 3,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: t.fillStrong)),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1).toDouble(),
            child: ColoredBox(color: t.primary),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final String label;
  final VoidCallback? onPick;
  const _AddTile({required this.label, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return AppTapTarget(
      onTap: onPick,
      semanticLabel: label,
      minWidth: 72,
      minHeight: 72,
      builder: (context, pressed) => SizedBox(
        width: 72,
        height: 72,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(t.fillStrong, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                pressed ? t.pressedOverlay : Colors.transparent,
                t.inset,
              ),
              borderRadius: BorderRadius.circular(AppRadius.inset),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 22, color: t.inkMute),
                Text('添加', style: t.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final AppUploadItem item;
  final int index;
  final ValueChanged<AppUploadItem>? onRemove;
  final ValueChanged<AppUploadItem>? onRetry;
  final ValueChanged<AppUploadItem>? onCancel;
  final ValueChanged<AppUploadItem>? onPreview;
  const _GridTile({
    required this.item,
    required this.index,
    this.onRemove,
    this.onRetry,
    this.onCancel,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final uploading = item.state == AppUploadState.uploading;
    final failed = item.state == AppUploadState.failed;
    VoidCallback? tap;
    String semantic;
    if (uploading) {
      tap = onCancel == null ? null : () => onCancel!(item);
      semantic = '第 ${index + 1} 张，上传中，点击取消';
    } else if (failed) {
      tap = onRetry == null ? null : () => onRetry!(item);
      semantic = '第 ${index + 1} 张，上传失败，重试';
    } else {
      tap = onPreview == null ? null : () => onPreview!(item);
      semantic = '第 ${index + 1} 张，预览';
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AppTapTarget(
              onTap: tap,
              semanticLabel: semantic,
              minWidth: 72,
              minHeight: 72,
              builder: (context, pressed) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.inset),
                child: Container(
                  color: failed ? t.danger.bg : t.fill,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.image != null) _UploadImage(image: item.image!),
                      if (uploading) ...[
                        ColoredBox(color: t.overlay),
                        Center(
                          child: item.progress == null
                              ? AppSpinner(size: 20, color: t.heroInk)
                              : Text(
                                  '${(item.progress! * 100).round()}%',
                                  style: t.small.copyWith(
                                    color: t.heroInk,
                                    fontFeatures: AppTokens.tabular,
                                  ),
                                ),
                        ),
                        if (item.progress != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _ProgressBar(item.progress!),
                          ),
                      ],
                      if (failed)
                        Center(
                          child: Text(
                            '重试',
                            style: t.small.copyWith(color: t.danger.fg),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!uploading && onRemove != null)
            Positioned(
              right: -10,
              top: -10,
              child: AppTapTarget(
                onTap: () => onRemove!(item),
                semanticLabel: '第 ${index + 1} 张，删除',
                builder: (context, pressed) => Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: t.overlay,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 14, color: t.heroInk),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter(this.color, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.75),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// 读取失败不冒充空槽；仍保留外围预览/重试操作。
class _UploadImage extends StatelessWidget {
  final ImageProvider image;
  const _UploadImage({required this.image});
  @override
  Widget build(BuildContext context) => Image(
    image: image,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: AppTokens.of(context).inkMute,
        semanticLabel: '图片加载失败',
      ),
    ),
  );
}
