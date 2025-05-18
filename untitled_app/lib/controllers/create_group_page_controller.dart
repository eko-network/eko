import 'package:flutter/material.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/constants.dart' as c;
import '../models/users.dart';
import 'dart:async';
import '../models/search_model.dart';
import 'package:go_router/go_router.dart';
import '../models/group_handler.dart';
import '../models/current_user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart'
    show Cache, PaginationGetterReturn;
import '../custom_widgets/searched_user_card.dart';

class CreateGroupPageController extends ChangeNotifier {
  String icon = '';
  final nameController = TextEditingController();
  final nameFocus = FocusNode();
  final descriptionController = TextEditingController();
  final searchTextController = TextEditingController();
  final PageController pageController = PageController();
  final selectedPeopleScroll = ScrollController();
  List<AppUser> selectedPeople = [];
  List<AppUser> hits = [];
  bool isLoading = false;
  bool showEmojiKeyboard = false;
  Timer? _debounce;
  int? selectedToDelete;
  final BuildContext context;
  bool canSwipe = false;
  final searchModel = SearchModel();
  String query = '';
  Cache searchedListData = Cache(items: [], end: false);
  bool creatingGroup = false;

  CreateGroupPageController({required this.context});
  void goForward() {
    if (nameController.text.length < c.minGroupName) {
      nameFocus.requestFocus();
      //FIXME show pop up
    } else {
      hideKeyboard();
      pageController.nextPage(
          duration: const Duration(milliseconds: c.signUpAnimationDuration),
          curve: Curves.decelerate);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    descriptionController.dispose();
    searchTextController.dispose();
    pageController.dispose();
    selectedPeopleScroll.dispose();
    super.dispose();
  }

  void _pop() {
    context.pop();
  }

  void updateCanSwipe() {
    if (nameController.text.length < c.minGroupName) {
      if (canSwipe) {
        canSwipe = false;
        notifyListeners();
      }
    } else {
      if (!canSwipe) {
        canSwipe = true;
        notifyListeners();
      }
    }
  }

  void _popTwice() {
    _pop();
    _pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void exitPressed() {
    if (selectedPeople.isEmpty &&
        icon == '' &&
        nameController.text == '' &&
        descriptionController.text == '') {
      _pop();
    } else {
      showMyDialog(
          AppLocalizations.of(context)!.exitEditProfileTitle,
          AppLocalizations.of(context)!.exitEditProfileBody,
          [
            AppLocalizations.of(context)!.exit,
            AppLocalizations.of(context)!.stay
          ],
          [_popTwice, _popDialog],
          context);
    }
  }

  void goBack() {
    hideKeyboard();
    pageController.previousPage(
        duration: const Duration(milliseconds: c.signUpAnimationDuration),
        curve: Curves.decelerate);
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
    return false;
  }

  Widget groupSearchPageBuilder(dynamic uid) {
    return UserCard(
      uid: uid,
      groupSearch: true,
      adder: addRemovePersonToList,
    );
  }

  void addRemovePersonToList(dynamic user, bool add) {
    if (add) {
      selectedPeople.add(user);
      Timer(const Duration(milliseconds: 50), () {
        selectedPeopleScroll.animateTo(
          selectedPeopleScroll.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
        );
      });
    } else {
      selectedPeople.removeWhere((element) => element.uid == user.uid);
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

  void createGroup() async {
    if (!creatingGroup) {
      creatingGroup = true;
      List<String> members = (selectedPeople.map((e) => e.uid).toList());
      members.insert(0, locator<CurrentUser>().getUID());
      final newGroup = Group(
        icon: icon,
        description: descriptionController.text,
        name: nameController.text,
        createdOn: DateTime.now().toUtc().toIso8601String(),
        lastActivity: DateTime.now().toUtc().toIso8601String(),
        members: members,
        notSeen: [],
      );
      newGroup.id = await GroupHandler().createGroup(newGroup);
      creatingGroup = false;
      context.pop();
    }
  }

  void pickEmoji() {
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
}
