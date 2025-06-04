import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled_app/custom_widgets/edit_profile_text_field.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import '../utilities/constants.dart' as c;

class _UserNameCheckLoading extends StatelessWidget {
  const _UserNameCheckLoading();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: width * 0.05,
          height: width * 0.05,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  late final TextEditingController usernameController;
  final usernameFocus = FocusNode();
  File? newProfileImage;
  Future<bool>? isUsernameAvailableAsync;
  Timer? _debounce;
  bool isLoading = false;
  void usernameListener() {
    final username = usernameController.text.trim();
    if (!isUsernameValid(username)) return;
    if (isUsernameAvailableAsync != null) {
      setState(() {
        isUsernameAvailableAsync = null;
      });
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: c.searchPageDebounce), () async {
      setState(() {
        isUsernameAvailableAsync = isUsernameAvailable(username);
      });
    });
  }

  @override
  void initState() {
    final user = ref.read(currentUserProvider).user;
    nameController = TextEditingController(text: user.name);
    bioController = TextEditingController(text: user.bio);
    usernameController = TextEditingController(text: user.username);
    usernameController.addListener(usernameListener);
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    usernameController.removeListener(usernameListener);
    nameController.dispose();
    bioController.dispose();
    usernameController.dispose();
    usernameFocus.dispose();
    super.dispose();
  }

  void _showUserNameReqs() {
    showMyDialog(
        AppLocalizations.of(context)!.invalidUserName,
        AppLocalizations.of(context)!.usernameReqs,
        [AppLocalizations.of(context)!.ok],
        [
          () {
            context.pop();
            usernameFocus.requestFocus();
          }
        ],
        context);
  }

  Future<bool> _validateUsername(String s) async {
    if (!isUsernameValid(s)) return false;
    // really shouldn't be null. if it is just let the next check deal with it
    if (isUsernameAvailableAsync == null) return true;
    if (!await isUsernameAvailableAsync!) return false;
    return true;
  }

  void _savePressed(UserModel user) async {
    if (isLoading) return;
    isLoading = true;
    final usernameTrimmed = usernameController.text.trim();
    final username = usernameTrimmed != user.username ? usernameTrimmed : null;
    if (username != null) {
      if (!await _validateUsername(username)) {
        usernameFocus.requestFocus();
        isLoading = false;
        return;
      }
    }
    final name = nameController.text != user.name ? nameController.text : null;
    final bio = bioController.text != user.bio ? bioController.text : null;
    ref.read(currentUserProvider.notifier).editProfile(
        name: name,
        bio: bio,
        profilePicture: newProfileImage,
        username: username);
    isLoading = false;
    if (mounted) context.pop();
  }

  Future<File?> _getProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return null;
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // cropStyle: CropStyle.circle,
        maxHeight: 300,
        maxWidth: 300,
        aspectRatio: const CropAspectRatio(ratioX: 150, ratioY: 150),
        uiSettings: [
          AndroidUiSettings(
            showCropGrid: false,
            hideBottomControls: true,
            cropStyle: CropStyle.circle,
            toolbarWidgetColor: Colors.black,
            toolbarColor: Colors.white,
          ),
          IOSUiSettings(cropStyle: CropStyle.circle)
        ]);
    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  void _setProfilePicturePressed() async {
    final img = await _getProfileImage();
    if (img == null) return;
    setState(() {
      newProfileImage = img;
    });
  }

  void _showWarning() {
    showMyDialog(
        AppLocalizations.of(context)!.exitEditProfileTitle,
        AppLocalizations.of(context)!.exitEditProfileBody,
        [
          AppLocalizations.of(context)!.exit,
          AppLocalizations.of(context)!.stay
        ],
        [
          () {
            context.pop();
            context.pop();
          },
          context.pop
        ],
        context);
  }

  bool _shouldShowSave(UserModel user) {
    final bioChanged = bioController.text != user.bio;
    final nameChanged = nameController.text != user.name;
    final profilePicChanged = newProfileImage != null;
    final usernameChanged = usernameController.text.trim() != user.username;
    return bioChanged || nameChanged || profilePicChanged || usernameChanged;
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final user = ref.watch(currentUserProvider).user;

    final height = MediaQuery.sizeOf(context).height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, Object? result) {
        if (didPop) return;
        if (!_shouldShowSave(user)) {
          context.pop();
          return;
        }
        _showWarning();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.editProfile,
              //AppLocalizations.of(context)!.save,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 0.0,
            actions: [
              AnimatedBuilder(
                animation: Listenable.merge(
                    [bioController, nameController, usernameController]),
                builder: (context, _) {
                  if (_shouldShowSave(user)) {
                    return TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      onPressed: () => _savePressed(user),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          newProfileImage == null
                              ? ProfilePicture(
                                  uid: user.uid,
                                  size: width * 0.4,
                                  onlineIndicatorEnabled: false,
                                )
                              : ProfilePictureFromFile(
                                  size: width * 0.4, file: newProfileImage!),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8)),
                            onPressed: () {
                              if (newProfileImage == null) {
                                _setProfilePicturePressed();
                              } else {
                                setState(() {
                                  newProfileImage = null;
                                });
                              }
                            },
                            child: Icon(
                              newProfileImage == null
                                  ? Icons.mode
                                  : Icons.close,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                ProfileInputFeild(
                  controller: nameController,
                  label: AppLocalizations.of(context)!.name,
                  maxLength: c.maxNameChars,
                ),
                SizedBox(height: height * 0.01),
                ProfileInputFeild(
                  controller: bioController,
                  label: AppLocalizations.of(context)!.bioTitle,
                  maxLength: c.maxBioChars,
                  inputType: TextInputType.multiline,
                ),
                SizedBox(height: height * 0.01),
                ProfileInputFeild(
                  focus: usernameFocus,
                  label: AppLocalizations.of(context)!.userName,
                  controller: usernameController,
                  inputType: TextInputType.text,
                  //maxLength: c.maxUsernameChars,
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: usernameController,
                  builder: (BuildContext context, TextEditingValue value, __) {
                    if (user.username == value.text.trim()) {
                      return SizedBox.shrink();
                    }
                    if (!isUsernameValid(value.text.trim())) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.invalidUserName,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          IconButton(
                              onPressed: () {
                                _showUserNameReqs();
                              },
                              icon: const Icon(Icons.help_outline_outlined))
                        ],
                      );
                    }
                    if (isUsernameAvailableAsync == null) {
                      return _UserNameCheckLoading();
                    }
                    return FutureBuilder(
                      future: isUsernameAvailableAsync,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                AppLocalizations.of(context)!.available,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                AppLocalizations.of(context)!.usernameInUse,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            );
                          }
                        }
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'error',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          );
                        }
                        return _UserNameCheckLoading();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
