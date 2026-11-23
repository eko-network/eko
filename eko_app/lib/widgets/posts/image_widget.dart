import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';

class ImageWidget extends StatelessWidget {
  final AsciiImage ascii;
  final VoidCallback? onTap;

  const ImageWidget({super.key, required this.ascii, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFullScreen(context),
      child: AsciiImageWidget(
        ascii: ascii,
        textStyle: TextStyle(
          fontFamily: 'MartianMono',
          fontWeight: FontWeight.w700,
          fontSize: 40,
          height: 1,
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => context.pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: AsciiImageWidget(
                ascii: ascii,
                textStyle: TextStyle(
                  fontFamily: 'MartianMono',
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
