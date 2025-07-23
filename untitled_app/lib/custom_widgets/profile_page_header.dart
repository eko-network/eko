import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/follow_info_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import '../utilities/constants.dart' as c;

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool loggedIn;

  const ProfileHeader({
    super.key,
    required this.user,
    this.loggedIn = true,
  });

  @override
  Widget build(BuildContext context) {
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
                      await context.pushNamed('profile_picture_detail',
                          pathParameters: {'id': user.uid});
                    }
                  },
                  icon: ProfilePicture(
                      uid: user.uid, size: c.widthGetter(context) * 0.24)),
              Flexible(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _FollowCountsDisplay(uid: user.uid)),
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
                //user.name,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                user.bio,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowCountsDisplay extends ConsumerWidget {
  final String uid;
  const _FollowCountsDisplay({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFollowInfo = ref.watch(FollowInfoProvider(uid));
    return asyncFollowInfo.when(
      data: (followInfo) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ProfilePageTopNumberDisplay(
            // number: user.followers.length,
            number: followInfo.followers,
            label: AppLocalizations.of(context)!.followers,
            onPressed: () {
              context.push('/profile/followers');
            },
          ),
          _ProfilePageTopNumberDisplay(
            // number: user.following.length,
            number: followInfo.following,
            label: AppLocalizations.of(context)!.following,
            onPressed: () {
              context.push('/profile/following');
            },
          ),
        ],
      ),
      loading: () => SizedBox(),
      error: (_, __) => Center(
        child: Text('An Error Occured'),
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
                fontSize: 17),
            children: [
              TextSpan(
                text: '\n$label',
              )
            ],
          ),
        ),
      ),
    );
  }
}
