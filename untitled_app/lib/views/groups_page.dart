import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/group_handler.dart';
// import '../controllers/groups_page_controller.dart';
import '../custom_widgets/controllers/pagination_controller.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/group_card.dart';
import '../utilities/constants.dart' as c;

class GroupsPage extends StatefulWidget {
  final bool reload;
  const GroupsPage({super.key, this.reload = false});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.reload) {
      // Force rebuild if needed
      setState(() {});
    }
  }

  void createGroupPressed() {
    context.push('/groups/create_group').then((v) {
      setState(() {});
    });
  }

  Future<PaginationGetterReturn> getGroups(dynamic time) {
    return GroupHandler().getGroups(time);
  }

  dynamic getTimeFromGroup(dynamic group) {
    return (group as Group).lastActivity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginationPage(
        getter: getGroups,
        card: groupCardBuilder,
        startAfterQuery: getTimeFromGroup,
        appbar: SliverAppBar(
          title: Text(
            AppLocalizations.of(context)!.groups,
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
          floating: true,
          pinned: false,
          scrolledUnderElevation: 0.0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => createGroupPressed(),
              icon: const Icon(
                Icons.group_add,
                size: 20,
              ),
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
      ),
    );
  }
}
