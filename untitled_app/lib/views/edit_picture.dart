import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:untitled_app/utilities/ascii_image_cropper.dart';

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
    final img = await convertImageToAsciiFromImage(cropped, dark: true);
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
          onPressed: () => context.pop(asciiPicture),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: asciiPicture == null
                  ? const Center(child: CircularProgressIndicator())
                  : AsciiImageWidget(ascii: asciiPicture!.data),
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
                      // IconButton(
                      //     onPressed: pickImage,
                      //     icon: Icon(
                      //       Icons.perm_media,
                      //       color: Theme.of(context).colorScheme.onSurface,
                      //     )),
                      // if (asciiImage != null) ...[
                      //   IconButton(
                      //       onPressed: _toggleDarkMode,
                      //       icon: Icon(
                      //         (isDarkMode) ? Icons.dark_mode : Icons.light_mode,
                      //         color: Theme.of(context).colorScheme.onSurface,
                      //       )),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_forward,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                          ),
                        ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_to_ascii/image_to_ascii.dart';
// import 'package:go_router/go_router.dart';
// import 'package:untitled_app/custom_widgets/image_widget.dart';
// import 'package:untitled_app/utilities/ascii_image_cropper.dart';
//
// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});
//
//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }
//
// class _CameraPageState extends State<CameraPage> {
//   late final AsciiCameraController _ctrl;
//   String frame = '';
//   XFile? selectedImage;
//   String? asciiImage;
//   bool isLoading = true;
//   bool isDarkMode = true;
//
//   void clearAll() => setState(() {
//         asciiImage = null;
//         selectedImage = null;
//       });
//
//   Future<void> pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     setState(() {
//       selectedImage = picked;
//     });
//
//     await convertImage();
//   }
//
//   Future<void> convertImage() async {
//     if (selectedImage == null) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     final ascii = await convertImageToAscii(selectedImage!.path,
//         darkMode: isDarkMode, color: false);
//
//     setState(() {
//       asciiImage = ascii;
//       isLoading = false;
//     });
//   }
//
//   void _toggleDarkMode() {
//     setState(() {
//       isDarkMode = !isDarkMode;
//     });
//     convertImage();
//   }
//
//   void captureFrame() {
//     setState(() {
//       asciiImage = frame;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // TODO: set dark mode based on theme provider
//     _ctrl = AsciiCameraController(darkMode: true);
//     _ctrl.initialize().then((_) {
//       _ctrl.stream.listen((ascii) => setState(() {
//             frame = ascii;
//             isLoading = false;
//           }));
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => context.pop(),
//         ),
//         actions: [
//           if (asciiImage != null) ...[
//             IconButton(
//               onPressed: clearAll,
//               icon: Icon(
//                 Icons.delete,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : asciiImage != null
//                       ? ImageWidget(ascii: asciiImage!)
//                       : ImageWidget(ascii: frame),
//             ),
//           ),
//           SizedBox(
//             height: 90,
//             child: Center(
//               child: asciiImage == null
//                   ? GestureDetector(
//                       onTap: captureFrame,
//                       child: Container(
//                         height: 70,
//                         width: 70,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Theme.of(context).colorScheme.onSurface,
//                             width: 4,
//                           ),
//                         ),
//                         child: Container(
//                           margin: const EdgeInsets.all(3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Theme.of(context).colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                     )
//                   : const SizedBox(),
//             ),
//           ),
//
//           // Bottom toolbar
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                         onPressed: pickImage,
//                         icon: Icon(
//                           Icons.perm_media,
//                           color: Theme.of(context).colorScheme.onSurface,
//                         )),
//                     if (asciiImage != null) ...[
//                       IconButton(
//                           onPressed: _toggleDarkMode,
//                           icon: Icon(
//                             (isDarkMode) ? Icons.dark_mode : Icons.light_mode,
//                             color: Theme.of(context).colorScheme.onSurface,
//                           )),
//                       InkWell(
//                         onTap: () {
//                           context.pop(asciiImage);
//                         },
//                         borderRadius: BorderRadius.circular(12),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 12),
//                           decoration: BoxDecoration(
//                             color:
//                                 Theme.of(context).colorScheme.primaryContainer,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(Icons.arrow_forward,
//                               size: 20,
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .onPrimaryContainer),
//                         ),
//                       ),
//                     ]
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
