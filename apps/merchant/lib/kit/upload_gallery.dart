import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';

import 'async_kit.dart';
import 'image_pick.dart';
import '../backend/merchant_api.dart';

class UploadRecord {
  final String id;
  final ImageProvider image;
  const UploadRecord(this.id, this.image);
}

/// 网格里只解码小图，省内存、滚动更顺。
ImageProvider? _thumb(ImageProvider? image) => image == null
    ? null
    : ResizeImage(image, width: 300, allowUpscaling: false);

class _Entry {
  final String requestId;
  final Uint8List? bytes;
  UploadRecord? record;
  AppUploadState state;
  _Entry(this.requestId, this.bytes, this.record, this.state);
  AppUploadItem get item => AppUploadItem(
    id: requestId,
    state: state,
    image: _thumb(bytes == null ? record?.image : MemoryImage(bytes!)),
  );
}

/// 全屏预览：双指缩放、双击放大、左右滑动切换；[images] 为空时不打开。
Future<void> previewImages(
  BuildContext context,
  List<ImageProvider> images, {
  int index = 0,
}) {
  if (images.isEmpty) return Future.value();
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => ImageViewerPage(images: images, index: index),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

Future<void> previewImage(BuildContext context, ImageProvider image) =>
    previewImages(context, [image]);

class ImageViewerPage extends StatefulWidget {
  final List<ImageProvider> images;
  final int index;
  const ImageViewerPage({super.key, required this.images, this.index = 0});
  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _page = PageController(initialPage: widget.index);
  late int _current = widget.index;
  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _page,
            itemCount: widget.images.length,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (i) => setState(() => _current = i),
            builder: (_, i) => PhotoViewGalleryPageOptions(
              imageProvider: widget.images[i],
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
              heroAttributes: null,
              errorBuilder: (_, _, _) => const Center(
                child: Text(
                  '图片加载失败，请关闭后重试',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            loadingBuilder: (_, event) => const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: top + 8,
            child: Semantics(
              button: true,
              label: '关闭预览',
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              top: top + 16,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    '${_current + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// UI适配层只管理上传展示；权限、存储路径与保存协议由调用者提供。
class UploadGallery extends StatefulWidget {
  final String title;
  final String? helper;
  final int max;
  final Future<List<UploadRecord>> Function() load;
  final Future<UploadRecord> Function(Uint8List bytes, String requestId)?
  upload;
  final Future<void> Function(UploadRecord record)? remove;
  final Future<void> Function(String requestId)? discard;
  final Future<Uint8List?> Function()? pickBytes;
  final Future<UploadRecord> Function(UploadRecord record)? refresh;
  final ValueChanged<bool>? onBusyChanged;
  final bool enabled;
  const UploadGallery({
    super.key,
    required this.title,
    required this.max,
    required this.load,
    this.upload,
    this.remove,
    this.discard,
    this.pickBytes,
    this.refresh,
    this.onBusyChanged,
    this.enabled = true,
    this.helper,
  });
  @override
  State<UploadGallery> createState() => _UploadGalleryState();
}

class _UploadGalleryState extends State<UploadGallery> {
  final _entries = <_Entry>[];
  final _key = GlobalKey<AsyncViewState<List<UploadRecord>>>();
  bool _busy = false;
  Future<List<UploadRecord>> _load() async {
    final records = await widget.load();
    if (mounted) {
      _entries
        ..clear()
        ..addAll(
          records.map((r) => _Entry(r.id, null, r, AppUploadState.uploaded)),
        );
    }
    return records;
  }

  void _busyChanged(bool value) {
    if (!mounted) return;
    setState(() => _busy = value);
    widget.onBusyChanged?.call(value);
  }

  Future<void> _pick() async {
    if (_busy || !widget.enabled || _entries.length >= widget.max) return;
    _busyChanged(true);
    try {
      final Uint8List? bytes;
      if (widget.pickBytes != null) {
        bytes = await widget.pickBytes!();
      } else {
        final file = await pickSingleImage(
          context,
          maxWidth: 1280,
          imageQuality: 80,
        );
        bytes = await file?.readAsBytes();
      }
      if (bytes == null || !mounted) return;
      if (bytes.length > AppImageRules.maxBytes) {
        throw const AppError('图片超过5MB，请选择更小的图片');
      }
      if (!mounted) return;
      final entry = _Entry(
        MerchantApi.newRequestId(),
        bytes,
        null,
        AppUploadState.uploading,
      );
      setState(() => _entries.add(entry));
      await _send(entry);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      _busyChanged(false);
    }
  }

  Future<void> _send(_Entry entry) async {
    try {
      final record = await widget.upload!(entry.bytes!, entry.requestId);
      if (!mounted) return;
      setState(() {
        entry.record = record;
        entry.state = AppUploadState.uploaded;
      });
    } catch (e) {
      if (mounted) {
        setState(() => entry.state = AppUploadState.failed);
        AppToast.error(context, e);
      }
    }
  }

  _Entry _entry(AppUploadItem item) =>
      _entries.firstWhere((e) => e.requestId == item.id);
  Future<void> _retry(AppUploadItem item) async {
    if (_busy || !widget.enabled) return;
    final e = _entry(item);
    _busyChanged(true);
    setState(() => e.state = AppUploadState.uploading);
    try {
      await _send(e);
    } finally {
      _busyChanged(false);
    }
  }

  Future<void> _remove(AppUploadItem item) async {
    if (_busy || !widget.enabled) return;
    final entry = _entry(item);
    _busyChanged(true);
    try {
      if (entry.record != null) {
        await widget.remove!(entry.record!);
      } else {
        await widget.discard?.call(entry.requestId);
      }
      if (mounted) setState(() => _entries.remove(entry));
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      _busyChanged(false);
    }
  }

  Future<void> _preview(AppUploadItem item) async {
    try {
      final tapped = _entry(item);
      final shown = _entries
          .where((e) => e.bytes != null || e.record != null)
          .toList();
      final images = await Future.wait(
        shown.map((e) async {
          if (e.bytes != null) return MemoryImage(e.bytes!) as ImageProvider;
          if (widget.refresh == null) return e.record!.image;
          return (await widget.refresh!(e.record!)).image;
        }),
      );
      if (mounted) {
        await previewImages(context, images, index: shown.indexOf(tapped));
      }
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => AsyncView<List<UploadRecord>>(
    key: _key,
    shrinkWrap: true,
    inlineError: true,
    pullToRefresh: false,
    skeletonScrollable: false,
    load: _load,
    isEmpty: (_) => false,
    skeleton: const SizedBox(
      height: 100,
      child: Row(
        children: [
          AppSkeleton(width: 72, height: 72, radius: 14),
          SizedBox(width: 10),
          AppSkeleton(width: 72, height: 72, radius: 14),
          SizedBox(width: 10),
          AppSkeleton(width: 72, height: 72, radius: 14),
        ],
      ),
    ),
    empty: (_) => const SizedBox(),
    builder: (_, _) => AppImageUploader.grid(
      title: widget.title,
      helper: widget.helper,
      max: widget.max,
      items: _entries.map((e) => e.item).toList(),
      enabled: widget.enabled && !_busy,
      readOnly: widget.upload == null,
      onPick: widget.upload == null ? null : _pick,
      onRetry: widget.upload == null ? null : _retry,
      onRemove: widget.remove == null ? null : _remove,
      onPreview: _preview,
    ),
  );
}
