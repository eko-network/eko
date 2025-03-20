import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../controllers/groups_page_controller.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/group_card.dart';
import '../utilities/constants.dart' as c;
//import 'package:cloud_firestore/cloud_firestore.dart';

// void addTagToDocuments() async {
//   final collection = FirebaseFirestore.instance.collection('posts');
//   final snapshots = collection.snapshots();

//   snapshots.listen((snapshot) {
//     snapshot.docs.forEach((doc) {
//       print(doc.id);
//       doc.reference.update({'tags': ['public']});
//       doc.reference.update({'tag': FieldValue.delete()});
//     });
//   });
// }

class GroupsPage extends StatelessWidget {
  final bool reload;
  const GroupsPage({super.key, this.reload = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupsPageController(context: context, reload:reload),
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) =>
              Provider.of<GroupsPageController>(context, listen: false)
                  .onWillPop(),
          child: Scaffold(
            body: PaginationPage(
              externalData: locator<FeedPostCache>().groupsCache,
              getter: Provider.of<GroupsPageController>(context, listen: true)
                  .getGroups,
              card: groupCardBuilder,
              startAfterQuery:
                  Provider.of<GroupsPageController>(context, listen: false)
                      .getTimeFromGroup,
              appbar: SliverAppBar(
                title: Text(AppLocalizations.of(context)!.groups, style: TextStyle(fontSize: 20),),
                centerTitle: true,
                floating: true,
                pinned: false,
                scrolledUnderElevation: 0.0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                actions: [
                  IconButton(
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () => Provider.of<GroupsPageController>(context,
                            listen: false)
                        .createGroupPressed(),
                    icon: const Icon(Icons.group_add, size: 20,),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: Divider(
                    color: Theme.of(context).colorScheme.outline,
                    height: c.dividerWidth,
                  ),
                ),
              ),
              //header: const _Header(),
            ),
          ),
        );
      },
    );
  }
}
