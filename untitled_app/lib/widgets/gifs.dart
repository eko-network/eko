import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/gif_provider.dart';

class GifAutocompleteWidget extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const GifAutocompleteWidget({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(autocompleteSuggestionsProvider);

    return Expanded(
        child: ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            controller.text = suggestion;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: suggestion.length),
            );
            ref.read(searchQueryProvider.notifier).setQuery(suggestion.trim());
            ref.read(autocompleteSuggestionsProvider.notifier).clear();
            focusNode.unfocus();
          },
        );
      },
    ));
  }
}

class GifSearchSection extends ConsumerStatefulWidget {
  const GifSearchSection({super.key});
  @override
  ConsumerState<GifSearchSection> createState() => _GifSearchSectionState();
}

class _GifSearchSectionState extends ConsumerState<GifSearchSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final autocompletes = ref.watch(autocompleteSuggestionsProvider);
    final gifsAsync = ref.watch(gifUrlsProvider);

    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    ref
                        .read(autocompleteSuggestionsProvider.notifier)
                        .fetch(value.trim());
                  },
                  onSubmitted: (value) {
                    ref
                        .read(searchQueryProvider.notifier)
                        .setQuery(value.trim());
                    ref.read(autocompleteSuggestionsProvider.notifier).clear();
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.outlineVariant,
                    hintText: 'Search for gifs',
                    prefixIcon: Icon(Icons.search),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 9,
        ),
        autocompletes.isNotEmpty
            ? GifAutocompleteWidget(
                controller: _controller,
                focusNode: _focusNode,
              )
            : GifResultsList(
                gifsAsync: gifsAsync,
              )
      ],
    ));
  }
}

class GifResultsList extends ConsumerWidget {
  final AsyncValue<List<String>> gifsAsync;
  const GifResultsList({super.key, required this.gifsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoCompleteSuggestions = ref.watch(autocompleteSuggestionsProvider);

    if (autoCompleteSuggestions.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return gifsAsync.when(
      data: (gifs) => gifs.isEmpty
          ? Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No GIFs found.',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            )
          : Expanded(
              child: MasonryGridView.count(
                padding: const EdgeInsets.only(bottom: 16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: gifs.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    ref.read(selectedGifProvider.notifier).setGif(gifs[index]);
                    context.pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        gifs[index],
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Failed to load GIF',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading GIFs: $err')),
    );
  }
}
