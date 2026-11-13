import 'dart:convert';

import 'package:flutter/material.dart';

import '../../kit/upload_gallery.dart';

class VoucherGallery extends StatelessWidget {
  final List<String> paths;
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
    this.onChanged,
    this.onBusyChanged,
    this.max = 5,
    this.title = '凭证',
    this.helper,
    this.enabled = true,
  });
  Future<UploadRecord> _read(String path) async {
    final r = await request({'action': 'expense_voucher', 'path': path});
    return UploadRecord(path, NetworkImage(r['item']['signedUrl'] as String));
  }

  @override
  Widget build(BuildContext context) => UploadGallery(
    title: title,
    helper: helper,
    max: max,
    enabled: enabled,
    load: () => Future.wait(paths.map(_read)),
    refresh: (r) => _read(r.id),
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
