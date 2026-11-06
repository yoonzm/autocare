import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../kit/async_kit.dart' show AppError;

/// Decode with Flutter's image codec (including orientation), then bound both
/// dimensions. Only the resulting PNG leaves the device; no local path is sent.
Future<Map<String, String>> preparePlatePhoto(String path) async {
  try {
    final file = File(path);
    if (await file.length() > 30 * 1024 * 1024) {
      throw const AppError('图片过大，请选择 30MB 以内的照片');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await file.readAsBytes(),
    );
    try {
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      try {
        final scale = math.min(
          1.0,
          1280 / math.max(descriptor.width, descriptor.height),
        );
        final codec = await descriptor.instantiateCodec(
          targetWidth: math.max(1, (descriptor.width * scale).round()),
          targetHeight: math.max(1, (descriptor.height * scale).round()),
        );
        try {
          final frame = await codec.getNextFrame();
          try {
            final data = await frame.image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (data == null || data.lengthInBytes > 5 * 1024 * 1024) {
              throw const AppError('图片过大，请重新拍摄或选择较小照片');
            }
            return {
              'image_base64': base64Encode(
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
              ),
              'mime_type': 'image/png',
            };
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }
      } finally {
        descriptor.dispose();
      }
    } finally {
      buffer.dispose();
    }
  } on AppError {
    rethrow;
  } catch (_) {
    throw const AppError('无法读取照片，请重新拍摄或选择图片');
  }
}
