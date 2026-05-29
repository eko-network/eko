import 'package:eko_app/main.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

bool _prefsInitialized = false;

/// One-time test initialization for app-level services used by widget tests.
Future<void> ensureAppHarnessReady() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (_prefsInitialized) return;
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  await PrefsService.init();
  _prefsInitialized = true;
}

/// Pumps [MyApp] with app-level defaults and optional provider overrides.
Future<ProviderContainer> pumpAppHarness(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final container = ProviderContainer(overrides: overrides);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return container;
}
