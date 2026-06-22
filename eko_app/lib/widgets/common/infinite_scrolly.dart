import 'package:flutter/material.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/widgets/common/max_width_content.dart';

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

// /// A widget that enables infinite scrolling through a list of items.
// ///
// /// [InfiniteScrolly] fetches items in chunks using the provided [getter] function
// /// and displays each item using the [widget] builder. It supports optional
// /// customizations such as a [SliverAppBar], headers, loading indicators, and
// /// an empty-state widget.
// ///
// /// Type parameters:
// /// - [K]: The type of the key in each item. In our architecture this is the object
// ///			passed to the providers build method.
// /// - [V]: The type of the value that a provider would return. This is essential
// /// -		for proper sorting.

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

  /// Optional controller
  final ScrollController? controller;

  const InfiniteScrolly({
    super.key,
    required this.getter,
    required this.widget,
    this.appBar,
    this.controller,
    this.header,
    this.loadingWidget,
    this.initialLoadingWidget,
    this.emptySetNotice,
    this.onRefresh,
  });

  @override
  State<InfiniteScrolly<K, V>> createState() => _InfiniteScrollyState<K, V>();
}

class _InfiniteScrollyState<K, V> extends State<InfiniteScrolly<K, V>> {
  List<MapEntry<K, V>> objectPairs = [];
  bool isEnd = false;
  bool isLoading = false;

  Future<void> onScroll() async {
    final returned = await widget.getter(objectPairs);
    setState(() {
      isEnd = returned.$2;
      objectPairs.addAll(returned.$1);
    });
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
  Widget build(BuildContext context) {
    return InfiniteScrollyCore<K>(
      appBar: widget.appBar,
      header: widget.header,
      initialLoadingWidget: widget.initialLoadingWidget,
      onRefresh: onRefresh,
      getter: onScroll,
      widget: widget.widget,
      list: objectPairs.map((item) => item.key).toList(),
      isEnd: isEnd,
      controller: widget.controller,
      loadingWidget: widget.loadingWidget,
    );
  }
}

class InfiniteScrollyCore<T> extends StatefulWidget {
  final Future<void> Function() getter;

  /// Builder function that takes a key and returns a widget to display it.
  final Widget Function(T) widget;

  // The data to display
  final List<T> list;

  // if there is no more data
  final bool isEnd;

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

  /// Optional controller
  final ScrollController? controller;

  const InfiniteScrollyCore({
    super.key,
    required this.getter,
    required this.widget,
    required this.list,
    required this.isEnd,
    this.onRefresh,
    this.appBar,
    this.header,
    this.loadingWidget,
    this.initialLoadingWidget,
    this.emptySetNotice,
    this.controller,
  });

  @override
  State<InfiniteScrollyCore<T>> createState() => _InfiniteScrollyCore<T>();
}

class _InfiniteScrollyCore<T> extends State<InfiniteScrollyCore<T>> {
  static const double _loadMoreTriggerDistance = 200;
  static const double _autoTopupScrollTolerance = 32;
  late final ScrollController scrollController;
  bool isLoading = false;

  Future<void> _loadMore() async {
    if (widget.isEnd || isLoading) return;
    isLoading = true;
    try {
      await widget.getter();
    } finally {
      isLoading = false;
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      if (!widget.isEnd &&
          scrollController.position.maxScrollExtent <=
              _autoTopupScrollTolerance) {
        _loadMore();
      }
    });
  }

  void onScroll() {
    if (widget.isEnd) return;
    final pos = scrollController.position;
    if (pos.maxScrollExtent - pos.pixels <= _loadMoreTriggerDistance) {
      _loadMore();
    }
  }

  @override
  void initState() {
    scrollController = widget.controller ?? ScrollController();
    if (widget.list.isEmpty && !widget.isEnd) {
      _loadMore();
    }
    scrollController.addListener(onScroll);
    super.initState();
  }

  @override
  void didUpdateWidget(InfiniteScrollyCore<T> oldWidget) {
    // retrigger the loading if the widget already exists, but was cleared
    // this may happen, for example, in an indexed stack
    super.didUpdateWidget(oldWidget);
    if (widget.list.isEmpty && !widget.isEnd) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    if (widget.controller == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmptySet = widget.list.isEmpty && widget.isEnd;
    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: CustomScrollView(
        // shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          if (widget.appBar != null) widget.appBar!,
          SliverList.builder(
            itemCount: widget.list.length + 2,
            itemBuilder: (BuildContext context, int index) {
              // build header
              if (index == 0) {
                return widget.header == null
                    ? const SizedBox()
                    : MaxWidthContent(child: widget.header!);
              }
              //normal case put cards
              if (widget.list.isNotEmpty && index < widget.list.length + 1) {
                return MaxWidthContent(
                  child: widget.widget(widget.list[index - 1]),
                );
              }
              //what to return if dataset is empty
              if (isEmptySet) {
                return MaxWidthContent(
                  child:
                      widget.emptySetNotice ??
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.nothingToSeeHere,
                          ),
                        ),
                      ),
                );
              }
              //what to return if dataset is under initial load sequence
              if (!widget.isEnd && widget.list.isEmpty) {
                return MaxWidthContent(
                  child:
                      widget.initialLoadingWidget ??
                      const _DefaultInitialLoader(),
                );
              }
              //end of feed
              if (widget.isEnd && widget.list.isNotEmpty) {
                return const MaxWidthContent(child: SizedBox());
              }
              // new posts are loading
              return MaxWidthContent(
                child:
                    widget.loadingWidget ??
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    ),
              );
            },
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
