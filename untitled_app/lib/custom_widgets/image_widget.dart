import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String text;

  const ImageWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    print(text.split('\n').length);
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Courier', // Use a monospaced font for ASCII art
        fontSize: 5, // Base font size, can be adjusted
      ),
    );

    // FittedBox(
    //   fit: BoxFit.contain,
    //   child: Text(
    //     text,
    //     style: const TextStyle(
    //       fontFamily: 'Courier', // Use a monospaced font for ASCII art
    //       fontSize: 10, // Base font size, can be adjusted
    //     ),
    //   ),
    // );
  }
}
