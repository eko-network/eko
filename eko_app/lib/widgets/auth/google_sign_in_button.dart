import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';

const _gLogoSvg = '''
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
  <path fill="none" d="M0 0h48v48H0z"></path>
</svg>
''';

const _gLogoSize = 20.0;
const _gapAfterLogo = 10.0;

const _lightFill = Color(0xFFFFFFFF);
const _lightStroke = Color(0xFF747775);
const _lightText = Color(0xFF1F1F1F);

const _darkFill = Color(0xFF131314);
const _darkStroke = Color(0xFF8E918F);
const _darkText = Color(0xFFE3E3E3);

const _buttonHeight = 40.0;
const _minButtonWidth = 80.0;

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? _darkFill : _lightFill;
    final stroke = isDark ? _darkStroke : _lightStroke;
    final textColor = isDark ? _darkText : _lightText;

    final label = AppLocalizations.of(context)!.continueWithGoogle;

    return Align(
      alignment: Alignment.center,
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: Semantics(
        button: true,
        label: label,
        child: SizedBox(
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: fill,
              foregroundColor: textColor,
              disabledForegroundColor: textColor.withValues(alpha: 0.38),
              disabledBackgroundColor: fill,
              side: BorderSide(color: stroke, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(_minButtonWidth, _buttonHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(
                        _gLogoSvg,
                        width: _gLogoSize,
                        height: _gLogoSize,
                      ),
                      const SizedBox(width: _gapAfterLogo),
                      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
