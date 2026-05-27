import 'package:collection/collection.dart';
import 'package:eko_app/database/daos/conversations_dao.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/messenger_conversations_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/views/messenger/chat_view.dart';
import 'package:eko_app/views/messenger/conversation_list.dart';
import 'package:eko_app/widgets/messenger/resizable_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdaptiveChat extends ConsumerWidget {
  final int? selectedConversationId;
  final controller = ResizablePanelController();

  AdaptiveChat({super.key, this.selectedConversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: conversationsAsync.when(
        data: (conversations) => LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= c.messengerWideScreen;
            if (isWideScreen) {
              return _buildWideLayout(
                  context, constraints, conversations, l10n);
            } else {
              return _buildNarrowLayout(context, conversations, l10n);
            }
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint(error.toString());
          return Center(
            child: Text('Could not load conversations: $error'),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    BoxConstraints constraints,
    List<ConversationWithContact> conversations,
    AppLocalizations l10n,
  ) {
    const double minWidth = 200.0;
    const double maxWidth = 600.0;
    const double defaultWidth = 400.0;
    const double snapWidth = c.kConversationAvatarRadius * 2 + 20;

    final selectedConversation = conversations.firstWhereOrNull(
      (item) => item.conversation.id == selectedConversationId,
    );

    return ResizablePanel(
      key: ValueKey(constraints.maxWidth),
      minWidth: minWidth,
      maxWidth: maxWidth,
      defaultWidth: defaultWidth,
      snapWidth: snapWidth,
      controller: controller,
      firstPanel: ConversationList(
        isWideScreen: true,
        conversations: conversations,
        selectedId: selectedConversationId,
        panelController: controller,
        onConversationTap: (id) => context.go('/messages/$id'),
      ),
      secondPanel:
          selectedConversationId == null || selectedConversation == null
              ? Center(
                  child: Text(
                    'Select a conversation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ChatView(conversation: selectedConversation, onBack: null),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<ConversationWithContact> conversations,
    AppLocalizations l10n,
  ) {
    final selectedConversation = conversations.firstWhereOrNull(
      (item) => item.conversation.id == selectedConversationId,
    );

    if (selectedConversationId == null || selectedConversation == null) {
      return ConversationList(
        isWideScreen: false,
        conversations: conversations,
        selectedId: null,
        onConversationTap: (id) => context.push('/messages/$id'),
      );
    } else {
      return ChatView(
        conversation: selectedConversation,
        onBack: () => context.go('/messages'),
      );
    }
  }
}
