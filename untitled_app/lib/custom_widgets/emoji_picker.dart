import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:go_router/go_router.dart';

class EmojiSelector extends StatelessWidget {
  const EmojiSelector({super.key, required this.onPressed});
  final void Function(String) onPressed;
  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      onEmojiSelected: (Category? category, Emoji? emoji) {
        onPressed((emoji?.emoji) ?? "");
        context.pop();
      },
      config: Config(
        // FIXME
        // columns: 7,
        // // Issue: https://github.com/flutter/flutter/issues/28894
        // emojiSizeMax: 32 *
        //     (foundation.defaultTargetPlatform == TargetPlatform.iOS
        //         ? 1.30
        //         : 1.0),
        // verticalSpacing: 0,
        // horizontalSpacing: 0,
        // gridPadding: EdgeInsets.zero,
        // initCategory: Category.SMILEYS,
        // bgColor: Theme.of(context).colorScheme.background,
        // indicatorColor: Theme.of(context).colorScheme.primary,
        // iconColor: Theme.of(context).colorScheme.outline,
        // iconColorSelected: Theme.of(context).colorScheme.primary,

        // skinToneDialogBgColor: Theme.of(context).colorScheme.outlineVariant,
        // skinToneIndicatorColor: Theme.of(context).colorScheme.outline,
        // enableSkinTones: true,
        // recentTabBehavior: RecentTabBehavior.NONE,
        // recentsLimit: 28,
        // replaceEmojiOnLimitExceed: false,
        // noRecents: const Text(
        //   'No Recents',
        //   style: TextStyle(fontSize: 20, color: Colors.black26),
        //   textAlign: TextAlign.center,
        // ),
      ),
    );
  }
}
