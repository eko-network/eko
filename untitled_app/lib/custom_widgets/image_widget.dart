import 'package:flutter/material.dart';
import 'package:image_to_ascii/image_to_ascii.dart';

class ImageWidget extends StatelessWidget {
  final AsciiImage ascii;

  const ImageWidget({super.key, required this.ascii});

  @override
  Widget build(BuildContext context) {
    return AsciiImageWidget(
      ascii: ascii,
      textStyle: TextStyle(
        fontFamily: 'MartianMono',
        fontWeight: FontWeight.w700,
        fontSize: 40,
        height: 1,
      ),
    );
  }
}
