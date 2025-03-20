import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled_app/controllers/view_post_page_controller.dart';
import 'package:untitled_app/custom_widgets/count_down_timer.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../localization/generated/app_localizations.dart';
import 'controllers/comment_card_controller.dart';
import '../utilities/constants.dart' as c;
import '../models/post_handler.dart' show Post;
import 'package:provider/provider.dart';
import 'profile_picture_loading.dart';
import '../custom_widgets/profile_avatar.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter/cupertino.dart';

Widget commentCardBuilder(dynamic post) {
  return CommentCard(post: post);
}

class CommentCard extends StatelessWidget {
  final Post post;

  const CommentCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return ChangeNotifierProvider.value(
      value: CommentCardController(post: post, context: context),
      builder: (context, child) {
        return (Provider.of<CommentCardController>(context, listen: false)
                    .isBlockedByMe() ||
                Provider.of<CommentCardController>(context, listen: false)
                    .blocksMe())
            ? const SizedBox.shrink()
            : TapRegion(
                onTapOutside: (v) =>
                    Provider.of<CommentCardController>(context, listen: false)
                        .scrollToStart(),
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    Provider.of<CommentCardController>(context, listen: false)
                        .onScrollEnd();
                    return true;
                  },
                  child: SingleChildScrollView(
                    controller: Provider.of<CommentCardController>(context,
                            listen: false)
                        .scrollController,
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: (post.author.uid ==
                                  locator<CurrentUser>().getUID())
                              ? Colors.red
                              : Theme.of(context).colorScheme.surface),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTapDown: (v) =>
                                  Provider.of<CommentCardController>(context,
                                          listen: false)
                                      .scrollToStart(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  width: width,
                                  child: _Card(post: post))),
                          SizedBox(
                            width: width * 0.2,
                            //color: Colors.red,
                            child: (post.author.uid ==
                                    locator<CurrentUser>().getUID())
                                ? GestureDetector(
                                    onTap: () =>
                                        Provider.of<CommentCardController>(
                                                context,
                                                listen: false)
                                            .deletePressed(),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.delete_simple,
                                          size: 32,
                                        ),
                                        CountDownTimer(
                                          dateTime: DateTime.parse(post.time)
                                              .toLocal()
                                              .add(const Duration(hours: 48)),
                                          textStyle:
                                              const TextStyle(fontSize: 13),
                                        )
                                      ],
                                    ))
                                : const Icon(
                                    CupertinoIcons.arrow_turn_up_left,
                                    size: 32,
                                  ),
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

class _Card extends StatelessWidget {
  final Post post;
  const _Card({required this.post});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: c.postPaddingHoriz,
              vertical: c.postPaddingVert,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the profile picture as a CircleAvatar
                IconButton(
                    onPressed: () {
                      if (Provider.of<CommentCardController>(context,
                              listen: false)
                          .isLoggedIn()) {
                        Provider.of<CommentCardController>(context,
                                listen: false)
                            .avatarPressed();
                      }
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    icon: ProfileAvatar(
                        url: post.author.profilePicture, size: width * 0.115)),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              if (Provider.of<CommentCardController>(context,
                                      listen: false)
                                  .isLoggedIn()) {
                                Provider.of<CommentCardController>(context,
                                        listen: false)
                                    .avatarPressed();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: SizedBox(
                                width: width * 0.65,
                                child: Row(
                                  children: [
                                    Text(
                                      "@${post.author.username}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (post.author.isVerified)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Icon(
                                          Icons.verified_rounded,
                                          size: c.verifiedIconSize,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceTint,
                                        ),
                                      ),
                                  ],
                                )),
                          ),
                          const SizedBox(width: 8.0),
                          // TextButton(
                          //   onPressed: () {
                          //     if (Provider.of<CommentCardController>(
                          //             context,
                          //             listen: false)
                          //         .isLoggedIn()) {
                          //       Provider.of<CommentCardController>(context,
                          //               listen: false)
                          //           .avatarPressed();
                          //     }
                          //   },
                          //   style: TextButton.styleFrom(
                          //     padding: EdgeInsets.zero,
                          //     minimumSize: const Size(0, 0),
                          //     tapTargetSize:
                          //         MaterialTapTargetSize.shrinkWrap,
                          //   ),
                          //   child: Text(
                          //     "@${post.author.username}",
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w300,
                          //       color: Theme.of(context)
                          //           .colorScheme
                          //           .onBackground,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      if (post.body != null)
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily:
                                  DefaultTextStyle.of(context).style.fontFamily,
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
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        Provider.of<CommentCardController>(
                                                context,
                                                listen: false)
                                            .tagPressed(chunk.substring(1)),
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
                      if (post.gifURL != null) GifWidget(url: post.gifURL!),
                      const SizedBox(height: 4.0),
                      TextButton(
                        onPressed: () {
                          if (Provider.of<CommentCardController>(context,
                                  listen: false)
                              .isLoggedIn()) {
                            Provider.of<PostPageController>(context,
                                    listen: false)
                                .replyPressed(post.author.username);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.reply,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(children: [
                  TimeStamp(time: post.time),

                  LikeButton(
                    isLiked: (Provider.of<CommentCardController>(context,
                            listen: true)
                        .liked),
                    likeBuilder: (isLiked) {
                      return Icon(
                        size: c.commentIconSize,
                        isLiked
                            ? CupertinoIcons.heart_solid
                            : CupertinoIcons.heart,
                        color: isLiked
                            ? const Color(0xFFff3040)
                            : Theme.of(context).colorScheme.onSurface,
                      );
                    },
                    onTap: (isLiked) async {
                      if (Provider.of<CommentCardController>(context,
                              listen: false)
                          .isLoggedIn()) {
                        Provider.of<CommentCardController>(context,
                                listen: false)
                            .likePressed();
                        return !isLiked;
                      }
                      return isLiked;
                    },
                    likeCount: Provider.of<CommentCardController>(context,
                            listen: true)
                        .likes,
                    countBuilder: (int? count, bool isLiked, String text) {
                      return Text(
                        text,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      );
                    },
                    likeCountAnimationType: LikeCountAnimationType.none,
                    circleSize: 0,
                    animationDuration: const Duration(milliseconds: 600),
                    bubblesSize: 25,
                    bubblesColor: const BubblesColor(
                        dotPrimaryColor: Color.fromARGB(255, 52, 105, 165),
                        dotSecondaryColor: Color.fromARGB(255, 65, 43, 161),
                        dotThirdColor: Color.fromARGB(255, 196, 68, 211),
                        dotLastColor: Color(0xFFff3040)),
                  ),
                  LikeButton(
                    isLiked: (Provider.of<CommentCardController>(context,
                            listen: true)
                        .disliked),
                    likeBuilder: (isLiked) {
                      return Icon(
                        size: c.commentIconSize,
                        isLiked
                            ? CupertinoIcons.heart_solid
                            : CupertinoIcons.heart,
                        color: isLiked
                            ? const Color(0xFFff3040)
                            : Theme.of(context).colorScheme.onSurface,
                      );
                    },
                    onTap: (isLiked) async {
                      if (Provider.of<CommentCardController>(context,
                              listen: false)
                          .isLoggedIn()) {
                        Provider.of<CommentCardController>(context,
                                listen: false)
                            .likePressed();
                        return !isLiked;
                      }
                      return isLiked;
                    },
                    likeCount: Provider.of<CommentCardController>(context,
                            listen: true)
                        .likes,
                    countBuilder: (int? count, bool isLiked, String text) {
                      return Text(
                        text,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      );
                    },
                    likeCountAnimationType: LikeCountAnimationType.none,
                    circleSize: 0,
                    animationDuration: const Duration(milliseconds: 600),
                    bubblesSize: 25,
                    bubblesColor: const BubblesColor(
                        dotPrimaryColor: Color.fromARGB(255, 52, 105, 165),
                        dotSecondaryColor: Color.fromARGB(255, 65, 43, 161),
                        dotThirdColor: Color.fromARGB(255, 196, 68, 211),
                        dotLastColor: Color(0xFFff3040)),
                  ),
                  // IconButton(
                  //   onPressed: () => Provider.of<CommentCardController>(
                  //           context,
                  //           listen: false)
                  //       .likePressed(),
                  //   icon: Row(
                  //     children: [
                  //       Icon(
                  // (Provider.of<CommentCardController>(context,
                  //             listen: true)
                  //         .liked)
                  //             ? Icons.favorite
                  //             : Icons.favorite_border,
                  //         color: Theme.of(context).colorScheme.onBackground,
                  //         size: c.postIconSize,
                  //       ),
                  //       const SizedBox(width: 5),
                  //       Text(
                  //         '${Provider.of<CommentCardController>(context, listen: true).likes}',
                  //         style: TextStyle(
                  //             color: Theme.of(context)
                  //                 .colorScheme
                  //                 .onBackground),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ])
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            height: c.dividerWidth,
          ),
        ],
      ),
    );
  }
}
