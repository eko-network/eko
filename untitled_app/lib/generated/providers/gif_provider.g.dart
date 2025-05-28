// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/gif_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedGifHash() => r'426ef4eb3a65eafe3877c6bcb72c963bd9a1ec7a';

/// See also [SelectedGif].
@ProviderFor(SelectedGif)
final selectedGifProvider =
    AutoDisposeNotifierProvider<SelectedGif, String?>.internal(
  SelectedGif.new,
  name: r'selectedGifProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedGifHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedGif = AutoDisposeNotifier<String?>;
String _$searchQueryHash() => r'3c36752ee11b18a9f1e545eb1a7209a7222d91c9';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
String _$gifUrlsHash() => r'a47b5ee9179f5562e077eb90f5b81634d5187581';

/// See also [GifUrls].
@ProviderFor(GifUrls)
final gifUrlsProvider =
    AutoDisposeAsyncNotifierProvider<GifUrls, List<String>>.internal(
  GifUrls.new,
  name: r'gifUrlsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gifUrlsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GifUrls = AutoDisposeAsyncNotifier<List<String>>;
String _$autocompleteSuggestionsHash() =>
    r'666c4c64154b1357a0ab1ad8601c27c73bb46c86';

/// See also [AutocompleteSuggestions].
@ProviderFor(AutocompleteSuggestions)
final autocompleteSuggestionsProvider =
    AutoDisposeNotifierProvider<AutocompleteSuggestions, List<String>>.internal(
  AutocompleteSuggestions.new,
  name: r'autocompleteSuggestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autocompleteSuggestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutocompleteSuggestions = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
