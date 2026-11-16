import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../kit/upload_gallery.dart';

class VoucherGallery extends StatelessWidget {
  final List<String> paths;

  /// 路径 → 签名链接，由后端读取记录时一并返回；没有链接的路径不显示。
  final Map<String, String> urls;
  final ValueChanged<List<String>>? onChanged;
  final ValueChanged<bool>? onBusyChanged;
  final int max;
  final String title;
  final String? helper;
  final bool enabled;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) request;
  const VoucherGallery({
    super.key,
    required this.paths,
    required this.request,
    this.urls = const {},
    this.onChanged,
    this.onBusyChanged,
    this.max = 5,
    this.title = '凭证',
    this.helper,
    this.enabled = true,
  });
  UploadRecord _record(String path) => UploadRecord(
    path,
    CachedNetworkImageProvider(urls[path]!, cacheKey: path),
  );

  @override
  Widget build(BuildContext context) => UploadGallery(
    title: title,
    helper: helper,
    max: max,
    enabled: enabled,
    load: () async => [
      for (final p in paths)
        if (urls.containsKey(p)) _record(p),
    ],
    onBusyChanged: onBusyChanged,
    upload: onChanged == null
        ? null
        : (bytes, requestId) async {
            final result = await request({
              'action': 'expense_upload',
              'data': base64Encode(bytes),
            });
            final path = result['item']['path'] as String;
            onChanged!([...paths, path]);
            return UploadRecord(path, MemoryImage(bytes));
          },
    remove: onChanged == null
        ? null
        : (r) async => onChanged!(paths.where((p) => p != r.id).toList()),
  );
}
