import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The name of [senderId] as quotes and reaction lists show it.
String senderName(WidgetRef ref, AppLocalizations l10n, Uri senderId, Uri me) {
  if (senderId == me) return l10n.messageYou;
  final uid = uidFromActorId(senderId);
  return ref.watch(userProvider(uid)).value?.name ?? uid;
}

/// The message a reply refers to, in the reply's bubble or above the input.
/// [message] is null when this device doesn't have it, e.g. it was deleted
/// here only.
class MessageQuote extends ConsumerWidget {
  final ecp.StoredMessage? message;
  final Uri me;

  /// Shown instead of the sender's name.
  final String? title;

  /// Shown in a bubble of [bubbleColor], otherwise above the input.
  final Color? bubbleColor;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const MessageQuote({
    super.key,
    required this.message,
    required this.me,
    this.title,
    this.bubbleColor,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final onBubble = bubbleColor != null;
    final foreground = onBubble ? Colors.white : colorScheme.onSurface;
    final message = this.message;

    final String text;
    IconData? icon;
    var italic = false;
    if (message == null) {
      text = l10n.messageOriginalNotFound;
      italic = true;
    } else if (message.deleted) {
      text = l10n.messageDeleted;
      italic = true;
    } else if (message.content?.trim().isNotEmpty ?? false) {
      text = message.content!.trim();
    } else {
      text = l10n.messagePhoto;
      icon = LucideIcons.image;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: onBubble
              ? Color.lerp(bubbleColor, Colors.black, 0.25)
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: onBubble ? Colors.white70 : colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        child: Row(
          mainAxisSize: onBubble ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Flexible(
              fit: onBubble ? FlexFit.loose : FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message != null)
                    Text(
                      title ?? senderName(ref, l10n, message.senderId, me),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(icon, size: 14, color: foreground),
                        ),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: emojiTextStyle(
                            TextStyle(
                              fontSize: 13,
                              fontStyle: italic ? FontStyle.italic : null,
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onClose != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
