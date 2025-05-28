import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/types/gif_model.dart';
part '../generated/providers/gif_provider.g.dart';

@riverpod
class SelectedGif extends _$SelectedGif {
  @override
  String? build() => null;

  void setGif(String url) => state = url;

  void clear() => state = null;
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@riverpod
class GifUrls extends _$GifUrls {
  List<String> _allGifs = [];
  String _nextPos = '';

  @override
  Future<List<String>> build() async {
    _allGifs = [];
    _nextPos = '';
    return await _fetchGifs();
  }

  Future<List<String>> _fetchGifs() async {
    final query = ref.watch(searchQueryProvider);
    final params = {
      'key': dotenv.env['TENOR_API_KEY'],
      'limit': '20',
      'media_filter': 'gif',
    };

    if (_nextPos.isNotEmpty) {
      params['pos'] = _nextPos;
    }

    final path = query.isEmpty ? '/v2/featured' : '/v2/search';
    if (query.isNotEmpty) {
      params['q'] = query;
    }

    final uri = Uri.https('tenor.googleapis.com', path, params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = TenorResponse.fromJson(json);

      // ✅ Set the new next position from the JSON
      _nextPos = json['next'] ?? '';

      _allGifs.addAll(results.results.map((r) => r.mediaFormats.gif.url));
      return _allGifs;
    }

    throw Exception('GIF fetch failed');
  }
}

@riverpod
class AutocompleteSuggestions extends _$AutocompleteSuggestions {
  @override
  List<String> build() => [];

  Future<void> fetch(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    final uri = Uri.https(
      'tenor.googleapis.com',
      '/v2/autocomplete',
      {
        'q': query,
        'key': dotenv.env['TENOR_API_KEY'],
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = List<String>.from(data['results']);
        state = results;
      } else {
        state = [];
      }
    } catch (e) {
      state = [];
    }
  }

  void clear() => state = [];
}
