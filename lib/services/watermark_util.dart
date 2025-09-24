import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class WatermarkUtil {
  static Future<Uint8List> applyWatermark({
    required Uint8List imageBytes,
    String watermarkText = 'AI Hair Styler',
  }) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: watermarkText,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: image.width.toDouble());

    final padding = 12.0;
    final offset = Offset(
      image.width - textPainter.width - padding,
      image.height - textPainter.height - padding,
    );
    // Draw semi-transparent bg behind text
    final bgRect = Rect.fromLTWH(
      offset.dx - 8,
      offset.dy - 4,
      textPainter.width + 16,
      textPainter.height + 8,
    );
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      bgPaint,
    );

    textPainter.paint(canvas, offset);
    final picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(image.width, image.height);
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}


