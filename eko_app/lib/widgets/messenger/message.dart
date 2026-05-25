import 'dart:math' show min;

import 'package:characters/characters.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/models/message_with_attachments.dart';
import 'package:eko_app/database/type_converters.dart';
import 'package:eko_app/providers/messenger_time_provider.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:eko_app/widgets/messenger/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

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

  final isEmojiLike = RegExp(r'[^\x00-\x7F]', unicode: true).hasMatch(text);

  return isEmojiLike;
}

class DateChip extends ConsumerWidget {
  final DateTime time;
  const DateChip({super.key, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final yesterday = now.subtract(const Duration(days: 1));

    final String text;

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      text = 'Today';
    } else if (time.year == yesterday.year &&
        time.month == yesterday.month &&
        time.day == yesterday.day) {
      text = 'Yesterday';
    } else {
      text = DateFormat('E, MMM d').format(time);
    }
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w300));
  }
}

class StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const StatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final IconData icon;
    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.mark_email_read;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        break;
    }
    return Icon(
      icon,
      size: 12,
      color:
          status == MessageStatus.failed ? colorScheme.error : Colors.white70,
    );
  }
}

class StatusWidget extends StatelessWidget {
  final Message message;
  final bool isReceived;
  const StatusWidget({
    super.key,
    required this.message,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RelativeTimeWidget(time: message.time),
          if (!isReceived)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: StatusIcon(status: message.status),
            ),
        ],
      ),
    );
  }
}

enum MessagePosition { top, middle, bottom, single }

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

class MessageWidget extends StatelessWidget {
  final bool isReceived;
  final MessageWithAttachments messageWithAttachments;
  final MessagePosition position;

  const MessageWidget({
    super.key,
    required this.isReceived,
    required this.messageWithAttachments,
    this.position = MessagePosition.single,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message = messageWithAttachments.message;
    final content = message.content?.trim();
    final hasContent = content?.isNotEmpty ?? false;
    final isBottom = position == MessagePosition.single ||
        position == MessagePosition.bottom;

    final isEmojiOnly = hasContent &&
        messageWithAttachments.attachments.isEmpty &&
        _isShortEmojiString(content!);

    final backgroundColor =
        isReceived ? colorScheme.surfaceContainerHighest : colorScheme.primary;

    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: messageWithAttachments.attachments.isNotEmpty
                  ? min(400, MediaQuery.of(context).size.width * 0.75)
                  : MediaQuery.of(context).size.width * 0.75,
            ),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: _posToBorder(position, isReceived),
              color: isEmojiOnly ? Colors.transparent : backgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isReceived
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                if (messageWithAttachments.attachments.isNotEmpty)
                  _AttachmentGrid(
                    attachments: messageWithAttachments.attachments,
                  ),
                if (hasContent)
                  _TextBubbleContent(
                    content: content!,
                    isEmojiOnly: isEmojiOnly,
                    showStatus: isBottom,
                    message: message,
                    isReceived: isReceived,
                  ),
              ],
            ),
          ),
          if (!hasContent && isBottom)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 10),
              child: StatusWidget(message: message, isReceived: isReceived),
            ),
          SizedBox(height: isBottom ? 12 : 4),
        ],
      ),
    );
  }
}

class _TextBubbleContent extends StatelessWidget {
  final String content;
  final bool isEmojiOnly;
  final bool showStatus;
  final Message message;
  final bool isReceived;

  const _TextBubbleContent({
    required this.content,
    required this.isEmojiOnly,
    required this.showStatus,
    required this.message,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            content,
            style: emojiTextStyle(
              TextStyle(fontSize: isEmojiOnly ? 32 : 14, color: Colors.white),
            ),
          ),
          if (showStatus)
            StatusWidget(message: message, isReceived: isReceived),
        ],
      ),
    );
  }
}

class _AttachmentGrid extends StatelessWidget {
  final List<MediaData> attachments;
  const _AttachmentGrid({required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.length == 1) {
      return Image.network(
        attachments.first.url.toString(),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.generate(attachments.length, (index) {
          final isFirstFullWidth = attachments.length % 2 != 0 && index == 0;
          final crossAxisCount = isFirstFullWidth ? 2 : 1;

          return StaggeredGridTile.count(
            crossAxisCellCount: crossAxisCount,
            mainAxisCellCount: isFirstFullWidth ? 1.2 : 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                attachments[index].url.toString(),
                fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),
    );
  }
}
