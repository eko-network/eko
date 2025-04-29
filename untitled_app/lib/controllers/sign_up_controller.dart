import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../custom_widgets/error_snack_bar.dart';
import '../utilities/constants.dart' as c;
import '../utilities/locator.dart';
import '../models/current_user.dart';

import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

// TODO add presubmission error checking
class SignUpController extends ChangeNotifier {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final yearController = TextEditingController();

  final nameFocus = FocusNode();
  final usernameFocus = FocusNode();
  final dobFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final passwordConfirmFocus = FocusNode();

  final keyFocus = FocusNode();

  final monthFocus = FocusNode();
  final dayFocus = FocusNode();
  final yearFocus = FocusNode();

  final pageController = PageController();
  final BuildContext context;

  final format = DateFormat('MM/dd/yyyy');

  bool availableUsername = false;
  bool validUsername = false;
  bool isChecking = false;
  bool firstPage = true;
  bool lastPage = false;
  bool loggingIn = false;
  bool goodPassword = false;
  double passwordPercent = 0;
  Timer? _debounce;
  List<String> passed = ['❌', '❌', '❌', '❌', '❌', '❌'];

  SignUpController({required this.context}) {
    // monthController.addListener(onMonthChanged);
    // yearController.addListener(onYearChanged);
    // dayController.addListener(onDayChanged);
  }

  @override
  void dispose() {
    keyFocus.dispose();

    // monthController.removeListener(onMonthChanged);
    // yearController.removeListener(onYearChanged);
    // dayController.removeListener(onDayChanged);

    nameController.dispose();
    usernameController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    nameFocus.dispose();
    usernameFocus.dispose();
    dobFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    passwordConfirmFocus.dispose();

    monthFocus.dispose();
    yearFocus.dispose();
    dayFocus.dispose();

    monthController.dispose();
    yearController.dispose();
    dayController.dispose();

    pageController.dispose();
    super.dispose();
  }

  // String? validateYear(String? s) {
  //   final now = DateTime.now();
  //   final currentYear = now.year;
  //   final year = int.parse(s ?? '1');
  //   if (year > currentYear || year < 1000) return "";
  //   return null;
  // }
  void formatTime(DateTime? birthday) {
    if (birthday != null) {
      final birthdyString = format.format(birthday);
      final birthdaylist = birthdyString.split('/');
      monthController.text = birthdaylist[0];
      dayController.text = birthdaylist[1];
      yearController.text = birthdaylist[2];
    }
  }

  void onKey(RawKeyEvent event) {
    if (monthFocus.hasFocus) {
      if (monthController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        dayFocus.requestFocus();
        dayController.text = event.character ?? '';
      }
    } else if (dayFocus.hasFocus) {
      if (dayController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        yearFocus.requestFocus();
        yearController.text = event.character ?? '';
      } else if (event.logicalKey.keyLabel == 'Backspace' &&
          dayController.text.isEmpty) {
        monthFocus.requestFocus();
      }
    } else if (yearFocus.hasFocus) {
      if (event.logicalKey.keyLabel == 'Backspace' &&
          yearController.text.isEmpty) {
        dayFocus.requestFocus();
      }
    }
  }

  // void onMonthChanged() {
  //   print("test");
  //   if (monthController.text.length == 2) {
  //     dayFocus.requestFocus();
  //   }
  // }

  // void onDayChanged() {
  //   if (dayController.text.length == 2) {
  //     yearFocus.requestFocus();
  //   }
  // }

  // void onYearChanged() {}

  passwordChanged() {
    passed = ['❌', '❌', '❌', '❌', '❌', '❌'];
    int points = 0;
    String pass1 = passwordController.text;
    String pass2 = passwordConfirmController.text;
    if ((pass1).length >= 7 && (pass1).length <= 32) {
      points++;
      passed[0] = '✅';
    }
    if (pass1.contains(RegExp(r'[a-z]'))) {
      points++;
      passed[1] = '✅';
    }
    if (pass1.contains(RegExp(r'[A-Z]'))) {
      points++;
      passed[2] = '✅';
    }

    if (pass1.contains(RegExp(r'[0-9]'))) {
      points++;
      passed[3] = '✅';
    }
    if (!pass1.contains(RegExp(r'^[A-Za-z0-9]*$'))) {
      points++;
      passed[4] = '✅';
    }
    if (pass1 == pass2 && pass1 != '') {
      points++;
      passed[5] = '✅';
    }
    goodPassword = (points == 6);
    if (pass1 != '') {
      passwordPercent = points / 6;
    } else {
      passwordPercent = 0;
    }
    notifyListeners();
  }

  void _pop() {
    context.pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _returnToWelcome() {
    _pop();
    context.go('/');
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showUserNameReqs() {
    showMyDialog(
        AppLocalizations.of(context)!.invalidUserName,
        AppLocalizations.of(context)!.usernameReqs,
        [AppLocalizations.of(context)!.ok],
        [_popDialog],
        context);
  }

  void keyboardGoToNextPage() async {
    await forwardPressed();
    Future.delayed(const Duration(milliseconds: 100),
        () => passwordFocus.requestFocus()); //waits for keyboard to close

    //focus1.requestFocus();
  }

  void _popAndGoBack() {
    _pop();
    backPressed();
    usernameFocus.requestFocus();
  }

  bool _handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return true;
      case 'username-taken':
        showMyDialog(
            AppLocalizations.of(context)!.usernameTakenTitle,
            AppLocalizations.of(context)!.usernameTakenBody,
            [AppLocalizations.of(context)!.goBack],
            [_popAndGoBack],
            context);
        break;
      case 'invalid-email':
        showMyDialog(
            AppLocalizations.of(context)!.invalidEmailTittle,
            AppLocalizations.of(context)!.invalidEmailBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        break;
      case 'weak-password':
        showMyDialog(
            AppLocalizations.of(context)!.weakPasswordTitle,
            AppLocalizations.of(context)!.weakPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        break;
      case 'email-already-in-use':
        showMyDialog(
            AppLocalizations.of(context)!.emailAlreadyInUseTitle,
            AppLocalizations.of(context)!.emailAlreadyInUseBody,
            [
              AppLocalizations.of(context)!.logIn,
              AppLocalizations.of(context)!.tryAgain
            ],
            [_returnToWelcome, _popDialog],
            context);
        break;
      default:
        showMyDialog(
            AppLocalizations.of(context)!.defaultErrorTittle,
            AppLocalizations.of(context)!.defaultErrorBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        break;
    }
    return false;
  }

  void onUsernameChanged(String s) {
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
      if (s != '') {
        // TODO
        // availableUsername = await locator<CurrentUser>()
        //     .isUsernameAvailable(usernameController.text.trim());

        isChecking = false;
        notifyListeners();
      }
    });
  }

  signUpPressed() async {
    hideKeyboard();

    if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      if (goodPassword ||
          (passwordController.text == 'password' && kDebugMode)) {
        loggingIn = true;
        notifyListeners();
        locator<CurrentUser>().email = emailController.text.trim();
        locator<CurrentUser>().username = usernameController.text.trim();
        locator<CurrentUser>().name = nameController.text.trim();

//TODO
        // if (await locator<CurrentUser>()
        //     .isUsernameAvailable(usernameController.text.trim())) {
        //   if (_handleError(
        //       await locator<CurrentUser>().signUp(passwordController.text))) {
        //     locator<CurrentUser>().addUserDataToFirestore();
        //   }
        // } else {
        //   _handleError('username-taken');
        // }

        loggingIn = false;
        notifyListeners();
      } else {
        _handleError('weak-password');
      }
    }
  }

  void backPressed() async {
    hideKeyboard();
    if (pageController.page != 0.0) {
      await pageController.previousPage(
          duration: const Duration(milliseconds: c.signUpAnimationDuration),
          curve: Curves.decelerate);
    } else {
      showMyDialog(
          AppLocalizations.of(context)!.exitCreateAccountTitle,
          AppLocalizations.of(context)!.exitCreateAccountBody,
          [
            AppLocalizations.of(context)!.goBack,
            AppLocalizations.of(context)!.stay
          ],
          [_returnToWelcome, _popDialog],
          context);
    }
  }

  DateTime? getDateTime() {
    try {
      // Parse the date string using the specified format
      // if (dayController.text.isEmpty ||
      //     monthController.text.isEmpty ||
      //     yearController.text.isEmpty) {
      //   return null;
      // }

      final day = int.tryParse(dayController.text);
      final month = int.tryParse(monthController.text);
      final year = int.tryParse(yearController.text);

      if (day == null || month == null || year == null) {
        // Invalid numeric values, return null
        return null;
      }

      if (1 > day || day > 31) {
        return null;
      }

      if (1 > month || month > 12) {
        return null;
      }

      if (1900 > year || year > DateTime.now().year) {
        return null;
      }

      // Create a DateTime object
      return DateTime(year, month, day);
    } catch (e) {
      // Parsing error, return null
      return null;
    }
  }

  forwardPressed() async {
    hideKeyboard();
    int page = pageController.page!.toInt();

    final birthday = getDateTime();
    if (birthday != null) {
      if (birthday.compareTo(
              DateTime.now().subtract(const Duration(hours: 13 * 365))) >=
          0) {
        //too young
        showMyDialog(
            AppLocalizations.of(context)!.tooYoungTitle,
            AppLocalizations.of(context)!.tooYoungBody,
            [AppLocalizations.of(context)!.ok],
            [_popDialog],
            context);
        return 'done';
      }
    } else {
//invalid
      showMyDialog(
          AppLocalizations.of(context)!.invalidBirthdayTitle,
          AppLocalizations.of(context)!.invalidBirthdayBody,
          [AppLocalizations.of(context)!.ok],
          [_popDialog],
          context);
      return 'done';
    }

    // Request focus for the empty field
    if (nameController.text == '') {
      nameFocus.requestFocus();
    } else if (nameController.text.length > c.maxNameChars) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
      nameFocus.requestFocus();
    } else if (!validUsername || isChecking || !availableUsername) {
      usernameFocus.requestFocus();
    } else if (emailController.text == '') {
      emailFocus.requestFocus();
    } else if (page == 0) {
      //_getPageData(page);
      //_setPageData(page + 1);
      await pageController.nextPage(
          duration: const Duration(milliseconds: c.signUpAnimationDuration),
          curve: Curves.decelerate);
    }
    return 'done';
  }
}
