import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String text;

  const ImageWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 50),
        child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,

                fontFamily: 'Courier', // Use a monospaced font for ASCII art
                fontSize: 25, // Base font size, can be adjusted
              ),
            )));

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
