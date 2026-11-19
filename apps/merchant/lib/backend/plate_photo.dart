import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

import '../kit/async_kit.dart' show AppError;

const _maxUploadBytes = 5 * 1024 * 1024;
const _maxFallbackEdge = 3200;
const _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

/// Preserve the original file when possible. Flutter decodes and orients
/// photos that need conversion, including formats supported by the OS codec.
Future<Map<String, String>> preparePlatePhoto(String path) async {
  try {
    final file = File(path);
    if (await file.length() > 30 * 1024 * 1024) {
      throw const AppError('图片过大，请选择 30MB 以内的照片');
    }
    final source = await file.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(source);
    try {
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      try {
        final mime = _originalMime(source);
        final upload = mime == null ? await _convertToJpeg(descriptor) : source;
        return {
          'image_base64': base64Encode(upload),
          'mime_type': mime ?? 'image/jpeg',
        };
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

String? _originalMime(Uint8List bytes) {
  if (bytes.length > _maxUploadBytes) return null;
  if (bytes.length >= 3 &&
      bytes[0] == 255 &&
      bytes[1] == 216 &&
      bytes[2] == 255) {
    try {
      final exif = img.decodeJpgExif(bytes);
      final orientation = exif?.imageIfd.orientation ?? 1;
      if (orientation == 1 && (exif?.gpsIfd.isEmpty ?? true)) {
        return 'image/jpeg';
      }
    } catch (_) {
      // The platform codec can still recover pixels from damaged metadata.
    }
    return null;
  }
  if (bytes.length >= _pngSignature.length &&
      Iterable<int>.generate(_pngSignature.length)
          .every((i) => bytes[i] == _pngSignature[i]) &&
      !_pngHasMetadata(bytes)) {
    return 'image/png';
  }
  return null;
}

bool _pngHasMetadata(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  for (var offset = _pngSignature.length; offset + 12 <= bytes.length;) {
    final length = data.getUint32(offset);
    final type = data.getUint32(offset + 4);
    offset += 12 + length;
    if (offset > bytes.length) return true;
    switch (type) {
      case 0x65584966: // eXIf: may carry orientation or GPS.
      case 0x69545874: // iTXt
      case 0x74455874: // tEXt
      case 0x7a545874: // zTXt
        return true;
      case 0x49454e44: // IEND
        return false;
    }
  }
  return true;
}

Future<Uint8List> _convertToJpeg(ui.ImageDescriptor descriptor) async {
  final scale = math.min(
    1.0,
    _maxFallbackEdge / math.max(descriptor.width, descriptor.height),
  );
  final codec = await descriptor.instantiateCodec(
    targetWidth: math.max(1, (descriptor.width * scale).round()),
    targetHeight: math.max(1, (descriptor.height * scale).round()),
  );
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final pixels = await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (pixels == null) {
        throw const AppError('无法读取照片，请重新拍摄或选择图片');
      }
      final jpeg = await compute(_encodeJpegWithinLimit, (
        width: image.width,
        height: image.height,
        pixels: pixels,
      ), debugLabel: 'plate-photo-jpeg');
      if (jpeg == null) {
        throw const AppError('图片过大，请重新拍摄或选择较小照片');
      }
      return jpeg;
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

Uint8List? _encodeJpegWithinLimit(
  ({int width, int height, ByteData pixels}) frame,
) {
  final original = img.Image.fromBytes(
    width: frame.width,
    height: frame.height,
    bytes: frame.pixels.buffer,
    bytesOffset: frame.pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  var photo = original;
  var jpeg = img.encodeJpg(photo, quality: 92);
  for (final edge in [2400, 1600]) {
    if (jpeg.length <= _maxUploadBytes) return jpeg;
    if (math.max(photo.width, photo.height) <= edge) continue;
    photo = img.copyResize(
      original,
      width: original.width >= original.height ? edge : null,
      height: original.height > original.width ? edge : null,
      interpolation: img.Interpolation.average,
    );
    jpeg = img.encodeJpg(photo, quality: 92);
  }
  return jpeg.length <= _maxUploadBytes ? jpeg : null;
}
