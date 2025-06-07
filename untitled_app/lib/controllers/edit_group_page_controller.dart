import 'package:flutter/material.dart';
import 'package:untitled_app/widgets/user_card.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../custom_widgets/controllers/pagination_controller.dart';
import '../utilities/constants.dart' as c;
import '../models/users.dart';
import 'dart:async';
import '../models/search_model.dart';
import 'package:go_router/go_router.dart';
import '../models/group_handler.dart';
import '../models/current_user.dart';

class EditGroupPageController extends ChangeNotifier {
  String icon = '';
  final searchTextController = TextEditingController();
  final PageController pageController = PageController();
  final selectedPeopleScroll = ScrollController();
  List<AppUser> selectedPeople = [];
  List<AppUser> hits = [];
  List<AppUser> membersList = [];
  List<AppUser> addedMembers = [];
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  Timer? _debounce;
  int? selectedToDelete;
  final BuildContext context;
  bool canSwipe = false;
  Cache searchedListData = Cache(items: [], end: false);
  String query = '';
  Group group;
  final searchModel = SearchModel();
  EditGroupPageController({required this.context, required this.group}) {
    init();
  }

  init() async {
    for (var uid in group.members) {
      AppUser user = AppUser();
      Map<String, dynamic>? userData = await user.readUserData(uid);
      if (userData != null) {
        membersList.add(AppUser.fromJson(userData));
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    pageController.dispose();
    selectedPeopleScroll.dispose();
    super.dispose();
  }

  void goForward() {
    pageController.nextPage(
        duration: const Duration(milliseconds: c.signUpAnimationDuration),
        curve: Curves.decelerate);
  }

  void goBack({bool? didPop}) {
    didPop ??= false;
    hideKeyboard();
    if (pageController.page != 0.0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: c.signUpAnimationDuration),
          curve: Curves.decelerate);
    } else if (!didPop) {
      context.pop();
    }
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<PaginationGetterReturn> getter(dynamic page) async {
    if (isLoading) {
      //forces loading animation
      return PaginationGetterReturn(end: false, payload: []);
    } else {
      page = page ?? 0;
      return searchModel.getter(page, query, true);
    }
  }

  Widget groupSearchPageBuilder(dynamic uid) {
    return UserCard(
      uid: uid,
      groupSearch: true,
      adder: addRemovePersonToList,
    );
  }

  dynamic startAfterQuery(dynamic lastUser) {
    return searchModel.startAfterQuery(lastUser);
  }

  void onSearchTextChanged(String s) async {
    isLoading = true;
    searchedListData.end = false;
    searchedListData.items = [];
    notifyListeners();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: c.searchPageDebounce),
      () async {
        query = s;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  bool isUserSelected(AppUser user) {
    for (AppUser slectedUser in selectedPeople) {
      if (user.uid == slectedUser.uid) {
        return true;
      }
    }
    for (AppUser slectedUser in membersList) {
      if (user.uid == slectedUser.uid) {
        return true;
      }
    }
    return false;
  }

  void addRemovePersonToList(dynamic user, bool add) {
    if (add) {
      selectedPeople.add(user);
      addedMembers.add(user);
      Timer(const Duration(milliseconds: 50), () {
        selectedPeopleScroll.animateTo(
          selectedPeopleScroll.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      });
    } else {
      if (addedMembers.contains(user)) {
        selectedPeople.removeWhere((element) => element.uid == user.uid);
      }
    }
    notifyListeners();
  }

  void setSelectedToDelete(int index) {
    if (index == selectedToDelete) {
      selectedPeople
          .removeWhere((element) => element.uid == selectedPeople[index].uid);
      selectedToDelete = null;
    } else {
      selectedToDelete = index;
    }
    notifyListeners();
  }

  void initializeSearch() {
    selectedPeople = [...addedMembers];
  }

  void updateGroupMembers() {
    pageController.previousPage(
        duration: Duration(milliseconds: 200), curve: Curves.decelerate);
    membersList.addAll(selectedPeople);
    List<String> members = (membersList.map((e) => e.uid).toList());
    group.members = members;
    GroupHandler().updateGroupMembers(group, members);
    notifyListeners();
  }

  void pickEmoji() async {
    context.pushNamed('pick_emoji', extra: _setIcon);
  }

  void _setIcon(String returnedString) {
    if (returnedString != '') icon = returnedString;
    notifyListeners();
  }

  void clearIcon() {
    icon = '';
    notifyListeners();
  }

  void _pop() {
    context.pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _leaveGroup() async {
    context.pop();
    showLoadingDialog(context);

    membersList
        .removeWhere((user) => user.uid == locator<CurrentUser>().getUID());
    List<String> members = (membersList.map((e) => e.uid).toList());
    _pop();
    //context.go("/groups", extra: true);
    if (members.isNotEmpty) {
      GroupHandler().updateGroupMembers(group, members);
    } else {
      // JUST REMOVED THIS, IDK WHAT IT DOES
      // locator<PostsHandling>().deleteData('groups/${group.id}');
    }
    context.go('/groups', extra: true);
  }

  void leaveGroup() {
    showMyDialog(
        AppLocalizations.of(context)!.leaveGroupWarningTitle,
        AppLocalizations.of(context)!.leaveGroupWarningTitle,
        [
          AppLocalizations.of(context)!.cancel,
          AppLocalizations.of(context)!.exit
        ],
        [_popDialog, _leaveGroup],
        context);

    // TODO: needs to reload the groups page
  }
}
