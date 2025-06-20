import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/poll_widget.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
// import 'package:untitled_app/interfaces/user.dart';
// import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/widgets/divider.dart';
import 'package:untitled_app/widgets/icons.dart' as icons;
import 'package:untitled_app/widgets/like_buttons.dart';
import 'package:untitled_app/widgets/repost_card.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/text_with_tags.dart';
import 'package:untitled_app/widgets/time_stamp.dart';
import 'package:untitled_app/widgets/user_tag.dart';
import '../utilities/constants.dart' as c;
import 'dart:io' show Platform;
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

Widget profilePostCardBuilder(String id) {
  return PostCard(id: id, isOnProfile: true, showGroup: true);
}

Widget otherProfilePostCardBuilder(String id) {
  return PostCard(id: id, isOnProfile: true);
}

Widget postCardBuilder(String id) {
  return PostCard(
    id: id,
  );
}

class GroupBadge extends ConsumerWidget {
  final String groupId;
  const GroupBadge({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final asyncGroup = ref.watch(groupProvider(groupId));
    return Padding(
      padding: EdgeInsets.only(left: width * 0.115 + 20),
      child: InkWell(
        onTap: () {
          final group = asyncGroup.valueOrNull;
          if (group == null) {
            return;
          }
          if (group.members.contains(ref.watch(currentUserProvider).user.uid)) {
            context.push('/groups/sub_group/${group.id}', extra: group);
          } else {
            showMyDialog(AppLocalizations.of(context)!.notInGroup, '',
                [AppLocalizations.of(context)!.ok], [context.pop], context,
                dismissable: true);
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 6, right: 6),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 2),
              asyncGroup.when(
                data: (group) => Text(
                  group.name,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                error: (_, __) => Text(
                  'Error',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                loading: () => Text(
                  'loading...',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostCard extends ConsumerStatefulWidget {
  final String id;
  final bool isPreview;
  final bool isPostPage;
  final bool isBuiltFromId;
  final bool isOnProfile;
  final bool showGroup;
  final bool visible;

  const PostCard(
      {super.key,
      required this.id,
      this.isPreview = false,
      this.isPostPage = false,
      this.isBuiltFromId = false,
      this.isOnProfile = false,
      this.showGroup = false,
      this.visible = true});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.postNotFound);
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PostLoader();
  }
}

class _PostCardState extends ConsumerState<PostCard> {
  bool sharing = false;
  bool isSelf = false;

  bool isLoggedIn() {
    // if (locator<CurrentUser>().getUID() == '') {
    //   showLogInDialog();
    //   return false;
    // }
    return true;
  }

  void showLogInDialog() {
    showMyDialog(
        AppLocalizations.of(context)!.logIntoApp,
        AppLocalizations.of(context)!.logInRequired,
        [
          AppLocalizations.of(context)!.goBack,
          AppLocalizations.of(context)!.signIn
        ],
        [_popDialog, _goToLogin],
        context,
        dismissable: true);
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _goToLogin() {
    context.go('/');
  }

  void sharePressed(String id) async {
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(
          text: 'Check out my post on Echo: ${c.appURL}/feed/post/$id'));
      showSnackBar(
          context: context,
          text: AppLocalizations.of(context)!.coppiedToClipboard);
    } else {
      if (!sharing) {
        sharing = true;
        await SharePlus.instance.share(ShareParams(
            text: 'Check out my post on Eko: ${c.appURL}/feed/post/$id'));
        sharing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return SizedBox.shrink();
    }
    final asyncPost = ref.watch(postProvider(widget.id));

    return asyncPost.when(data: (post) {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser.blockedUsers.contains(post.uid) ||
          currentUser.blockedBy.contains(post.uid)) {
        return SizedBox.shrink();
      }

      return PostCardFromPost(
          isOnProfile: widget.isOnProfile,
          sharePressed: sharePressed,
          isPreview: widget.isPreview,
          isPostPage: widget.isPostPage,
          isLoggedIn: isLoggedIn(),
          showGroup: widget.showGroup,
          post: post);
    }, error: (object, stack) {
      return _Error();
    }, loading: () {
      return _Loading();
    });
  }
}

class PostCardFromPost extends ConsumerWidget {
  final PostModel post;
  final bool isPreview;
  final bool isLoggedIn;
  final bool isPostPage;
  final bool isOnProfile;
  final bool showGroup;
  final void Function(String)? sharePressed;

  const PostCardFromPost(
      {this.isOnProfile = false,
      this.sharePressed,
      this.isPreview = false,
      this.isPostPage = false,
      this.isLoggedIn = true,
      this.showGroup = false,
      super.key,
      required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 0, right: 0),
      child: InkWell(
        onTap: () => (!isPreview && !isPostPage && isLoggedIn)
            ? context
                .push('/feed/post/${post.id}', extra: post)
                .then((v) async {})
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showGroup && post.tags.first != 'public')
              GroupBadge(groupId: post.tags.first),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: c.postPaddingHoriz,
                //vertical: c.postPaddingVert,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the profile picture as a CircleAvatar
                  ProfilePicture(
                    onPressed: () {
                      if (!isPreview && !isOnProfile) {
                        if (post.uid !=
                            ref.read(currentUserProvider).user.uid) {
                          context.push('/feed/sub_profile/${post.uid}');
                        } else {
                          context.go('/profile');
                        }
                      }
                    },
                    uid: post.uid,
                    size: width * 0.115,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    onlineIndicatorEnabled: !isOnProfile,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: UserTag(
                              onPressed: () {
                                if (!isPreview && !isOnProfile) {
                                  if (post.uid !=
                                      ref.read(currentUserProvider).user.uid) {
                                    context
                                        .push('/feed/sub_profile/${post.uid}');
                                  } else {
                                    context.go('/profile');
                                  }
                                }
                              },
                              uid: post.uid,
                            )),
                            if (!isPreview) TimeStamp(time: post.getDateTime()),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        if (post.title.isNotEmpty)
                          TextWithTags(
                            text: post.title,
                            baseTextStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontFamily:
                                  DefaultTextStyle.of(context).style.fontFamily,
                            ),
                          ),
                        const SizedBox(height: 6.0),
                        if (post.repostId != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: RepostCard(
                                postId: post.repostId!,
                                isLoggedIn: isLoggedIn,
                                isPreview: isPreview),
                          ),
                        if (post.gifUrl != null)
                          Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: GifWidget(url: post.gifUrl!)),
                        if (post.imageString != null)
                          Padding(
                              padding:
                                  const EdgeInsets.only(right: 50, bottom: 6),
                              child: ImageWidget(
                                ascii: post.imageString!,
                              )),
                        if (post.pollOptions != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: PollWidget(
                              post: post,
                              isPreview: isPreview,
                            ),
                          ),
                        if (post.body.isNotEmpty) TextWithTags(text: post.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: c.postPaddingHoriz,
                //vertical: c.postPaddingVert-8,
              ),
              child: isPreview
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: width * 0.115 + 8),
                        LikeButtons(
                          post: post,
                          disabled: isPreview,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            if (isLoggedIn) {
                              if (!isPreview && !isPostPage) {
                                context.push('/feed/post/${post.id}',
                                    extra: post);
                              }
                            }
                          },
                          child: icons.Comment(
                            size: c.postIconSize,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Count(
                          count: post.commentCount,
                          onTap: () {
                            if (isLoggedIn) {
                              if (!isPreview && !isPostPage) {
                                context.push('/feed/post/${post.id}',
                                    extra: post);
                              }
                            }
                          },
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            if (isLoggedIn && !isPreview) {
                              final Map<String, dynamic> queryParameters = {
                                'repostId': post.id
                              };
                              queryParameters['timestamp'] = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              if (post.tags.isNotEmpty &&
                                  post.tags.first != 'public') {
                                queryParameters['id'] = post.tags.first;
                              }
                              context.goNamed('compose',
                                  queryParameters: queryParameters);
                            }
                          },
                          child: icons.Repost(
                            size: c.postIconSize,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                            onTap: () {
                              if (isLoggedIn) {
                                isPreview || sharePressed == null
                                    ? null
                                    : sharePressed!(post.id);
                              }
                            },
                            child: icons.Share(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: c.postIconSize)),
                        const SizedBox(width: 5),
                      ],
                    ),
            ),
            if (!isPreview)
              Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: SizedBox(width: width, child: StyledDivider()))
          ],
        ),
      ),
    );
  }
}
