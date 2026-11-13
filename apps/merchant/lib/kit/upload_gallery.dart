import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';

import 'async_kit.dart';
import 'image_pick.dart';
import '../backend/merchant_api.dart';

class UploadRecord {
  final String id;
  final ImageProvider image;
  const UploadRecord(this.id, this.image);
}

class _Entry {
  final String requestId;
  final Uint8List? bytes;
  UploadRecord? record;
  AppUploadState state;
  _Entry(this.requestId, this.bytes, this.record, this.state);
  AppUploadItem get item => AppUploadItem(
    id: requestId,
    state: state,
    image: bytes == null ? record?.image : MemoryImage(bytes!),
  );
}

Future<void> previewImage(BuildContext context, ImageProvider image) =>
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Stack(
          children: [
            SizedBox(
              height: 420,
              width: double.infinity,
              child: InteractiveViewer(
                child: Image(
                  image: image,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Text('图片加载失败，请关闭后重试')),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: AppIconButton(
                icon: Icons.close,
                semanticLabel: '关闭预览',
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );

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
        final file = await pickSingleImage(context);
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
      final entry = _entry(item);
      final image = entry.bytes != null
          ? MemoryImage(entry.bytes!)
          : (widget.refresh == null
                    ? entry.record!
                    : await widget.refresh!(entry.record!))
                .image;
      if (mounted) await previewImage(context, image);
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
