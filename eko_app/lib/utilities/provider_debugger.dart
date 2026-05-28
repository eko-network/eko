import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

base class ProviderDebuggerObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    debugPrint('Provider ${context.provider} was initialized');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    debugPrint('Provider ${context.provider} was disposed');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    debugPrint('Provider ${context.provider} updated');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('Provider ${context.provider} threw $error at $stackTrace');
  }
}
