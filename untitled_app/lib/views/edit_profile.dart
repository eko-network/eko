import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/edit_profile_text_field.dart';
import 'package:untitled_app/custom_widgets/profile_picture_loading.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/edit_profile_controller.dart';
import 'package:provider/provider.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/profile_avatar.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return ChangeNotifierProvider(
      create: (context) => EditProfileController(context: context),
      builder: (context, child) {
        final height = MediaQuery.sizeOf(context).height;
        return PopScope(
          canPop: !Provider.of<EditProfileController>(context, listen: true)
              .showSave,
          onPopInvoked: (didPop) {
            if (!didPop) {
              Provider.of<EditProfileController>(context, listen: false)
                  .showWarning();
            }
          },
          // onWillPop: () async {
          //   Provider.of<EditProfileController>(context, listen: false)
          //       .exitPressed();
          //   return false;
          // },
          child: GestureDetector(
            onTap: () =>
                Provider.of<EditProfileController>(context, listen: false)
                    .hideKeyboard(),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded,
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                          onPressed: () => Provider.of<EditProfileController>(
                                  context,
                                  listen: false)
                              .exitPressed(),
                        ),

                        Text(
                          AppLocalizations.of(context)!.editProfile,
                          //AppLocalizations.of(context)!.save,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (Provider.of<EditProfileController>(context,
                                listen: true)
                            .showSave)
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context)!.save,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onPressed: () => Provider.of<EditProfileController>(
                                    context,
                                    listen: false)
                                .savePressed(),
                          ),

                        //const Spacer(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              SizedBox(
                                height: width * 0.4,
                                width: width * 0.4,
                                child: ClipOval(
                                    child: Provider.of<EditProfileController>(
                                                    context,
                                                    listen: true)
                                                .newProfileImage !=
                                            null
                                        ? Image.file(
                                            fit: BoxFit.fill,
                                            Provider.of<EditProfileController>(
                                                    context,
                                                    listen: true)
                                                .newProfileImage!)
                                        : ProfileAvatar(
                                            url: Provider.of<
                                                        EditProfileController>(
                                                    context,
                                                    listen: true)
                                                .profileImage)),
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(15)),
                                  onPressed: () =>
                                      Provider.of<EditProfileController>(
                                              context,
                                              listen: false)
                                          .editProfileImagePressed(),
                                  child: const Icon(
                                    Icons.mode,
                                    size: 25,
                                  ))
                              // const Image(
                              //   image: AssetImage('images/edit.png'),
                              // )
                            ],
                          ),
                        ],
                      ),
                    ),
                    ProfileInputFeild(
                      controller: Provider.of<EditProfileController>(context,
                              listen: false)
                          .nameController,
                      onChanged: (s) => Provider.of<EditProfileController>(
                              context,
                              listen: false)
                          .checkChanges(),
                      label: AppLocalizations.of(context)!.name,
                      maxLength: c.maxNameChars,
                    ),
                    SizedBox(height: height * 0.01),
                    ProfileInputFeild(
                      controller: Provider.of<EditProfileController>(context,
                              listen: false)
                          .bioController,
                      onChanged: (s) => Provider.of<EditProfileController>(
                              context,
                              listen: false)
                          .checkChanges(),
                      label: AppLocalizations.of(context)!.bioTitle,
                      maxLength: c.maxBioChars,
                      inputType: TextInputType.multiline,
                    ),
                    SizedBox(height: height * 0.01),
                    ProfileInputFeild(
                      onChanged: (s) => Provider.of<EditProfileController>(
                              context,
                              listen: false)
                          .onUsernameChanged(s),
                      focus: Provider.of<EditProfileController>(context,
                              listen: false)
                          .usernameFocus,
                      label: AppLocalizations.of(context)!.userName,
                      controller: Provider.of<EditProfileController>(context,
                              listen: false)
                          .usernameController,
                      inputType: TextInputType.text,
                      //maxLength: c.maxUsernameChars,
                    ),
                    if (Provider.of<EditProfileController>(context,
                                listen: true)
                            .usernameController
                            .text !=
                        '')
                      Row(
                        children: [
                          const SizedBox(width: 5),
                          Consumer<EditProfileController>(
                            builder: (context, signUpController, _) =>
                                signUpController.validUsername
                                    ? signUpController.isChecking
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              width: width * 0.05,
                                              height: width * 0.05,
                                              child:
                                                  const CircularProgressIndicator(),
                                            ))
                                        : signUpController.availableUsername
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .available,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .usernameInUse,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error),
                                                ),
                                              )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .invalidUserName,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Provider.of<EditProfileController>(
                                                        context,
                                                        listen: false)
                                                    .showUserNameReqs();
                                              },
                                              icon: const Icon(
                                                  Icons.help_outline_outlined))
                                        ],
                                      ),
                          )
                        ],
                      ),
                    SizedBox(
                      height: height * 0.5,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
