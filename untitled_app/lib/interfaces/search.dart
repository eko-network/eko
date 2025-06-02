import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class SearchInterface {
  static Future<List<MapEntry<String, int>>> hitsQuery(String query,
      {required int page}) async {
    final response = await http.post(
      Uri.parse(
          'https://${dotenv.env["ALGOLIA_APP_ID"]!}-dsn.algolia.net/1/indexes/users/query'),
      headers: <String, String>{
        'X-Algolia-API-Key': dotenv.env['SEARCH_API_KEY']!,
        'X-Algolia-Application-Id': dotenv.env['ALGOLIA_APP_ID']!,
      },
      body: jsonEncode(<String, String>{
        'params': 'query=$query&hitsPerPage=${c.usersOnSearch}&page=$page',
      }),
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body)['hits'] as List)
          .map<MapEntry<String, int>>(
              (item) => MapEntry(UserModel.fromJson(item).uid, page))
          .toList();
    } else {
      return [];
    }
  }

  static Future<(List<MapEntry<String, int>>, bool)> getter(
      List<MapEntry<String, int>> list, WidgetRef ref, String query) async {
    final hits =
        await hitsQuery(query, page: list.isEmpty ? 0 : list.last.value + 1);
    int offset = 0;
    final List<Future<UserModel>> asyncUsers = [];
    for (final obj in hits) {
      if (obj.key == ref.watch(currentUserProvider).user.uid) {
        offset++;
        continue;
      }
      asyncUsers.add(ref.read(userProvider(obj.key).future));
    }
    await Future.wait(asyncUsers);
    return (hits, hits.length < c.usersOnSearch - offset);
  }
}
