import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';
import 'package:untitled_app/custom_widgets/poll_widget.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/text_with_tags.dart';
import 'package:untitled_app/widgets/time_stamp.dart';
import 'package:untitled_app/widgets/user_tag.dart';

class RepostCard extends ConsumerWidget {
  final String postId;
  final bool isLoggedIn;
  final bool isPreview;
  const RepostCard(
      {super.key,
      required this.postId,
      required this.isLoggedIn,
      required this.isPreview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final asyncPost = ref.watch(postProvider(postId));
    return asyncPost.when(
        data: (post) => DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: BoxBorder.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: c.dividerWidth,
                  )),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 3),
                child: InkWell(
                  onTap: () => (!isPreview && isLoggedIn)
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
                                if (!isPreview) {
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
                              size: width * 0.085,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
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
                                          if (!isPreview) {
                                            if (post.uid !=
                                                ref
                                                    .read(currentUserProvider)
                                                    .user
                                                    .uid) {
                                              context.push(
                                                  '/feed/sub_profile/${post.uid}');
                                            } else {
                                              context.go('/profile');
                                            }
                                          }
                                        },
                                        uid: post.uid,
                                      )),
                                      TimeStamp(time: post.getDateTime()),
                                    ],
                                  ),
                                  const SizedBox(height: 6.0),
                                  if (post.title.isNotEmpty)
                                    TextWithTags(
                                      text: post.title,
                                      baseTextStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 15,
                                        fontFamily: DefaultTextStyle.of(context)
                                            .style
                                            .fontFamily,
                                      ),
                                    ),
                                  const SizedBox(height: 6.0),
                                  if (post.gifUrl != null)
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 6),
                                        child: GifWidget(url: post.gifUrl!)),
                                  if (post.imageString != null)
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            right: 50, bottom: 6),
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
                                  if (post.body.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 6),
                                      child: TextWithTags(text: post.body),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        error: (e, __) {
          debugPrint(e.toString());
          return Text('Failed to Load');
        },
        loading: () => CircularProgressIndicator());
  }
}
