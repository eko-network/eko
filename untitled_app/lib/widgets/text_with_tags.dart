import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/providers/current_user_provider.dart';

Future<void> defaultTagPressed(
    String username, BuildContext context, WidgetRef ref) async {
  if (ref.watch(currentUserProvider).user.username == username) {
    context.go('/profile');
  } else {
    String? uid = await getUidFromUsername(username);
    if (!context.mounted) return;
    context.push('/feed/sub_profile/$uid');
  }
}

class TextWithTags extends ConsumerStatefulWidget {
  final TextStyle? baseTextStyle;
  final TextStyle? tagTextStyle;
  final List<String> text;
  final Future<void> Function(String)? onTagPressed;
  const TextWithTags(
      {super.key,
      required this.text,
      this.tagTextStyle,
      this.baseTextStyle,
      this.onTagPressed});

  @override
  ConsumerState<TextWithTags> createState() => _TextWithTagsState();
}

class _TextWithTagsState extends ConsumerState<TextWithTags> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.baseTextStyle ??
            TextStyle(
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            ),
        children: widget.text.map((chunk) {
          if (chunk.startsWith('@')) {
            // This is a username, create a hyperlink
            return TextSpan(
              text: chunk,
              style: widget.tagTextStyle ??
                  TextStyle(color: Theme.of(context).colorScheme.surfaceTint),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (isLoading) return;
                  isLoading = true;
                  if (widget.onTagPressed == null) {
                    await defaultTagPressed(chunk.substring(1), context, ref);
                  } else {
                    await widget.onTagPressed!(chunk.substring(1));
                  }
                  isLoading = false;
                },
            );
          } else {
            // This is a normal text, create a TextSpan
            return TextSpan(
              text: chunk,
            );
          }
        }).toList(),
      ),
    );
  }
}
