import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/plate_photo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _PhotoApi extends MerchantApi {
  Map<String, dynamic>? sent;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    String? requestId,
  }) async {
    sent = body;
    return {'matched': false, 'plate': '京A12345'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a 2400px PNG reaches merchant-v1 byte for byte', () async {
    final directory = await Directory.systemTemp.createTemp(
      'autocare-plate-photo-',
    );
    try {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
          .drawPaint(ui.Paint()..color = const ui.Color(0xff224466));
      final picture = recorder.endRecording();
      final image = await picture.toImage(2400, 1200);
      final source = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('${directory.path}/camera.png');
      final original = source!.buffer.asUint8List(
        source.offsetInBytes,
        source.lengthInBytes,
      );
      await file.writeAsBytes(original);
      picture.dispose();
      image.dispose();
      final api = _PhotoApi();
      final result = await api.recognizePlate(file.path);
      expect(result['plate'], '京A12345');
      expect(api.sent!['action'], 'recognize_plate');
      expect(api.sent!['kind'], 'members');
      expect(api.sent!['mime_type'], 'image/png');
      expect(api.sent!.containsKey('image_path'), isFalse);
      final bytes = base64Decode(api.sent!['image_base64'] as String);
      expect(bytes, original);
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('an upright JPEG retains its original bytes and MIME type', () async {
    final directory = await Directory.systemTemp.createTemp('plate-jpeg-');
    addTearDown(() => directory.delete(recursive: true));
    final original = img.encodeJpg(img.Image(width: 1800, height: 900));
    final file = await File('${directory.path}/album.jpg')
        .writeAsBytes(original);
    final prepared = await preparePlatePhoto(file.path);

    expect(prepared['mime_type'], 'image/jpeg');
    expect(base64Decode(prepared['image_base64']!), original);
  });

  test('JPEG orientation is applied to pixels before upload', () async {
    final directory = await Directory.systemTemp.createTemp('plate-rotated-');
    addTearDown(() => directory.delete(recursive: true));
    final photo = img.Image(width: 80, height: 40);
    img.fillRect(
      photo,
      x1: 0,
      y1: 0,
      x2: 39,
      y2: 39,
      color: img.ColorRgb8(255, 0, 0),
    );
    img.fillRect(
      photo,
      x1: 40,
      y1: 0,
      x2: 79,
      y2: 39,
      color: img.ColorRgb8(0, 0, 255),
    );
    // Use an unrotated JPEG payload with an explicit EXIF rotation.
    final original = img.injectJpgExif(
      img.encodeJpg(photo),
      img.ExifData()..imageIfd.orientation = 6,
    )!;
    final file = await File('${directory.path}/rotated.jpg')
        .writeAsBytes(original);
    final prepared = await preparePlatePhoto(file.path);
    final jpeg = base64Decode(prepared['image_base64']!);
    final decoded = img.decodeJpg(jpeg)!;

    expect(prepared['mime_type'], 'image/jpeg');
    expect(img.decodeJpgExif(jpeg)?.imageIfd.orientation, isNull);
    expect((decoded.width, decoded.height), (40, 80));
    expect(decoded.getPixel(20, 10).r, greaterThan(200));
    expect(decoded.getPixel(20, 70).b, greaterThan(200));
  });

  test(
    'a PNG over the upload limit keeps its dimensions when JPEG fits',
    () async {
      final directory = await Directory.systemTemp.createTemp('plate-large-');
      addTearDown(() => directory.delete(recursive: true));
      final original = img.encodePng(
        img.Image(width: 2500, height: 1000),
        level: 0,
      );
      expect(original.length, greaterThan(5 * 1024 * 1024));
      final file = await File('${directory.path}/large.png')
          .writeAsBytes(original);
      final prepared = await preparePlatePhoto(file.path);
      final jpeg = base64Decode(prepared['image_base64']!);
      final decoded = img.decodeJpg(jpeg)!;

      expect(prepared['mime_type'], 'image/jpeg');
      expect(jpeg.length, lessThanOrEqualTo(5 * 1024 * 1024));
      expect((decoded.width, decoded.height), (2500, 1000));
    },
  );

  test('a supported source format outside JPEG and PNG is converted', () async {
    final directory = await Directory.systemTemp.createTemp('plate-bmp-');
    addTearDown(() => directory.delete(recursive: true));
    final original = img.encodeBmp(img.Image(width: 80, height: 40));
    final file = await File('${directory.path}/source.bmp')
        .writeAsBytes(original);
    final prepared = await preparePlatePhoto(file.path);
    final decoded = img.decodeJpg(base64Decode(prepared['image_base64']!))!;

    expect(prepared['mime_type'], 'image/jpeg');
    expect((decoded.width, decoded.height), (80, 40));
  });

  test(
    'an upright JPEG with GPS data does not send the original metadata',
    () async {
      final directory = await Directory.systemTemp.createTemp('plate-gps-');
      addTearDown(() => directory.delete(recursive: true));
      final exif = img.ExifData()
        ..imageIfd.orientation = 1
        ..gpsIfd[1] = img.IfdValueAscii('N');
      final original = img.injectJpgExif(
        img.encodeJpg(img.Image(width: 80, height: 40)),
        exif,
      )!;
      expect(img.decodeJpgExif(original)?.gpsIfd.isEmpty, isFalse);
      final file = await File('${directory.path}/gps.jpg')
          .writeAsBytes(original);
      final prepared = await preparePlatePhoto(file.path);
      final jpeg = base64Decode(prepared['image_base64']!);

      expect(prepared['mime_type'], 'image/jpeg');
      expect(img.decodeJpgExif(jpeg)?.gpsIfd.isEmpty ?? true, isTrue);
    },
  );

  test('missing and non-image files fail before recognition', () async {
    final directory = await Directory.systemTemp.createTemp(
      'autocare-plate-invalid-',
    );
    try {
      await expectLater(
        preparePlatePhoto('${directory.path}/missing.jpg'),
        throwsA(isA<AppError>()),
      );
      final file = await File('${directory.path}/invalid.jpg')
          .writeAsString('not a photo');
      final api = _PhotoApi();
      await expectLater(
        api.recognizePlate(file.path),
        throwsA(isA<AppError>()),
      );
      expect(api.sent, isNull);
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
