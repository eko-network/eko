import 'package:eko_app/widgets/posts/markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/posts/gif_widget.dart';
import 'package:eko_app/widgets/posts/image_widget.dart';
import 'package:eko_app/widgets/posts/poll_widget.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/widgets/common/divider.dart';
import 'package:eko_app/widgets/common/icons.dart' as icons;
import 'package:eko_app/widgets/common/count.dart';
import 'package:eko_app/widgets/posts/like_buttons.dart';
import 'package:eko_app/widgets/posts/repost_card.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/widgets/common/time_stamp.dart';
import 'package:eko_app/widgets/users/user_tag.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

Widget profilePostCardBuilder(int id) {
  return PostCard(id: id, isOnProfile: true);
}

Widget otherProfilePostCardBuilder(int id) {
  return PostCard(id: id, isOnProfile: true);
}

Widget postCardBuilder(int id) {
  return PostCard(id: id);
}

class PostCard extends ConsumerStatefulWidget {
  final int id;
  final bool isPreview;
  final bool isPostPage;
  final bool isOnProfile;
  final bool visible;

  const PostCard({
    super.key,
    required this.id,
    this.isPreview = false,
    this.isPostPage = false,
    this.isOnProfile = false,
    this.visible = true,
  });

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
        AppLocalizations.of(context)!.signIn,
      ],
      [_popDialog, _goToLogin],
      context,
      dismissable: true,
    );
  }

  void _popDialog() {
    context.pop();
  }

  void _goToLogin() {
    context.go('/');
  }

  void sharePressed(int id) async {
    if (kIsWeb) {
      Clipboard.setData(
        ClipboardData(
          text: 'Check out my post on eko: ${c.appURL}/feed/post/$id',
        ),
      );
      showSnackBar(
        context: context,
        text: AppLocalizations.of(context)!.copiedToClipboard,
      );
    } else {
      if (!sharing) {
        sharing = true;
        await SharePlus.instance.share(
          ShareParams(
            text: 'Check out my post on eko: ${c.appURL}/feed/post/$id',
          ),
        );
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
    return asyncPost.when(
      data: (post) {
        return PostCardFromPost(
          isOnProfile: widget.isOnProfile,
          sharePressed: sharePressed,
          isPreview: widget.isPreview,
          isPostPage: widget.isPostPage,
          isLoggedIn: isLoggedIn(),
          post: post,
        );
      },
      error: (object, stack) {
        if (widget.isOnProfile) {
          return const SizedBox.shrink();
        }
        return _Error();
      },
      loading: () {
        return _Loading();
      },
    );
  }
}

class PostCardFromPost extends ConsumerWidget {
  final PostModel post;
  final bool isPreview;
  final bool isLoggedIn;
  final bool isPostPage;
  final bool isOnProfile;
  final void Function(int)? sharePressed;

  const PostCardFromPost({
    this.isOnProfile = false,
    this.sharePressed,
    this.isPreview = false,
    this.isPostPage = false,
    this.isLoggedIn = true,
    super.key,
    required this.post,
  });

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
                          final user = ref.read(userProvider(post.uid)).value;
                          if (user != null) {
                            context.push(
                              '/users/${user.username}?uid=${user.uid}',
                            );
                          } else {
                            // Fallback to just uid if user data not available
                            context.push('/users/_?uid=${post.uid}');
                          }
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
                                uid: post.uid,
                                onPressedWithUser: (user) {
                                  if (!isPreview && !isOnProfile) {
                                    if (post.uid !=
                                        ref
                                            .read(currentUserProvider)
                                            .user
                                            .uid) {
                                      context.push(
                                        '/users/${user.username}?uid=${user.uid}',
                                      );
                                    } else {
                                      context.go('/profile');
                                    }
                                  }
                                },
                              ),
                            ),
                            if (!isPreview) TimeStamp(time: post.getDateTime()),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        if (post.title?.isNotEmpty ?? false)
                          MarkdownView(
                            content: post.title!,
                            type: MarkdownType.title,
                          ),
                        const SizedBox(height: 6.0),
                        if (post.repostId != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: RepostCard(
                              postId: post.repostId!,
                              isLoggedIn: isLoggedIn,
                              isPreview: isPreview,
                            ),
                          ),
                        if (post.gifUrl != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: GifWidget(url: post.gifUrl!),
                          ),
                        if (post.imageString != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 50,
                              bottom: 6,
                            ),
                            child: ImageWidget(ascii: post.imageString!),
                          ),
                        if (post.poll != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: PollWidget(post: post, isPreview: isPreview),
                          ),
                        if (post.body?.isNotEmpty ?? false)
                          MarkdownView(content: post.body!),
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
                        LikeButtons(post: post, disabled: isPreview),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            if (isLoggedIn) {
                              if (!isPreview && !isPostPage) {
                                context.push(
                                  '/feed/post/${post.id}',
                                  extra: post,
                                );
                              }
                            }
                          },
                          child: icons.Comment(
                            size: c.postIconSize,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 3),
                        Count(
                          count: post.commentCount,
                          onTap: () {
                            if (isLoggedIn) {
                              if (!isPreview && !isPostPage) {
                                context.push(
                                  '/feed/post/${post.id}',
                                  extra: post,
                                );
                              }
                            }
                          },
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            if (isLoggedIn && !isPreview) {
                              final Map<String, dynamic> queryParameters = {
                                'repostId': post.id.toString(),
                              };
                              queryParameters['timestamp'] = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              context.goNamed(
                                'compose',
                                queryParameters: queryParameters,
                              );
                            }
                          },
                          child: icons.Repost(
                            size: c.postIconSize,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            size: c.postIconSize,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
            ),
            if (!isPreview)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(width: width, child: StyledDivider()),
              ),
          ],
        ),
      ),
    );
  }
}
