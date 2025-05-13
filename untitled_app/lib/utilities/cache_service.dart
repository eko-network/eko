class PoolService<T> {
  final Map<String, _CacheEntry<T>> _map = {};
  final String Function(T) keySelector;
  final void Function(String) onInsert;
  final Duration? validTime;
  PoolService(
      {required this.keySelector, required this.onInsert, this.validTime});

  void putAll(List<T> items) {
    final now = DateTime.now();
    for (final item in items) {
      final key = this.keySelector(item);
      _map[key] = _CacheEntry(value: item, insertedAt: now);
      this.onInsert(key);
    }
  }

  T? getItem(String key) {
    final item = _map[key];
    // return null if the requested item is not present if it isn't null remove it from the map
    if (item == null) {
      return null;
    } else {
      _map.remove(key);
    }
    // if there is no duration we don't need to check if the data is fresh
    if (this.validTime == null) {
      return item.value;
    }
    // make sure data is fresh
    if (DateTime.now().difference(item.insertedAt) > this.validTime!) {
      return null;
    }
    return item.value;
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime insertedAt;
  const _CacheEntry({required this.value, required this.insertedAt});
}
