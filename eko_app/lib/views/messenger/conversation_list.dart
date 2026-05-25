import 'package:eko_app/database/daos/conversations_dao.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/emoji_text_style.dart';
import 'package:eko_app/widgets/messenger/avatar.dart';
import 'package:eko_app/widgets/messenger/relative_time.dart';
import 'package:eko_app/widgets/messenger/resizable_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConversationList extends ConsumerStatefulWidget {
  final bool isWideScreen;
  final List<ConversationWithContact> conversations;
  final int? selectedId;
  final ResizablePanelController? panelController;
  final void Function(int) onConversationTap;

  const ConversationList({
    super.key,
    required this.conversations,
    required this.selectedId,
    required this.onConversationTap,
    required this.isWideScreen,
    this.panelController,
  });

  @override
  ConsumerState<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<ConversationList> {
  final newMessageController = TextEditingController();
  bool newChatScreen = false;

  void onNewPressed() {
    widget.panelController?.expand();
    setState(() {
      newChatScreen = true;
    });
  }

  Future<void> onSearchGetPressed() async {
    final l10n = AppLocalizations.of(context)!;
    if (ref.read(authProvider).uid == null) {
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User not found'),
        content: Text(
          'Could not find "${newMessageController.text.trim()}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ecpReady = ref.watch(authProvider).uid?.isNotEmpty ?? false;

    return Scaffold(
      body: SafeArea(
        child: ecpReady
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final showOnlyAvatar = constraints.maxWidth <
                      (c.kConversationAvatarRadius * 2) + 45;
                  return IndexedStack(
                    index: newChatScreen ? 1 : 0,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 8),
                          if (!showOnlyAvatar)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () => context.go('/profile'),
                                  icon: const Icon(Icons.settings_outlined),
                                  iconSize: 30,
                                  padding: const EdgeInsets.all(5),
                                  splashRadius: c.kConversationAvatarRadius,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.messengerTitle,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: onNewPressed,
                                  icon: const Icon(Icons.edit_outlined),
                                  iconSize: 30,
                                  padding: const EdgeInsets.all(5),
                                  splashRadius: c.kConversationAvatarRadius,
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          if (showOnlyAvatar) ...[
                            IconButton(
                              onPressed: () => context.go('/profile'),
                              icon: const Icon(Icons.settings_outlined),
                            ),
                            IconButton(
                              onPressed: onNewPressed,
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ],
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.conversations.length,
                              itemBuilder: (context, index) {
                                final conversation =
                                    widget.conversations[index];
                                final isSelected =
                                    conversation.conversation.id ==
                                        widget.selectedId;

                                if (showOnlyAvatar) {
                                  return Tooltip(
                                    message:
                                        conversation.contact.preferredUsername,
                                    child: ListTile(
                                      selected: isSelected,
                                      selectedTileColor:
                                          colorScheme.secondaryContainer,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      title: Center(
                                        child: MessengerAvatar(
                                          person: conversation.contact,
                                        ),
                                      ),
                                      onTap: () => widget.onConversationTap(
                                        conversation.conversation.id,
                                      ),
                                    ),
                                  );
                                }

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor:
                                      colorScheme.secondaryContainer,
                                  leading: MessengerAvatar(
                                    person: conversation.contact,
                                  ),
                                  title: Text(
                                    conversation.contact.preferredUsername,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    conversation
                                            .conversation.lastMessageContent ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: emojiTextStyle(const TextStyle()),
                                  ),
                                  trailing: RelativeTimeWidget(
                                    time: conversation
                                        .conversation.lastMessageTime,
                                  ),
                                  onTap: () => widget.onConversationTap(
                                    conversation.conversation.id,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 8),
                          if (!showOnlyAvatar)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: c.kConversationAvatarRadius * 2,
                                  height: c.kConversationAvatarRadius * 2,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        newChatScreen = false;
                                      });
                                    },
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 30,
                                    padding: const EdgeInsets.all(5),
                                    splashRadius: c.kConversationAvatarRadius,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'New message',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 5,
                            ),
                            child: TextField(
                              controller: newMessageController,
                              decoration: InputDecoration(
                                hintText: '@username or address',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: newMessageController,
                            builder: (context, value, child) {
                              return newMessageController.text.isEmpty
                                  ? const SizedBox()
                                  : ListTile(
                                      leading: CircleAvatar(
                                        radius: c.kConversationAvatarRadius,
                                        child: Text(
                                          newMessageController.text[0],
                                        ),
                                      ),
                                      title: Text(
                                        newMessageController.text,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: onSearchGetPressed,
                                    );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Sign in to use messenger',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
      ),
    );
  }
}
