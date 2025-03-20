import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
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
import 'package:flutter/foundation.dart';

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
                              .then((v) async {
                              // notifier.rebuild();

                              //comments = await locator<PostsHandling>().countComments(post.postId);

                              // Provider.of<PaginationController>(context,
                              //         listen: false)
                              //     .rebuildFunction();
                            })
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
                                              child:
                                                  Row(
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
                                      if (post.gifURL != null && post.image == null)
                                        InkWell(
                                            onDoubleTap: () {
                                              if (!isPreview) {
                                                if (!Provider.of<
                                                            PostCardController>(
                                                        context,
                                                        listen: false)
                                                    .liked) {
                                                  Provider.of<PostCardController>(
                                                          context,
                                                          listen: false)
                                                      .likePressed();
                                                }
                                              }
                                            },
                                            child:
                                                GifWidget(url: post.gifURL!)),
                                      if (post.image != null)
                                        InkWell(
                                            onDoubleTap: () {
                                              if (!isPreview) {
                                                if (!Provider.of<
                                                            PostCardController>(
                                                        context,
                                                        listen: false)
                                                    .liked) {
                                                  Provider.of<PostCardController>(
                                                          context,
                                                          listen: false)
                                                      .likePressed();
                                                }
                                              }
                                            },
                                            child:
                                                ImageWidget(text: post.image!)),
                                      if (post.gifURL != null || post.image != null)
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
                                    return Icon(
                                      size: c.postIconSize,
                                      isLiked
                                          ? CupertinoIcons.heart_solid
                                          : CupertinoIcons.heart,
                                      color: isLiked
                                          ? const Color(0xFFff3040)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                  likeCount: null,
                                  likeCountAnimationType:
                                      LikeCountAnimationType.none,
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
                                      dotLastColor: Color(0xFFff3040)),
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
                                          //comments = await locator<PostsHandling>().countComments(post.postId);

                                          Provider.of<PaginationController>(
                                                  context,
                                                  listen: false)
                                              .rebuildFunction();
                                        });
                                      }
                                    }
                                  },
                                  child: Icon(
                                    CupertinoIcons.chat_bubble,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: c.postIconSize,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  //iconSize: c.postIconSize,
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
                                  child: Icon(
                                    kIsWeb
                                        ? CupertinoIcons
                                            .arrowshape_turn_up_right
                                        : Platform.isIOS
                                            ? CupertinoIcons.share
                                            : CupertinoIcons
                                                .arrowshape_turn_up_right,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: c.postPaddingHoriz + width * 0.115 + 14,
                                bottom: 9),
                            child: RichText(
                              text: TextSpan(
                                style: likeCommentTextStyle,
                                children: [
                                  //TextSpan(text:"${formatTime(post.time)} • "),
                                  //,
                                  TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (Provider.of<PostCardController>(
                                                  context,
                                                  listen: false)
                                              .isLoggedIn()) {
                                            context.push(
                                                "/feed/post/${post.postId}/likes",
                                                extra: post.postId);
                                          }
                                        },
                                      text:
                                          "${Provider.of<PostCardController>(context, listen: true).post.likes} ${Provider.of<PostCardController>(context, listen: true).post.likes == 1 ? AppLocalizations.of(context)!.like : AppLocalizations.of(context)!.likes} • "),
                                  TextSpan(
                                      text:
                                          "${Provider.of<PostCardController>(context, listen: true).post.commentCount} ${Provider.of<PostCardController>(context, listen: true).post.commentCount == 1 ? AppLocalizations.of(context)!.comment : AppLocalizations.of(context)!.comments}")
                                ],
                              ),
                            ),
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
