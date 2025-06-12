import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/search.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:untitled_app/widgets/user_search_bar.dart';
import '../widgets/user_card.dart';
import '../utilities/constants.dart' as c;

class FloatingSearchBar extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  FloatingSearchBar({required this.child, this.height = 60});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
  List<MapEntry<String, int>> data = [];
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
    debounce =
        Timer(const Duration(milliseconds: c.searchPageDebounce), () async {
      final res = await SearchInterface.getter([], ref, controller.text);
      setState(() {
        data = res.$1;
        isEnd = res.$2;
      });
    });
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
      child: Scaffold(
        body: InfiniteScrollyShell<String>(
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
            final res =
                await SearchInterface.getter(data, ref, controller.text);
            setState(() {
              data.addAll(res.$1);
              isEnd = res.$2;
            });
          },
          initialLoadingWidget: UserLoader(
            length: 12,
          ),
          widget: userCardBuilder,
          header: UserSearchBar(controller: controller),
        ),
      ),
    );
  }
}
