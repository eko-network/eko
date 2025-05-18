import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/poll_widget.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
// import 'package:untitled_app/interfaces/user.dart';
// import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/widgets/divider.dart';
import 'package:untitled_app/widgets/like_buttons.dart';
import 'package:untitled_app/widgets/post_loader.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/time_stamp.dart';
import 'package:untitled_app/widgets/user_tag.dart';
import '../utilities/constants.dart' as c;
import 'package:provider/provider.dart' as prov;
import 'dart:io' show Platform;
import 'package:untitled_app/localization/generated/app_localizations.dart';

Widget commentCardBuilder(String id) {
  return CommentCard(
    id: id,
  );
}

class CommentCard extends ConsumerStatefulWidget {
  final String id;

  const CommentCard({super.key, required this.id});

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.defaultErrorTittle);
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PostLoader();
  }
}

class _CommentCardState extends ConsumerState<CommentCard> {
  bool sharing = false;
  bool isSelf = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final asyncPost = ref.watch(postProvider(widget.id));

    return asyncPost.when(data: (post) {
      return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 0, right: 0),
        child: InkWell(
          onTap: () => context
              .push('/feed/post/${post.id}', extra: post)
              .then((v) async {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: c.postPaddingHoriz,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the profile picture as a CircleAvatar
                    ProfilePicture(
                      onPressed: () {
                        if (post.uid !=
                            ref.read(currentUserProvider).user.uid) {
                          context.push('/feed/sub_profile/${post.uid}');
                        } else {
                          context.go('/profile');
                        }
                      },
                      uid: post.uid,
                      size: width * 0.115,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                  if (post.uid !=
                                      ref.read(currentUserProvider).user.uid) {
                                    context
                                        .push('/feed/sub_profile/${post.uid}');
                                  } else {
                                    context.go('/profile');
                                  }
                                },
                                uid: post.uid,
                              )),
                              TimeStamp(time: post.getDateTime()),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          if (post.title?.isNotEmpty ?? false)
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: DefaultTextStyle.of(context)
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
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          // tagPressed(chunk.substring(1));
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
                            ),
                          if (post.gifUrl != null) GifWidget(url: post.gifUrl!),
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
                                  fontFamily: DefaultTextStyle.of(context)
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
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // tagPressed(chunk.substring(1));
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
                    LikeButtons(post: post),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        context
                            .push('/feed/post/${post.id}', extra: post)
                            .then((v) async {
                          prov.Provider.of<PaginationController>(context,
                                  listen: false)
                              .rebuildFunction();
                        });
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
                    Count(
                      count: post.commentCount,
                      onTap: () {
                        context
                            .push('/feed/post/${post.id}', extra: post)
                            .then((v) async {
                          prov.Provider.of<PaginationController>(context,
                                  listen: false)
                              .rebuildFunction();
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    InkWell(
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
              SizedBox(width: width, child: StyledDivider())
            ],
          ),
        ),
      );
    }, error: (object, stack) {
      return _Error();
    }, loading: () {
      return _Loading();
    });
  }
}
