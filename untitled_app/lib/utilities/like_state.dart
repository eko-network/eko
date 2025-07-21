import 'package:json_annotation/json_annotation.dart';

enum LikeState {
  liked,
  disliked,
  none;

  static LikeState fromJson(Map<String, dynamic> json) {
    if (json['is_liked'] as bool? ?? false) {
      return LikeState.liked;
    } else if (json['is_disliked'] as bool? ?? false) {
      return LikeState.disliked;
    } else {
      return LikeState.none;
    }
  }
}

class LikeStateConverter
    implements JsonConverter<LikeState, Map<String, dynamic>> {
  const LikeStateConverter();

  @override
  LikeState fromJson(Map<String, dynamic> json) {
    return LikeState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(LikeState state) {
    return {
      'is_liked': state == LikeState.liked,
      'is_disliked': state == LikeState.disliked,
    };
  }
}
