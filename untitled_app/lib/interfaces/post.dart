import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/activity.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/types/activity.dart';
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

Future<String> uploadPost(PostModel post, WidgetRef ref) async {
  final firestore = FirebaseFirestore.instance;
  // update time (the server should probably do this itself)
  final fixedPost =
      post.copyWith(createdAt: DateTime.now().toUtc().toIso8601String());
  final json = fixedPost.toJson();

  //don't put these in firebase
  json.remove('commentCount');
  json.remove('id');

  // upload
  final postId = await firestore
      .collection('posts')
      .add(json)
      .then((documentSnapshot) => documentSnapshot.id);

  // get users tagged in the post
  final List<Future<String?>> idFutures = [];
  for (int i = 1; i < post.title.length; i += 2) {
    idFutures.add(getUidFromUsername(post.title[i].substring(1)));
  }
  for (int i = 1; i < post.body.length; i += 2) {
    idFutures.add(getUidFromUsername(post.body[i].substring(1)));
  }

  // activity content
  late final String content;
  if (json['title'] != null) {
    content = json['title'];
  } else if (json['body'] != null) {
    content = json['body'];
  } else {
    content = "${json['author']} tagged you in a post";
  }

  final taggedUsers = await Future.wait(idFutures);
  // make sure not to notify yourself
  final Set<String> sentActivites = {ref.watch(currentUserProvider).user.uid};
  final List<Future<void>> activityFutures = [];

  late final Set<String>? members;
  if (post.tags.contains('public')) {
    members = null;
  } else {
    final group = await ref.read(groupProvider(post.tags.first).future);
    members = Set<String>.from(group.members);
  }

  for (final user in taggedUsers) {
    if (user == null) {
      continue;
    }
    if (sentActivites.contains(user)) {
      continue;
    }
    sentActivites.add(user);

    if (members != null && !members.contains(user)) {
      // This is a group post and the tagged user is not it the group.
      continue;
    }

    final activity = ActivityModel(
        id: '',
        createdAt: post.createdAt,
        type: 'tag',
        content: content,
        path: postId,
        sourceUid: post.uid);
    activityFutures.add(uploadActivity(activity, user));
  }

  return postId;
}

Future<String> uploadComment(CommentModel comment, WidgetRef ref) async {
  final firestore = FirebaseFirestore.instance;
  final json = comment.toJson();
  final post = await ref.read(postProvider(comment.postId).future);

  //don't put these in firebase
  json.remove('id');
  json.remove('postId');

  // upload
  final commentId = await firestore
      .collection('posts')
      .doc(comment.postId)
      .collection('comments')
      .add(json)
      .then((documentSnapshot) => documentSnapshot.id);

  if (ref.watch(currentUserProvider).user.uid != post.uid) {
    final activity = ActivityModel(
        id: '',
        createdAt: comment.createdAt,
        type: 'comment',
        content: json['body'] ?? 'Click to see gif',
        path: comment.postId,
        sourceUid: comment.uid);

    uploadActivity(activity, post.uid);
  }

  // get users tagged in the comment
  final List<Future<String?>> idFutures = [];
  for (int i = 1; i < comment.body.length; i += 2) {
    idFutures.add(getUidFromUsername(comment.body[i].substring(1)));
  }

  // activity content
  final String content = json['body'];

  final taggedUsers = await Future.wait(idFutures);

  // make sure not to notify yourself
  final Set<String> sentActivites = {ref.watch(currentUserProvider).user.uid};
  final List<Future<void>> activityFutures = [];

  for (final user in taggedUsers) {
    if (user == null) {
      continue;
    }
    if (sentActivites.contains(user)) {
      continue;
    }
    sentActivites.add(user);

    final activity = ActivityModel(
        id: '',
        createdAt: comment.createdAt,
        type: 'tag',
        content: content,
        path: comment.postId,
        sourceUid: comment.uid);
    activityFutures.add(uploadActivity(activity, user));
  }

  return commentId;
}
