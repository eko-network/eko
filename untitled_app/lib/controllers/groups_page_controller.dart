import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'bottom_nav_bar_controller.dart';
import '../models/group_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;

class GroupsPageController extends ChangeNotifier {
  //Cache groups = Cache(end: false, items: []);
  final BuildContext context;
  final bool reload;
  GroupsPageController({required this.context, required this.reload}) {
    _init();
  }
  void _init() {
    if (reload) {
      rebuild();
    }
  }

  void rebuild() {
    notifyListeners();
  }

  void createGroupPressed() async {
    //notifyListeners();
    context.push('/groups/create_group').then((v) {
      notifyListeners();
    });
  }

  Future<bool> onWillPop() async {
    locator<NavBarController>().goBranch(0);
    return false;
  }

  Future<PaginationGetterReturn> getGroups(dynamic time) {
    return GroupHandler().getGroups(time);
  }

  dynamic getTimeFromGroup(dynamic group) {
    return (group as Group).lastActivity;
  }
}
