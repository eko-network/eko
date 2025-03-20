import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../../models/current_user.dart';
import '../../utilities/locator.dart';
import '../../models/post_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../error_snack_bar.dart';
import '../../utilities/constants.dart' as c;

class PostCardController extends ChangeNotifier {
  BuildContext context;
  Post post;
  // late int comments;
  // late int likes;
  late bool liked;
  late bool disliked;
  bool liking = false;
  bool disliking = false;
  bool sharing = false;
  late bool isSelf;
  bool visible = true;
  // Group? group;

  final bool isBuiltFromId;
  PostCardController(
      {required this.context,
      required this.post,
      required this.isBuiltFromId}) {
    _init();
  }
  _init() async {
    //print("test");
    liked = locator<CurrentUser>().checkIsLiked(post.postId);
    disliked = locator<CurrentUser>().checkIsDisliked(post.postId);
    // likes = post.likes;
    // comments = post.commentCount;
    isSelf = post.author.uid == locator<CurrentUser>().getUID();
    notifyListeners();
    // if (!post.tags.contains("public")) {
    //   group = await GroupHandler().getGroupFromId(post.tags.first);
    //   print(group?.name);
    //   notifyListeners();
    // }
  }

  // @override
  // void dispose() {
  //   postMap.remove(post.postId); // Remove from global map
  //   super.dispose();
  //   debugPrint("disposed");
  // }

//FIXME could be optomized
  // void rebuildFeed() {
  //   Provider.of<PaginationController>(context, listen: false).rebuildFunction();
  // }

  void groupBannerPressed() {
    final group = post.group;
    if (group != null) {
      if (group.members.contains(locator<CurrentUser>().getUID())) {
        context.push("/groups/sub_group/${group.id}", extra: group);
      } else {
        showMyDialog(AppLocalizations.of(context)!.notInGroup, "",
            [AppLocalizations.of(context)!.ok], [_popDialog], context,
            dismissable: true);
      }
    }
  }

  // postPressed() {
  //   context.push("/feed/post/${post.postId}", extra: post).then((v) async {
  //     //comments = await locator<PostsHandling>().countComments(post.postId);

  //     rebuildFeed();
  //   });
  // }

  // commentPressed() {
  //   postPressed();
  // }

  bool isBlockedByMe() {
    return locator<CurrentUser>().blockedUsers.contains(post.author.uid);
  }

  bool blocksMe() {
    return locator<CurrentUser>().blockedBy.contains(post.author.uid);
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

  // void rebuild() {
  //   //notifyListeners();
  // }

  // avatarPressed() async {
  //   if (post.author.uid != locator<CurrentUser>().getUID()) {
  //     await context.push("/feed/sub_profile/${post.author.uid}",
  //         extra: post.author);
  //   } else {
  //     context.go("/profile");
  //   }
  // }

  // tagPressed(String username) async {
  //   String? uid = await locator<CurrentUser>().getUidFromUsername(username);
  //   if (locator<CurrentUser>().getUID() == uid) {
  //     context.go("/profile");
  //   } else {
  //     context.push("/feed/sub_profile/$uid");
  //   }
  // }

  sharePressed() async {
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(
          text:
              "Check out my post on Echo: ${c.appURL}/feed/post/${post.postId}"));
      showSnackBar(
          context: context,
          text: AppLocalizations.of(context)!.coppiedToClipboard);
    } else {
      if (!sharing) {
        sharing = true;
        await Share.share(
            'Check out my post on Echo: ${c.appURL}/feed/post/${post.postId}');
        sharing = false;
      }
    }
  }

  likePressed() async {
    if (!liking) {
      //set bool
      liking = true;
      //get action
      liked = locator<CurrentUser>()
          .checkIsLiked(post.postId); //prevent user from double likeing

      if (liked) {
        //set bool
        liked = false;
        //remove like
        post.likes--;
        //also remove from parent if not linked to cache
        // if (isBuiltFromId) {
        //   Provider.of<PostPageController>(context, listen: false)
        //       .changeInternalLikes(-1);
        // }
        // //update cache if present
        // if (post.hasCache) {
        //   locator<FeedPostCache>().updateLikes(post.postId, -1);
        // }

        notifyListeners();
        //undo if it fails. maybe remove this
        if (!await locator<CurrentUser>().removeLike(post.postId, null)) {
          liked = true;
          post.likes++;
          // if (isBuiltFromId) {
          //   Provider.of<PostPageController>(context, listen: false)
          //       .changeInternalLikes(1);
          // }

          // if (post.hasCache) {
          //   locator<FeedPostCache>().updateLikes(post.postId, 1);
          // }

          notifyListeners();
        }
      } else {
        // animation
        // _opacity = 1;
        // notifyListeners();
        // Future.delayed(const Duration(milliseconds: 500), () {
        //   _opacity = 0;
        //   notifyListeners();
        // });

        liked = true;
        //locator<FeedPostCache>().updateLikes(post.postId, 1);
        post.likes++;
        // if (isBuiltFromId) {
        //   Provider.of<PostPageController>(context, listen: false)
        //       .changeInternalLikes(1);
        // }

        // if (post.hasCache) {
        //   locator<FeedPostCache>().updateLikes(post.postId, 1);
        // }

        notifyListeners();
        //undo if it fails
        if (!await locator<CurrentUser>().addLike(post.postId, null)) {
          liked = false;
          //locator<FeedPostCache>().updateLikes(post.postId, -1);
          post.likes--;
          // if (isBuiltFromId) {
          //   Provider.of<PostPageController>(context, listen: false)
          //       .changeInternalLikes(-1);
          // }

          // if (post.hasCache) {
          //   locator<FeedPostCache>().updateLikes(post.postId, -1);
          // }
          notifyListeners();
        }
      }
      //only rebuild from parent here to avoid reseting bool
      // if (isBuiltFromId) {
      //   Provider.of<PostPageController>(context, listen: false).rebuild();
      // }
      liking = false;
    }
  }

  dislikePressed() async {
    if (!disliking) {
      //set bool
      disliking = true;
      //get action
      disliked = locator<CurrentUser>()
          .checkIsDisliked(post.postId); //prevent user from double likeing

      if (disliked) {
        //set bool
        disliked = false;
        //remove like
        post.dislikes--;
        notifyListeners();
        //undo if it fails. maybe remove this
        if (!await locator<CurrentUser>().removeDislike(post.postId, null)) {
          disliked = true;
          post.dislikes++;
          notifyListeners();
        }
      } else {
        // animation
        disliked = true;
        post.dislikes++;
        notifyListeners();
        //undo if it fails
        if (!await locator<CurrentUser>().addDislike(post.postId, null)) {
          disliked = false;
          post.dislikes--;
          notifyListeners();
        }
      }
      disliking = false;
    }
  }
}
