import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageWidget extends StatelessWidget {
  final String text;

  const ImageWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Text(
          text,
          style: GoogleFonts.martianMono(
            textStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 25,
                height: 1.0),
          ),
          softWrap: false,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }
}