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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageLocal =
        await picker.pickImage(source: ImageSource.gallery);

    if (imageLocal == null) return;

    setState(() {
      selectedImage = imageLocal;
      isLoading = true;
    });

    // Convert to ASCII
    //FIXME update ascii_to_image first
    final ascii = await ImageToAscii().convertImageToAscii(imageLocal.path);

    setState(() {
      asciiImage = ascii;
      isLoading = false;
    });
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
        actions: [
          if (asciiImage != null)
            TextButton(
              onPressed: () {
                context.pop(asciiImage);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.done,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else if (asciiImage != null)
              ImageWidget(text: asciiImage!)
            else
              Text(
                AppLocalizations.of(context)!.noImageSelected,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            if (asciiImage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(AppLocalizations.of(context)!.changeImage),
                    ),
                    // You can add more editing controls here in the future
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(AppLocalizations.of(context)!.pickImage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
