import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';

class EditPicture extends StatefulWidget {
  final XFile picture;
  const EditPicture({super.key, required this.picture});

  @override
  State<EditPicture> createState() => _EditPictureState();
}

class _EditPictureState extends State<EditPicture> {
  AsciiImage? asciiPicture;

  Future<void> convert() async {
    final cropped = await cropToAspectRatio(widget.picture.path,
        desiredWidth: 150, vScale: 0.75);
    final img = await convertImageToAscii(cropped, dark: true);
    setState(() {
      asciiPicture = img;
    });
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Image.file(File(widget.picture.path)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: asciiPicture == null
                  ? const Center(child: CircularProgressIndicator())
                  : AsciiImageWidget(ascii: asciiPicture!),
            ),
          ),
          // Bottom toolbar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (asciiPicture != null)
                      InkWell(
                        onTap: () {
                          context.pop(asciiPicture);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_forward,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
