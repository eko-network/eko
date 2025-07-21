import 'package:untitled_app/utilities/like_state.dart';

import '../utilities/supabase_ref.dart';

mixin Likeable {
  bool _isLiking = false;
  String get rpcName;
  int get contentId;
  LikeState get likeState;
  int get likes;
  int get dislikes;
  void copyForLikeable(
      {required LikeState likeState, int? likes, int? dislikes});

  Future<void> likeToggle() async {
    if (_isLiking) return;
    _isLiking = true;
    if (likeState == LikeState.liked) {
      copyForLikeable(likeState: LikeState.none, likes: likes - 1);
      await supabase.rpc(rpcName, params: {
        'p_id': contentId,
        'p_is_liking': false,
        'p_is_dislike': false,
      });
    } else {
      if (likeState == LikeState.disliked) {
        copyForLikeable(
            likeState: LikeState.liked,
            likes: likes + 1,
            dislikes: dislikes - 1);
      } else {
        copyForLikeable(likeState: LikeState.liked, likes: likes + 1);
      }
      await supabase.rpc(rpcName, params: {
        'p_id': contentId,
        'p_is_liking': true,
        'p_is_dislike': false,
      });
    }
    _isLiking = false;
  }

  Future<void> dislikeToggle() async {
    if (_isLiking) return;
    _isLiking = true;
    if (likeState == LikeState.disliked) {
      copyForLikeable(likeState: LikeState.none, dislikes: dislikes - 1);
      await supabase.rpc(rpcName, params: {
        'p_id': contentId,
        'p_is_liking': false,
        'p_is_dislike': true,
      });
    } else {
      if (likeState == LikeState.liked) {
        copyForLikeable(
            likeState: LikeState.disliked,
            likes: likes - 1,
            dislikes: dislikes + 1);
      } else {
        copyForLikeable(likeState: LikeState.disliked, dislikes: dislikes + 1);
      }
      await supabase.rpc(rpcName, params: {
        'p_id': contentId,
        'p_is_liking': true,
        'p_is_dislike': true,
      });
    }
    _isLiking = false;
  }
}
