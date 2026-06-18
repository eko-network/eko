import 'dart:async';
import 'package:eko_app/interfaces/search.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/types/group.dart';
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
  final List<GroupWithUsers> groups;
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

  Future<void> onUserSelected(UserModel user) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final peer = EkoPerson.fromUid(user.uid);
      await ref.watch(ecpClientProvider).groups.createGroup([peer]);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.keysExchanged)));
      setState(() {
        newChatScreen = false;
        searchController.clear();
        searchData.clear();
        searchIsEnd = false;
        lastSearchVal = '';
      });
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
                        Text(
                          'Chats',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                                  iconSize: 22,
                                  padding: const EdgeInsets.only(right: 10),
                                  splashRadius: c.kConversationAvatarRadius,
                                ),
                              ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.groups.length,
                        itemBuilder: (context, index) {
                          final gu = widget.groups[index];
                          final isSelected = gu.group.id == widget.selectedId;
                          return GroupCard(
                            showOnlyAvatar: showOnlyAvatar,
                            group: gu,
                            isSelected: isSelected,
                            onTap: () => widget.onGroupTap(gu.group.id),
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
                                  searchController.clear();
                                  searchData.clear();
                                  searchIsEnd = false;
                                  lastSearchVal = '';
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
                            l10n.newMessage,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
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
                            actionWidget: (_) => SizedBox.shrink(),
                            uid: uid,
                            onCardPressed: onUserSelected,
                          ),
                          header: UserSearchBar(controller: searchController),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
