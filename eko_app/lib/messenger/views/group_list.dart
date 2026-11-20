import 'dart:async';
import 'package:ecp/ecp.dart';
import 'package:eko_app/interfaces/search.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/views/device_warning.dart';
import 'package:eko_app/messenger/widgets/group_card.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/messenger/widgets/resizable_panel.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/widgets/search/user_search_bar.dart';
import 'package:eko_app/widgets/users/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GroupList extends ConsumerStatefulWidget {
  final bool isWideScreen;
  final List<MlsGroupRecord> groups;
  final int? selectedId;
  final ResizablePanelController? panelController;
  final void Function(int) onGroupTap;

  const GroupList({
    super.key,
    required this.selectedId,
    required this.onGroupTap,
    required this.isWideScreen,
    required this.groups,
    this.panelController,
  });

  @override
  ConsumerState<GroupList> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<GroupList> {
  final searchController = TextEditingController();
  bool newChatScreen = false;
  bool newGroupMode = false;
  bool creatingGroup = false;
  // the person whose DM is being opened, to show progress on their card
  String? pendingUid;
  // keyed by uid, in the order they were picked
  final Map<String, UserModel> groupMembers = {};
  List<MapEntry<String, double>> searchData = [];
  bool searchIsEnd = false;
  Timer? debounce;
  String lastSearchVal = '';

  void onNewPressed() {
    widget.panelController?.expand();
    setState(() {
      newChatScreen = true;
    });
  }

  void searchInputListener() {
    if (searchController.text == lastSearchVal) return;
    lastSearchVal = searchController.text;
    setState(() {
      searchData.clear();
      searchIsEnd = false;
    });
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        final res = await SearchInterface.getter(
          [],
          ref,
          searchController.text,
          excludeCurrent: true,
        );
        setState(() {
          searchData = res.$1;
          searchIsEnd = res.$2;
        });
      },
    );
  }

  Future<void> onSearchRefresh() async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    final res = await SearchInterface.getter(
      [],
      ref,
      searchController.text,
      excludeCurrent: true,
    );
    setState(() {
      searchData = res.$1;
      searchIsEnd = res.$2;
    });
  }

  Future<void> onSearchLoadMore() async {
    final res = await SearchInterface.getter(
      searchData,
      ref,
      searchController.text,
      excludeCurrent: true,
    );
    setState(() {
      searchData.addAll(res.$1);
      searchIsEnd = res.$2;
    });
  }

  void closeNewChat() {
    setState(() {
      newChatScreen = false;
      newGroupMode = false;
      groupMembers.clear();
      searchController.clear();
      searchData.clear();
      searchIsEnd = false;
      lastSearchVal = '';
    });
  }

  void onUserSelected(UserModel user) {
    if (!newGroupMode) {
      setState(() => pendingUid = user.uid);
      createGroup([user]);
      return;
    }
    setState(() {
      if (groupMembers.remove(user.uid) == null) groupMembers[user.uid] = user;
    });
  }

  Future<void> createGroup(List<UserModel> users) async {
    final l10n = AppLocalizations.of(context)!;
    final peers = [for (final user in users) EkoPerson.fromUid(user.uid)];
    final client = ref.read(ecpClientProvider);
    final accepted = <Uri>{};

    setState(() => creatingGroup = true);
    try {
      MlsGroupRecord? group;
      while (true) {
        try {
          final (created, _) = await client.groups.createGroup(peers);
          group = await client.core.storage.groupStore.getGroupByGroupId(
            created.groupId,
          );
          break;
        } on EcpDeviceChainChangedException catch (e) {
          // a second change from the same person after accepting it is a
          // real failure, not something to ask about again
          if (!accepted.add(e.actor)) rethrow;
          final user = users.firstWhere(
            (u) => actorIdFromUid(u.uid) == e.actor,
          );
          if (!mounted || !await confirmDevicesChanged(context, user.name)) {
            return;
          }
          try {
            // brings them back into shared chats, the DM included, which the
            // createGroup retry then reuses
            await client.groups.acceptDeviceReset(Person.fromId(e.actor));
          } on EcpException catch (e) {
            debugPrint('[GroupList] acceptDeviceReset: $e');
          }
        }
      }
      if (!mounted) return;
      closeNewChat();
      if (group != null) widget.onGroupTap(group.id);
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.keyExchangeFailed),
          content: Text(l10n.userMayNotHaveDeviceRegistered),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          creatingGroup = false;
          pendingUid = null;
        });
      }
    }
  }

  @override
  void initState() {
    searchController.addListener(searchInputListener);
    super.initState();
  }

  @override
  void dispose() {
    searchController.removeListener(searchInputListener);
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showOnlyAvatar =
                constraints.maxWidth < (c.kConversationAvatarRadius * 2) + 45;
            return IndexedStack(
              index: newChatScreen ? 1 : 0,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!showOnlyAvatar)
                          Text(
                            l10n.chats,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        showOnlyAvatar
                            ? IconButton(
                                onPressed: onNewPressed,
                                icon: const Icon(LucideIcons.squarePen),
                              )
                            : Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: onNewPressed,
                                  icon: const Icon(LucideIcons.squarePen),
                                  iconSize: 24,
                                  splashRadius: c.kConversationAvatarRadius,
                                ),
                              ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.groups.length,
                        itemBuilder: (context, index) {
                          final group = widget.groups[index];
                          final isSelected = group.id == widget.selectedId;
                          return GroupCard(
                            showOnlyAvatar: showOnlyAvatar,
                            group: group,
                            isSelected: isSelected,
                            onTap: () => widget.onGroupTap(group.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.05,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (!showOnlyAvatar)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: c.kConversationAvatarRadius * 2,
                                height: c.kConversationAvatarRadius * 2,
                                child: IconButton(
                                  onPressed: newGroupMode
                                      ? () => setState(() {
                                          newGroupMode = false;
                                          groupMembers.clear();
                                        })
                                      : closeNewChat,
                                  icon: const Icon(Icons.chevron_left),
                                  iconSize: 24,
                                  splashRadius: c.kConversationAvatarRadius,
                                ),
                              ),
                            ),
                            Text(
                              newGroupMode ? l10n.newGroup : l10n.newMessage,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (newGroupMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  // one person is a DM, see onUserSelected
                                  onPressed:
                                      groupMembers.length < 2 || creatingGroup
                                      ? null
                                      : () => createGroup(
                                          groupMembers.values.toList(),
                                        ),
                                  child: creatingGroup
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(l10n.create),
                                ),
                              ),
                          ],
                        ),
                      Expanded(
                        child: GestureDetector(
                          onPanDown: (details) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: InfiniteScrollyCore<String>(
                            onRefresh: onSearchRefresh,
                            list: searchData.map((item) => item.key).toList(),
                            isEnd: searchIsEnd,
                            getter: onSearchLoadMore,
                            initialLoadingWidget: const UserLoader(),
                            widget: (uid) => UserCard(
                              actionWidget: (_) => uid == pendingUid
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : newGroupMode
                                  ? Icon(
                                      groupMembers.containsKey(uid)
                                          ? LucideIcons.circleCheck
                                          : LucideIcons.circle,
                                    )
                                  : SizedBox.shrink(),
                              uid: uid,
                              onCardPressed: creatingGroup
                                  ? (_) {}
                                  : onUserSelected,
                            ),
                            header: Column(
                              children: [
                                SizedBox(height: 15),
                                if (!newGroupMode)
                                  // Material rather than a DecoratedBox so the
                                  // tiles' ink shows over the background
                                  Material(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(15),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        _NewChatOptionTile(
                                          icon: LucideIcons.users,
                                          label: l10n.newGroup,
                                          onTap: () => setState(
                                            () => newGroupMode = true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (groupMembers.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final user in groupMembers.values)
                                          InputChip(
                                            label: Text('@${user.username}'),
                                            onDeleted: creatingGroup
                                                ? null
                                                : () => onUserSelected(user),
                                          ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 15),
                                UserSearchBar(controller: searchController),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NewChatOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _NewChatOptionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
