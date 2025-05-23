import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/group_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../utilities/locator.dart';
import '../models/post_handler.dart';
import 'package:go_router/go_router.dart';

class SubGroupController extends ChangeNotifier {
  Group? group;
  final String id;
  final BuildContext context;
  bool groupNotFound = false;
  bool notInGroup = false;
  SubGroupController({
    required this.context,
    required this.id,
  }) {
    _init();
  }
  // @override
  // void dispose() {
  //   print("trying to kill");
  // }

  Future<void> _init() async {
    group ??= await GroupHandler()
        .getGroupFromId(id); //FIXME might break if opening deleted group
    // builtFromID = true;
    // post!.hasCache = true;

    if (group == null) {
      final readGroup = await GroupHandler().getGroupFromId(id);
      if (readGroup != null) {
        if (readGroup.members.contains(locator<CurrentUser>().getUID())) {
          group = readGroup;
        } else {
          notInGroup = true;
        }
      } else {
        groupNotFound = true;
      }
    }
    notifyListeners();
    if (group != null) {
      if (group!.notSeen.contains(locator<CurrentUser>().getUID())) {
        final firestore = FirebaseFirestore.instance;
        group!.notSeen.removeWhere((element) {
          return element == locator<CurrentUser>().getUID();
        });
        await firestore.collection('groups').doc(group!.id).update(
          {
            'notSeen': FieldValue.arrayRemove([locator<CurrentUser>().getUID()])
          },
        );
      }
    }
  }

  Future<PaginationGetterReturn> getGroupPosts(dynamic time) {
    return locator<PostsHandling>().getGroupPosts(time, id);
  }

  dynamic getTimeFromPost(dynamic post) {
    return locator<PostsHandling>().getTimeFromPost(post);
  }

  void addPost() {
    context.go('/compose', extra: group);
  }

  void editGroup() {
    context.push('/groups/sub_group/${group?.id}/edit_group', extra: group);
  }
}
