import 'package:collection/collection.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/group_provider.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/messenger/views/chat_view.dart';
import 'package:eko_app/messenger/views/group_list.dart';
import 'package:eko_app/messenger/widgets/resizable_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';

class AdaptiveChat extends ConsumerStatefulWidget {
  final int? selectedGroupId;
  final controller = ResizablePanelController();

  AdaptiveChat({super.key, this.selectedGroupId});

  @override
  ConsumerState<AdaptiveChat> createState() => _AdaptiveChatState();
}

class _AdaptiveChatState extends ConsumerState<AdaptiveChat> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isWideScreen =
          MediaQuery.of(context).size.width >= c.messengerWideScreen;
      if (!isWideScreen) {
        if (widget.selectedGroupId != null) {
          ref.read(navBarProvider.notifier).disable();
        } else {
          ref.read(navBarProvider.notifier).enable();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: groupsAsync.when(
        data: (groups) => LayoutBuilder(
          builder: (context, constraints) {
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
    List<GroupWithUsers> groups,
    AppLocalizations l10n,
  ) {
    const double minWidth = 200.0;
    const double maxWidth = 600.0;
    const double defaultWidth = 400.0;
    const double snapWidth = c.kConversationAvatarRadius * 2 + 20;

    final selectedGroup = groups.firstWhereOrNull(
      (item) => item.group.id == widget.selectedGroupId,
    );

    return ResizablePanel(
      key: ValueKey(constraints.maxWidth),
      minWidth: minWidth,
      maxWidth: maxWidth,
      defaultWidth: defaultWidth,
      snapWidth: snapWidth,
      controller: widget.controller,
      firstPanel: GroupList(
        isWideScreen: true,
        groups: groups,
        selectedId: widget.selectedGroupId,
        panelController: widget.controller,
        onGroupTap: (id) {
          context.go('/messages/$id');
        },
      ),
      secondPanel: widget.selectedGroupId == null || selectedGroup == null
          ? Center(
              child: Text(
                'Select a conversation',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ChatView(group: selectedGroup, onBack: null),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<GroupWithUsers> groups,
    AppLocalizations l10n,
  ) {
    final selectedGroup = groups.firstWhereOrNull(
      (item) => item.group.id == widget.selectedGroupId,
    );

    if (widget.selectedGroupId == null || selectedGroup == null) {
      return GroupList(
        isWideScreen: false,
        groups: groups,
        selectedId: null,
        onGroupTap: (id) {
          ref.read(navBarProvider.notifier).disable();
          context.push('/messages/$id');
        },
      );
    } else {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            ref.read(navBarProvider.notifier).enable();
          }
        },
        child: ChatView(
          group: selectedGroup,
          onBack: () {
            context.pop();
          },
        ),
      );
    }
  }
}
