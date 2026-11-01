import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/common/feed_options_button.dart';
import 'package:eko_app/widgets/common/max_width_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/popular_feed_provider.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';

import 'package:eko_app/widgets/common/icons.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/posts/post_card.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';

const appBarHeight = kToolbarHeight;

class _FeedAppBarContent extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback onLogoTap;
  const _FeedAppBarContent({
    required this.selectedIndex,
    required this.onSelectionChanged,
    required this.onLogoTap,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MaxWidthContent(
      child: SizedBox(
        height: appBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.pushNamed('recent'),
                  child: Bell(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(onTap: onLogoTap, child: Eko()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FeedOptionsButton<int>(
                  selectedValue: selectedIndex,
                  onChanged: onSelectionChanged,
                  options: [
                    FeedOption(label: l10n.following, value: 0),
                    FeedOption(label: l10n.feedTabNew, value: 1),
                    FeedOption(label: l10n.feedTabPopular, value: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  int selectedIndex = 0;
  final followingScrollController = ScrollController();
  final newScrollController = ScrollController();
  final popScrollController = ScrollController();

  Widget _buildCurrentFeed() {
    final appBar = _buildFeedAppBar();
    switch (selectedIndex) {
      case 0:
        return _FollowingFeed(
          controller: followingScrollController,
          appBar: appBar,
        );
      case 1:
        return _NewFeed(controller: newScrollController, appBar: appBar);
      case 2:
        return _PopularFeed(controller: popScrollController, appBar: appBar);
      default:
        return _FollowingFeed(
          controller: followingScrollController,
          appBar: appBar,
        );
    }
  }

  SliverAppBar _buildFeedAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleSpacing: 0,
      toolbarHeight: appBarHeight,
      title: _FeedAppBarContent(
        selectedIndex: selectedIndex,
        onSelectionChanged: _onFeedOptionChanged,
        onLogoTap: _refreshCurrentTab,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: MaxWidthContent(
          child: Divider(
            color: Theme.of(context).colorScheme.outline,
            height: 0.5,
          ),
        ),
      ),
    );
  }

  void _onFeedOptionChanged(int index) {
    if (selectedIndex == index) {
      return;
    }
    setState(() {
      selectedIndex = index;
      PrefsService.lastFeedPageIndex = index;
    });
  }

  Future<void> _refreshCurrentTab() async {
    switch (selectedIndex) {
      case 0:
        await ref.read(followingFeedProvider.notifier).refresh();
        return;
      case 1:
        await ref.read(newFeedProvider.notifier).refresh();
        return;
      case 2:
        await ref.read(popularFeedProvider.notifier).refresh();
        return;
      default:
        return;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = PrefsService.lastFeedPageIndex.clamp(0, 2);
  }

  @override
  void dispose() {
    followingScrollController.dispose();
    newScrollController.dispose();
    popScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentFeed();
  }
}

class _FollowingFeed extends ConsumerStatefulWidget {
  final ScrollController controller;
  final SliverAppBar appBar;
  const _FollowingFeed({required this.controller, required this.appBar});

  @override
  ConsumerState<_FollowingFeed> createState() => __FollowingFeedState();
}

class __FollowingFeedState extends ConsumerState<_FollowingFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = ref.watch(followingFeedProvider);
    return InfiniteScrollyCore<int>(
      isEnd: provider.$2,
      list: provider.$1,
      appBar: widget.appBar,
      getter: ref.read(followingFeedProvider.notifier).getter,
      onRefresh: ref.read(followingFeedProvider.notifier).refresh,
      initialLoadingWidget: PostLoader(),
      widget: postCardBuilder,
      controller: widget.controller,
    );
  }
}

class _NewFeed extends ConsumerStatefulWidget {
  final ScrollController controller;
  final SliverAppBar appBar;
  const _NewFeed({required this.controller, required this.appBar});

  @override
  ConsumerState<_NewFeed> createState() => __NewFeedState();
}

class __NewFeedState extends ConsumerState<_NewFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = ref.watch(newFeedProvider);
    return InfiniteScrollyCore<int>(
      isEnd: provider.$2,
      list: provider.$1,
      appBar: widget.appBar,
      getter: ref.read(newFeedProvider.notifier).getter,
      onRefresh: ref.read(newFeedProvider.notifier).refresh,
      initialLoadingWidget: PostLoader(),
      widget: postCardBuilder,
      controller: widget.controller,
    );
  }
}

class _PopularFeed extends ConsumerStatefulWidget {
  final ScrollController controller;
  final SliverAppBar appBar;
  const _PopularFeed({required this.controller, required this.appBar});

  @override
  ConsumerState<_PopularFeed> createState() => __PopularFeedState();
}

class __PopularFeedState extends ConsumerState<_PopularFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = ref.watch(popularFeedProvider);
    return InfiniteScrollyCore<int>(
      isEnd: provider.$2,
      list: provider.$1,
      appBar: widget.appBar,
      getter: ref.read(popularFeedProvider.notifier).getter,
      onRefresh: ref.read(popularFeedProvider.notifier).refresh,
      initialLoadingWidget: PostLoader(),
      widget: postCardBuilder,
      controller: widget.controller,
    );
  }
}
