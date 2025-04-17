import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/poll_widget.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'controllers/post_card_controller.dart';
import '../utilities/constants.dart' as c;
import '../models/post_handler.dart' show Post;
import 'package:provider/provider.dart';
import '../custom_widgets/profile_avatar.dart';
import 'dart:io' show Platform;
import 'package:like_button/like_button.dart';

Widget postCardBuilder(dynamic post) {
  post as Post;
  return PostCard(
    key: Key(post.postId),
    post: post,
  );
}

Widget otherProfilePostCardBuilder(dynamic post) {
  return PostCard(
    post: post,
    isOnProfile: true,
  );
}

Widget profilePostCardBuilder(dynamic post) {
  post as Post;
  return PostCard(
    key: Key(post.postId),
    post: post,
    isOnProfile: true,
    showGroup: true,
  );
}

class CountDisplay extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const CountDisplay({
    Key? key,
    required this.count,
    required this.onTap,
  }) : super(key: key);

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

class PostCard extends StatelessWidget {
  final Post post;
  final bool isPreview;
  final bool isPostPage;
  final bool isBuiltFromId;
  final bool isOnProfile;
  final bool showGroup;

  const PostCard(
      {super.key,
      required this.post,
      this.isPreview = false,
      this.isPostPage = false,
      this.isBuiltFromId = false,
      this.isOnProfile = false,
      this.showGroup = false});

  PostCardController getController(String id, BuildContext context) {
    if (!postMap.containsKey(post.postId)) {
      postMap[post.postId] = PostCardController(
          post: post, context: context, isBuiltFromId: isBuiltFromId);
    } else {
      postMap[post.postId]!.post = post;
      postMap[post.postId]!.liked =
          locator<CurrentUser>().checkIsLiked(post.postId);
      postMap[post.postId]!.disliked =
          locator<CurrentUser>().checkIsDisliked(post.postId);
    }
    return postMap[post.postId]!;
  }

  tagPressed(String username, BuildContext context) async {
    String? uid = await locator<CurrentUser>().getUidFromUsername(username);
    if (locator<CurrentUser>().getUID() == uid) {
      context.go("/profile");
    } else {
      context.push("/feed/sub_profile/$uid");
    }
  }

  avatarPressed(BuildContext context) async {
    if (post.author.uid != locator<CurrentUser>().getUID()) {
      await context.push("/feed/sub_profile/${post.author.uid}",
          extra: post.author);
    } else {
      context.go("/profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      //lazy: true,

      key: Key(post.postId),
      value: getController(post.postId, context),
      builder: (context, child) {
        //  PostCardController(
        //     post: post, context: context, isBuiltFromId: isBuiltFromId),
        //builder: (context, child) {
        return Consumer<PostCardController>(
          builder: (context, notifier, child) {
            // print(post.body);
            final width = c.widthGetter(context);
            final likeCommentTextStyle = TextStyle(
                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                color: Theme.of(context).colorScheme.onSurfaceVariant);
            return (!notifier.visible ||
                    Provider.of<PostCardController>(context, listen: false)
                        .isBlockedByMe() ||
                    Provider.of<PostCardController>(context, listen: false)
                        .blocksMe())
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 0, right: 0),
                    child: InkWell(
                      onTap: () => (!isPreview &&
                              !isPostPage &&
                              Provider.of<PostCardController>(context,
                                      listen: false)
                                  .isLoggedIn())
                          ? context
                              .push("/feed/post/${post.postId}", extra: post)
                              .then((v) async {})
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showGroup && post.group != null)
                            Padding(
                              padding:
                                  EdgeInsets.only(left: width * 0.115 + 20),
                              child: InkWell(
                                onTap: () => Provider.of<PostCardController>(
                                        context,
                                        listen: false)
                                    .groupBannerPressed(),
                                child: Container(
                                  padding:
                                      const EdgeInsets.only(left: 6, right: 6),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.group,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        post.group!.name,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      (!isPreview && !isOnProfile)
                                          ? avatarPressed(context)
                                          : null;
                                    }
                                  },
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  icon: ProfileAvatar(
                                    size: width * 0.115,
                                    url: post.author.profilePicture,
                                  ),
                                ),

                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                if (Provider.of<
                                                            PostCardController>(
                                                        context,
                                                        listen: false)
                                                    .isLoggedIn()) {
                                                  (!isPreview && !isOnProfile)
                                                      ? avatarPressed(context)
                                                      : null;
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "@${post.author.username}",
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (post.author.isVerified)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 6),
                                                      child: Icon(
                                                        Icons.verified_rounded,
                                                        size:
                                                            c.verifiedIconSize,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceTint,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // const Spacer(),
                                          if (!isPreview)
                                            TimeStamp(time: post.time),
                                          // if (!isPreview)
                                          //   InkWell(
                                          //       onTap: () {},
                                          //       child: Icon(Icons.more_vert))
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      if (post.title?.isNotEmpty ?? false)
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 15,
                                              //fontWeight: FontWeight.bold,
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
                                                          if (!isPreview) {
                                                            tagPressed(
                                                                chunk.substring(
                                                                    1),
                                                                context);
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
                                      // display gif/image/poll
                                      if (post.isPoll &&
                                          post.pollOptions != null &&
                                          post.pollOptions!.isNotEmpty)
                                        PollWidget(
                                          postId: post.postId,
                                          options: post.pollOptions!,
                                          isPreview: isPreview,
                                        ),
                                      if (post.gifURL != null &&
                                          post.image == null &&
                                          !post.isPoll)
                                        GifWidget(url: post.gifURL!),
                                      if (post.image != null && !post.isPoll)
                                        ImageWidget(text: post.image!),
                                      if (post.gifURL != null ||
                                          post.image != null ||
                                          post.isPoll)
                                        const SizedBox(height: 6.0),

                                      if (post.body?.isNotEmpty ??
                                          false) //&& post.body != []
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
                                                          if (!isPreview) {
                                                            tagPressed(
                                                                chunk.substring(
                                                                    1),
                                                                context);
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
                                  isLiked: Provider.of<PostCardController>(
                                          context,
                                          listen: true)
                                      .liked,
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
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      if (!isPreview) {
                                        Provider.of<PostCardController>(context,
                                                listen: false)
                                            .likePressed();
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
                                CountDisplay(
                                  count: Provider.of<PostCardController>(
                                          context,
                                          listen: true)
                                      .post
                                      .likes,
                                  onTap: () {
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      context.push(
                                          "/feed/post/${post.postId}/likes",
                                          extra: post.postId);
                                    }
                                  },
                                ),
                                LikeButton(
                                  isLiked: Provider.of<PostCardController>(
                                          context,
                                          listen: true)
                                      .disliked,
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
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      if (!isPreview) {
                                        Provider.of<PostCardController>(context,
                                                listen: false)
                                            .dislikePressed();
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
                                CountDisplay(
                                  count: Provider.of<PostCardController>(
                                          context,
                                          listen: true)
                                      .post
                                      .dislikes,
                                  onTap: () {
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      context.push(
                                          "/feed/post/${post.postId}/dislikes",
                                          extra: post.postId);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      if (!isPreview && !isPostPage) {
                                        context
                                            .push("/feed/post/${post.postId}",
                                                extra: post)
                                            .then((v) async {
                                          Provider.of<PaginationController>(
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
                                CountDisplay(
                                  count: Provider.of<PostCardController>(
                                          context,
                                          listen: true)
                                      .post
                                      .commentCount,
                                  onTap: () {
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      if (!isPreview && !isPostPage) {
                                        context
                                            .push("/feed/post/${post.postId}",
                                                extra: post)
                                            .then((v) async {
                                          Provider.of<PaginationController>(
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
                                    if (Provider.of<PostCardController>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      isPreview
                                          ? null
                                          : Provider.of<PostCardController>(
                                                  context,
                                                  listen: false)
                                              .sharePressed();
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
        );
      },
    );
  }
}
