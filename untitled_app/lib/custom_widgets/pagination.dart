import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'controllers/pagination_controller.dart';
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

class PaginationPage extends StatelessWidget {
  final Future<PaginationGetterReturn> Function(dynamic) getter;
  final dynamic Function(dynamic) startAfterQuery;
  final Function()? extraRefresh;
  final Widget Function(dynamic) card;
  final Widget? header;
  final Widget? emptySetNotice;
  final Widget? loadingWidget;
  final Widget? initialLoadingWidget;

  final bool shrinkWrap;
  final SliverAppBar? appbar;
  final Cache? externalData;
  //final bool forceLoadingState;
  const PaginationPage({
    super.key,
    this.externalData,
    this.shrinkWrap = false,
    required this.getter,
    //this.forceLoadingState = false,
    required this.card,
    this.appbar,
    this.extraRefresh,
    this.header,
    required this.startAfterQuery,
    this.emptySetNotice,
    this.initialLoadingWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return prov.ChangeNotifierProvider.value(
      value: PaginationController(
        //hasAppbar: (appbar != null),
        externalData: externalData,
        extraRefresh: extraRefresh,
        getter: getter,
        context: context,
        startAfterQuery: startAfterQuery,
      ),
      builder: (context, child) {
        return RefreshIndicator(
          child: CustomScrollView(
            shrinkWrap: shrinkWrap,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics:
                ((!prov.Provider.of<PaginationController>(context, listen: true)
                            .data
                            .end) &&
                        prov.Provider.of<PaginationController>(context,
                                listen: true)
                            .data
                            .items
                            .isEmpty)
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
            controller:
                prov.Provider.of<PaginationController>(context, listen: false)
                    .scrollController,
            slivers: [
              if (appbar != null) appbar!,
              // if(appbar != null) SliverToBoxAdapter(child: SizedBox(height:40, child:Text("test")),),
              // const SliverAppBar(
              //   title: Text("test"),
              //   floating: true,
              //   pinned: false,
              // ),
              // if ((!prov.Provider.of<PaginationController>(context, listen: true)
              //         .data
              //         .end) &&
              //     prov.Provider.of<PaginationController>(context, listen: true)
              //         .data
              //         .items
              //         .isEmpty)
              //   SizedBox()
              // else
              SliverList.builder(
                itemCount: prov.Provider.of<PaginationController>(context,
                            listen: true)
                        .data
                        .items
                        .length +
                    2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    //build header
                    return header ?? const SizedBox();
                  } else if (prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .items
                          .isNotEmpty &&
                      index <
                          prov.Provider.of<PaginationController>(context, listen: true)
                                  .data
                                  .items
                                  .length +
                              1) {
                    //normal case put cards
                    return card(prov.Provider.of<PaginationController>(context,
                            listen: true)
                        .data
                        .items[index - 1]);
                  } else if (prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .end &&
                      prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .items
                          .isEmpty) {
                    //what to return if dataset is empty
                    return emptySetNotice ??
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(
                                child: Text(AppLocalizations.of(context)!
                                    .nothingToSeeHere)));
                  } else if ((!prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .end) &&
                      prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .items
                          .isEmpty) {
                    //what to return if dataset is under initial load sequence
                    return initialLoadingWidget ??
                        const _DefaultInitialLoader();
                  } else if (prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .end &&
                      prov.Provider.of<PaginationController>(context, listen: true)
                          .data
                          .items
                          .isNotEmpty) {
                    //end of feed
                    return const SizedBox();
                  } else {
                    // new posts are loading
                    return loadingWidget ??
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(),
                          ),
                        );
                  }
                },
              ),
            ],
          ),
          onRefresh: () =>
              prov.Provider.of<PaginationController>(context, listen: false)
                  .onRefresh(),
        );
      },
    );
  }
}
