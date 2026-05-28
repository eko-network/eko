import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/follow_info_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  final bool loggedIn;

  const ProfileHeader({super.key, required this.user, this.loggedIn = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followInfo = ref.watch(followInfoProvider(user.uid));
    final followersCount = followInfo.value?.followers ?? 0;
    final followingCount = followInfo.value?.following ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (loggedIn) {
                    await context.pushNamed(
                      'profile_picture_detail',
                      pathParameters: {'id': user.uid},
                    );
                  }
                },
                icon: ProfilePicture(
                  uid: user.uid,
                  size: c.widthGetter(context) * 0.24,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfilePageTopNumberDisplay(
                            number: followersCount,
                            label: AppLocalizations.of(context)!.followers,
                            onPressed: () {
                              if (loggedIn) {
                                context.push(
                                  '/users/${user.username}/followers?uid=${user.uid}',
                                );
                              }
                            },
                          ),
                          _ProfilePageTopNumberDisplay(
                            number: followingCount,
                            label: AppLocalizations.of(context)!.following,
                            onPressed: () {
                              if (loggedIn) {
                                context.push(
                                  '/users/${user.username}/following?uid=${user.uid}',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username != ''
                    ? user.name
                    : AppLocalizations.of(context)!.userNotFound,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(user.bio),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfilePageTopNumberDisplay extends StatelessWidget {
  final int number;
  final String label;
  final VoidCallback onPressed;

  const _ProfilePageTopNumberDisplay({
    required this.number,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: NumberFormat.compact().format(number),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.normal,
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
              fontSize: 17,
            ),
            children: [TextSpan(text: '\n$label')],
          ),
        ),
      ),
    );
  }
}
