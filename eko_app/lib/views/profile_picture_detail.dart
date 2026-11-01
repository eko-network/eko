import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/loading/profile_picture_loading.dart';
import 'package:eko_app/widgets/users/network_or_default_profile_image.dart';

class ProfilePictureDetail extends ConsumerWidget {
  final String uid;

  const ProfilePictureDetail({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));
    final diameter = MediaQuery.sizeOf(context).shortestSide * 0.9;
    return Scaffold(
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.shadow,
          ),
          child: Center(
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: ClipOval(
                child: asyncUser.when(
                  data: (user) => NetworkOrDefaultProfileImage(
                    imageUrl: user.profilePicture,
                  ),
                  error: (_, _) => Center(
                    child: Text(AppLocalizations.of(context)!.shortLoadError),
                  ),
                  loading: () => const Center(child: LoadingProfileImage()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
