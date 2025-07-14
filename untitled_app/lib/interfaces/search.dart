import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/utilities/supabase_ref.dart';

class SearchInterface {
  static Future<Iterable<(UserModel, double)>> hitsQuery(String query,
      {required double? similarity,
      required String? uid,
      bool excludeCurrent = false}) async {
    final List<dynamic> response = await supabase.rpc('search_users', params: {
      'p_limit': c.usersOnSearch,
      'p_last_uid': uid,
      'p_last_similarity': similarity,
      'p_search': query,
      'p_exclude_current_user': excludeCurrent
    });
    return response
        .map((map) => (UserModel.fromJson(map), 1.0 * map['similarity']));
  }

  static Future<(List<(String, double)>, bool)> getter(
      List<(String, double)> list, WidgetRef ref, String query,
      {excludeCurrent = false}) async {
    final last = list.isEmpty ? null : list.last;
    final hits = await hitsQuery(query,
        similarity: last?.$2, uid: last?.$1, excludeCurrent: excludeCurrent);
    final List<(String, double)> retList = [];
    for (final hit in hits) {
      ref.read(userPoolProvider).put(hit.$1);
      retList.add((hit.$1.uid, hit.$2));
    }

    return (retList, hits.length < c.usersOnSearch);
  }
}
