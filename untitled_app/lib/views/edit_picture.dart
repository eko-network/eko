import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';

class EditPicture extends StatefulWidget {
  final XFile picture;
  const EditPicture({super.key, required this.picture});

  @override
  State<EditPicture> createState() => _EditPictureState();
}

class _EditPictureState extends State<EditPicture> {
  AsciiImage? asciiPicture;
  bool isDark = true;
  bool isColor = false;
  int density = 150;
  bool densityControllVisible = false;
  bool downloading = false;
  GlobalKey imageKey = GlobalKey();
  bool isLoading = false;

  Future<void> convert() async {
    setState(() {
      isLoading = true;
    });
    final cropped = await cropToAspectRatio(widget.picture.path,
        desiredWidth: density, vScale: 0.75);
    final img =
        await convertImageToAscii(cropped, dark: isDark, color: isColor);
    setState(() {
      asciiPicture = img;
      isLoading = false;
    });
  }

  void toggleDarkMode() {
    setState(() {
      isDark = !isDark;
    });
    convert();
  }

  void toggleColor() {
    setState(() {
      isColor = !isColor;
    });
    convert();
  }

  void changeDensity(int newDensity) {
    setState(() {
      density = newDensity;
    });
    convert();
  }

  double mapDensityToSlider(int densityValue) {
    // Linear mapping from [10,200] to [0,100]
    return ((densityValue - 10) / 190) * 100;
  }

  int mapSliderToDensity(double sliderValue) {
    // Linear mapping from [0,100] to [10,200]
    return (sliderValue / 100 * 190 + 10).round();
  }

  void copyPressed() {
    if (asciiPicture != null) {
      Clipboard.setData(ClipboardData(text: asciiPicture!.toDisplayString()));
    }
  }

  void downloadPressed() async {
    if (downloading) return;
    downloading = true;

    RenderRepaintBoundary boundary =
        imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Create a temporary file
    final Directory tempDir = await getTemporaryDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String tempPath = '${tempDir.path}/$timestamp.png';

    // Save to temp file
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(pngBytes);

    // Save to gallery
    await GallerySaver.saveImage(tempPath, toDcim: true)
        .then((_) => tempFile.delete());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to gallery'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    downloading = false;
  }

  @override
  void initState() {
    convert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: copyPressed,
                  icon: Icon(
                    Icons.copy,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: downloadPressed,
                  icon: Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    if (asciiPicture != null) context.pop(asciiPicture);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_forward,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: asciiPicture == null
                  ? const Center(child: CircularProgressIndicator())
                  : RepaintBoundary(
                      key: imageKey,
                      child: Stack(
                        children: [
                          Align(
                            child: ImageWidget(ascii: asciiPicture!),
                          ),
                          if (isLoading)
                            SizedBox.expand(
                              child: BackdropFilter(
                                filter:
                                    ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: densityControllVisible ? 60 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: mapDensityToSlider(density),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label:
                                mapDensityToSlider(density).toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                density = mapSliderToDensity(value);
                              });
                            },
                            onChangeEnd: (value) {
                              changeDensity(mapSliderToDensity(value));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // toolbar
          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: toggleDarkMode,
                  icon: Icon(
                    size: 35,
                    (isDark) ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: toggleColor,
                  icon: Icon(
                    size: 35,
                    isColor ? Icons.palette : Icons.filter_b_and_w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      densityControllVisible = !densityControllVisible;
                    });
                  },
                  icon: Icon(
                    size: 35,
                    Icons.tune,
                    color: densityControllVisible
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
