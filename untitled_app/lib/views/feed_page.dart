import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/following_feed_provider.dart';
import 'package:untitled_app/providers/new_feed_provider.dart';

import 'package:untitled_app/widgets/icons.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/post_card.dart';
import 'package:untitled_app/widgets/post_loader.dart';

const appBarHeight = 80.0;

class RoundedTabIndicator extends Decoration {
  final BoxPainter _painter;

  RoundedTabIndicator(
      {required Color color, required double radius, required double thickness})
      : _painter = _RoundedPainter(color, radius, thickness);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RoundedPainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double thickness;

  _RoundedPainter(Color color, this.radius, this.thickness)
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Rect rect = Offset(
          offset.dx - 5,
          cfg.size!.height - thickness,
        ) &
        Size(cfg.size!.width + 10, thickness);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rRect, _paint);
  }
}

class _Tab extends StatelessWidget {
  final String label;
  const _Tab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 0, bottom: 10),
        child: Text(label));
  }
}

class _AppBar extends StatelessWidget {
  final double height;
  final TabController tabController;
  const _AppBar({required this.height, required this.tabController});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SizedBox(
        height: appBarHeight,
        child: Column(
          children: [
            Flexible(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Eko(),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.95, 0.05),
                    child: Bell(),
                  )
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              tabs: const [
                _Tab(label: 'Following'),
                _Tab(label: 'New'),
                _Tab(label: 'Popular'),
              ],
              indicator: RoundedTabIndicator(
                color: Theme.of(context).colorScheme.primary,
                radius: 4,
                thickness: 3,
              ),
              indicatorPadding: EdgeInsets.only(bottom: 5, top: 4),
              labelColor: Theme.of(context).colorScheme.onSurface,
              labelPadding: EdgeInsets.all(0),
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurface.withAlpha(200),
            )
          ],
        ),
      ),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  late final TabController tabController;
  final followingScrollController = ScrollController();
  final newScrollController = ScrollController();
  final popScrollController = ScrollController();
  static const targetRevealDelta = appBarHeight * 1.5;
  double appBarOffset = 0.0;
  double lastOffset = 0.0;
  double revealDelta = 0.0;

  ScrollController getCurrentScrollController() {
    switch (tabController.index) {
      case 0:
        return followingScrollController;
      case 1:
        return newScrollController;
      case 2:
        return popScrollController;
      default:
        return followingScrollController;
    }
  }

  void scrollListener() {
    final currentOffset = getCurrentScrollController().offset;
    final delta = currentOffset - lastOffset;

    if (delta < 0) {
      if (revealDelta < targetRevealDelta && currentOffset > appBarHeight) {
        revealDelta -= delta;
      } else if (appBarOffset != 0.0) {
        setState(() {
          appBarOffset -= delta;
          appBarOffset = appBarOffset.clamp(-appBarHeight, 0.0);
        });
      }
    } else {
      revealDelta = 0.0;
      if (appBarOffset != appBarHeight) {
        setState(() {
          appBarOffset -= delta;
          appBarOffset = appBarOffset.clamp(-appBarHeight, 0.0);
        });
      }
    }
    lastOffset = currentOffset;
  }

  @override
  void initState() {
    super.initState();
    followingScrollController.addListener(scrollListener);
    newScrollController.addListener(scrollListener);
    popScrollController.addListener(scrollListener);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    followingScrollController.removeListener(scrollListener);
    newScrollController.removeListener(scrollListener);
    popScrollController.removeListener(scrollListener);
    followingScrollController.dispose();
    newScrollController.dispose();
    popScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                if (appBarOffset <= -appBarHeight * 0.9 &&
                    getCurrentScrollController().offset > appBarHeight) {
                  setState(() {
                    appBarOffset = -appBarHeight;
                  });
                } else {
                  setState(() {
                    appBarOffset = 0.0;
                  });
                }
              }
              return false;
            },
            child: TabBarView(
              controller: tabController,
              children: [
                _FollowingTab(controller: followingScrollController),
                _NewTab(controller: newScrollController),
                _PopTab(controller: popScrollController),
              ],
            )),
        AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
            top: appBarOffset,
            left: 0,
            right: 0,
            height: appBarHeight,
            child: _AppBar(
              height: appBarHeight,
              tabController: tabController,
            )),
      ],
    );
  }
}

class _FollowingTab extends ConsumerWidget {
  final ScrollController controller;
  const _FollowingTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(followingFeedProvider);
    return InfiniteScrollyShell<String>(
      isEnd: provider.$2,
      list: provider.$1,
      header: SizedBox(
        height: appBarHeight,
      ),
      getter: ref.read(followingFeedProvider.notifier).getter,
      onRefresh: ref.read(followingFeedProvider.notifier).refresh,
      initialLoadingWidget: PostLoader(
        length: 3,
      ),
      widget: postCardBuilder,
      controller: controller,
    );
  }
}

class _NewTab extends ConsumerWidget {
  final ScrollController controller;
  const _NewTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(newFeedProvider);
    return InfiniteScrollyShell<String>(
      isEnd: provider.$2,
      list: provider.$1,
      header: SizedBox(
        height: appBarHeight,
      ),
      getter: ref.read(newFeedProvider.notifier).getter,
      onRefresh: ref.read(newFeedProvider.notifier).refresh,
      initialLoadingWidget: PostLoader(
        length: 3,
      ),
      widget: postCardBuilder,
      controller: controller,
    );
  }
}

class _PopTab extends ConsumerWidget {
  final ScrollController controller;
  const _PopTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfiniteScrolly<String, int>(
      header: SizedBox(
        height: appBarHeight,
      ),
      getter: (data) async {
        return await popGetter(data, ref);
      },
      initialLoadingWidget: PostLoader(
        length: 3,
      ),
      widget: postCardBuilder,
      controller: controller,
    );
  }
}
