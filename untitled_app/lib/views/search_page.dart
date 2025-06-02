import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/search.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../widgets/user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(height * 0.01),
          prefixIcon: Padding(
            padding: EdgeInsets.all(width * 0.035),
            child: Image.asset(
                (Theme.of(context).brightness == Brightness.dark)
                    ? 'images/algolia_logo_white.png'
                    : 'images/algolia_logo_blue.png',
                width: width * 0.05,
                height: width * 0.05),
          ),
          hintText: AppLocalizations.of(context)!.search,
          filled: true,
          fillColor: Theme.of(context).colorScheme.outlineVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
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
          header: _SearchBar(controller: controller),
        ),
      ),
    );
  }
}
