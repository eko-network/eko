import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eko_app/widgets/inputs/profile_input_field.dart';
import 'package:eko_app/widgets/inputs/username_check_display.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

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
  bool isLoading = false;

  @override
  void initState() {
    final user = ref.read(currentUserProvider).user;
    nameController = TextEditingController(text: user.name);
    bioController = TextEditingController(text: user.bio);
    usernameController = TextEditingController(text: user.username);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    usernameController.dispose();
    usernameFocus.dispose();
    super.dispose();
  }

  // Future<bool> _validateUsername(String s) async {
  //   if (!isUsernameValid(s)) return false;
  //   // really shouldn't be null. if it is just let the next check deal with it
  //   return usernameValid;
  // }

  Future<void> _savePressed(UserModel user) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    await Future<void>.delayed(Duration.zero);
    final usernameTrimmed = usernameController.text.trim();
    final username = usernameTrimmed != user.username ? usernameTrimmed : null;
    if (username != null) {
      if (!isUsernameValid(username)) {
        usernameFocus.requestFocus();
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          showSnackBar(
            text: AppLocalizations.of(context)!.usernameReqs,
            context: context,
            variant: SnackBarVariant.destructive,
          );
        }

        return;
      }
      if (!await isUsernameAvailable(username)) {
        usernameFocus.requestFocus();
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          showSnackBar(
            text: AppLocalizations.of(context)!.usernameInUse,
            context: context,
            variant: SnackBarVariant.destructive,
          );
        }
        return;
      }
    }
    final name = nameController.text != user.name ? nameController.text : null;
    final bio = bioController.text != user.bio ? bioController.text : null;
    try {
      await ref
          .read(currentUserProvider.notifier)
          .editProfile(
            name: name,
            bio: bio,
            profilePicture: newProfileImage,
            username: username,
          );
      if (mounted) {
        final updatedUsername = ref.read(currentUserProvider).user.username;
        context.go('/users/$updatedUsername');
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        if (e.toString().contains('username_taken')) {
          usernameFocus.requestFocus();
          showSnackBar(
            text: AppLocalizations.of(context)!.usernameInUse,
            context: context,
            variant: SnackBarVariant.destructive,
          );
        } else {
          showSnackBar(
            text: 'Failed to update profile',
            context: context,
            variant: SnackBarVariant.destructive,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    }
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
        IOSUiSettings(cropStyle: CropStyle.circle),
      ],
    );
    if (croppedFile == null) return null;
    return _compressImageToMaxBytes(
      File(croppedFile.path),
      c.maxProfilePictureSizeBytes,
    );
  }

  Future<File> _compressImageToMaxBytes(File file, int maxBytes) async {
    final originalBytes = await file.readAsBytes();
    if (originalBytes.lengthInBytes <= maxBytes) {
      return file;
    }
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      return file;
    }

    int quality = 95;
    List<int> compressedBytes = img.encodeJpg(decoded, quality: quality);
    while (compressedBytes.length > maxBytes && quality > 5) {
      quality -= 5;
      compressedBytes = img.encodeJpg(decoded, quality: quality);
    }

    await file.writeAsBytes(compressedBytes, flush: true);
    return file;
  }

  void _setProfilePicturePressed() async {
    final img = await _getProfileImage();
    if (img == null) return;
    setState(() {
      newProfileImage = img;
    });
  }

  bool _shouldShowSave(UserModel user) {
    final bioChanged = bioController.text != user.bio;
    final nameChanged = nameController.text != user.name;
    final profilePicChanged = newProfileImage != null;
    final usernameChanged = usernameController.text.trim() != user.username;
    return bioChanged || nameChanged || profilePicChanged || usernameChanged;
  }

  Future<bool> _confirmExitWithUnsavedChanges() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.exitEditProfileTitle),
          content: Text(AppLocalizations.of(context)!.exitEditProfileBody),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(AppLocalizations.of(context)!.stay),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(AppLocalizations.of(context)!.exit),
            ),
          ],
        );
      },
    );
    return shouldExit ?? false;
  }

  Future<void> _onBackPressed(UserModel user) async {
    if (isLoading) return;
    if (!_shouldShowSave(user)) {
      if (mounted) {
        context.pop();
      }
      return;
    }
    final shouldExit = await _confirmExitWithUnsavedChanges();
    if (shouldExit && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final user = ref.watch(currentUserProvider).user;

    final height = MediaQuery.sizeOf(context).height;
    return PopScope(
      canPop: !isLoading && !_shouldShowSave(user),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !mounted) return;
        await _onBackPressed(user);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AppScaffold(
          contrainBody: true,
          appBar: EkoAppBar(
            onBack: () => _onBackPressed(user),
            title: Text(AppLocalizations.of(context)!.editProfile),
            actions: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  bioController,
                  nameController,
                  usernameController,
                ]),
                builder: (context, _) {
                  if (_shouldShowSave(user)) {
                    return TextButton(
                      onPressed: isLoading ? null : () => _savePressed(user),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                                      size: width * 0.4,
                                      file: newProfileImage!,
                                    ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(8),
                                ),
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ProfileInputField(
                      controller: nameController,
                      label: AppLocalizations.of(context)!.name,
                      maxLength: c.maxNameChars,
                    ),
                    SizedBox(height: height * 0.01),
                    ProfileInputField(
                      controller: bioController,
                      label: AppLocalizations.of(context)!.bioTitle,
                      maxLength: c.maxBioChars,
                      inputType: TextInputType.multiline,
                    ),
                    SizedBox(height: height * 0.01),
                    ProfileInputField(
                      focus: usernameFocus,
                      label: AppLocalizations.of(context)!.userName,
                      controller: usernameController,
                      inputType: TextInputType.text,
                    ),
                    UsernameCheckDisplay(
                      controller: usernameController,
                      focus: usernameFocus,
                      skipVal: user.username,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.55),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
