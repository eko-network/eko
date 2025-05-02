import 'package:flutter/material.dart';
import '../utilities/locator.dart';
import '../models/current_user.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;
import 'dart:async';

class EditProfileController extends ChangeNotifier {
  String profileImage = locator<CurrentUser>().profilePicture;
  File? newProfileImage;

  //String profileBio = locator<CurrentUser>().bio;
  final BuildContext context;
  bool showSave = false;
  final bioController = TextEditingController(text: locator<CurrentUser>().bio);
  // final bioFocus = FocusNode();
  // int bioNewLines = '\n'.allMatches(locator<CurrentUser>().bio).length;
  // int bioBodyChars = locator<CurrentUser>().bio.length;

  final nameController =
      TextEditingController(text: locator<CurrentUser>().name);
  // final nameFocus = FocusNode();
  // int bioNameBodyChars = locator<CurrentUser>().bioName.length;

  final usernameController =
      TextEditingController(text: locator<CurrentUser>().username);
  final usernameFocus = FocusNode();

  bool availableUsername = true;
  bool validUsername = true;
  bool isChecking = false;
  Timer? _debounce;

  int titleChars = 0;
  bool showBioCounts = false;
  bool showBioNameCounts = false;
  EditProfileController({required this.context});
  editProfileImagePressed() async {
    newProfileImage = await locator<CurrentUser>().setPreviewProfileImage();
    if (newProfileImage != null) {
      checkChanges();
      notifyListeners();
    }
  }

  hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocus.dispose();
    bioController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void checkChanges() {
    if (locator<CurrentUser>().name != nameController.text ||
        locator<CurrentUser>().bio != bioController.text ||
        newProfileImage != null) {
      showSave = true;
      notifyListeners();
    } else {
      showSave = false;
      notifyListeners();
    }
  }

  void _pop() {
    if (context.mounted) {
      context.pop();
    }
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _popTwice() {
    _pop();
    _pop();
  }

  void _showLoadingDialog() {
    showLoadingDialog(context);
  }

  void showWarning() {
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

  void exitPressed() {
    if (showSave) {
      showWarning();
    } else {
      _pop();
    }
  }

//FIXME optomize
  void savePressed() async {
    bool shouldPop = true;
    if (locator<CurrentUser>().name != nameController.text) {
      await _saveNameData(nameController.text);
    }
    if (locator<CurrentUser>().bio != bioController.text) {
      await _saveBioData(bioController.text);
    }
    //TODO
    // if (locator<CurrentUser>().username != usernameController.text.trim()) {
    //   if (await locator<CurrentUser>()
    //       .isUsernameAvailable(usernameController.text.trim())) {
    //     await _saveUsernameData(usernameController.text.trim());
    //   } else {
    //     shouldPop = false;
    //     usernameTakenDialog();
    //   }
    // }
    if (newProfileImage != null) {
      _showLoadingDialog();
      await locator<CurrentUser>().uploadProfilePicture(newProfileImage!);
      _pop();
    }
    if (shouldPop) {
      _pop();
    }
  }

  void showUserNameReqs() {
    showMyDialog(
        AppLocalizations.of(context)!.invalidUserName,
        AppLocalizations.of(context)!.usernameReqs,
        [AppLocalizations.of(context)!.ok],
        [_popDialog],
        context);
  }

  void usernameTakenDialog() {
    showMyDialog(
        AppLocalizations.of(context)!.usernameTakenTitle,
        AppLocalizations.of(context)!.usernameTakenBody,
        [AppLocalizations.of(context)!.goBack],
        [_popDialog],
        context);
  }

  // showCountsBio(bool show) {
  //   showBioCounts = show;
  //   if (!show) {
  //     bioFocus.unfocus();
  //   }
  //   notifyListeners();
  // }

  // showCountsName(bool show) {
  //   showBioNameCounts = show;
  //   if (!show) {
  //     nameFocus.unfocus();
  //   }
  //   notifyListeners();
  // }

  Future<void> _saveBioData(String bio) async {
    // TODO: This will eventually need to upload all the data that changed as profile editing gets larger
    // Im thinking a 'save' and 'cancel' button pops up on the app bar is an edit is detected
    if (await locator<CurrentUser>().uploadProfileBio(bio) == 'success') {
      locator<CurrentUser>().bio = bio;
    }
  }

  Future<void> _saveNameData(String name) async {
    if (await locator<CurrentUser>().uploadProfileName(name) == 'success') {
      locator<CurrentUser>().name = name;
    }
  }

  Future<void> _saveUsernameData(String username) async {
    if (await locator<CurrentUser>().uploadProfileUsername(username) ==
        'success') {
      locator<CurrentUser>().username = username;
    }
  }

  void onUsernameChanged(String s) {
    showSave = false;
    if (!s.trim().contains(RegExp(c.userNameReqs))) {
      validUsername = false;
      notifyListeners();
    } else {
      validUsername = true;
      isChecking = true;
      notifyListeners();
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: c.searchPageDebounce), () async {
      //TODO
      // if (s != '') {
      //   if (s == locator<CurrentUser>().username) {
      //     availableUsername = true;
      //   } else {
      //     availableUsername = await locator<CurrentUser>()
      //         .isUsernameAvailable(usernameController.text.trim());
      //   }
      //   isChecking = false;
      //   notifyListeners();
      // }
    });
    if (locator<CurrentUser>().username != usernameController.text.trim() &&
        validUsername == true) {
      showSave = true;
    }
  }
}
