import 'dart:io';

import 'package:material_ui/material_ui.dart';

TextStyle emojiTextStyle(TextStyle style) {
  if (Platform.isLinux) {
    return style.copyWith(fontFamilyFallback: const ['NotoEmoji']);
  }
  return style;
}
