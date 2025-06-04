import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Loads an image from the given [path], then crops it to either a 5:4 or 4:5
/// aspect ratio (centered) based on the original image's dimensions.
Future<ui.Image> cropToAspectRatio(String path,
    {double portrait = 4 / 5,
    double landscape = 5 / 4,
    int? desiredWidth,
    double vScale = 1.0}) async {
  final Uint8List bytes = await File(path).readAsBytes();

  final descriptor = await ui.ImageDescriptor.encoded(
      await ui.ImmutableBuffer.fromUint8List(bytes));

  final isPortrait = descriptor.height >= descriptor.width;

  final ui.Codec codec = await descriptor.instantiateCodec(
      targetWidth: isPortrait ? desiredWidth : null,
      targetHeight: !isPortrait && desiredWidth != null
          ? (desiredWidth * landscape).round()
          : null);

  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image originalImage = frameInfo.image;

  final int width = originalImage.width;
  final int height = originalImage.height;
  final double originalAspect = width / height;

  // Decide target aspect ratio
  double targetAspect;
  if (originalAspect > 1.0) {
    targetAspect = landscape;
  } else {
    targetAspect = portrait;
  }

  // Calculate target dimensions
  int targetWidth = width;
  int targetHeight = height;

  if (originalAspect > targetAspect) {
    // Too wide — crop width
    targetWidth = (height * targetAspect).toInt();
  } else {
    // Too tall — crop height
    targetHeight = (width / targetAspect).toInt();
  }

  final int finalHeight = (targetHeight * vScale).round();

  final int offsetX = ((width - targetWidth) / 2).round();
  final int offsetY = ((height - targetHeight) / 2).round();

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  final paint = ui.Paint();

  // Draw cropped part onto new canvas
  canvas.drawImageRect(
    originalImage,
    ui.Rect.fromLTWH(offsetX.toDouble(), offsetY.toDouble(),
        targetWidth.toDouble(), targetHeight.toDouble()),
    ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), finalHeight.toDouble()),
    paint,
  );

  final ui.Picture picture = recorder.endRecording();
  return picture.toImage(targetWidth, finalHeight);
}
