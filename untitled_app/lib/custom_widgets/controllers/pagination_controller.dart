import 'package:flutter/material.dart';

class Cache {
  List<dynamic> items;
  bool end;
  Cache({required this.items, required this.end});
}
class PaginationGetterReturn {
  final bool end;
  final List<dynamic> payload;
  PaginationGetterReturn({required this.end, required this.payload});
}

class PaginationController extends ChangeNotifier {
  final Future<PaginationGetterReturn> Function(dynamic) getter;
  final dynamic Function(dynamic) startAfterQuery;
  final Function()? extraRefresh;
  final BuildContext context;

  bool loading = false;

  ScrollController scrollController = ScrollController();
  Cache? externalData;
  late Cache data;

  PaginationController({
    required this.externalData,
    required this.extraRefresh,
    required this.getter,
    required this.context,
    required this.startAfterQuery,
  }) {
    init();
  }
  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void init() async {
    scrollController.addListener(_onScroll);
    // if (cacheIndex == null) {
    data = externalData ?? Cache(items: [], end: false);

    // } else {
    //   items = List.from(locator<FeedPostCache>().postsList[cacheIndex!].posts);
    //   end = locator<FeedPostCache>().postsList[cacheIndex!].end;
    // }
    if (data.items.isEmpty) {
      final returned = await getter(null); //should be passed null
      data.end = returned.end;
      data.items.addAll(returned.payload);
    }
    notifyListeners();
  }

  rebuildFunction() {
    notifyListeners();
  }

  Future<void> _onScroll() async {
    if (!data.end) {
      if (scrollController.position.maxScrollExtent -
              scrollController.position.pixels <=
          MediaQuery.sizeOf(context).height * 0.2) {
        if (loading == false) {
          loading = true;
          if (data.items.isNotEmpty) {
            final returned = await getter(
                startAfterQuery(data.items.last)); //should be passed startAfter
            data.end = returned.end;
            data.items.addAll(returned.payload);
            notifyListeners();
          }

          loading = false;
        }
      }
    }
  }

  Future<void> onRefresh() async {
    if (extraRefresh != null) {
      await extraRefresh!();
    }
    data.end = false;
    data.items.clear();
    // if (cacheIndex != null) {
    //   locator<FeedPostCache>().postsList[cacheIndex!].posts.clear();
    //   locator<FeedPostCache>().postsList[cacheIndex!].end = false;
    // }
    final returned = await getter(null); //should be passed null
    data.end = returned.end;
    data.items.addAll(returned.payload);

    notifyListeners();
  }
}
