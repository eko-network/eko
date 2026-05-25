import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:klipy_dart/klipy_dart.dart';

class GifPicker extends StatefulWidget {
  final void Function(KlipyResultObject) onGifSelected;
  final KlipyClient client;

  const GifPicker({
    super.key,
    required this.onGifSelected,
    required this.client,
  });

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<KlipyResultObject> _gifs = [];
  bool _isLoading = false;
  String? _nextPos;
  String _currentQuery = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTrending();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_isLoading &&
        _nextPos != null) {
      _loadMoreGifs();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchGifs(query);
    });
  }

  Future<void> _loadTrending() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _nextPos = null;
      _gifs.clear();
    });

    try {
      final response = await widget.client.featured();
      if (mounted) {
        setState(() {
          _gifs = response?.results ?? [];
          _nextPos = response?.next;
          _currentQuery = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading trending GIFs: $e');
    }
  }

  Future<void> _searchGifs(String query) async {
    if (_isLoading) {
      return;
    }
    if (query.isEmpty) {
      _loadTrending();
      return;
    }

    setState(() {
      _isLoading = true;
      _nextPos = null;
      _gifs.clear();
    });

    try {
      final response = await widget.client.search(query);
      if (mounted) {
        setState(() {
          _gifs = response?.results ?? [];
          _nextPos = response?.next;
          _currentQuery = query;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error searching GIFs: $e');
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_nextPos == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = _currentQuery.isEmpty
          ? await widget.client.featured(pos: _nextPos)
          : await widget.client.search(_currentQuery, pos: _nextPos);

      if (mounted) {
        setState(() {
          final newResults = response?.results ?? [];
          _gifs.addAll(newResults);
          _nextPos = response?.next;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading more GIFs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.primary.withValues(alpha: 0.1),
              hintText: 'Search GIFs',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _searchGifs(value);
            },
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: _gifs.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  itemCount: _nextPos != null ? _gifs.length + 1 : _gifs.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) {
                    if (index >= _gifs.length) {
                      return _nextPos != null
                          ? _buildLoadingItem(colorScheme)
                          : Container();
                    }
                    return _buildGifItem(_gifs[index], colorScheme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingItem(ColorScheme colorScheme) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
    );
  }

  Widget _buildGifItem(KlipyResultObject gif, ColorScheme colorScheme) {
    final mediaObj = gif.media.tinyGif ?? gif.media.gif;
    final url = mediaObj?.url;
    if (url == null) return const SizedBox();

    double aspectRatio = 1.0;
    try {
      aspectRatio = mediaObj?.dimensions.aspectRatio ?? 1.0;
    } catch (_) {
      aspectRatio = 1.0;
    }

    return GestureDetector(
      onTap: () => widget.onGifSelected(gif),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: colorScheme.primary.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white54),
              );
            },
          ),
        ),
      ),
    );
  }
}
