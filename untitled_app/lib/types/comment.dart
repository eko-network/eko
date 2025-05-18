import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:untitled_app/interfaces/comment.dart';
part '../generated/types/comment.freezed.dart';
part '../generated/types/comment.g.dart';

List<String>? _parseText(String? text) {
  if (text == null) return null;

  // const String userNameReqs = c.userNameReqs;
  // RegExp regExp = RegExp('(@$userNameReqs\\b)', caseSensitive: false);
  RegExp regExp = RegExp(r'@[a-z0-9_]{3,24}', caseSensitive: false);

  List<String> chunks = [];
  int lastEnd = 0;

  regExp.allMatches(text).forEach((match) {
    // Add the chunk of text before the match to the list
    String precedingText = text.substring(lastEnd, match.start);
    if (precedingText.isNotEmpty) {
      chunks.add(precedingText);
    } else if (chunks.isNotEmpty && chunks.last.startsWith('@')) {
      // If the last chunk was a username, add an empty string
      chunks.add('');
    }

    // Add the match itself
    chunks.add(match.group(0)!);
    lastEnd = match.end;
  });

  // If there's any text left after the last match, add this remaining text to the list
  if (lastEnd < text.length) {
    chunks.add(text.substring(lastEnd));
  }

  return chunks;
}

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();

  @JsonSerializable(explicitToJson: true)
  const factory CommentModel({
    required String uid,
    required String id,
    required String postId,
    String? gifUrl,
    List<String>? body,
    required int likes,
    required int dislikes,
    required String createdAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      //MANUALLY ADD THESE TO THE MAP FOR NOW.//
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      // ***** //
      createdAt: json['time'],
      uid: json['author'] ?? '',
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      gifUrl: json['gifUrl'],
      body: _parseText(json['body']),
    );
  }

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  static Future<CommentModel> fromFireStoreDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final json = doc.data();
    json['id'] = doc.id;
    json['postId'] = doc.reference.parent.parent?.id;
    return CommentModel.fromJson(json);
  }
}
