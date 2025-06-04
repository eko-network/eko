import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/group_list_provider.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import '../widgets/group_card.dart';
import '../utilities/constants.dart' as c;

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(groupListProvider);
    return Scaffold(
      body: InfiniteScrollyShell(
        isEnd: provider.$2,
        list: provider.$1,
        getter: ref.read(groupListProvider.notifier).getter,
        onRefresh: ref.read(groupListProvider.notifier).refresh,
        widget: groupCardBuilder,
        appBar: SliverAppBar(
          title: Text(
            AppLocalizations.of(context)!.groups,
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
          floating: true,
          pinned: false,
          scrolledUnderElevation: 0.0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => context.push('/groups/create_group'),
              icon: const Icon(
                Icons.group_add,
                size: 20,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Divider(
              color: Theme.of(context).colorScheme.outline,
              height: c.dividerWidth,
            ),
          ),
        ),
      ),
    );
  }
}
