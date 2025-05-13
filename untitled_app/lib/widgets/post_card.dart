import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/poll_widget.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/utilities/enums.dart';
import 'package:untitled_app/widgets/post_loader.dart';
import 'package:untitled_app/widgets/time_stamp.dart';
import '../utilities/constants.dart' as c;
import 'package:provider/provider.dart' as prov;
import '../custom_widgets/profile_avatar.dart';
import 'dart:io' show Platform;
import 'package:like_button/like_button.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

Widget profilePostCardBuilder(String id) {
  return PostCard(id: id, isOnProfile: true, showGroup: true, key: Key(id));
}

class _Count extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _Count({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
        ],
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
    return const Text('Error');
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ShimmerPost();
  }
}

class _PostCardState extends ConsumerState<PostCard> {
  bool sharing = false;
  bool isSelf = false;

  @override
  void initState() {
    super.initState();
  }

  // void _init() {
  //   // liked = locator<CurrentUser>().checkIsLiked(post.postId);
  //   // disliked = locator<CurrentUser>().checkIsDisliked(post.postId);
  //   // isSelf = post.author.uid == locator<CurrentUser>().getUID();
  // }

  void groupBannerPressed() {
    // final group = post.group;
    // if (group != null) {
    //   if (group.members.contains(locator<CurrentUser>().getUID())) {
    //     context.push('/groups/sub_group/${group.id}', extra: group);
    //   } else {
    //     showMyDialog(AppLocalizations.of(context)!.notInGroup, '',
    //         [AppLocalizations.of(context)!.ok], [_popDialog], context,
    //         dismissable: true);
    //   }
    // }
  }

  bool isBlockedByMe() {
    return false;
    // return locator<CurrentUser>().blockedUsers.contains(post.author.uid);
  }

  bool blocksMe() {
    return false;
    // return locator<CurrentUser>().blockedBy.contains(post.author.uid);
  }

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

  sharePressed(String id) async {
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(
          text: 'Check out my post on Echo: ${c.appURL}/feed/post/$id'));
      showSnackBar(
          context: context,
          text: AppLocalizations.of(context)!.coppiedToClipboard);
    } else {
      if (!sharing) {
        sharing = true;
        await Share.share(
            'Check out my post on Echo: ${c.appURL}/feed/post/$id');
        sharing = false;
      }
    }
  }

  Future<void> tagPressed(String username) async {
    String? uid = await getUidFromUsername(username);
    if (!mounted) return;
    if (ref.read(currentUserProvider).user.uid == uid) {
      context.go('/profile');
    } else {
      context.push('/feed/sub_profile/$uid');
    }
  }

  avatarPressed(String uid) async {
    if (uid != ref.read(currentUserProvider).user.uid) {
      await context.push('/feed/sub_profile/$uid');
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    if (!widget.visible || isBlockedByMe() || blocksMe()) {
      return SizedBox.shrink();
    }
    final asyncPost = ref.watch(postProvider(widget.id));

    return asyncPost.when(
        data: (post) {
          final asyncAuthor = ref.watch(userProvider(post.uid));
          return asyncAuthor.when(
              data: (author) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 0, right: 0),
                  child: InkWell(
                    onTap: () => (!widget.isPreview &&
                            !widget.isPostPage &&
                            isLoggedIn())
                        ? context
                            .push('/feed/post/${post.id}', extra: post)
                            .then((v) async {})
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (widget.showGroup && post.group != null)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: width * 0.115 + 20),
                        //     child: InkWell(
                        //       onTap: () => groupBannerPressed(),
                        //       child: Container(
                        //         padding:
                        //             const EdgeInsets.only(left: 6, right: 6),
                        //         decoration: BoxDecoration(
                        //             color: Theme.of(context)
                        //                 .colorScheme
                        //                 .primaryContainer,
                        //             borderRadius: BorderRadius.circular(10)),
                        //         child: Row(
                        //           mainAxisSize: MainAxisSize.min,
                        //           children: [
                        //             Icon(
                        //               Icons.group,
                        //               color: Theme.of(context)
                        //                   .colorScheme
                        //                   .onPrimaryContainer,
                        //             ),
                        //             const SizedBox(width: 2),
                        //             Text(
                        //               post.group!.name,
                        //               style: TextStyle(
                        //                   color: Theme.of(context)
                        //                       .colorScheme
                        //                       .onPrimaryContainer),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
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
                              IconButton(
                                onPressed: () {
                                  if (isLoggedIn()) {
                                    (!widget.isPreview && !widget.isOnProfile)
                                        ? avatarPressed(author.uid)
                                        : null;
                                  }
                                },
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                icon: ProfileAvatar(
                                  size: width * 0.115,
                                  url: author.profilePicture,
                                ),
                              ),

                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              if (isLoggedIn()) {
                                                (!widget.isPreview &&
                                                        !widget.isOnProfile)
                                                    ? avatarPressed(author.uid)
                                                    : null;
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  '@${author.username}',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (author.isVerified)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    child: Icon(
                                                      Icons.verified_rounded,
                                                      size: c.verifiedIconSize,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surfaceTint,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!widget.isPreview)
                                          TimeStamp(time: post.createdAt),
                                      ],
                                    ),
                                    const SizedBox(height: 6.0),
                                    if (post.title?.isNotEmpty ?? false)
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily:
                                                DefaultTextStyle.of(context)
                                                    .style
                                                    .fontFamily,
                                          ),
                                          children: post.title!.map((chunk) {
                                            if (chunk.startsWith('@')) {
                                              // This is a username, create a hyperlink
                                              return TextSpan(
                                                text: chunk,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceTint),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () async {
                                                        if (!widget.isPreview) {
                                                          tagPressed(chunk
                                                              .substring(1));
                                                        }
                                                      },
                                              );
                                            } else {
                                              // This is a normal text, create a TextSpan
                                              return TextSpan(
                                                text: chunk,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              );
                                            }
                                          }).toList(),
                                        ),
                                      ),
                                    const SizedBox(height: 6.0),
                                    if (post.isPoll)
                                      PollWidget(
                                        postId: post.id,
                                        options: post.pollOptions!,
                                        pollVoteCounts: post.pollVoteCounts!,
                                        isPreview: widget.isPreview,
                                      ),
                                    if (post.gifUrl != null)
                                      GifWidget(url: post.gifUrl!),
                                    if (post.imageString != null)
                                      ImageWidget(text: post.imageString!),
                                    if (post.gifUrl != null ||
                                        post.imageString != null ||
                                        post.isPoll)
                                      const SizedBox(height: 6.0),
                                    if (post.body?.isNotEmpty ?? false)
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily:
                                                DefaultTextStyle.of(context)
                                                    .style
                                                    .fontFamily,
                                          ),
                                          children: post.body!.map((chunk) {
                                            if (chunk.startsWith('@')) {
                                              // This is a username, create a hyperlink
                                              return TextSpan(
                                                text: chunk,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceTint),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        if (!widget.isPreview) {
                                                          tagPressed(chunk
                                                              .substring(1));
                                                        }
                                                      },
                                              );
                                            } else {
                                              // This is a normal text, create a TextSpan
                                              return TextSpan(
                                                text: chunk,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              );
                                            }
                                          }).toList(),
                                        ),
                                      ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: width * 0.115 + 8),
                              LikeButton(
                                isLiked: post.likeState == LikeState.isLiked,
                                likeBuilder: (isLiked) {
                                  return SvgPicture.string(
                                    '''
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
           fill="${isLiked ? '#FF3040' : 'none'}" 
           stroke="${isLiked ? '#FF3040' : '#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}'}" 
           stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
        <path d="M9 18v-6H5l7-7 7 7h-4v6H9z"/>
      </svg>
      ''',
                                    width: c.postIconSize,
                                    height: c.postIconSize,
                                  );
                                },
                                onTap: (isLiked) async {
                                  if (isLoggedIn()) {
                                    if (!widget.isPreview) {
                                      if (!isLiked) {
                                        ref
                                            .read(
                                                postProvider(post.id).notifier)
                                            .addLike();
                                      } else {
                                        ref
                                            .read(
                                                postProvider(post.id).notifier)
                                            .removeLike();
                                      }
                                      return !isLiked;
                                    }
                                    return isLiked;
                                  }
                                  return false;
                                },
                                likeCountAnimationType:
                                    LikeCountAnimationType.none,
                                likeCountPadding: null,
                                circleSize: 0,
                                animationDuration:
                                    const Duration(milliseconds: 600),
                                bubblesSize: 25,
                                bubblesColor: const BubblesColor(
                                  dotPrimaryColor:
                                      Color.fromARGB(255, 52, 105, 165),
                                  dotSecondaryColor:
                                      Color.fromARGB(255, 65, 43, 161),
                                  dotThirdColor:
                                      Color.fromARGB(255, 196, 68, 211),
                                  dotLastColor: Color(0xFFff3040),
                                ),
                              ),
                              _Count(
                                count: post.likes,
                                onTap: () {
                                  if (isLoggedIn()) {
                                    context.push('/feed/post/${post.id}/likes',
                                        extra: post.id);
                                  }
                                },
                              ),
                              LikeButton(
                                isLiked: post.likeState ==
                                    LikeState.isDisliked, //dislike
                                likeBuilder: (isDisliked) {
                                  return SvgPicture.string(
                                    '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
           fill="${isDisliked ? '#FF3040' : 'none'}" 
           stroke="${isDisliked ? '#FF3040' : '#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}'}" 
           stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
        <path d="M15 6v6h4l-7 7-7-7h4V6h6z"/>
      </svg>
      ''',
                                    width: c.postIconSize,
                                    height: c.postIconSize,
                                  );
                                },
                                onTap: (isDisliked) async {
                                  if (isLoggedIn()) {
                                    if (!widget.isPreview) {
                                      if (!isDisliked) {
                                        ref
                                            .read(
                                                postProvider(post.id).notifier)
                                            .addDislike();
                                      } else {
                                        ref
                                            .read(
                                                postProvider(post.id).notifier)
                                            .removeDislike();
                                      }
                                      return !isDisliked;
                                    }
                                    return isDisliked;
                                  }
                                  return false;
                                },
                                likeCountAnimationType:
                                    LikeCountAnimationType.none,
                                likeCountPadding: null,
                                circleSize: 0,
                                animationDuration:
                                    const Duration(milliseconds: 600),
                                bubblesSize: 25,
                                bubblesColor: const BubblesColor(
                                  dotPrimaryColor:
                                      Color.fromARGB(255, 52, 105, 165),
                                  dotSecondaryColor:
                                      Color.fromARGB(255, 65, 43, 161),
                                  dotThirdColor:
                                      Color.fromARGB(255, 196, 68, 211),
                                  dotLastColor: Color(0xFFff3040),
                                ),
                              ),
                              _Count(
                                count: post.dislikes,
                                onTap: () {
                                  if (isLoggedIn()) {
                                    context.push(
                                        '/feed/post/${post.id}/dislikes',
                                        extra: post.id);
                                  }
                                },
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  if (isLoggedIn()) {
                                    if (!widget.isPreview &&
                                        !widget.isPostPage) {
                                      context
                                          .push('/feed/post/${post.id}',
                                              extra: post)
                                          .then((v) async {
                                        prov.Provider.of<PaginationController>(
                                                context,
                                                listen: false)
                                            .rebuildFunction();
                                      });
                                    }
                                  }
                                },
                                child: SvgPicture.string(
                                  '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}"  stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-message-circle"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg>''',
                                  width: c.postIconSize,
                                  height: c.postIconSize,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              _Count(
                                count: post.commentCount,
                                onTap: () {
                                  if (isLoggedIn()) {
                                    if (!widget.isPreview &&
                                        !widget.isPostPage) {
                                      context
                                          .push('/feed/post/${post.id}',
                                              extra: post)
                                          .then((v) async {
                                        prov.Provider.of<PaginationController>(
                                                context,
                                                listen: false)
                                            .rebuildFunction();
                                      });
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  if (isLoggedIn()) {
                                    widget.isPreview
                                        ? null
                                        : sharePressed(post.id);
                                  }
                                },
                                child: SvgPicture.string(
                                  Platform.isIOS
                                      ? '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-share"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" x2="12" y1="2" y2="15"/></svg>'''
                                      : '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-share-2"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" x2="15.42" y1="13.51" y2="17.49"/><line x1="15.41" x2="8.59" y1="6.51" y2="10.49"/></svg>''',
                                  width: c.postIconSize,
                                  height: c.postIconSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: width,
                          child: Divider(
                            color: Theme.of(context).colorScheme.outline,
                            height: c.dividerWidth,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              error: (object, stack) {
                print(object);
                print(stack);
                return _Error();
              },
              loading: () => _Loading());
        },
        error: (object, stack) {
          print(object);
          print(stack);
          return _Error();
        },
        loading: () => _Loading());
  }
}
