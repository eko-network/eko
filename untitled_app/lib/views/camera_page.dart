import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:image/image.dart' as img;
import 'package:untitled_app/widgets/always_oriented.dart';

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
  late final StreamSubscription _accelerometer;
  DeviceOrientation orientation = DeviceOrientation.portraitUp;
  bool cameraAvailable = false;
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (mounted) context.pop(picked);
  }

  void captureFrame() async {
    final currentOrientaion = orientation;
    final picture = await _ctrl.takePicture();
    if (picture != null) {
      if (currentOrientaion != DeviceOrientation.portraitUp) {
        final original = img.decodeImage(await picture.readAsBytes());
        if (original == null) {
          if (mounted) context.pop(picture);
          return;
        }
        num angle = 0;
        if (currentOrientaion == DeviceOrientation.landscapeRight) {
          angle = 90;
        } else if (currentOrientaion == DeviceOrientation.landscapeLeft) {
          angle = 270;
        } else {
          angle = 180;
        }
        final rotated = img.copyRotate(original, angle: angle);
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await img.encodeJpgFile(path, rotated);
        if (mounted) context.pop(XFile(path));
        return;
      }
      if (mounted) context.pop(picture);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl =
        AsciiCameraController(darkMode: widget.isDark, width: 150, height: 150);
    _ctrl.initialize().then((_) => setState(() {
          cameraAvailable = true;
        }));

    _accelerometer =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      final x = event.x;
      final y = event.y;
      if (x.abs() < 5 && y < -7) {
        if (orientation != DeviceOrientation.portraitDown) {
          setState(() {
            orientation = DeviceOrientation.portraitDown;
          });
        }
      } else if (y.abs() < 5 && x > 7) {
        if (orientation != DeviceOrientation.landscapeLeft) {
          setState(() {
            orientation = DeviceOrientation.landscapeLeft;
          });
        }
      } else if (y.abs() < 5 && x < -7) {
        if (orientation != DeviceOrientation.landscapeRight) {
          setState(() {
            orientation = DeviceOrientation.landscapeRight;
          });
        }
      } else if (x.abs() < 5 && y > 7) {
        if (orientation != DeviceOrientation.portraitUp) {
          setState(() {
            orientation = DeviceOrientation.portraitUp;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _accelerometer.cancel();
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
                    return Align(
                      child: ImageWidget(
                          ascii: AsciiImage.fromSimpleString(snapshot.data!)),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          // if (cameraAvailable &&
          // //     !_ctrl.frontCameras.contains(_ctrl.currentCameraIndex))
          // DecoratedBox(
          //     decoration: BoxDecoration(),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: List.generate(_ctrl.cameras.length, (index) {
          //         // final camera = _ctrl.cameras[index];
          //         return InkWell(
          //             onTap: () async {
          //               await _ctrl.switchToCamera(index);
          //               setState(() {});
          //             },
          //             child: Padding(
          //               padding: EdgeInsetsGeometry.symmetric(horizontal: 1),
          //               child: DecoratedBox(
          //                 decoration: BoxDecoration(
          //                     shape: BoxShape.circle,
          //                     color: Theme.of(context).colorScheme.primary),
          //                 child: Padding(
          //                   padding: EdgeInsetsGeometry.all(8),
          //                   child: Text('${index + 1}'),
          //                 ),
          //               ),
          //             ));
          //       }, growable: false),
          //     )),
          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AlwaysOriented(
                    orientation: orientation,
                    child: IconButton(
                      onPressed: pickImage,
                      icon: Icon(
                        size: 35,
                        Icons.perm_media,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                SizedBox(
                  height: 90,
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
                  ),
                ),
                AlwaysOriented(
                  orientation: orientation,
                  child: IconButton(
                    onPressed: () async {
                      if (_ctrl.backCameras
                          .contains(_ctrl.currentCameraIndex)) {
                        await _ctrl.switchToFront();
                      } else {
                        await _ctrl.switchToBack();
                      }
                    },
                    icon: Icon(
                      Icons.autorenew,
                      size: 35,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
