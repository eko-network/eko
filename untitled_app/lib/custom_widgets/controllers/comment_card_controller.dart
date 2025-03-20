import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/controllers/view_post_page_controller.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../../models/current_user.dart';
import '../../utilities/locator.dart';
import '../../models/post_handler.dart' show Post, PostsHandling;
//import '../../models/feed_post_cache.dart' show FeedPostCache;

class CommentCardController extends ChangeNotifier {
  BuildContext context;

  Post post;
  late int likes;
  late int dislikes;
  late bool liked;
  late bool disliked;
  bool liking = false;
  bool disliking = false;
  late bool isSelf;
  final scrollController = ScrollController();

  CommentCardController({required this.context, required this.post}) {
    _init();
  }
  _init() async {
    liked = locator<CurrentUser>().checkIsLiked(post.postId);
    disliked = locator<CurrentUser>().checkIsDisliked(post.postId);
    likes = post.likes;
    dislikes = post.dislikes;
    isSelf = post.author.uid == locator<CurrentUser>().getUID();
    //scrollController.addListener(scrollListener);

    notifyListeners();
  }

  bool isBlockedByMe() {
    return locator<CurrentUser>().blockedUsers.contains(post.author.uid);
  }

  bool blocksMe() {
    return locator<CurrentUser>().blockedBy.contains(post.author.uid);
  }

  void onScrollEnd() async {
    Timer(
      const Duration(milliseconds: 1),
      () {
        final scrollPercentage = scrollController.position.pixels /
            scrollController.position.maxScrollExtent;
        if (post.author.uid == locator<CurrentUser>().getUID()) {
          if (scrollPercentage >= 0.8) {
            scrollToEnd();
          } else {
            scrollToStart();
          }
        } else {
          if (scrollPercentage >= 0.9) {
            scrollToStart();
            if (isLoggedIn()) {
              Provider.of<PostPageController>(context, listen: false)
                  .replyPressed(post.author.username);
            }
          } else {
            scrollToStart();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> scrollToStart() async {
    if (scrollController.offset != 0) {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 80), curve: Curves.linear);
    }
  }

  Future<void> scrollToEnd() async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 80), curve: Curves.linear);
  }

  avatarPressed() async {
    if (post.author.uid != locator<CurrentUser>().getUID()) {
      await context.push("/feed/sub_profile/${post.author.uid}",
          extra: post.author);
      //update post liked in sub menu
      final newvalue = locator<CurrentUser>().checkIsLiked(post.postId);
      if (liked != newvalue) {
        liked = newvalue;
        likes += newvalue ? 1 : -1;
      }
      notifyListeners();
    } else {
      context.go("/profile");
    }
  }

  tagPressed(String username) async {
    if (isLoggedIn()) {
      String? uid = await locator<CurrentUser>().getUidFromUsername(username);
      if (locator<CurrentUser>().getUID() == uid) {
        context.go("/profile");
      } else {
        context.push("/feed/sub_profile/$uid");
      }
    }
  }

  bool isLoggedIn() {
    if (locator<CurrentUser>().getUID() == '') {
      showLogInDialog();
      return false;
    }
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

  void _pop() {
    context.pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _goToLogin() {
    context.go('/');
  }

  void _deletePostFromDialog() async {
    _popDialog();
    Provider.of<PostPageController>(context, listen: false).reduceComments();
    await locator<PostsHandling>()
        .deleteData("posts/${post.rootPostId}/comments/${post.postId}");

    Provider.of<PostPageController>(context, listen: false)
        .removeComment(post.postId);
  }

  void deletePressed() {
    scrollToStart();
    if (DateTime.parse(post.time)
        .toLocal()
        .add(const Duration(hours: 48))
        .difference(DateTime.now())
        .isNegative) {
      //delete
      showMyDialog(
          AppLocalizations.of(context)!.deleteCommentWarningTitle,
          AppLocalizations.of(context)!.deletePostWarningBody,
          [
            AppLocalizations.of(context)!.cancel,
            AppLocalizations.of(context)!.delete
          ],
          [_popDialog, _deletePostFromDialog],
          context);
    } else {
      //too early
      showMyDialog(
          AppLocalizations.of(context)!.tooEarlyDeleteTitle,
          AppLocalizations.of(context)!.tooEarlyDeleteBody,
          [AppLocalizations.of(context)!.ok],
          [_popDialog],
          context);
    }
  }

  likePressed() async {
    //if (post.author.uid != locator<CurrentUser>().getUID()) {
    if (!liking) {
      liking = true;
      liked = locator<CurrentUser>()
          .checkIsLiked(post.postId); //prevent user from double likeing

      if (liked) {
        liked = false;
        //locator<FeedPostCache>().updateLikes(post.postId, -1);
        likes--;
        notifyListeners();
        //undo if it fails. maybe remove this
        if (!await locator<CurrentUser>()
            .removeLike(post.rootPostId!, post.postId)) {
          liked = true;
          //locator<FeedPostCache>().updateLikes(post.postId, 1);
          likes++;
          notifyListeners();
        }
      } else {
        liked = true;
        //locator<FeedPostCache>().updateLikes(post.postId, 1);
        likes++;
        notifyListeners();
        //undo if it fails
        if (!await locator<CurrentUser>()
            .addLike(post.rootPostId!, post.postId)) {
          liked = false;
          //locator<FeedPostCache>().updateLikes(post.postId, -1);
          likes--;
          notifyListeners();
        }
      }
      liking = false;
    }
    //}
  }
  dislikePressed() async {
    //if (post.author.uid != locator<CurrentUser>().getUID()) {
    if (!disliking) {
      disliking = true;
      disliked = locator<CurrentUser>()
          .checkIsDisliked(post.postId); //prevent user from double likeing

      if (disliked) {
        disliked = false;
        //locator<FeedPostCache>().updateLikes(post.postId, -1);
        dislikes--;
        notifyListeners();
        //undo if it fails. maybe remove this
        if (!await locator<CurrentUser>()
            .removeDislike(post.rootPostId!, post.postId)) {
          disliked = true;
          //locator<FeedPostCache>().updateLikes(post.postId, 1);
          dislikes++;
          notifyListeners();
        }
      } else {
        disliked = true;
        //locator<FeedPostCache>().updateLikes(post.postId, 1);
        dislikes++;
        notifyListeners();
        //undo if it fails
        if (!await locator<CurrentUser>()
            .addDislike(post.rootPostId!, post.postId)) {
          disliked = false;
          //locator<FeedPostCache>().updateLikes(post.postId, -1);
          dislikes--;
          notifyListeners();
        }
      }
      liking = false;
    }
    //}
  }
}
