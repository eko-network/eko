import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/interfaces/search.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/search/user_search_bar.dart';
import 'package:eko_app/widgets/users/user_card.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class FloatingSearchBar extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  FloatingSearchBar({required this.child, this.height = 60});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  List<MapEntry<String, double>> data = [];
  bool isEnd = false;
  Timer? debounce;
  String lastVal = '';

  void inputListener() {
    if (controller.text == lastVal) return;
    lastVal = controller.text;
    setState(() {
      data.clear();
      isEnd = false;
    });
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        final res = await SearchInterface.getter([], ref, controller.text);
        setState(() {
          data = res.$1;
          isEnd = res.$2;
        });
      },
    );
  }

  @override
  void initState() {
    controller.addListener(inputListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(inputListener);
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AppScaffold(
        body: InfiniteScrollyCore<String>(
          onRefresh: () async {
            if (debounce?.isActive ?? false) debounce!.cancel();
            final res = await SearchInterface.getter([], ref, controller.text);
            setState(() {
              data = res.$1;
              isEnd = res.$2;
            });
          },
          list: data.map((item) => item.key).toList(),
          isEnd: isEnd,
          getter: () async {
            final res = await SearchInterface.getter(
              data,
              ref,
              controller.text,
            );
            setState(() {
              data.addAll(res.$1);
              isEnd = res.$2;
            });
          },
          initialLoadingWidget: UserLoader(),
          widget: userCardBuilder,
          header: UserSearchBar(controller: controller),
          fixedHeader: true,
        ),
      ),
    );
  }
}
