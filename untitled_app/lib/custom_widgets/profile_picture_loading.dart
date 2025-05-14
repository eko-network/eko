import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingProfileImage extends StatelessWidget {
  const LoadingProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('images/default.jpg'),
        Shimmer.fromColors(
            baseColor: const Color.fromARGB(100, 130, 131, 130),
            highlightColor: Colors.white,
            child:
                Opacity(opacity: 0.8, child: Image.asset('images/default.jpg')))
      ],
    );
  }
}
