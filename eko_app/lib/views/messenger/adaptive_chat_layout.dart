import 'package:collection/collection.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/messenger/group_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/views/messenger/chat_view.dart';
import 'package:eko_app/views/messenger/group_list.dart';
import 'package:eko_app/widgets/messenger/resizable_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdaptiveChat extends ConsumerWidget {
  final int? selectedGroupId;
  final controller = ResizablePanelController();

  AdaptiveChat({super.key, this.selectedGroupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: groupsAsync.when(
        data: (groups) => LayoutBuilder(
          builder: (context, constraints) {
            print(groups);
            final isWideScreen = constraints.maxWidth >= c.messengerWideScreen;
            if (isWideScreen) {
              return _buildWideLayout(context, constraints, groups, l10n);
            } else {
              return _buildNarrowLayout(context, groups, l10n);
            }
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint(error.toString());
          return Center(child: Text('Could not load: $error'));
        },
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    BoxConstraints constraints,
    List<MlsGroupRecord> groups,
    AppLocalizations l10n,
  ) {
    const double minWidth = 200.0;
    const double maxWidth = 600.0;
    const double defaultWidth = 400.0;
    const double snapWidth = c.kConversationAvatarRadius * 2 + 20;

    final selectedGroup = groups.firstWhereOrNull(
      (item) => item.id == selectedGroupId,
    );

    return ResizablePanel(
      key: ValueKey(constraints.maxWidth),
      minWidth: minWidth,
      maxWidth: maxWidth,
      defaultWidth: defaultWidth,
      snapWidth: snapWidth,
      controller: controller,
      firstPanel: GroupList(
        isWideScreen: true,
        groups: groups,
        selectedId: selectedGroupId,
        panelController: controller,
        onConversationTap: (id) => context.go('/messages/$id'),
      ),
      secondPanel: selectedGroupId == null || selectedGroup == null
          ? Center(
              child: Text(
                'Select a conversation',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : SizedBox(), //ChatView(conversation: selecte, onBack: null),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<MlsGroupRecord> groups,
    AppLocalizations l10n,
  ) {
    final selectedConversation = groups.firstWhereOrNull(
      (item) => item.id == selectedGroupId,
    );

    if (selectedGroupId == null || selectedConversation == null) {
      return GroupList(
        isWideScreen: false,
        groups: groups,
        selectedId: null,
        onConversationTap: (id) => context.push('/messages/$id'),
      );
    } else {
      return ChatView(
        group: selectedConversation,
        onBack: () => context.go('/messages'),
      );
    }
  }
}
