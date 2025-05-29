import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// todo add to models
class GifData {
  final String url;
  final int width;
  final int height;

  GifData({required this.url, required this.width, required this.height});
}

class GifSearchSection extends StatefulWidget {
  const GifSearchSection({super.key});

  @override
  State<GifSearchSection> createState() => _GifSearchSectionState();
}

class _GifSearchSectionState extends State<GifSearchSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<String> _suggestions = [];
  List<GifData> _gifData = [];
  String _nextPos = '';
  String _error = '';
  String _currentQuery = '';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchGifs('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _nextPos.isNotEmpty) {
        _fetchGifs(_currentQuery, append: true);
      }
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final uri = Uri.https('tenor.googleapis.com', '/v2/autocomplete', {
      'q': query,
      'key': dotenv.env['TENOR_API_KEY'],
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _suggestions = List<String>.from(json['results']);
        });
      } else {
        setState(() => _suggestions = []);
      }
    } catch (_) {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _fetchGifs(String query, {bool append = false}) async {
    if (!append) {
      setState(() {
        _error = '';
        _gifData = [];
        _nextPos = '';
        _currentQuery = query;
      });
    }

    final path = query.isEmpty ? '/v2/featured' : '/v2/search';
    final params = {
      'key': dotenv.env['TENOR_API_KEY'],
      'limit': '20',
      if (query.isNotEmpty) 'q': query,
      if (_nextPos.isNotEmpty) 'pos': _nextPos,
    };

    final uri = Uri.https('tenor.googleapis.com', path, params);

    try {
      setState(() => _isLoadingMore = true);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List;
        setState(() {
          _nextPos = json['next'] ?? '';
          final newGifs = results
              .map((r) {
                // todo christian store the full quality in firebase
                final mediaFormats = r['media_formats'];
                Map<String, dynamic>? chosenFormat =
                    mediaFormats['tinygif'] ?? mediaFormats['gif'];
                if (chosenFormat == null) return null;

                final url = chosenFormat['url'];
                final dims = chosenFormat['dims'];

                if (url == null || dims == null || dims.length < 2) return null;

                return GifData(url: url, width: dims[0], height: dims[1]);
              })
              .whereType<GifData>()
              .toList();
          _gifData = append ? [..._gifData, ...newGifs] : newGifs;
        });
      } else {
        setState(() => _error = 'Failed to load gifs');
      }
    } catch (_) {
      setState(() => _error = 'Failed to load gifs');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _fetchSuggestions,
                  onSubmitted: (value) {
                    _fetchGifs(value.trim());
                    setState(() => _suggestions = []);
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.outlineVariant,
                    hintText: 'Search for gifs',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        if (_suggestions.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _controller.text = suggestion;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: suggestion.length),
                    );
                    setState(() => _suggestions = []);
                    _focusNode.unfocus();
                    _fetchGifs(suggestion.trim());
                  },
                );
              },
            ),
          )
        else if (_error.isNotEmpty)
          Center(child: Text(_error))
        else
          Expanded(
            child: MasonryGridView.count(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: _gifData.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  context.pop(_gifData[index].url);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio:
                            _gifData[index].width / _gifData[index].height,
                        child: Image.network(
                          _gifData[index].url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )),
                ),
              ),
            ),
          )
      ]),
    );
  }
}
