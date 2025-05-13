import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';

class _DefaultInitialLoader extends StatelessWidget {
  const _DefaultInitialLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 12),
        child: LoadingSpinner(),
      ),
    );
  }
}

/// A widget that enables infinite scrolling through a list of items.
///
/// [InfiniteScrolly] fetches items in chunks using the provided [getter] function
/// and displays each item using the [widget] builder. It supports optional
/// customizations such as a [SliverAppBar], headers, loading indicators, and
/// an empty-state widget.
///
/// Type parameters:
/// - [K]: The type of the key in each item. In our architecture this is the object
///			passed to the providers build method.
/// - [V]: The type of the value that a provider would return. This is essential
/// -		for proper sorting.
class InfiniteScrolly<K, V> extends StatefulWidget {
  /// Function that receives the current list of items and returns the next chunk. The getter
  ///		must treat the list it recives as read only. The data may get out of date, but that is ok.
  ///   Also must return bool to signifiy if this is the last chunk
  final Future<(List<MapEntry<K, V>>, bool)> Function(List<MapEntry<K, V>>)
      getter;

  /// Builder function that takes a key and returns a widget to display it.
  final Widget Function(K) widget;

  /// Optional function to run on pull to refresh
  final Future<void> Function()? onRefresh;

  /// Optional SliverAppBar to display at the top of the scroll view.
  final SliverAppBar? appBar;

  /// Optional widget displayed above the list (but below the app bar).
  final Widget? header;

  /// Optional widget shown when more items are being loaded.
  final Widget? loadingWidget;

  /// Optional widget shown during the initial load.
  final Widget? initialLoadingWidget;

  /// Optional widget shown when the list is empty and no new data is expected.
  final Widget? emptySetNotice;

  const InfiniteScrolly(
      {super.key,
      required this.getter,
      required this.widget,
      this.appBar,
      this.header,
      this.loadingWidget,
      this.initialLoadingWidget,
      this.emptySetNotice,
      this.onRefresh});

  @override
  State<InfiniteScrolly<K, V>> createState() => _InfiniteScrollyState<K, V>();
}

class _InfiniteScrollyState<K, V> extends State<InfiniteScrolly<K, V>> {
  final scrollController = ScrollController();
  List<MapEntry<K, V>> objectPairs = [];
  bool isEnd = false;
  bool isLoading = false;

  void onScroll() async {
    if (!isEnd) {
      if (scrollController.position.maxScrollExtent -
              scrollController.position.pixels <=
          scrollController.position.maxScrollExtent * 0.2) {
        if (!isLoading) {
          isLoading = true;
          if (objectPairs.isNotEmpty) {
            final returned = await widget.getter(objectPairs);
            setState(() {
              isEnd = returned.$2;
              objectPairs.addAll(returned.$1);
            });
          }
          isLoading = false;
        }
      }
    }
  }

  Future<void> onRefresh() async {
    if (widget.onRefresh != null) {
      //this can kill the widget so we must ckeck mounted
      await widget.onRefresh!();
    }
    if (mounted) {
      final returned = await widget.getter([]);
      setState(() {
        isEnd = returned.$2;
        objectPairs = returned.$1;
      });
    }
  }

  @override
  void initState() {
    scrollController.addListener(onScroll);
    widget.getter([]).then((returned) => setState(() {
          isEnd = returned.$2;
          objectPairs = returned.$1;
        }));

    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmptySet = objectPairs.isEmpty && isEnd;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: isEmptySet
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          if (widget.appBar != null) widget.appBar!,
          SliverList.builder(
              itemCount: objectPairs.length + 2,
              itemBuilder: (BuildContext context, int index) {
                // build header
                if (index == 0) {
                  return widget.header ?? SizedBox();
                }
                //normal case put cards
                if (objectPairs.isNotEmpty && index < objectPairs.length + 1) {
                  return widget.widget(objectPairs[index - 1].key);
                }
                //what to return if dataset is empty
                if (isEmptySet) {
                  return widget.emptySetNotice ??
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                              child: Text(AppLocalizations.of(context)!
                                  .nothingToSeeHere)));
                }
                //what to return if dataset is under initial load sequence
                if (!isEnd && objectPairs.isEmpty) {
                  return widget.initialLoadingWidget ??
                      const _DefaultInitialLoader();
                }
                //end of feed
                if (isEnd && objectPairs.isNotEmpty) {
                  return const SizedBox();
                }
                // new posts are loading
                return widget.loadingWidget ??
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    );
              }),
        ],
      ),
    );
  }
}
