import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/plate_photo.dart';
import 'package:flutter_test/flutter_test.dart';

class _PhotoApi extends MerchantApi {
  Map<String, dynamic>? sent;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    sent = body;
    return {'matched': false, 'plate': '京A12345'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('camera/album image is resized proportionally and real PNG bytes are sent to merchant-v1', () async {
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
      await file.writeAsBytes(source!.buffer.asUint8List());
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
      final codec = await ui.instantiateImageCodec(bytes);
      final decoded = (await codec.getNextFrame()).image;
      expect(decoded.width, 1280);
      expect(decoded.height, 640);
      decoded.dispose();
      codec.dispose();
    } finally {
      await directory.delete(recursive: true);
    }
  });

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
