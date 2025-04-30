import 'package:untitled_app/custom_widgets/post_card.dart';
import 'package:untitled_app/models/post_handler.dart' show Post;

Map<String, PostCard> postMap = {};

class Cache {
  List<dynamic> items;
  bool end;
  Cache({required this.items, required this.end});
}

class FeedPostCache {
  Cache groupsCache = Cache(end: false, items: []);
  Cache profileCache = Cache(end: false, items: []);
  List<Cache> postsList =
      List.generate(3, (index) => Cache(items: [], end: false));

  void addPost(int index, Post post) {
    postsList[index].items.insert(0, post);
  }

  void clearFeedCache() {
    postsList = List.generate(3, (index) => Cache(items: [], end: false));
  }

  void clearGroupProfileCache() {
    groupsCache = Cache(end: false, items: []);
    profileCache = Cache(end: false, items: []);
  }

  //TODO review, considor other solutions
  // updateLikes(String id, int offset) {
  //   for (Cache element in postsList) {
  //     for (Post post in element.items) {
  //       if (post.postId == id) {
  //         post.likes += offset;
  //         break; //assumes each post is only in each list one time
  //       }
  //     }
  //   }
  // }

  // updateComments(String id, int offset) {
  //   for (Cache element in postsList) {
  //     for (Post post in element.items) {
  //       if (post.postId == id) {
  //         post.commentCount += offset;
  //         break; //assumes each post is only in each list one time
  //       }
  //     }
  //   }
  // }

  void removePostFromAllCaches(String id) {
    for (Cache element in postsList) {
      element.items.removeWhere((post) {
        post as Post;
        return post.postId == id;
      });
    }
    profileCache.items.removeWhere((post) {
      post as Post;
      return post.postId == id;
    });
  }
}
