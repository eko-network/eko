import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InnerCameraPage(
        isDark: Theme.of(context).brightness == Brightness.dark);
  }
}

class InnerCameraPage extends StatefulWidget {
  final bool isDark;
  const InnerCameraPage({super.key, required this.isDark});

  @override
  State<InnerCameraPage> createState() => _InnerCameraPageState();
}

class _InnerCameraPageState extends State<InnerCameraPage> {
  late final AsciiCameraController _ctrl;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (mounted) context.pop(picked);
  }

  void captureFrame() async {
    final picture = await _ctrl.takePicture();
    if (picture != null) {
      if (mounted) context.pop(picture);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl =
        AsciiCameraController(darkMode: widget.isDark, width: 150, height: 150);
    _ctrl.initialize();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder(
                stream: _ctrl.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    //TODO
                    return Text(snapshot.error.toString());
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ImageWidget(
                      ascii: AsciiImage.fromV0String(snapshot.data!),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: Center(
                child: GestureDetector(
              onTap: captureFrame,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 4,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            )),
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
                      onPressed: pickImage,
                      icon: Icon(
                        Icons.perm_media,
                        color: Theme.of(context).colorScheme.onSurface,
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
