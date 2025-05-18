import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled_app/utilities/logo_service.dart';

String colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).substring(2)}';
}

class Bell extends StatelessWidget {
  final Color? color;
  final BoxFit fit;
  const Bell({super.key, this.color, this.fit = BoxFit.contain});
  @override
  Widget build(BuildContext context) {
    final strColor =
        colorToHex(color ?? Theme.of(context).colorScheme.onSurface);
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="$strColor" stroke="$strColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-bell-icon lucide-bell"><path d="M10.268 21a2 2 0 0 0 3.464 0"/><path d="M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"/></svg>',
      fit: fit, // Makes the SVG maintain aspect ratio
    );
  }
}

class Eko extends ConsumerWidget {
  final Color? color;
  final BoxFit fit;
  const Eko({
    super.key,
    this.color,
    this.fit = BoxFit.contain,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SvgPicture.string(
      LogoService.instance,
      fit: fit,
      colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    );
  }
}
