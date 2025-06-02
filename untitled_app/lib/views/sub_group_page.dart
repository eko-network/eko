import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/types/group.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/widgets/post_card.dart';
import '../utilities/constants.dart' as c;

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.8,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: width * 0.45,
            height: width * 0.15,
            child: TextButton(
              onPressed: () => context.go('/feed'),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.exit,
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

SliverAppBar _appBar(BuildContext context, GroupModel group) {
  final width = c.widthGetter(context);
  return SliverAppBar(
    automaticallyImplyLeading: false,
    leading: IconButton(
      color: Theme.of(context).colorScheme.onSurface,
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back_ios_rounded),
    ),
    actions: [
      IconButton(
        color: Theme.of(context).colorScheme.onSurface,
        onPressed: () {
          context.push('/groups/sub_group/${group.id}/edit_group',
              extra: group);
        },
        icon: const Icon(Icons.create),
      ),
    ],
    floating: true,
    pinned: false,
    scrolledUnderElevation: 0.0,
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    title: Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (group.icon != '')
          SizedBox(
            width: width * 0.13,
            height: width * 0.13,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                group.icon,
              ),
            ),
          ),
        SizedBox(
            width: width * 0.4,
            child: Text(group.name,
                style: TextStyle(fontSize: width * 0.06),
                overflow: TextOverflow.ellipsis)),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(3),
      child: Divider(
        color: Theme.of(context).colorScheme.outline,
        height: c.dividerWidth,
      ),
    ),
  );
}

class SubGroupPage extends ConsumerWidget {
  final String id;
  const SubGroupPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroup = ref.watch(groupProvider(id));
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 70,
        child: FloatingActionButton.large(
          heroTag: null,
          onPressed: () {
            context.goNamed('compose',
                queryParameters:
                    asyncGroup.hasValue ? {'id': asyncGroup.value?.id} : {});
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 40),
        ),
      ),
      body: asyncGroup.when(
        data: (group) => group.members
                .contains(ref.watch(currentUserProvider).user.uid)
            ? InfiniteScrolly<String, String>(
                appBar: _appBar(context, group),
                getter: (data) async {
                  return await getGroupPosts(data, ref, group.id);
                },
                widget: postCardBuilder,
                initialLoadingWidget: PostLoader(
                  length: 4,
                ),
              )
            : _ErrorMessage(message: AppLocalizations.of(context)!.notInGroup),
        loading: () => Center(child: LoadingSpinner()),
        error: (_, __) =>
            _ErrorMessage(message: AppLocalizations.of(context)!.groupNotFound),
      ),
    );
  }
}
