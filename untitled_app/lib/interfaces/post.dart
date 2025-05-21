import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/types/post.dart';

Future<int> countComments(String postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .count()
      .get()
      .then((value) => value.count ?? 0, onError: (e) => 0);
}

// Converts a String to the List<String> eko tag format.
List<String> parseTextToTags(String? text) {
  if (text == null) return [];

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

Future<String> uploadPost(PostModel post) async {
  final firestore = FirebaseFirestore.instance;
  // update time (the server should probably do this itself)
  final fixedPost =
      post.copyWith(createdAt: DateTime.now().toUtc().toIso8601String());
  final json = fixedPost.toJson();

  //don't put these in firebase
  json.remove('commentCount');
  json.remove('id');
  final postId = await firestore
      .collection('posts')
      .add(json)
      .then((documentSnapshot) => documentSnapshot.id);
  return postId;
}
