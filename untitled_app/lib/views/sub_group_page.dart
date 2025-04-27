import 'package:flutter/material.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../models/group_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as prov;
import '../controllers/sub_group_controller.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/post_card.dart';
import '../utilities/constants.dart' as c;

class SubGroupPage extends StatelessWidget {
  final Group? group;
  final String id;
  const SubGroupPage({super.key, required this.group, required this.id});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return prov.ChangeNotifierProvider(
      create: (context) =>
          SubGroupController(passedGroup: group, context: context, id: id),
      builder: (context, child) {
        return Scaffold(
          floatingActionButton: SizedBox(
            width: 70,
            child: FloatingActionButton.large(
              heroTag: null,
              onPressed: () =>
                  prov.Provider.of<SubGroupController>(context, listen: false)
                      .addPost(),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 40),
            ),
          ),
          body: (prov.Provider.of<SubGroupController>(context, listen: true)
                      .groupNotFound ||
                  prov.Provider.of<SubGroupController>(context, listen: true)
                      .notInGroup)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.8,
                        child: Text(
                          (prov.Provider.of<SubGroupController>(context,
                                      listen: true)
                                  .groupNotFound)
                              ? AppLocalizations.of(context)!.groupNotFound
                              : AppLocalizations.of(context)!.notInGroup,
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
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
                )
              : (prov.Provider.of<SubGroupController>(context, listen: true)
                          .group ==
                      null)
                  ? const Center(child: LoadingSpinner())
                  : PaginationPage(
                      appbar: SliverAppBar(
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                        ),
                        actions: [
                          IconButton(
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () =>
                                prov.Provider.of<SubGroupController>(context,
                                        listen: false)
                                    .editGroup(),
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
                            if (prov.Provider.of<SubGroupController>(context,
                                        listen: true)
                                    .group!
                                    .icon !=
                                '')
                              SizedBox(
                                width: width * 0.13,
                                height: width * 0.13,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    prov.Provider.of<SubGroupController>(
                                            context,
                                            listen: true)
                                        .group!
                                        .icon,
                                  ),
                                ),
                              ),
                            SizedBox(
                                width: width * 0.4,
                                child: Text(
                                    prov.Provider.of<SubGroupController>(
                                            context,
                                            listen: true)
                                        .group!
                                        .name,
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
                      ),
                      //header: const _Header(),
                      getter: prov.Provider.of<SubGroupController>(context,
                              listen: false)
                          .getGroupPosts,
                      card: postCardBuilder,
                      startAfterQuery: prov.Provider.of<SubGroupController>(
                              context,
                              listen: false)
                          .getTimeFromPost,
                      initialLoadingWidget: const FeedLoader(),
                    ),
        );
      },
    );
  }
}
