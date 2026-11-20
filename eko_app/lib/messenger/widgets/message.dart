import 'dart:math' show min;
import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/time_provider.dart';
import 'package:eko_app/messenger/views/chat_view.dart';
import 'package:eko_app/messenger/widgets/message_quote.dart';
import 'package:eko_app/messenger/widgets/relative_time.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

bool _isShortEmojiString(String text) {
  const maxLen = 5;
  final glyphs = text.trim().characters;

  if (glyphs.isEmpty || glyphs.length > maxLen) {
    return false;
  }

  final hasNormalText = RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text);

  if (hasNormalText) {
    return false;
  }

  final isEmojiLike = RegExp(
    // ignore: valid_regexps
    r'[^\x00-\x7F]|\p{Emoji}',
    unicode: true,
  ).hasMatch(text);

  return isEmojiLike;
}

class DateChip extends ConsumerWidget {
  final DateTime time;
  const DateChip({super.key, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final yesterday = now.subtract(Duration(days: 1));

    final String text;
    final l10n = AppLocalizations.of(context)!;

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      text = l10n.today;
    } else if (time.year == yesterday.year &&
        time.month == yesterday.month &&
        time.day == yesterday.day) {
      text = l10n.yesterday;
    } else {
      text = DateFormat('E, MMM d').format(time);
    }
    return Text(text, style: TextStyle(fontWeight: FontWeight.w300));
  }
}

enum MessageStatus { sending, sent, delivered, failed }

class StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const StatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (status) {
      case MessageStatus.sending:
        icon = LucideIcons.clock;
        break;
      case MessageStatus.sent:
        icon = LucideIcons.check;
        break;
      case MessageStatus.delivered:
        icon = LucideIcons.mailCheck;
        break;
      case MessageStatus.failed:
        icon = LucideIcons.badgeAlert;
        break;
    }
    return Icon(
      icon,
      size: 12,
      color: status == MessageStatus.failed
          ? Theme.of(context).colorScheme.error
          : Colors.white70,
    );
  }
}

class StatusWidget extends StatelessWidget {
  final ecp.StoredMessage message;
  final bool isReceived;
  final VoidCallback? onEditedTap;
  const StatusWidget({
    super.key,
    required this.message,
    required this.isReceived,
    this.onEditedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0), // Optical alignment
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.editedAt != null && !message.deleted)
            GestureDetector(
              onTap: onEditedTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  AppLocalizations.of(context)!.messageEdited,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          RelativeTimeWidget(time: message.receivedAt),
          if (!isReceived && !message.deleted)
            Padding(
              padding: EdgeInsetsGeometry.only(left: 4),
              child: StatusIcon(
                status: message.delivered
                    ? MessageStatus.delivered
                    : MessageStatus.sent,
              ),
            ),
        ],
      ),
    );
  }
}

BorderRadius _posToBorder(MessagePosition pos, bool isReceived) {
  const double big = 16.0;
  const double small = 4.0;

  final bool isTopFlattened =
      pos == MessagePosition.middle || pos == MessagePosition.bottom;
  final bool isBottomFlattened =
      pos == MessagePosition.middle || pos == MessagePosition.top;

  return BorderRadius.only(
    topLeft: Radius.circular(isReceived && isTopFlattened ? small : big),
    bottomLeft: Radius.circular(isReceived && isBottomFlattened ? small : big),
    topRight: Radius.circular(!isReceived && isTopFlattened ? small : big),
    bottomRight: Radius.circular(
      !isReceived && isBottomFlattened ? small : big,
    ),
  );
}

const _sentColor = Color(0xFF115AEF);
const _receivedColor = Color(0xFF3B3B3B);

/// What a reply quotes, see [MessageBubble.quoted].
typedef QuotedMessage = ({ecp.StoredMessage? message});

/// A message in a chat, with its reactions. Long pressing it or right
/// clicking opens the message's actions, swiping it right replies to it.
class MessageWidget extends StatelessWidget {
  final bool isReceived;
  final ecp.StoredMessage message;
  final MessagePosition position;
  final Uri me;
  final QuotedMessage? quoted;
  final List<ecp.StoredReaction> reactions;
  final bool highlighted;

  /// Called with the bubble's position on screen.
  final void Function(Rect bubble)? onActions;
  final VoidCallback? onReply;
  final VoidCallback? onQuoteTap;
  final VoidCallback? onReactionsTap;
  final VoidCallback? onEditedTap;

  const MessageWidget({
    super.key,
    required this.isReceived,
    required this.message,
    required this.me,
    this.position = MessagePosition.single,
    this.quoted,
    this.reactions = const [],
    this.highlighted = false,
    this.onActions,
    this.onReply,
    this.onQuoteTap,
    this.onReactionsTap,
    this.onEditedTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBottom =
        position == MessagePosition.single ||
        position == MessagePosition.bottom;

    void openActions(BuildContext bubbleContext) {
      final box = bubbleContext.findRenderObject() as RenderBox?;
      if (box == null || onActions == null) return;
      onActions!(box.localToGlobal(Offset.zero) & box.size);
    }

    final bubble = Builder(
      builder: (bubbleContext) => GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          openActions(bubbleContext);
        },
        onSecondaryTap: () => openActions(bubbleContext),
        child: MessageBubble(
          isReceived: isReceived,
          message: message,
          position: position,
          me: me,
          quoted: quoted,
          onQuoteTap: onQuoteTap,
          onEditedTap: onEditedTap,
        ),
      ),
    );

    final content = Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isReceived
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          bubble,
          if (reactions.isNotEmpty)
            Transform.translate(
              offset: const Offset(0, -6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ReactionsPill(
                  reactions: reactions,
                  me: me,
                  onTap: onReactionsTap,
                ),
              ),
            ),
          if (!_hasText(message) && isBottom)
            Padding(
              padding: EdgeInsets.only(
                top: reactions.isEmpty ? 5 : 0,
                bottom: 10,
              ),
              child: StatusWidget(
                message: message,
                isReceived: isReceived,
                onEditedTap: onEditedTap,
              ),
            ),
          SizedBox(height: isBottom ? 12 : 4),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlighted
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
          : Colors.transparent,
      child: onReply == null || message.deleted
          ? content
          // own messages are on the right, they swipe the other way
          : SwipeToReply(
              onReply: onReply!,
              reverse: !isReceived,
              child: content,
            ),
    );
  }
}

bool _hasText(ecp.StoredMessage message) =>
    message.deleted || (message.content?.trim().isNotEmpty ?? false);

/// The bubble of a message, also shown on its own above the actions.
class MessageBubble extends StatelessWidget {
  final bool isReceived;
  final ecp.StoredMessage message;
  final MessagePosition position;
  final Uri me;

  /// The message this one replies to, null when it isn't a reply.
  final QuotedMessage? quoted;
  final VoidCallback? onQuoteTap;
  final VoidCallback? onEditedTap;

  const MessageBubble({
    super.key,
    required this.isReceived,
    required this.message,
    required this.me,
    this.position = MessagePosition.single,
    this.quoted,
    this.onQuoteTap,
    this.onEditedTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = message.content?.trim();
    final hasContent = content?.isNotEmpty ?? false;
    final isBottom =
        position == MessagePosition.single ||
        position == MessagePosition.bottom;
    final quoted = message.deleted ? null : this.quoted;

    final isEmojiOnly =
        hasContent &&
        message.attachment.isEmpty &&
        quoted == null &&
        _isShortEmojiString(content!);

    final backgroundColor = isReceived ? _receivedColor : _sentColor;

    return Container(
      constraints: BoxConstraints(
        maxWidth: message.attachment.isNotEmpty
            ? min(400, MediaQuery.of(context).size.width * 0.75)
            : MediaQuery.of(context).size.width * 0.75,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: _posToBorder(position, isReceived),
        color: isEmojiOnly
            ? Colors.transparent
            : message.deleted
            ? backgroundColor.withValues(alpha: 0.4)
            : backgroundColor,
      ),
      child: _QuoteWidth(
        quoted: quoted != null,
        hasAttachment: message.attachment.isNotEmpty,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // a quote is as wide as the reply, or the reply as the quote
          crossAxisAlignment: quoted != null
              ? CrossAxisAlignment.stretch
              : isReceived
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (quoted != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: MessageQuote(
                  message: quoted.message,
                  me: me,
                  bubbleColor: backgroundColor,
                  onTap: onQuoteTap,
                ),
              ),
            if (message.attachment.isNotEmpty)
              _AttachmentGrid(attachments: message.attachment),
            if (message.deleted)
              _TextBubbleContent(
                content: isReceived
                    ? l10n.messageDeleted
                    : l10n.messageYouDeleted,
                isEmojiOnly: false,
                italic: true,
                showStatus: true,
                message: message,
                isReceived: isReceived,
              )
            else if (hasContent)
              _TextBubbleContent(
                content: content!,
                isEmojiOnly: isEmojiOnly,
                // "Edited" opens the history, so it shows on every edited message
                showStatus: isBottom || message.editedAt != null,
                message: message,
                isReceived: isReceived,
                onEditedTap: onEditedTap,
              ),
          ],
        ),
      ),
    );
  }
}

/// Sizes a bubble with a quote to its widest part, which the quote and text
/// then stretch to. Attachments already make the bubble as wide as it gets.
class _QuoteWidth extends StatelessWidget {
  final bool quoted;
  final bool hasAttachment;
  final Widget child;

  const _QuoteWidth({
    required this.quoted,
    required this.hasAttachment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) =>
      quoted && !hasAttachment ? IntrinsicWidth(child: child) : child;
}

/// The reactions under a message: the most used emoji and how many there
/// are.
class _ReactionsPill extends StatelessWidget {
  final List<ecp.StoredReaction> reactions;
  final Uri me;
  final VoidCallback? onTap;

  const _ReactionsPill({required this.reactions, required this.me, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = <String, int>{};
    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    final top = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    final mine = reactions.any((r) => r.senderId == me);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: mine
              ? Color.lerp(
                  colorScheme.surfaceContainerHighest,
                  _sentColor,
                  0.35,
                )
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.surface, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              top.take(3).join(),
              style: emojiTextStyle(const TextStyle(fontSize: 14)),
            ),
            if (reactions.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${reactions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextBubbleContent extends StatelessWidget {
  final String content;
  final bool isEmojiOnly;
  final bool italic;
  final bool showStatus;
  final ecp.StoredMessage message;
  final bool isReceived;
  final VoidCallback? onEditedTap;

  const _TextBubbleContent({
    required this.content,
    required this.isEmojiOnly,
    required this.showStatus,
    required this.message,
    required this.isReceived,
    this.italic = false,
    this.onEditedTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = showStatus
        ? StatusWidget(
            message: message,
            isReceived: isReceived,
            onEditedTap: onEditedTap,
          )
        : null;
    final text = Text.rich(
      TextSpan(
        text: content,
        children: [
          // keeps room for the status at the end of the last line
          if (status != null)
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: status,
                ),
              ),
            ),
        ],
      ),
      style: emojiTextStyle(
        TextStyle(
          fontSize: isEmojiOnly ? 32 : 14,
          fontStyle: italic ? FontStyle.italic : null,
          color: italic ? Colors.white70 : Colors.white,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // the status in the bottom corner, also when a quote makes the bubble
      // wider than the text
      child: status == null
          ? text
          : Stack(
              children: [
                text,
                Positioned(right: 0, bottom: 0, child: status),
              ],
            ),
    );
  }
}

/// Swiping [child] right far enough calls [onReply], or left when
/// [reverse].
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final bool reverse;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
    this.reverse = false,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  static const _threshold = 56.0;
  static const _max = 80.0;

  late final _offset = AnimationController(
    vsync: this,
    upperBound: _max,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  // how far it is swiped in its direction
  void _update(DragUpdateDetails details) {
    final wasPast = _offset.value >= _threshold;
    _offset.value += widget.reverse ? -details.delta.dx : details.delta.dx;
    if (!wasPast && _offset.value >= _threshold) HapticFeedback.lightImpact();
  }

  void _end(DragEndDetails _) {
    if (_offset.value >= _threshold) widget.onReply();
    _offset.animateTo(0, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: _end,
      onHorizontalDragCancel: () => _offset.animateTo(0),
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) => Stack(
          alignment: widget.reverse
              ? Alignment.centerRight
              : Alignment.centerLeft,
          children: [
            Opacity(
              opacity: (_offset.value / _threshold).clamp(0, 1),
              child: Padding(
                padding: widget.reverse
                    ? const EdgeInsets.only(right: 4)
                    : const EdgeInsets.only(left: 4),
                child: const Icon(LucideIcons.reply, size: 20),
              ),
            ),
            Transform.translate(
              offset: Offset(
                widget.reverse ? -_offset.value : _offset.value,
                0,
              ),
              child: child,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Hosts remote media may be loaded from. Loading an arbitrary url from a
/// message would reveal the recipient's IP address to whoever chose it.
bool _isAllowedMediaUrl(Uri url) {
  if (url.scheme != 'https') return false;
  final host = url.host.toLowerCase();
  return host == 'klipy.com' || host.endsWith('.klipy.com');
}

class _AttachmentGrid extends StatelessWidget {
  final List<ecp.ActivityPubObject> attachments;
  const _AttachmentGrid({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = attachments.whereType<ecp.Image>().toList();
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      final image = images.first;
      final width = image.width;
      final height = image.height;
      return AspectRatio(
        aspectRatio: width != null && height != null && width > 0 && height > 0
            ? width / height
            : 1,
        child: _AttachmentImage(image: image),
      );
    }

    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: List.generate(images.length, (index) {
        final isFirstFullWidth = images.length % 2 != 0 && index == 0;
        final crossAxisCount = isFirstFullWidth ? 2 : 1;

        return StaggeredGridTile.count(
          crossAxisCellCount: crossAxisCount,
          mainAxisCellCount: isFirstFullWidth ? 1.2 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _AttachmentImage(image: images[index]),
          ),
        );
      }),
    );
  }
}

class _AttachmentImage extends StatelessWidget {
  final ecp.Image image;
  const _AttachmentImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Icon(LucideIcons.imageOff, color: Colors.white38, size: 20),
      ),
    );
    if (!_isAllowedMediaUrl(image.url)) return placeholder;

    return Semantics(
      label: image.name,
      image: true,
      child: Image.network(
        image.url.toString(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const ColoredBox(color: Color(0xFF2A2A2A)),
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
