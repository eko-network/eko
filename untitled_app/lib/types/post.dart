import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
part '../generated/types/post.freezed.dart';
part '../generated/types/post.g.dart';

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
abstract class PostModel with _$PostModel {
  @JsonSerializable(explicitToJson: true)
  const factory PostModel({
    required String uid,
    required String id,
    String? gifUrl,
    String? imageString,
    List<String>? title,
    List<String>? body,
    required List<String> tags,
    required int likes,
    required int dislikes,
    required int commentCount,
    required String createdAt,
    required bool isPoll,
    List<String>? pollOptions,
    Map<String, int>? pollVoteCounts,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      //MANUALLY ADD THESE TO THE MAP FOR NOW.//
      commentCount: json['commentCount'] ?? 0,
      id: json['id'] ?? '',
      // ***** //
      createdAt: json['time'],
      isPoll: json['isPoll'] ?? false,
      uid: json['author'] ?? '',
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      tags: List<String>.from(
        json['tags'] ?? ['pulic'],
      ),
      gifUrl: json['gifUrl'],
      imageString: json['image'],
      pollOptions: json['pollOptions'] != null
          ? List<String>.from(json['pollOptions'])
          : null,
      pollVoteCounts: json['pollVoteCounts'] != null
          ? Map<String, int>.from(json['pollVoteCounts'])
          : null,
      //broken
      title: _parseText(json['title']),
      body: _parseText(json['body']),
    );
  }

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  static Future<PostModel> fromFireStoreDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final json = doc.data();
    json['id'] = doc.id;
    json['commentCount'] = await countComments(doc.id);
    return PostModel.fromJson(json);
  }
}
