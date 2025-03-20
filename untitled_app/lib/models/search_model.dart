import 'dart:convert';
import 'package:http/http.dart' as http;
import 'users.dart';
import "../utilities/constants.dart" as c;
import '../models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchModel {
  Future<List<AppUser>> hitsQuery(String query, {int page = 0}) async {
    final response = await http.post(
      Uri.parse(
          'https://${dotenv.env["ALGOLIA_APP_ID"]!}-dsn.algolia.net/1/indexes/users/query'),
      headers: <String, String>{
        'X-Algolia-API-Key': dotenv.env["SEARCH_API_KEY"]!,
        'X-Algolia-Application-Id': dotenv.env["ALGOLIA_APP_ID"]!,
      },
      body: jsonEncode(<String, String>{
        'params': 'query=$query&hitsPerPage=${c.usersOnSearch}&page=$page',
      }),
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body)['hits'] as List)
          .map((i) => AppUser.fromJson(i, page: page))
          .toList();
    } else {
      return [];
    }
  }

  dynamic startAfterQuery(dynamic lastUser) {
    lastUser as AppUser;
    if (lastUser.pageIndex == null) {
      return 0;
    } else {
      return lastUser.pageIndex! + 1;
    }
  }

  Future<PaginationGetterReturn> getter(
      int page, String query, bool removeUser) async {
    //page = page ?? 0;
    List<AppUser> list = await hitsQuery(query, page: page);
    //remove current user
    int offset = 0; //controls end logic
    if (removeUser) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].uid == locator<CurrentUser>().getUID()) {
          list.removeAt(i);
          offset = 1;
          break;
        }
      }
    }

    return PaginationGetterReturn(
        end: (list.length < (c.usersOnSearch - offset)), payload: list);
  }
}
