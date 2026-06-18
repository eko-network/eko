import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('id'),
  ];

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// No description provided for @addText.
  ///
  /// In en, this message translates to:
  /// **'Add text...'**
  String get addText;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @bioTitle.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioTitle;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @birthdayExplanation.
  ///
  /// In en, this message translates to:
  /// **'We use this to ensure you are old enough to use the app.'**
  String get birthdayExplanation;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blockBody.
  ///
  /// In en, this message translates to:
  /// **'This will hide content the user posts and prevent them from viewing your profile.'**
  String get blockBody;

  /// No description provided for @blockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Blocked Accounts'**
  String get blockedAccounts;

  /// No description provided for @blockedByUserMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not currently have permission to view this content.'**
  String get blockedByUserMessage;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockTitle;

  /// No description provided for @bySigningUp.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get bySigningUp;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changeEmailVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your new email address. Open it to finish changing your email.'**
  String get changeEmailVerificationBody;

  /// No description provided for @changeEmailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your new email'**
  String get changeEmailVerificationTitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @commentRequired.
  ///
  /// In en, this message translates to:
  /// **'Comment Required'**
  String get commentRequired;

  /// No description provided for @commentTaggedText.
  ///
  /// In en, this message translates to:
  /// **'tagged you in a comment!'**
  String get commentTaggedText;

  /// No description provided for @commentText.
  ///
  /// In en, this message translates to:
  /// **'commented on your post!'**
  String get commentText;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @cont.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cont;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to Clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @createAPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a Password'**
  String get createAPassword;

  /// No description provided for @currentEmail.
  ///
  /// In en, this message translates to:
  /// **'Current email'**
  String get currentEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @defaultErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again later or reach out to conetechnologiesdev@gmail.com.'**
  String get defaultErrorBody;

  /// No description provided for @defaultErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get defaultErrorTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'All account data will be deleted. This action cannot be undone. Press \"Go Back\" to cancel'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteCommentWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteCommentWarningTitle;

  /// No description provided for @deletePostWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to proceed? This action cannot be undone.'**
  String get deletePostWarningBody;

  /// No description provided for @deletePostWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePostWarningTitle;

  /// No description provided for @dislikes.
  ///
  /// In en, this message translates to:
  /// **'Down-ekos'**
  String get dislikes;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @ekoText.
  ///
  /// In en, this message translates to:
  /// **'eko\'ed your post!'**
  String get ekoText;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAlreadyInUseBody.
  ///
  /// In en, this message translates to:
  /// **'An account with that email already exists'**
  String get emailAlreadyInUseBody;

  /// No description provided for @emailAlreadyInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Already In-Use'**
  String get emailAlreadyInUseTitle;

  /// No description provided for @allFieldsEmpty.
  ///
  /// In en, this message translates to:
  /// **'All fields are empty.'**
  String get allFieldsEmpty;

  /// No description provided for @commentCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Comment can\'t be empty.'**
  String get commentCantBeEmpty;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitEditProfileBody.
  ///
  /// In en, this message translates to:
  /// **'All changes will be lost.'**
  String get exitEditProfileBody;

  /// No description provided for @exitEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitEditProfileTitle;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followText.
  ///
  /// In en, this message translates to:
  /// **'followed you!'**
  String get followText;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a password reset link.'**
  String get forgotPasswordBody;

  /// No description provided for @getTheApp.
  ///
  /// In en, this message translates to:
  /// **'Get the App'**
  String get getTheApp;

  /// No description provided for @gifLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get gifLoadingError;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @invalidBirthdayBody.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid birthday.'**
  String get invalidBirthdayBody;

  /// No description provided for @invalidEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and try again.'**
  String get invalidEmailBody;

  /// No description provided for @invalidUserName.
  ///
  /// In en, this message translates to:
  /// **'Username does not meet requirements'**
  String get invalidUserName;

  /// No description provided for @iveVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iveVerifiedMyEmail;

  /// No description provided for @keyExchangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Key exchange failed'**
  String get keyExchangeFailed;

  /// No description provided for @keysExchanged.
  ///
  /// In en, this message translates to:
  /// **'Keys exchanged'**
  String get keysExchanged;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Up-ekos'**
  String get likes;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get logIn;

  /// No description provided for @loginFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and password and try again.'**
  String get loginFailedBody;

  /// No description provided for @logInRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access all features of eko.'**
  String get logInRequired;

  /// No description provided for @logIntoApp.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get logIntoApp;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @needTwoOptions.
  ///
  /// In en, this message translates to:
  /// **'You need at least two poll options'**
  String get needTwoOptions;

  /// No description provided for @blankPollOption.
  ///
  /// In en, this message translates to:
  /// **'Poll options can\'t be blank'**
  String get blankPollOption;

  /// No description provided for @tooManyPollOptions.
  ///
  /// In en, this message translates to:
  /// **'Too many poll options'**
  String get tooManyPollOptions;

  /// No description provided for @newActivityNotifications.
  ///
  /// In en, this message translates to:
  /// **'New Activity Notifications'**
  String get newActivityNotifications;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @newLines.
  ///
  /// In en, this message translates to:
  /// **'New Lines'**
  String get newLines;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeAMessage;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New Password Must be Different'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nothingToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing to see here!'**
  String get nothingToSeeHere;

  /// No description provided for @noteToSelf.
  ///
  /// In en, this message translates to:
  /// **'Note to Self'**
  String get noteToSelf;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @option.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get option;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated.'**
  String get passwordChangedBody;

  /// No description provided for @passwordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordMatch;

  /// No description provided for @passwordMinChars.
  ///
  /// In en, this message translates to:
  /// **'8 or more characters'**
  String get passwordMinChars;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post Not Found'**
  String get postNotFound;

  /// No description provided for @postPreviewInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Posts will now be published immediately after you press the post button.'**
  String get postPreviewInfoBody;

  /// No description provided for @postPreviewInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview Disabled'**
  String get postPreviewInfoTitle;

  /// No description provided for @postTaggedText.
  ///
  /// In en, this message translates to:
  /// **'tagged you in a post!'**
  String get postTaggedText;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postTitle;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @removeVote.
  ///
  /// In en, this message translates to:
  /// **'Remove vote'**
  String get removeVote;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide information on why you are reporting this post.'**
  String get reportDetails;

  /// No description provided for @requiredResetPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you have not logged in since May 2026, you need to reset your password.'**
  String get requiredResetPasswordPrompt;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendVerificationEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Share Online Status'**
  String get shareOnlineStatus;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @showPostPreview.
  ///
  /// In en, this message translates to:
  /// **'Show post preview'**
  String get showPostPreview;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @tooEarlyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Posts/comments may only be deleted 48 hours after they are posted.'**
  String get tooEarlyDeleteBody;

  /// No description provided for @tooManyChar.
  ///
  /// In en, this message translates to:
  /// **'Too many characters.'**
  String get tooManyChar;

  /// No description provided for @tooManyLine.
  ///
  /// In en, this message translates to:
  /// **'Too many newlines.'**
  String get tooManyLine;

  /// No description provided for @tooYoungBody.
  ///
  /// In en, this message translates to:
  /// **'You must be 13 years old to make an account'**
  String get tooYoungBody;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Please download the latest update to continue.'**
  String get updateRequiredBody;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @usernameInUse.
  ///
  /// In en, this message translates to:
  /// **'Username Unavailable'**
  String get usernameInUse;

  /// No description provided for @usernameReqs.
  ///
  /// In en, this message translates to:
  /// **'Usernames must be between 3 and 24 characters. Usernames can only contain lowercase letters, numbers, and underscores.'**
  String get usernameReqs;

  /// No description provided for @usernameTakenBody.
  ///
  /// In en, this message translates to:
  /// **'Please go back and choose a different username.'**
  String get usernameTakenBody;

  /// No description provided for @userMayNotHaveDeviceRegistered.
  ///
  /// In en, this message translates to:
  /// **'User may not have a device registered.'**
  String get userMayNotHaveDeviceRegistered;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get userNotFound;

  /// No description provided for @verificationUrl.
  ///
  /// In en, this message translates to:
  /// **'Verification Url'**
  String get verificationUrl;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email. Check your inbox and spam folder, then click the link to verify your account.'**
  String get verifyEmailBody;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @viewDislikes.
  ///
  /// In en, this message translates to:
  /// **'See Down-ekos'**
  String get viewDislikes;

  /// No description provided for @viewLikes.
  ///
  /// In en, this message translates to:
  /// **'See Up-ekos'**
  String get viewLikes;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'votes'**
  String get votes;

  /// No description provided for @weakPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Check password requirements and try again.'**
  String get weakPasswordBody;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'eko'**
  String get appTitle;

  /// No description provided for @feedTabNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get feedTabNew;

  /// No description provided for @feedTabPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get feedTabPopular;

  /// No description provided for @messengerTitle.
  ///
  /// In en, this message translates to:
  /// **'eko messenger'**
  String get messengerTitle;

  /// No description provided for @messengerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'eko messenger coming soon'**
  String get messengerSubtitle;

  /// No description provided for @messengerSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Register this device to send and receive end-to-end encrypted messages.'**
  String get messengerSetupBody;

  /// No description provided for @enableMessages.
  ///
  /// In en, this message translates to:
  /// **'Enable messages'**
  String get enableMessages;

  /// No description provided for @registeringDevice.
  ///
  /// In en, this message translates to:
  /// **'Registering device…'**
  String get registeringDevice;

  /// No description provided for @deviceRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set up messaging on this device.'**
  String get deviceRegistrationFailed;

  /// No description provided for @selectEmojiTitle.
  ///
  /// In en, this message translates to:
  /// **'Select emoji'**
  String get selectEmojiTitle;

  /// No description provided for @pushDistributorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a distributor'**
  String get pushDistributorPickerTitle;

  /// No description provided for @pushOpenNotification.
  ///
  /// In en, this message translates to:
  /// **'Open notification'**
  String get pushOpenNotification;

  /// No description provided for @gifSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search KLIPY'**
  String get gifSearchHint;

  /// No description provided for @gifsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load GIFs'**
  String get gifsLoadFailed;

  /// No description provided for @postToPublicConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Post to {visibility}?'**
  String postToPublicConfirmTitle(String visibility);

  /// No description provided for @markdownBoldTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get markdownBoldTooltip;

  /// No description provided for @markdownItalicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get markdownItalicTooltip;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingEllipsis;

  /// No description provided for @shortLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get shortLoadError;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this profile'**
  String get profileLoadFailed;

  /// No description provided for @profileResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load user'**
  String get profileResolveFailed;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery'**
  String get imageSavedToGallery;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @repostLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this post'**
  String get repostLoadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'hi', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
