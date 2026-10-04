// Hub card sizes: v4 uniform-Large migration, defaults, and the
// Large / Extra Large / Half picker persistence.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/study_layout_provider.dart';

void main() {
  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
  }

  test('defaults are all Large (full, not expanded)', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    for (final c in StudyLayoutNotifier.defaultLayoutV2()) {
      expect(c.span, CardSpan.full, reason: c.id);
      expect(c.expanded, isFalse, reason: c.id);
    }
  });

  test('v3 stored layout migrates to uniform Large', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = PreferencesService(prefs);
    svc.saveStudyLayout(jsonEncode([
      {
        'id': 'dictionary',
        'size': 'medium',
        'span': 'half',
        'version': 3,
      },
      {
        'id': 'commentary',
        'size': 'medium',
        'span': 'quarter',
        'version': 3,
      },
    ]));
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(svc),
      ],
    );
    addTearDown(container.dispose);

    final layout = container.read(studyLayoutProvider);
    final byId = {for (final c in layout) c.id: c};
    // Stored customs reset to Large once...
    expect(byId['dictionary']!.span, CardSpan.full);
    expect(byId['dictionary']!.expanded, isFalse);
    expect(byId['commentary']!.span, CardSpan.full);
    // ...and stored cards survive alongside defaults.
    // (plans_live itself is appended by the hub's _orderedCards merge,
    // covered by the hub widget test.)
    for (final id in ['your_space', 'dictionary', 'commentary']) {
      expect(byId.containsKey(id), isTrue, reason: id);
    }
  });

  test('setCardSize persists span + expanded at version 4', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    container.read(studyLayoutProvider);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('dictionary', span: CardSpan.half, expanded: false);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary',
            span: CardSpan.full, expanded: true);

    var layout = container.read(studyLayoutProvider);
    var byId = {for (final c in layout) c.id: c};
    expect(byId['dictionary']!.span, CardSpan.half);
    expect(byId['commentary']!.expanded, isTrue);

    // Quarter is rejected back to full.
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary',
            span: CardSpan.quarter, expanded: false);
    layout = container.read(studyLayoutProvider);
    byId = {for (final c in layout) c.id: c};
    expect(byId['commentary']!.span, CardSpan.full);

    // Persisted JSON carries version 4.
    final prefs = container.read(preferencesProvider);
    final decoded =
        jsonDecode(prefs.getStudyLayout()!) as List;
    expect(
        decoded.every((e) => (e as Map)['version'] == 4), isTrue);
  });
}
