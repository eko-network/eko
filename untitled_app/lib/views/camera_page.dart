import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  XFile? selectedImage;
  String? asciiImage;
  bool isLoading = false;
  bool isDarkMode = true;

  Future<void> _convertImageToAscii() async {
    if (selectedImage == null) return;

    setState(() {
      isLoading = true;
    });

    final ascii = await ImageToAscii()
        .convertImageToAscii(selectedImage!.path, darkMode: isDarkMode);

    setState(() {
      asciiImage = ascii;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageLocal =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageLocal == null) return;

    setState(() {
      selectedImage = imageLocal;
    });

    await _convertImageToAscii();
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    _convertImageToAscii();
  }

  @override
  void initState() {
    super.initState();
    _pickImage();
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
          // Main content area (image or placeholder)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : asciiImage != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ImageWidget(text: asciiImage!),
                      )
                    : Center(
                        child: Text(
                          AppLocalizations.of(context)!.noImageSelected,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
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
                    IconButton(
                        onPressed: _pickImage,
                        icon: Icon(
                          Icons.perm_media,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    if (asciiImage != null) ...[
                      IconButton(
                          onPressed: _toggleDarkMode,
                          icon: Icon(
                            (isDarkMode) ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                      InkWell(
                        onTap: () {
                          context.pop(asciiImage);
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
                    ]
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
