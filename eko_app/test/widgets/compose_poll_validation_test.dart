import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/post_preview_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/views/compose_page.dart';
import 'package:eko_app/widgets/posts/poll_creator.dart';
import 'package:eko_app/widgets/posts/poll_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

class _PostPreviewDisabled extends PostPreview {
  @override
  bool build() => false;
}

class _PostPreviewEnabled extends PostPreview {
  @override
  bool build() => true;
}

Future<void> _pumpCompose(
  WidgetTester tester, {
  bool postPreviewEnabled = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final container = ProviderContainer(
    overrides: [
      ...signedInNavigationOverrides(),
      postPreviewProvider.overrideWith(
        postPreviewEnabled ? _PostPreviewEnabled.new : _PostPreviewDisabled.new,
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('hi'),
          Locale('id'),
        ],
        home: const ComposePage(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _addPoll(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.poll));
  await tester.pumpAndSettle();
}

Future<void> _post(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Post').last);
  await tester.pump();
}

void main() {
  setUpAll(ensureNavigationTestPrefs);

  testWidgets('poll requires at least two filled options', (tester) async {
    await _pumpCompose(tester);
    await _addPoll(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Yes');
    await _post(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(TextButton).last),
    )!;
    expect(find.text(l10n.needTwoOptions), findsOneWidget);
  });

  testWidgets('poll rejects blank options', (tester) async {
    await _pumpCompose(tester);
    await _addPoll(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Yes');
    await tester.enterText(find.byType(TextFormField).at(1), 'No');
    await tester.tap(find.widgetWithText(TextButton, 'Add option'));
    await tester.pump();

    await _post(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(TextButton).last),
    )!;
    expect(find.text(l10n.blankPollOption), findsOneWidget);
  });

  testWidgets('poll add option button stops at max options', (tester) async {
    await _pumpCompose(tester);
    await _addPoll(tester);

    while (find
        .widgetWithText(TextButton, 'Add option')
        .evaluate()
        .isNotEmpty) {
      await tester.tap(find.widgetWithText(TextButton, 'Add option'));
      await tester.pump();
    }

    expect(find.byType(TextFormField), findsNWidgets(c.maxPollOptions));
    expect(find.widgetWithText(TextButton, 'Add option'), findsNothing);
  });

  testWidgets('poll rejects too many options', (tester) async {
    await _pumpCompose(tester);
    await _addPoll(tester);

    final pollOptions = tester
        .widget<PollCreator>(find.byType(PollCreator))
        .pollOptions;
    pollOptions
      ..clear()
      ..addAll([for (var i = 0; i < c.maxPollOptions + 1; i++) 'Option $i']);

    await _post(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(TextButton).last),
    )!;
    expect(find.text(l10n.tooManyPollOptions), findsOneWidget);
  });

  testWidgets('post preview renders poll options', (tester) async {
    await _pumpCompose(tester, postPreviewEnabled: true);
    await _addPoll(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Yes');
    await tester.enterText(find.byType(TextFormField).at(1), 'No');
    await _post(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(PollWidget), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('Yes')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('No')),
      findsOneWidget,
    );
  });
}
