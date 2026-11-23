import 'dart:math' show max, min;

import 'package:ecp/ecp.dart' as ecp;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/message_provider.dart';
import 'package:eko_app/messenger/widgets/emoji_picker.dart';
import 'package:eko_app/messenger/widgets/message_quote.dart';
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Own messages can be edited or deleted for everyone this long after
/// sending them.
const editWindow = Duration(hours: 24);

const quickReactions = ['❤️', '👍', '👎', '😂', '😮', '😢'];

enum MessageAction { reply, edit, copy, delete }

sealed class MessageActionChoice {
  const MessageActionChoice();
}

/// React with [emoji], or take back the reaction when it is the current one.
class ReactChoice extends MessageActionChoice {
  final String emoji;
  const ReactChoice(this.emoji);
}

/// Pick a reaction from all emoji.
class MoreReactionsChoice extends MessageActionChoice {
  const MoreReactionsChoice();
}

class ActionChoice extends MessageActionChoice {
  final MessageAction action;
  const ActionChoice(this.action);
}

/// Shows [bubble] where it was, at [bubbleRect], with reactions above it and
/// [actions] below, like a long press on a message in Signal.
Future<MessageActionChoice?> showMessageActions(
  BuildContext context, {
  required Rect bubbleRect,
  required Widget bubble,
  required bool isReceived,
  required String? myReaction,
  required bool canReact,
  required List<MessageAction> actions,
}) {
  return showGeneralDialog<MessageActionChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.96, end: 1.0).animate(animation),
        child: child,
      ),
    ),
    // the bubble's text needs a Material for its default style
    pageBuilder: (context, _, _) => Material(
      type: MaterialType.transparency,
      child: _MessageActionsOverlay(
        bubbleRect: bubbleRect,
        bubble: bubble,
        isReceived: isReceived,
        myReaction: myReaction,
        canReact: canReact,
        actions: actions,
      ),
    ),
  );
}

class _MessageActionsOverlay extends StatelessWidget {
  final Rect bubbleRect;
  final Widget bubble;
  final bool isReceived;
  final String? myReaction;
  final bool canReact;
  final List<MessageAction> actions;

  const _MessageActionsOverlay({
    required this.bubbleRect,
    required this.bubble,
    required this.isReceived,
    required this.myReaction,
    required this.canReact,
    required this.actions,
  });

  static const _margin = 8.0;
  static const _barHeight = 52.0;
  // the quick reactions and the button for all emoji, see _ReactionBar
  static final _barWidth = (quickReactions.length + 1) * 44.0 + 8;
  static const _actionHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final barHeight = canReact ? _barHeight + _margin : 0.0;
    final menuHeight = actions.length * _actionHeight + 16 + _margin;
    final available =
        size.height - padding.vertical - 2 * _margin - barHeight - menuHeight;
    final bubbleHeight = min(bubbleRect.height, max(available, 48.0));
    final total = barHeight + bubbleHeight + menuHeight;
    // where the message was, moved up or down to fit on screen
    final top = (bubbleRect.top - barHeight)
        .clamp(
          padding.top + _margin,
          max(padding.top + _margin, size.height - padding.bottom - total),
        )
        .toDouble();
    final offset = max(
      0.0,
      isReceived
          ? bubbleRect.left - _margin
          : size.width - bubbleRect.right - _margin,
    );
    // the bar lines up with the message too, as far as it fits on screen
    final barOffset = min(
      offset,
      max(0.0, size.width - 2 * _margin - _barWidth),
    );
    EdgeInsets inset(double offset) => isReceived
        ? EdgeInsets.only(left: offset)
        : EdgeInsets.only(right: offset);

    return Stack(
      children: [
        Positioned(
          top: top,
          left: _margin,
          right: _margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isReceived
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              if (canReact) ...[
                Padding(
                  padding: inset(barOffset),
                  child: _ReactionBar(myReaction: myReaction),
                ),
                const SizedBox(height: _margin),
              ],
              Padding(
                padding: inset(offset),
                child: SizedBox(
                  height: bubbleHeight,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: IgnorePointer(child: bubble),
                  ),
                ),
              ),
              const SizedBox(height: _margin),
              Padding(
                padding: inset(offset),
                child: _ActionMenu(actions: actions),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionBar extends StatelessWidget {
  final String? myReaction;
  const _ReactionBar({required this.myReaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // an emoji picked from all of them takes the last spot
    final emoji = [...quickReactions];
    if (myReaction != null && !emoji.contains(myReaction)) {
      emoji.last = myReaction!;
    }
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(26),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in emoji)
                _ReactionButton(
                  selected: e == myReaction,
                  onTap: () => Navigator.of(context).pop(ReactChoice(e)),
                  child: Text(
                    e,
                    style: emojiTextStyle(const TextStyle(fontSize: 26)),
                  ),
                ),
              _ReactionButton(
                selected: false,
                onTap: () =>
                    Navigator.of(context).pop(const MoreReactionsChoice()),
                child: Icon(
                  LucideIcons.smilePlus,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _ReactionButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: selected
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              )
            : null,
        child: child,
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final List<MessageAction> actions;
  const _ActionMenu({required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final action in actions)
                InkWell(
                  onTap: () => Navigator.of(context).pop(ActionChoice(action)),
                  child: SizedBox(
                    height: _MessageActionsOverlay._actionHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            switch (action) {
                              MessageAction.reply => LucideIcons.reply,
                              MessageAction.edit => LucideIcons.pencil,
                              MessageAction.copy => LucideIcons.copy,
                              MessageAction.delete => LucideIcons.trash2,
                            },
                            size: 20,
                            color: action == MessageAction.delete
                                ? colorScheme.error
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            switch (action) {
                              MessageAction.reply => l10n.reply,
                              MessageAction.edit => l10n.messageEdit,
                              MessageAction.copy => l10n.messageCopy,
                              MessageAction.delete => l10n.delete,
                            },
                            style: TextStyle(
                              color: action == MessageAction.delete
                                  ? colorScheme.error
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets the user pick any emoji to react with.
Future<String?> pickReaction(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: 400,
      child: StyledEmojiPicker(
        onEmojiSelected: (emoji) => Navigator.of(context).pop(emoji),
      ),
    ),
  );
}

enum DeleteChoice { forMe, forEveryone }

/// Asks how to delete a message. Only own messages within [editWindow] can be
/// deleted for everyone.
Future<DeleteChoice?> confirmDelete(
  BuildContext context, {
  required bool forEveryone,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<DeleteChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.messageDeleteTitle),
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(DeleteChoice.forMe),
          child: Text(l10n.messageDeleteForMe),
        ),
        if (forEveryone)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteChoice.forEveryone),
            child: Text(l10n.messageDeleteForEveryone),
          ),
      ],
    ),
  );
}

/// Who reacted to a message with what. Tapping our own reaction takes it
/// back through [onRemove].
Future<void> showReactions(
  BuildContext context, {
  required List<ecp.StoredReaction> reactions,
  required Uri me,
  required ValueChanged<ecp.StoredReaction> onRemove,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) =>
        _ReactionsSheet(reactions: reactions, me: me, onRemove: onRemove),
  );
}

class _ReactionsSheet extends ConsumerStatefulWidget {
  final List<ecp.StoredReaction> reactions;
  final Uri me;
  final ValueChanged<ecp.StoredReaction> onRemove;

  const _ReactionsSheet({
    required this.reactions,
    required this.me,
    required this.onRemove,
  });

  @override
  ConsumerState<_ReactionsSheet> createState() => _ReactionsSheetState();
}

class _ReactionsSheetState extends ConsumerState<_ReactionsSheet> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final counts = <String, int>{};
    for (final reaction in widget.reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    final shown = widget.reactions
        .where((r) => _filter == null || r.emoji == _filter)
        .toList();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.messageReactions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label:
                      '${l10n.messageReactionsAll} ${widget.reactions.length}',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final entry in counts.entries)
                  _FilterChip(
                    label: '${entry.key} ${entry.value}',
                    selected: _filter == entry.key,
                    onTap: () => setState(() => _filter = entry.key),
                  ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final reaction in shown)
                  ListTile(
                    title: Text(
                      senderName(ref, l10n, reaction.senderId, widget.me),
                    ),
                    subtitle: reaction.senderId == widget.me
                        ? Text(l10n.messageReactionTapToRemove)
                        : null,
                    trailing: Text(
                      reaction.emoji,
                      style: emojiTextStyle(const TextStyle(fontSize: 24)),
                    ),
                    onTap: reaction.senderId == widget.me
                        ? () {
                            Navigator.of(context).pop();
                            widget.onRemove(reaction);
                          }
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: emojiTextStyle(const TextStyle())),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// The versions of an edited message, newest first.
Future<void> showEditHistory(
  BuildContext context, {
  required ecp.StoredMessage message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _EditHistorySheet(message: message),
  );
}

class _EditHistorySheet extends ConsumerWidget {
  final ecp.StoredMessage message;
  const _EditHistorySheet({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final revisions =
        ref.watch(messageRevisionsProvider(message.serverActivityId)).value ??
        const [];
    final versions = <MessageRevision>[
      (content: message.content, since: message.editedAt ?? message.receivedAt),
      ...revisions.reversed,
    ];
    final format = DateFormat.yMMMd().add_jm();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.messageEditHistory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final (i, version) in versions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              version.content ?? '',
                              style: emojiTextStyle(const TextStyle()),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i < versions.length - 1
                                ? '${l10n.messageEdited} ${format.format(version.since)}'
                                : format.format(version.since),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
